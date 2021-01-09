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

--Control Signals
signal Rsrc_out : std_logic;
signal Rdst_out : std_logic;
signal Rsrc_in : std_logic;
signal Rdst_in : std_logic;

signal IR_in : std_logic;

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
  ---------------------------RAM----------------------------------------
  --ram_we <= not dst_en;
  --ram_inst: ram generic map (WORDSIZE, RAM_ADDRESS_SIZE) port map(clk, ram_we, counter_out, bus_io, Ram_out);
  --bus_io <= Ram_out when src_en = '0' else (others => 'Z');
  ---------------------------Counter------------------------------------
  --counter_inst: counter generic map(RAM_ADDRESS_SIZE) port map(clk, rst, counter_out);
  
end system_1;
