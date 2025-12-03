--
-- VHDL Architecture Senso_lib.tester.behav
--
-- Created:
--          by - st177504.st177504 (pc027)
--          at - 16:45:11 12/03/25
--
-- using Siemens HDL Designer(TM) 2025.2 Built on 26 May 2025 at 14:52:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
ENTITY tester IS
  generic ( 
    MAX_CYCL_LENGTH : integer := 255);
  port(
    clk, res_n: in std_logic;
    reset     : out std_logic;
    fb        : out std_logic_vector(7 downto 1));
END ENTITY tester;

--
ARCHITECTURE behav OF tester IS
BEGIN
  process (clk, res_n) is
    variable fb_cnt   : integer := 0;
    variable wait_cnt : integer := 0;
  begin
    if res_n = '1' then
      reset <= '1';
      fb <= (others => '0');
    elsif rising_edge(clk) then
      if fb_cnt <= MAX_CYCL_LENGTH then
        fb <= std_logic_vector(unsigned(fb_cnt));
      end if;
      
      if wait_cnt <= MAX_CYCL_LENGTH then
        wait_cnt := wait_cnt + 1;
      else
        wait_cnt := 0;
        fb_cnt   := fb_cnt + 1;
      end if;
    end if;
  end process;
    
END ARCHITECTURE behav;

