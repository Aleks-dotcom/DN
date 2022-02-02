library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_baudgen is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        rxclk_en_i : in STD_LOGIC;
        baud_sel_i : in STD_LOGIC_VECTOR (1 downto 0);
        RxClk_o : out STD_LOGIC;
        TxClk_o : out STD_LOGIC
    );
end uart_baudgen;

architecture Behavioral of uart_baudgen is

COMPONENT uart_clk16
    PORT(
        clk_i : IN std_logic;
        rst_i : IN std_logic;
        baud_sel_i : IN std_logic_vector (1 downto 0);
        clk16_o : OUT std_logic
    );
END COMPONENT;

COMPONENT uart_RxClk
    PORT(
        clk_i : IN std_logic;
        rst_i : IN std_logic;
        enable_i : IN std_logic;
        clk16_i : IN std_logic;
        RxClk_o : OUT std_logic
    );
END COMPONENT;

COMPONENT uart_TxClk
    PORT(
        clk_i : IN std_logic;
        rst_i : IN std_logic;
        clk16_i : IN std_logic;
        TxClk_o : OUT std_logic
    );
END COMPONENT;

    signal clk16 : STD_LOGIC;
    signal TxClk : STD_LOGIC;
    signal RxClk : STD_LOGIC;
    
begin
    -- IO assignments :
    RxClk_o <= RxClk;
    TxClk_o <= TxClk;
    -- Components instantiation:
    -- CLK16:
    Inst_uart_clk16: uart_clk16 PORT MAP(
        clk_i => clk_i ,
        rst_i => rst_i ,
        baud_sel_i => baud_sel_i ,
        clk16_o => clk16
    );
    -- RXCLK:
    Inst_uart_RxClk: uart_RxClk PORT MAP(
        clk_i => clk_i ,
        rst_i => rst_i ,
        enable_i => rxclk_en_i ,
        clk16_i => clk16 ,
        RxClk_o => RxClk
    );
    -- TXCLK:
    Inst_uart_TxClk: uart_TxClk PORT MAP(
        clk_i => clk_i ,
        rst_i => rst_i ,
        clk16_i => clk16 ,
        TxClk_o => TxClk
    );
end Behavioral;