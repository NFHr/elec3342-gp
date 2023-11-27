LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mcdecoder IS
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
    mcd_valid : OUT STD_LOGIC
  );
END mcdecoder;

ARCHITECTURE Behavioral OF mcdecoder IS
    TYPE state_type IS (St_RESET, St_ERROR, St_WAIT, St_checkstart_1, St_checkstart_2, St_checkstart_3, St_checkstart_again_1, St_READ, St_READ_1, St_READ_2, St_READ_3, St_READ_4, St_READ_5, St_READ_6, St_checkend_1, St_checkend_2, St_checkend_3);
    SIGNAL state, next_state : state_type := St_RESET;
    CONSTANT clkPeriod : TIME := 10 us;
BEGIN
    sync_process : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            state <= St_RESET;
        ELSIF rising_edge(clk) THEN
            IF valid = '1' THEN
                state <= next_state;
            END IF;
        END IF;
    END PROCESS;

    state_logic : PROCESS (state)
    BEGIN
        next_state <= state;
        CASE (state) IS
            WHEN St_RESET =>
                IF din = "000" THEN
                    next_state <= St_checkstart_1;
                ELSE
                    next_state <= St_WAIT;
                END IF;
            WHEN St_WAIT =>
                IF din = "000" THEN
                    next_state <= St_checkstart_1;
                ELSE
                    next_state <= St_RESET;
                END IF;
            WHEN St_ERROR =>
                next_state <= St_RESET;
            WHEN St_checkstart_1 =>
                IF din = "111" THEN
                    next_state <= St_checkstart_2;
                ELSIF din = "000" THEN
                    next_state <= St_checkstart_again_1;
                ELSE
                    next_state <= St_WAIT;
                END IF;
            WHEN St_checkstart_again_1 =>
                IF din = "111" THEN
                    next_state <= St_checkstart_2;
                ELSE
                    next_state <= St_WAIT;
                END IF;
            WHEN St_checkstart_2 =>
                IF din = "000" THEN
                    next_state <= St_checkstart_3;
                ELSE
                    next_state <= St_WAIT;
                END IF;
            WHEN St_checkstart_3 =>
                IF din = "111" THEN
                    next_state <= St_READ;
                ELSIF din = "000" THEN
                    next_state <= St_checkstart_1;
                ELSE
                    next_state <= St_WAIT;
                END IF;
            WHEN St_READ =>
                IF din = "001" THEN
                    next_state <= St_READ_1;
                ELSIF din = "010" THEN
                    next_state <= St_READ_2;
                ELSIF din = "011" THEN
                    next_state <= St_READ_3;
                ELSIF din = "100" THEN
                    next_state <= St_READ_4;
                ELSIF din = "101" THEN
                    next_state <= St_READ_5;
                ELSIF din = "110" THEN
                    next_state <= St_READ_6;
                ELSIF din = "000" THEN
                    next_state <= St_ERROR;
                ELSIF din = "111" THEN
                    next_state <= St_checkend_1;
                END IF;
            WHEN St_READ_1 =>
                IF din = ("000" OR "111" OR "001") THEN
                    next_state <= St_ERROR;
                ELSE
                    next_state <= St_READ;
                END IF;
            WHEN St_READ_2 =>
                IF din = ("000" OR "111" OR "010") THEN
                    next_state <= St_ERROR;
                ELSE
                    next_state <= St_READ;
                END IF;
            WHEN St_READ_3 =>
                IF din = ("000" OR "111" OR "011") THEN
                    next_state <= St_ERROR;
                ELSE
                    next_state <= St_READ;
                END IF;
            WHEN St_READ_4 =>
                IF din = ("000" OR "111" OR "100") THEN
                    next_state <= St_ERROR;
                ELSE
                    next_state <= St_READ;
                END IF;
            WHEN St_READ_5 =>
                IF din = ("000" OR "111" OR "101") THEN
                    next_state <= St_ERROR;
                ELSE
                    next_state <= St_READ;
                END IF;
            WHEN St_READ_6 =>
                IF din = ("000" OR "111" OR "110") THEN
                    next_state <= St_ERROR;
                ELSE
                    next_state <= St_READ;
                END IF;
            WHEN St_checkend_1 =>
                IF din = "000" THEN
                    next_state <= St_checkend_2;
                ELSE
                    next_state <= St_ERROR;
                END IF;
            WHEN St_checkend_2 =>
                IF din = "111" THEN
                    next_state <= St_checkend_3;
                ELSE
                    next_state <= St_ERROR;
                END IF;
            WHEN St_checkend_3 =>
                IF din = "000" THEN
                    next_state <= St_WAIT;
                ELSE
                    next_state <= St_ERROR;
                END IF;
        END CASE;
    END PROCESS;
    output_logic : PROCESS (state)
    BEGIN
        dvalid <= '0';
        IF state = St_ERROR THEN
            error <= '1';
        ELSE
            error <= '0';
        END IF;
        IF state = St_READ_1 THEN
            IF din = "010" THEN
                dout <= "01000001";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "011" THEN
                dout <= "01000010";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "100" THEN
                dout <= "01000011";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "101" THEN
                dout <= "01000100";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "110" THEN
                dout <= "01000101";
                dvalid <= '1', '0' AFTER clkPeriod;
            END IF;
        END IF;
        IF state = St_READ_2 THEN
            IF din = "001" THEN
                dout <= "01000110";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "011" THEN
                dout <= "01000111";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "100" THEN
                dout <= "01001000";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "101" THEN
                dout <= "01001001";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "110" THEN
                dout <= "01001010";
                dvalid <= '1', '0' AFTER clkPeriod;
            END IF;
        END IF;
        IF state = St_READ_3 THEN
            IF din = "001" THEN
                dout <= "01001011";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "010" THEN
                dout <= "01001100";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "100" THEN
                dout <= "01001101";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "101" THEN
                dout <= "01001110";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "110" THEN
                dout <= "01001111"; --O
                dvalid <= '1', '0' AFTER clkPeriod;
            END IF;
        END IF;
        IF state = St_READ_4 THEN
            IF din = "001" THEN
                dout <= "01010000";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "010" THEN
                dout <= "01010001";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "011" THEN
                dout <= "01010010";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "101" THEN
                dout <= "01010011";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "110" THEN
                dout <= "01010100"; --T
                dvalid <= '1', '0' AFTER clkPeriod;
            END IF;
        END IF;
        IF state = St_READ_5 THEN
            IF din = "001" THEN
                dout <= "01010101";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "010" THEN
                dout <= "01010110";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "011" THEN
                dout <= "01010111";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "100" THEN
                dout <= "01011000";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "110" THEN
                dout <= "01011001"; --Y
                dvalid <= '1', '0' AFTER clkPeriod;
            END IF;
        END IF;
        IF state = St_READ_6 THEN
            IF din = "001" THEN
                dout <= "01011010";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "010" THEN
                dout <= "00100001";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "011" THEN
                dout <= "00101110";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "100" THEN
                dout <= "00111111";
                dvalid <= '1', '0' AFTER clkPeriod;
            ELSIF din = "101" THEN
                dout <= "00100000";
                dvalid <= '1', '0' AFTER clkPeriod;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;
