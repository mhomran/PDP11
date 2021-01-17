library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;
use IEEE.std_logic_arith.all;

entity system is
  GENERIC (
    WORDSIZE : integer := 16;
    REG_NUM : integer := 8;
    RAM_ADDRESS_SIZE : integer := 11 --to get 2K words
  );
  port(
      clk_input : in std_logic;
      IRQ : in std_logic
    );  
end system;

architecture system_1 of system is

--CLK
signal clk : std_logic;

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

--decoder 
component decAxB is
  generic (INPUT_SIZE: integer := 3);
  PORT(
      en : in std_logic; 
      A : in std_logic_vector(INPUT_SIZE-1 DOWNTO 0);
      Y : out std_logic_vector(2**INPUT_SIZE-1 DOWNTO 0)
   );
end component;


--alu
component alu is
generic (WORDSIZE : integer := 16);
port (                 	
    A, B: in std_logic_vector(WORDSIZE-1 downto 0); 
    S: in std_logic_vector(3 downto 0);
    Cin: in std_logic;
    FLAGS_Cin: in std_logic;
    F: out std_logic_vector(WORDSIZE-1 downto 0);
    ALU_FLAGS: out std_logic_vector(WORDSIZE-1 downto 0)
    );            		
end component; 

--ram
component ram is
	generic(
		WORDSIZE : integer := 16;
		ADDRESS_SIZE : integer := 16
	);
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address : IN  std_logic_vector(ADDRESS_SIZE-1 DOWNTO 0);
		datain  : IN  std_logic_vector(WORDSIZE-1 DOWNTO 0);
		dataout : OUT std_logic_vector(WORDSIZE-1 DOWNTO 0));
end component;

--Decoding unit
component DCU IS
	GENERIC (ADDRESS_SIZE : INTEGER := 9);
	PORT(
		FLAGS: IN std_logic_vector(15 DOWNTO 0);
		IR : IN std_logic_vector(15 DOWNTO  0);
		clk : in std_logic;
		IRQ : IN std_logic;
		control_word: OUT std_logic_vector(34 DOWNTO 0)
		);
END component;

--inputs of the tristates
type R_out is array (REG_NUM-1 downto 0) of std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal R_output : R_out;

signal RAM_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal IR_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal TEMP_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal SOURCE_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal DEST_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal Y_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal Op2_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal Op1_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal Z_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal FLAGS_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal ADDRESS_DEC_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal MAR_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal MDR_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);

--decoders output
signal src_out : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal dst_out : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal R_output_en : std_logic_vector(REG_NUM-1 DOWNTO 0);

signal src_in : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal dst_in : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal R_input_en : std_logic_vector(REG_NUM-1 DOWNTO 0);

--the bus
signal bus_io : std_logic_vector(WORDSIZE-1 DOWNTO 0);

-- ALU
signal ALU_FLAGS : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal FLAGS_input : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal Z_input : std_logic_vector(WORDSIZE-1 DOWNTO 0);

--RAM
signal MDR_input : std_logic_vector(WORDSIZE-1 DOWNTO 0);

--Interrupt
signal PC_input : std_logic_vector(WORDSIZE-1 DOWNTO 0);

--Control Signals
signal Rsrc_out : std_logic;
signal Rdst_out : std_logic;
signal Rsrc_in : std_logic;
signal Rdst_in : std_logic;

signal IR_in : std_logic;

signal TEMP_in : std_logic;
signal TEMP_out : std_logic;

signal SOURCE_in : std_logic;
signal SOURCE_out : std_logic;

signal DEST_in : std_logic;
signal DEST_out : std_logic;

signal Y_in : std_logic;
signal Clear_Y : std_logic;

signal Z_in : std_logic;
signal Z_out : std_logic;

signal FLAGS_in : std_logic;
signal FLAGS_out : std_logic;
signal FLAGS_ch : std_logic;

signal Address_out : std_logic;

signal Carry_in : std_logic;
signal alu_selector : std_logic_vector(3 downto 0);

signal MAR_in : std_logic;
signal MDR_in : std_logic;
signal MDR_out : std_logic;
signal RAM_Write : std_logic;
signal RAM_Read : std_logic;

signal HLT : std_logic := '0';

signal INT : std_logic := '0';

signal PC_in : std_logic := '0';
signal PC_in_or_output : std_logic;
signal PC_out : std_logic := '0';
signal PC_out_or_output : std_logic;

signal SP_in : std_logic := '0';
signal SP_in_or_output : std_logic;
signal SP_out : std_logic := '0';
signal SP_out_or_output : std_logic;

--Control word
signal control_word : std_logic_vector(34 DOWNTO 0);

begin
  ----------------------------clock gating -----------------------------
  clk <= clk_input and not HLT;
  ----------------------------register file-----------------------------
  R: for i in 0 to REG_NUM-3 generate
    R_reg: reg generic map (WORDSIZE) port map(clk, R_input_en(i), bus_io, R_output(i));  
    bus_io <= R_output(i) when R_output_en(i) = '1' else (others => 'Z');
  end generate;

  PC: reg generic map (WORDSIZE) port map(clk, PC_in_or_output, PC_input, R_output(REG_NUM-1));  
  bus_io <= R_output(REG_NUM-1) when PC_out_or_output = '1' else (others => 'Z');
  PC_in_or_output <= PC_in or R_input_en(REG_NUM-1);
  PC_out_or_output <= PC_out or R_output_en(REG_NUM-1);
  PC_input <= bus_io when INT = '0' else conv_std_logic_vector(1024, WORDSIZE); --1024 address (ISR base address)

  SP: reg generic map (WORDSIZE) port map(clk, SP_in_or_output, bus_io, R_output(REG_NUM-2));  
  bus_io <= R_output(REG_NUM-2) when SP_out_or_output = '1' else (others => 'Z');
  SP_in_or_output <= SP_in or R_input_en(REG_NUM-2);
  SP_out_or_output <= SP_out or R_output_en(REG_NUM-2);
  
  src_out_dec_inst: decAxB generic map (integer(ceil(log2(real(REG_NUM))))) port map(Rsrc_out, IR_output(8 downto 6), src_out);
  dst_out_dec_inst: decAxB generic map (integer(ceil(log2(real(REG_NUM))))) port map(Rdst_out, IR_output(2 downto 0), dst_out);
  
  src_in_dec_inst: decAxB generic map (integer(ceil(log2(real(REG_NUM))))) port map(Rsrc_in, IR_output(8 downto 6), src_in);
  dst_in_dec_inst: decAxB generic map (integer(ceil(log2(real(REG_NUM))))) port map(Rdst_in, IR_output(2 downto 0), dst_in);

  R_output_en <= dst_out or src_out;
  R_input_en <= dst_in or src_in;
  ----------------------------Other registers --------------------------
  IR: reg generic map (WORDSIZE) port map(clk, IR_in, bus_io, IR_output);  

  TEMP: reg generic map (WORDSIZE) port map(clk, TEMP_in, bus_io, TEMP_output);
  bus_io <= TEMP_output when TEMP_out = '1' else (others => 'Z');

  SOURCE: reg generic map (WORDSIZE) port map(clk, SOURCE_in, bus_io, SOURCE_output);
  bus_io <= SOURCE_output when SOURCE_out = '1' else (others => 'Z');

  DEST: reg generic map (WORDSIZE) port map(clk, DEST_in, bus_io, DEST_output);
  bus_io <= DEST_output when DEST_out = '1' else (others => 'Z');

  Y: reg generic map (WORDSIZE) port map(clk, Y_in, bus_io, Y_output);
  
  Z: reg generic map (WORDSIZE) port map(clk, Z_in, Z_input, Z_output);
  bus_io <= Z_output when Z_out = '1' else (others => 'Z');

  ADDRESS_DEC_output(6 downto 0) <= IR_output(6 downto 0);
  ADDRESS_DEC_output(WORDSIZE-1 downto 7) <= (others => '0') when IR_output(7) = '0'
  else (others => '1');
  
  bus_io <= ADDRESS_DEC_output when Address_out = '1' else (others => 'Z');
  ---------------------------ALU----------------------------------------
  Op1_output <= Y_output when Clear_Y = '0' else bus_io;
  Op2_output <= bus_io when Clear_Y = '0' else (others => '0');

  ALU_inst: alu generic map (WORDSIZE) port map(Op1_output, Op2_output, alu_selector, Carry_in, FLAGS_output(0), Z_input, ALU_FLAGS);
  
  FLAGS: reg generic map (WORDSIZE) port map(clk, FLAGS_in, FLAGS_input, FLAGS_output);
  FLAGS_input <= bus_io when FLAGS_ch = '1' else ALU_FLAGS;
  bus_io <= FLAGS_output when FLAGS_out = '1' else (others => 'Z');
  ---------------------------RAM----------------------------------------
  RAM_inst: ram generic map (WORDSIZE, RAM_ADDRESS_SIZE) 
  port map(clk, RAM_Write, MAR_output(RAM_ADDRESS_SIZE-1 downto 0), MDR_output, RAM_output);

  MAR: reg generic map (WORDSIZE) port map(clk, MAR_in, bus_io, MAR_output);

  MDR: reg generic map (WORDSIZE) port map(clk, MDR_in, MDR_input, MDR_output);
  MDR_input <= RAM_output when RAM_Read = '1' else bus_io;
  bus_io <= MDR_output when MDR_out = '1' else (others => 'Z');
  -------------------------------Decoding unit---------------------------
  DCU_inst: dcu port map(FLAGS_output, IR_output, clk, IRQ, control_word);
  -------------------------------Signal Assignment -----------------------
  PC_out     <= control_word(0);
  MDR_out    <= control_word(1);
  Z_out      <= control_word(2);
  Rsrc_out   <= control_word(3);
  Rdst_out   <= control_word(4);
  TEMP_out   <= control_word(5);
  Address_out<= control_word(6);
  SOURCE_out <= control_word(7);
  DEST_out   <= control_word(8);
  SP_out     <= control_word(9);
  FLAGS_out  <= control_word(10);

  PC_in      <= control_word(11);
  IR_in      <= control_word(12);
  Z_in       <= control_word(13);
  Rsrc_in    <= control_word(14);
  Rdst_in    <= control_word(15);
  SP_in      <= control_word(16);
  MAR_in     <= control_word(17);
  MDR_in     <= control_word(18);
  TEMP_in    <= control_word(19);
  Y_in       <= control_word(20);
  SOURCE_in  <= control_word(21);
  DEST_in    <= control_word(22);

  alu_selector <= control_word(26 downto 23);

  RAM_Read   <= control_word(27);
  RAM_Write  <= control_word(28);
  Clear_Y    <= control_word(29);
  Carry_in   <= control_word(30);
  FLAGS_in   <= control_word(31);
  HLT        <= control_word(32);
  INT        <= control_word(33);
  FLAGS_CH   <= control_word(34);

end system_1;
