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
        symbol_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- output 3-bit detection symbol
    );
END symb_det_stub;

ARCHITECTURE Behavioral OF symb_det_stub IS

    CONSTANT CLOCK_FREQ : INTEGER := (96000/16 - 1);
    CONSTANT COLDDOWN : INTEGER := (30 - 1);

    SIGNAL freq_counter : INTEGER RANGE 0 TO CLOCK_FREQ := CLOCK_FREQ;
    SIGNAL data_idx : INTEGER RANGE 0 TO COLDDOWN := 0;

BEGIN

    sync_proc : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            symbol_valid <= '0';
            data_idx <= 0;
            freq_counter <= CLOCK_FREQ;
        ELSIF rising_edge(clk) THEN
            IF freq_counter = 0 THEN
                IF data_idx = COLDDOWN THEN
                    data_idx <= 0;
                ELSE
                    data_idx <= data_idx + 1;
                END IF;
                
                IF data_idx <= 28 then
                    symbol_valid <= '1';
                end if;
                
                freq_counter <= CLOCK_FREQ;
            ELSE
                symbol_valid <= '0';
                freq_counter <= freq_counter - 1;
            END IF;
        END IF;
    END PROCESS sync_proc;

    symbol_out_proc : PROCESS (data_idx)
    BEGIN
        CASE data_idx IS
            WHEN 1 => symbol_out <= "000";
            WHEN 2 => symbol_out <= "111";
            WHEN 3 => symbol_out <= "000";
            WHEN 4 => symbol_out <= "111";

            WHEN 5 => symbol_out <= "011";
            WHEN 6 => symbol_out <= "010";

            WHEN 7 => symbol_out <= "001";
            WHEN 8 => symbol_out <= "101";

            WHEN 9 => symbol_out <= "010";
            WHEN 10 => symbol_out <= "001";

            WHEN 11 => symbol_out <= "101";
            WHEN 12 => symbol_out <= "011";

            WHEN 13 => symbol_out <= "110";
            WHEN 14 => symbol_out <= "011";

            WHEN 15 => symbol_out <= "001";
            WHEN 16 => symbol_out <= "100";

            WHEN 17 => symbol_out <= "101";
            WHEN 18 => symbol_out <= "001";

            WHEN 19 => symbol_out <= "101";
            WHEN 20 => symbol_out <= "011";

            WHEN 21 => symbol_out <= "100";
            WHEN 22 => symbol_out <= "001";

            WHEN 23 => symbol_out <= "101";
            WHEN 24 => symbol_out <= "110";

            WHEN 25 => symbol_out <= "111";
            WHEN 26 => symbol_out <= "000";
            WHEN 27 => symbol_out <= "111";
            WHEN 28 => symbol_out <= "000";

            WHEN OTHERS => symbol_out <= "000";

        END CASE;
    END PROCESS;

END Behavioral;