-- part 4/4: [data processing part]
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DATA_PROCESS is
    -- SW1~3ÀÇ ½ºÀ§Ä¡ ÀÔ·ÂÀ» ¹Þ¾Æ 5°¡Áö Á¤º¸¸¦ Á¦°øÇÏ´Â ³»ºÎ signal·Î Ãâ·Â.
    port( RESET, CLK : in std_logic;
            SW1, SW2, SW3 : in std_logic;
            taxiCharge : out std_logic_vector(15 downto 0);
            taxiChargeCnt : out std_logic_vector(15 downto 0);
            extraCharge : out std_logic_vector(1 downto 0);
--            mileageM : out std_logic_vector(11 downto 0);
            isCall : out std_logic;
				processState : out std_logic_vector(1 downto 0));
end DATA_PROCESS;

architecture DATA_Behavioral of DATA_PROCESS is
    signal processState_reg : std_logic_vector(1 downto 0);
    -- "00": ´ë±â, "01": "½ÃÀÛ", "10": "Á¤Áö"
    signal SW1_flag, SW2_flag, SW3_flag : std_logic;
    signal insSW1, insSW2, insSW3 : std_logic;

    signal taxiCharge_reg, taxiChargeCnt_reg : std_logic_vector(15 downto 0);
    signal extraCharge_reg : std_logic_vector(1 downto 0);
--    signal mileageM_reg : std_logic_vector(11 downto 0);
    signal isCall_reg : std_logic;

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
	 processState <= processState_reg;

    process(SW1, SW2, SW3, SW1_flag_rst, SW2_flag_rst, SW3_flag_rst)
    -- switch inputÀ» °¢°¢ÀÇ instruction signal·Î ¹Ù²ãÁÖ´Â process ...1/2
    begin
        -- ¶¼´Â ¼ø°£¿¡ ¹ß»ý½ÃÅ°´Â °ÍÀÌ¹Ç·Î active-LO·Î µ¿ÀÛÇÏ´Â ½ºÀ§Ä¡¿¡¼­´Â '1'.
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
    -- switch inputÀ» °¢°¢ÀÇ instruction signal·Î ¹Ù²ãÁÖ´Â process ...2/2
    begin
        if RESET = '0' then
            SW1_flag_rst <= '1';
            SW2_flag_rst <= '1';
            SW3_flag_rst <= '1';

            insSW1 <= '0';
            insSW2 <= '0';
            insSw3 <= '0';
        elsif CLK = '0' and CLK'event then
        -- clk's falling edge¿¡¼­ ´ÙÀ½ falling edge±îÁö 1 clock period¸¸Å­
        -- instruction signalÀ» º¸³»ÁÖ¾î¾ß ´Ù¸¥ process¿¡¼­ clk's rising edgeÀÏ ¶§
        -- Á¦´ë·Î Ã³¸®ÇÒ ¼ö ÀÖÀ½.
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
    -- SW1~3ÀÇ ½ÅÈ£¿¡ µû¶ó ¿øÇÏ´Â È¸·Î µ¿ÀÛÀ» ±â¼úÇÏ´Â process
    begin
        if RESET = '0' then
            processState_reg <= "00";
            
            extraCharge_reg <= "00";
            isCall_reg <= '0';
				
				stop_check_flag <= '0';
        elsif CLK = '1' and CLK'event then
            if insSW1 = '1' then
                -- processState = "00"Àº '´ë±â', "01"Àº 'ÁÖÇà', "10"Àº 'Á¤Áö'.
                -- state°¡ "10"¿¡¼­ "00"À¸·Î ³Ñ¾î°¥ ¶§ payment display¸¦ À§ÇÑ isPayment¸¦ set.
                if processState_reg = "00" or processState_reg = "01" then
                    processState_reg <= processState_reg + 1;
						  
						  -- ´ÙÀ½ state = "10" (=Á¤Áö)
						  if processState_reg = "01" then
								stop_check_flag <= '1';
						  end if;
                elsif processState_reg = "10" then
                    processState_reg <= "00";
						  
						  -- ´ÙÀ½ state = "00" (=´ë±â)
						  if stop_check_flag = '1' then
								extraCharge_reg <= "00";
								isCall_reg <= '0';
								
								stop_check_flag <= '0';
						  end if;
                end if;
            end if;

            if insSW2 = '1' then
                -- È£Ãâ ¿©ºÎ °áÁ¤ÇÏ´Â ½ÅÈ£.
                isCall_reg <= '1';
            end if;
            
            if insSW3 = '1' then
                -- ÇÒÁõ % °áÁ¤ÇÏ´Â ½ÅÈ£.
                if extraCharge_reg = "00" or extraCharge_reg = "01" then
                    extraCharge_reg <= extraCharge_reg + 1;
                elsif extraCharge_reg = "10" then
                    extraCharge_reg <= "00";
                end if;
            end if;
        end if;
    end process;

    process(RESET, CLK)
    -- ÁÖÇà ¸ðµåÀÏ ¶§, taxiChargeCnt¿Í mileageMÀ» ÀûÀýÇÑ clk ÁÖ±â¿¡ µû¶ó º¯°æÇÏ°í
    -- taxiChargeCnt°¡ 0À¸·Î ¶³¾îÁö´Â ¼ø°£ taxiCharge¸¦ Áõ°¡½ÃÅ´(¿ä±Ý Áõ°¡).
        variable clk_cnt0 : std_logic_vector(11 downto 0);  -- ÇÒÁõ 0%
        variable clk_cnt1 : std_logic_vector(11 downto 0);  -- ÇÒÁõ 20%
        variable clk_cnt2 : std_logic_vector(11 downto 0);  -- ÇÒÁõ 40%
    begin
        if RESET = '0' then
            clk_cnt0 := "000000000000";
            
            taxiCharge_reg <= "0000101110111000";    -- decimal 3000
            taxiChargeCnt_reg <= "0111010100110000"; -- decimal 30000
				
				stop_check_flag2 <= '0';

--            mileageM_reg <= "000000000000";
        elsif CLK = '1' and CLK'event then
            if processState_reg = "00" or processState_reg = "10" then
            -- €´ë±â/Á¤Áö ¸ðµåÀÏ ¶§
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
            -- ÁÖÇà ¸ðµåÀÏ ¶§
                if taxiChargeCnt_reg = "000000000000" then
                    taxiCharge_reg <= taxiCharge_reg + x"64"; -- 100¿ø Ãß°¡
                    taxiChargeCnt_reg <= "0000101110111000"; -- Ã¹ 30000 ÀÌÈÄ 3000À¸·Î count down
                elsif taxiChargeCnt_reg > "0000000000000000" then
                    if extraCharge_reg = "00" then
                        if clk_cnt0 = "111110100000" then    -- decimal 4000, 1 ms ÁÖ±â ¸¸µé¾î ÁÖ±â
                            clk_cnt0 := "000000000000";
                            taxiChargeCnt_reg <= taxiChargeCnt_reg - 1;
                            -- 1 ms¸¶´Ù taxiChargeCnt °¨¼Ò½ÃÅ´
                        else
                            clk_cnt0 := clk_cnt0 + 1;
                        end if;
                    elsif extraCharge_reg = "01" then
                        if clk_cnt1 = "110010000000" then    -- decimal 3200 ¼¿ ¶§¸¶´Ù taxiChargeCnt °¨¼Ò
                            clk_cnt1 := "000000000000";
                            taxiChargeCnt_reg <= taxiChargeCnt_reg - 1;
                        else
                            clk_cnt1 := clk_cnt1 + 1;
                        end if;
                    elsif extraCharge_reg = "10" then
                        if clk_cnt2 = "100101100000" then    -- decimal 2400 ¼¿ ¶§¸¶´Ù taxiChargeCnt °¨¼Ò -- 0 Ãß°¡!
                            clk_cnt2 := "000000000000";
                            taxiChargeCnt_reg <= taxiChargeCnt_reg - 1;
                        else
                            clk_cnt2 := clk_cnt2 + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end DATA_Behavioral;
