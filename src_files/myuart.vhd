library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity myuart is
    Port (
           din : in STD_LOGIC_VECTOR (7 downto 0);
           busy: out STD_LOGIC;
           wen : in STD_LOGIC;
           sout : out STD_LOGIC;
           clr : in STD_LOGIC;
           clk : in STD_LOGIC;
           state_wait : out std_logic;
           state_sending : out std_logic;
           state_idle : out std_logic
           );
end myuart;

architecture rtl of myuart is
    type state_type is (WAIT_FOR_DATA, SEND_START_BIT, SEND_DATA_BIT_0, SEND_DATA_BIT_1, SEND_DATA_BIT_2, SEND_DATA_BIT_3, SEND_DATA_BIT_4, SEND_DATA_BIT_5, SEND_DATA_BIT_6, SEND_DATA_BIT_7, SEND_STOP_BIT);
    signal state, next_state : state_type := WAIT_FOR_DATA;
    signal din_reg : STD_LOGIC_VECTOR (7 downto 0);
    signal baud_counter: unsigned(3 downto 0) := (others => '0');   -- 9600/96kHz (1/10)
begin
    SYNC_PROC: process(clk)
    begin
        if clr = '1' then
            state <= WAIT_FOR_DATA;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;
    
    NEXT_STATE_DECODE: process(clk, wen)
    begin
        case state is
            when WAIT_FOR_DATA =>
                if wen = '1' then
                    next_state <= SEND_START_BIT;
                    
                end if;
            when SEND_START_BIT =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_DATA_BIT_0;
                    baud_counter <= (others => '0');
                end if;
            when SEND_DATA_BIT_0 =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_DATA_BIT_1;
                    baud_counter <= (others => '0');
                end if;
            when SEND_DATA_BIT_1 =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_DATA_BIT_2;
                    baud_counter <= (others => '0');
                end if;
            when SEND_DATA_BIT_2 =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_DATA_BIT_3;
                    baud_counter <= (others => '0');
                end if;
            when SEND_DATA_BIT_3 =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_DATA_BIT_4;
                    baud_counter <= (others => '0');
                end if;
            when SEND_DATA_BIT_4 =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_DATA_BIT_5;
                    baud_counter <= (others => '0');
                end if;
            when SEND_DATA_BIT_5 =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_DATA_BIT_6;
                    baud_counter <= (others => '0');
                end if;
            when SEND_DATA_BIT_6 =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_DATA_BIT_7;
                    baud_counter <= (others => '0');
                end if;
            when SEND_DATA_BIT_7 =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= SEND_STOP_BIT;
                    baud_counter <= (others => '0');
                end if;
            when SEND_STOP_BIT =>
                baud_counter <= baud_counter + 1;
                if baud_counter = "1001" then
                    next_state <= WAIT_FOR_DATA;
                    baud_counter <= (others => '0');
                end if;
            when others =>
                next_state <= WAIT_FOR_DATA;
            end case;
    end process;
    
    OUTPUT_DECODE : process(state)
    begin
        case state is
           when WAIT_FOR_DATA =>
                busy <= '0';
                sout <= '1';
            when SEND_START_BIT =>
                busy <= '1';
                sout <= '0';
            when SEND_DATA_BIT_0 =>
                busy <= '1';
                sout <= din_reg(0);
            when SEND_DATA_BIT_1 =>
                busy <= '1';
                sout <= din_reg(1);
            when SEND_DATA_BIT_2 =>
                busy <= '1';
                sout <= din_reg(2);
            when SEND_DATA_BIT_3 =>
                busy <= '1';
                sout <= din_reg(3);
            when SEND_DATA_BIT_4 =>
                busy <= '1';
                sout <= din_reg(4);
            when SEND_DATA_BIT_5 =>
                busy <= '1';
                sout <= din_reg(5);
            when SEND_DATA_BIT_6 =>
                busy <= '1';
                sout <= din_reg(6);
            when SEND_DATA_BIT_7 =>
                busy <= '1';
                sout <= din_reg(7);
            when SEND_STOP_BIT =>
                busy <= '1';
                sout <= '1';
            when others =>
                busy <= '0';
                sout <= '1';
            end case;
    end process;
    
    DEBUG_PROC : process (state)
        begin
          state_wait <= '0';
          state_sending <= '0';
          state_idle <= '0';
          case state is
            when WAIT_FOR_DATA =>
              state_wait <= '1';
            when SEND_START_BIT | SEND_DATA_BIT_0 | SEND_DATA_BIT_1 | SEND_DATA_BIT_2 | SEND_DATA_BIT_3 | SEND_DATA_BIT_4 | SEND_DATA_BIT_5 | SEND_DATA_BIT_6 | SEND_DATA_BIT_7 | SEND_STOP_BIT =>
              state_sending <= '1';
            when others =>
              null;
          end case;
        end process;
end rtl;
