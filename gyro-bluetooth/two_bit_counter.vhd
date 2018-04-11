--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    07/11/2012
-- Module Name:    two_bit_counter
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: Produces the select/control signals used to display data.
--
-- Revision History: 
-- 						Revision 0.01 - File Created (Andrew Skreen)
--							Revision 1.00 - Added Comments and Converted to Verilog (Josh Sackos)
--////////////////////////////////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ==============================================================================
-- 										  Define Module
-- ==============================================================================
entity two_bit_counter is
    Port ( dclk : in  STD_LOGIC;
			  rst : in  STD_LOGIC;
           control : out  STD_LOGIC_VECTOR (1 downto 0));
end two_bit_counter;

architecture Behavioral of two_bit_counter is

-- ==============================================================================
-- 								  Signals, Constants, Types
-- ==============================================================================
			
			signal count : STD_LOGIC_VECTOR (1 downto 0);

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			-- Counting process
			process ( dclk , rst ) begin
				if rising_edge(dclk) then
					if rst='1' then 
						count <= ( others => '0' );
					else
						count <= count + 1;
					end if;
				end if;
			end process;	

			-- Assign output control bus
			control <= count;

end Behavioral;

