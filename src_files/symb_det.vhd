LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY symb_det IS
    PORT (
        clk : IN STD_LOGIC; -- input clock 96kHz
        clr : IN STD_LOGIC; -- input synchronized reset
        adc_data : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
        symbol_valid : OUT STD_LOGIC;
        symbol_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol

        det_sample : OUT STD_LOGIC;
        det_sound : OUT STD_LOGIC
    );
END symb_det;

ARCHITECTURE Behavioral OF symb_det IS

    -- 6000 clk per digit
    CONSTANT DELAY : INTEGER := 50;
    CONSTANT CLOCK_FREQ : INTEGER := 96000;
    CONSTANT ADC_FREQ : INTEGER := 16;

    SIGNAL freq_counter : INTEGER RANGE 0 TO CLOCK_FREQ := DELAY * ADC_FREQ;
    SIGNAL start_sampling : STD_LOGIC := '0';

    SIGNAL sampling : STD_LOGIC := '0';
    SIGNAL data_cycle : INTEGER;
    SIGNAL sample_done : STD_LOGIC := '0';
    SIGNAL cnt : INTEGER := 0;

BEGIN

    proc_enable_sampling : PROCESS (clk, clr)
        VARIABLE idle : STD_LOGIC := '1';
    BEGIN
        IF clr = '1' THEN
            freq_counter <= DELAY * ADC_FREQ;
            start_sampling <= '0';
            idle := '1';
        ELSIF rising_edge(clk) THEN
            IF idle = '1' AND adc_data /= 0 THEN
                idle := '0';
            END IF;
            IF idle = '0' THEN
                IF freq_counter = 0 THEN
                    start_sampling <= '1';
                    freq_counter <= CLOCK_FREQ/ADC_FREQ;
                ELSE
                    freq_counter <= freq_counter - 1;
                    start_sampling <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS proc_enable_sampling;

    det_sample <= start_sampling;

    zero_crossing_detection : PROCESS (start_sampling, clk)
        --ZCD: detect the adc reaches 2047 with the same direction
        VARIABLE ref : INTEGER := 2047; --unchanged
        VARIABLE cycle : INTEGER;
        VARIABLE cycle1 : INTEGER;
        VARIABLE data : INTEGER;
        VARIABLE valid_delay : INTEGER := 0;
    BEGIN
        IF start_sampling = '1' THEN
            sampling <= '1';
            cnt <= 0;
            cycle := 0;
            cycle1 := 0;
        ELSIF rising_edge(clk) THEN --and sound = '1' 
            IF sampling = '1' THEN
                data := to_integer(unsigned(adc_data));
                IF (data - ref) <= 120 AND (cycle - cycle1) > 10 THEN
                    IF (ref - data) <= 160 THEN
                        IF cnt = 0 THEN
                            cycle := 0;
                            cnt <= cnt + 1;
                            cycle1 := cycle;
                        ELSIF cnt = 2 THEN
                            data_cycle <= cycle - 1;
                            sampling <= '0';
                            sample_done <= '1';
                            valid_delay := 0;
                        ELSE
                            cnt <= cnt + 1;
                            cycle1 := cycle;
                        END IF;
                    END IF;
                END IF;
                cycle := cycle + 1;
            END IF;
            IF valid_delay >= 1 THEN
                sample_done <= '0';
            END IF;
            valid_delay := valid_delay + 1;
        END IF;
    END PROCESS;

    output_logic : PROCESS (sample_done)
    BEGIN
        symbol_valid <= sample_done;
        IF sample_done = '1' THEN
            IF data_cycle >= 175 THEN -- 7 -- 183
                symbol_out <= "111";
            ELSIF data_cycle >= 140 THEN -- 6 -- 145
                symbol_out <= "110";
            ELSIF data_cycle >= 117 THEN -- 5 -- 122
                symbol_out <= "101";
            ELSIF data_cycle >= 94 THEN -- 4 -- 97
                symbol_out <= "100";
            ELSIF data_cycle >= 77 THEN -- 3 -- 82
                symbol_out <= "011";
            ELSIF data_cycle >= 64 THEN -- 2 -- 69
                symbol_out <= "010";
            ELSIF data_cycle >= 51 THEN -- 1 -- 55
                symbol_out <= "001";
            ELSE -- data_cycle >= 41 THEN -- 0 -- 45
                symbol_out <= "000";
            END IF;
        END IF;
    END PROCESS;

END Behavioral;