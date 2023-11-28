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
        symbol_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- output 3-bit detection symbol
    );
END symb_det;

ARCHITECTURE Behavioral OF symb_det IS

    -- 6000 clk per digit
    CONSTANT DELAY : INTEGER := 50;
    CONSTANT CLOCK_FREQ : INTEGER := 96000;
    CONSTANT ADC_FREQ : INTEGER := 16;

    SIGNAL freq_counter : INTEGER RANGE 0 TO CLOCK_FREQ := DELAY * ADC_FREQ;
    SIGNAL start_sampling : STD_LOGIC := '0';
    SIGNAL sound : STD_LOGIC := '0';
    SIGNAL sampling : STD_LOGIC := '0';
    SIGNAL data_cycle : INTEGER;
    SIGNAL sample_done : STD_LOGIC := '0';
    SIGNAL cnt : INTEGER := 0;
    SIGNAL threshold : INTEGER := 200;
    SIGNAL pre_data : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL signed_data : signed(11 DOWNTO 0);
    SIGNAL square_sig : STD_LOGIC;
    SIGNAL square_buf : STD_LOGIC;
    SIGNAL en_count : STD_LOGIC;
BEGIN

    proc_enable_sampling : PROCESS (clk, clr)
        VARIABLE idle : STD_LOGIC := '1';
    BEGIN
        IF clr = '1' THEN
            freq_counter <= DELAY * ADC_FREQ;
            start_sampling <= '0';
            idle := '1';
        ELSIF rising_edge(clk) THEN
            signed_data <= signed(adc_data);
            IF idle = '1' AND sound = '1' THEN -- adjust sound threshold -- original : adc_data /= 0
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
        det_sound <= idle;
    END PROCESS proc_enable_sampling;


    -- Average moving
    process (clk, clr)
    VARIABLE inp : INTEGER;
    begin
       inp := to_integer(unsigned(adc_data)) - 2047;
       if clr = '1' then -- reset
           sum <= 0;
           avg <= 0;
       elsif rising_edge(clk) then
           sum <= inp + sum - avg; -- update sum
           avg <= sum / n; -- calc average
       end if;
    end process;
    -- Sound threshold
    sound <= '1' when abs(avg) > threshold else '0';


    square_wave : process (clk, signed_data)
    BEGIN
        IF signed_data > 250 THEN
        square_sig <= '1';
        ELSIF signed_data < -250 THEN
            square_sig <= '0';
        END IF;
        square_buf <= square_sig;
    END PROCESS 


    zero_crossing_detection : PROCESS (start_sampling, clk)
        --ZCD: detect the adc reaches 2047 with the same direction
        -- VARIABLE ref : INTEGER := 2047; --unchanged
        VARIABLE cycle : INTEGER;
        VARIABLE cycle1 : INTEGER;
        VARIABLE data : INTEGER;
        VARIABLE valid_delay : INTEGER := 0;
    BEGIN
        IF start_sampling = '1' THEN
            sampling <= '1';
            cnt <= 0;
        ELSIF rising_edge(clk) THEN
            IF sampling = '1' THEN
                IF square_buf = '0' AND square_sig = '1' THEN
                    en_count <= '1';
                    IF cnt = 1 THEN
                        data_cycle <= cycle - 1;
                        sampling <= '0';
                        sample_done <= '1';
                        valid_delay := 0;
                        en_count <= '0';
                    cnt <= cnt + 1;
                    END IF;
                ELSE
                    en_count <= '0';
                END IF;
                IF en_count = '1' THEN
                    data_cycle <= data_cycle + 1;
                else
                    data_cycle <= '0';
                END IF;
            END IF;
        END IF;
        -- IF valid_delay >= 1 THEN
        --     sample_done <= '0';
        -- valid_delay := valid_delay + 1;
        -- END IF;
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