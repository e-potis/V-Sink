library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity LED_TX is
    Port ( clk : in  STD_LOGIC;
			  inpt: in STD_LOGIC;
			  fifo_clk: out STD_LOGIC;
			  fifo_full: in STD_LOGIC;
			  fifo_empty: in STD_LOGIC;
			  fifo_reset: out STD_LOGIC;
			  we: out STD_LOGIC;
			  re: out STD_LOGIC;
			  led_out:out STD_LOGIC;
           tx : out  STD_LOGIC);
end LED_TX;

architecture Behavioral of LED_TX is

signal reset_count : integer range 0 to 8191 :=0;
signal fifo_count : integer range 0 to 127 :=0;
signal led_count : integer range 0 to 127 :=0;
type state_type is (wait_st,start_st,reset_st);  
signal current_st: state_type :=wait_st;
signal next_st: state_type;
  
signal read_bit: std_logic;



begin


process (clk)
begin

if (rising_edge(clk)) then
		if (fifo_count=119) then   --1.25us = 120 counts @96MHz
			fifo_count <= 0;
		else
			fifo_count <= fifo_count + 1;
		end if;
		if (fifo_count<60) then
			fifo_clk<='1';
		else
			fifo_clk<='0';
		end if;
		
		if (fifo_count=30) then   --1.25us = 120 counts @96MHz
			led_count <= 0;		
		else
			led_count <= led_count + 1;
		end if;
		
		
end if;
end process;


process (clk,fifo_full,fifo_empty)
begin


if (rising_edge(clk)) then
current_st<=next_st;


  case current_st is
   
	when wait_st =>
		we<='1';
		re<='0';	
		led_out<='1';
	   tx<='0';
		fifo_reset<='1';
		
			if (fifo_full='1') then 
				next_st<=start_st;
			end if;
			
			
	when start_st =>
		we<='0';
		re<='1';
		led_out<='0';
		fifo_reset<='0';	
		if (fifo_count=0) then
			read_bit<=inpt;
		end if;
		
				  if read_bit='1' then
						if fifo_count <58 then
							tx<='1';
						else
							tx<='0';
						end if;
					else						
						if fifo_count<24 then
							tx<='1';
						else
							tx<='0';
						end if;
					end if;	

		if (fifo_empty='1') then
			next_st<=reset_st;
		end if;					
	
	
	when reset_st =>
	   we<='0';
   	re<='0';
		tx<='0';
		fifo_reset<='0';


		if (reset_count>5000) then --4800 should be 50us
			tx<='0';
			next_st<=wait_st;
			reset_count<=0; 
	   else
			reset_count<=reset_count+1;
		
		end if;
		
   end case;

end if;


end process;


end Behavioral;

