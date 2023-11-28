----------------------------------------------------------------------------------
-- Course: ELEC3342
-- Module Name: clk_div - Behavioral
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

entity clk_div is
    Port (  clk_in      : in STD_LOGIC;
            locked      : in STD_LOGIC;
            clk_div128  : out STD_LOGIC);
end clk_div;

architecture rtl of clk_div is
    signal clk_divider: unsigned(6 downto 0) := "0000000";
begin

clk_div_proc: process(clk_in)
begin
    if (rising_edge(clk_in)) then
        if locked = '1' then
            clk_divider <= clk_divider + 1;
        end if;
    end if;  
end process;
clk_div128 <= clk_divider(6);

end rtl;
