library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_RxClk is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        enable_i : in STD_LOGIC;
        clk16_i : in STD_LOGIC;
        RxClk_o : out STD_LOGIC
    );
end uart_RxClk;

architecture Behavioral of uart_RxClk is
    signal count : STD_LOGIC_VECTOR(2 downto 0);
    signal rxclk : STD_LOGIC ;
begin
    -- stevec , ki steje 8 period signala clk16_i
    -- in nato tvori pulz v trajanju ene periode clk
    P_TXCLK: process ( clk_i)
    begin
        if (clk_i ' event and clk_i = '1') then
            rxclk <= '0'; -- default is 0
            if rst_i = '1' then
                rxclk <= '0';
                count <= ( others => '0');
            elsif ( enable_i = '1') then
                if ( clk16_i = '1') then
                    count <= count + 1;
                    if count = "111" then
                        count <= ( others => '0');
                        rxclk <= '1'; -- pulz v trajanju enega cikla
                    end if;
                end if;
            else
                count <= ( others => '0'); -- ce ni enable , pobrisi stevec
            end if;
        end if;
    end process;
    RxClk_o <= rxclk;
end Behavioral;