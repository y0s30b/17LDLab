-- part 4/4: [data processing part]
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DATA_PROCESS is
    -- SW1~3�위칅력받아 5가지 �보륜공�는 �� signal�출
    port( RESET, CLK : in std_logic;
            SW1, SW2, SW3 : in std_logic;
            taxiCharge : out std_logic_vector(15 downto 0);
            taxiChargeCnt : out std_logic_vector(15 downto 0);
            extraCharge : out std_logic_vector(1 downto 0);
--            mileageM : out std_logic_vector(11 downto 0);
            isCall : out std_logic;
            isPayment : out std_logic;
				processState : out std_logic_vector(1 downto 0));
end DATA_PROCESS;

architecture DATA_Behavioral of DATA_PROCESS is
    signal processState_reg : std_logic_vector(1 downto 0);
    -- "00": �� "01": "�작", "10": "��"
    signal SW1_flag, SW2_flag, SW3_flag : std_logic;
    signal insSW1, insSW2, insSW3 : std_logic;

    signal taxiCharge_reg, taxiChargeCnt_reg : std_logic_vector(15 downto 0);
    signal extraCharge_reg : std_logic_vector(1 downto 0);
--    signal mileageM_reg : std_logic_vector(11 downto 0);
    signal isCall_reg, isPayment_reg : std_logic;

    signal SW1_flag_rst, SW2_flag_rst, SW3_flag_rst : std_logic;
	 signal isCall_add1000_flag : std_logic;
	 signal stop_check_flag : std_logic;
	 signal stop_check_flag2 : std_logic;
begin
    taxiCharge <= taxiCharge_reg;
    taxiChargeCnt <= taxiChargeCnt_reg;
    extraCharge <= extraCharge_reg;
--    mileageM <= mileageM_reg;
    isCall <= isCall_reg;
    isPayment <= isPayment_reg;
	 processState <= processState_reg;

    process(SW1, SW2, SW3, SW1_flag_rst, SW2_flag_rst, SW3_flag_rst)
    -- switch input각각instruction signal�바꿔주process ...1/2
    begin
        -- �는 �간발생�키것이므�active-LO롙작�는 �위치에�는 '1'.
        if SW1 = '1' and SW1'event then
            SW1_flag <= '1';
        end if;
        if SW2 = '1' and SW2'event then
            SW2_flag <= '1';
        end if;
        if SW3 = '1' and SW3'event then
            SW3_flag <= '1';
        end if;

        if SW1_flag_rst = '1' then
            SW1_flag <= '0';
        end if;
        if SW2_flag_rst = '1' then
            SW2_flag <= '0';
        end if;
        if SW3_flag_rst = '1' then
            SW3_flag <= '0';
        end if;
        
    end process;

    process(RESET, CLK)
    -- switch input각각instruction signal�바꿔주process ...2/2
    begin
        if RESET = '0' then
            SW1_flag_rst <= '1';
            SW2_flag_rst <= '1';
            SW3_flag_rst <= '1';

            insSW1 <= '0';
            insSW2 <= '0';
            insSw3 <= '0';
        elsif CLK = '0' and CLK'event then
        -- clk's falling edge�서 �음 falling edge까� 1 clock period만큼
        -- instruction signal보내주어�른 process�서 clk's rising edge
        -- ���처리�
            if SW1_flag_rst = '1' then
                SW1_flag_rst <= '0';
            end if;
            if SW2_flag_rst = '1' then
                SW2_flag_rst <= '0';
            end if;
            if SW3_flag_rst = '1' then
                SW3_flag_rst <= '0';
            end if;

            if SW1_flag = '1' then
                if insSW1 = '0' then 
                    insSW1 <= '1';
                elsif insSW1 = '1' then
                    insSW1 <= '0';
                    SW1_flag_rst <= '1';
                end if;
            end if;
            if SW2_flag = '1' then
                if insSW2 = '0' then
                    insSW2 <= '1';
                elsif insSW2 = '1' then
                    insSW2 <= '0';
                    SW2_flag_rst <= '1';
                end if;
            end if;
            if SW3_flag = '1' then
                if insSW3 = '0' then
                    insSW3 <= '1';
                elsif insSW3 = '1' then
                    insSW3 <= '0';
                    SW3_flag_rst <= '1';
                end if;
            end if;
        end if;
    end process;

    process(RESET, CLK)
    -- SW1~3�호�라 �하�로 �작기술�는 process
    begin
        if RESET = '0' then
            processState_reg <= "00";
            
            extraCharge_reg <= "00";
            isCall_reg <= '0';
            isPayment_reg <= '0';
				
				stop_check_flag <= '0';
        elsif CLK = '1' and CLK'event then
            if insSW1 = '1' then
                -- processState_reg = "00"�'��, "01"�'주행', "10"�'��'.
                -- state가 "10"�서 "00"�로 �어�payment display륄한 isPayment�set.
                if processState_reg = "00" or processState_reg = "01" then
                    processState_reg <= processState_reg + 1;
                    isPayment_reg <= '0';
						  
						  -- ���� state = "10" (=����)
						  if processState_reg = "01" then
								stop_check_flag <= '1';
						  end if;
                elsif processState_reg = "10" then
                    processState_reg <= "00";
                    isPayment_reg <= '1';
						  
						  -- ���� state = "00" (=���)
						  if stop_check_flag = '1' then
								extraCharge_reg <= "00";
								isCall_reg <= '0';
								isPayment_reg <= '0';
								
								stop_check_flag <= '0';
						  end if;
                end if;
            end if;

            if insSW2 = '1' then
                -- �출 �� 결정�는 �호.
                isCall_reg <= '1';
            end if;
            
            if insSW3 = '1' then
                -- �증 % 결정�는 �호.
                if extraCharge_reg = "00" or extraCharge_reg = "01" then
                    extraCharge_reg <= extraCharge_reg + 1;
                elsif extraCharge_reg = "10" then
                    extraCharge_reg <= "00";
                end if;
            end if;
        end if;
    end process;

    process(RESET, CLK)
    -- 주행 모드 taxiChargeCnt�mileageM�절clk 주기�라 변경하�
    -- taxiChargeCnt가 0�로 �어지�간 taxiCharge�증�킴(�금 증�).
        variable clk_cnt0 : std_logic_vector(11 downto 0);  -- �증 0%
        variable clk_cnt1 : std_logic_vector(11 downto 0);  -- �증 20%
        variable clk_cnt2 : std_logic_vector(11 downto 0);  -- �증 40%
    begin
        if RESET = '0' then
            clk_cnt0 := "000000000000";
            
            taxiCharge_reg <= "0000101110111000";    -- decimal 3000
            taxiChargeCnt_reg <= "0111010100110000"; -- decimal 30000
				
				stop_check_flag2 <= '0';

--            mileageM_reg <= "000000000000";
        elsif CLK = '1' and CLK'event then
            if processState_reg = "00" or processState_reg = "10" then
            -- �긕� 모드�서 '�출'버튼 �용 가
                if isCall_reg = '1' then
						  if isCall_add1000_flag = '0' then
							  taxiCharge_reg <= taxiCharge_reg + "0000001111101000";
							  isCall_add1000_flag <= '1';
						  end if;
                elsif isCall_reg = '0' then
						  isCall_add1000_flag <= '0';
					 end if;
					 
					 if processState_reg = "10" then
							stop_check_flag2 <= '1';
					 end if;
					 
					 if processState_reg = "00" and stop_check_flag2 = '1' then
							taxiCharge_reg <= "0000101110111000";    -- decimal 3000
							taxiChargeCnt_reg <= "0111010100110000"; -- decimal 30000
							stop_check_flag2 <= '0';
					 end if;
            elsif processState_reg = "01" then
            -- 주행 모드
                if taxiChargeCnt_reg = "000000000000" then
                    taxiCharge_reg <= taxiCharge_reg + x"64"; -- 100추�
                    taxiChargeCnt_reg <= "0001101110111000"; -- �0000 �후 3000�로 count down
                elsif taxiChargeCnt_reg > "0000000000000000" then
                    if extraCharge_reg = "00" then
                        if clk_cnt0 = "11111010000" then    -- decimal 4000, 1 ms 주기 만들주기 -- 0 추�!
                            clk_cnt0 := "000000000000";
                            taxiChargeCnt_reg <= taxiChargeCnt_reg - 1;
                            -- 1 ms마다 taxiChargeCnt 감소�킴
                        else
                            clk_cnt0 := clk_cnt0 + 1;
                        end if;
                    elsif extraCharge_reg = "01" then
                        if clk_cnt1 = "11001000000" then    -- decimal 3200 � �마taxiChargeCnt 감소 -- 0 추�!
                            clk_cnt1 := "000000000000";
                            taxiChargeCnt_reg <= taxiChargeCnt_reg - 1;
                        else
                            clk_cnt1 := clk_cnt1 + 1;
                        end if;
                    elsif extraCharge_reg = "10" then
                        if clk_cnt2 = "10010110000" then    -- decimal 2400 � �마taxiChargeCnt 감소 -- 0 추�!
                            clk_cnt2 := "000000000000";
                            taxiChargeCnt_reg <= taxiChargeCnt_reg - 1;
                        else
                            clk_cnt2 := clk_cnt2 + 1;
                        end if;
                    end if;
                        -- 주행 거리 mileageM관부분도 �기추��
                        -- 추�추�
                        -- 추�
                end if;
            end if;
        end if;
    end process;
end DATA_Behavioral;
