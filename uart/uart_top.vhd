library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_top is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        RxD_i : in STD_LOGIC;
        txstart_i : in STD_LOGIC;
        txreg_we_i : in STD_LOGIC;
        baud_i : in STD_LOGIC_VECTOR (1 downto 0);
        txdata_i : in STD_LOGIC_VECTOR (7 downto 0);
        rxrdy_o : out STD_LOGIC;
        txbusy_o : out STD_LOGIC;
        TxD_o : out STD_LOGIC;
        rxdata_o : out STD_LOGIC_VECTOR (7 downto 0)
    );
end uart_top;

architecture Behavioral of uart_top is

    COMPONENT uart_baudgen
        PORT(
            clk_i : IN std_logic;
            rst_i : IN std_logic;
            rxclk_en_i : IN std_logic;
            baud_sel_i : IN std_logic_vector (1 downto 0);
            RxClk_o : OUT std_logic;
            TxClk_o : OUT std_logic
        );
    END COMPONENT;
    
    COMPONENT uart_Tx
        PORT(
            clk_i : IN std_logic;
            rst_i : IN std_logic;
            txclk_i : IN std_logic;
            txstart_i : IN std_logic;
            txreg_we_i : IN std_logic;
            tx_data_i : IN std_logic_vector (7 downto 0);
            txbusy_o : OUT std_logic;
            TxD_o : OUT std_logic
        );
    END COMPONENT;
    
    COMPONENT uart_Rx
        PORT(
            clk_i : IN std_logic;
            rst_i : IN std_logic;
            rxclk_i : IN std_logic;
            RxD_i : IN std_logic;
            rxrdy_o : OUT std_logic;
            rxclk_en_o : OUT std_logic;
            rx_data_o : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    
    signal rxclk_en : std_logic;
    signal rxclk : std_logic;
    signal txclk : std_logic;
    signal txbusy : std_logic;
    signal txd : std_logic;
    signal rxd : std_logic;
    signal rxrdy : std_logic;
    signal rx_data : std_logic_vector (7 downto 0);
    
begin
    -- IO assignments:
    txbusy_o <= txbusy ;
    TxD_o <= txd;
    rxrdy_o <= rxrdy ;
    rxdata_o <= rx_data;
    
    -- D cell for RxD synhronization:
    FFD : process ( clk_i)
    begin
        if (clk_i ' event and clk_i = '1') then
            if rst_i = '1' then
                rxd <= '1';
            else
                rxd <= RxD_i;
            end if;
        end if;
    end process;
    
    -- components instantiation:
    
    -- Baud Generator :
    Inst_uart_baudgen: uart_baudgen PORT MAP(
            clk_i => clk_i ,
            rst_i => rst_i ,
            rxclk_en_i => rxclk_en ,
            baud_sel_i => "11" ,
            RxClk_o => rxclk ,
            TxClk_o => txclk
        );
        
    -- Transmitter :
    Inst_uart_Tx: uart_Tx PORT MAP(
            clk_i => clk_i ,
            rst_i => rst_i ,
            txclk_i => txclk ,
            txstart_i => txstart_i ,
            txreg_we_i => txreg_we_i ,
            tx_data_i => txdata_i ,
            txbusy_o => txbusy ,
            TxD_o => txd
        );
        
    -- Reciever :
    Inst_uart_Rx: uart_Rx PORT MAP(
            clk_i => clk_i ,
            rst_i => rst_i ,
            rxclk_i => rxclk ,
            RxD_i => rxd ,
            rxrdy_o => rxrdy ,
            rxclk_en_o => rxclk_en ,
            rx_data_o => rx_data 
        );
end Behavioral;