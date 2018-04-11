--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    07/11/2012
-- Module Name:    digit_select
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: Converts data from binary to either HEX or BCD format.
--
-- Revision History: 
-- 						Revision 0.01 - File Created (Andrew Skreen)
--							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
--////////////////////////////////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ==============================================================================
-- 										  Define Module
-- ==============================================================================
entity digit_select is
    Port ( D1 : in  STD_LOGIC_VECTOR (3 downto 0);
           D2 : in  STD_LOGIC_VECTOR (3 downto 0);
           D3 : in  STD_LOGIC_VECTOR (3 downto 0);
           D4 : in  STD_LOGIC_VECTOR (3 downto 0);
           control : in  STD_LOGIC_VECTOR (1 downto 0);
           digit : out  STD_LOGIC_VECTOR (3 downto 0));
end digit_select;

architecture Behavioral of digit_select is

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			-- Assign digit to display on SSD cathodes
			with control select
				digit<=D1 when "11",
						 D2 when "10",
						 D3 when "01",
						 D4 when others;

end Behavioral;

