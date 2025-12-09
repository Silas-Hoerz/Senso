--
-- VHDL Architecture Senso_lib.galois_lfsr.behav
--
-- Created:
--          by - st177504.st177504 (pc027)
--          at - 16:16:58 12/03/25
--
-- using Siemens HDL Designer(TM) 2025.2 Built on 26 May 2025 at 14:52:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY galois_lfsr IS
  port(
    clk, res_n: in std_logic;
    reset     : in std_logic;
    fb        : in std_logic_vector(7 downto 1);
    q         : out std_logic_vector(7 downto 0)
  );
END ENTITY galois_lfsr;

--
ARCHITECTURE behav OF galois_lfsr IS
  signal q_int: std_logic_vector(7 downto 0);
BEGIN
  q <= q_int;
  process (clk, res_n) is
  begin
    if res_n = '0' then
      q_int <= (others => '0');
      
    elsif rising_edge(clk) then
      if reset = '1' then
        q_int <= (others => '1');
      else
        q_int(0) <= q_int(7);
        
        for i in 1 to 7 loop
          
          if fb(i) = '1' then
            q_int(i) <= q_int(7) xor q_int(i-1);
          else
            q_int(i) <= q_int(i-1);
          end if;
          
        end loop;
      end if; 
    end if;
      
  end process;
END ARCHITECTURE behav;
