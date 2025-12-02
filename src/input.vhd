library ieee;
use ieee.std_logic_1164.all;


entity input is
    port( clk, res_n: in std_logic;
        key_in_n: in std_logic_vector(3 downto 0);
        key_valid: out std_logic;
        key_color: out std_logic_vector(1 downto 0));
end entity input;

architecture behav of input is
    -- button
    component button is
        port( 
            clk, res_n : in std_logic;
            tx_n       : in std_logic;
            key        : out std_logic
        );
    end component button;

    signal keys : std_logic_vector(3 downto 0);
begin

    -- Instanz der Buttons:
    u_btn_red: button
        port map(
            clk => clk,
            res_n => res_n,
            tx_n => key_in_n(0),
            key => keys(0)
        );
    u_btn_blue: button
        port map(
            clk => clk,
            res_n => res_n,
            tx_n => key_in_n(1),
            key => keys(1)
        );
    u_btn_yellow: button
        port map(
            clk => clk,
            res_n => res_n,
            tx_n => key_in_n(2),
            key => keys(2)
        );
    u_btn_green: button
        port map(
            clk => clk,
            res_n => res_n,
            tx_n => key_in_n(3),
            key => keys(3)
        );

    -- Rein kombinatorisch? JA!
    
    check_valid: process (keys) is
    begin
        if keys = "0000" then -- keys sollten sowie so nur einen Takt '1' sein.
            key_valid <= '0';
        else
            key_valid <= '1';
        end if;
    end process check_valid;

    process (keys) is
    begin  
        key_color <= "00";
        if keys(0) = '1' then
            key_color <= "00";
        elsif keys(1) = '1' then
            key_color <= "01";
        elsif keys(2) = '1' then
            key_color <= "10";
        elsif keys(3) = '1' then
            key_color <= "11";
        end if;
    end process;
end architecture behav;
