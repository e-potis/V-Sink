-------------------------------------------------------------------------------
-- Module Name:        i2c_slave_block
-- Module Description: I2C Slave + RAM block
--
--
--
-- Revision History
--
-- v0.1 - 19/06/11
--      - Initial Dev Release
--
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity i2c_slave_block is

  port
    (
      CLK                       : in  std_ulogic;  -- Clock for This Level SM
      HARD_RESET_N              : in  std_ulogic;  -- Hard Reset active low
      I2C_SLAVE_ADDRESS         : in  std_logic_vector (6 downto 0);
      I2C_CLK_INPUT             : in  std_ulogic;  -- I2C Serial Clock in
      I2C_DATA_INPUT            : in  std_ulogic;  -- I2C Serial Data in
      I2C_DRV_DATA_LINE_LOW_OUT : out std_ulogic  -- When high, the I2C Serial Data out is driven low.
      ) ;

end i2c_slave_block;

architecture rtl of i2c_slave_block is

  component i2c_slave2
    port
      (
        CLR_IN      : in std_ulogic;    -- Active high, async clear/reset
        CLK_IN      : in std_ulogic;    -- Fast system clock > 10MHz
        I2C_ADDRESS : in std_ulogic_vector(7 downto 1);  -- I2C Slave address
                                        -- Set s what I2C address 
                                        -- the block will respond to

        RD_BUS_IN : in std_ulogic_vector(7 downto 0);  -- Parallel read data

        SCL_IN    : in std_ulogic;      -- I2C Serial Clock from pin
        SDA_IO_IN : in std_ulogic;      -- I2C Serial data input from pin

        SDA_IO_OUT : out std_ulogic;    -- I2C Serial data output to pin
                                        -- When '1', SDA pin must be driven low
                                        -- When '0', SDA pin must be High 'Z'

        SUBADDR_OUT   : out std_ulogic_vector(7 downto 0);  -- Parallel Address Bus
        WRITE_BUS_OUT : out std_ulogic_vector(7 downto 0);  -- Parallel Write data

        WRITE_PULSE_OUT : out std_ulogic;  -- One CLK_IN long, active high write pulse.
        READ_PULSE_OUT  : out std_ulogic;  -- One CLK_IN long, active high read pulse.
        READ_WRITE_OUT  : out std_ulogic   -- Read/not(write) output signal
        );
  end component;

  component RAM
    port
      (
        CLKA  : in  std_logic;
        RSTA  : in  std_logic;
        WEA   : in  std_logic_vector(0 downto 0);
        ADDRA : in  std_logic_vector(6 downto 0);
        DINA  : in  std_logic_vector(7 downto 0);
        DOUTA : out std_logic_vector(7 downto 0)
        );
  end component;


  -- Internal signals
  signal hard_reset     : std_ulogic;   -- Internal active high reset
  --SIGNAL i2cb_data_in_i         : STD_ULOGIC_VECTOR(7 DOWNTO 0) ; --
  --SIGNAL i2cb_data_out_i        : STD_ULOGIC_VECTOR(7 DOWNTO 0) ; --
  signal ram_clock_i    : std_ulogic;   -- 
  signal ram_we_i       : std_ulogic_vector(0 downto 0);   -- 
  signal ram_rd_i       : std_ulogic;   -- 
  signal ram_we_rd_i    : std_ulogic;   -- 
  signal ram_address_i  : std_ulogic_vector (7 downto 0);  -- 
  signal ram_data_in_i  : std_ulogic_vector(7 downto 0);   -- 
  signal ram_data_out_i : std_logic_vector(7 downto 0);    --
  
begin

  -- Buffer Internal Signals to Outputs


  -- assignments
  hard_reset <= not(HARD_RESET_N);

  ram_clock_i <= CLK;


-------------------------------------------------------------------------------
  -- Component Instantiation

  u2_1 : i2c_slave2
    port map
    (
      CLR_IN          => hard_reset,
      CLK_IN          => CLK,
      I2C_ADDRESS     => std_ulogic_vector(I2C_SLAVE_ADDRESS),
      RD_BUS_IN       => std_ulogic_vector(ram_data_out_i),
      SCL_IN          => I2C_CLK_INPUT,
      SDA_IO_IN       => I2C_DATA_INPUT,
      SDA_IO_OUT      => I2C_DRV_DATA_LINE_LOW_OUT,
      SUBADDR_OUT     => ram_address_i,
      WRITE_BUS_OUT   => ram_data_in_i,
      WRITE_PULSE_OUT => ram_we_i(0),
      READ_PULSE_OUT  => ram_rd_i,
      READ_WRITE_OUT  => ram_we_rd_i
      );

  u2_2 : RAM
    port map
    (
      CLKA  => CLK,
      RSTA  => hard_reset,
      WEA   => std_logic_vector(ram_we_i),
      ADDRA => std_logic_vector(ram_address_i(6 downto 0)),
      DINA  => std_logic_vector(ram_data_in_i),
      DOUTA => ram_data_out_i
      );


end rtl;
