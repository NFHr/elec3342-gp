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
        symbol_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- output 3-bit detection symbol

        det_state : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
    );
END symb_det;

ARCHITECTURE Behavioral OF symb_det IS

    CONSTANT DELAY : INTEGER := 3000;
    CONSTANT SAMPLE_FREQ : INTEGER := 96000 / 16 - 1;
    SIGNAL clk_counter : INTEGER RANGE 0 TO SAMPLE_FREQ := SAMPLE_FREQ;
    SIGNAL en_sample : STD_LOGIC := '0';

    SIGNAL data_cycle : INTEGER RANGE 0 TO 512 := 0;

    SIGNAL signed_data : SIGNED(11 DOWNTO 0);


    SIGNAL zcd_range : SIGNED(1 DOWNTO 0);
    SIGNAL zcd : STD_LOGIC;
    SIGNAL prev_zcd : STD_LOGIC;

    TYPE state_type IS (ST_IDLE, ST_START, ST_WAIT, ST_COUNT_READY, ST_COUNT, ST_OUTPUT);
    SIGNAL state, next_state : state_type := St_IDLE;
BEGIN

    signed_data <= signed(adc_data - b"100000000000");

    SYNC_PROC : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            state <= ST_IDLE;
        ELSIF rising_edge(clk) THEN
            state <= next_state;
            prev_zcd <= zcd;
        END IF;
    END PROCESS;


    SYNC_SAMPLE_PROC : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            en_sample <= '0';
            clk_counter <= SAMPLE_FREQ;
        ELSIF rising_edge(clk) THEN
            IF state = ST_START THEN
                en_sample <= '0';
                clk_counter <= DELAY;
            ELSIF clk_counter = 0 THEN
                en_sample <= '1';
                clk_counter <= SAMPLE_FREQ;
            ELSE
                en_sample <= '0';
                clk_counter <= clk_counter - 1;
            END IF;
        END IF;
    END PROCESS;

    SYNC_CYCLE_COUNT_PROC : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            data_cycle <= 0;
        ELSIF rising_edge(clk) THEN
            IF state = ST_COUNT THEN
                data_cycle <= data_cycle + 1;
            ELSIF state = ST_WAIT THEN
                data_cycle <= 0;
            END IF;
        END IF;
    END PROCESS;

    ZCD_PROC : PROCESS (signed_data)
    BEGIN
        IF signed_data >= 425 THEN
            zcd_range <= "10";
            zcd <= '1';
        ELSIF signed_data <= - 425 THEN
            zcd <= '0';
            zcd_range <= "01";
        ELSE
            zcd_range <= "00";
        END IF;
    END PROCESS;

    NEXT_STATE_PROC : PROCESS (state, en_sample, zcd)
    BEGIN
        next_state <= state;
        CASE (state) IS
            WHEN ST_IDLE =>
                next_state <= ST_START;
            WHEN ST_START =>
                next_state <= ST_WAIT;
            WHEN ST_WAIT =>
                IF en_sample = '1' THEN
                    next_state <= ST_COUNT_READY;
                END IF;
            WHEN ST_COUNT_READY =>
                IF zcd = '1' AND prev_zcd = '0' THEN
                    next_state <= ST_COUNT;
                END IF;
            WHEN ST_COUNT =>
                IF zcd = '1' AND prev_zcd = '0' THEN
                    next_state <= ST_OUTPUT;
                END IF;
            WHEN ST_OUTPUT =>
                next_state <= ST_WAIT;
            WHEN OTHERS =>
                next_state <= ST_IDLE;
        END CASE;
    END PROCESS;

    OUTPUT_PROC : PROCESS (state)
    BEGIN
        CASE state IS
            WHEN ST_OUTPUT =>
                symbol_valid <= '1';
                CASE data_cycle IS
                    WHEN 165 TO 512 =>      -- 183
                        symbol_out <= "0111"; -- 7
                    WHEN 134 TO 164 =>      -- 146
                        symbol_out <= "0110"; -- 6
                    WHEN 110 TO 133 =>      -- 122
                        symbol_out <= "0101"; -- 5
                    WHEN 90 TO 109 =>       -- 97
                        symbol_out <= "0100"; -- 4
                    WHEN 76 TO 89 =>        -- 82
                        symbol_out <= "0011"; -- 3
                    WHEN 62 TO 75 =>        -- 68
                        symbol_out <= "0010"; -- 2
                    WHEN 51 TO 61 =>        -- 54
                        symbol_out <= "0001"; -- 1
                    WHEN 38 TO 50 =>        -- 46
                        symbol_out <= "0000"; -- 0
                    WHEN 0 TO 37 =>         -- 27
                        symbol_out <= "1000"; -- 8
                    WHEN OTHERS =>
                        symbol_out <= "0000";
                END CASE;
            WHEN OTHERS =>
                symbol_out <= "0000";
                symbol_valid <= '0';
        END CASE;
    END PROCESS;

    DEBUG_PROCESS : PROCESS (state)
    BEGIN
        CASE state IS
            WHEN ST_IDLE => det_state <= "00001";
            WHEN ST_START => det_state <= "00010";
            WHEN ST_WAIT => det_state <= "00100";
            WHEN ST_COUNT => det_state <= "01000";
            WHEN ST_OUTPUT => det_state <= "10000";
            WHEN OTHERS => det_state <= "00000";
        END CASE;
    END PROCESS;

END Behavioral;