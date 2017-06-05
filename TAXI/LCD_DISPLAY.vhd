-- part 2/4: [LCD display part] CLK period = 20 ms (50 Hz frequency)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD_DISPLAY is 
    -- taxiCharge를 제외한 4가지의 정보를 LCD로 출력.
    port ( RESET, CLK : in std_logic;
            LCD_A : out std_logic_vector(1 downto 0);
            LCD_EN : out std_logic;
            LCD_D : out std_logic_vector(7 downto 0);
            taxiChargeCnt : in std_logic_vector(15 downto 0);
            extraCharge : in std_logic_vector(1 downto 0);
            mileageM : in std_logic_vector(12 downto 0);
            isCall : in std_logic);
end LCD_DISPLAY;

architecture LCD_Behavioral of LCD_DISPLAY is
    signal LCD_CLK : std_logic;
begin
end LCD_Behavioral;
