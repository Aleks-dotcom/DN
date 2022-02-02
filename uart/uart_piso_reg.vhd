library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_piso_reg is
    generic (
        data_width : integer := 10
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        we_i : in STD_LOGIC;
        ce_i : in STD_LOGIC;
        data_i : in STD_LOGIC_VECTOR ( data_width -3 downto 0);
        data_o : out STD_LOGIC
    );
end uart_piso_reg;

architecture Behavioral of uart_piso_reg is
    signal q : STD_LOGIC_VECTOR ( data_width -1 downto 0);
    
begin
    P_PISO : process ( clk_i)
    begin
        if clk_i ' event and clk_i ='1' then
            if rst_i ='1' then
                q <= (others => '1');
            elsif we_i = '1' then
                q <= '1' & data_i & '0'; -- STOP data START
            elsif ce_i = '1' then -- shift right
                q <= '1' & q( data_width -1 downto 1);
            end if;
        end if;
        data_o <= q (0); -- LSB goes out
    end process;
end Behavioral;