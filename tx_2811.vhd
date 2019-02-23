library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity tx_2811 is
    Port ( clk : in  STD_LOGIC;
			  inpt: in STD_LOGIC_VECTOR(24575 downto 0);
			  strobe: in STD_LOGIC;
           tx : out  STD_LOGIC);
end tx_2811;

architecture Behavioral of tx_2811 is
signal count : integer range 0 to 124 :=0;
signal bit_count: integer range 0 to 24575 :=0;
signal flag : std_logic;
begin


baud_timer: process(clk,strobe)
begin

if strobe='1' then
 flag<='1';
 bit_count<=0;
 count <= 0;
 
elsif clk'event and clk='1' and flag = '1' then
-----		
		if bit_count = 24575 then
			flag<='0';
			tx<='0';
		else
	-----	
				if count=125 then
					
					bit_count<=bit_count+1;
				else
					count <= count + 1;
				end if;
	-----		
				if inpt(bit_count)='1' then
					if count<60 then
						tx<='1';
					else
						tx<='0';
					end if;
	    		else						
					if count<25 then
						tx<='1';
					else
						tx<='0';
					end if;
				end if;		
		end if;
end if;
end process baud_timer;


end Behavioral;

