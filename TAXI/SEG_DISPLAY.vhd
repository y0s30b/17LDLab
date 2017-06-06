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
    signal sel_reg : std_logic_vector(2 downto 0);   -- 6개의 7-segment 중 어느 것에 출력할 지 결정.
    signal data_reg : std_logic_vector(3 downto 0);  -- segReg로 보내기 위한 data의 중간 단계.
    signal seg_reg : std_logic_vector(7 downto 0);   -- output SEG_X로 보내기 위한 signal.
    signal AA, BB, CC, DD, EE, FF : std_logic_vector(3 downto 0);
begin
    process(sel_reg)
	begin
		case sel_reg is		
		-- sel은 어느 7-segment에 값을 표시할 지 결정
		-- 6개의 7-segment가 있고 각 segment는 시, 분, 초를 부분적으로 담당함.
			when "000" =>	DIGIT <= "000001";
							data_reg <= AA;
			when "001" =>	DIGIT <= "000010";
							data_reg <= BB;
			when "010" =>	DIGIT <= "000100";
							data_reg <= CC;
			when "011" =>	DIGIT <= "001000";
							data_reg <= DD;
			when "100" =>	DIGIT <= "010000";
							data_reg <= EE;
			when "101" =>	DIGIT <= "100000";
							data_reg <= FF;
			when others => null;
		end case;
	end process;
	
	process(RESET, CLK)	
	-- display time every 50 us on 7-segment
	-- 50 us로 하면 사람 눈엔 stable한 걸로 보임!
		variable seg_clk_cnt : integer range 0 to 200;
	begin
		if RESET = '0' then
			sel_reg <= "000";
			seg_clk_cnt := 0;
		elsif CLK'event and CLK = '1' then
			if seg_clk_cnt = 200 then	-- 내장되어 있는 수정 진동자의 주파수가 4Mhz이고,
										-- 이는 0.25 us여서 200번 진동하면 50 us가 된다.
				seg_clk_cnt := 0;		-- 초기화 1
				
				if sel_reg = "101" then		-- 초기화 2
					sel_reg <= "000";
				else					-- 번갈아가며 sel_reg 결정(0~5)
					sel_reg <= sel_reg + 1;
				end if;
			else
				seg_clk_cnt := seg_clk_cnt + 1;
			end if;
		end if;
	end process;
	
	process(data_reg)		
	-- data는 sel로 선택된 7-segment에 출력할 '값'
	begin
		case data_reg is	-- dpgfedcba 순
			when "0000" => seg_reg <= "00111111";
			when "0001" => seg_reg <= "00000110";
			when "0010" => seg_reg <= "01011011";
			when "0011" => seg_reg <= "01001111";
			when "0100" => seg_reg <= "01100110";
			when "0101" => seg_reg <= "01101101";
			when "0110" => seg_reg <= "01111101";
			when "0111" => seg_reg <= "00100111";
			when "1000" => seg_reg <= "01111111";
			when "1001" => seg_reg <= "01101111";
			when others => null;
		end case;
	end process;
	SEG_A <= seg_reg(0);
	SEG_B <= seg_reg(1);
	SEG_C <= seg_reg(2);
	SEG_D <= seg_reg(3);
	SEG_E <= seg_reg(4);
	SEG_F <= seg_reg(5);
	SEG_G <= seg_reg(6);
	SEG_DP <= seg_reg(7);
	-- 각 7-segment별 출력 신호를 보낼 위치(segment 정보)를 signal seg에 저장한 후
	-- 이 signal의 값들을 회로 블록의 output으로 보낸다.

    process(RESET, CLK)
    -- taxiCharge가 16bit로 들어오는 걸 BCD로 바꾸어서 AA~FF로 내보내야 함
    -- 여기 부분에서 처리!!
    begin
    end process;
	
end SEG_Behavioral;
