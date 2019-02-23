--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.1
--  \   \         Application : sch2hdl
--  /   /         Filename : main.vhf
-- /___/   /\     Timestamp : 03/31/2013 18:46:01
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -sympath "C:/Documents and Settings/Owner/My Documents/Dropbox/Johnny5/papillio2812/ipcore_dir" -intstyle ise -family spartan3e -flat -suppress -vhdl "C:/Documents and Settings/Owner/My Documents/Dropbox/Johnny5/papillio2812/main.vhf" -w "C:/Documents and Settings/Owner/My Documents/Dropbox/Johnny5/papillio2812/main.sch"
--Design Name: main
--Device: spartan3e
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity main is
   port ( clk : in    std_logic; 
          rx  : in    std_logic; 
          A0  : out   std_logic; 
          c8  : out   std_logic);
end main;

architecture BEHAVIORAL of main is
   attribute BOX_TYPE   : string ;
   signal XLXN_8                   : std_logic;
   signal XLXN_53                  : std_logic_vector (7 downto 0);
   signal XLXN_57                  : std_logic;
   signal XLXN_59                  : std_logic;
   signal XLXN_60                  : std_logic;
   signal XLXN_61                  : std_logic;
   signal XLXN_62                  : std_logic_vector (0 downto 0);
   signal XLXN_63                  : std_logic;
   signal XLXN_66                  : std_logic;
   signal XLXN_68                  : std_logic;
   signal XLXN_70                  : std_logic;
   signal XLXN_74                  : std_logic;
   signal XLXI_3_RST_IN_openSignal : std_logic;
   component baud_gen
      port ( clk  : in    std_logic; 
             baud : out   std_logic);
   end component;
   
   component uart_rx
      port ( serial_in    : in    std_logic; 
             en_16_x_baud : in    std_logic; 
             clk          : in    std_logic; 
             data_strobe  : out   std_logic; 
             data_out     : out   std_logic_vector (7 downto 0));
   end component;
   
   component clk_mult
      port ( RST_IN          : in    std_logic; 
             CLKIN_IN        : in    std_logic; 
             CLKFX_OUT       : out   std_logic; 
             CLKIN_IBUFG_OUT : out   std_logic; 
             CLK0_OUT        : out   std_logic);
   end component;
   
   component VCC
      port ( P : out   std_logic);
   end component;
   attribute BOX_TYPE of VCC : component is "BLACK_BOX";
   
   component rx_fifo
      port ( rst    : in    std_logic; 
             wr_clk : in    std_logic; 
             din    : in    std_logic_vector (7 downto 0); 
             wr_en  : in    std_logic; 
             full   : out   std_logic; 
             rd_clk : in    std_logic; 
             dout   : out   std_logic_vector (0 downto 0); 
             rd_en  : in    std_logic; 
             empty  : out   std_logic);
   end component;
   
   component LED_TX
      port ( clk        : in    std_logic; 
             inpt       : in    std_logic; 
             fifo_full  : in    std_logic; 
             fifo_empty : in    std_logic; 
             fifo_clk   : out   std_logic; 
             we         : out   std_logic; 
             re         : out   std_logic; 
             led_out    : out   std_logic; 
             tx         : out   std_logic; 
             fifo_reset : out   std_logic);
   end component;
   
begin
   XLXI_1 : baud_gen
      port map (clk=>XLXN_74,
                baud=>XLXN_68);
   
   XLXI_2 : uart_rx
      port map (clk=>XLXN_68,
                en_16_x_baud=>XLXN_8,
                serial_in=>rx,
                data_out(7 downto 0)=>XLXN_53(7 downto 0),
                data_strobe=>XLXN_70);
   
   XLXI_3 : clk_mult
      port map (CLKIN_IN=>clk,
                RST_IN=>XLXI_3_RST_IN_openSignal,
                CLKFX_OUT=>XLXN_74,
                CLKIN_IBUFG_OUT=>open,
                CLK0_OUT=>open);
   
   XLXI_5 : VCC
      port map (P=>XLXN_8);
   
   XLXI_7 : rx_fifo
      port map (din(7 downto 0)=>XLXN_53(7 downto 0),
                rd_clk=>XLXN_57,
                rd_en=>XLXN_59,
                rst=>XLXN_63,
                wr_clk=>XLXN_70,
                wr_en=>XLXN_66,
                dout(0)=>XLXN_62(0),
                empty=>XLXN_60,
                full=>XLXN_61);
   
   XLXI_8 : LED_TX
      port map (clk=>XLXN_74,
                fifo_empty=>XLXN_60,
                fifo_full=>XLXN_61,
                inpt=>XLXN_62(0),
                fifo_clk=>XLXN_57,
                fifo_reset=>XLXN_63,
                led_out=>c8,
                re=>XLXN_59,
                tx=>A0,
                we=>XLXN_66);
   
end BEHAVIORAL;


