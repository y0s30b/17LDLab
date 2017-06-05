-- part 3/4: [7-segment display part] CLK period = 512 ms
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SEG_DISPLAY is
    -- taxiCharge를 7-segment display로 출력.
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
            taxiCharge : in std_logic_vector(15 downto 0)
    );
end SEG_DISPLAY;

architecture SEG_Behavioral of SEG_DISPLAY is
 --   signal SEG_CLK : std_logic;
    signal selReg : std_logic_vector(2 downto 0);   -- 6개의 7-segment 중 어느 것에 출력할 지 결정.
    signal dataReg : std_logic_vector(3 downto 0);  -- segReg로 보내기 위한 data의 중간 단계.
    signal segReg : std_logic_vector(7 downto 0);   -- output SEG_X로 보내기 위한 signal.
begin
end SEG_Behavioral;
