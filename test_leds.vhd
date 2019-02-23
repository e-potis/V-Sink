library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity test_leds is
    Port ( clk : in  STD_LOGIC;
           tx : out  STD_LOGIC);
end test_leds;

architecture Behavioral of test_leds is

type state_type is (wait_st,start_st);  
signal current_st,next_st: state_type;  

signal count : integer range 0 to 124 :=0;
signal word: STD_LOGIC_VECTOR (1535 downto 0) := X"ff0000ff0000ff0000ff0000ff0000ff0000ff0000ff000000000000000000000000000000000000000000000000000000ff0000ff0000ff0000ff0000ff0000ff0000ff0000ff000000000000000000000000000000000000000000000000000000ff0000ff0000ff0000ff0000ff0000ff0000ff0000ff000000000000000000000000000000000000000000000000ff0000ff0000ff0000ff0000ff0000ff0000ff0000ff0000000000000000000000000000000000000000000000000000";
signal bit_count: integer range 0 to 2047:=0;

begin

process(clk)
begin
if (rising_edge(clk)) then

					if count=124 then
						count<=0;
						if (bit_count=1575) then
							bit_count<=0;
						else
							bit_count<=bit_count+1;
					   end if;
					else
						count <= count + 1;
					end if;
					
					if (bit_count>1535) then
							tx<='0';
					else			
							if word(bit_count)='1' then
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


end process;


end Behavioral;

