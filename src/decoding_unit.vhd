LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY DCU IS
	GENERIC (ADDRESS_SIZE : INTEGER := 9);
	PORT(
		FLAGS: IN std_logic_vector(15 DOWNTO 0);
		IR : IN std_logic_vector(15 DOWNTO  0);
		clk : in std_logic;
		control_word: OUT std_logic_vector(34 DOWNTO 0)
		);
		
END ENTITY DCU;
		
		
ARCHITECTURE dcu1 OF DCU IS

-- pla
component PLA IS
GENERIC (ADDRESS_SIZE : INTEGER := 9);
PORT(
	IR : IN std_logic_vector(15 DOWNTO  0);
	uAR : OUT std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0)
);
	
END component;

--register 
component reg IS
GENERIC (WORDSIZE : integer := 16);
		 PORT(
			 	clk : IN std_logic; 
        		en : in std_logic;
		 		d : IN std_logic_vector(WORDSIZE-1 DOWNTO 0);
				q : OUT std_logic_vector(WORDSIZE-1 DOWNTO 0)
				);
END component;

-- control store
component control_store IS
	generic(
		WORDSIZE : integer := 36;
		ADDRESS_SIZE : integer := 9
	);
	PORT(
		address : IN  std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
		dataout : OUT std_logic_vector(WORDSIZE-1 DOWNTO 0)
		);
END component;

-- OR's
		signal OR_dst: std_logic := '0';
		signal OR_indsrc: std_logic := '0';
		signal OR_inddst: std_logic := '0';
		signal OR_result: std_logic := '0';
		signal OR_ALU: std_logic := '0';
		signal OR_sng_JSR: std_logic := '0';
		signal OR_INT : std_logic := '0';

		signal PLA_out : std_logic := '0';
		
		signal PLA_output : std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
		signal uAR_output : std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0) := (others => '0');
		signal uIR : std_logic_vector(35 DOWNTO 0);
		signal uAR_input : std_logic_vector(8 DOWNTO 0) := (others => '0');
		
		begin
			--------------------------- control store -----------------------------
			cs: control_store generic map(36, 9) port map (uAR_output, uIR);
			
			--------------------------- uAR register ------------------------------
			uAR: reg generic map(9) port map (clk, '1', uAR_input, uAR_output);
			
			------------------------------- PLA -----------------------------------
			PLA_inst: PLA port map(IR, PLA_output);
			
			PLA_out <= uIR(3);
			
	process (PLA_output, uAR_input, uIR, IR, OR_dst, OR_indsrc, OR_inddst, OR_result, OR_ALU, OR_sng_JSR, OR_INT, PLA_out)
		variable temp : std_logic_vector(8 DOWNTO 0);
	begin
		
		if PLA_out = '1' then 
			temp := PLA_output;
		else
			temp := (others => '0');
		end if;

		-- OR next address
		temp := temp or uIR(35 DOWNTO 27); 
		
		-- OR dst
		temp(3) := temp(3) or (OR_dst and IR(3) and (not IR(5)) and (not IR(4)));
		temp(5 DOWNTO 4) := temp(5 DOWNTO 4) or ((OR_dst & OR_dst) and IR(5 DOWNTO 4));

		-- OR indsrc
		temp(1) := temp(1) or (OR_indsrc and IR(9));

		-- OR indds
		temp(1) := temp(1) or (OR_inddst and IR(3));

		-- OR result
		temp(1) := temp(1) or (OR_result and (not IR(5)) and (not IR(4)) and (not IR(3)));

		-- OR ALU
		-- uAR_input() <= 
		uAR_input <= temp;
	end process;
	
END dcu1;
