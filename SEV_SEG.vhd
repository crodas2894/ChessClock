library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SEV_SEG is
  Port (clk : in std_logic;
        p1_time : in STD_LOGIC_VECTOR (15 downto 0);
        p2_time : in STD_LOGIC_VECTOR (15 downto 0);
        seg1 : out std_logic_vector(6 downto 0);
        seg2 : out std_logic_vector(6 downto 0);
        seg3 : out std_logic_vector(6 downto 0);
        seg4 : out std_logic_vector(6 downto 0);
        seg5 : out std_logic_vector(6 downto 0);
        seg6 : out std_logic_vector(6 downto 0);
        seg7 : out std_logic_vector(6 downto 0);
        seg8 : out std_logic_vector(6 downto 0));
end SEV_SEG;

architecture Behavioral of SEV_SEG is

signal bcd1, bcd2, bcd3, bcd4, bcd5, bcd6, bcd7, bcd8: std_logic_vector(3 downto 0);

begin
process(clk, bcd1, bcd2, bcd3, bcd4, bcd5, bcd6, bcd7, bcd8)
begin
    bcd1 <= std_logic_vector(to_unsigned(to_integer(unsigned(p2_time))mod 10, 4));
    bcd2 <= std_logic_vector(to_unsigned(to_integer((unsigned(p2_time))/10)mod 6, 4));
    bcd3 <= std_logic_vector(to_unsigned(to_integer((unsigned(p2_time))/60)mod 10, 4));
    bcd4 <= std_logic_vector(to_unsigned(to_integer((unsigned(p2_time))/600)mod 10, 4));
    bcd5 <= std_logic_vector(to_unsigned(to_integer(unsigned(p1_time))mod 10, 4));
    bcd6 <= std_logic_vector(to_unsigned(to_integer((unsigned(p1_time))/10)mod 6, 4));
    bcd7 <= std_logic_vector(to_unsigned(to_integer((unsigned(p1_time))/60)mod 10, 4));
    bcd8 <= std_logic_vector(to_unsigned(to_integer((unsigned(p1_time))/600)mod 10, 4));
if (rising_edge(clk)) then
--Player 1 seconds
    case bcd1 is
            when "0000"=> seg1 <="1111110";  -- '0'
            when "0001"=> seg1 <="0110000";  -- '1'
            when "0010"=> seg1 <="1101101";  -- '2'
            when "0011"=> seg1 <="1111001";  -- '3'
            when "0100"=> seg1 <="0110011";  -- '4' 
            when "0101"=> seg1 <="1011011";  -- '5'
            when "0110"=> seg1 <="1011111";  -- '6'
            when "0111"=> seg1 <="1110000";  -- '7'
            when "1000"=> seg1 <="1111111";  -- '8'
            when "1001"=> seg1 <="1111001";  -- '9'
             --nothing is displayed when a number more than 9 is given as input. 
            when others=> seg1 <="1111111";
    end case;
--Player 1 seconds    
    case bcd2 is
            when "0000"=> seg2 <="1111110";  -- '0'
    when "0001"=> seg2 <="0110000";  -- '1'
    when "0010"=> seg2 <="1101101";  -- '2'
    when "0011"=> seg2 <="1111001";  -- '3'
    when "0100"=> seg2 <="0110011";  -- '4' 
    when "0101"=> seg2 <="1011011";  -- '5'
    when "0110"=> seg2 <="1011111";  -- '6'
    when "0111"=> seg2 <="1110000";  -- '7'
    when "1000"=> seg2 <="1111111";  -- '8'
    when "1001"=> seg2 <="1111001";  -- '9'
     --nothing is displayed when a number more than 9 is given as input. 
    when others=> seg2 <="0000000";
    end case;
--Player 2 seconds    
    case bcd3 is
        when "0000"=> seg3 <="1111110";  -- '0'
        when "0001"=> seg3 <="0110000";  -- '1'
        when "0010"=> seg3 <="1101101";  -- '2'
        when "0011"=> seg3 <="1111001";  -- '3'
        when "0100"=> seg3 <="0110011";  -- '4' 
        when "0101"=> seg3 <="1011011";  -- '5'
        when "0110"=> seg3 <="1011111";  -- '6'
        when "0111"=> seg3 <="1110000";  -- '7'
        when "1000"=> seg3 <="1111111";  -- '8'
        when "1001"=> seg3 <="1111001";  -- '9'
        --nothing is displayed when a number more than 9 is given as input. 
        when others=> seg3 <="0000000";
    end case;
--Player 2 seconds  
    case bcd4 is
        when "0000"=> seg4 <="1111110";  -- '0'
        when "0001"=> seg4 <="0110000";  -- '1'
        when "0010"=> seg4 <="1101101";  -- '2'
        when "0011"=> seg4 <="1111001";  -- '3'
        when "0100"=> seg4 <="0110011";  -- '4' 
        when "0101"=> seg4 <="1011011";  -- '5'
        when "0110"=> seg4 <="1011111";  -- '6'
        when "0111"=> seg4 <="1110000";  -- '7'
        when "1000"=> seg4 <="1111111";  -- '8'
        when "1001"=> seg4 <="1111001";  -- '9'
        --nothing is displayed when a number more than 9 is given as input. 
        when others=> seg4 <="0000000";
    end case;
--Player 1 minutes   
    case bcd5 is
        when "0000"=> seg5 <="1111110";  -- '0'
        when "0001"=> seg5 <="0110000";  -- '1'
        when "0010"=> seg5 <="1101101";  -- '2'
        when "0011"=> seg5 <="1111001";  -- '3'
        when "0100"=> seg5 <="0110011";  -- '4' 
        when "0101"=> seg5 <="1011011";  -- '5'
        when "0110"=> seg5 <="1011111";  -- '6'
        when "0111"=> seg5 <="1110000";  -- '7'
        when "1000"=> seg5 <="1111111";  -- '8'
        when "1001"=> seg5 <="1111001";  -- '9'
        --nothing is displayed when a number more than 9 is given as input. 
        when others=> seg5 <="0000000";
    end case;
--Player 1 minutes    
    case bcd6 is
        when "0000"=> seg6 <="1111110";  -- '0'
        when "0001"=> seg6 <="0110000";  -- '1'
        when "0010"=> seg6 <="1101101";  -- '2'
        when "0011"=> seg6 <="1111001";  -- '3'
        when "0100"=> seg6 <="0110011";  -- '4' 
        when "0101"=> seg6 <="1011011";  -- '5'
        when "0110"=> seg6 <="1011111";  -- '6'
        when "0111"=> seg6 <="1110000";  -- '7'
        when "1000"=> seg6 <="1111111";  -- '8'
        when "1001"=> seg6 <="1111001";  -- '9'
        --nothing is displayed when a number more than 9 is given as input. 
        when others=> seg6 <="0000000";
    end case;
--Player 2 minutes
    case bcd7 is
        when "0000"=> seg7 <="1111110";  -- '0'
        when "0001"=> seg7 <="0110000";  -- '1'
        when "0010"=> seg7 <="1101101";  -- '2'
        when "0011"=> seg7 <="1111001";  -- '3'
        when "0100"=> seg7 <="0110011";  -- '4' 
        when "0101"=> seg7 <="1011011";  -- '5'
        when "0110"=> seg7 <="1011111";  -- '6'
        when "0111"=> seg7 <="1110000";  -- '7'
        when "1000"=> seg7 <="1111111";  -- '8'
        when "1001"=> seg7 <="1111001";  -- '9'
        --nothing is displayed when a number more than 9 is given as input. 
        when others=> seg7 <="0000000";
    end case;
--Player 2 minutes    
    case bcd8 is
        when "0000"=> seg8 <="1111110";  -- '0'
        when "0001"=> seg8 <="0110000";  -- '1'
        when "0010"=> seg8 <="1101101";  -- '2'
        when "0011"=> seg8 <="1111001";  -- '3'
        when "0100"=> seg8 <="0110011";  -- '4' 
        when "0101"=> seg8 <="1011011";  -- '5'
        when "0110"=> seg8 <="1011111";  -- '6'
        when "0111"=> seg8 <="1110000";  -- '7'
        when "1000"=> seg8 <="1111111";  -- '8'
        when "1001"=> seg8 <="1111001";  -- '9'
        --nothing is displayed when a number more than 9 is given as input. 
        when others=> seg8 <="0000000";
    end case;
end if;
end process;
end Behavioral;
