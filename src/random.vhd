library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity random is
    port(
        clk, res_n  : in std_logic;
        next_rnd    : in std_logic; -- Berechnet nächsten Wert
        store_rnd   : in std_logic; -- Speichert aktuellen Wert in MR (Merk-Register)
        restore_rnd : in std_logic; -- Lädt Wert aus MR zurück in SR (Shift-Register)
        rnd         : out std_logic_vector(1 downto 0) -- 2 Bit Zufallsfarbe
    );
end entity random;

architecture behav of random is
    -- Das Rückkopplungsmuster aus deiner "best FB.txt"
    -- Bit 7 ist MSB. fb(7 downto 1)
    constant FB_PATTERN : std_logic_vector(7 downto 1) := "0001110";

    signal sr : std_logic_vector(7 downto 0); -- Schieberegister (Current State)
    signal mr : std_logic_vector(7 downto 0); -- Merkregister (Saved Seed)
    
    -- Hilfssignal für die Berechnung des nächsten Zustands (kombinatorisch)
    signal sr_next : std_logic_vector(7 downto 0);

begin

    -- 1. Kombinatorik: Galois LFSR Logik (Next State Logic)
    -- Berechnet, wie das Register im nächsten Takt aussehen würde
    process(sr)
    begin
        -- Bit 0 kommt vom MSB (Rotieren)
        sr_next(0) <= sr(7);
        
        -- Bits 1 bis 7 mit XOR Verknüpfung gemäß Feedback Pattern
        for i in 1 to 7 loop
            if FB_PATTERN(i) = '1' then
                sr_next(i) <= sr(7) xor sr(i-1);
            else
                sr_next(i) <= sr(i-1);
            end if;
        end loop;
    end process;

    -- 2. Sequentielle Logik: Register Steuerung (SR und MR)
    process(clk, res_n)
    begin
        if res_n = '0' then
            -- Reset: WICHTIG! Darf nicht 0 sein, sonst bleibt LFSR stehen.
            sr <= "11111111"; 
            mr <= "11111111";
            
        elsif rising_edge(clk) then
            
            -- Priorität 1: Restore (Seed laden)
            if restore_rnd = '1' then
                sr <= mr;
            
            -- Priorität 2: Next (Nächste Zahl berechnen) 
            elsif next_rnd = '1' then
                sr <= sr_next;
            
            -- Sonst: Wert halten (implizit)
            end if;

            -- Unabhängig davon: Store (Seed speichern)
            if store_rnd = '1' then
                mr <= sr;
            end if;
            
        end if;
    end process;

    -- 3. Output: Wir nehmen die untersten 2 Bits 
    rnd <= sr(1 downto 0);

end architecture behav;