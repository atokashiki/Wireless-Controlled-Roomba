--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    07/11/2012
-- Module Name:    data_select
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: Uses "sel" input signals to select data to output on "data" bus.
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
entity data_select is
    Port ( x_axis : in  STD_LOGIC_VECTOR (15 downto 0);
           y_axis : in  STD_LOGIC_VECTOR (15 downto 0);
           z_axis : in  STD_LOGIC_VECTOR (15 downto 0);
			  temp_data : in STD_LOGIC_VECTOR (7 downto 0);
           data : out  STD_LOGIC_VECTOR (15 downto 0);
           sel : in  STD_LOGIC_VECTOR (1 downto 0));
end data_select;

architecture Behavioral of data_select is

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			with sel select
				data <= x_axis when "00",
						  y_axis when "01",
						  z_axis when "10",
						  X"00" & temp_data when others;

end Behavioral;

