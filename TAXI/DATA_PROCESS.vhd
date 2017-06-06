-- part 4/4: [data processing part]
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DATA_PROCESS is
    -- SW1~3¤ìœ„ì¹…ë ¥ë°›ì•„ 5ê°€ì§€ •ë³´ë¥œê³µ˜ëŠ” ´ë signalë¡ì¶œë ¥.
    port( RESET, CLK : in std_logic;
            SW1, SW2, SW3 : in std_logic;
            taxiCharge : out std_logic_vector(15 downto 0);
            taxiChargeCnt : out std_logic_vector(15 downto 0);
            extraCharge : out std_logic_vector(1 downto 0);
            mileageM : out std_logic_vector(12 downto 0);
            isCall : out std_logic;
            isPayment : out std_logic);
end DATA_PROCESS;

architecture DATA_Behavioral of DATA_PROCESS is
    signal processState : std_logic_vector(1 downto 0);
    -- "00": €ê¸ "01": "œìž‘", "10": "•ì"
    signal SW1_flag, SW2_flag, SW3_flag : std_logic;
    signal insSW1, insSW2, insSW3 : std_logic;

    signal taxiCharge_reg, taxiChargeCnt_reg : std_logic_vector(15 downto 0);
    signal extraCharge_reg : std_logic_vector(1 downto 0);
    signal mileageM_reg : std_logic_vector(12 downto 0);
    signal isCall_reg, isPayment_reg : std_logic;
begin
    taxiCharge <= taxiCharge_reg;
    taxiChargeCnt <= taxiChargeCnt_reg;
    extraCharge <= extraCharge_reg;
    mileageM <= mileageM_reg;
    isCall <= isCall_reg;
    isPayment <= isPayment_reg;

    process(SW1, SW2, SW3)
    -- switch inputê°ê°instruction signalë¡ë°”ê¿”ì£¼ëŠ” process ...1/2
    begin
        -- ¼ëŠ” œê°„ë°œìƒœí‚¤ê²ƒì´ë¯€ë¡active-LOë¡™ìž‘˜ëŠ” ¤ìœ„ì¹˜ì—œëŠ” '1'.
        if SW1 = '1' and SW1'event then
            SW1_flag <= '1';
        end if;
        if SW2 = '1' and SW2'event then
            SW2_flag <= '1';
        end if;
        if SW3 = '1' and SW3'event then
            SW3_flag <= '1';
        end if;
    end process;

    process(CLK)
    -- switch inputê°ê°instruction signalë¡ë°”ê¿”ì£¼ëŠ” process ...2/2
    begin
        if CLK = '0' and CLK'event then
        -- clk's falling edgeì„œ ¤ìŒ falling edgeê¹Œì 1 clock periodë§Œí¼
        -- instruction signalë³´ë‚´ì£¼ì–´¤ë¥¸ processì„œ clk's rising edge
        -- œëë¡ì²˜ë¦¬ˆìŒ.
            if SW1_flag = '1' then
                if insSW1 = '0' then 
                    insSW1 <= '1';
                elsif insSW1 = '1' then
                    insSW1 <= '0';
                    SW1_flag <= '0';
                end if;
            end if;
            if SW2_flag = '1' then
                if insSW2 = '0' then
                    insSW2 <= '1';
                elsif insSW2 = '1' then
                    insSW2 <= '0';
                    SW2_flag <= '0';
                end if;
            end if;
            if SW3_flag = '1' then
                if insSW3 = '0' then
                    insSW3 <= '1';
                elsif insSW3 = '1' then
                    insSW3 <= '0';
                    SW3_flag <= '0';
                end if;
            end if;
        end if;
    end process;

    process(RESET, CLK)
    -- SW1~3 í˜¸°ë¼ í•˜Œë¡œ ™ìž‘ê¸°ìˆ ˜ëŠ” process
    begin
        if RESET = '0' then
            processState <= "00";

            SW1_flag <= '0';
            SW2_flag <= '0';
            SW3_flag <= '0';
            
            insSW1 <= '0';
            insSW2 <= '0';
            insSw3 <= '0';
            
            taxiCharge_reg <= "0000101110111000";    -- decimal 3000
            taxiChargeCnt_reg <= "0111010100110000"; -- decimal 30000
            
            extraCharge_reg <= "00";
            mileageM_reg <= "0000000000000";
            isCall_reg <= '0';
            isPayment_reg <= '0';

        elsif CLK = '1' and CLK'event then
            if insSW1 = '1' then
                -- processState = "00"€ '€ê¸, "01"€ 'ì£¼í–‰', "10"€ '•ì'.
                -- stateê°€ "10"ì„œ "00"¼ë¡œ ˜ì–´ê°payment displayë¥„í•œ isPaymentë¥set.
                if processState = "00" or processState = "01" then
                    processState <= processState + 1;
                    isPayment_reg <= '0';
                elsif processState = "10" then
                    processState <= "00";
                    isPayment_reg <= '1';
                end if;
            end if;

            if insSW2 = '1' then
                -- ¸ì¶œ ¬ë ê²°ì •˜ëŠ”  í˜¸.
                isCall_reg <= '1';
            end if;
            
            if insSW3 = '1' then
                --  ì¦ % ê²°ì •˜ëŠ”  í˜¸.
                if extraCharge_reg = "00" or extraCharge_reg = "01" then
                    extraCharge_reg <= extraCharge_reg + 1;
                elsif extraCharge_reg = "10" then
                    extraCharge_reg <= "00";
                end if;
            end if;
        end if;
    end process;

    process(RESET, CLK)
    -- ì£¼í–‰ ëª¨ë“œ taxiChargeCnt€ mileageMì ˆclk ì£¼ê¸°°ë¼ ë³€ê²½í•˜ê³
    -- taxiChargeCntê°€ 0¼ë¡œ ¨ì–´ì§€œê°„ taxiChargeë¥ì¦êœí‚´(”ê¸ˆ ì¦ê).
        variable clk_cnt0 : std_logic_vector(11 downto 0);
    begin
        if RESET = '0' then
            clk_cnt0 := "000000000000";
        elsif CLK = '1' and CLK'event then
            if processState = "01" then
                -- ì£¼í–‰ ëª¨ë“œ

                if taxiChargeCnt_reg = "000000000000" then
                    taxiCharge_reg <= taxiCharge_reg + x"64"; -- 100ì¶”ê
                    taxiChargeCnt_reg <= "0001101110111000"; -- ì²30000 ´í›„ 3000¼ë¡œ count down
                elsif taxiChargeCnt_reg > "0000000000000000" then
                    if clk_cnt0 = "11111010000" then-- decimal 4000, 1 ms ì£¼ê¸° ë§Œë“¤ì£¼ê¸°
                        clk_cnt0 := "000000000000";
                        taxiChargeCnt_reg <= taxiChargeCnt_reg - 1;
                        -- 1 msë§ˆë‹¤ taxiChargeCnt ê°ì†Œœí‚´

                        -- ì£¼í–‰ ê±°ë¦¬ mileageMê´€ë¶€ë¶„ë„ ¬ê¸°ì¶”ê˜ê¸°
                        -- ì¶”êì¶”ê
                        -- ì¶”ê˜ì„¸
                    else
                        clk_cnt0 := clk_cnt0 + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end DATA_Behavioral;
