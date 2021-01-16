library ieee;                                	
use ieee.std_logic_1164.all;  
use ieee.std_logic_misc.all;  

entity ALU is 
generic (WORDSIZE : integer := 16);
port (                 	
    A, B: in std_logic_vector(WORDSIZE-1 downto 0); 
    S: in std_logic_vector(3 downto 0);
    Cin: in std_logic;
    FLAGS_Cin: in std_logic;
    F: out std_logic_vector(WORDSIZE-1 downto 0);
    ALU_FLAGS: out std_logic_vector(WORDSIZE-1 downto 0)
    );            		
end ALU; 

-- Architecture
architecture RTL of ALU is 

component my_adder is
  port (
    a,b,cin : in  std_logic;
    s, cout : out std_logic );
end component;

signal Op2: std_logic_vector(WORDSIZE-1 downto 0);
signal Carry_temp : std_logic_vector(WORDSIZE-1 DOWNTO 0);
signal F_temp: std_logic_vector(WORDSIZE-1 downto 0); 
signal Cin_temp : std_logic;
signal overflow_temp1 : std_logic;

begin

  Op2 <= B when S = "0000" --ADD
  else not B when S = "0001" --SUB
  else (others => '0');

  Cin_temp <= FLAGS_Cin when S = "1100"
  else FLAGS_Cin when S = "1101"
  else '1' when S = "0001"
  else Cin; 
  
  --generate the full adders
  Adders_output_0: my_adder port map(A(0), Op2(0), Cin_temp, F_temp(0), Carry_temp(0));
  adders: for i in 1 to WORDSIZE-1 generate
    Adder_output: my_adder port map(A(i), Op2(i), Carry_temp(i-1), F_temp(i), Carry_temp(i));
  end generate;

  --------------------------------FLAGS-----------------------------------------

  --carry flag
  ALU_FLAGS(0) <= Carry_temp(WORDSIZE-1) when S = "0000" --ADD
  else Carry_temp(WORDSIZE-1) when S = "0001" --SUB
  else B(0) when S = "0110" --LSR
  else B(0) when S = "0111" --ROR
  else B(0) when S = "1000" --ASR
  else B(WORDSIZE-1) when S = "1001" --LSL
  else B(WORDSIZE-1) when S = "1010" --ROL
  else Carry_temp(WORDSIZE-1) when S = "1100" --ADC
  else Carry_temp(WORDSIZE-1) when S = "1101" --SBC
  else '0';
  
  --zero flag
  ALU_FLAGS(1) <= nor_reduce(F_temp);

  --Negative (N) flag
  ALU_FLAGS(2) <= F_temp(WORDSIZE-1);

  --Overflow (V) flag
  -- S7 ~(A7 + B7) + ~(S7 + ~(A7 B7))
  overflow_temp1 <= F_temp(WORDSIZE-1) and not (A(WORDSIZE-1) or B(WORDSIZE-1));
  ALU_FLAGS(3) <= overflow_temp1 or not (F_temp(WORDSIZE-1) or not (A(WORDSIZE-1) and B(WORDSIZE-1)));

  ALU_FLAGS(WORDSIZE-1 downto 4) <= (others => '0');
  -----------------------------------------------------------------------

  F <= F_temp when S = "0000" --ADD
  else F_temp when S = "0001" --SUB
  else (A and B) when S = "0010" --AND
  else (A or B) when S = "0011" --OR
  else (A xor B) when S = "0100" --XOR
  else (not B) when S = "0101" --NOT
  else ('0' & B(WORDSIZE-1 downto 1)) when S = "0110" --LSR
  else (B(0) & B(WORDSIZE-1 downto 1)) when S = "0111" --ROR
  else (B(WORDSIZE-1) & B(WORDSIZE-1 downto 1)) when S = "1000" --ASR
  else (B(WORDSIZE-2 downto 0) & '0') when S = "1001" --LSL
  else (B(WORDSIZE-2 downto 0) & B(WORDSIZE-1)) when S = "1010" --ROL
  else (others => '0') when S = "1011" --CLR
  else F_temp when S = "1100" --ADC
  else F_temp when S = "1101" --SBC
  else (others => '0');
  
end architecture RTL;
