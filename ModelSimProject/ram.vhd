LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY ram IS
	generic(
		WORDSIZE : integer := 32;
		ADDRESS_SIZE : integer := 6
	);
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address : IN  std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
		datain  : IN  std_logic_vector(WORDSIZE-1 DOWNTO 0);
		dataout : OUT std_logic_vector(WORDSIZE-1 DOWNTO 0));
END ENTITY ram;

ARCHITECTURE syncrama OF ram IS

	TYPE ram_type IS ARRAY(0 TO 2**ADDRESS_SIZE-1) OF std_logic_vector(WORDSIZE-1 DOWNTO 0);
	SIGNAL ram : ram_type;
	
	BEGIN
		PROCESS(clk) IS
			BEGIN
				IF rising_edge(clk) THEN  
					IF we = '1' THEN
						ram(to_integer(unsigned(address))) <= datain;
					END IF;
				END IF;
		END PROCESS;
		dataout <= ram(to_integer(unsigned(address)));
END syncrama;
