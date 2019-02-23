--------------------------------------------------------------------
--------------------------------------------------------------------
--
-- VHDL module for I2C Peripheral/Slave
--
-- Taken from a Verilog version (see below):
--
--  Alacron Inc. - Confidential: All Rights Reserved
--  Copyright (C) 2003
--
--  Title       : I2C Slave Control Logic
--  File        : I2CSLAVE.v
--  Author      : Gabor Szakacs
--  Created     : 25-May-2004 - Adapted from I2CSLAVE.abl
--
--------------------------------------------------------------------
--  Description :
-- This code implements an I2C slave-only controller.
-- Access to internal registers uses the sub-address
-- protocol like a serial EEPROM.  No registers are
-- implemented in this module, however the module
-- provides a simple bus interface to external registers.
-- GLS - 12/13/00

-- I2C inputs are oversampled by clk_in, which should run
-- at a minimum of 5 MHz for a 100 KHz I2C bus.  The
-- debouncing on the inputs has been tested at up to 80 MHz.
-- The I2C 7-bit device address is set by i2c_address.  Address
-- 0x6A was selected for FastImage because it doesn't
-- conflict with other devices on board.

-- Three 8-bit buses are implemented for read data, write
-- data and subaddress.  For a simple implementation where
-- only one 8-bit register is required, the subaddress may
-- be used as the register output using simple write and
-- read protocol on the I2C bus.  In this case looping the
-- subaddress output to the read data bus allows register
-- read-back.

-- For use with multiple internal registers, the subaddress
-- provides the register address.  The rd_wr_out output indicates
-- the direction of the current I2C bus transaction and may
-- be used to enable read data onto an externally combined
-- read/write data bus.  The wr_pulse_out signal can be used as
-- an active-high latch enable or clock enable for the
-- external registers.  It comes on for one period of clk_in
-- and the subaddress and data are valid for at least one
-- clk_in period before and after wr_pulse_out.

-- A rd_pulse_out output goes high for one clk_in period at the
-- beginning of each data byte read.  This indicates the
-- time when external data is latched from the read data
-- bus.  It may be used to create side-effects on read
-- such as clearing sticky status bits.
--
--------------------------------------------------------------------
--------------------------------------------------------------------
LIBRARY IEEE ;
USE IEEE.STD_LOGIC_1164.ALL ;
USE IEEE.NUMERIC_STD.ALL ;
use IEEE.std_logic_misc.all;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity i2c_slave2 is
  
	port (
	      CLR_IN		: in STD_ULOGIC; -- Active high, async clear/reset
	      CLK_IN		: in STD_ULOGIC; -- Fast system clock > 10MHz
	      I2C_ADDRESS	: in STD_ULOGIC_VECTOR(7 DOWNTO 1); -- I2C Slave address
	      											        -- Set s what I2C address 
	      											        -- the block will respond to
	      
	      RD_BUS_IN		: in STD_ULOGIC_VECTOR(7 DOWNTO 0); -- Parallel read data
	      
	      SCL_IN		: in STD_ULOGIC; -- I2C Serial Clock from pin
	      SDA_IO_IN		: in STD_ULOGIC; -- I2C Serial data input from pin
	      
	      SDA_IO_OUT	: out STD_ULOGIC; -- I2C Serial data output to pin
	      								  -- When '1', SDA pin must be driven low
	      								  -- When '0', SDA pin must be High 'Z'
	      
	      SUBADDR_OUT	: out STD_ULOGIC_VECTOR(7 DOWNTO 0); -- Parallel Address Bus
	      WRITE_BUS_OUT : out STD_ULOGIC_VECTOR(7 DOWNTO 0); -- Parallel Write data
	      
	      WRITE_PULSE_OUT : out STD_ULOGIC; -- One CLK_IN long, active high write pulse.
	      READ_PULSE_OUT  : out STD_ULOGIC; -- One CLK_IN long, active high read pulse.
	      READ_WRITE_OUT  : out STD_ULOGIC  -- Read/not(write) output signal
		  );

end i2c_slave2;

-- purpose: Behavioral discription
architecture RTL of i2c_slave2 is
  
    -- you can't re-use and output!  So you need to create local versions
	
	SIGNAL sda_sr					: STD_ULOGIC_VECTOR(3 DOWNTO 0); -- Input debounce shifter for SDA
	SIGNAL scl_sr					: STD_ULOGIC_VECTOR(3 DOWNTO 0); -- Input debounce shifter for SCL
	
	SIGNAL sda_i					: STD_ULOGIC; -- Debounced version of SDA input
	SIGNAL scl_i					: STD_ULOGIC; -- Debounced version of SCL input
	
	SIGNAL was_sda_i				: STD_ULOGIC; -- Retimed versions; used in edge detection
	SIGNAL was_scl_i				: STD_ULOGIC; -- Retimed versions; used in edge detection	
	
	SIGNAL read_pulse_i				: STD_ULOGIC; -- Internal version of output
	SIGNAL write_pulse_i			: STD_ULOGIC; -- Internal version of output	
	SIGNAL read_pulse_delayed_i		: STD_ULOGIC; -- Internal version of output retimed
	SIGNAL write_pulse_delayed_i	: STD_ULOGIC; -- Internal version of output	retimed

  -- Signals used by the internal process
	SIGNAL i2c_start				: STD_ULOGIC; -- When high, a I2C 'start' as been detencted
	SIGNAL i2c_stop					: STD_ULOGIC; -- High for one CLK_IN - indicates a I2C stop
	SIGNAL byte_count				: UNSIGNED(3 DOWNTO 0); -- Counts bits on I2C Bytes
	SIGNAL ack_cyc					: STD_ULOGIC; -- High for one SCL period and = byte_count(3)
	SIGNAl addr_byte				: STD_ULOGIC; -- High during I2C address byte
	SIGNAL addr_ack					: STD_ULOGIC; -- High during address byte acknowledge bit
	SIGNAL subadd_byte				: STD_ULOGIC; -- High during sub address I2C byte
	SIGNAL subadd_ack				: STD_ULOGIC; -- High during sub address byte acknowledge bit
	SIGNAL data_byte				: STD_ULOGIC; -- High during a I2C data data_byte
	
	SIGNAL was_ack_cyc				: STD_ULOGIC; -- Retimed version of ack_cyc
	SIGNAL my_cyc					: STD_ULOGIC; -- Set high when I2C address matches I2C_ADDRESS
	
	SIGNAL in_sr					: STD_ULOGIC_VECTOR(7 DOWNTO 0); -- Shifter for incoming byte
	SIGNAL out_sr					: STD_ULOGIC_VECTOR(7 DOWNTO 0); -- Shifter for outgoing byte

	SIGNAL subadd_out_i				: STD_LOGIC_VECTOR (7 DOWNTO 0); -- Shifter for outgoing byte
	SIGNAL read_not_write_out_i		: STD_ULOGIC; -- Internal version of READ_WRITE_OUT output
	
begin  -- RTL

	-- Output assignments
	SUBADDR_OUT 		<= STD_ULOGIC_VECTOR(subadd_out_i);
	WRITE_PULSE_OUT 	<= write_pulse_i;
	READ_PULSE_OUT  	<= read_pulse_i;
	READ_WRITE_OUT  	<= read_not_write_out_i;
  
	-- Processes

------------------------------------------------------------------------
-- Debounce, then delay debounced signals for edge detection
------------------------------------------------------------------------
	input_debounce : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
	  		sda_sr 		<= "1111"; -- Reset the SDA SR to all '1's
	  		sda_i  		<= '1';  -- Reset the internal SDA signal to '1'
	  		was_sda_i	<= '0'; -- Reset the retimed bit to '0'
	  		scl_sr 		<= "1111"; -- Reset the SCL SR to all '1's
	  		scl_i  		<= '1';  -- Reset the internal SCL signal to '1'
	  		was_scl_i	<= '0'; -- Reset the retimed bit to '0'
		ELSIF (RISING_EDGE(CLK_IN)) THEN
			-- Shift in SDA and debounce
			sda_sr(3 DOWNTO 1) <= sda_sr(2 DOWNTO 0);
			sda_sr(0) <= SDA_IO_IN;
			
			IF (sda_sr = "0000") THEN
			  sda_i <= '0';
			ELSIF (sda_sr = "1111") THEN
			  sda_i <= '1';
			ELSE
			  sda_i <= sda_i;
			END IF;
			
			was_sda_i <= sda_i; -- Retimed for edge detection 	  		
	  		
			-- Shift in SCL and debounce
			scl_sr(3 DOWNTO 1) <= scl_sr(2 DOWNTO 0);
			scl_sr(0) <= SCL_IN;
			
			IF (scl_sr = "0000") THEN
			  scl_i <= '0';
			ELSIF (scl_sr = "1111") THEN
			  scl_i <= '1';
			ELSE -- not strictly necessary
			  scl_i <= scl_i;
			END IF;
			
			was_scl_i <= scl_i; -- Retimed for edge detection
		END IF;
		
	END PROCESS input_debounce; 	  		
	  		
-------------------------------------------------------------------
-- Detect start and stop conditions on I2C bus:
-------------------------------------------------------------------
	start_stop_detect : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			i2c_start	<= '0';
			i2c_stop	<= '0';
		ELSIF (RISING_EDGE(CLK_IN)) THEN
		  -- Falling edge on SDA with SCL high is an I2C start
		  IF (scl_i = '1' AND was_scl_i = '1' AND 
		      sda_i = '0' AND was_sda_i = '1') THEN
		        i2c_start <= '1';
		  -- hold high until SCL goes low
		  ELSIF (scl_i = '0' AND was_scl_i = '0') THEN
		  	    i2c_start <= '0';
		  ELSE -- not strictly necessary
		        i2c_start <= i2c_start;
		  END IF;
		  
		  -- Detect a I2C stop
		  -- SDA low to high with SCL high 
		  -- i2c_stop only goes high for one CLK_IN period
		  IF (scl_i = '1' AND was_scl_i = '1' AND
		      sda_i = '1' AND was_sda_i = '0') THEN
		        i2c_stop <= '1';
		  ELSE -- not strictly necessary
		        i2c_stop <= '0';
		  END IF;
		END IF;
				  
	END PROCESS start_stop_detect;
	  		
------------------------------------------------------
-- Increment bit counter on falling edges of the
-- SCL signal after the first in a packet.
-- Count bit position within bytes:
--
-- The MSB of byte_count = ack_cyc as it is high for
-- the ninth bit in a shift.
-- Stays high for one SCL period, falling edge to falling
-- edge
------------------------------------------------------
	bits_in_bytes : PROCESS (CLR_IN, CLK_IN, i2c_start, byte_count)
	  BEGIN
	  	IF (CLR_IN = '1' or i2c_start = '1') THEN
			--ack_cyc		<= '0';
			byte_count	<= (OTHERS => '0');
		ELSIF (RISING_EDGE(CLK_IN)) THEN
		  -- Detect a falling edge on SCL
	  	  IF (scl_i = '0' AND was_scl_i = '1') THEN
	  	    -- If the MSB of byte_count goes high,
	  	    -- clear the byte counter
	  	    -- else inc the byte counter
	  	    IF (byte_count = 8) THEN
	  	      byte_count <= (OTHERS => '0');
	  	    ELSE
	  	      byte_count <= byte_count + 1;
	  	    END IF;
	  	  ELSE -- not strictly necessary
	  	      byte_count <= byte_count;
	  	  END IF;
	  	END IF;
	  	
	  	ack_cyc <= byte_count(3);
	  	
	 END PROCESS bits_in_bytes;
	 
------------------------------------------------------
-- For edge detection of ack cycles:
------------------------------------------------------
	ack_detect : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			was_ack_cyc	<= '0';
		ELSIF (RISING_EDGE(CLK_IN)) THEN
		  was_ack_cyc <= ack_cyc;
		END IF;
	
	END PROCESS	ack_detect;
	
------------------------------------------------------
-- The main decision process as it decides what to do at
-- each process step boundry
------------------------------------------------------
	decision_maker : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
	  		-- Zero all the process flags
			addr_byte		<= '0';
			addr_ack		<= '0';
			subadd_byte		<= '0';
			subadd_ack		<= '0';
			data_byte		<= '0';
			read_pulse_i	<= '0';
			write_pulse_i	<= '0';
		ELSIF (RISING_EDGE(CLK_IN)) THEN
      	  -- addr_byte is on during the first byte transmitted after
      	  -- a START condition.
  	  	  IF (i2c_start = '1') THEN
  	  	    addr_byte <= '1';
  	  	  ELSIF (ack_cyc = '1') THEN
  	  	    addr_byte <= '0';
  	  	  ELSE
  	  	    addr_byte <= addr_byte;
  	  	  END IF;
	  		
      	  -- addr_ack is on during acknowledge cycle of the address
      	  -- byte.
      	  IF (addr_byte = '1' AND ack_cyc = '1') THEN
      	    addr_ack <= '1';
      	  ELSIF (ack_cyc = '0') THEN
      	    addr_ack <= '0';
      	  ELSE
      	    addr_ack <= addr_ack;
      	  END IF;
      	  
      	  -- subad_byte is on for the second byte of my write cycle.
	  	  IF (addr_ack = '1' AND ack_cyc = '0' AND
	  	      read_not_write_out_i = '0' AND my_cyc = '1') THEN
	  	        subadd_byte <= '1';
	  	  ELSIF (ack_cyc = '1') THEN
	  	        subadd_byte <= '0';
	  	  ELSE
	  	        subadd_byte <= subadd_byte;
	  	  END IF;

      	  -- subad_ack is on during the acknowledge cycle of the
      	  -- subaddress byte.
      	  IF (subadd_byte = '1' AND ack_cyc = '1') THEN
      	    subadd_ack <= '1';
      	  ELSIF (ack_cyc = '0') THEN
      	    subadd_ack <= '0';
      	  ELSE
      	    subadd_ack <= subadd_ack;
      	  END IF;

      	  -- data_byte is on for my read or write data cycles.  This is
      	  -- any read cycle after the address, or write cycles after
      	  -- the subaddress.  It remains on until the I2C STOP event or
      	  -- any NACK.
	  	  IF ((addr_ack = '1' AND ack_cyc = '0' AND
	  	       read_not_write_out_i = '1' AND my_cyc = '1')
	  	      OR
	  	      (subadd_ack = '1' AND ack_cyc = '0')) THEN
	  	           data_byte <= '1';
	  	  ELSIF ((i2c_stop = '1') 
	  	         OR 
	  	         (ack_cyc = '1' AND scl_i = '1' AND sda_i = '1')) THEN
	  	           data_byte <= '0';
	  	  ELSE
	  	           data_byte <= data_byte;
	  	  END IF;  	

    	  -- wr_pulse_out is on for one clock cycle while the data
      	  -- on the output bus is valid.
      	  IF (data_byte = '1' AND ack_cyc = '0' AND
      	      was_ack_cyc = '1' AND read_not_write_out_i = '0') THEN
      	        write_pulse_i <= '1';
      	  ELSE
      	        write_pulse_i <= '0';
      	  END IF;
  	  		
      	  -- rd_pulse_out is on for one clock cycle when external
      	  -- read data is transfered into the output shift register
      	  -- for transmission to the I2C bus.
  	  	  IF ((addr_ack = '1' AND ack_cyc = '0' AND
  	  	       read_not_write_out_i = '1' AND my_cyc = '1')
  	  	      OR
  	  	      (data_byte = '1' AND ack_cyc = '0' AND
  	  	       was_ack_cyc = '1' AND read_not_write_out_i = '1')) THEN
  	  	         read_pulse_i <= '1';
  	  	  ELSE
  	  	         read_pulse_i <= '0';
  	  	  END IF;
  	    END IF;                
  	    
	END PROCESS decision_maker; 
	  		
----------------------------------------------------
-- wr_bus_7_0_out is loaded from the I2C input S/R at the
-- end of each write data cycle.
------------------------------------------------------
	set_the_write_out_bus : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			WRITE_BUS_OUT	<= X"00";
		ELSIF (RISING_EDGE(CLK_IN)) THEN	  		
	  	  IF (data_byte = '1' AND ack_cyc = '1' AND
	  	      was_ack_cyc = '0' and read_not_write_out_i = '0') THEN
	  	        WRITE_BUS_OUT <= in_sr;
--	  	  ELSE
--	  	        WRITE_BUS_OUT <= WRITE_BUS_OUT;
	  	  END IF;
	  	END IF;
	 
	 END PROCESS set_the_write_out_bus;	
	  		
------------------------------------------------------
-- out_sr shifts data out to the I2C bus during read
-- data cycles.  Transitions occur after the falling
-- edge of SCL.  Fills with 1's from right.
------------------------------------------------------
    load_the_read_byte : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			out_sr	<= X"FF";
		ELSIF (RISING_EDGE(CLK_IN)) THEN	  		
      	  IF (read_pulse_i = '1') THEN
      	    out_sr <= RD_BUS_IN;
      	  ELSIF (scl_i = '0' AND was_scl_i = '1') THEN
      	    out_sr(7 DOWNTO 1) <= out_sr(6 DOWNTO 0);
      	    out_sr(0) <= '1';
      	  ELSE
      	    out_sr <= out_sr;
      	  END IF;
      	END IF;                     
      	
     END PROCESS load_the_read_byte;		
	  		
------------------------------------------------------
-- Delayed pulses for incrementing subaddress:
------------------------------------------------------
	rd_wr_delayed_pulses : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			read_pulse_delayed_i	<= '0';
			write_pulse_delayed_i	<= '0';	
		ELSIF (RISING_EDGE(CLK_IN)) THEN 	  		
			read_pulse_delayed_i	<= read_pulse_i;
			write_pulse_delayed_i	<= write_pulse_i;
		END IF;
		
	END PROCESS rd_wr_delayed_pulses; 	
	  		
------------------------------------------------------
-- subaddr_7_0_out is loaded after the second byte of a write
-- cycle has fully shifted in.  It increments after each
-- read or write access.
------------------------------------------------------
	subaddr_handler : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			subadd_out_i	<= X"00";
		ELSIF (RISING_EDGE(CLK_IN)) THEN	  		
		  IF (subadd_byte = '1' AND ack_cyc = '1') THEN
		    subadd_out_i <= STD_LOGIC_VECTOR(in_sr);
		  ELSIF (read_pulse_delayed_i = '1' OR
		         write_pulse_delayed_i = '1') THEN
		           subadd_out_i <= STD_LOGIC_VECTOR(UNSIGNED(subadd_out_i) + 1);
		  ELSE
		    subadd_out_i <= subadd_out_i;
		  END IF;
		END IF;                 
		
	END PROCESS subaddr_handler;
		  
------------------------------------------------------
-- Shift I2C data in after rising edge of SCL.
------------------------------------------------------
	shift_data_in : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			in_sr	<= X"00";
		ELSIF (RISING_EDGE(CLK_IN)) THEN
		  -- Detect rising edge on SCL
		  IF (scl_i = '1' AND was_scl_i = '0') THEN
		    in_sr(7 DOWNTO 1) <= in_sr(6 DOWNTO 0);
		    in_sr(0) <= sda_i;
		  ELSE
		    in_sr <= in_sr;
		  END IF;
		END IF;

	END PROCESS shift_data_in;

------------------------------------------------------
-- Read / not Write.  For external bus drivers if necessary.
-- Latch the Read bit of the address cycle.
------------------------------------------------------
	read_not_write_cntl : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			read_not_write_out_i <= '0';
		ELSIF (RISING_EDGE(CLK_IN)) THEN
          IF (addr_byte = '1' AND ack_cyc = '1') THEN
            read_not_write_out_i <= in_sr(0);
          ELSE
            read_not_write_out_i <= read_not_write_out_i;
          END IF;
        END IF;
        
	END PROCESS read_not_write_cntl;

------------------------------------------------------
-- Decode address.  My cycle if address upper 7 bits
-- match with i2c_address defined above.
------------------------------------------------------
	is_this_cycle_for_me : PROCESS (CLR_IN, CLK_IN, i2c_start)
	  BEGIN
	  	IF (CLR_IN = '1' OR i2c_start = '1') THEN
			my_cyc <= '0';
		ELSIF (RISING_EDGE(CLK_IN)) THEN
		  -- At the end of the address byte...
		  IF (addr_byte = '1' AND ack_cyc = '1' AND
		      -- if the shifted in address and the I2C base i2c address
		      -- match, set my_cyc
		      in_sr(7 DOWNTO 1) = I2C_ADDRESS) THEN
		        my_cyc <= '1';
		  ELSE
		        my_cyc <= my_cyc;
		  END IF;
		END IF;
		
	END PROCESS is_this_cycle_for_me;

------------------------------------------------------
-- I2C data output drive low signal (1 = drive SDA low)
-- Invert this signal for T input of OBUFT or IOBUF
-- or use it directly for OBUFE.
------------------------------------------------------
	drive_the_sda_out : PROCESS (CLR_IN, CLK_IN)
	  BEGIN
	  	IF (CLR_IN = '1') THEN
			SDA_IO_OUT <= '0';
		ELSIF (RISING_EDGE(CLK_IN)) THEN
		  IF ((my_cyc = '1' AND addr_ack = '1') -- Address ack
		      OR
		      -- Write byte acknowledge
		      (my_cyc = '1' AND read_not_write_out_i = '0' AND ack_cyc = '1')
			  OR
			  (data_byte = '1' AND read_not_write_out_i = '1' AND
			   ack_cyc = '0' AND out_sr(7) = '0')) THEN
			     SDA_IO_OUT <= '1';
		  ELSE
		    SDA_IO_OUT <= '0';
		  END IF;
		END IF;
	
	END PROCESS drive_the_sda_out;

end RTL;