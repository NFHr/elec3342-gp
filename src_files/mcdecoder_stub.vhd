LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mcdecoder_stub is
    port (
        din     : IN std_logic_vector(2 downto 0);
        valid   : IN std_logic;
        clr     : IN std_logic;
        clk     : IN std_logic;
        dout    : OUT std_logic_vector(7 downto 0);
        dvalid  : OUT std_logic;
        error   : OUT std_logic;

        mcd_err : OUT STD_LOGIC;
        mcd_wait : OUT STD_LOGIC;
        mcd_decode : OUT STD_LOGIC;
        mcd_fin : OUT STD_LOGIC;
        mcd_valid : OUT STD_LOGIC
        );
end mcdecoder_stub;

architecture Behavioral of mcdecoder_stub is
  SIGNAL cnt : INTEGER;
BEGIN
    dout <= "01000001";
    error <= '0';

    proc_sample_cnt: process(clk, clr)
    begin
        if clr = '1' then
            dvalid <= '0';
            cnt <= 0;
        elsif rising_edge(clk) then
            if (cnt = 96000) then 
                dvalid <= '1';
                cnt <= 0;
            else 
                dvalid <= '0';
                cnt <= cnt + 1;
            end if;
        end if;
    end process proc_sample_cnt;
    
    mcd_err <= '1';
    mcd_wait <= '1';
    mcd_decode <= '1';
    mcd_fin <= '1';
    mcd_valid <= '1';

end Behavioral;

