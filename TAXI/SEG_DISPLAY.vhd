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
    signal SEG_CLK : std_logic;
begin
    process(RESET, CLK)
        variable seg_clk_cnt : integer range 0 to 200;
    begin
        if RESET = '0' then
        elsif CLK = '1' and CLK'event then
        end if;
    end process;
end SEG_Behavioral;
