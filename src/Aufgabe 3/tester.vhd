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

ARCHITECTURE behav OF tester IS
    -- SIGNALE gehören hier hin:
    signal fb_cnt   : unsigned(6 downto 0); 
BEGIN
  
  -- Zuweisung: fb_cnt (6 downto 0) auf fb (7 downto 1) mappen
  fb <= std_logic_vector(fb_cnt);

  process (clk, res_n) is
    -- VARIABLEN gehören HIER HIN (in den Prozess):
    variable wait_cnt : integer range 0 to MAX_CYCL_LENGTH + 5; 
  begin
    if res_n = '0' then
      reset <= '0';
      fb_cnt <= (others => '0');
      wait_cnt := 0;
    elsif rising_edge(clk) then
      
      -- Ablaufsteuerung
      if wait_cnt = 0 then
          reset <= '1';        -- Reset aktivieren
          wait_cnt := wait_cnt + 1;
          
      elsif wait_cnt = 1 then
          reset <= '0';        -- Reset deaktivieren
          wait_cnt := wait_cnt + 1;
          
      elsif wait_cnt <= MAX_CYCL_LENGTH then
          wait_cnt := wait_cnt + 1; -- Warten...
          
      else 
          -- Maximale Zeit abgelaufen, nächstes Muster testen
          wait_cnt := 0;
          fb_cnt <= fb_cnt + 1;
      end if;
      
    end if;
  end process;
END ARCHITECTURE behav;