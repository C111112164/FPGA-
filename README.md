# HW1  [counter](https://www.youtube.com/shorts/73Q8eGjqQkQ)


# HW2

# HW3  [pwm_breath](https://youtube.com/shorts/ERdG7_-1m0k?si=1AEDhDLYroMPUOqn)

# HW4  [pingpong](https://youtube.com/shorts/tOnv0RMuBEo?si=bTVY1dGMhjbBNnCr)

# HW5  [vga_bonus](https://www.youtube.com/watch?v=AdTL2_zqUU8)

# HW5-2 [vga_pingpong](https://www.youtube.com/watch?v=OKdsW8d9eu4)


PDF下方有more pages代表還有要記得點
![image](https://github.com/user-attachments/assets/ec38545f-94be-437d-8a51-3075212f07d5)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity vga_controller is
    Port ( clk       : in  STD_LOGIC;       -- FPGA時鐘
           rst_n     : in  STD_LOGIC;       -- 重置信號
           i_sw_up   : in  STD_LOGIC;       -- 平率增
           i_sw_dn   : in  STD_LOGIC;       -- 平率減
           hsync     : out STD_LOGIC;       -- 水平同步信號
           vsync     : out STD_LOGIC;       -- 垂直同步信號
           red       : out STD_LOGIC_VECTOR (3 downto 0);  -- 紅色顏色分量
           green     : out STD_LOGIC_VECTOR (3 downto 0);  -- 綠色顏色分量
           blue      : out STD_LOGIC_VECTOR (3 downto 0)   -- 藍色顏色分量
           );
end vga_controller;

architecture Behavioral of vga_controller is
    -- VGA參數定義 (640x480解析度，60Hz刷新率)
    constant H_SYNC_CYCLES    : integer := 96;    -- 水平同步脈寬
    constant H_BACK_PORCH     : integer := 48;    -- 水平後座標
    constant H_ACTIVE_VIDEO   : integer := 640;   -- 顯示區寬度
    constant H_FRONT_PORCH    : integer := 16;    -- 水平前座標
    constant V_SYNC_CYCLES    : integer := 2;     -- 垂直同步脈寬
    constant V_BACK_PORCH     : integer := 33;    -- 垂直後座標
    constant V_ACTIVE_VIDEO   : integer := 480;   -- 顯示區高度
    constant V_FRONT_PORCH    : integer := 10;    -- 垂直前座標
    constant CIRCLE_CENTER_X  : integer := 320;   -- 圓心 X 座標
    constant CIRCLE_CENTER_Y  : integer := 240;   -- 圓心 Y 座標
    constant CIRCLE_RADIUS    : integer := 100;   -- 半徑
   signal           sw  : STD_LOGIC_VECTOR(1 downto 0);
    signal divclk: STD_LOGIC_VECTOR(1 downto 0);
    signal fclk: STD_LOGIC;
    signal h_count : integer range 0 to H_ACTIVE_VIDEO + H_SYNC_CYCLES + H_BACK_PORCH + H_FRONT_PORCH - 1 := 0;  -- 水平計數器
    signal v_count : integer range 0 to V_ACTIVE_VIDEO + V_SYNC_CYCLES + V_BACK_PORCH + V_FRONT_PORCH - 1 := 0;  -- 垂直計數器
    signal n_cycle_PWM : integer range 0 to 5000;

begin
sw <= i_sw_up & i_sw_dn;
    -- Division of the clock for VGA sync
    fd: process(clk, rst_n)
    begin
        if rst_n = '0' then
            divclk <= (others => '0');
        elsif rising_edge(clk) then
            divclk <= divclk + 1;
        end if;
    end process;
    
    fclk <= divclk(1);

    -- VGA同步信號生成
    hsync <= '0' when (h_count < H_SYNC_CYCLES) else '1';
    vsync <= '0' when (v_count < V_SYNC_CYCLES) else '1';

    -- 圓形的繪製邏輯
    process(fclk, rst_n, i_sw_up, i_sw_dn)
    begin
        if rst_n = '0' then
            red <= "0000";
            green <= "0000";
            blue <= "0000";
        elsif rising_edge(fclk) then
            if (h_count >= H_BACK_PORCH) and (h_count < H_ACTIVE_VIDEO + H_BACK_PORCH) and 
               (v_count >= V_BACK_PORCH) and (v_count < V_ACTIVE_VIDEO + V_BACK_PORCH) then
                if ( (h_count - CIRCLE_CENTER_X) *(h_count - CIRCLE_CENTER_X)  + (v_count - CIRCLE_CENTER_Y) *(v_count - CIRCLE_CENTER_Y) ) <= 20 * 20 then
                    -- 使用正確的to_unsigned範圍
                    red   <= "0000";
                    green <= "1111";
                    blue  <= "0000";
                else
                    red   <= "0000";
                    green <= "0000";
                    blue  <= "0000";
                end if;
            end if;
        end if;
    end process;

    -- 水平計數器控制
    process(fclk, rst_n)
    begin
        if rst_n = '0' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(fclk) then
            if h_count = H_ACTIVE_VIDEO + H_SYNC_CYCLES + H_BACK_PORCH + H_FRONT_PORCH - 1 then
                h_count <= 0;
                if v_count = V_ACTIVE_VIDEO + V_SYNC_CYCLES + V_BACK_PORCH + V_FRONT_PORCH - 1 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    -- 呼吸頻率調整
    BFA: process(fclk, rst_n, i_sw_up, i_sw_dn)
    begin
        if rst_n = '0' then
            n_cycle_PWM <= 2000; -- Default value
        elsif rising_edge(fclk) then
            case sw is
                when "00" => null;
                when "01" =>
                    if n_cycle_PWM > 500 then
                        n_cycle_PWM <= n_cycle_PWM - 500;
                    end if;
                when "10" =>
                    if n_cycle_PWM < 5000 then
                        n_cycle_PWM <= n_cycle_PWM + 500;
                    end if;
                when others => null;
            end case;
        end if;
    end process;

end Behavioral;
