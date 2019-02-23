----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  e-potis
-- 
-- Create Date:    20:09:44 12/03/2010 
-- Design Name: 
-- Module Name:    clk2baud - Behavioral 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity baud_gen is
    Port ( clk : in  STD_LOGIC;
           baud : out  STD_LOGIC);
end baud_gen;

architecture Behavioral of baud_gen is
signal baud_count : integer range 0 to 15 :=0;
begin


baud_timer: process(clk)
begin

if (rising_edge(clk)) then
		if (baud_count=3) then   --1.25us = 120 counts @96MHz
			baud_count <= 0;
		else
			baud_count <= baud_count + 1;
		end if;
		if (baud_count<2) then
			baud<='1';
		else
			baud<='0';
		end if;
end if;
end process;



--	if clk'event and clk='1' then
--		if baud_count=1 then
--			baud_count <= 0;
--			baud <= '1';
--		else
--			baud_count <= baud_count + 1;
--			baud <= '0';
--		end if;
--	end if;


end Behavioral;

