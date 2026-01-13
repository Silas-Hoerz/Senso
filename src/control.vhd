library ieee;
use ieee.std_logic_1164.all;

entity control is
    port(
        clk, res_n    : in std_logic;
        
        -- Inputs von anderen Modulen
        key_valid     : in std_logic;
        key_color     : in std_logic_vector(1 downto 0);
        timer_expired : in std_logic;
        step_eq_score : in std_logic;
        rnd_color     : in std_logic_vector(1 downto 0); 

        -- Outputs zu anderen Modulen
        start_timer   : out std_logic;
        dec_duration  : out std_logic;
        res_duration  : out std_logic;
        
        inc_step      : out std_logic;
        res_step      : out std_logic;
        inc_score     : out std_logic;
        res_score     : out std_logic;
        
        store_rnd     : out std_logic;
        restore_rnd   : out std_logic;
        next_rnd      : out std_logic;
        
        led_on        : out std_logic;
        all_on        : out std_logic;
        led_color     : out std_logic_vector(1 downto 0)
    );
end entity control;

architecture behav of control is

    type state_t is (
        IDLE,           -- Wartet auf Spielstart
        PREP_NEW_GAME,  -- Initiiert neues Spiel
        PREP_SEQ,       -- Vorbereiten zum Abspielen
        SHOW_LED,       -- LED leuchtet (Computer)
        WAIT_SHOW,      -- Warten bis Leuchtdauer vorbei
        PAUSE_LED,      -- Kurze Pause zwischen LEDs
        WAIT_PAUSE,     -- Warten bis Pause vorbei
        NEXT_SEQ_STEP,  -- Nächster Schritt in der Sequenz
        PREP_USER,      -- Vorbereiten für Benutzereingabe
        WAIT_INPUT,     -- Warten auf Tastendruck
        CHECK_INPUT,    -- Eingabe prüfen
        -- NEUE ZUSTÄNDE FÜR FEEDBACK:
        FEEDBACK_ON,    -- LED der gedrückten Taste einschalten
        WAIT_FEEDBACK,  -- Warten (kurzes Aufleuchten)
        -- ENDE NEU
        INPUT_CORRECT,  -- Eingabe war korrekt -> Weiter
        LEVEL_UP,       -- Runde geschafft
        GAME_OVER       -- Falsche Eingabe
    );
    
    signal current_state, next_state : state_t;
    
    -- Neues Signal zum Speichern der gedrückten Farbe
    signal stored_key_color : std_logic_vector(1 downto 0);

begin

    -- 1. Zustandsspeicher & Datenspeicher
    state_reg: process(clk, res_n)
    begin
        if res_n = '0' then
            current_state <= IDLE;
            stored_key_color <= "00";
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            -- WICHTIG: Farbe sofort speichern, wenn Taste gültig ist.
            -- key_valid ist nur für 1 Takt high!
            if key_valid = '1' then
                stored_key_color <= key_color;
            end if;
        end if;
    end process;

    -- 2. Übergangslogik (Next State Logic)
    trans_logic: process(current_state, key_valid, timer_expired, step_eq_score, stored_key_color, rnd_color)
    begin
        -- Default: Bleibe im Zustand
        next_state <= current_state;

        case current_state is
            when IDLE =>
                if key_valid = '1' then
                    next_state <= PREP_NEW_GAME;
                end if;

            when PREP_NEW_GAME =>
                next_state <= PREP_SEQ;

            when PREP_SEQ =>
                next_state <= SHOW_LED;

            when SHOW_LED =>
                next_state <= WAIT_SHOW;

            when WAIT_SHOW =>
                if timer_expired = '1' then
                    next_state <= PAUSE_LED;
                end if;

            when PAUSE_LED =>
                next_state <= WAIT_PAUSE;

            when WAIT_PAUSE =>
                if timer_expired = '1' then
                    next_state <= NEXT_SEQ_STEP;
                end if;

            when NEXT_SEQ_STEP =>
                if step_eq_score = '1' then
                    next_state <= PREP_USER;
                else
                    next_state <= SHOW_LED;
                end if;

            when PREP_USER =>
                next_state <= WAIT_INPUT;

            when WAIT_INPUT =>
                if key_valid = '1' then
                    next_state <= CHECK_INPUT;
                end if;

            when CHECK_INPUT =>
                -- Vergleich mit gespeicherter Farbe
                if stored_key_color = rnd_color then
                    -- Erst Feedback anzeigen (LED leuchten lassen)
                    next_state <= FEEDBACK_ON;
                else
                    next_state <= GAME_OVER;
                end if;

            -- NEU: Feedback Ablauf
            when FEEDBACK_ON =>
                next_state <= WAIT_FEEDBACK;
                
            when WAIT_FEEDBACK =>
                if timer_expired = '1' then
                    next_state <= INPUT_CORRECT;
                end if;
            -- ENDE NEU

            when INPUT_CORRECT =>
                if step_eq_score = '1' then
                    next_state <= LEVEL_UP;
                else
                    next_state <= WAIT_INPUT; -- Nächste Eingabe erwarten
                end if;

            when LEVEL_UP =>
                next_state <= PREP_SEQ;

            when GAME_OVER =>
                if key_valid = '1' then
                    next_state <= IDLE;
                end if;
                
            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- 3. Ausgangslogik (Output Logic)
    output_logic: process(current_state, rnd_color, stored_key_color)
    begin
        -- Default Zuweisungen (vermeidet Latches)
        start_timer   <= '0';
        dec_duration  <= '0';
        res_duration  <= '0';
        inc_step      <= '0';
        res_step      <= '0';
        inc_score     <= '0';
        res_score     <= '0';
        store_rnd     <= '0';
        restore_rnd   <= '0';
        next_rnd      <= '0';
        led_on        <= '0';
        all_on        <= '0';
        led_color     <= "00";

        case current_state is
            when IDLE =>
                res_score    <= '1';
                res_duration <= '1';
                next_rnd     <= '1';

            when PREP_NEW_GAME =>
                store_rnd    <= '1';
                res_score    <= '1';

            when PREP_SEQ =>
                restore_rnd  <= '1';
                res_step     <= '1';

            when SHOW_LED =>
                led_on       <= '1';
                led_color    <= rnd_color; -- Computer Farbe
                start_timer  <= '1';

            when WAIT_SHOW =>
                led_on       <= '1';
                led_color    <= rnd_color;

            when PAUSE_LED =>
                start_timer  <= '1';

            when NEXT_SEQ_STEP =>
                next_rnd     <= '1';
                inc_step     <= '1';

            when PREP_USER =>
                restore_rnd  <= '1';
                res_step     <= '1';

            -- NEU: Feedback Ausgänge
            when FEEDBACK_ON =>
                led_on       <= '1';
                led_color    <= stored_key_color; -- Spieler Farbe anzeigen
                start_timer  <= '1';              -- Timer starten
                
            when WAIT_FEEDBACK =>
                led_on       <= '1';
                led_color    <= stored_key_color;
            -- ENDE NEU

            when INPUT_CORRECT =>
                next_rnd     <= '1';
                inc_step     <= '1'; 

            when LEVEL_UP =>
                inc_score    <= '1';
                dec_duration <= '1';

            when GAME_OVER =>
                all_on       <= '1';

            when others =>
                null;
        end case;
    end process;

end architecture behav;