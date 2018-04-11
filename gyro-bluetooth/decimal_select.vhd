--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    07/11/2012
-- Module Name:    decimal_select
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: Select decimal display data.
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
entity decimal_select is
    Port ( control : in  STD_LOGIC_VECTOR (1 downto 0);
           dp : out  STD_LOGIC);
end decimal_select;

architecture Behavioral of decimal_select is

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			with control select
				dp<=	 '1' when "11",
						 '1' when "10",
						 '1' when "01",
						 '1' when others;

end Behavioral;

