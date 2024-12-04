library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.std_logic_arith.ALL;

entity vga_controller is
    Port ( clk       : in  STD_LOGIC;       -- FPGA����
           rst_n     : in  STD_LOGIC;       -- ���m�H��
           hsync     : out STD_LOGIC;       -- �����P�B�H��
           vsync     : out STD_LOGIC;       -- �����P�B�H��
           red       : out STD_LOGIC_VECTOR (3 downto 0);  -- �����C����q
           green     : out STD_LOGIC_VECTOR (3 downto 0);  -- ����C����q
           blue      : out STD_LOGIC_VECTOR (3 downto 0)   -- �Ŧ��C����q
           );
end vga_controller;

architecture Behavioral of vga_controller is
    -- VGA�ѼƩw�q (640x480�ѪR�סA60Hz��s�v)
    constant H_SYNC_CYCLES : integer := 96;  -- �����P�B�߼e
    constant H_BACK_PORCH : integer := 48;   -- ������y��
    constant H_ACTIVE_VIDEO : integer := 640; -- ��ܰϼe��
    constant H_FRONT_PORCH : integer := 16;  -- �����e�y��
    constant V_SYNC_CYCLES : integer := 2;   -- �����P�B�߼e
    constant V_BACK_PORCH : integer := 33;   -- ������y��
    constant V_ACTIVE_VIDEO : integer := 480; -- ��ܰϰ���
    constant V_FRONT_PORCH : integer := 10;  -- �����e�y��
    signal divclk:STD_LOGIC_VECTOR(1 downto 0);
    signal fclk:STD_LOGIC;
    signal h_count : integer range 0 to 799 := 0;  -- �����p�ƾ�
    signal v_count : integer range 0 to 524 := 0;  -- �����p�ƾ�
    signal random_color : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- �H���I���C��
begin
    process(fclk, rst_n)
    begin
        if rst_n = '0' then
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

    -- �H���I���C��ͦ� (�i�H�אּ���Ӫ��H���޿�)
    random_color <= "001" when (h_count = 100 and v_count = 100) else random_color;

    -- ��Ϊ�ø�s�޿�
    -- ��ߦ�m (320, 240)�A�b�| 100
    --    if ( (h_count - 320) * (h_count - 320) ) +(  (v_count - 240) * (v_count - 240) ) <= 100 * 100 then
process(fclk, rst_n)
    begin    
   if ( (h_count - 480) * (h_count - 480) ) +(  (v_count - 360) * (v_count - 360) ) <=15 * 20 then
        red   <= "0000";
        green <= "1111";  -- �����
        blue  <= "0000";
    else
        -- �I���C��]�m���H���C��
        case random_color is
            when "000" => 
                red   <= "0000";
                green <= "0000";
                blue  <= "1111"; -- �Ŧ�I��
            when "001" => 
                red   <= "1111";
                green <= "0000";
                blue  <= "0000"; -- ����I��
            when others => 
                red   <= "0000";
                green <= "1111";
                blue  <= "0000"; -- �w�]���I��
        end case;
    end if;
   end process;    
fd:process(clk ,rst_n)
begin
if (rst_n = '0') then 
    divclk <= (others => '0');
elsif (rising_edge(clk)) then
    divclk <= divclk +1 ;
end if;
end process fd;
fclk <= divclk(1);      
end Behavioral;
