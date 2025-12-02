library ieee;
use ieee.std_logic_1164.all;

entity top is
end entity top;

architecture behav of top is
    
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

    component timer_tb is
        port(
            clk, res_n    : out std_logic;
            start_timer   : out std_logic;
            dec_duration  : out std_logic;
            res_duration  : out std_logic
        );
    end component;

    signal clk, res_n    : std_logic;
    signal start_timer   : std_logic;    
    signal dec_duration  : std_logic;
    signal res_duration  : std_logic;
    signal timer_expired : std_logic;

begin

    u_dut: timer
        generic map (
            CLK_FREQ_HZ => 50_000_000
        )
        port map(
            clk           => clk,
            res_n         => res_n,
            start_timer   => start_timer,
            dec_duration  => dec_duration,
            res_duration  => res_duration,
            timer_expired => timer_expired
        );

    u_tb: timer_tb
        port map( 
            clk          => clk,
            res_n        => res_n,
            start_timer  => start_timer,
            dec_duration => dec_duration,
            res_duration => res_duration
        );

end architecture behav;