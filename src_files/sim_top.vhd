----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Jiajun Wu, Mo Song
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top with a signal generator module
-- Module Name: sys_top - Behavioral
-- Project Name: Music Decoder
-- Target Devices: Xilinx Basys3
-- Tool Versions: Vivado 2022.1
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

entity sys_top is
    Port (  
        clk_100m    : in STD_LOGIC; -- input clock 96kHz
        clr         : in STD_LOGIC; -- input synchronized reset
        csn         : out STD_LOGIC;
        sclk        : out STD_LOGIC;
        sdata       : in STD_LOGIC;
        sout        : out STD_LOGIC;
        led_busy    : out STD_LOGIC;
        
        switch_debug : in std_logic;
        led : out std_logic_vector(12 downto 0);
        seg : out std_logic_vector(6 downto 0);
        an      : out std_logic_vector(3 downto 0)
    );
end sys_top;

architecture Behavioral of sys_top is
    component adccntrl is
        Port (  csn : out STD_LOGIC;
                sclk : out STD_LOGIC;
                sdata : in STD_LOGIC;
                data : out STD_LOGIC_VECTOR(11 DOWNTO 0);
                clk : in STD_LOGIC;
                clr : in STD_LOGIC);
    end component adccntrl;
    component clk_wiz_0
        port
        (
            clk_12288k  : out    std_logic;
            -- Status and control signals
            -- reset       : in     std_logic;
            locked      : out    std_logic;
            clk_100m    : in     std_logic
        );
    end component clk_wiz_0;
    component clk_div is
        Port (  clk_in      : in STD_LOGIC;
                locked      : in STD_LOGIC;
                clk_div128  : out STD_LOGIC);
    end component clk_div;
    component symb_det is
        Port (  clk         : in STD_LOGIC; -- input clock 96kHz
                clr         : in STD_LOGIC; -- input synchronized reset
                adc_data    : in STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
                symbol_valid: out STD_LOGIC;
                symbol_out  : out STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol
                en_samping_debug : out STD_LOGIC;
                sound_debug : out std_logic
                );
    end component symb_det;
    component mcdecoder is
        port (
                din     : IN std_logic_vector(2 downto 0);
                valid   : IN std_logic;
                clr     : IN std_logic;
                clk     : IN std_logic;
                dout    : OUT std_logic_vector(7 downto 0);
                dvalid  : OUT std_logic;
                error   : OUT std_logic;
                state_err_debug : out std_logic;
                state_wait_debug : out std_logic;
                state_decode_debug : out std_logic;
                state_fin_debug : out std_logic;
                state_valid_debug : out std_logic);
                
    end component mcdecoder;
    component myuart is
        Port ( 
            din : in STD_LOGIC_VECTOR (7 downto 0);
            busy: out STD_LOGIC;
            wen : in STD_LOGIC;
            sout : out STD_LOGIC;
            clr : in STD_LOGIC;
            clk : in STD_LOGIC;
            state_wait : out std_logic;
            state_sending : out std_logic;
            state_idle : out std_logic);
    end component myuart;

    signal clk_12288k       : STD_LOGIC;
    signal clk              : STD_LOGIC;
    signal locked           : STD_LOGIC;
    signal symbol_valid     : STD_LOGIC;
    signal symbol_out       : STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol 
    signal dout             : STD_LOGIC_VECTOR(7 downto 0);
    signal dvalid           : STD_LOGIC;
    signal error            : STD_LOGIC;
    signal adc_data         : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    signal led_valid_debug : STD_LOGIC;
    signal led_dvalid_debug : STD_LOGIC;
    signal led_debug : STD_LOGIC;
    signal state_err_debug : std_logic;
    signal state_wait_debug : std_logic;
    signal state_decode_debug : std_logic;
    signal state_fin_debug : std_logic;
    signal state_valid_debug : std_logic;
    signal state_wait : std_logic;
    signal state_sending : std_logic;
    signal state_idle : std_logic;
    signal en_samping_debug : std_logic;
    signal sound_debug : std_logic;
begin

    -- if it works, copy to top.vhd
    clk_wiz_inst : clk_wiz_0
        port map ( 
    -- Clock out ports  
        clk_12288k => clk_12288k,
    -- Status and control signals                
        -- reset => clr,
        locked => locked,
        -- Clock in ports
        clk_100m => clk_100m
    );
    
    -- 96kHz clk
    clk_div_128_inst : clk_div port map (
        clk_in => clk_12288k,
        locked => locked,
        clk_div128 => clk
    );
    
    -- real adc
    adc_ctrl_inst: adccntrl port map(
        csn     => csn,
        sclk    => sclk,
        sdata   => sdata,
        data    => adc_data,
        clk     => clk_12288k,
        clr     => clr
    );

    symb_det_inst: symb_det port map (
        clk         => clk, 
        clr         => clr, 
        adc_data    => adc_data, 
        symbol_valid=> symbol_valid, 
        symbol_out  => symbol_out,
        en_samping_debug => en_samping_debug,
        sound_debug => sound_debug
    );

    mcdecoder_inst: mcdecoder port map (
        din     => symbol_out, 
        valid   => symbol_valid, 
        clr     => clr, 
        clk     => clk, 
        dout    => dout, 
        dvalid  => dvalid,
        error   => error,
        state_err_debug => state_err_debug,
        state_wait_debug => state_wait_debug,
        state_decode_debug => state_decode_debug,
        state_fin_debug => state_fin_debug,
        state_valid_debug => state_valid_debug
    );

    -- you may need a FIFO here

    myuart_inst: myuart port map (
        din     => dout,
        busy    => led_busy,
        wen     => dvalid,
        sout    => sout,
        clr     => clr,
        clk     => clk,
        state_wait => state_wait,
        state_sending => state_sending,
        state_idle => state_idle
    );
    
    led_valid_debug <= symbol_valid;
    led_dvalid_debug <= dvalid;
    led_debug <= '0';
        
    DEBUG_PROC : PROCESS(switch_debug)
    BEGIN
        if switch_debug = '1' then
            led <= led_valid_debug & led_dvalid_debug & led_debug & state_err_debug & state_wait_debug & state_decode_debug & state_fin_debug & state_valid_debug & state_wait & state_sending & state_idle & en_samping_debug & sound_debug;
        else
            led <= adc_data(11 downto 0) & '0';
        end if;
    END PROCESS;
    
    an <= "1110";
    process(symbol_out)
    begin
        case symbol_out is
            when "000" => seg <= "1000000"; -- 0
            when "001" => seg <= "1001111"; -- 1
            when "010" => seg <= "0100100"; -- 2
            when "011" => seg <= "0110000"; -- 3
            when "100" => seg <= "0011001"; -- 4
            when "101" => seg <= "0010010"; -- 5
            when "110" => seg <= "0000010"; -- 6
            when "111" => seg <= "1111000"; -- 7
        end case;
    end process;


    
end Behavioral;
