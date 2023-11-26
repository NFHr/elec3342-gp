LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mcdecoder is
    port (
        din     : IN std_logic_vector(2 downto 0);
        valid   : IN std_logic;
        clr     : IN std_logic;
        clk     : IN std_logic;
        dout    : OUT std_logic_vector(7 downto 0);
        dvalid  : OUT std_logic;
        error   : OUT std_logic;
        state_err_debug : out std_logic;
        state_wait_debug : out std_logic;
        state_decode_debug : out std_logic;
        state_fin_debug : out std_logic;
        state_valid_debug : out std_logic
        );
end mcdecoder;

architecture Behavioral of mcdecoder is
  TYPE state_type IS (St_ERROR, St_WAIT_BOS, St_DECODE, St_DECODE_FIN, St_VALID);
  SIGNAL next_state, state : state_type;
  SIGNAL din_reg : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
  SIGNAL dout_cnt : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL dout_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN

  SYNC_PROC : PROCESS (clk, clr)
  BEGIN
    IF (clr = '1') THEN
      state <= St_WAIT_BOS;
    ELSIF rising_edge(clk) THEN
      state <= next_state;
    END IF;
  END PROCESS;

  NEXT_STATE_PROC : PROCESS (state, din_reg)
    VARIABLE eos_flag : STD_LOGIC := '0';
  BEGIN
    CASE state IS
      WHEN St_VALID =>
        next_state <= St_DECODE;
      WHEN St_ERROR =>
        next_state <= St_WAIT_BOS;
      WHEN St_WAIT_BOS =>
        IF din_reg = "000111000111" THEN
          next_state <= St_DECODE;
        END IF;
      WHEN St_DECODE =>
        IF dout_cnt = "01" THEN
          next_state <= St_DECODE_FIN;
        END IF;
      WHEN St_DECODE_FIN =>
        IF dout_cnt = "10" THEN
          next_state <= St_VALID;
          CASE din_reg(5 DOWNTO 0) IS
              --1x
            WHEN "001010" => dout_reg <= "01000010";--B
            WHEN "001011" => dout_reg <= "01000100";--D
            WHEN "001100" => dout_reg <= "01001000";--H
            WHEN "001101" => dout_reg <= "01001100";--L
            WHEN "001110" => dout_reg <= "01010010";--R
              --2x
            WHEN "010001" => dout_reg <= "01000001";--A
            WHEN "010011" => dout_reg <= "01000111";--G
            WHEN "010100" => dout_reg <= "01001011";--K
            WHEN "010101" => dout_reg <= "01010001";--Q
            WHEN "010110" => dout_reg <= "01010110";--V
              --3x
            WHEN "011001" => dout_reg <= "01000011";--C
            WHEN "011010" => dout_reg <= "01000110";--F
            WHEN "011100" => dout_reg <= "01010000";--P
            WHEN "011101" => dout_reg <= "01010101";--U
            WHEN "011110" => dout_reg <= "01011010";--Z
              --4x
            WHEN "100001" => dout_reg <= "01000101";--E
            WHEN "100010" => dout_reg <= "01001010";--J
            WHEN "100011" => dout_reg <= "01001111";--O
            WHEN "100101" => dout_reg <= "01011001";--Y
            WHEN "100110" => dout_reg <= "00101110";--. 
              --5x
            WHEN "101001" => dout_reg <= "01001001";--I
            WHEN "101010" => dout_reg <= "01001110";--N
            WHEN "101011" => dout_reg <= "01010100";--T
            WHEN "101100" => dout_reg <= "01011000";--X
            WHEN "101110" => dout_reg <= "00111111";--?
              --6x
            WHEN "110001" => dout_reg <= "01001101";--M
            WHEN "110010" => dout_reg <= "01010011";--S
            WHEN "110011" => dout_reg <= "01010111";--W
            WHEN "110100" => dout_reg <= "00100001";--!
            WHEN "110101" => dout_reg <= "00100000";--SPACE
            WHEN OTHERS =>
              IF din_reg(5 DOWNTO 0) = "111000" THEN
                IF eos_flag = '1' THEN
                  next_state <= St_WAIT_BOS;
                  eos_flag := '0';
                ELSE
                  eos_flag := '1';
                  next_state <= St_DECODE;
                END IF;
              ELSE
                next_state <= St_ERROR;
              END IF;
          END CASE;
        END IF;
      WHEN OTHERS => next_state <= state;
    END CASE;
  END PROCESS;

  DIN_PROC : PROCESS (valid)
  BEGIN
    IF valid = '1' THEN
      din_reg <= din_reg(8 DOWNTO 0) & din;
      IF state = St_DECODE THEN
        dout_cnt <= "01";
      ELSIF state = St_DECODE_FIN THEN
        dout_cnt <= "10";
      END IF;
    ELSE
      dout_cnt <= "00";
    END IF;
  END PROCESS;

  OUTPUT_PROC : PROCESS (state)
  BEGIN
    CASE state IS
      WHEN St_ERROR =>
        error <= '1';
        dvalid <= '0';
      WHEN St_VALID =>
        dout <= dout_reg;
        dvalid <= '1';
        error <= '0';
      WHEN OTHERS =>
        error <= '0';
        dvalid <= '0';
    END CASE;
  END PROCESS;
  
  DEBUG_PROC : process (state)
  begin
    state_err_debug <= '0';
    state_wait_debug <= '0';
    state_decode_debug <= '0';
    state_fin_debug <= '0';
    state_valid_debug <= '0';

    case state is
        when St_ERROR =>
            state_err_debug <= '1';
        when St_WAIT_BOS =>
            state_wait_debug <= '1';
        when St_DECODE =>
            state_decode_debug <= '1';
        when St_DECODE_FIN =>
            state_fin_debug <= '1';
        when St_VALID =>
            state_valid_debug <= '1';
    end case;
  end process;
end Behavioral;

