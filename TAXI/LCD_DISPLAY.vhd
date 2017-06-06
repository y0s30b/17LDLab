-- part 2/4: [LCD display part] CLK period = 20 ms (50 Hz frequency)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD_DISPLAY is 
    -- taxiCharge륜외4가지�보�LCD�출력.
    port ( RESET, CLK : in std_logic;
            LCD_A : out std_logic_vector(1 downto 0);
            LCD_EN : out std_logic;
            LCD_D : out std_logic_vector(7 downto 0);
            taxiChargeCnt : in std_logic_vector(15 downto 0);
            extraCharge : in std_logic_vector(1 downto 0);
            mileageM : in std_logic_vector(12 downto 0);
            isCall : in std_logic;
            isPayment : in std_logic);
end LCD_DISPLAY;

architecture LCD_Behavioral of LCD_DISPLAY is
	type reg is array( 0 to 31 ) of std_logic_vector( 7 downto 0 );

	signal reg_file : reg;
	signal w_enable_reg : std_logic;
	signal load_100k : std_logic;
	signal clk_100k : std_logic;
	signal cnt_100k : std_logic_vector (7 downto 0);
	signal load_50 : std_logic;
	signal clk_50 : std_logic;
	signal cnt_50 : std_logic_vector (11 downto 0);
	signal lcd_cnt : std_logic_vector (8 downto 0);
	signal lcd_state : std_logic_vector (7 downto 0);
	signal lcd_nstate : std_logic_vector (7 downto 0);
	signal lcd_db : std_logic_vector (7 downto 0);
begin
end LCD_Behavioral;
