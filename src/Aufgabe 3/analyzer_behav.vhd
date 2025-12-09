--
-- VHDL Architecture Senso_lib.analyzer.behav
--
-- Created:
--          by - st177504.st177504 (pc027)
--          at - 16:40:29 12/03/25
--
-- using Siemens HDL Designer(TM) 2025.2 Built on 26 May 2025 at 14:52:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
ENTITY analyzer IS
  port(
    clk, res_n  : in std_logic;
    reset       : in std_logic;
    q           : in std_logic_vector(7 downto 0));
END ENTITY analyzer;

--
ARCHITECTURE behav OF analyzer IS
BEGIN
  process is
    variable cycle_length_counter: integer;
    variable start_value: std_logic_vector(7 downto 0);
  begin
    wait until res_n = '1';
    loop
      wait on clk until clk = '1' and reset = '1';
      cycle_length_counter := 1;
      wait on clk until clk = '1' and reset = '0';
      start_value := q;
      wait on clk until clk = '1';
      while q /= start_value loop
        cycle_length_counter := cycle_length_counter + 1;
        wait on clk until clk = '1';
      end loop;
      report "cycle length: " & integer'image(cycle_length_counter);
    end loop;
  end process;
END ARCHITECTURE behav;
