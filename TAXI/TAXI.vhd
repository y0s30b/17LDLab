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
    -- component of LCD_DISPLAY: taxiCharge �외4가지 �보�LCD출력.
    component LCD_DISPLAY is
        port ( RESET, CLK : in std_logic;
            LCD_A : out std_logic_vector(1 downto 0);
            LCD_EN : out std_logic;
            LCD_D : out std_logic_vector(7 downto 0);
            taxiChargeCnt : in std_logic_vector(15 downto 0);
            extraCharge : in std_logic_vector(1 downto 0);
            mileageM : in std_logic_vector(12 downto 0);
            isCall : in std_logic;
				isPayment : in std_logic);
    end component;

    -- component of SEG_DISPLAY: taxiCharge �보�7-segment출력.
    component SEG_DISPlAY is
        port ( RESET, CLK : in std_logic;
            DIGIT : out std_logic_vector(6 downto 1);
            SEG_A : out std_logic;
            SEG_B : out std_logic;
            SEG_C : out std_logic;
            SEG_D : out std_logic;
            SEG_E : out std_logic;
            SEG_F : out std_logic;
            SEG_G : out std_logic;
            SEG_DP : out std_logic;
            taxiCharge : in std_logic_vector(15 downto 0));
    end component;

    -- component of DATA_PROCESS: SW1~3 �위칅력�라 5가지 �보 �성.
    component DATA_PROCESS is
        port( RESET, CLK : in std_logic;
            SW1, SW2, SW3 : in std_logic;
            taxiCharge : out std_logic_vector(15 downto 0);
            taxiChargeCnt : out std_logic_vector(15 downto 0);
            extraCharge : out std_logic_vector(1 downto 0);
            mileageM : out std_logic_vector(12 downto 0);
            isCall : out std_logic;
				isPayment : out std_logic);
    end component;

    -- < LCD� 7-segment�시�보�을 �는 �� signal5가지 > --
    signal taxiCharge : std_logic_vector (15 downto 0);
    -- taxiCharge3000��작taxi 가격을 보여 준
    signal taxiChargeCnt : std_logic_vector (15 downto 0);
    -- taxiChargeCnt가 0�는 �간 taxiCharge 증�. 초기 �태�서 30000부count down.
    signal extraCharge : std_logic_vector (1 downto 0);
    -- 00%(="00"), 20%(="01"), 40%(="10")
    signal mileageM : std_logic_vector (12 downto 0);
    -- 최� 0x1FFF m(=8191 m)
    signal isCall : std_logic;
    -- Not Call(='0'), Call(='1')
    signal isPayment : std_logic;
    -- isPayment = '1'� 10, 11벌로 �성최종 �산 �면�우�호�다.
begin
    LCD : LCD_DISPLAY port map (RESET, CLK, LCD_A, LCD_EN, LCD_D, taxiChargeCnt, extraCharge, mileageM, isCall, isPayment);
    SEG : SEG_DISPLAY port map (RESET, CLK, DIGIT, SEG_A, SEG_B, SEG_C, SEG_D, SEG_E, SEG_F, SEG_G, SEG_DP, taxiCharge);
    DATA : DATA_PROCESS port map (RESET, CLK, SW1, SW2, SW3, taxiCharge, taxiChargeCnt, extraCharge, mileageM, isCall, isPayment);
end Behavioral;
