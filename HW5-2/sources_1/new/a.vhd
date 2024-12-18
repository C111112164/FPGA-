library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity vga_controller is
    Port ( i_clk            : in STD_LOGIC;
           i_rst            : in STD_LOGIC;
           i_left_button    : in STD_LOGIC; --s5
           i_right_button   : in STD_LOGIC; --s9
           o_count          : out STD_LOGIC_VECTOR(7 downto 0);
           hsync     : out STD_LOGIC;       -- �����P�B�H��
           vsync     : out STD_LOGIC;       -- �����P�B�H��
           red       : out STD_LOGIC_VECTOR (3 downto 0);  -- �����C����q
           green     : out STD_LOGIC_VECTOR (3 downto 0);  -- ����C����q
           blue      : out STD_LOGIC_VECTOR (3 downto 0)   -- �Ŧ��C����q
           );
end vga_controller;

architecture Behavioral of vga_controller is
    
signal count            : STD_LOGIC_VECTOR(7 downto 0);
signal right_score      : STD_LOGIC_VECTOR(3 downto 0);
signal left_score       : STD_LOGIC_VECTOR(3 downto 0);
signal divclk           :STD_LOGIC_VECTOR(26 downto 0);
signal led_clk          :STD_LOGIC;
type counter_state is (reserve,counter_is_counting_left, counter_is_counting_right,left_win,right_win,left_ready_serve,right_ready_serve);
signal counter_move_state: counter_state;
signal prestate: counter_state;
    
    signal   x: integer;
    -- VGA�ѼƩw�q (640x480�ѪR�סA60Hz��s�v)
    constant xplus         : integer := 100;
    constant H_SYNC_CYCLES : integer := 96;  -- �����P�B�߼e
    constant H_BACK_PORCH : integer := 48;   -- ������y��
    constant H_ACTIVE_VIDEO : integer := 640; -- ��ܰϼe��
    constant H_FRONT_PORCH : integer := 16;  -- �����e�y��
    constant V_SYNC_CYCLES : integer := 2;   -- �����P�B�߼e
    constant V_BACK_PORCH : integer := 33;   -- ������y��
    constant V_ACTIVE_VIDEO : integer := 480; -- ��ܰϰ���
    constant V_FRONT_PORCH : integer := 10;  -- �����e�y��
    signal fclk:STD_LOGIC;
    signal h_count : integer range 0 to 799 := 0;  -- �����p�ƾ�
    signal v_count : integer range 0 to 524 := 0;  -- �����p�ƾ�

begin
o_count <= count;



    -- �����M�����p�ƾ���s
    process(fclk, i_rst)
    begin
        if i_rst = '0' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(fclk) then
            if h_count = 799 then
                h_count <= 0;
                if v_count = 524 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    -- �����P�B�H���M�����P�B�H��
    hsync <= '0' when (h_count < H_SYNC_CYCLES) else '1';
    vsync <= '0' when (v_count < V_SYNC_CYCLES) else '1';

    -- ��Ϊ�ø�s�޿�
    process(fclk, i_rst)
    begin    
        if i_rst = '0' then
            red   <= "0000";
            green <= "0000";
            blue  <= "0000";  -- ��l���¦�
        elsif rising_edge(fclk) then
            -- ��ߦ�m (480, 360)�A�b�| 15
            if ( (  h_count - x -xplus) * ( h_count - x-xplus) + (v_count - 360) * (v_count - 360) <= 15 * 15 ) then
                red   <= "0000";         -- ���⬰ 0000
                green <= "1111";         -- ��⬰ 1111
                blue  <= "0000";         -- �Ŧ⬰ 0000
            else
                red   <= "0100";         -- �q�{���¦�
                green <= "1000";         -- �q�{���¦�
                blue  <= "0011";         -- �q�{���¦�
            end if;
        end if;
    end process;



vga_move :process (i_clk , i_rst)
begin
    if i_rst = '0' then
        x <=320; 
    elsif led_clk' event and led_clk = '1' then
        case counter_move_state is 
            when counter_is_counting_left =>
                x <= x-60; --????
            when counter_is_counting_right =>
               x <= x+60; --?k??
            when right_win =>
                null; --??????                         
            when left_win =>    
                null;  --??????
            when left_ready_serve =>
                x <=60; --?????l??                          
            when right_ready_serve =>
                x <=540; --?k???l??
            when others =>
                null;
        end case;
    end if;                
end process;



led_move_state :process (i_clk , i_rst , i_left_button , i_right_button)
begin
    if  i_rst = '0'  then --???l?k?o?y
            counter_move_state <= reserve;
    elsif i_clk' event and i_clk = '1' then
        prestate <= counter_move_state;
        case counter_move_state is 
            when counter_is_counting_left =>
                if (count = "10000000") and (i_left_button = '1') then --??????
                    counter_move_state <= counter_is_counting_right;             
                elsif (i_left_button = '0' and count = "00000000") or (count<"10000000" and i_left_button='1') then --???S????
                    counter_move_state <= right_win;   
                end if;                   
            when counter_is_counting_right =>
                if (count = "00000001") and (i_right_button = '1') then --?k????
                    counter_move_state <= counter_is_counting_left;
                elsif (i_right_button = '0' and count = "00000000") or (i_right_button = '1' and count > "00000001") then --?k?S????
                    counter_move_state <= left_win;
                end if;    
            when right_win =>
                if count = (left_score(0)&left_score(1)&left_score(2)&left_score(3)) & right_score then
                    counter_move_state <= reserve;
                end if;
                --if i_left_button = '1' then --???w???o?y
                --    counter_move_state <= left_ready_serve;
                --end if;                           
            when left_win =>
                if count = (left_score(0)&left_score(1)&left_score(2)&left_score(3)) & right_score then
                    counter_move_state <= reserve;
                end if;
            when left_ready_serve =>
                if count = "10000000" then --???o?y
                    counter_move_state <= counter_is_counting_right;
                end if;                           
            when right_ready_serve =>
                if count = "00000001" then --?k?o?y
                    counter_move_state <= counter_is_counting_left;
                end if;
            when reserve =>
                if i_left_button = '1' then
                    counter_move_state <= left_ready_serve;
                elsif i_right_button = '1' then 
                    counter_move_state <= right_ready_serve;
                else
                    counter_move_state <= reserve;
                end if;
            when others =>
                null;
        end case;
    end if;
end process;

counter :process (i_clk , i_rst)
begin
    if i_rst = '0' then
        count <= "00000000";--count???l?? 
    elsif led_clk' event and led_clk = '1' then
        case counter_move_state is 
            when counter_is_counting_left =>
                count <= count(6 downto 0) & '0'; --????
            when counter_is_counting_right =>
                count <= '0' & count(7 downto 1); --?k??
            when right_win =>
                count <= (left_score(0)&left_score(1)&left_score(2)&left_score(3)) & right_score; --??????                         
            when left_win =>    
                count <= (left_score(0)&left_score(1)&left_score(2)&left_score(3)) & right_score;  --??????
            when left_ready_serve =>
                count <= "10000000"; --?????l??                          
            when right_ready_serve =>
                count <= "00000001"; --?k???l??
            when others =>
                null;
        end case;
    end if;                
end process;

count_score : process (i_clk, i_rst)
begin
    if i_rst = '0' then
        right_score <= "0000"; -- ???l?? score
        left_score  <= "0000"; 
    elsif i_clk' event and i_clk = '1' then
        case counter_move_state is  
            when counter_is_counting_left =>
                null; 
            when counter_is_counting_right =>
                null; 
            when right_win =>
                if prestate = counter_is_counting_left then
                
                    right_score <= right_score + '1'; --right_win  
                else
                    right_score <= right_score;
                end if;
            when left_win =>    
                if prestate = counter_is_counting_right then                
                    left_score <= left_score + '1'; --right_win  
                else
                    left_score <= left_score;
                end if;
            when left_ready_serve =>
                null;                         
            when right_ready_serve =>
                null;
            when others =>
                null;             
        end case;    
    end if;
end process;


    -- �������W�B�z (���F����fclk�H��)
  fd:process(i_clk ,i_rst)
begin
if i_rst = '0' then 
    divclk <= (others => '0');
elsif rising_edge(i_clk) then
    divclk <= divclk +1 ;
end if;
end process fd;
led_clk <= divclk(24);
fclk <= divclk(1); 
end Behavioral;