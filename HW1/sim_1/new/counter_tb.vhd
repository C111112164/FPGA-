library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_tb is
end counter_tb;

architecture Behavioral of counter_tb is
    component Counter
    port(i_clk : in STD_LOGIC;
         i_rst : in STD_LOGIC;
         o_count1 : out STD_LOGIC_VECTOR(3 downto 0);
         o_count2 : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
   
    signal i_clk : STD_LOGIC := '0';
    signal i_rst : STD_LOGIC := '0';
    signal o_count1: std_logic_vector(3 downto 0); --�w�q 4-bit �T��
    signal o_count2: std_logic_vector(3 downto 0); --�w�q 4-bit �T��
   
begin
    --�D
    TB: counter port map (
        i_clk => i_clk,
        i_rst => i_rst,
        o_count1 => o_count1,
        o_count2 => o_count2  
       );

    -- �����ͦ�
    process
    begin
       i_clk <= '0';
        wait for 5 ps;
       i_clk <= '1';
        wait for 5 ps;
    end process;
   
    -- ���չL�{
    process
    begin
        i_rst <= '0';
        wait for 10 ns;
        i_rst <= '1';
       
        wait;
    end process;

end Behavioral;

