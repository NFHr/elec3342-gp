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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY sim_top IS
    PORT (
        clk : IN STD_LOGIC; -- input clock 96kHz
        clr : IN STD_LOGIC; -- input synchronized reset
        adc_data : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        sout : OUT STD_LOGIC;
        led_busy : OUT STD_LOGIC;
        
        mcd_dout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END sim_top;

ARCHITECTURE Behavioral OF sim_top IS

    COMPONENT symb_det IS
        PORT (
            clk : IN STD_LOGIC; -- input clock 96kHz
            clr : IN STD_LOGIC; -- input synchronized reset
            adc_data : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
            symbol_valid : OUT STD_LOGIC;
            symbol_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
    END COMPONENT symb_det;

    COMPONENT mcdecoder IS
        PORT (
            din : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            valid : IN STD_LOGIC;
            clr : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            dvalid : OUT STD_LOGIC;
            error : OUT STD_LOGIC);
    END COMPONENT mcdecoder;

    COMPONENT myuart IS
        PORT (
            din : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            busy : OUT STD_LOGIC;
            wen : IN STD_LOGIC;
            sout : OUT STD_LOGIC;
            clr : IN STD_LOGIC;
            clk : IN STD_LOGIC);
    END COMPONENT myuart;

    SIGNAL symbol_valid : STD_LOGIC;
    SIGNAL symbol_out : STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol 
    SIGNAL dout : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL dvalid : STD_LOGIC;
    SIGNAL error : STD_LOGIC;

BEGIN

    symb_det_inst : symb_det PORT MAP(
        clk => clk,
        clr => clr,
        adc_data => adc_data,
        symbol_valid => symbol_valid,
        symbol_out => symbol_out,);

    mcdecoder_inst : mcdecoder PORT MAP(
        din => symbol_out,
        valid => symbol_valid,
        clr => clr,
        clk => clk,
        dout => dout,
        dvalid => dvalid,
        error => error);

    -- you may need a FIFO here

    myuart_inst : myuart PORT MAP(
        din => dout,
        busy => led_busy,
        wen => dvalid,
        sout => sout,
        clr => clr,
        clk => clk);
    
    mcd_dout <= dout;

END Behavioral;