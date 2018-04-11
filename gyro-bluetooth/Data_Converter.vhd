----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:27:13 03/10/2017 
-- Design Name: 
-- Module Name:    Data_Converter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Data_Converter is
    Port (D1 : in  STD_LOGIC_VECTOR (3 downto 0);
           D2 : in  STD_LOGIC_VECTOR (3 downto 0);
           D3 : in  STD_LOGIC_VECTOR (3 downto 0);
           D4 : in  STD_LOGIC_VECTOR (3 downto 0);
           RESULT : out STD_LOGIC_VECTOR(10 downto 0));
end Data_Converter;

architecture Behavioral of Data_Converter is

signal x1 : std_logic_vector(10 downto 0);
signal x2 : std_logic_vector(10 downto 0);
signal x3 : std_logic_vector(10 downto 0);
signal temp : std_logic_vector(10 downto 0);


begin
--x1 <= std_logic_vector(resize(unsigned(D2), x1'length));
--x2 <= std_logic_vector(resize(unsigned(D3), x2'length));
--x3 <= std_logic_vector(resize(unsigned(D4), x3'length));
x1 <= std_logic_vector(to_unsigned(to_integer(unsigned(D2)) * 100, 11));
x2 <= std_logic_vector(to_unsigned(to_integer(unsigned(D3)) * 10, 11));
x3 <= std_logic_vector(to_unsigned(to_integer(unsigned(D2)) * 1, 11));
--
--with D2 select
--x1 <= "0" when "0000",
--      "1" when "0001",
--      2 when "0010",
--      "3" when "0011",
--      "4" when "0100",
--      "5" when "0101",
--      "6" when "0110",
--      "7" when "0111",
--      "8" when "1000",
--      "9" when "1001";
--
--with D3 select
--x2 <= "0" when "0000",
--      "1" when "0001",
--      "2" when "0010",
--      "3" when "0011",
--      "4" when "0100",
--      "5" when "0101",
--      "6" when "0110",
--      "7" when "0111",
--      "8" when "1000",
--      "9" when "1001";
--
--with D4 select
--x3 <= "0" when "0000",
--      "1" when "0001",
--      "2" when "0010",
--      "3" when "0011",
--      "4" when "0100",
--      "5" when "0101",
--      "6" when "0110",
--      "7" when "0111",
--      "8" when "1000",
--      "9" when "1001";

with D1 select
    RESULT <= ( not(x1 + x2 + x3) + 1 ) when "1111", 
                        ( x1 + x2 + x3 ) when others;

--RESULT <= (15 downto 11 => temp(10), 10 downto 0 => temp);

end Behavioral;

