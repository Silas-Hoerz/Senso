library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity button is
    port( 
        clk, res_n: in std_logic;
        tx_n: in std_logic;
        key: out std_logic);
end entity button;

architecture behav of button is
    signal tx_1st, tx_sync: std_logic;

    type state_t is (IDLE, SET_KEY, HOLD);
    signal current_state, next_state: state_t;
begin
    drs: process(clk, res_n) is
    begin
        if res_n = '0' then
            tx_1st <= '0';
            tx_sync <= '0';
        else
            if clk'event and clk = '1' then
                tx_sync <= tx_1st;
                tx_1st <= not tx_n;
            end if;
        end if;
    end process drs;

    state: process(clk, res_n) is
    begin
        if res_n = '0' then
           current_state <= IDLE;
        else
            if clk'event and clk = '1' then
                current_state <= next_state;
            end if;            
        end if;
    end process state;

    output: process(current_state) is
    begin
        case current_state is
        when SET_KEY =>
            key <= '1';
        when others =>
            key <= '0';
        end case;
    end process output;

    state_transition: process (current_state,tx_sync)
    begin
        case current_state is
        when IDLE =>
            if tx_sync = '1' then
                next_state <= SET_KEY;
            else
                next_state <= IDLE;
            end if;
        when SET_KEY =>      
            if tx_sync = '1' then
                next_state <= HOLD;
            else
                next_state <= IDLE;
            end if;
        when HOLD =>
            if tx_sync = '1' then
                next_state <= HOLD;
            else
                next_state <= IDLE;
            end if;
        end case;
    end process state_transition; 

end architecture behav;