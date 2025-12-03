--
-- VHDL Architecture Senso_lib.button_tb.behav
--
-- Created:
--          by - st177504.st177504 (pc027)
--          at - 15:56:02 12/03/25
--
-- using Siemens HDL Designer(TM) 2025.2 Built on 26 May 2025 at 14:52:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
entity button_tb is
    -- Die Testbench exportiert die Signale für die Top-Level Simulation
    port(
        clk       : out std_logic;
        res_n     : out std_logic;
        tx_n      : out std_logic
    );
end entity button_tb;

architecture behav of button_tb is
    constant clk_period : time := 20 ns; -- 50 MHz
begin

    -- Taktgenerator
    clk_gen: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clk_gen;

    -- Stimuli Prozess
    stim_proc: process
    begin
        -- 1. Initialisierung
        res_n <= '0';
        tx_n  <= '1'; -- Taster NICHT gedrückt (High wegen Pull-Up / Low-Aktiv)
        wait for 100 ns;

        -- 2. Reset loslassen
        res_n <= '1';
        wait for 40 ns;

        -- 3. Tastendruck (Lang)
        -- Wir drücken den Taster (ziehen auf '0') und halten ihn gedrückt.
        -- Erwartung: 'key' soll genau EINEN Takt lang '1' werden, dann wieder '0'.
        report "Druecke Taster (lang)...";
        tx_n <= '0'; 
        wait for 200 ns; -- 10 Takte gedrückt halten
        
        -- Loslassen
        report "Lasse Taster los...";
        tx_n <= '1';
        wait for 100 ns;

        -- 4. Tastendruck (Kurz)
        -- Wir simulieren einen kürzeren Druck
        report "Druecke Taster (kurz)...";
        tx_n <= '0';
        wait for 60 ns; -- 3 Takte
        tx_n <= '1';
        
        wait for 100 ns;

        -- 5. "Prellen" simulieren (Schnelles Wackeln)
        -- Da du den DRS hast, sollte das stabilisiert werden, 
        -- aber der Impulsverkürzer feuert beim ersten stabilen '0'.
        report "Simuliere Prellen/Schnelles Drücken...";
        tx_n <= '0'; wait for 20 ns;
        tx_n <= '1'; wait for 20 ns;
        tx_n <= '0'; wait for 100 ns; -- Jetzt stabil gedrückt
        tx_n <= '1';

        wait; -- Ende
    end process stim_proc;

end architecture behav;

