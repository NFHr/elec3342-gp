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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adccntrl is
    Port (  csn : out STD_LOGIC;
            sclk : out STD_LOGIC;
            sdata : in STD_LOGIC;
            data : out STD_LOGIC_VECTOR(11 DOWNTO 0);
            clk : in STD_LOGIC;
            clr : in STD_LOGIC);
end adccntrl;

architecture Behavioral of adccntrl is

signal cnt: unsigned (6 downto 0) := "0000000"; -- 128/4 = 32 32/2 = 16
signal data_i: std_logic_vector(11 downto 0) := "000000000000";
signal dshift: std_logic;

type state_type is (
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
signal state, next_state : state_type;

begin

proc_out_data: process(clk)
begin
    if rising_edge(clk) then
        if clr = '1' then
            data <= (others => '0');
        elsif cnt = "100000" then
            data <= data_i;
        end if;
    end if;
end process proc_out_data;

proc_cnt: process (clk, clr)
begin
    if clr = '1' then
        cnt <= (others=>'0');
    elsif (rising_edge(clk)) then
        cnt <= cnt + 1;
    end if;
end process;

proc_state: process (clk, clr)
begin
    if (clr = '1') then
        state <= SIDLE;
    elsif (rising_edge(clk)) then
        state <= next_state;
    end if;
end process;

proc_ns: process (state, cnt)
begin
    next_state <= state;
    case (state) is
    when SIDLE =>
        if (cnt = "000000") then
            next_state <= SZ3H;
        end if;
    when SZ3H =>
        next_state <= SXL;
    when SXL =>
        next_state <= SXH;
    when SXH =>
        if (cnt = "100001") then
            next_state <= SIDLE;
        else
            next_state <= SXL;
        end if;
    when OTHERS =>
        next_state <= SIDLE;
    end case;
end process;

-- output logic
csn <= '1' when state = SIDLE else '0';
sclk <= '0' when state = SXL else '1';
dshift <= '1' when state = SXL and cnt /= "100000" else '0';

-- 12 bit shift register
proc_shftreg : process (clk, clr)
begin
    if (clr = '1') then
        data_i <= (others => '0');
    elsif (rising_edge(clk)) then
        if (dshift = '1') then
            data_i <= data_i(10 downto 0) & sdata;
        end if;
    end if;
end process;


end Behavioral;
