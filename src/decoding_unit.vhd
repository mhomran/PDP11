LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
use ieee.std_logic_misc.all;  


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

component decAxB is
generic (INPUT_SIZE: integer := 2);
PORT(
	en : in std_logic; 
	A : in std_logic_vector(INPUT_SIZE-1 DOWNTO 0);
	Y : out std_logic_vector(2**INPUT_SIZE-1 DOWNTO 0)
	);
end component;

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
		

		signal eq_cond_code : std_logic_vector(2 downto 0);
		signal eq : std_logic;
		
		signal ne_cond_code : std_logic_vector(2 downto 0);
		signal ne : std_logic;
		
		signal lo_cond_code : std_logic_vector(2 downto 0);
		signal lo : std_logic;
		
		signal ls_cond_code : std_logic_vector(2 downto 0);
		signal ls : std_logic;
		
		signal hi_cond_code : std_logic_vector(2 downto 0);
		signal hi : std_logic;
		
		signal hs_cond_code : std_logic_vector(2 downto 0);
		signal hs : std_logic;
		
		signal branch : std_logic;

	--Decoders output
	signal F1_decoded : std_logic_vector(15 downto 0);
	signal F2_decoded : std_logic_vector(7 downto 0);
	signal F3_decoded : std_logic_vector(3 downto 0);
	signal F4_decoded : std_logic_vector(3 downto 0);
	signal F6_decoded : std_logic_vector(3 downto 0);
	signal F10_decoded : std_logic_vector(7 downto 0);
	
	begin
		--------------------------- control store -----------------------------
		cs: control_store generic map(36, 9) port map (uAR_output, uIR);
		
		--------------------------- uAR register ------------------------------
		uAR: reg generic map(9) port map (clk, '1', uAR_input, uAR_output);
		
		------------------------------- PLA -----------------------------------
		PLA_inst: PLA port map(IR, PLA_output);
		
		PLA_out <= uIR(3);
		----------------------------Condtion codes-----------------------------
		eq_cond_code <= IR(10 downto 8) xnor "001";
		ne_cond_code <= IR(10 downto 8) xnor "010";
		lo_cond_code <= IR(10 downto 8) xnor "011";
		ls_cond_code <= IR(10 downto 8) xnor "100";
		hi_cond_code <= IR(10 downto 8) xnor "101";
		hs_cond_code <= IR(10 downto 8) xnor "110";
		--------------------------------FLAGS----------------------------------
		eq <= and_reduce(eq_cond_code) and FLAGS(1);
		ne <= and_reduce(ne_cond_code) and not FLAGS(1);
		lo <= and_reduce(lo_cond_code) and FLAGS(0);
		ls <= and_reduce(ls_cond_code) and or_reduce(FLAGS(1 downto 0));
		hi <= and_reduce(hi_cond_code) and not or_reduce(FLAGS(1 downto 0));
		hs <= and_reduce(hs_cond_code) and not FLAGS(0);

		branch <= eq or ne or lo or ls or hi or hs;
		---------------------------------Oring ---------------------------------
	process (PLA_output, uAR_input, uIR, IR, OR_dst, OR_indsrc, OR_inddst, 
	OR_result, OR_ALU, OR_sng_JSR, OR_INT, PLA_out)
		variable temp : std_logic_vector(8 DOWNTO 0);
	begin
		
		if PLA_out = '1' then 
			temp := PLA_output;

			if IR(15 downto 12) = "1010" then
				if branch = '1' then
					temp := temp;
				else
					temp := (others => '0');
				end if;
			else temp := temp;
			end if;

		else
			temp := (others => '0');
		end if;

		-- OR next address
		temp := temp or uIR(35 DOWNTO 27); 
		
		-- OR dst
		temp(3) := temp(3) or (OR_dst and IR(3) and (not IR(5)) and (not IR(4)));
		temp(5 DOWNTO 4) := temp(5 DOWNTO 4) or ((OR_dst & OR_dst) and IR(5 DOWNTO 4));

		-- OR indsrc
		temp(1) := temp(1) or (OR_indsrc and not IR(9));

		-- OR indds
		temp(1) := temp(1) or (OR_inddst and not IR(3));

		-- OR result
		temp(1) := temp(1) or (OR_result and (not IR(5)) and (not IR(4)) and (not IR(3)));

		-- OR ALU
		temp(5) := temp(5) or (OR_ALU and IR(15));
		temp(4) := temp(4) or (OR_ALU and IR(14));
		temp(3) := temp(3) or (OR_ALU and IR(13));
		temp(2) := temp(2) or (OR_ALU and IR(12));

		--OR_sng_JSR
		temp(5) := temp(5) or (OR_sng_JSR and and_reduce(IR(15 DOWNTO 12) xnor "1001"));
		temp(6) := temp(6) or (OR_sng_JSR and and_reduce(IR(15 DOWNTO 10) xnor "110000"));

		--OR_INT
		--TODO

		uAR_input <= temp;
	end process;

	------------------------------------signal decoders--------------------------
	F1: decAxB generic map (4) port map('1', uIR(26 downto 23), F1_decoded);
	F2: decAxB generic map (3) port map('1', uIR(22 downto 20), F2_decoded);
	F3: decAxB generic map (2) port map('1', uIR(19 downto 18), F3_decoded);
	F4: decAxB generic map (2) port map('1', uIR(17 downto 16), F4_decoded);
	F6: decAxB generic map (2) port map('1', uIR(11 downto 10), F6_decoded);

	F10: decAxB generic map (3) port map('1', uIR(6 downto 4), F10_decoded);
	OR_dst <= F10_decoded(1);
	OR_indsrc <= F10_decoded(2);
	OR_inddst <= F10_decoded(3);
	OR_result <= F10_decoded(4);
	OR_ALU <= F10_decoded(5);
	OR_sng_JSR <= F10_decoded(6);
	OR_INT <= F10_decoded(7);
	-----------------------------------Control Word -----------------------------
	control_word(0) <= F1_decoded(1); 	--PC_out;
	control_word(1) <= F1_decoded(2); 	--MDR_out;
	control_word(2) <= F1_decoded(3); 	--Z_out;
	control_word(3) <= F1_decoded(4); 	--Rsrc_out;
	control_word(4) <= F1_decoded(5); 	--Rdst_out;
	control_word(5) <= F1_decoded(6); 	--TEMP_out;
	control_word(6) <= F1_decoded(7); 	--Address_out;
	control_word(7) <= F1_decoded(8); 	--SOURCE_out;
	control_word(8) <= F1_decoded(9); 	--DEST_out;
	control_word(9) <= F1_decoded(10); 	--SP_out;
	control_word(10) <= F1_decoded(11); --FLAGS_out;

	control_word(11) <= F2_decoded(1); 	--PC_in;
	control_word(12) <= F2_decoded(2);	--IR_in;
	control_word(13) <= F2_decoded(3); 	--Z_in;
	control_word(14) <= F2_decoded(4); 	--Rsrc_in;
	control_word(15) <= F2_decoded(5); 	--Rdst_in;
	control_word(16) <= F2_decoded(6); 	--SP_in;

	control_word(17) <= F3_decoded(1); 	--MAR_in;
	control_word(18) <= F3_decoded(2); 	--MDR_in;
	control_word(19) <= F3_decoded(3); 	--TEMP_in;
	
	control_word(20) <= F4_decoded(1); 	--Y_in;
	control_word(21) <= F4_decoded(2); 	--SOURCE_in;
	control_word(22) <= F4_decoded(3); 	--DEST_in;

	control_word(26 downto 23) <= uIR(15 downto 12); --ALU_sel;

	control_word(27) <= F6_decoded(1); 	--RAM_Read;
	control_word(28) <= F6_decoded(2); 	--RAM_Write;

	control_word(29) <= uIR(9); --Clear_Y
	control_word(30) <= uIR(8); --Carry_in
	control_word(31) <= uIR(7); --FLAGS_in
	control_word(32) <= uIR(2); --HLT
	control_word(33) <= uIR(1); --INT
	control_word(34) <= uIR(0); --FLAGS_CH

END dcu1;
