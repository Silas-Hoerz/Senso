library ieee;
use ieee.std_logic_1164.all;
use work.senso_pkg.all; -- Für den seven_segment_t Typ

entity senso is
    port(
        clk, res_n : in std_logic;
        
        -- Eingänge (Taster, low-aktiv)
        key_in_n   : in std_logic_vector(3 downto 0);
        
        -- Ausgänge (LEDs)
        leds       : out std_logic_vector(3 downto 0);
        
        -- Ausgänge (7-Segment)
        score_low  : out seven_segment_t;
        score_high : out seven_segment_t
    );
end entity senso;

architecture struct of senso is

    -- --- KOMPONENTEN ---
    
    component input is
        port( 
            clk, res_n : in std_logic;
            key_in_n   : in std_logic_vector(3 downto 0);
            key_valid  : out std_logic;
            key_color  : out std_logic_vector(1 downto 0)
        );
    end component;

    component control is
        port(
            clk, res_n    : in std_logic;
            key_valid     : in std_logic;
            key_color     : in std_logic_vector(1 downto 0);
            timer_expired : in std_logic;
            step_eq_score : in std_logic;
            rnd_color     : in std_logic_vector(1 downto 0);
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
    end component;

    component output is
        port(
            led_on  : in std_logic;
            all_on  : in std_logic;
            color   : in std_logic_vector(1 downto 0);
            leds    : out std_logic_vector(3 downto 0)
        );
    end component;

    component timer is
        generic ( CLK_FREQ_HZ : integer := 50_000_000 );
        port(
            clk, res_n    : in std_logic;
            start_timer   : in std_logic;
            dec_duration  : in std_logic;
            res_duration  : in std_logic;
            timer_expired : out std_logic
        );
    end component;

    component counter is
        port(
            clk, res_n    : in std_logic;
            res_step      : in std_logic;
            inc_step      : in std_logic;
            res_score     : in std_logic;
            inc_score     : in std_logic;
            step_eq_score : out std_logic;
            score_low     : out seven_segment_t;
            score_high    : out seven_segment_t
        );
    end component;

    component random is
        port(
            clk, res_n  : in std_logic;
            next_rnd    : in std_logic;
            store_rnd   : in std_logic;
            restore_rnd : in std_logic;
            rnd         : out std_logic_vector(1 downto 0)
        );
    end component;

    -- --- INTERNE SIGNALE (Wires) ---
    
    -- Von Input
    signal key_valid_s : std_logic;
    signal key_color_s : std_logic_vector(1 downto 0);
    
    -- Von Timer
    signal timer_expired_s : std_logic;
    
    -- Von Counter
    signal step_eq_score_s : std_logic;
    
    -- Von Random
    signal rnd_color_s : std_logic_vector(1 downto 0);
    
    -- Von Control (Steuersignale)
    signal start_timer_s  : std_logic;
    signal dec_duration_s : std_logic;
    signal res_duration_s : std_logic;
    
    signal inc_step_s     : std_logic;
    signal res_step_s     : std_logic;
    signal inc_score_s    : std_logic;
    signal res_score_s    : std_logic;
    
    signal store_rnd_s    : std_logic;
    signal restore_rnd_s  : std_logic;
    signal next_rnd_s     : std_logic;
    
    signal led_on_s       : std_logic;
    signal all_on_s       : std_logic;
    signal led_color_s    : std_logic_vector(1 downto 0);

begin

    -- 1. Input Block
    u_input: input
        port map(
            clk       => clk,
            res_n     => res_n,
            key_in_n  => key_in_n,
            key_valid => key_valid_s,
            key_color => key_color_s
        );

    -- 2. Control Unit (Das Gehirn)
    u_control: control
        port map(
            clk           => clk,
            res_n         => res_n,
            -- Inputs
            key_valid     => key_valid_s,
            key_color     => key_color_s,
            timer_expired => timer_expired_s,
            step_eq_score => step_eq_score_s,
            rnd_color     => rnd_color_s,
            -- Outputs
            start_timer   => start_timer_s,
            dec_duration  => dec_duration_s,
            res_duration  => res_duration_s,
            inc_step      => inc_step_s,
            res_step      => res_step_s,
            inc_score     => inc_score_s,
            res_score     => res_score_s,
            store_rnd     => store_rnd_s,
            restore_rnd   => restore_rnd_s,
            next_rnd      => next_rnd_s,
            led_on        => led_on_s,
            all_on        => all_on_s,
            led_color     => led_color_s
        );

    -- 3. Output Block (LED Treiber)
    u_output: output
        port map(
            led_on => led_on_s,
            all_on => all_on_s,
            color  => led_color_s,
            leds   => leds
        );

    -- 4. Timer
    u_timer: timer
        generic map ( CLK_FREQ_HZ => 50_000_000 )
        port map(
            clk           => clk,
            res_n         => res_n,
            start_timer   => start_timer_s,
            dec_duration  => dec_duration_s,
            res_duration  => res_duration_s,
            timer_expired => timer_expired_s
        );

    -- 5. Zähler (Score & Steps)
    u_counter: counter
        port map(
            clk           => clk,
            res_n         => res_n,
            res_step      => res_step_s,
            inc_step      => inc_step_s,
            res_score     => res_score_s,
            inc_score     => inc_score_s,
            step_eq_score => step_eq_score_s,
            score_low     => score_low,   -- Geht direkt nach draußen
            score_high    => score_high
        );

    -- 6. Random (Zufallsgenerator)
    u_random: random
        port map(
            clk         => clk,
            res_n       => res_n,
            next_rnd    => next_rnd_s,
            store_rnd   => store_rnd_s,
            restore_rnd => restore_rnd_s,
            rnd         => rnd_color_s
        );

end architecture struct;