LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY rom IS
	generic(
		WORDSIZE : integer := 36;
		ADDRESS_SIZE : integer := 9
	);
	PORT(
		address : IN  std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
		dataout : OUT std_logic_vector(WORDSIZE-1 DOWNTO 0)
		);
END ENTITY rom;

ARCHITECTURE roma OF rom IS

	TYPE rom_type IS ARRAY(0 TO 2**ADDRESS_SIZE-1) OF std_logic_vector(WORDSIZE-1 DOWNTO 0);
	SIGNAL rom : rom_type;
	BEGIN
		dataout <= rom(to_integer(unsigned(address)));
END roma;
