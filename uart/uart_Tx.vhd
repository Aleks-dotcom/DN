library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_Tx is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        txclk_i : in STD_LOGIC;
        txstart_i : in STD_LOGIC;
        txreg_we_i : in STD_LOGIC;
        tx_data_i : in STD_LOGIC_VECTOR (7 downto 0);
        txbusy_o : out STD_LOGIC;
        TxD_o : out STD_LOGIC
    );
end uart_Tx;

architecture Behavioral of uart_Tx is
    COMPONENT uart_Tx_cu
    PORT(
            clk_i : IN std_logic;
            rst_i : IN std_logic;
            txclk_i : IN std_logic;
            txstart_i : IN std_logic;
            txbusy_o : OUT std_logic;
            txactive_o : OUT STD_LOGIC;
            piso_ce_o : OUT std_logic
        );
    END COMPONENT;

    COMPONENT uart_piso_reg
        PORT(
            clk_i : IN std_logic;
            rst_i : IN std_logic;
            we_i : IN std_logic;
            ce_i : IN std_logic;
            data_i : IN std_logic_vector (7 downto 0);
            data_o : OUT std_logic
        );
    END COMPONENT;
    
    signal piso_ce : STD_LOGIC;
    signal txbusy : STD_LOGIC;
    signal txactive : STD_LOGIC;
    signal txregout : STD_LOGIC;
    signal TxD : STD_LOGIC;
    
begin
    -- IO assignments :
    txbusy_o <= txbusy ;
    TxD_o <= TxD;
    
    -- MUX ( keeps TxD line high if no transmition):
    TxD <= txregout WHEN txactive ='1' ELSE '1';
    
    -- components instantiation :
    -- Tx Control Unit :
    Inst_uart_Tx_cu: uart_Tx_cu PORT MAP(
        clk_i => clk_i ,
        rst_i => rst_i ,
        txclk_i => txclk_i ,
        txstart_i => txstart_i ,
        txbusy_o => txbusy ,
        txactive_o => txactive ,
        piso_ce_o => piso_ce
        );
        
    -- Tx PISO register :
    Inst_uart_piso_reg: uart_piso_reg PORT MAP(
        clk_i => clk_i ,
        rst_i => rst_i ,
        we_i => txreg_we_i ,
        ce_i => piso_ce ,
        data_i => tx_data_i ,
        data_o => txregout
        );
        
end Behavioral;