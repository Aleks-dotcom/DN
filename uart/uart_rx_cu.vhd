library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_rx_cu is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        rxclk_i : in STD_LOGIC;
        RxD_i : in STD_LOGIC;
        sipo_ce_o : out STD_LOGIC;
        rxclk_en_o : out STD_LOGIC; -- omogoci rxclk
        rxrdy_o : out STD_LOGIC
    );
end uart_rx_cu;

architecture Behavioral of uart_rx_cu is
    signal count : STD_LOGIC_VECTOR (0 downto 0);
    signal clk2 : STD_LOGIC ;
    
    --Use descriptive names for the states :
    type state_type is ( st_IDLE , st_START ,
    st_BIT0 , st_BIT1 , st_BIT2 , st_BIT3 ,
    st_BIT4 , st_BIT5 , st_BIT6 , st_BIT7 ,
    st_STOP);
    signal state , next_state : state_type;
    
    -- Declare internal signals for all outputs of the state machine:
    signal sipo_ce : std_logic;
    signal clk2_en : STD_LOGIC;
    signal rxrdy : std_logic;
    signal rxclk_en : std_logic; -- rxclk bo omogocen ob
                                -- start bitu ( negativni fronti )
                                -- na ta nacin se sprejemnik
                                -- vedno znova signal       
    
    begin
    
        -- stevec , ki steje 2 periodi signala rxclk_i
        -- in nato tvori pulz v trajanju ene periode clk
        P_CLK2 : process ( clk_i)
        begin
            if (clk_i ' event and clk_i = '1') then
                clk2 <= '0'; -- default is 0
                if rst_i = '1' then
                    clk2 <= '0';
                    count <= ( others => '0');
                elsif ( clk2_en = '1') then
                    if ( rxclk_i = '1') then
                        count <= count + 1;
                        if count = "1" then
                            count <= ( others => '0');
                            clk2 <= '1'; -- pulz v trajanju enega clk2 
                        end if;
                    end if;
                else
                    count <= ( others => '0'); -- ce ni enable , pobrisi stevec
                end if;
            end if;
        end process;
        
        -- ----------------------------------------------------
        -- KONCNI AVTOMAT:
        -- ----------------------------------------------------
        SYNC_PROC: process ( clk_i )
        begin
            if (clk_i ' event and clk_i = '1') then
                if ( rst_i = '1') then
                    state <= st_IDLE;
                    sipo_ce_o <= '0';
                    rxrdy_o <= '0';
                    rxclk_en_o <= '0';
                else
                    state <= next_state;
                    sipo_ce_o <= sipo_ce;
                    rxrdy_o <= rxrdy ;
                    rxclk_en_o <= rxclk_en;
                end if;
            end if;
        end process;
        
        --MEALY State Machine - Outputs based on state and inputs
        OUTPUT_DECODE: process (state , rxclk_i , clk2 , RxD_i )
        begin
            --defaults :
            sipo_ce <= '0';
            rxrdy <= '0';
            rxclk_en <= '0';
            clk2_en <= '0';
            --decode internal output signals:
            case (state) is
                when st_IDLE =>
                    sipo_ce <= '0';
                    rxrdy <= '0';
                    rxclk_en <= '0';
                    clk2_en <= '0';
                when st_START =>
                    sipo_ce <= '0';
                    rxrdy <= '0';
                    rxclk_en <= '1';
                when st_BIT0 =>
                    rxclk_en <= '1';
                    clk2_en <= '1';
                    if clk2 = '1' then -- sredina bita 0
                        sipo_ce <= '1'; -- berem bit 0
                    end if;
                when st_BIT1 =>
                    rxclk_en <= '1';
                    clk2_en <= '1';
                    if clk2 = '1' then -- sredina bita 1
                        sipo_ce <= '1'; -- berem bit 1
                    end if;
                when st_BIT2 =>
                    rxclk_en <= '1';
                    clk2_en <= '1';
                    if clk2 = '1' then -- sredina bita 2
                        sipo_ce <= '1'; -- berem bit 2
                    end if;
                when st_BIT3 =>
                    rxclk_en <= '1';
                    clk2_en <= '1';
                    if clk2 = '1' then -- sredina bita 3
                        sipo_ce <= '1'; -- berem bit 3
                    end if;
                when st_BIT4 =>
                    rxclk_en <= '1';
                    clk2_en <= '1';
                    if clk2 = '1' then -- sredina bita 4
                        sipo_ce <= '1'; -- berem bit 4
                    end if;
                when st_BIT5 =>
                    rxclk_en <= '1';
                    clk2_en <= '1';
                    if clk2 = '1' then -- sredina bita 5
                        sipo_ce <= '1'; -- berem bit 5
                    end if;
                when st_BIT6 =>
                    rxclk_en <= '1';
                    clk2_en <= '1';
                    if clk2 = '1' then -- sredina bita 6
                        sipo_ce <= '1'; -- berem bit 6
                    end if;
                when st_BIT7 =>
                    rxclk_en <= '1';
                    clk2_en <= '1';
                    if clk2 = '1' then -- sredina bita 7
                        sipo_ce <= '1'; -- berem bit 7
                    end if;
                when st_STOP =>
                    rxclk_en <= '1';
                    sipo_ce <= '0';
                    clk2_en <= '1';
                    if RxD_i = '1' and clk2 = '1' then -- received STOP bit
                        rxrdy <= '1';
                    end if;
                when others =>
                    rxclk_en <= '0';
                    sipo_ce <= '0';
                    rxrdy <= '0';
            end case;
        end process;
    NEXT_STATE_DECODE: process ( state , rxclk_i , clk2 , RxD_i )
    begin
        --declare default state for next_state to avoid latches
        next_state <= state ; --default is to stay in current state
        --decode next_state:
        -- change state only if pulse is present:
        case ( state ) is
            when st_IDLE =>
                if RxD_i = '0' then -- received falling edge on RxD
                    next_state <= st_START;
                end if;
            when st_START =>
                if rxclk_i = '1' then
                    -- treba je tudi preveriti ali je linija
                    -- se vedno v nizkem stanju ( ali je START bit)
                    if RxD_i = '0' then
                        next_state <= st_BIT0;
                    else -- ni START bita
                        next_state <= st_IDLE;
                    end if;
                end if;
            when st_BIT0 =>
                if clk2 = '1' then
                    next_state <= st_BIT1;
                end if;
            when st_BIT1 =>
                if clk2 = '1' then
                    next_state <= st_BIT2;
                end if;
            when st_BIT2 =>
                if clk2 = '1' then
                    next_state <= st_BIT3;
                end if;
            when st_BIT3 =>
                if clk2 = '1' then
                    next_state <= st_BIT4;
                end if;
            when st_BIT4 =>
                if clk2 = '1' then
                    next_state <= st_BIT5;
                end if;
            when st_BIT5 =>
                if clk2 = '1' then
                    next_state <= st_BIT6;
                end if;
            when st_BIT6 =>
                if clk2 = '1' then
                    next_state <= st_BIT7;
                end if;
            when st_BIT7 =>
                if clk2= '1' then
                    next_state <= st_STOP;
                end if;
            when st_STOP =>
                if clk2 = '1' and RxD_i = '1' then
                    next_state <= st_IDLE;
                end if;
            when others =>
                next_state <= st_IDLE;
        end case;
    end process;
end Behavioral;