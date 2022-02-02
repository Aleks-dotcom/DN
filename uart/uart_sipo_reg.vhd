library IEEE;
use IEEE. STD_LOGIC_1164. ALL;
use IEEE. STD_LOGIC_ARITH. ALL;
use IEEE. STD_LOGIC_UNSIGNED. ALL;

entity uart_sipo_reg is
    generic (
        data_width : integer := 8
    );
    Port (
        clk_i : in STD_LOGIC;
        rst_i : in STD_LOGIC;
        ce_i : in STD_LOGIC;
        data_i : in STD_LOGIC;
        data_o : out STD_LOGIC_VECTOR ( data_width -1 downto 0)
    );
end uart_sipo_reg;

architecture Behavioral of uart_sipo_reg is
    signal q : STD_LOGIC_VECTOR ( data_width -1 downto 0);
begin
    process ( clk_i )
    begin
        if clk_i ' event and clk_i ='1' then
            if rst_i ='1' then
                q <= (others => '0');
            elsif ce_i = '1' then
                q <= data_i & q(( data_width -1) downto 1) ;
            end if;
        end if;
        data_o <= q;
    end process;
end Behavioral;