----------------------------------------------------------------------------------
-- Course: ELEC3342
-- Module Name: adccntrl - Behavioral
-- Project Name: mcdecoder_sys
-- Created By: Hayden So
--
-- Copyright (C) 2021  Hayden So
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY adccntrl IS
    PORT (
        csn : OUT STD_LOGIC;
        sclk : OUT STD_LOGIC;
        sdata : IN STD_LOGIC;
        data : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        clk : IN STD_LOGIC;
        clr : IN STD_LOGIC);
END adccntrl;

ARCHITECTURE Behavioral OF adccntrl IS

    SIGNAL cnt : unsigned (6 DOWNTO 0) := "0000000"; -- 128/4 = 32 32/2 = 16
    SIGNAL data_i : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000";
    SIGNAL dshift : STD_LOGIC;

    TYPE state_type IS (
        SIDLE, SZ3H, SXL, SXH
        --    SZ2L, SZ2H, SZ1L, SZ1H, SZ0L, SZ0H,
        --    SDB11L, SDB11H, SDB10L, SDB10H, 
        --    SDB9L, SDB9H, SDB8L, SDB8H, 
        --    SDB7L, SDB7H, SDB6L, SDB6H, 
        --    SDB5L, SDB5H, SDB4L, SDB4H, 
        --    SDB3L, SDB3H, SDB2L, SDB2H, 
        --    SDB1L, SDB1H, SDB0L, SDB0H,
        --    SQUIETL, SQUIETH
    );
    SIGNAL state, next_state : state_type;

BEGIN

    proc_out_data : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF clr = '1' THEN
                data <= (OTHERS => '0');
            ELSIF cnt = "100000" THEN
                data <= data_i;
            END IF;
        END IF;
    END PROCESS proc_out_data;

    proc_cnt : PROCESS (clk, clr)
    BEGIN
        IF clr = '1' THEN
            cnt <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            cnt <= cnt + 1;
        END IF;
    END PROCESS;

    proc_state : PROCESS (clk, clr)
    BEGIN
        IF (clr = '1') THEN
            state <= SIDLE;
        ELSIF (rising_edge(clk)) THEN
            state <= next_state;
        END IF;
    END PROCESS;

    proc_ns : PROCESS (state, cnt)
    BEGIN
        next_state <= state;
        CASE (state) IS
            WHEN SIDLE =>
                IF (cnt = "000000") THEN
                    next_state <= SZ3H;
                END IF;
            WHEN SZ3H =>
                next_state <= SXL;
            WHEN SXL =>
                next_state <= SXH;
            WHEN SXH =>
                IF (cnt = "100001") THEN
                    next_state <= SIDLE;
                ELSE
                    next_state <= SXL;
                END IF;
            WHEN OTHERS =>
                next_state <= SIDLE;
        END CASE;
    END PROCESS;

    -- output logic
    csn <= '1' WHEN state = SIDLE ELSE
        '0';
    sclk <= '0' WHEN state = SXL ELSE
        '1';
    dshift <= '1' WHEN state = SXL AND cnt /= "100000" ELSE
        '0';

    -- 12 bit shift register
    proc_shftreg : PROCESS (clk, clr)
    BEGIN
        IF (clr = '1') THEN
            data_i <= (OTHERS => '0');
        ELSIF (rising_edge(clk)) THEN
            IF (dshift = '1') THEN
                data_i <= data_i(10 DOWNTO 0) & sdata;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;