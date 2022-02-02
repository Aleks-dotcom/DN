library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_clk16 is
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        baud_sel_i : in STD_LOGIC_VECTOR (1 downto 0);
        clk16_o : out STD_LOGIC
    );
end uart_clk16;

architecture Behavioral of uart_clk16 is
    signal delilnik : integer;
    signal count : integer;
    signal clk16 : STD_LOGIC;
begin
    -- IO assignment :
    clk16_o <= clk16;
    
    -- izbira delilnega razmerja za 50 MHz uro
    -- izbira se izvede z vhodom baud_sel_i
    P_DEL : process ( baud_sel_i)
    begin
        case ( baud_sel_i) is
            when "00" =>
                delilnik <= 27; -- 115200
            when "01" =>
                delilnik <= 163; -- 19200
            when "10" =>
                delilnik <= 325; -- 9600
            when "11" =>
                delilnik <= 651; -- 4800
            when others =>
                delilnik <= 27; -- 115200 , never reached!
        end case;
    end process;
    
    -- stevec , ki generira uro clk16
    -- ura je 16- kratnik prenosne hitrosti
    -- generira se pulz v trajanju ene clk periode
    P_CLK16: process ( clk_i)
    begin
    if (clk_i ' event and clk_i = '1') then
            if rst_i = '1' then
                clk16 <= '0';
                count <= 0;
            else
                if count = delilnik -1 then
                    count <= 0;
                    clk16 <= '1';
                else
                    count <= count + 1;
                    clk16 <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;