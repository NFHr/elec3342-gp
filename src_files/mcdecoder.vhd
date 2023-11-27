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
        error : OUT STD_LOGIC
    );
END mcdecoder;

ARCHITECTURE behavioral OF mcdecoder IS

    TYPE state_type IS (St_WAIT, St_BOS, St_DECODE, St_VALID, St_EOS, St_ERROR);
    SIGNAL next_state, state : state_type := St_WAIT;

    SIGNAL digits : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL valid_buffer : STD_LOGIC;
    SIGNAL index, index_buffer : STD_LOGIC := '1';

BEGIN

    SYNC_DIGIT_INDEX : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            index <= '1';
        ELSIF rising_edge(clk) THEN
            index_buffer <= index;
            IF (valid = '1' AND valid_buffer = '0') THEN
                digits <= digits(2 DOWNTO 0) & din;
                index <= NOT index;
            END IF;
            valid_buffer <= valid;
        END IF;
    END PROCESS;

    SYNC_PROC : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            state <= St_WAIT;
        ELSIF rising_edge(clk) THEN
            state <= next_state;
        END IF;
    END PROCESS;

    NEXT_STATE_PROC : PROCESS (state, digits)
    BEGIN
        CASE state IS
            WHEN St_WAIT =>
                IF digits = "000111" THEN
                    next_state <= St_BOS;
                END IF;
            WHEN St_BOS =>
                IF (index = '1' AND index_buffer = '0') THEN
                    IF digits = "000111" THEN
                        next_state <= St_DECODE;
                    ELSE
                        next_state <= St_WAIT;
                    END IF;
                END IF;
            WHEN St_DECODE =>
                IF (index = '1' AND index_buffer = '0') THEN
                    IF digits = "111000" THEN
                        next_state <= St_EOS;
                    ELSE
                        next_state <= St_VALID;
                    END IF;
                END IF;
            WHEN St_VALID =>
                next_state <= St_DECODE;
            WHEN St_EOS =>
                IF (index = '1' AND index_buffer = '0') THEN
                    IF digits = "111000" THEN
                        next_state <= St_WAIT;
                    ELSE
                        next_state <= St_ERROR;
                    END IF;
                END IF;
            WHEN St_ERROR =>
                next_state <= St_WAIT;
            WHEN OTHERS =>
                next_state <= St_WAIT;
        END CASE;
    END PROCESS;

    OUTPUT_LOGIC : PROCESS (state)
    BEGIN
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

END behavioral;