-- part 3/4: [7-segment display part] CLK period = 512 ms
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SEG_DISPLAY is
    -- taxiCharge�� 7-segment display�� ���.
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
    signal sel_reg : std_logic_vector(2 downto 0);   -- 6���� 7-segment �� ��� �Ϳ� ����� �� ����.
    signal data_reg : std_logic_vector(3 downto 0);  -- segReg�� ������ ���� data�� �߰� �ܰ�.
    signal seg_reg : std_logic_vector(7 downto 0);   -- output SEG_X�� ������ ���� signal.
    signal AA, BB, CC, DD, EE, FF : std_logic_vector(3 downto 0);
begin
   process(sel_reg)
	begin
		case sel_reg is		
		-- sel�� ��� 7-segment�� ���� ǥ���� �� ����
		-- 6���� 7-segment�� �ְ� �� segment�� ��, ��, �ʸ� �κ������� �����.
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
	-- 50 us�� �ϸ� ��� ���� stable�� �ɷ� ����!
		variable seg_clk_cnt : integer range 0 to 200;
	begin
		if RESET = '0' then
			sel_reg <= "000";
			seg_clk_cnt := 0;
		elsif CLK'event and CLK = '1' then
			if seg_clk_cnt = 200 then	-- ����Ǿ� �ִ� ���� �������� ���ļ��� 4Mhz�̰�,
										-- �̴� 0.25 us���� 200�� �����ϸ� 50 us�� �ȴ�.
				seg_clk_cnt := 0;		-- �ʱ�ȭ 1
				
				if sel_reg = "101" then		-- �ʱ�ȭ 2
					sel_reg <= "000";
				else					-- �����ư��� sel_reg ����(0~5)
					sel_reg <= sel_reg + 1;
				end if;
			else
				seg_clk_cnt := seg_clk_cnt + 1;
			end if;
		end if;
	end process;
	
	process(data_reg)		
	-- data�� sel�� ���õ� 7-segment�� ����� '��'
	begin
		case data_reg is	-- dpgfedcba ��
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
	-- �� 7-segment�� ��� ��ȣ�� ���� ��ġ(segment ����)�� signal seg�� ������ ��
	-- �� signal�� ������ ȸ�� ����� output���� ������.

	process(RESET, CLK)
		 -- taxiCharge�� 16bit�� ������ �� BCD�� �ٲپ AA~FF�� �������� ��
		 -- double-dabble algorithm �̿�
		variable temp : STD_LOGIC_VECTOR (15 downto 0);
		variable bcd : UNSIGNED (19 downto 0) := (others => '0');
	begin
		if CLK = '1' and CLK'event then
			bcd := (others => '0');
			temp := taxiCharge;
			
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

				bcd := bcd(18 downto 0) & temp(15);
				temp := temp(14 downto 0) & '0';
			end loop;

			-- set outputs
			AA <= "0000";
			FF <= STD_LOGIC_VECTOR(bcd(3 downto 0));
			EE <= STD_LOGIC_VECTOR(bcd(7 downto 4));
			DD <= STD_LOGIC_VECTOR(bcd(11 downto 8));
			CC <= STD_LOGIC_VECTOR(bcd(15 downto 12));
			BB <= STD_LOGIC_VECTOR(bcd(19 downto 16));
		end if;
	end process;
	
end SEG_Behavioral;
