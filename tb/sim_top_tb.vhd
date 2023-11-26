LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY sim_top_tb IS
    --  Port ( );
END sim_top_tb;

ARCHITECTURE Behavioral OF sim_top_tb IS
    COMPONENT sim_top IS
        PORT (
            clk : IN STD_LOGIC; -- input clock 96kHz
            clr : IN STD_LOGIC; -- input synchronized reset
            adc_data : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            sout : OUT STD_LOGIC;
            led_busy : OUT STD_LOGIC;

            mcd_dout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));

    END COMPONENT sim_top;

    FILE file_VECTORS : text;

    CONSTANT clkPeriod : TIME := 10 ns;
    CONSTANT ADC_WIDTH : INTEGER := 12;
    CONSTANT SAMPLE_LEN : INTEGER := 168000;

    SIGNAL clk : STD_LOGIC;
    SIGNAL clr : STD_LOGIC;
    SIGNAL adc_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL sample_cnt : INTEGER := 0;
    SIGNAL sout : STD_LOGIC;
    SIGNAL led_busy : STD_LOGIC;

    SIGNAL mcd_dout : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- sine wave signal
    TYPE wave_array IS ARRAY (0 TO SAMPLE_LEN - 1) OF STD_LOGIC_VECTOR (ADC_WIDTH - 1 DOWNTO 0);
    SIGNAL input_wave : wave_array;
BEGIN

    sim_top_inst : sim_top PORT MAP(
        clk => clk,
        clr => clr,
        adc_data => adc_data,
        sout => sout,
        led_busy => led_busy,
        mcd_dout => mcd_dout
    );

    proc_init_array : PROCESS
        -- variable input_wave_temp: wave_array;
        VARIABLE wave_amp : STD_LOGIC_VECTOR(ADC_WIDTH - 1 DOWNTO 0);
        VARIABLE line_index : INTEGER := 0;
        VARIABLE v_ILINE : line;
    BEGIN
        -- file_open(file_VECTORS, "/vol/datastore/jiajun/americano_01/elec3342/ELEC3342_fa22_prj/tb/info_wave.txt", read_mode);
        file_open(file_VECTORS, "info_wave.txt", read_mode);
        FOR i IN 0 TO (SAMPLE_LEN - 1) LOOP
            readline(file_VECTORS, v_ILINE);
            read(v_ILINE, wave_amp);
            input_wave(i) <= wave_amp;
        END LOOP;
        WAIT;
    END PROCESS proc_init_array;

    -- clock process
    proc_clk : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clkPeriod/2;
        clk <= '1';
        WAIT FOR clkPeriod/2;
    END PROCESS proc_clk;

    proc_clr : PROCESS
    BEGIN
        clr <= '1', '0' AFTER clkPeriod;
        WAIT;
    END PROCESS proc_clr;

    proc_adc_data : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF clr = '1' THEN
                adc_data <= (OTHERS => '0');
            ELSE
                adc_data <= input_wave(sample_cnt);
            END IF;
        END IF;
    END PROCESS proc_adc_data;

    proc_sample_cnt : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF clr = '1' THEN
                sample_cnt <= 0;
            ELSIF (sample_cnt = SAMPLE_LEN - 1) THEN
                sample_cnt <= 0;
            ELSE
                sample_cnt <= sample_cnt + 1;
            END IF;
        END IF;
    END PROCESS proc_sample_cnt;

END Behavioral;