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

	process(RESET,CLK,load_100k,cnt_100k) --Clock(100kHz) Generator
	Begin
		if RESET = '0' then
			cnt_100k <= (others => '0');
			clk_100k <= '0';
		elsif rising_edge (CLK) then
			if load_100k = '1' then
				cnt_100k <= (others => '0');
				clk_100k <= not clk_100k;
			else
				cnt_100k <= cnt_100k + 1;
			end if;
		end if;
	end process;
	load_100k <= '1' when (cnt_100k = X"13") else '0';

	process(RESET,clk_100k,load_50,cnt_50) --Clock(50 Hz) Generator
	Begin
		if RESET = '0' then
			cnt_50 <= (others => '0');
			clk_50 <= '0';
		elsif rising_edge (clk_100k) then
			if load_50 = '1' then
				cnt_50 <= (others => '0');
				clk_50 <= not clk_50;
			else
				cnt_50 <= cnt_50 + 1;
			end if;
		end if;
	end process;
	load_50 <= '1' when (cnt_50 = X"3E7") else '0'; -- 999

	process(RESET, clk_50)
	Begin
		if RESET = '0' then
			lcd_state <= (others =>'0');
		elsif rising_edge (clk_50) then
			lcd_state <= lcd_nstate;
		end if;
	end process;
	w_enable_reg <= '0' when lcd_state < X"06" else '1';

	process(RESET, CLK)
	Begin
		if RESET = '0' then
			for i in 0 to 31 loop
				reg_file(i) <= X"20";
			end loop;
		elsif CLK'event and CLK='1' then
			if w_enable_reg ='1' and data_out ='1' then
				reg_file(conv_integer(addr)) <= data;
			end if;
		end if;
	end process;

	process(RESET, lcd_state) -- lcd_state (X00~X26)
	Begin
		if RESET='0' then
			lcd_nstate <= X"00";
		else
			case lcd_state is
			when X"00" => lcd_db <= "00111000" ; -- Function set
			lcd_nstate <= X"01" ;
			when X"01" => lcd_db <= "00001000" ; -- Display OFF
			lcd_nstate <= X"02" ;
			when X"02" => lcd_db <= "00000001" ; -- Display clear
			lcd_nstate <= X"03" ;
			when X"03" => lcd_db <= "00000110" ; -- Entry mode set
			lcd_nstate <= X"04" ;
			when X"04" => lcd_db <= "00001100" ; -- Display ON
			lcd_nstate <= X"05" ;
			when X"05" => lcd_db <= "00000011" ; -- Return Home
			lcd_nstate <= X"06" ;
			when X"06" => lcd_db <= reg_file(0) ;
			lcd_nstate <= X"07" ;
			when X"07" => lcd_db <= reg_file(1) ;
			lcd_nstate <= X"08" ;
			when X"08" => lcd_db <= reg_file(2) ;
			lcd_nstate <= X"09" ;
			when X"09" => lcd_db <= reg_file(3) ;
			lcd_nstate <= X"0A" ;
			when X"0A" => lcd_db <= reg_file(4) ;
			lcd_nstate <= X"0B" ;
			when X"0B" => lcd_db <= reg_file(5) ;
			lcd_nstate <= X"0C" ;
			when X"0C" => lcd_db <= reg_file(6) ;
			lcd_nstate <= X"0D" ;
			when X"0D" => lcd_db <= reg_file(7) ;
			lcd_nstate <= X"0E" ;
			when X"0E" => lcd_db <= reg_file(8) ;
			lcd_nstate <= X"0F" ;
			when X"0F" => lcd_db <= reg_file(9) ;
			lcd_nstate <= X"10" ;
			when X"10" => lcd_db <= reg_file(10) ;
			lcd_nstate <= X"11" ;
			when X"11" => lcd_db <= reg_file(11) ;
			lcd_nstate <= X"12" ;
			when X"12" => lcd_db <= reg_file(12) ;
			lcd_nstate <= X"13" ;
			when X"13" => lcd_db <= reg_file(13) ;
			lcd_nstate <= X"14" ;
			when X"14" => lcd_db <= reg_file(14) ;
			lcd_nstate <= X"15" ;
			when X"15" => lcd_db <= reg_file(15) ;
			lcd_nstate <= X"16" ;
			when X"16" => lcd_db <= X"C0" ; -- Change Line
			lcd_nstate <= X"17" ;
			when X"17" => lcd_db <= reg_file(16) ;
			Lcd_nstate <= X"18" ;
			when X"18" => lcd_db <= reg_file(17) ;
			lcd_nstate <= X"19" ;
			when X"19" => lcd_db <= reg_file(18) ;
			lcd_nstate <= X"1A" ;
			when X"1A" => lcd_db <= reg_file(19) ;
			lcd_nstate <= X"1B" ;
			when X"1B" => lcd_db <= reg_file(20) ;
			lcd_nstate <= X"1C" ;
			when X"1C" => lcd_db <= reg_file(21) ;
			lcd_nstate <= X"1D" ;
			when X"1D" => lcd_db <= reg_file(22) ;
			lcd_nstate <= X"1E" ;
			when X"1E" => lcd_db <= reg_file(23) ;
			lcd_nstate <= X"1F" ;
			when X"1F" => lcd_db <= reg_file(24) ;
			lcd_nstate <= X"20" ;
			when X"20" => lcd_db <= reg_file(25) ;
			lcd_nstate <= X"21" ;
			when X"21" => lcd_db <= reg_file(26) ;
			lcd_nstate <= X"22" ;
			when X"22" => lcd_db <= reg_file(27) ;
			lcd_nstate <= X"23" ;
			when X"23" => lcd_db <= reg_file(28) ;
			lcd_nstate <= X"24" ;
			when X"24" => lcd_db <= reg_file(29) ;
			lcd_nstate <= X"25" ;
			when X"25" => lcd_db <= reg_file(30) ;
			lcd_nstate <= X"26" ;
			when X"26" => lcd_db <= reg_file(31) ;
			lcd_nstate <= X"05" ; -- return home
			when others => lcd_db <= (others => '0') ;
			end case;
		end if;
	end process;

	LCD_A(1) <= '0';
	LCD_A(0) <= '0' when (lcd_state >= X"00" and lcd_state < X"06") or (lcd_state =X"16")
							else '1';
	LCD_EN <= clk_50; --LCD_EN <= '0' when w_enable_reg='0' else clk_100;
	LCD_D <= lcd_db; -- LCD display data
	w_enable <= w_enable_reg;

    process(RESET, CLK)
    begin
    end process;
end LCD_Behavioral;
