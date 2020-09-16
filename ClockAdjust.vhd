library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockAdjust is
 Port (    clk : in STD_LOGIC;
           clk_out: out STD_LOGIC;
           clk_1hz : out STD_LOGIC );
end ClockAdjust;

architecture Behavioral of ClockAdjust is
   
signal orig: STD_LOGIC_VECTOR(25 downto 0) := "10111110101111000010000000"; -- 100,000,000 in binary
signal orig_count: STD_LOGIC_VECTOR(25 downto 0) := (others => '0');
signal newclk : std_logic := '0';

begin

clk_1hz <= newclk;

process(clk,newclk)
begin
    if (rising_edge(clk)) then
        orig_count <= orig_count + 1;
        if(orig_count > orig) then
            newclk <= not newclk;
            orig_count <= (others => '0');
        end if;
     end if;
end process;

process(clk)
variable count: integer:= 0;
variable clksig: std_logic:= '0';
begin
    if (rising_edge(clk)) then
        if (count < 20000) then
            count:= count +1;
        else
            clksig := not clksig;
            count := 0;
        end if;
    end if;
    clk_out <= clksig;
end process;

end Behavioral;
