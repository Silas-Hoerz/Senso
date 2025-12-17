library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    port(
        clk, res_n    : in std_logic;
        res_step      : in std_logic;
        inc_step      : in std_logic;
        res_score     : in std_logic;
        inc_score     : in std_logic;
        step_eq_score : out std_logic;
        score_low     : out std_logic_vector(6 downto 0);
        score_high    : out std_logic_vector(6 downto 0)
    );
end entity counter;

architecture behav of counter is
    -- Interne Signale als Integer für einfaches Rechnen
    signal step_cnt  : integer range 0 to 63;
    signal score_cnt : integer range 0 to 99;

    -- Hilfsfunktion für 7-Segment-Dekodierung (Low-Aktiv)
    -- Mapping: g f e d c b a
    function int2seven(val : integer) return std_logic_vector is
    begin
        case val is
            when 0 => return "1000000"; -- 0
            when 1 => return "1111001"; -- 1
            when 2 => return "0100100"; -- 2
            when 3 => return "0110000"; -- 3
            when 4 => return "0011001"; -- 4
            when 5 => return "0010010"; -- 5
            when 6 => return "0000010"; -- 6
            when 7 => return "1111000"; -- 7
            when 8 => return "0000000"; -- 8
            when 9 => return "0010000"; -- 9
            when others => return "1111111"; -- Off
        end case;
    end function;

begin

    -- Prozess für Step-Zähler
    process(clk, res_n)
    begin
        if res_n = '0' then
            step_cnt <= 0;
        elsif rising_edge(clk) then
            if res_step = '1' then
                step_cnt <= 0;
            elsif inc_step = '1' then
                step_cnt <= step_cnt + 1;
            end if;
        end if;
    end process;

    -- Prozess für Score-Zähler
    process(clk, res_n)
    begin
        if res_n = '0' then
            score_cnt <= 0;
        elsif rising_edge(clk) then
            if res_score = '1' then
                score_cnt <= 0;
            elsif inc_score = '1' then
                if score_cnt < 99 then
                    score_cnt <= score_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- Vergleicher
    step_eq_score <= '1' when (step_cnt = score_cnt) else '0';

    -- Ausgabe auf 7-Segment (Konvertierung Integer -> BCD -> 7Seg)
    -- Einer-Stelle: score_cnt mod 10
    -- Zehner-Stelle: score_cnt / 10
    score_low  <= int2seven(score_cnt mod 10);
    score_high <= int2seven(score_cnt / 10);

end architecture behav;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.senso_pkg.all; -- Zugriff auf unseren neuen Typ

entity counter is
    port(
        clk, res_n    : in std_logic;
        res_step      : in std_logic;
        inc_step      : in std_logic;
        res_score     : in std_logic;
        inc_score     : in std_logic;
        step_eq_score : out std_logic;
        -[span_3](start_span)- Hier nutzen wir jetzt den schönen Typ statt std_logic_vector[span_3](end_span)
        score_low     : out seven_segment_t;
        score_high    : out seven_segment_t
    );
end entity counter;

architecture behav of counter is
    signal step_cnt  : integer range 0 to 63;
    signal score_cnt : integer range 0 to 99;

    -- Hilfsfunktion zur Umwandlung von Integer (0-9) in unseren Record-Typ
    function get_segments(digit : integer) return seven_segment_t is
        variable res : seven_segment_t;
    begin
        -[span_4](start_span)- Low-Aktiv: '0' bedeutet Segment leuchtet[span_4](end_span)
        -[span_5](start_span)- Mapping gemäß Abbildung auf Seite 13[span_5](end_span)
        case digit is
            --      a    b    c    d    e    f    g
            when 0 => res := (a=>'0', b=>'0', c=>'0', d=>'0', e=>'0', f=>'0', g=>'1');
            when 1 => res := (a=>'1', b=>'0', c=>'0', d=>'1', e=>'1', f=>'1', g=>'1');
            when 2 => res := (a=>'0', b=>'0', c=>'1', d=>'0', e=>'0', f=>'1', g=>'0');
            when 3 => res := (a=>'0', b=>'0', c=>'0', d=>'0', e=>'1', f=>'1', g=>'0');
            when 4 => res := (a=>'1', b=>'0', c=>'0', d=>'1', e=>'1', f=>'0', g=>'0');
            when 5 => res := (a=>'0', b=>'1', c=>'0', d=>'0', e=>'1', f=>'0', g=>'0');
            when 6 => res := (a=>'0', b=>'1', c=>'0', d=>'0', e=>'0', f=>'0', g=>'0');
            when 7 => res := (a=>'0', b=>'0', c=>'0', d=>'1', e=>'1', f=>'1', g=>'1');
            when 8 => res := (a=>'0', b=>'0', c=>'0', d=>'0', e=>'0', f=>'0', g=>'0');
            when 9 => res := (a=>'0', b=>'0', c=>'0', d=>'0', e=>'1', f=>'0', g=>'0');
            when others => res := SEVEN_SEG_OFF;
        end case;
        return res;
    end function;

begin

    -- Zählerlogik für 'step' (Sequenzposition)
    process(clk, res_n)
    begin
        if res_n = '0' then
            step_cnt <= 0;
        elsif rising_edge(clk) then
            if res_step = '1' then
                step_cnt <= 0;
            elsif inc_step = '1' then
                step_cnt <= step_cnt + 1;
            end if;
        end if;
    end process;

    -- Zählerlogik für 'score' (Punktestand)
    process(clk, res_n)
    begin
        if res_n = '0' then
            score_cnt <= 0;
        elsif rising_edge(clk) then
            if res_score = '1' then
                score_cnt <= 0;
            elsif inc_score = '1' then
                if score_cnt < 99 then
                    score_cnt <= score_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -[span_6](start_span)- Komparator: Prüft, ob wir das Ende der Sequenz erreicht haben[span_6](end_span)
    step_eq_score <= '1' when (step_cnt = score_cnt) else '0';

    -- Ausgabe: Integer -> Record
    score_low  <= get_segments(score_cnt mod 10);
    score_high <= get_segments(score_cnt / 10);

end architecture behav;


    library ieee;
use ieee.std_logic_1164.all;

package senso_pkg is
    -- Definition eines Records für die 7-Segment-Anzeige
    -[span_1](start_span)- Dies entspricht der Anforderung nach einer "besseren Schnittstelle"[span_1](end_span)
    type seven_segment_t is record
        a, b, c, d, e, f, g : std_logic;
    end record;

    -- Optional: Ein "Alles Aus"-Zustand als Konstante (High = Aus, da Low-Aktiv)
    constant SEVEN_SEG_OFF : seven_segment_t := 
        (a => '1', b => '1', c => '1', d => '1', e => '1', f => '1', g => '1');
end package senso_pkg;
        
