library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    generic ( 
        CLK_FREQ_HZ : integer := 50_000_000
    ); -- 50 MHz
    port(
        clk, res_n:     in std_logic;
        start_timer:    in std_logic;
        dec_duration:   in std_logic; -- Decrement duration
        res_duration:   in std_logic; -- Reset duration
        timer_expired:  out std_logic);
end entity timer;

architecture behav of timer is
    constant MAX_CYCLES : integer := (CLK_FREQ_HZ / 1000) * 500; --500 ms
    constant MIN_CYCLES : integer := (CLK_FREQ_HZ / 1000) * 250; --250 ms
    constant DEC_STEP   : integer := MAX_CYCLES / 10;
    
    signal is_running:  boolean;
    signal duration : integer range 0 to MAX_CYCLES := MAX_CYCLES;
    signal cycle_cnt: integer range 0 to MAX_CYCLES := 0;
begin
    delay: process(clk, res_n) is
    begin
        if res_n = '0' then --Async

            is_running <= false;
            timer_expired <= '0';
            cycle_cnt <= 0;
            duration <= MAX_CYCLES;

        elsif rising_edge(clk) then --Sync

            -- Logik zum Setzen des Expired Signals
            timer_expired <= '0';

            if start_timer = '1' then 
                is_running <= true;
            end if;

            if is_running then
                if cycle_cnt < duration then
                    cycle_cnt <= cycle_cnt + 1;
                else
                    cycle_cnt <= 0;
                    timer_expired <= '1';
                    is_running <= false;
                end if;
            end if;

            -- Logik zum Verkürzen der Duration
            if res_duration = '1' then
                duration <= MAX_CYCLES;
            elsif dec_duration = '1' then
                if duration > (MIN_CYCLES + DEC_STEP) then
                    duration  <= duration - DEC_STEP;
                else 
                    duration <= MIN_CYCLES;
                end if;
            end if;
        end if;
    end process delay;
end architecture behav;