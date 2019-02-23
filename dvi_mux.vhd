----------------------------------------------------------------------------------
-- Company:            
-- Engineer:        e-potis
-- Create Date:     15:41:24 04/05/2013 
-- Design Name:     Video to LED
-- Module Name:     dvi_mux - Behavioral 
-- Target Devices:  Spartan 6
-- Tool versions:   ISE 14.3
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 0.05 - splits first 31 rows off to 31 output LED drivers.
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity dvi_mux is
  generic (
    row_length     : integer := 1024;
    number_of_rows : integer := 32);
  port (clk             : in  std_logic;
        rst             : in  std_logic;
        serial_out      : out std_logic_vector(number_of_rows-1 downto 0);
        debug_full      : out std_logic;
        debug_empty     : out std_logic;
        dvi_hsync       : in  std_logic;
        dvi_vsync       : in  std_logic;
        dvi_hblnk       : in  std_logic;
        dvi_vblnk       : in  std_logic;
        dvi_de          : in  std_logic;
        dvi_red         : in  std_logic_vector(7 downto 0);
        dvi_green       : in  std_logic_vector(7 downto 0);
        dvi_blue        : in  std_logic_vector(7 downto 0);
        mux_state_debug : out std_logic;
        de_debug        : out std_logic
        );
end dvi_mux;

architecture Behavioral of dvi_mux is

  component LED_driver
    port (
      dvi_red        : in  std_logic_vector (7 downto 0);
      dvi_green      : in  std_logic_vector (7 downto 0);
      dvi_blue       : in  std_logic_vector (7 downto 0);
      dvi_valid      : in  std_logic;
      dvi_clk        : in  std_logic;
      driver_clk     : in  std_logic;
      rst            : in  std_logic;
      dvi_hsync      : in  std_logic;
      dvi_row_length : in  std_logic_vector(11 downto 0);
      serial_out     : out std_logic;
      full           : out std_logic;
      empty          : out std_logic);
  end component;

  type   gen_dvi_states is (wait_for_start, write_data);
  signal gen_dvi_state : gen_dvi_states;


  type   color_row_array is array (number_of_rows-1 downto 0) of std_logic_vector(7 downto 0);
  signal red_row   : color_row_array;
  signal blue_row  : color_row_array;
  signal green_row : color_row_array;
  signal row_hsync : std_logic_vector(number_of_rows-1 downto 0);
  signal row_valid : std_logic_vector(number_of_rows-1 downto 0);

  signal red   : std_logic_vector(7 downto 0);
  signal green : std_logic_vector(7 downto 0);
  signal blue  : std_logic_vector(7 downto 0);

  signal row_counter   : unsigned(number_of_rows-1 downto 0);
  type   dvi_mux_state_type is (wait_for_frame_start, current_frame);
  signal dvi_mux_state : dvi_mux_state_type;

  signal full_array  : std_logic_vector(number_of_rows-1 downto 0);
  signal empty_array : std_logic_vector(number_of_rows-1 downto 0);

  signal zeros : std_logic_vector(number_of_rows-1 downto 0);
  signal ones  : std_logic_vector(number_of_rows-1 downto 0);

  signal dvi_hsync_z : std_logic;

  type   gen_vblnk_states is (wait_for_de, wait_for_vsync);
  signal dvi_int_vblnk   : std_logic;
  signal dvi_vblnk_state : gen_vblnk_states;
  
begin

  zeros <= (others => '0');
  ones  <= (others => '1');

  gen_int_vblnk : process (clk, rst)
  begin  -- process gen_int_vblnk
    if rst = '1' then
      dvi_int_vblnk   <= '0';
      dvi_vblnk_state <= wait_for_vsync;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case dvi_vblnk_state is
        when wait_for_vsync =>
          if dvi_vsync = '1' then
            dvi_int_vblnk   <= '1';
            dvi_vblnk_state <= wait_for_de;
          else
            dvi_int_vblnk   <= '0';
            dvi_vblnk_state <= wait_for_vsync;
          end if;
        when wait_for_de =>
          if dvi_de = '1' then
            dvi_int_vblnk   <= '0';
            dvi_vblnk_state <= wait_for_vsync;
          else
            dvi_int_vblnk   <= '1';
            dvi_vblnk_state <= wait_for_de;
          end if;
        when others => null;
      end case;
      
    end if;
  end process gen_int_vblnk;

  mux_state_debug <= '0' when dvi_mux_state = wait_for_frame_start else '1';
  de_debug        <= '0' when row_valid = zeros                       else '1';

  dvi_mux : process (clk, rst)
  begin  -- process dvi_mux
    if rst = '1' then                   -- asynchronous reset (active high)
      row_counter   <= (others => '0');
      dvi_mux_state <= wait_for_frame_start;
      dvi_hsync_z   <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      case dvi_mux_state is
        when wait_for_frame_start =>
          if dvi_hsync = '1' and dvi_vsync = '1' then
            dvi_mux_state <= current_frame;
          else
            dvi_mux_state <= wait_for_frame_start;
          end if;
          row_counter <= (others => '0');
        when current_frame =>
          if dvi_int_vblnk = '1' then
            row_counter <= (others => '0');
          elsif dvi_hsync = '1' and dvi_hsync_z = '0' then
            row_counter <= row_counter + "1";
          end if;
        when others => null;
      end case;
      dvi_hsync_z <= dvi_hsync;
    end if;
  end process dvi_mux;

  generate_rows : for i in number_of_rows-1 downto 0 generate
    red_row(i)   <= dvi_red   when to_integer(row_counter) = i and dvi_mux_state = current_frame else (others => '0');
    green_row(i) <= dvi_green when to_integer(row_counter) = i and dvi_mux_state = current_frame else (others => '0');
    blue_row(i)  <= dvi_blue  when to_integer(row_counter) = i and dvi_mux_state = current_frame else (others => '0');
    row_valid(i) <= dvi_de    when to_integer(row_counter) = i and dvi_mux_state = current_frame else '0';
    row_hsync(i) <= dvi_hsync when to_integer(row_counter) = i and dvi_mux_state = current_frame else '0';

    LED_driver_i : LED_driver
      port map (
        dvi_red        => red_row(i),
        dvi_green      => green_row(i),
        dvi_blue       => blue_row(i),
        dvi_valid      => row_valid(i),
        dvi_clk        => clk,
        driver_clk     => clk,
        rst            => rst,
        dvi_hsync      => row_hsync(i),
        dvi_row_length => std_logic_vector(to_unsigned(row_length, 12)),
        serial_out     => serial_out(i),
        full           => full_array(i),
        empty          => empty_array(i));

  end generate generate_rows;

  debug_empty <= '0' when empty_array = X"00000000" else '1';
  debug_full  <= '0' when full_array = X"00000000"  else '1';
  
end Behavioral;

