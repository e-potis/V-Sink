library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity WORD_CON is
    Port ( serin : in  STD_LOGIC_VECTOR (7 downto 0);
			  strobe_in: in  STD_LOGIC;
			  clk: in STD_LOGIC;
			  strobe_out: out STD_LOGIC;
			  A : out STD_LOGIC_VECTOR (24575 downto 0)
			  
			  );
			  
end WORD_CON;

architecture Behavioral of WORD_CON is

signal word: STD_LOGIC_VECTOR (24575 downto 0);

begin

process (strobe_in)

variable byte_no: integer range 0 to 3071:=3071;

begin


	if (rising_edge(strobe_in)) then
			
			if (byte_no=3071) then
				byte_no:=0;
				A<=word;
				A(7 downto 0) <= serin;
				strobe_out<='1';
			else
				word((byte_no*8+7) downto byte_no*8)<=serin;
				byte_no:=byte_no+1;
				strobe_out<='0';
			end if;
			
	end if;

end process;

end Behavioral;

