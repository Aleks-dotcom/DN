library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--use ieee.numeric_std;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity input_decode is
    Port ( rx_data : in STD_LOGIC_VECTOR (7 downto 0);
           rx_rdy : in STD_LOGIC;
           clk : in STD_LOGIC;
           command : out STD_LOGIC_VECTOR (4 downto 0);
           args : out STD_LOGIC_VECTOR (31 downto 0);
           ready : out STD_LOGIC);
end input_decode;

architecture Behavioral of input_decode is

    signal reg : std_logic_vector (31 downto 0);
    signal temp : std_logic_vector (31 downto 0);
    type state_type is ( IDLE , ARG, SEND );
    signal state , next_state : state_type;
    signal valid : std_logic := '0';
    signal rdy : std_logic := '0';
    --signal args_s : STD_LOGIC_VECTOR (27 downto 0) := "0000000000000000000000000000";
    signal rez : integer := 0;
    signal t : integer := 0;
    signal idle_state : std_logic := '0';
    signal counter_ready : integer := 0;

begin

    SYNC_PROC: process ( clk ) -- delovanje registra stanj 
	begin
		if (clk'event and clk = '1') then
				state <= next_state;
		end if;
	end process;
	
	NEXT_STATE_DECODE: process (state, valid, idle_state, rdy )
	begin
	   --TODO
        next_state <= state; 	
        case ( state ) is
            when IDLE =>	
                if valid = '1' and clk ='1'  then	next_state <= ARG;
                else			next_state <= IDLE;
                end if;
            when ARG =>	
                if rdy = '1' and clk ='1' then	next_state <= SEND;
                else			next_state <= ARG;
                end if;
            when SEND =>	
                --if rx_rdy = '1' and clk ='1' then	next_state <= IDLE;
                if idle_state  = '1' and clk ='1' then	next_state <= IDLE;
                else			next_state <= SEND;
                end if;
            when others =>		next_state <= IDLE;
                      end case;
	end process;
	
	OUTPUT_DECODE: process ( clk, rx_rdy  )
	begin

		if (clk'event and clk = '1') then
		
		    if state = IDLE then
		          rdy <= '0';
		         ready <= '0';
		         idle_state <= '0';
		         case (rx_data) is
                    when "01100100" => --debug
                        command <= "00001";
                        valid <= '1';
                    when "01110010" => --read
                        command <= "00010";
                        valid <= '1';
                    when "01110100" => --trace
                        command <= "00011";
                        valid <= '1';
                    when "01101001" => --idle
                        command <= "00000";
                        valid <= '1';
                    when "01100010" => --break
                        command <= "00100";
                        valid <= '1';
                    when others => --ne posljemo nic
                        valid <= '0';
                end case;
			     
			elsif state = ARG then
			     valid <= '0';
			     if rx_rdy = '1' then
                     if rx_data = "00001101" then -- ascii "ENTER" (carriage return)
                         args <= std_logic_vector(to_unsigned(rez, args'length));
                         
                         rdy <= '1';
                     elsif rx_data = "00100000" then -- ascii "SPACE"
                         rdy <= '0';
                     else
                         valid <= '0';
                         --args_s <= std_logic_vector(shift_left(unsigned (args_s), 8));
                         --t <= to_integer(unsigned(rx_data)) - 48; --30?
                         --rez <= rez*10
                         rez <= rez*10 + to_integer(unsigned(rx_data)) - 48;
    --                     args_s <= std_logic_vector(to_unsigned(rez, args_s'length));
    
                          --rez <= unsigned(args_s) + unsigned(rx_data);
                          --args_s <= std_logic_vector(rez);
    --                      args_s <= args_s and "00000000000000000000"&rx_data;
                     end if;  
                     --prebranac <= ''
                  end if;
            elsif state = SEND  then
                 rez <= 0;
			     ready <= '1';
			     if counter_ready >= 10 then 
			         counter_ready <= 0;
			         idle_state <= '1';
			     else
			         counter_ready <= counter_ready + 1;
			     end if;
			end if;
		end if;		
	end process;

end Behavioral;
