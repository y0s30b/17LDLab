-- part 2/4: [LCD display part] CLK period = 20 ms (50 Hz frequency)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD_DISPLAY is 
    -- taxiCharge륜외4가지�보�LCD�출
    port ( RESET, CLK : in std_logic;
            LCD_A : out std_logic_vector(1 downto 0);
            LCD_EN : out std_logic;
            LCD_D : out std_logic_vector(7 downto 0);
            taxiChargeCnt : in std_logic_vector(15 downto 0);
            extraCharge : in std_logic_vector(1 downto 0);
--            mileageM : in std_logic_vector(11 downto 0);
            isCall : in std_logic;
            isPayment : in std_logic;
				processState : in std_logic_vector(1 downto 0));
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
	
	signal lcd_state : std_logic_vector (7 downto 0);
	signal lcd_nstate : std_logic_vector (7 downto 0);
	signal lcd_db : std_logic_vector (7 downto 0);
	
	signal human_clk : std_logic;
begin
	process(RESET,CLK,load_100k,cnt_100k) -- Clock(100kHz) Generator
	Begin
		if RESET = '0' then
			cnt_100k <= (others => '0');
			clk_100k <= '0';
		elsif CLK = '1' and CLK'event then
			if load_100k = '1' then
				cnt_100k <= (others => '0');
				clk_100k <= not clk_100k;
			else
				cnt_100k <= cnt_100k + 1;
			end if;
		end if;
	end process;
	load_100k <= '1' when (cnt_100k = X"13") else '0';

	process(RESET,clk_100k,load_50,cnt_50) -- Clock(50 Hz) Generator
	Begin
		if RESET = '0' then
			cnt_50 <= (others => '0');
			clk_50 <= '0';
		elsif clk_100k = '1' and clk_100k'event then
			if load_50 = '1' then
				cnt_50 <= (others => '0');
				clk_50 <= not clk_50;
			else
				cnt_50 <= cnt_50 + 1;
			end if;
		end if;
	end process;
	load_50 <= '1' when (cnt_50 = X"3E7") else '0'; -- 999
	
	process(RESET, CLK)
		variable count_clk : integer range 0 to 2000000;
	begin
		if RESET = '0' then
			count_clk := 0;
			human_clk <= '0';
		elsif CLK = '1' and CLK'event then
			count_clk := count_clk + 1;
			if count_clk = 2000000 then
				human_clk <= not human_clk;
				count_clk := 0;
			end if;
		end if;
	end process;

	process(RESET, clk_50)
	Begin
		if RESET = '0' then
			lcd_state <= (others =>'0');
		elsif clk_50 = '1' and clk_50'event then
			lcd_state <= lcd_nstate;
		end if;
	end process;
	w_enable_reg <= '0' when lcd_state < X"06" else '1';

	process(RESET, CLK, human_clk)
		variable tmp_chargeCnt : std_logic_vector(15 downto 0);
		variable bcd : UNSIGNED (19 downto 0) := (others => '0');

--		variable tmp_mileageM : std_logic_vector(11 downto 0);
--		variable bcd2 : UNSIGNED (15 downto 0) := (others => '0');
		
	Begin
		if RESET = '0' then
			for i in 0 to 31 loop
				reg_file(i) <= X"20";
			end loop;
		elsif CLK'event and CLK='1' then
--			if w_enable_reg ='1' and data_out ='1' then
--			if w_enable_reg = '1' then
--				reg_file(conv_integer(addr)) <= data;
--			end if;

			-- taxiChargeCnt 출력�는 부�
			bcd := (others => '0');
			tmp_chargeCnt := taxiChargeCnt;
			
			for i in 0 to 15 loop
				if bcd(3 downto 0) > 4 then 
					bcd(3 downto 0) := bcd(3 downto 0) + 3;
				end if;

				if bcd(7 downto 4) > 4 then 
					bcd(7 downto 4) := bcd(7 downto 4) + 3;
				end if;

				if bcd(11 downto 8) > 4 then  
					bcd(11 downto 8) := bcd(11 downto 8) + 3;
				end if;

				if bcd(15 downto 12) > 4 then
					bcd(15 downto 12) := bcd(15 downto 12) + 3;
				end if;

				bcd := bcd(18 downto 0) & tmp_chargeCnt(15);
				tmp_chargeCnt := tmp_chargeCnt(14 downto 0) & '0';
			end loop;

			reg_file(5) <= ("0000" & STD_LOGIC_VECTOR(bcd(3 downto 0))) + 48;
			reg_file(4) <= ("0000" & STD_LOGIC_VECTOR(bcd(7 downto 4))) + 48;
			reg_file(3) <= ("0000" & STD_LOGIC_VECTOR(bcd(11 downto 8))) + 48;
			reg_file(2) <= ("0000" & STD_LOGIC_VECTOR(bcd(15 downto 12))) + 48;
			reg_file(1) <= ("0000" & STD_LOGIC_VECTOR(bcd(19 downto 16))) + 48;
			
			-- CALL 문구 출력�는 부�
			if isCall = '1' then
				reg_file(7) <= "01000011";
				reg_file(8) <= "01000001";
				reg_file(9) <= "01001100";
				reg_file(10) <= "01001100";
			end if;

			-- extraCharge 출력�는 부�
			reg_file(23) <= "01000101";
			case extraCharge is
				when "00" => reg_file(24) <= "00000000" + 48;
				when "01" => reg_file(24) <= "00000010" + 48;
				when "10" => reg_file(24) <= "00000100" + 48;
				when others => null;
			end case;
			reg_file(25) <= "00000000" + 48;
			reg_file(26) <= "00100101";

			-- mileageM 출력�는 부�
--			bcd2 := (others => '0');
--			tmp_mileageM := mileageM;
			
--			for j in 0 to 11 loop
--				if bcd2(3 downto 0) > 4 then 
--					bcd2(3 downto 0) := bcd2(3 downto 0) + 3;
--				end if;

--				if bcd2(7 downto 4) > 4 then 
--					bcd2(7 downto 4) := bcd2(7 downto 4) + 3;
--				end if;

--				if bcd2(11 downto 8) > 4 then  
--					bcd2(11 downto 8) := bcd2(11 downto 8) + 3;
--				end if;

--				bcd2 := bcd2(14 downto 0) & tmp_mileageM(11);
--				tmp_mileageM := tmp_mileageM(10 downto 0) & '0';
--			end loop;

--			reg_file(20) <=  ("0000" & STD_LOGIC_VECTOR(bcd2(3 downto 0))) + 48;
--			reg_file(19) <=  ("0000" & STD_LOGIC_VECTOR(bcd2(7 downto 4))) + 48;
--			reg_file(18) <=  ("0000" & STD_LOGIC_VECTOR(bcd2(11 downto 8))) + 48;
--			reg_file(17) <=  ("0000" & STD_LOGIC_VECTOR(bcd2(15 downto 12))) + 48;
--			reg_file(21) <= "01101101";

			case processState is
			when "00" =>	reg_file(17) <= X"20";
								reg_file(18) <= "01010111";
								reg_file(19) <= "01000001";
								reg_file(20) <= "01001001";
								reg_file(21) <= "01010100";
			when "01" =>	reg_file(17) <= "01000100";
								reg_file(18) <= "01010010";
								reg_file(19) <= "01001001";
								reg_file(20) <= "01010110";
								reg_file(21) <= "01000101";
			when "10" =>	reg_file(17) <= X"20";
								reg_file(18) <= "01010011";
								reg_file(19) <= "01010100";
								reg_file(20) <= "01001111";
								reg_file(21) <= "01010000";
			when others => null;
			end case;

			if human_clk = '1' then
				reg_file(12) <= "00111110";
				reg_file(13) <= "00111110";
				reg_file(14) <= "10100101";
				reg_file(15) <= "10100101";
				
				reg_file(28) <= "10100101";
				reg_file(29) <= "00111110";
				reg_file(30) <= "00111110";
				reg_file(31) <= "10100101";
			elsif human_clk = '0' then
				reg_file(13) <= "00111110";
				reg_file(14) <= "00111110";
				reg_file(12) <= "10100101";
				reg_file(15) <= "10100101";
				
				reg_file(29) <= "10100101";
				reg_file(30) <= "00111110";
				reg_file(28) <= "00111110";
				reg_file(31) <= "10100101";
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
	LCD_A(0) <= '0' when (lcd_state >= X"00" and lcd_state < X"06") or (lcd_state = X"16")
							else '1';
	LCD_EN <= not clk_50; --LCD_EN <= '0' when w_enable_reg='0' else clk_100;
	LCD_D <= lcd_db; -- LCD display data
	--w_enable <= w_enable_reg;
end LCD_Behavioral;
