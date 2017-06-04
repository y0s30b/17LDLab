-- SKKU Logic Design Laboratory 2017
-- Term project x Class 44 x Team 3
-- TAXI Meter Calibrator
-- 2017 JUNE

-- part 1/4: TOP level
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TAXI is
    Port ( RESET : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           LCD_A : out  STD_LOGIC_VECTOR (1 downto 0);
           LCD_EN : out  STD_LOGIC;
           LCD_D : out  STD_LOGIC_VECTOR (7 downto 0);
           SW1 : in  STD_LOGIC;
           SW2 : in  STD_LOGIC;
           SW3 : in  STD_LOGIC;
           DIGIT : out  STD_LOGIC_VECTOR (6 downto 1);
           SEG_A : out  STD_LOGIC;
           SEG_B : out  STD_LOGIC;
           SEG_C : out  STD_LOGIC;
           SEG_D : out  STD_LOGIC;
           SEG_E : out  STD_LOGIC;
           SEG_F : out  STD_LOGIC;
           SEG_G : out  STD_LOGIC;
           SEG_DP : out  STD_LOGIC);
end TAXI;

architecture Behavioral of TAXI is
    -- < LCD와 7-segment에 표시할 정보들을 담는 내부 signal들 5가지 > --
    signal taxiCharge : std_logic_vector (15 downto 0);
    -- taxiCharge는 3000원부터 시작해 taxi 가격을 보여 준다.
    signal taxiChargeCnt : std_logic_vector (15 downto 0);
    -- taxiChargeCnt가 0이 되는 순간 taxiCharge 증가. 초기 상태에서 30000부터 count down.
    signal extraCharge : std_logic_vector (1 downto 0);
    -- 00%(="00"), 20%(="01"), 40%(="10")
    signal mileageM : std_logic_vector (12 downto 0);
    -- 최대 0x1FFF m(=8191 m)
    signal isCall : std_logic;
    -- Not Call(='0'), Call(='1')
begin
end Behavioral;


-- part 2/4: [LCD display part] CLK period = 20 ms (50 Hz frequency)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD_DISPLAY is 
    port ();
end LCD_DISPLAY;

architecture LCD_Behavioral of LCD_DISPLAY is
begin
end LCD_Behavioral;

-- part 3/4: [7-segment display part] CLK period = 512 ms
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SEG_DISPLAY is
    port ();
end SEG_DISPLAY;

architecture SEG_Behavioral of SEG_DISPLAY is
begin
end SEG_Behavioral;

-- part 4/4: [data processing part]
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DATA_PROCESS is
    port();
end DATA_PROCESS;

architecture DATA_Behavioral of DATA_PROCESS is
begin
end DATA_Behavioral;
