library ieee;
use ieee.std_logic_1164.all;

entity button_top is
end entity button_top;

architecture struct of button_top is

    -- Komponente: Dein Button Design
    component button is
        port( 
            clk, res_n : in std_logic;
            tx_n       : in std_logic;
            key        : out std_logic
        );
    end component button;

    -- Komponente: Die Testbench
    component button_tb is
        port(
            clk       : out std_logic;
            res_n     : out std_logic;
            tx_n      : out std_logic;
            key       : in  std_logic
        );
    end component button_tb;

    -- Verbindungssignale
    signal clk_sig   : std_logic;
    signal res_n_sig : std_logic;
    signal tx_n_sig  : std_logic;
    signal key_sig   : std_logic;

begin

    -- Instanz des Prüflings (Device Under Test)
    u_dut: button
        port map(
            clk   => clk_sig,
            res_n => res_n_sig,
            tx_n  => tx_n_sig,
            key   => key_sig
        );

    -- Instanz der Testbench
    u_tb: button_tb
        port map(
            clk   => clk_sig,
            res_n => res_n_sig,
            tx_n  => tx_n_sig,
            key   => key_sig
        );

end architecture struct;