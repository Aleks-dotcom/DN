library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_registers is
    Port (
        hard_reset : in STD_LOGIC;
        reg : in std_logic_vector(31 downto 0);
        clk_i : in STD_LOGIC;
        enable_i : in STD_LOGIC;
        txbusy_i : in STD_LOGIC;

        rst_o : out STD_LOGIC;
        txstart_o : out STD_LOGIC;
        txreg_we_o : out STD_LOGIC;
        txdata_o : out STD_LOGIC_VECTOR (7 downto 0);
        num_of_reg : out STD_LOGIC_VECTOR (4 downto 0)
    );
end read_registers;

architecture Behavioral of read_registers is
    type state_byte is ( IDLE, SEND );
    signal curr_state : state_byte := IDLE;
    type state_reg is ( IDLE, NEW_REG, EN );
    signal curr_state_reg : state_reg := IDLE;
    signal busy : integer := 5;
    signal rst_dly : integer := 2000;
    signal we_dly : integer := 2000;
    signal st_dly : integer := 200000;
    signal nr_dly : integer := 2;
    signal enable_byte : std_logic := '0';
    signal run : integer := 32;

begin

    test: process ( clk_i )
    begin
        if (clk_i ' event and clk_i = '1') then
            -- reset 
            if hard_reset = '1' then
                curr_state_reg <= IDLE;
                curr_state <= IDLE;
            end if;        
            
            -- sprehajamo se po registrih
            if curr_state_reg = IDLE and enable_i = '1' then
                curr_state_reg <= NEW_REG;
                run <= 0;
            elsif curr_state_reg = NEW_REG then
                num_of_reg <= std_logic_vector(to_unsigned(run, 5));
                enable_byte <= '1';
                run <= run + 1;
                nr_dly <= 2;
                curr_state_reg <= EN;
            elsif curr_state_reg = EN then
                enable_byte <= '0';
                if busy = 5 and run < 32 and nr_dly = 0 then
                    curr_state_reg <= NEW_REG;
                elsif busy = 5 and run < 32 and nr_dly > 0 then
                    nr_dly <= nr_dly - 1;
                elsif run = 32 and enable_i = '0' then
                    curr_state_reg <= IDLE;
                elsif run = 32 and enable_i = '1' then
                    curr_state_reg <= EN;
                elsif busy < 5 then
                    curr_state_reg <= EN;
                end if;
            end if;

            -- sprehajamo se po bytih
            if enable_byte = '1' and curr_state = IDLE then
                busy <= 0;
                curr_state <= SEND;
            end if;
            if enable_byte = '0' and curr_state = SEND and busy = 5 then
                curr_state <= IDLE;
            end if;
            if busy < 4 then
                -- reset high
                if rst_dly > 0 then
                    rst_o <= '1';
                    txreg_we_o <= '0';
                    txstart_o <= '0';
                    rst_dly <= rst_dly - 1;
                elsif rst_dly = 0 then
                    rst_o <= '0';
                end if;
                -- we high
                if rst_dly = 0 and we_dly > 0 then
                    rst_o <= '0';
                    case (busy) is
                        when 0 => txdata_o <= reg (31 downto 24);
                        when 1 => txdata_o <= reg (23 downto 16);
                        when 2 => txdata_o <= reg (15 downto 8);
                        when 3 => txdata_o <= reg(7 downto 0);
                        when others => txdata_o <= "00000000";
                    end case;

                    txreg_we_o <= '1';
                    txstart_o <= '0';
                    we_dly <= we_dly - 1;
                elsif we_dly = 0 then
                    txreg_we_o <= '0';
                end if;
                if rst_dly = 0 and we_dly = 0 and st_dly > 0 then
                    rst_o <= '0';
                    txreg_we_o <= '0';
                    txstart_o <= '1';
                    st_dly <= st_dly - 1;
                elsif  st_dly = 0 then
                    txstart_o <= '0';
                end if;
            end if;
            if busy < 4 and rst_dly = 0 and we_dly = 0 and st_dly = 0 then
                busy <= busy + 1;
                rst_dly <= 2000;
                we_dly <= 2000;
                st_dly <= 200000;
            elsif busy = 4 and enable_byte = '0' then
                busy <= 5;
            end if;
        end if;
    end process;
end Behavioral;