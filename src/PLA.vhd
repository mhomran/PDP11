LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY PLA IS
	GENERIC (ADDRESS_SIZE : INTEGER := 9);
	PORT(
		OR_dst: IN std_logic;
		OR_indsrc: IN std_logic;
		OR_inddst: IN std_logic;
		OR_result: IN std_logic;
--		OR_ALU: IN std_logic;
--		OR_sng_JSR: IN std_logic;
--		OR_INT: IN std_logic;
	
		uAR : OUT std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
--		FLAGS : IN  std_logic_vector(15 DOWNTO 0);
		IR : IN std_logic_vector(15 DOWNTO  0)
	);
		
END ENTITY PLA;

ARCHITECTURE PLAa OF PLA IS
	signal uARTemp : std_logic_vector(8 DOWNTO 0);
	constant src_base_address : std_logic_vector(8 DOWNTO 0) := std_logic_vector(to_unsigned(8#101#, uAR'length));
	BEGIN
		PROCESS (IR)	
			begin
			case IR(15 DOWNTO 12) is
			  WHEN "0000" => uARTemp <= src_base_address;
			  WHEN "0001" => uARTemp <= src_base_address;
			  WHEN "0010" => uARTemp <= src_base_address;
			  WHEN "0011" => uARTemp <= src_base_address;
			  WHEN "0100" => uARTemp <= src_base_address;
			  WHEN "0101" => uARTemp <= src_base_address;
			  WHEN "0110" => uARTemp <= src_base_address;
			  WHEN "0111" => uARTemp <= src_base_address;
			  WHEN "1000" => uARTemp <= src_base_address;
			  WHEN others => uARTemp <= (others => '0');
			end case;
		uARTemp(5 DOWNTO 4) <= src_base_address(5 DOWNTO 4) or IR(11 DOWNTO 10);
		
		uARTemp(3) <= (src_base_address(3) or IR(9)) and (not IR(10)) and (not IR(11));
		END PROCESS;
		uAR <= uARTemp;
END PLAa;
