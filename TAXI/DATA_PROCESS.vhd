-- part 4/4: [data processing part]
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DATA_PROCESS is
    -- SW1~3의 스위치 입력을 받아 5가지 정보를 제공하는 내부 signal로 출력.
    port( RESET, CLK : in std_logic;
            SW1, SW2, SW3 : in std_logic;
            taxiCharge : out std_logic_vector(15 downto 0);
            taxiChargeCnt : out std_logic_vector(15 downto 0);
            extraCharge : out std_logic_vector(1 downto 0);
            mileageM : out std_logic_vector(12 downto 0);
            isCall : out std_logic
            isPayment);
end DATA_PROCESS;

architecture DATA_Behavioral of DATA_PROCESS is
    signal processState : std_logic_vector(1 downto 0) := "00";
    -- "00": 대기, "01": "시작", "10": "정지", "11": "정산" 
    signal SW1_flag, SW2_flag, SW3_flag : std_logic := '0';
    signal insSW1, insSW2, insSW3 : std_logic := '0';
begin
    process(SW1, SW2, SW3)
    -- switch input을 각각의 instruction signal로 바꿔주는 process ...1/2
    begin
        -- 떼는 순간에 발생시키는 것이므로 active-LO로 동작하는 스위치에서는 '1'.
        if SW1 = '1' and SW1'event then
            SW1_flag <= '1';
        end if;
        if SW2 = '1' and SW2'event then
            SW2_flag <= '1';
        end if;
        if SW3 = '1' and SW3'event then
            SW3_flag <= '1';
        end if;
    end process;

    process(CLK)
    -- switch input을 각각의 instruction signal로 바꿔주는 process ...2/2
    begin
        if CLK = '0' and CLK'event then
        -- clk's falling edge에서 다음 falling edge까지 1 clock period만큼
        -- instruction signal을 보내주어야 다른 process에서 clk's rising edge일 때
        -- 제대로 처리할 수 있음.
            if SW1_flag = '1' then
                if insSW1 = '0' then 
                    insSW1 <= '1';
                elsif insSW1 = '1' then
                    insSW1 <= '0';
                    SW1_flag <= '0';
                end if;
            end if;
            if SW2_flag = '1' then
                if insSW2 = '0' then
                    insSW2 <= '1';
                elsif insSW2 = '1' then
                    insSW2 <= '0';
                    SW2_flag <= '0';
                end if;
            end if;
            if SW3_flag = '1' then
                if insSW3 = '0' then
                    insSW3 <= '1';
                elsif insSW3 = '1' then
                    insSW3 <= '0';
                    SW3_flag <= '0';
                end if;
            end if;
        end if;
    end process;

    
end DATA_Behavioral;
