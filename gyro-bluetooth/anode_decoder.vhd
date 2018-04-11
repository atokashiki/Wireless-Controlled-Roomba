--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    07/11/2012
-- Module Name:    anode_decoder
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: Produces anode patterns to illuminate one digit on the SSD at a time.
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
entity anode_decoder is
    Port ( anode : out  STD_LOGIC_VECTOR (3 downto 0);
           control : in  STD_LOGIC_VECTOR (1 downto 0));
end anode_decoder;

architecture Behavioral of anode_decoder is

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			-- Anode Mux
			with control select
				anode<= "1110" when "00",
						  "1101" when "01",
						  "1011" when "10",
						  "0111" when others;

end Behavioral;

