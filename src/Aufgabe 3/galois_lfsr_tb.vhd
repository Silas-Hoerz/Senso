LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY galois_lfsr_tb IS
-- Testbench hat keine Ports
END ENTITY galois_lfsr_tb;

ARCHITECTURE struct OF galois_lfsr_tb IS

  -- 1. Komponenten Deklaration (Muss exakt mit deinen Entities übereinstimmen)
  COMPONENT galois_lfsr
    PORT (
      clk, res_n : IN std_logic;
      reset      : IN std_logic;
      fb         : IN std_logic_vector(7 DOWNTO 1);
      q          : OUT std_logic_vector(7 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT tester
    GENERIC (
      MAX_CYCL_LENGTH : integer := 255
    );
    PORT (
      clk, res_n : IN std_logic;
      reset      : OUT std_logic;
      fb         : OUT std_logic_vector(7 DOWNTO 1)
    );
  END COMPONENT;

  COMPONENT analyzer
    PORT (
      clk, res_n : IN std_logic;
      reset      : IN std_logic;
      q          : IN std_logic_vector(7 DOWNTO 0)
    );
  END COMPONENT;

  -- 2. Signale zum Verbinden der Komponenten (Wires)
  signal clk_s    : std_logic := '0';
  signal res_n_s  : std_logic := '0';
  
  signal reset_s  : std_logic;                    -- Verbindung tester -> lfsr/analyzer
  signal fb_s     : std_logic_vector(7 downto 1); -- Verbindung tester -> lfsr
  signal q_s      : std_logic_vector(7 downto 0); -- Verbindung lfsr -> analyzer

  -- Konstante für Taktperiode (50 MHz = 20 ns)
  constant CLK_PERIOD : time := 20 ns;

BEGIN

  -- 3. Takt- und Reset-Generierung (Ersetzt den Block 'clk_res_gen')
  -- Taktprozess
  clk_gen: process
  begin
    clk_s <= '0';
    wait for CLK_PERIOD / 2;
    clk_s <= '1';
    wait for CLK_PERIOD / 2;
  end process clk_gen;

  -- Reset-Prozess (einmalig am Anfang)
  res_gen: process
  begin
    res_n_s <= '0'; -- Reset aktiv (low)
    wait for 55 ns; 
    res_n_s <= '1'; -- Reset inaktiv
    wait;           -- Warten für immer
  end process res_gen;

  -- 4. Instanziierung und Verdrahtung (Port Maps)
  
  -- Der Tester (Erzeugt fb Muster und Sync-Reset Pulse)
  i_tester : tester
    GENERIC MAP (
      MAX_CYCL_LENGTH => 255 -- 2^8 - 1 = 255
    )
    PORT MAP (
      clk   => clk_s,
      res_n => res_n_s,
      reset => reset_s,
      fb    => fb_s
    );

  -- Das DUT (Device Under Test) - Dein LFSR
  i_galois_lfsr : galois_lfsr
    PORT MAP (
      clk   => clk_s,
      res_n => res_n_s,
      reset => reset_s,
      fb    => fb_s,
      q     => q_s
    );

  -- Der Analyzer (Prüft die Zykluslänge)
  i_analyzer : analyzer
    PORT MAP (
      clk   => clk_s,
      res_n => res_n_s,
      reset => reset_s,
      q     => q_s
    );

END ARCHITECTURE struct;