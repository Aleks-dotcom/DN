library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_Tx_cu is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        txclk_i : in STD_LOGIC;
        txstart_i : in STD_LOGIC;
        txbusy_o : out STD_LOGIC;
        txactive_o : out STD_LOGIC;
        piso_ce_o : out STD_LOGIC
    );
end uart_Tx_cu;

architecture Behavioral of uart_Tx_cu is
    --Use descriptive names for the states , like st1_reset , st2_search
    type state_type is ( st0_IDLE , st1_START ,
                        st2_BIT0 , st3_BIT1 , st4_BIT2 ,
                        st5_BIT3 , st6_BIT4 , st7_BIT5 ,
                        st8_BIT6 , st9_BIT7 ,
                        st10_STOP , st11_WAIT );
    signal state , next_state : state_type;
    -- Declare internal signals for all outputs of the state machine
    signal txbusy : std_logic;
    signal txactive : std_logic;
    signal piso_ce : std_logic;
    
begin

    SYNC_PROC: process ( clk_i )
    begin
        if (clk_i ' event and clk_i = '1') then
            if ( rst_i = '1') then
                state <= st0_IDLE;
            else
                state <= next_state;
                txbusy_o <= txbusy ;
                txactive_o <= txactive;
                piso_ce_o <= piso_ce;
            end if;
        end if;
    end process;
                
    --MEALY State Machine - Outputs based on state and inputs
    OUTPUT_DECODE: process ( state , txclk_i , txstart_i)
    begin
        -- defaults :
        txbusy <= '0';
        txactive <= '0';
        piso_ce <= '0';
        --decode internal output signals
        case ( state ) is
            when st0_IDLE =>
                piso_ce <= '0';
                txactive <= '0';
                if txstart_i = '1' then
                    txbusy <= '1';
                end if;
            when st1_START =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st2_BIT0 =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st3_BIT1 =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st4_BIT2 =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st5_BIT3 =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st6_BIT4 =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st7_BIT5 =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st8_BIT6 =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st9_BIT7 =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st10_STOP =>
                txbusy <= '1';
                txactive <= '1';
                if txclk_i = '1' then
                    piso_ce <= '1';
                end if;
            when st11_WAIT =>
                txbusy <= '0';
                txactive <= '0';
                piso_ce <= '0';
            when others =>
                txbusy <= '0';
                txactive <= '0';
                piso_ce <= '0';
        end case;
    end process;
    
    NEXT_STATE_DECODE: process (state , txclk_i , txstart_i)
    begin
        -- declare default state for next_state to avoid latches
        next_state <= state; --default is to stay in current state
        --decode next_state:
        -- change state only if txclk pulse is present:
        case ( state ) is
            when st0_IDLE =>
                if txclk_i = '1' and txstart_i = '1' then
                    next_state <= st1_START;
                end if;
            when st1_START =>
                if txclk_i = '1' then
                    next_state <= st2_BIT0;
                end if;
            when st2_BIT0 =>
                if txclk_i = '1' then
                    next_state <= st3_BIT1;
                end if;
            when st3_BIT1 =>
                if txclk_i = '1' then
                    next_state <= st4_BIT2;
                end if;
            when st4_BIT2 =>
                if txclk_i = '1' then
                    next_state <= st5_BIT3;
                end if;
            when st5_BIT3 =>
                if txclk_i = '1' then
                    next_state <= st6_BIT4;
                end if;
            when st6_BIT4 =>
                if txclk_i = '1' then
                    next_state <= st7_BIT5;
                end if;
            when st7_BIT5 =>
                if txclk_i = '1' then
                    next_state <= st8_BIT6;
                end if;
            when st8_BIT6 =>
                if txclk_i = '1' then
                    next_state <= st9_BIT7;
                end if;   
            when st9_BIT7 =>
                if txclk_i = '1' then
                    next_state <= st10_STOP;
                end if;
            when st10_STOP =>
                if txclk_i = '1' then
                    next_state <= st11_WAIT;
                end if;
            when st11_WAIT =>
                if txstart_i = '0' then
                    next_state <= st0_IDLE;
                end if;
            when others =>
                if txclk_i = '1' then
                    next_state <= st0_IDLE;
                end if;
        end case;
    end process;
end Behavioral;