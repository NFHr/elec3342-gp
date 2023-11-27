LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY symb_det_stub IS
    PORT (
        clk : IN STD_LOGIC; -- input clock 96kHz
        clr : IN STD_LOGIC; -- input synchronized reset
        adc_data : IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- input 12-bit ADC data
        symbol_valid : OUT STD_LOGIC;
        symbol_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); -- output 3-bit detection symbol

        det_sample : OUT STD_LOGIC;
        det_sound : OUT STD_LOGIC
    );
END symb_det_stub;

ARCHITECTURE Behavioral OF symb_det_stub IS

    CONSTANT CLOCK_FREQ : INTEGER := 96000/16;

    SIGNAL freq_counter : INTEGER RANGE 0 TO CLOCK_FREQ := CLOCK_FREQ - 1;
    SIGNAL data_idx : INTEGER RANGE 0 TO 27 := 0;
    SIGNAL gen : STD_LOGIC;

BEGIN

    symbol_valid_proc : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            gen <= '0';
            freq_counter <= CLOCK_FREQ - 1;
        ELSIF rising_edge(clk) THEN
            IF freq_counter = 0 THEN
                gen <= '1';
                symbol_valid <= '1';
                det_sample <= '1';
                freq_counter <= CLOCK_FREQ - 1;
            ELSE
                gen <= '0';
                symbol_valid <= '0';
                det_sample <= '0';
                freq_counter <= freq_counter - 1;
            END IF;
        END IF;
    END PROCESS symbol_valid_proc;

    data_idx_proc : PROCESS (gen, clr, clk)
    BEGIN
        IF clr = '1' THEN
            data_idx <= 0;
        ELSIF rising_edge(clk) AND gen = '1' THEN
            IF data_idx = 27 THEN
                data_idx <= 0;
            ELSE
                data_idx <= data_idx + 1;
            END IF;
        END IF;
    END PROCESS data_idx_proc;

    symbol_out_proc : PROCESS (data_idx, clk)
    BEGIN
        IF rising_edge(clk) THEN
            CASE data_idx IS
                WHEN 0 => symbol_out <= "000";
                WHEN 1 => symbol_out <= "111";
                WHEN 2 => symbol_out <= "000";
                WHEN 3 => symbol_out <= "111";

                WHEN 4 => symbol_out <= "011";
                WHEN 5 => symbol_out <= "010";

                WHEN 6 => symbol_out <= "001";
                WHEN 7 => symbol_out <= "101";

                WHEN 8 => symbol_out <= "010";
                WHEN 9 => symbol_out <= "001";

                WHEN 10 => symbol_out <= "101";
                WHEN 11 => symbol_out <= "011";

                WHEN 12 => symbol_out <= "110";
                WHEN 13 => symbol_out <= "011";

                WHEN 14 => symbol_out <= "001";
                WHEN 15 => symbol_out <= "100";

                WHEN 16 => symbol_out <= "101";
                WHEN 17 => symbol_out <= "001";

                WHEN 18 => symbol_out <= "101";
                WHEN 19 => symbol_out <= "011";

                WHEN 20 => symbol_out <= "100";
                WHEN 21 => symbol_out <= "001";

                WHEN 22 => symbol_out <= "110";
                WHEN 23 => symbol_out <= "100";

                WHEN 24 => symbol_out <= "111";
                WHEN 25 => symbol_out <= "000";
                WHEN 26 => symbol_out <= "111";
                WHEN 27 => symbol_out <= "000";

                WHEN OTHERS => symbol_out <= "000";

            END CASE;
        END IF;
    END PROCESS;

END Behavioral;