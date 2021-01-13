LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

ENTITY counter IS
generic(COUNTER_SIZE : integer := 8);
PORT(
  clk : IN std_logic;
  rst : in std_logic;
  cnt : OUT std_logic_vector(COUNTER_SIZE-1 downto 0)
);
END ENTITY counter;

architecture counter_1 of counter is
  signal t_cnt : std_logic_vector(COUNTER_SIZE-1 downto 0);
begin
  counting: process(clk, rst)
  begin
    if rst = '1' then
      t_cnt <= std_logic_vector(to_unsigned(10, COUNTER_SIZE));
    elsif rising_edge(clk) then
      if (t_cnt = 0) then  
        t_cnt <= (others => '1');
      else
        t_cnt <= t_cnt - 1; 
      end if;  
    end if;
  end process;

  cnt <= t_cnt;
end counter_1;

