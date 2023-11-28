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
        error : OUT STD_LOGIC;
        mcd_state : OUT STD_LOGIC_VECTOR(5 downto 0)
    );
END mcdecoder_stub;

ARCHITECTURE Behavioral OF mcdecoder_stub IS
BEGIN
    error <= '0';
    mcd_state <= (OTHERS => '0');
    
    PROCESS (clk, clr)
    BEGIN
        IF (clr = '1') THEN
            dvalid <= '0';
            dout <= "00100000";
        ELSIF rising_edge(clk) THEN
            IF (valid = '1') THEN
                dvalid <= '1';
                dout <= "00110" & din;
            ELSE
                dvalid <= '0';
                dout <= "00100000";
            END IF;
        END IF;
    END PROCESS;

END Behavioral;