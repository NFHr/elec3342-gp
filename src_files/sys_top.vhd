LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sys_top IS
    PORT (
        clk_100m : IN STD_LOGIC; -- input clock 96kHz
        clr : IN STD_LOGIC; -- input synchronized reset
        csn : OUT STD_LOGIC;
        sclk : OUT STD_LOGIC;
        sdata : IN STD_LOGIC;
        sout : OUT STD_LOGIC;
        led_busy : OUT STD_LOGIC;

        debug_swc : IN STD_LOGIC;
        debug_led : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        debug_seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        debug_ano : OUT STD_LOGIC);
END sys_top;

ARCHITECTURE Behavioral OF sys_top IS

    COMPONENT adccntrl IS
        PORT (
            csn : OUT STD_LOGIC;
            sclk : OUT STD_LOGIC;
            sdata : IN STD_LOGIC;
            data : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            clk : IN STD_LOGIC;
            clr : IN STD_LOGIC);
    END COMPONENT adccntrl;

    COMPONENT clk_wiz_0
        PORT (
            clk_12288k : OUT STD_LOGIC;
            -- Status and control signals
            -- reset       : in     std_logic;
            locked : OUT STD_LOGIC;
            clk_100m : IN STD_LOGIC
        );
    END COMPONENT clk_wiz_0;

    COMPONENT clk_div IS
        PORT (
            clk_in : IN STD_LOGIC;
            locked : IN STD_LOGIC;
            clk_div128 : OUT STD_LOGIC);
    END COMPONENT clk_div;

    COMPONENT symb_det IS
        PORT (
            clk : IN STD_LOGIC; -- input clock 96kHz
            clr : IN STD_LOGIC; -- input synchronized reset
            adc_data : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
            symbol_valid : OUT STD_LOGIC;
            symbol_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol

            det_sample : OUT STD_LOGIC;
            det_sound : OUT STD_LOGIC);
    END COMPONENT symb_det;

    COMPONENT mcdecoder IS
        PORT (
            din : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            valid : IN STD_LOGIC;
            clr : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            dvalid : OUT STD_LOGIC;
            error : OUT STD_LOGIC;

            mcd_err : OUT STD_LOGIC;
            mcd_wait : OUT STD_LOGIC;
            mcd_decode : OUT STD_LOGIC;
            mcd_fin : OUT STD_LOGIC;
            mcd_valid : OUT STD_LOGIC);
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

    SIGNAL clk_12288k : STD_LOGIC;
    SIGNAL clk : STD_LOGIC;
    SIGNAL locked : STD_LOGIC;
    SIGNAL symbol_valid : STD_LOGIC;
    SIGNAL symbol_out : STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol 
    SIGNAL dout : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL dvalid : STD_LOGIC;
    SIGNAL error : STD_LOGIC;
    SIGNAL adc_data : STD_LOGIC_VECTOR(11 DOWNTO 0);

    -- DEBUG SIGNAL
    SIGNAL l_mcd_dvalid : STD_LOGIC;
    SIGNAL l_mcd_error : STD_LOGIC;
    SIGNAL s_mcd_err : STD_LOGIC;
    SIGNAL s_mcd_wait : STD_LOGIC;
    SIGNAL s_mcd_decode : STD_LOGIC;
    SIGNAL s_mcd_fin : STD_LOGIC;
    SIGNAL s_mcd_valid : STD_LOGIC;

    SIGNAL l_det_valid : STD_LOGIC;
    SIGNAL l_det_sample : STD_LOGIC;
    SIGNAL l_det_sound : STD_LOGIC;

BEGIN

    -- if it works, copy to top.vhd
    clk_wiz_inst : clk_wiz_0
    PORT MAP(
        -- Clock out ports  
        clk_12288k => clk_12288k,
        -- Status and control signals                
        -- reset => clr,
        locked => locked,
        -- Clock in ports
        clk_100m => clk_100m
    );

    -- 96kHz clk
    clk_div_128_inst : clk_div PORT MAP(
        clk_in => clk_12288k,
        locked => locked,
        clk_div128 => clk
    );

    -- real adc
    adc_ctrl_inst : adccntrl PORT MAP(
        csn => csn,
        sclk => sclk,
        sdata => sdata,
        data => adc_data,
        clk => clk_12288k,
        clr => clr
    );

    symb_det_inst : symb_det PORT MAP(
        clk => clk,
        clr => clr,
        adc_data => adc_data,
        symbol_valid => symbol_valid,
        symbol_out => symbol_out,
        det_sample => l_det_sample,
        det_sound => l_det_sound);

    mcdecoder_inst : mcdecoder PORT MAP(
        din => symbol_out,
        valid => symbol_valid,
        clr => clr,
        clk => clk,
        dout => dout,
        dvalid => dvalid,
        error => error,

        mcd_err => s_mcd_err,
        mcd_wait => s_mcd_wait,
        mcd_decode => s_mcd_decode,
        mcd_fin => s_mcd_fin,
        mcd_valid => s_mcd_valid);

    -- you may need a FIFO here

    myuart_inst : myuart PORT MAP(
        din => dout,
        busy => led_busy,
        wen => dvalid,
        sout => sout,
        clr => clr,
        clk => clk);

    -- DEBUG
    l_det_valid <= symbol_valid;
    l_mcd_dvalid <= dvalid;
    l_mcd_error <= error;

    DEBUG_LED_PROC : PROCESS (debug_swc)
    BEGIN
        IF debug_swc = '1' THEN
            debug_ano <= '0';
            debug_led <=
                l_det_valid &
                l_mcd_dvalid &
                l_mcd_error &
                s_mcd_err &
                s_mcd_wait &
                s_mcd_decode &
                s_mcd_fin &
                s_mcd_valid &
                '0' &
                '0' &
                l_det_sample &
                l_det_sound;
        ELSE
            debug_ano <= '1';
            debug_led <= (OTHERS => '0');
        END IF;
    END PROCESS;

    DEBUG_SEG_PROC : PROCESS (symbol_out)
    BEGIN
        CASE symbol_out IS
            WHEN "000" => debug_seg <= "1000000"; -- 0
            WHEN "001" => debug_seg <= "1001111"; -- 1
            WHEN "010" => debug_seg <= "0100100"; -- 2
            WHEN "011" => debug_seg <= "0110000"; -- 3
            WHEN "100" => debug_seg <= "0011001"; -- 4
            WHEN "101" => debug_seg <= "0010010"; -- 5
            WHEN "110" => debug_seg <= "0000010"; -- 6
            WHEN "111" => debug_seg <= "1111000"; -- 7
        END CASE;
    END PROCESS;

END Behavioral;