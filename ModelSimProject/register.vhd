LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY reg IS
GENERIC (WORDSIZE : integer := 32);
		 PORT(
			 	clk : IN std_logic; 
				en : in std_logic;
		 		d : IN std_logic_vector(WORDSIZE-1 DOWNTO 0);
				q : OUT std_logic_vector(WORDSIZE-1 DOWNTO 0) := (others => '0')
				);
END reg;

ARCHITECTURE reg_1 OF reg IS
BEGIN
	PROCESS(clk)
	BEGIN
		IF rising_edge(clk) and en = '1'  THEN     
			q <= d;
		END IF;
	END PROCESS;
END reg_1;


