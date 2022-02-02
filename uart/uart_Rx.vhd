library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_Rx is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        rxclk_i : in STD_LOGIC;
        RxD_i : in STD_LOGIC;
        rxrdy_o : out STD_LOGIC;
        rxclk_en_o : out STD_LOGIC;
        rx_data_o : out STD_LOGIC_VECTOR (7 downto 0)
    );
end uart_Rx;

architecture Behavioral of uart_Rx is
    COMPONENT uart_rx_cu
    PORT(
        clk_i : IN std_logic;
        rst_i : IN std_logic;
        rxclk_i : IN std_logic;
        RxD_i : IN std_logic;
        sipo_ce_o : OUT std_logic;
        rxclk_en_o : out STD_LOGIC;
        rxrdy_o : OUT std_logic
        );
    END COMPONENT;
    COMPONENT uart_sipo_reg
        PORT(
            clk_i : IN std_logic;
            rst_i : IN std_logic;
            ce_i : IN std_logic;
            data_i : IN std_logic;
            data_o : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    
    signal sipo_ce : std_logic;
    signal rxrdy : std_logic;
    signal rxclk_en : std_logic;
    signal data : std_logic_vector (7 downto 0);

begin
    -- IO assignments:
    rxrdy_o <= rxrdy ;
    rx_data_o <= data;
    rxclk_en_o <= rxclk_en;
    
    -- components instantiation:
    
    -- Receiver 's control unit:
    Inst_uart_rx_cu: uart_rx_cu PORT MAP(
            clk_i => clk_i ,
            rst_i => rst_i ,
            rxclk_i => rxclk_i ,
            RxD_i => RxD_i ,
            sipo_ce_o => sipo_ce ,
            rxclk_en_o => rxclk_en ,
            rxrdy_o => rxrdy
        );
    -- SIPO register:
    Inst_uart_sipo_reg: uart_sipo_reg PORT MAP(
            clk_i => clk_i ,
            rst_i => rst_i ,
            ce_i => sipo_ce ,
            data_i => RxD_i ,
            data_o => data
        );
end Behavioral;