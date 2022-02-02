library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_TxClk is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        clk16_i : in STD_LOGIC;
        TxClk_o : out STD_LOGIC
    );
end uart_TxClk;

architecture Behavioral of uart_TxClk is
    signal count : STD_LOGIC_VECTOR(3 downto 0);
    signal txclk : STD_LOGIC ;
begin
    -- stevec , ki steje 16 period signala clk16_i
    -- in nato tvori pulz v trajanju ene periode clk
    P_TXCLK: process ( clk_i)
    begin
        if (clk_i ' event and clk_i = '1') then
            txclk <= '0'; -- default is 0
            if rst_i = '1' then
                txclk <= '0';
                count <= ( others => '0');
            elsif clk16_i = '1' then
                count <= count + 1;
                if count = X"F" then
                    count <= ( others => '0');
                    txclk <= '1'; -- pulz v trajanju enega cikla
                end if;
            end if;
        end if;
    end process;
    TxClk_o <= txclk;
end Behavioral;