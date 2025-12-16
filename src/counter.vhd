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