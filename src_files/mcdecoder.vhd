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

        mcd_state : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
    );
END mcdecoder;

ARCHITECTURE rtl OF mcdecoder IS

    TYPE state_type IS (St_WAIT, St_BOS_READY, St_BOS, St_DECODE_READY, St_DECODE, St_EOS_READY, St_EOS, St_VALID, St_ERROR);

    SIGNAL next_state, state : state_type := St_WAIT;

    SIGNAL digits : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL index : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

    SYNC_PROC : PROCESS (clk, clr)
    BEGIN
        IF (clr = '1') THEN
            state <= St_WAIT;
        ELSIF rising_edge(clk) THEN
            state <= next_state;
        END IF;
    END PROCESS;

    SYNC_NEXT_PROC : PROCESS (clr, clk)
    BEGIN
        IF (clr = '1') THEN
            digits <= "000000";
            index <= "00";
        ELSIF rising_edge(clk) THEN
            IF valid = '1' THEN
                digits <= digits(2 DOWNTO 0) & din;
                CASE state IS
                    WHEN St_BOS_READY | St_DECODE_READY | St_EOS_READY =>
                        index <= "01";
                    WHEN St_BOS | St_DECODE | St_EOS =>
                        index <= "10";
                    WHEN OTHERS =>
                        index <= "00";
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    NEXT_STATE_PROC : PROCESS (state, digits)
    BEGIN
        next_state <= state;
        CASE state IS
            WHEN St_WAIT =>
                IF digits = "000111" THEN
                    next_state <= St_BOS_READY;
                END IF;
            WHEN St_BOS_READY =>
                IF index = "01" THEN
                    next_state <= St_BOS;
                END IF;
            WHEN St_BOS =>
                IF index = "10" THEN
                    IF digits = "000111" THEN
                        next_state <= St_DECODE_READY;
                    ELSE
                        next_state <= St_WAIT;
                    END IF;
                END IF;
            WHEN St_DECODE_READY =>
                IF index = "01" THEN
                    next_state <= St_DECODE;
                END IF;
            WHEN St_DECODE =>
                IF index = "10" THEN
                    IF digits = "111000" THEN
                        next_state <= St_EOS_READY;
                    ELSE
                        next_state <= St_VALID;
                    END IF;
                END IF;
            WHEN St_EOS_READY =>
                IF index = "01" THEN
                    next_state <= St_EOS;
                END IF;
            WHEN St_EOS =>
                IF index = "10" THEN
                    IF digits = "111000" THEN
                        next_state <= St_WAIT;
                    ELSE
                        next_state <= St_ERROR;
                    END IF;
                END IF;
            WHEN St_VALID =>
                next_state <= St_DECODE_READY;
            WHEN St_ERROR =>
                next_state <= St_WAIT;
            WHEN OTHERS =>
                next_state <= state;
        END CASE;
    END PROCESS;

    OUTPUT_PROC : PROCESS (state)
    BEGIN
        dout <= (OTHERS => '0');
        CASE state IS
            WHEN St_ERROR =>
                error <= '1';
                dvalid <= '0';
            WHEN St_VALID =>
                error <= '0';
                dvalid <= '1';
                CASE digits IS
                    WHEN "001010" => dout <= "01000010";--B
                    WHEN "001011" => dout <= "01000100";--D
                    WHEN "001100" => dout <= "01001000";--H
                    WHEN "001101" => dout <= "01001100";--L
                    WHEN "001110" => dout <= "01010010";--R

                    WHEN "010001" => dout <= "01000001";--A
                    WHEN "010011" => dout <= "01000111";--G
                    WHEN "010100" => dout <= "01001011";--K
                    WHEN "010101" => dout <= "01010001";--Q
                    WHEN "010110" => dout <= "01010110";--V

                    WHEN "011001" => dout <= "01000011";--C
                    WHEN "011010" => dout <= "01000110";--F
                    WHEN "011100" => dout <= "01010000";--P
                    WHEN "011101" => dout <= "01010101";--U
                    WHEN "011110" => dout <= "01011010";--Z

                    WHEN "100001" => dout <= "01000101";--E
                    WHEN "100010" => dout <= "01001010";--J
                    WHEN "100011" => dout <= "01001111";--O
                    WHEN "100101" => dout <= "01011001";--Y
                    WHEN "100110" => dout <= "00101110";--. 

                    WHEN "101001" => dout <= "01001001";--I
                    WHEN "101010" => dout <= "01001110";--N
                    WHEN "101011" => dout <= "01010100";--T
                    WHEN "101100" => dout <= "01011000";--X
                    WHEN "101110" => dout <= "00111111";--?

                    WHEN "110001" => dout <= "01001101";--M
                    WHEN "110010" => dout <= "01010011";--S
                    WHEN "110011" => dout <= "01010111";--W
                    WHEN "110100" => dout <= "00100001";--!
                    WHEN "110101" => dout <= "00100000";--SPACE

                    WHEN OTHERS => dvalid <= '0';
                END CASE;
            WHEN OTHERS =>
                error <= '0';
                dvalid <= '0';
        END CASE;
    END PROCESS;

    DEBUG_PROCESS : PROCESS (state)
    BEGIN
        CASE state IS
            WHEN St_WAIT => mcd_state <= "000001";
            WHEN St_BOS_READY | St_BOS => mcd_state <= "000010";
            WHEN St_DECODE_READY | St_DECODE => mcd_state <= "000100";
            WHEN St_EOS_READY | St_EOS => mcd_state <= "001000";
            WHEN St_VALID => mcd_state <= "010000";
            WHEN St_ERROR => mcd_state <= "100000";
            WHEN OTHERS => mcd_state <= "000000";
        END CASE;
    END PROCESS;

END rtl;