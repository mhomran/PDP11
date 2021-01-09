library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;

entity system is
  GENERIC (
    WORDSIZE : integer := 16;
    REG_NUM : integer := 8;
    RAM_ADDRESS_SIZE : integer := 16
  );
  port(
      clk: in std_logic
    );  
end system;

architecture system_1 of system is

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

--inputs of the tristates
type R_out is array (REG_NUM-1 downto 0) of std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal R_output : R_out;

signal Ram_out : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal IR_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal TEMP_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal SOURCE_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal DEST_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal Y_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal Z_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal FLAGS_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal ADDRESS_DEC_output : std_logic_vector(WORDSIZE-1 DOWNTO 0);

--decoders output
signal src_out : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal dst_out : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal R_output_en : std_logic_vector(REG_NUM-1 DOWNTO 0);

signal src_in : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal dst_in : std_logic_vector(REG_NUM-1 DOWNTO 0);
signal R_input_en : std_logic_vector(REG_NUM-1 DOWNTO 0);

--the bus
signal bus_io : std_logic_vector(WORDSIZE-1 DOWNTO 0);

--ram WE signal
signal ram_we : std_logic;

-- ALU
signal ALU_FLAGS : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal FLAGS_input : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal Z_input : std_logic_vector(WORDSIZE-1 DOWNTO 0);

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

signal Z_in : std_logic;
signal Z_out : std_logic;

signal FLAGS_in : std_logic;
signal FLAGS_out : std_logic;
signal FLAGS_ch : std_logic;

signal Address_out : std_logic;

signal Carry_in : std_logic;
signal alu_selector : std_logic_vector(3 downto 0);

begin
  ----------------------------register file-----------------------------
  R: for i in 0 to REG_NUM-1 generate
    R_reg: reg generic map (WORDSIZE) port map(clk, R_input_en(i), bus_io, R_output(i));  
    bus_io <= R_output(i) when R_output_en(i) = '1' else (others => 'Z');
  end generate;
  
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

  ADDRESS_DEC_output(7 downto 0) <= IR_output(7 downto 0);
  ADDRESS_DEC_output(WORDSIZE-1 downto 8) <= (others => '0');
  bus_io <= ADDRESS_DEC_output when Address_out = '1' else (others => 'Z');

  FLAGS: reg generic map (WORDSIZE) port map(clk, FLAGS_in, FLAGS_input, FLAGS_output);
  FLAGS_input <= bus_io when FLAGS_ch = '1' else ALU_FLAGS;
  bus_io <= FLAGS_output when FLAGS_out = '1' else (others => 'Z');
  ---------------------------ALU----------------------------------------
  ALU_inst: alu generic map (WORDSIZE) port map(Y_output, bus_io, alu_selector, Carry_in, FLAGS_output(0), Z_input, ALU_FLAGS);

  ---------------------------RAM----------------------------------------
  --ram_we <= not dst_en;
  --ram_inst: ram generic map (WORDSIZE, RAM_ADDRESS_SIZE) port map(clk, ram_we, counter_out, bus_io, Ram_out);
  --bus_io <= Ram_out when src_en = '0' else (others => 'Z');
  ---------------------------Counter------------------------------------
  --counter_inst: counter generic map(RAM_ADDRESS_SIZE) port map(clk, rst, counter_out);
  
end system_1;
