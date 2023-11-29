LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY myuart IS
    PORT (
        din : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        busy : OUT STD_LOGIC;
        wen : IN STD_LOGIC;
        sout : OUT STD_LOGIC;
        clr : IN STD_LOGIC;
        clk : IN STD_LOGIC
    );
END myuart;

ARCHITECTURE Behavioral OF myuart IS

    TYPE state_type IS (RESET, IDLE, START_BIT, DATA_BIT, STOP_BIT);
    SIGNAL state, next_state : state_type := IDLE;

    SIGNAL baud_en : STD_LOGIC := '0';

    SIGNAL din_idx : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL din_idx_clr : STD_LOGIC := '1';
    SIGNAL din_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL start : STD_LOGIC := '0';

BEGIN

    BAUD_SYNC_PROC : PROCESS (clk, clr)
        VARIABLE baud_count : INTEGER RANGE 0 TO 9 := 0;
    BEGIN
        IF clr = '1' THEN
            baud_en <= '0';
            baud_count := 0;
            start <= '0';
            din_idx <= 0;
        ELSIF rising_edge(clk) THEN
            IF din_idx_clr = '1' THEN
                din_idx <= 0;
            ELSIF baud_en = '1' THEN
                din_idx <= din_idx + 1;
            END IF;

            IF state = STOP_BIT THEN
                start <= '0';
            ELSIF wen = '1' AND start = '0' THEN
                start <= '1';
                din_reg <= din;
            END IF;

            IF baud_count = 9 THEN
                baud_en <= '1';
                baud_count := 0;
            ELSE
                baud_en <= '0';
                baud_count := baud_count + 1;
            END IF;
        END IF;
    END PROCESS;

    UART_SYNC_PROC : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            state <= IDLE;
        ELSIF rising_edge(clk) THEN
            state <= next_state;
        END IF;
    END PROCESS;

    UART_NEXT_STATE_PROC : PROCESS (state, baud_en, start, din_idx)
    BEGIN
        IF baud_en = '1' THEN
            CASE state IS
                WHEN IDLE =>
                    din_idx_clr <= '1';
                    IF start = '1' THEN
                        next_state <= START_BIT;
                    END IF;
                WHEN START_BIT =>
                    din_idx_clr <= '0';
                    next_state <= DATA_BIT;
                WHEN DATA_BIT =>
                    din_idx_clr <= '0';
                    IF din_idx = 7 THEN
                        din_idx_clr <= '1';
                        next_state <= STOP_BIT;
                    END IF;
                WHEN STOP_BIT =>
                    din_idx_clr <= '1';
                    next_state <= IDLE;
                WHEN OTHERS =>
                    next_state <= state;
            END CASE;
        END IF;
    END PROCESS;

    UART_OUTPUT_PROC : PROCESS (state)
    BEGIN
        CASE state IS
            WHEN IDLE =>
                busy <= '0';
                sout <= '1';
            WHEN START_BIT =>
                busy <= '1';
                sout <= '0';
            WHEN DATA_BIT =>
                busy <= '1';
                sout <= din_reg(din_idx);
            WHEN STOP_BIT =>
                busy <= '1';
                sout <= '1';
            WHEN OTHERS =>
                busy <= '0';
                sout <= '1';
        END CASE;
    END PROCESS;
END Behavioral;