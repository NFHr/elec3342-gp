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
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC;
            rst : IN STD_LOGIC);
    END COMPONENT fifo_generator_0;

    -- SIGNAL debug_data_count : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL full : STD_LOGIC;
    SIGNAL wr_en : STD_LOGIC;

    SIGNAL empty : STD_LOGIC;
    SIGNAL rd_en : STD_LOGIC;

    SIGNAL wr_rst_busy : STD_LOGIC;
    SIGNAL rd_rst_busy : STD_LOGIC;

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
        wr_rst_busy => wr_rst_busy,
        rd_rst_busy => rd_rst_busy,
        rst => clr);
    
    rd_en <= NOT (empty OR uart_busy OR rd_rst_busy);
    wr_en <= NOT (full OR NOT mcd_wen OR wr_rst_busy);
    
    uart_wen <= rd_en;

END rtl;