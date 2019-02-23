----------------------------------------------------------------------------------
-- Company:         
-- Engineer:        e-potis
-- Create Date:     15:41:24 04/05/2013 
-- Design Name:     Video to LED
-- Module Name:     LED_DRIVER - Behavioral 
-- Target Devices:  Spartan 6
-- Tool versions:   ISE 14.3
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.02 - Flipped polarity of input bits
-- Revision 0.03 - Duplicates last pixel if fifo runs dry
--               - Removed start of frame state
-- Revision 0.04 - unchanged
-- Revision 0.05 - Separated mux from test input
--               - fixed first bit issue
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity LED_DRIVER is
  port (dvi_red        : in  std_logic_vector (7 downto 0);  -- DVI data
        dvi_green      : in  std_logic_vector (7 downto 0);
        dvi_blue       : in  std_logic_vector (7 downto 0);
        dvi_valid      : in  std_logic;  -- DVI valid
        dvi_clk        : in  std_logic;  -- DVI clock
        driver_clk     : in  std_logic;  -- Driver Clock (100 Mhz)
        rst            : in  std_logic;  -- Reset
        dvi_hsync      : in  std_logic;  -- Hsync (deliminates rows)
        dvi_row_length : in  std_logic_vector(11 downto 0);  -- Row length
        serial_out     : out std_logic;  -- Output data
        full           : out std_logic;  -- Fifo full indicator (debug)
        empty          : out std_logic  -- fifo empty indicator (debug)
        );
end LED_DRIVER;

architecture Behavioral of LED_DRIVER is

  component driver_fifo
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      rd_clk        : in  std_logic;
      din           : in  std_logic_vector(23 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector(23 downto 0);
      full          : out std_logic;
      empty         : out std_logic;
      valid         : out std_logic;
      rd_data_count : out std_logic_vector(1 downto 0);
      wr_data_count : out std_logic_vector(1 downto 0)
      );
  end component;

  signal symbol_high : std_logic_vector(124 downto 0);
  signal symbol_low  : std_logic_vector(124 downto 0);

  signal fifo_din   : std_logic_vector(23 downto 0);
  signal fifo_wr_en : std_logic;
  signal fifo_rd_en : std_logic;
  signal fifo_dout  : std_logic_vector(23 downto 0);
  signal fifo_full  : std_logic;
  signal fifo_empty : std_logic;


  signal fifo_write_counter : unsigned(11 downto 0);

  signal bit_counter    : unsigned(4 downto 0);
  signal shift_counter  : unsigned(6 downto 0);
  signal pixel_counter  : unsigned(11 downto 0);
  signal current_symbol : std_logic_vector(124 downto 0);
  signal current_bit    : std_logic_vector(23 downto 0);
  signal reset_counter  : unsigned(12 downto 0);

  type   fifo_write_states is (wait_for_hsync_and_space, write_data);
  signal fifo_write_state : fifo_write_states;

  type   fifo_read_states is (reset_count, shift_out_data, wait_for_data, first_sample,read_first_bit_1,read_first_bit_2);
  signal fifo_read_state : fifo_read_states;

  signal fifo_dout_valid : std_logic;
  signal wr_data_count   : std_logic_vector(1 downto 0);
  signal rd_data_count   : std_logic_vector(1 downto 0);

  signal data_out : std_logic;

  signal dvi_red_flipped   : std_logic_vector(7 downto 0);
  signal dvi_green_flipped : std_logic_vector(7 downto 0);
  signal dvi_blue_flipped  : std_logic_vector(7 downto 0);

begin

  flip_bits: for i in 0 to 7 generate
    dvi_red_flipped(i)   <= dvi_red(7-i);
    dvi_green_flipped(i) <= dvi_green(7-i);
    dvi_blue_flipped(i)  <= dvi_blue(7-i);  
  end generate flip_bits;

  -- Symbol definitions:
  symbol_high(124 downto 60) <= (others => '0');
  symbol_high(59 downto 0)   <= (others => '1');
  symbol_low(124 downto 25)  <= (others => '0');
  symbol_low(24 downto 0)    <= (others => '1');

  -- Debug connections
  full  <= fifo_full;
  empty <= fifo_empty;

  -------------------------------------------------------------------------------
  -- FIFO WRITE 
  -------------------------------------------------------------------------------
  -- Hold off writing data until:
  -- Fifo has enough space
  -- Frame sync occurs.
  -- Fifo should never overflow.

  -- STATES:
  -----------
  -- + Wait_for_sync_and_space
  -- + write_data

  -- ASSUMPTIONS:
  ---------------
  -- Blue in most significant position
  -- Red in middle
  -- Green in least significant position

  gen_input_data : process (dvi_clk, rst)
  begin  -- process gen_input_data
    if rst = '1' then                   -- asynchronous reset (active low)
      fifo_din           <= (others => '0');
      fifo_wr_en         <= '0';
      fifo_write_state   <= wait_for_hsync_and_space;
      fifo_write_counter <= (others => '0');
    elsif dvi_clk'event and dvi_clk = '1' then  -- rising clock edge
      case fifo_write_state is
        when wait_for_hsync_and_space =>
          fifo_din           <= (others => '0');
          fifo_wr_en         <= '0';
          fifo_write_counter <= (others => '0');
          if fifo_empty = '1' and dvi_hsync = '1' then
            fifo_write_state <= write_data;
          else
            fifo_write_state <= wait_for_hsync_and_space;
          end if;
        when write_data =>
          if fifo_write_counter = unsigned(dvi_row_length) then
            fifo_write_counter <= (others => '0');
            fifo_write_state   <= wait_for_hsync_and_space;
            fifo_din           <= (others => '0');
            fifo_wr_en         <= '0';
          else
            if dvi_valid = '1' then
              fifo_din           <= dvi_blue_flipped & dvi_red_flipped & dvi_green_flipped;
              fifo_wr_en         <= '1';
              fifo_write_counter <= fifo_write_counter + "1";
            else
              fifo_din   <= (others => '0');
              fifo_wr_en <= '0';
            end if;
            fifo_write_state <= write_data;
          end if;
        when others => null;
      end case;
    end if;
  end process gen_input_data;

  driver_fifo_i : driver_fifo
    port map (
      rst           => rst,
      wr_clk        => dvi_clk,
      rd_clk        => driver_clk,
      din           => fifo_din,
      wr_en         => fifo_wr_en,
      rd_en         => fifo_rd_en,
      dout          => fifo_dout,
      full          => fifo_full,
      empty         => fifo_empty,
      valid         => fifo_dout_valid,
      rd_data_count => rd_data_count,
      wr_data_count => wr_data_count);

  -----------------------------------------------------------------------------
  -- READ FIFO
  -----------------------------------------------------------------------------

  -- Reads out a 24-bit pixel word
  -- Iterates through the word, bit by bit
  -- for each bit, shift out a symbol based on bit value.

  -- Each symbol is a 125-bit value, where each bit represents a timeslice of
  -- 10ns or 1 clock cycle at 100Mhz. it takes 1250ns to clock out one symbol
  -- (125 clock cycles).

  -- COUNTERS:
  ------------
  -- pixel_counter: iterates through each pixel in row: 1024 pixels
  -- current_bit: the 24 bit value of the current pixel
  -- bit_counter: iterates through each bit in the pixel: 24 bits
  -- current_symbol: the 125 bit symbol value of the current bit
  -- shift_counter: iterates through each bit in the symbol: 125 bits
  -- data_out: the 1 bit current output bit value.
  -- reset_counter: counts the length of the reset

  -- FIFO OUT TIMING:
  -------------------
  -- fifo rd enable is triggered for one clock cycle while the last bit of the
  -- last symbol of the last pixel is read out.
  
  shift_register : process (driver_clk, rst)
  begin  -- process shift_register
    if rst = '1' then                   -- asynchronous reset (active high)
      current_symbol  <= (others => '0');
      shift_counter   <= (others => '0');
      current_bit     <= (others => '0');
      bit_counter     <= (others => '0');
      data_out        <= '0';
      fifo_rd_en      <= '0';
      pixel_counter   <= (others => '0');
      reset_counter   <= (others => '0');
      fifo_read_state <= reset_count;
    elsif driver_clk'event and driver_clk = '1' then  -- rising clock edge
      case fifo_read_state is
        when reset_count =>
          if reset_counter = "1001111101100" then     -- 5100 
            fifo_read_state <= wait_for_data;
            reset_counter   <= (others => '0');
          else
            fifo_read_state <= reset_count;
            reset_counter   <= reset_counter + "1";
          end if;
          current_symbol <= (others => '0');
          shift_counter  <= (others => '0');
          current_bit    <= (others => '0');
          bit_counter    <= (others => '0');
          data_out       <= '0';
          fifo_rd_en     <= '0';
          pixel_counter  <= (others => '0');
        when wait_for_data =>
          if rd_data_count /= "00" then
            fifo_rd_en      <= '1';
            fifo_read_state <= read_first_bit_1;
          else
            fifo_rd_en      <= '0';
            fifo_read_state <= wait_for_data;
          end if;
        when read_first_bit_1 =>
          fifo_rd_en <= '0';
          fifo_read_state <= read_first_bit_2;
        when read_first_bit_2 =>
          fifo_rd_en <= '0';
          current_bit <= fifo_dout;
          fifo_read_state <= shift_out_data;
        when shift_out_data =>
          if shift_counter = "1111100" then           --125
            if bit_counter = "10111" then             -- 23
              bit_counter <= (others => '0');
              current_bit <= fifo_dout;
              fifo_rd_en  <= '0';
              if pixel_counter = unsigned(dvi_row_length) - "1" then
                pixel_counter   <= (others => '0');
                fifo_read_state <= reset_count;
              else
                pixel_counter   <= pixel_counter + "1";
                fifo_read_state <= shift_out_data;
              end if;
            else
              if bit_counter = "10110" and fifo_empty = '0' then           -- 22
                fifo_rd_en <= '1';
              else
                fifo_rd_en <= '0';
              end if;
              bit_counter <= bit_counter + "1";
            end if;
            shift_counter <= (others => '0');
            if current_bit(to_integer(bit_counter)) = '1' then
              current_symbol <= symbol_high;
            else
              current_symbol <= symbol_low;
            end if;
            data_out <= current_symbol(to_integer(shift_counter));
          else
            fifo_rd_en    <= '0';
            data_out      <= current_symbol(to_integer(shift_counter));
            shift_counter <= shift_counter + "1";
          end if;
        when others => null;
      end case;
    end if;
  end process shift_register;

  serial_out <= data_out;

end Behavioral;

