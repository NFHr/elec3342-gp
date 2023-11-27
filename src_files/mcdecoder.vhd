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

ARCHITECTURE Behavioral OF mcdecoder IS

  TYPE state_type IS (St_RESET, St_ERROR, St_WAIT_BOS, St_DECODE, St_DECODE_FIN, St_DECODE_OK);
  SIGNAL next_state, state : state_type := St_RESET;

  SIGNAL prev_valid : STD_LOGIC;
  SIGNAL digits : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL index, prev_index : STD_LOGIC := '1';

BEGIN

  SYNC_PROC : PROCESS (clk, clr)
  BEGIN
    IF clr = '1' THEN
      state <= St_RESET;
    ELSIF rising_edge(clk) THEN
      state <= next_state;
      prev_index <= index;
      IF (valid = '1' AND prev_valid = '0') THEN
        digits <= digits(2 DOWNTO 0) & din;
        index <= (state = St_RESET) ? '1' : NOT index;
      END IF;
      prev_valid <= valid;
    END IF;
  END PROCESS;

  NEXT_STATE_PROC : PROCESS (state, digits)
  BEGIN
    CASE(state) IS
      WHEN St_RESET =>
      IF digits = "000111" THEN
        nest_state <= St_STARTING;
      END IF;
      WHEN St_STARTING =>
      IF (index = '1' AND prev_index = '0') THEN
        IF digits = "000111" THEN
          next_state <= St_RESET;
        ELSE
          next_state <= St_ERROR;
        END IF;
      END IF;
      WHEN St_LISTENING =>
      IF (index = '1' AND prev_index = '0') THEN
        IF note_byte = "111000" THEN
          next_state <= St_ENDDING;
        ELSE
          next_state <= St_WRITING;
        END IF;
      END IF;
      WHEN St_WRITING => next_state <= St_LISTENING;
      WHEN St_ENDDING =>
      IF (index = '1' AND prev_index = '0') THEN
        IF note_byte = "111000" THEN
          next_state <= St_RESET;
        ELSE
          next_state <= St_ERROR;
        END IF;
      END IF;
      WHEN St_ERROR => next_state <= St_RESET;
      WHEN OTHERS => next_state <= St_RESET;
    END CASE;
  END PROCESS;

  OUTPUT_LOGIC : PROCESS (state)
  BEGIN
    CASE state IS
      WHEN St_ERROR =>
        error <= '1';
        dvalid <= '0';
      WHEN St_WRITING =>
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

          WHEN OTHERS => dout <= "00000000";
        END CASE;
      WHEN OTHERS =>
        error <= '0';
        dvalid <= '0';
    END CASE;
  END PROCESS;

END Behavioral;