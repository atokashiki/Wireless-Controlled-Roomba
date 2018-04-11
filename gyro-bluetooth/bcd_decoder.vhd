----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:39:20 11/09/2011 
-- Design Name: 
-- Module Name:    bcd_decoder - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bcd_decoder is
    Port ( binary_in : in  STD_LOGIC_VECTOR (15 downto 0);
			  bcd_out : out STD_LOGIC_VECTOR (19 downto 0));
end bcd_decoder;

architecture Behavioral of bcd_decoder is

function binary_to_bcd( unsigned_data : std_logic_vector(15 downto 0) ) return std_logic_vector is
	variable i : integer := 0;
	variable bcd : std_logic_vector(19 downto 0) := (others => '0');
	variable init_bin : std_logic_vector(15 downto 0) := unsigned_data;

begin

	for i in 0 to 15 loop
		bcd := bcd(18 downto 0) & init_bin(15);
		init_bin := init_bin(14 downto 0) & '0';
		
		if (i < 7 and bcd(3 downto 0) > "0100") then
			bcd(3 downto 0) := bcd(3 downto 0) + "0011";
		end if;
		
		if (i < 7 and bcd(7 downto 4) > "0100") then
			bcd(7 downto 4) := bcd(7 downto 4) + "0011";
		end if;
		
		if (i < 7 and bcd(11 downto 8) > "0100") then
			bcd(11 downto 8) := bcd(11 downto 8) + "0011";
		end if;
		
		if (i < 7 and bcd(15 downto 12) > "0100") then
			bcd(15 downto 12) := bcd(15 downto 12) + "0011";
		end if;
		
		if (i < 7 and bcd(19 downto 16) > "0100") then
			bcd(19 downto 16) := bcd(19 downto 16) + "0011";
		end if;
		
	end loop;
return bcd;

end binary_to_bcd;

begin

end Behavioral;

