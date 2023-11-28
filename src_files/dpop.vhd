LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;
ENTITY dpop IS
    PORT (
        mcd_din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        mcd_wen : IN STD_LOGIC;

        uart_dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        uart_busy : IN STD_LOGIC;
        uart_wen : OUT STD_LOGIC;

        clk : IN STD_LOGIC;
        clr : IN STD_LOGIC);
END dpop;

ARCHITECTURE rtl OF dpop IS
    COMPONENT fifo_generator_0 IS
        PORT (
            -- data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full : OUT STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            empty : OUT STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            rd_en : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC);
    END COMPONENT fifo_generator_0;

    -- SIGNAL debug_data_count : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL full : STD_LOGIC;
    
    SIGNAL wr_en : STD_LOGIC;

    SIGNAL srst : STD_LOGIC;

    SIGNAL empty : STD_LOGIC;
    SIGNAL rd_en : STD_LOGIC;

BEGIN
    fifo_inst : fifo_generator_0 PORT MAP(
        -- data_count => debug_data_count,
        full => full,
        din => mcd_din,
        wr_en => wr_en,
        empty => empty,
        dout => uart_dout,
        rd_en => rd_en,
        clk => clk,
        rst => srst);

    PROCESS (clr, clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF clr = '1' THEN
                srst <= '1';
            ELSE
                srst <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (empty, uart_busy)
    BEGIN
        IF empty = '0' AND uart_busy = '0' THEN
            rd_en <= '1';
            uart_wen <= '1';
        ELSE
            rd_en <= '0';
            uart_wen <= '0';
        END IF;
    END PROCESS;

    PROCESS (full, mcd_wen)
    BEGIN
        IF full = '0' AND mcd_wen = '1' THEN
            wr_en <= '1';
        ELSE
            wr_en <= '0';
        END IF;
    END PROCESS;

END rtl;