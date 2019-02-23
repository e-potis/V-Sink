----------------------------------------------------------------------------------
-- Company:             
-- Engineer:        e-potis
-- Create Date:     15:41:24 04/05/2013 
-- Design Name:     Video to LED
-- Module Name:     gen_test_video - Behavioral 
-- Target Devices:  Spartan 6
-- Tool versions:   ISE 14.3
-- Revision: 
-- Revision 0.05 - File Created
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity gen_test_video is
  port (clk_100   : in  std_logic;
        rst_n     : in  std_logic;
        dvi_hsync : out std_logic;
        dvi_vsync : out std_logic;
        dvi_hblnk : out std_logic;
        dvi_vblnk : out std_logic;
        dvi_de    : out std_logic;
        dvi_red   : out std_logic_vector(7 downto 0);
        dvi_green : out std_logic_vector(7 downto 0);
        dvi_blue  : out std_logic_vector(7 downto 0)
        );
end gen_test_video;

architecture Behavioral of gen_test_video is

  component timing
    port (
      tc_hsblnk : in std_logic_vector(10 downto 0);
      tc_hssync : in std_logic_vector(10 downto 0);
      tc_hesync : in std_logic_vector(10 downto 0);
      tc_heblnk : in std_logic_vector(10 downto 0);
      tc_vsblnk : in std_logic_vector(10 downto 0);
      tc_vssync : in std_logic_vector(10 downto 0);
      tc_vesync : in std_logic_vector(10 downto 0);
      tc_veblnk : in std_logic_vector(10 downto 0);

      hcount : out std_logic_vector(10 downto 0);
      hsync  : out std_logic;
      hblnk  : out std_logic;

      vcount : out std_logic_vector(10 downto 0);
      vsync  : out std_logic;
      vblnk  : out std_logic;

      restart : in std_logic;
      clk     : in std_logic);
  end component;

  component hdcolorbar
    port (
      i_clk_74M : in  std_logic;        -- 74.25MHz clk
      i_rst     : in  std_logic;
      baronly   : in  std_logic;        -- output only 75% color bar
      i_format  : in  std_logic_vector(1 downto 0);  -- format, 00 = non hd, non interleave
      i_vcnt    : in  std_logic_vector(11 downto 0);  -- vertical counter
      i_hcnt    : in  std_logic_vector(11 downto 0);  -- horizontal counter
      o_r       : out std_logic_vector(7 downto 0);
      o_g       : out std_logic_vector(7 downto 0);
      o_b       : out std_logic_vector(7 downto 0));
  end component;
  
  constant HPIXELS : integer := 1024;    --//Horizontal Live Pixels
  constant VLINES  : integer := 768;    --//Vertical Live lines
  constant HSYNCPW : integer := 136;     --//HSYNC Pulse Width
  constant VSYNCPW : integer := 6;      --//VSYNC Pulse Width
  constant HFNPRCH : integer := 24;     --//Horizontal Front Portch
  constant VFNPRCH : integer := 3;     --//Vertical Front Portch
  constant HBKPRCH : integer := 160;     --//Horizontal Front Portch
  constant VBKPRCH : integer := 29;     --//Vertical Front Portch

  signal dvi_hsync_z  : std_logic;
  signal dvi_hsync_z2 : std_logic;
  signal dvi_vsync_z  : std_logic;
  signal dvi_vsync_z2 : std_logic;
  signal dvi_hblnk_z  : std_logic;
  signal dvi_hblnk_z2 : std_logic;
  signal dvi_vblnk_z  : std_logic;
  signal dvi_vblnk_z2 : std_logic;
  
  signal clk : std_logic;
  signal rst : std_logic;

  signal tc_hsblnk : std_logic_vector(10 downto 0);
  signal tc_hssync : std_logic_vector(10 downto 0);
  signal tc_hesync : std_logic_vector(10 downto 0);
  signal tc_heblnk : std_logic_vector(10 downto 0);
  signal tc_vsblnk : std_logic_vector(10 downto 0);
  signal tc_vssync : std_logic_vector(10 downto 0);
  signal tc_vesync : std_logic_vector(10 downto 0);
  signal tc_veblnk : std_logic_vector(10 downto 0);
  signal hcount    : std_logic_vector(10 downto 0);
  signal hblnk     : std_logic;
  signal vcount    : std_logic_vector(10 downto 0);
  signal vsync     : std_logic;
  signal vblnk     : std_logic;
  signal hsync     : std_logic;

  signal red   : std_logic_vector(7 downto 0);
  signal green : std_logic_vector(7 downto 0);
  signal blue  : std_logic_vector(7 downto 0);

begin


  clk <= clk_100;
  rst <= not rst_n;

  timing_1 : timing
    port map (
      tc_hsblnk => tc_hsblnk,
      tc_hssync => tc_hssync,
      tc_hesync => tc_hesync,
      tc_heblnk => tc_heblnk,
      tc_vsblnk => tc_vsblnk,
      tc_vssync => tc_vssync,
      tc_vesync => tc_vesync,
      tc_veblnk => tc_veblnk,
      hcount    => hcount,
      hsync     => hsync,
      hblnk     => hblnk,
      vcount    => vcount,
      vsync     => vsync,
      vblnk     => vblnk,
      restart   => rst,
      clk       => clk);

  hdcolorbar_1 : hdcolorbar
    port map (
      i_clk_74M => clk,
      i_rst     => rst,
      baronly   => '0',
      i_format  => "00",
      i_vcnt    => "0" & vcount,
      i_hcnt    => "0" & hcount,
      o_r       => red,
      o_g       => green,
      o_b       => blue);

  tc_hsblnk <= std_logic_vector(to_unsigned(HPIXELS - 1, 11));
  tc_hssync <= std_logic_vector(to_unsigned(HPIXELS - 1 + HFNPRCH, 11));
  tc_hesync <= std_logic_vector(to_unsigned(HPIXELS - 1 + HFNPRCH + HSYNCPW, 11));
  tc_heblnk <= std_logic_vector(to_unsigned(HPIXELS - 1 + HFNPRCH + HSYNCPW + HBKPRCH, 11));
  tc_vsblnk <= std_logic_vector(to_unsigned(VLINES - 1, 11));
  tc_vssync <= std_logic_vector(to_unsigned(VLINES - 1 + VFNPRCH, 11));
  tc_vesync <= std_logic_vector(to_unsigned(VLINES - 1 + VFNPRCH + VSYNCPW, 11));
  tc_veblnk <= std_logic_vector(to_unsigned(VLINES - 1 + VFNPRCH + VSYNCPW + VBKPRCH, 11));

  dvi_mux : process (clk, rst)
  begin  -- process dvi_mux
    if rst = '1' then                   -- asynchronous reset (active high)
      dvi_hsync_z  <= '0';
      dvi_hsync_z2 <= '0';
      dvi_vsync_z  <= '0';
      dvi_vsync_z2 <= '0';
      dvi_hblnk_z  <= '0';
      dvi_hblnk_z2 <= '0';
      dvi_vblnk_z  <= '0';
      dvi_vblnk_z2 <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      dvi_hsync_z  <= hsync;
      dvi_hsync_z2 <= dvi_hsync_z;
      dvi_vsync_z  <= vsync;
      dvi_vsync_z2 <= dvi_vsync_z;
      dvi_hblnk_z  <= hblnk;
      dvi_hblnk_z2 <= dvi_hblnk_z;
      dvi_vblnk_z  <= vblnk;
      dvi_vblnk_z2 <= dvi_vblnk_z;
    end if;
  end process dvi_mux;

  dvi_hsync <= dvi_hsync_z2;
  dvi_vsync <= dvi_vsync_z2;
  dvi_hblnk <= dvi_hblnk_z2;
  dvi_vblnk <= dvi_vblnk_z2;

  dvi_de    <= not (dvi_hblnk_z2 or dvi_vblnk_z2);
  dvi_red   <= red;
  dvi_green <= green;
  dvi_blue  <= blue;

  
end Behavioral;

