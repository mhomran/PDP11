LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY PLA IS
	GENERIC (ADDRESS_SIZE : INTEGER := 9);
	PORT(
		uAR : OUT std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
		IR : IN std_logic_vector(15 DOWNTO  0)
	);
		
END ENTITY PLA;

ARCHITECTURE PLAa OF PLA IS
	signal uARTemp : std_logic_vector(8 DOWNTO 0);
	constant src_base_address : std_logic_vector(8 DOWNTO 0) := std_logic_vector(to_unsigned(8#101#, uAR'length));
	constant dst_base_address : std_logic_vector(8 DOWNTO 0) := std_logic_vector(to_unsigned(8#201#, uAR'length));
	constant branch_base_address : std_logic_vector(8 DOWNTO 0) := std_logic_vector(to_unsigned(8#005#, uAR'length));
	constant nop_base_address : std_logic_vector(8 DOWNTO 0) := std_logic_vector(to_unsigned(8#000#, uAR'length));
	constant hlt_base_address : std_logic_vector(8 DOWNTO 0) := std_logic_vector(to_unsigned(8#004#, uAR'length));
	constant rts_base_address : std_logic_vector(8 DOWNTO 0) := std_logic_vector(to_unsigned(8#640#, uAR'length));
	constant iret_base_address : std_logic_vector(8 DOWNTO 0) := std_logic_vector(to_unsigned(8#660#, uAR'length));
	BEGIN
		PROCESS (IR)	
			begin
				if to_integer(unsigned(IR(15 DOWNTO 12))) < 9 then
					uARTemp <= src_base_address;
					uARTemp(5 DOWNTO 4) <= src_base_address(5 DOWNTO 4) or IR(11 DOWNTO 10);
			
					uARTemp(3) <= (src_base_address(3) or IR(9)) and (not IR(10)) and (not IR(11));
				
				elsif to_integer(unsigned(IR(15 DOWNTO 12))) = 9 or IR(15 DOWNTO 10) = "110000" then
					uARTemp <= dst_base_address;
					uARTemp(5 DOWNTO 4) <= dst_base_address(5 DOWNTO 4) or IR(5 DOWNTO 4);
			
					uARTemp(3) <= (dst_base_address(3) or IR(3)) and (not IR(4)) and (not IR(5));
				
				elsif to_integer(unsigned(IR(15 DOWNTO 12))) = 10 then
					uARTemp <= branch_base_address;
				
				elsif to_integer(unsigned(IR(15 DOWNTO 12))) = 11 and IR(11 DOWNTO 10) = "01" then 
					uARTemp <= nop_base_address;
				
				elsif to_integer(unsigned(IR(15 DOWNTO 12))) = 11 and IR(11 DOWNTO 10) = "00" then 
					uARTemp <= hlt_base_address;
				
				elsif IR(15 DOWNTO 10) = "110001" then
					uARTemp <= rts_base_address;

				elsif IR(15 DOWNTO 10) = "110010" then
					uARTemp <= iret_base_address;
				else uARTemp <= (others => '0');
				end if;		
					
				
		END PROCESS;
		uAR <= uARTemp;
END PLAa;
