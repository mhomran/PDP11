LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY my_adder IS
	PORT (a,b,cin : IN  std_logic;
		  s, cout : OUT std_logic );
END my_adder;

ARCHITECTURE a_my_adder OF my_adder IS
	BEGIN
	s <= a XOR b XOR cin;
	cout <= (a AND b) OR (cin AND (a XOR b));
END a_my_adder;