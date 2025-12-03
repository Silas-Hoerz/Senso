--
-- VHDL Architecture Senso_lib.timer_tb.behav
--
-- Created:
--          by - st177504.st177504 (pc027)
--          at - 16:47:33 11/19/25
--
-- using Siemens HDL Designer(TM) 2025.2 Built on 26 May 2025 at 14:52:30
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
entity timer_tb is
    port(
        clk, res_n:     out std_logic;
        start_timer:    out std_logic;
        dec_duration:   out std_logic;
        res_duration:   out std_logic);
end entity timer_tb;

architecture behav of timer_tb is
    constant clk_period: time := 20 ns;
begin

    -- Clock
    clk_gen: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process clk_gen;

    -- Signale
    sig_gen: process
    begin
        -- Initialisierung
        res_n <= '0';
        start_timer <= '0';
        dec_duration <= '0';
        res_duration <= '0';
        
        -- Reset halten und loslassen
        wait for 40 ns;
        res_n <= '1';
        wait for 40 ns;

        -- TEST 1: Standard-Durchlauf (Dauer = 10 Zyklen)
        report "Starte Timer mit voller Dauer (10 Zyklen)...";
        start_timer <= '1';
        wait for clk_period; -- 1 Takt Puls
        start_timer <= '0';
        
        -- Wir warten > 10 Zyklen (200ns). Sagen wir 300ns zur Sicherheit.
        wait for 300 ns; 

        -- TEST 2: Zeit verkürzen
        -- Wir ziehen 3 mal ab. 
        -- Start: 10. Nach 3x dec_duration sind wir bei 7 Zyklen.
        -- Da DEC_STEP = MAX/10 = 1 ist.
        report "Verkürze Zeit 3x ...";
        
        -- Puls 1
        dec_duration <= '1'; wait for clk_period; dec_duration <= '0';
        wait for clk_period;
        -- Puls 2
        dec_duration <= '1'; wait for clk_period; dec_duration <= '0';
        wait for clk_period;
        -- Puls 3
        dec_duration <= '1'; wait for clk_period; dec_duration <= '0';
        wait for clk_period;

        -- TEST 3: Verkürzter Durchlauf (Dauer sollt jetzt 7 Zyklen sein = 140ns)
        report "Starte Timer mit verkürzter Dauer (7 Zyklen)...";
        start_timer <= '1';
        wait for clk_period;
        start_timer <= '0';
        
        wait for 300 ns;

        -- TEST 4: Limit testen (Min Cycles = 5)
        -- Wir ziehen noch 5 mal ab. Wir sollten bei 5 hängenbleiben (Underflow-Schutz).
        report "Teste Minimum Limit...";
        for i in 1 to 5 loop
            dec_duration <= '1'; wait for clk_period; dec_duration <= '0';
            wait for clk_period;
        end loop;

        -- Starten und schauen: Sollte jetzt 5 Zyklen (100ns) laufen
        start_timer <= '1';
        wait for clk_period;
        start_timer <= '0';
        wait for 200 ns;

        -- TEST 5: Reset Duration
        report "Setze Dauer zurück...";
        res_duration <= '1'; wait for clk_period; res_duration <= '0';
        
        -- Sollte wieder 10 Zyklen laufen
        start_timer <= '1'; wait for clk_period; start_timer <= '0';
        wait for 300 ns;

        report "Simulation beendet.";
        wait; -- Simulation stoppen
        
    end process sig_gen;

end architecture behav;
