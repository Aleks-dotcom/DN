----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.02.2022 11:53:13
-- Design Name: 
-- Module Name: top_debugger - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_debugger is
    Port ( 
           clk : in STD_LOGIC;
           data_ram : in STD_LOGIC_VECTOR (31 downto 0);
           reset : in STD_LOGIC;
           tx_pc : in STD_LOGIC;
           tx_dbg : out STD_LOGIC;
           addr_ram : out STD_LOGIC_VECTOR (4 downto 0);
           clk_processor : out STD_LOGIC 
          );
end top_debugger;

architecture Behavioral of top_debugger is
    component main_state_machine is
        Port (
               clk : in STD_LOGIC;                                   -- clock
               command : in STD_LOGIC_VECTOR (4 downto 0);           -- encoded command for the next state
               recv : in STD_LOGIC;                                  -- recieve signal -> when 1 new command and arguments have arrived
               args : in STD_LOGIC_VECTOR(31 downto 0);              -- arguments of the command
               reset : in STD_LOGIC;                                 -- reset the state machine                     
               data_out : in STD_LOGIC_VECTOR(31 downto 0);          -- data za prebrat ram
               clk_enable : out STD_LOGIC := '0';                    -- enable / disable the clock signal for the processor
               read_enable : out STD_LOGIC;                          -- enable read module to read all the pipeline registers
               addr_out : out STD_LOGIC_VECTOR(4 downto 0)           -- addr to request data from ram
             );
	end component;
    component input_decode is
        Port ( 
               rx_data : in STD_LOGIC_VECTOR (7 downto 0);           -- data we read from Tx_PC
               rx_rdy : in STD_LOGIC;                                -- ready signal for rx line
               clk : in STD_LOGIC;                                   -- system clock
               command : out STD_LOGIC_VECTOR (4 downto 0);          -- decoded command we send to main_state_machine
               args : out STD_LOGIC_VECTOR (31 downto 0);            -- decoded args we send to main_state_machine
               ready : out STD_LOGIC                                 -- ready signal we send to main_state_machine so that it knows when new data is ready
              );
	end component;
	
	component uart_top is
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
	end component;
	
	component read_registers is 
	        Port (
                    clk_i : in STD_LOGIC;                            -- system clock
                    hard_reset : in STD_LOGIC;                       -- reset automat
                    reg : in std_logic_vector(31 downto 0);          -- current register that we are requesting from ram
                    enable_i : in STD_LOGIC;                         -- signal recieved from main_state_mchine to start reading
                    txbusy_i : in STD_LOGIC;                         -- signal from PC to know when tx line is busy
                    rst_o : out STD_LOGIC;                           -- reset uart SM
                    txstart_o : out STD_LOGIC;                       -- transmition
                    txreg_we_o : out STD_LOGIC;                      -- transmition
                    txdata_o : out STD_LOGIC_VECTOR (7 downto 0);    -- data we send to PC
                    num_of_reg : out STD_LOGIC_VECTOR (4 downto 0)   -- ram addr of register to read
                );
    end component;
    
    -- internal signals input_decode <=> MSM
    signal ready_recv_internal : STD_LOGIC;
    signal command_internal : STD_LOGIC_VECTOR (4 downto 0);
    signal args_internal : STD_LOGIC_VECTOR (31 downto 0);
    
    -- internal signals MSM <=> read_registers
    signal read_done_internal : STD_LOGIC;
    signal read_enable_internal : STD_LOGIC;
    
    -- internal signals uart
    signal txstart_internal : STD_LOGIC;
    signal txreg_we_internal : STD_LOGIC;
    signal txdata_internal : STD_LOGIC_VECTOR (7 downto 0);
    signal rxdata_internal : STD_LOGIC_VECTOR (7 downto 0);
    signal rxready_internal : STD_LOGIC;
    signal txbusy_internal : STD_LOGIC;
    
begin
    msm: main_state_machine
    port map (
            clk => clk,
            command => command_internal,
            recv => ready_recv_internal,
            args => args_internal,
            reset => reset,
            data_out => data_ram,
            read_enable => read_enable_internal,
            addr_out => addr_ram,
            clk_enable => clk_processor
        );

    uart: uart_top
    port map (
            clk_i => clk,
            rst_i => reset,
            txstart_i => txstart_internal,
            txreg_we_i => txreg_we_internal,
            txdata_i => txdata_internal,
            baud_i => "11",
            RxD_i => tx_pc,
            rxdata_o => rxdata_internal,
            rxrdy_o => rxready_internal,
            TxD_o => tx_dbg,
            txbusy_o =>txbusy_internal
        );

    id: input_decode
    port map (
            clk => clk,
            rx_data => rxdata_internal,
            rx_rdy => rxready_internal,
            command => command_internal,
            args => args_internal,
            ready => ready_recv_internal
        );


    rr: read_registers
    port map (
            clk_i => clk,
            hard_reset => reset,
            reg =>data_ram,
            enable_i => read_enable_internal,
            txbusy_i => txbusy_internal,
            rst_o => reset,
            txstart_o => txstart_internal,
            txreg_we_o => txreg_we_internal,
            txdata_o => txdata_internal,
            num_of_reg => addr_ram
        );
    
end Behavioral;
