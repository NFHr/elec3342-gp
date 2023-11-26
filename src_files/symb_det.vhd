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
    SIGNAL pre_data : INTEGER := 2047;
    CONSTANT threshold : INTEGER := 10;
    SIGNAL n : INTEGER := 8; -- block size for calculating average movement
    -- signal sound: std_logic;
    SIGNAL avg : INTEGER;
    SIGNAL sum : INTEGER;
BEGIN

    proc_enable_sampling : PROCESS (clk, clr)
        VARIABLE idle : STD_LOGIC := '1';
    BEGIN
        IF clr = '1' THEN
            freq_counter <= DELAY * ADC_FREQ;
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

    -- Step 1 Debugger by uncomment the following line  
    det_sample <= start_sampling; -- Debugging-- use symbol_valid as en_sampling 

    --     Average moving
    --    process (clk, clr)
    --    VARIABLE inp : INTEGER;
    --begin
    --   inp := to_integer(unsigned(adc_data));
    --    if clr = '1' then -- reset
    --        sum <= 0;
    --        avg <= 0;
    --    elsif rising_edge(clk) then
    --        sum <= inp + sum - avg; -- update sum
    --        avg <= sum / n; -- calc average
    --    end if;
    --end process;
    -- Sound threshold
    --sound <= '1' when (abs(avg-2047)) > threshold else '0';
    --det_sound <= '1' when abs(avg) > threshold else '0';
    det_sound <= '0';

    zero_crossing_detection : PROCESS (start_sampling, clk)
        --ZCD: detect the adc reaches 2047 with the same direction
        VARIABLE ref : INTEGER := 2047; --unchanged
        VARIABLE cycle : INTEGER;
        VARIABLE data : INTEGER;
        VARIABLE cycle1 : INTEGER;
        VARIABLE valid_delay : INTEGER := 0;
    BEGIN
        IF start_sampling = '1' THEN
            sampling <= '1';
            cnt <= 0;
            cycle := 0;
            cycle1 := 0;
            pre_data <= to_integer(signed(adc_data));
        ELSIF sampling = '1' THEN -- and sound = '1'
            IF rising_edge(clk) THEN
                data := to_integer(signed(adc_data));
                IF (data * pre_data) <= 0 AND (cycle - cycle1) > 15 THEN
                    --                    IF (ref - data) <= 125 THEN
                    IF cnt = 0 THEN
                        cycle := 0;
                        cnt <= cnt + 1;
                        cycle1 := cycle;
                    ELSIF cnt = 2 THEN
                        data_cycle <= cycle;
                        sampling <= '0';
                        sample_done <= '1';
                        valid_delay := 0;
                    ELSE
                        cnt <= cnt + 1;
                        cycle1 := cycle;
                    END IF;
                    --                    END IF;
                ELSE
                    IF valid_delay >= 2 THEN
                        sample_done <= '0';
                    END IF;
                END IF;
                cycle := cycle + 1;
                valid_delay := valid_delay + 1;
                pre_data <= data;
            END IF;
        ELSE
            IF valid_delay >= 2 THEN
                sample_done <= '0';
            END IF;
            valid_delay := valid_delay + 1;
        END IF;
    END PROCESS;

    -- Step 2 Debugger by uncomment the following 2 out of 3 lines
    --    symbol_valid <= sample_done;
    --    symbol_out <= '0' & '0' & start_sampling;
    --    symbol_out <= std_logic_vector(to_unsigned(cnt, 3)); -- Debugging : show when output is avaliable
    --symbol_valid <= sample_done;
    output_logic : PROCESS (data_cycle, sample_done)
    BEGIN
        IF sample_done = '1' THEN
            symbol_valid <= sample_done;
            IF data_cycle >= 180 THEN -- 7
                symbol_out <= "111";
            ELSIF data_cycle >= 142 THEN -- 6
                symbol_out <= "110";
            ELSIF data_cycle >= 119 THEN -- 5
                symbol_out <= "101";
            ELSIF data_cycle >= 94 THEN -- 4
                symbol_out <= "100";
            ELSIF data_cycle >= 78 THEN -- 3
                symbol_out <= "011";
            ELSIF data_cycle >= 65 THEN -- 2
                symbol_out <= "010";
            ELSIF data_cycle >= 51 THEN -- 1
                symbol_out <= "001";
            ELSIF data_cycle >= 42 THEN -- 0
                symbol_out <= "000";
            END IF;
        END IF;
    END PROCESS;

END Behavioral;