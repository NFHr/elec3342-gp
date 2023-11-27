LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY mcdecoder_stub IS
    PORT (
        din : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        valid : IN STD_LOGIC;
        clr : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        dvalid : OUT STD_LOGIC;
        error : OUT STD_LOGIC
    );
END mcdecoder_stub;

ARCHITECTURE Behavioral OF mcdecoder_stub IS
    CONSTANT CLOCK_CYCLE : INTEGER := (120 - 1);

    SIGNAL clock_cnt : INTEGER RANGE 0 TO CLOCK_CYCLE;
    SIGNAL char_cnt : INTEGER RANGE 0 TO 26;

BEGIN
    error <= '0';

    proc_clock_cnt : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            dvalid <= '0';
            clock_cnt <= 0;
        ELSIF rising_edge(clk) THEN
            IF (clock_cnt = CLOCK_CYCLE) THEN
                IF (char_cnt = 26) THEN
                    char_cnt <= 0;
                ELSE
                    char_cnt <= char_cnt + 1;
                END IF;
                dvalid <= '1';
                clock_cnt <= 0;
            ELSE
                dvalid <= '0';
                clock_cnt <= clock_cnt + 1;
            END IF;
        END IF;
    END PROCESS;

    proc_char_clk_cnt : PROCESS (clk, clr)
    BEGIN
        CASE char_cnt IS
            WHEN 1 => dout <= "01000001"; -- A
            WHEN 2 => dout <= "01000010"; -- B
            WHEN 3 => dout <= "01000011"; -- C
            WHEN 4 => dout <= "01000100"; -- D
            WHEN 5 => dout <= "01000101"; -- E
            WHEN 6 => dout <= "01000110"; -- F
            WHEN 7 => dout <= "01000111"; -- G
            WHEN 8 => dout <= "01001000"; -- H
            WHEN 9 => dout <= "01001001"; -- I
            WHEN 10 => dout <= "01001010"; -- J
            WHEN 11 => dout <= "01001011"; -- K
            WHEN 12 => dout <= "01001100"; -- L
            WHEN 13 => dout <= "01001101"; -- M
            WHEN 14 => dout <= "01001110"; -- N
            WHEN 15 => dout <= "01001111"; -- O
            WHEN 16 => dout <= "01010000"; -- P
            WHEN 17 => dout <= "01010001"; -- Q
            WHEN 18 => dout <= "01010010"; -- R
            WHEN 19 => dout <= "01010011"; -- S
            WHEN 20 => dout <= "01010100"; -- T
            WHEN 21 => dout <= "01010101"; -- U
            WHEN 22 => dout <= "01010110"; -- V
            WHEN 23 => dout <= "01010111"; -- W
            WHEN 24 => dout <= "01011000"; -- X
            WHEN 25 => dout <= "01011001"; -- Y
            WHEN 26 => dout <= "01011010"; -- Z
            WHEN OTHERS => dout <= "00101110";
        END CASE;
    END PROCESS;
END Behavioral;