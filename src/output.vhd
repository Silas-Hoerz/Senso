library ieee;
use ieee.std_logic_1164.all;

entity output is
    port(
        led_on  : in std_logic;
        all_on  : in std_logic;
        color   : in std_logic_vector(1 downto 0);
        leds    : out std_logic_vector(3 downto 0) -- Annahme: High-Aktiv für VHDL Logik
    );
end entity output;

architecture behav of output is
begin
    process(led_on, all_on, color)
    begin
        -- Standardmäßig alles aus
        leds <= "0000";

        if all_on = '1' then
            leds <= "1111";
        elsif led_on = '1' then
            case color is
                when "00" => leds <= "0001"; -- LED 0
                when "01" => leds <= "0010"; -- LED 1
                when "10" => leds <= "0100"; -- LED 2
                when "11" => leds <= "1000"; -- LED 3
                when others => leds <= "0000";
            end case;
        end if;
    end process;
end architecture behav;