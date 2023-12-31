LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

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
                debug_an : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));

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
                        -- reset             : in         std_logic;
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
                        symbol_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- output 4-bit detection symbol

                        det_state : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
                );
        END COMPONENT symb_det;

        COMPONENT mcdecoder IS
                PORT (
                        din : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
                        valid : IN STD_LOGIC;
                        clr : IN STD_LOGIC;
                        clk : IN STD_LOGIC;
                        dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                        dvalid : OUT STD_LOGIC;
                        error : OUT STD_LOGIC;
                        mcd_state : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
                );
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

        COMPONENT dpop IS
                PORT (
                        mcd_din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
                        mcd_wen : IN STD_LOGIC;

                        uart_dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                        uart_busy : IN STD_LOGIC;
                        uart_wen : OUT STD_LOGIC;

                        clk : IN STD_LOGIC;
                        clr : IN STD_LOGIC);
        END COMPONENT dpop;

        SIGNAL clk_12288k : STD_LOGIC;
        SIGNAL clk : STD_LOGIC;
        SIGNAL locked : STD_LOGIC;
        SIGNAL symbol_valid : STD_LOGIC;
        SIGNAL symbol_out : STD_LOGIC_VECTOR(3 DOWNTO 0); -- output 3-bit detection symbol 
        SIGNAL dout : STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL dvalid : STD_LOGIC;
        SIGNAL error : STD_LOGIC;
        SIGNAL adc_data : STD_LOGIC_VECTOR(11 DOWNTO 0);

        SIGNAL uart_din : STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL uart_busy : STD_LOGIC;
        SIGNAL uart_wen : STD_LOGIC;

        SIGNAL mcd_state : STD_LOGIC_VECTOR(5 DOWNTO 0);
        SIGNAL det_state : STD_LOGIC_VECTOR(4 DOWNTO 0);

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

                det_state => det_state
                );

        mcdecoder_inst : mcdecoder PORT MAP(
                din => symbol_out,
                valid => symbol_valid,
                clr => clr,
                clk => clk,
                dout => dout,
                dvalid => dvalid,
                error => error,
                mcd_state => mcd_state);

        dpop_inst : dpop PORT MAP(
                mcd_din => dout,
                mcd_wen => dvalid,
                uart_dout => uart_din,
                uart_busy => uart_busy,
                uart_wen => uart_wen,
                clk => clk,
                clr => clr);

        myuart_inst : myuart PORT MAP(
                din => uart_din,
                busy => uart_busy,
                wen => uart_wen,
                sout => sout,
                clr => clr,
                clk => clk);

        led_busy <= uart_busy;

        DEBUG_LED_PROC : PROCESS (debug_swc, mcd_state, det_state)
        BEGIN
                debug_an <= "111" & NOT debug_swc;
                IF debug_swc = '1' THEN
                        debug_led <= "0" & det_state & mcd_state;
                ELSE
                        debug_led <= (OTHERS => '0');
                END IF;
        END PROCESS;

        DEBUG_SEG_PROC : PROCESS (clk)
        BEGIN
            if rising_edge(clk) then
                CASE symbol_out IS
                        WHEN "0000" => debug_seg <= "1000000"; -- 0
                        WHEN "0001" => debug_seg <= "1001111"; -- 1
                        WHEN "0010" => debug_seg <= "0100100"; -- 2
                        WHEN "0011" => debug_seg <= "0110000"; -- 3
                        WHEN "0100" => debug_seg <= "0011001"; -- 4
                        WHEN "0101" => debug_seg <= "0010010"; -- 5
                        WHEN "0110" => debug_seg <= "0000010"; -- 6
                        WHEN "0111" => debug_seg <= "1111000"; -- 7
                        WHEN "1000" => debug_seg <= "0000000"; -- 8
                        WHEN OTHERS => debug_seg <= "1111111";
                END CASE;
             end if;
        END PROCESS;

END Behavioral;