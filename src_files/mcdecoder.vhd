LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mcdecoder IS
    PORT (
        din : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
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

    SIGNAL din_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
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
            din_reg <= "00000000";
            index <= "00";
        ELSIF rising_edge(clk) THEN
            IF valid = '1' THEN
                din_reg <= din_reg(3 DOWNTO 0) & din;
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

    NEXT_STATE_PROC : PROCESS (state, din_reg)
    BEGIN
        next_state <= state;
        CASE state IS
            WHEN St_WAIT =>
                IF din_reg = "00000111" THEN
                    next_state <= St_BOS_READY;
                END IF;
            WHEN St_BOS_READY =>
                IF index = "01" THEN
                    next_state <= St_BOS;
                END IF;
            WHEN St_BOS =>
                IF index = "10" THEN
                    IF din_reg = "00000111" THEN
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
                    IF din_reg = "01110000" THEN
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
                    IF din_reg = "01110000" THEN
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
        CASE state IS
            WHEN St_ERROR =>
                error <= '1';
                dvalid <= '0';
            WHEN St_VALID =>
                error <= '0';
                dvalid <= '1';
                CASE din_reg IS
                    WHEN "00010010" => dout <= "01000010";--B
                    WHEN "00010011" => dout <= "01000100";--D
                    WHEN "00010100" => dout <= "01001000";--H
                    WHEN "00010101" => dout <= "01001100";--L
                    WHEN "00010110" => dout <= "01010010";--R

                    WHEN "00100001" => dout <= "01000001";--A
                    WHEN "00100011" => dout <= "01000111";--G
                    WHEN "00100100" => dout <= "01001011";--K
                    WHEN "00100101" => dout <= "01010001";--Q
                    WHEN "00100110" => dout <= "01010110";--V

                    WHEN "00110001" => dout <= "01000011";--C
                    WHEN "00110010" => dout <= "01000110";--F
                    WHEN "00110100" => dout <= "01010000";--P
                    WHEN "00110101" => dout <= "01010101";--U
                    WHEN "00110110" => dout <= "01011010";--Z

                    WHEN "01000001" => dout <= "01000101";--E
                    WHEN "01000010" => dout <= "01001010";--J
                    WHEN "01000011" => dout <= "01001111";--O
                    WHEN "01000101" => dout <= "01011001";--Y
                    WHEN "01000110" => dout <= "00101110";--. 

                    WHEN "01010001" => dout <= "01001001";--I
                    WHEN "01010010" => dout <= "01001110";--N
                    WHEN "01010011" => dout <= "01010100";--T
                    WHEN "01010100" => dout <= "01011000";--X
                    WHEN "01010110" => dout <= "00111111";--?

                    WHEN "01100001" => dout <= "01001101";--M
                    WHEN "01100010" => dout <= "01010011";--S
                    WHEN "01100011" => dout <= "01010111";--W
                    WHEN "01100100" => dout <= "00100001";--!
                    WHEN "01100101" => dout <= "00100000";--SPACE

                        -- New mappings
                    WHEN "00011000" => dout <= "00101000";--(
                    WHEN "00101000" => dout <= "00101001";--)
                    WHEN "00111000" => dout <= "00111001";--9
                    WHEN "01001000" => dout <= "00111000";--8
                    WHEN "01011000" => dout <= "00110111";--7
                    WHEN "01101000" => dout <= "00110110";--6

                    WHEN "10000001" => dout <= "00110000";--0
                    WHEN "10000010" => dout <= "00110001";--1
                    WHEN "10000011" => dout <= "00110010";--2
                    WHEN "10000100" => dout <= "00110011";--3
                    WHEN "10000101" => dout <= "00110100";--4
                    WHEN "10000110" => dout <= "00110101";--5
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