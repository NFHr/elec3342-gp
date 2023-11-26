----------------------------------------------------------------------------------
-- Company: Computer Architecture and System Research (CASR), HKU, Hong Kong
-- Engineer: Jiajun Wu, Mo Song
-- 
-- Create Date: 09/09/2022 06:20:56 PM
-- Design Name: system top
-- Module Name: top - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

use STD.textio.all;
use ieee.std_logic_textio.all;

entity sim_top_tb is
--  Port ( );
end sim_top_tb;

architecture Behavioral of sim_top_tb is
    component sim_top is
        Port (  
            clk         : in STD_LOGIC; -- input clock 96kHz
            clr         : in STD_LOGIC; -- input synchronized reset
            adc_data    : in STD_LOGIC_VECTOR(11 DOWNTO 0);
            sout        : out STD_LOGIC;
            led_busy    : out STD_LOGIC;
            led_valid_debug : out STD_LOGIC;
            led_dvalid_debug : out STD_LOGIC;
            led_error_debug : out STD_LOGIC;
            symb_det_debug : out STD_LOGIC_VECTOR(2 DOWNTO 0);
            mcdecoder_debug : out std_logic_vector(7 downto 0)
        );
    end component sim_top;

    file file_VECTORS   : text;

    constant clkPeriod  : time := 10 ns;
    constant ADC_WIDTH  : integer := 12;
    constant SAMPLE_LEN : integer := 168000;
    
    signal clk          : std_logic;
    signal clr          : std_logic;
    signal adc_data     : std_logic_vector(11 downto 0);
    signal sample_cnt   : integer := 0;
    signal sout         : std_logic;
    signal led_busy     : std_logic;
    signal symb_det_debug : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal mcdecoder_debug : std_logic_vector(7 downto 0);
    signal led_valid_debug : std_logic;
    signal led_dvalid_debug : std_logic;
    signal led_error_debug : std_logic;
    -- sine wave signal
    type wave_array is array (0 to SAMPLE_LEN-1) of std_logic_vector (ADC_WIDTH-1 downto 0);
    signal input_wave: wave_array;
begin

    sim_top_inst: sim_top port map(
        clk         => clk,
        clr         => clr,
        adc_data    => adc_data,
        sout        => sout,
        led_busy    => led_busy,
        led_valid_debug =>  led_valid_debug,
        led_dvalid_debug => led_dvalid_debug,
        led_error_debug => led_error_debug,
        symb_det_debug => symb_det_debug,
        mcdecoder_debug => mcdecoder_debug

    );

    proc_init_array: process
        -- variable input_wave_temp: wave_array;
        variable wave_amp   : std_logic_vector(ADC_WIDTH-1 downto 0);
        variable line_index : integer := 0;
        variable v_ILINE    : line;
    begin
        -- file_open(file_VECTORS, "/vol/datastore/jiajun/americano_01/elec3342/ELEC3342_fa22_prj/tb/info_wave.txt", read_mode);
        file_open(file_VECTORS, "info_wave.txt", read_mode);
        for i in 0 to (SAMPLE_LEN-1) loop
            readline(file_VECTORS, v_ILINE);
            read(v_ILINE, wave_amp);
            input_wave(i) <= wave_amp;
        end loop;
        wait;
    end process proc_init_array;

    -- clock process
    proc_clk: process
    begin
        clk <= '0';
        wait for clkPeriod/2;
        clk <= '1';
        wait for clkPeriod/2;
    end process proc_clk;

    proc_clr: process
    begin
        clr <= '1', '0' after clkPeriod;
        wait;
    end process proc_clr;

    proc_adc_data: process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                adc_data <= (others=>'0');
            else
                adc_data <= input_wave(sample_cnt);
            end if;
        end if;
    end process proc_adc_data;

    proc_sample_cnt: process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                sample_cnt <= 0;
            elsif (sample_cnt = SAMPLE_LEN - 1) then 
                sample_cnt <= 0;
            else 
                sample_cnt <= sample_cnt + 1;
            end if;
        end if;
    end process proc_sample_cnt;

end Behavioral;
