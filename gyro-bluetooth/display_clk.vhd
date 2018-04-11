--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    08/16/2011
-- Module Name:    display_clk
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: This module is a simple clock divider that produces the clock signal
--					 used in display controller.
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
entity display_clk is
    Port ( clk : in  STD_LOGIC;
			  RST : in  STD_LOGIC;
           dclk : out  STD_LOGIC);
end display_clk;

architecture Behavioral of display_clk is

-- ==============================================================================
-- 								  Signals, Constants, Types
-- ==============================================================================

	constant CNTENDVAL : STD_LOGIC_VECTOR(15 downto 0) := "1011011100110101";
	signal cntval : STD_LOGIC_VECTOR (15 downto 0);

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			----------------------------------------
			--			  Clock Divider Process
			----------------------------------------
			process (clk)
			begin
				if rising_edge(clk) then
					if RST = '1' then
						cntval<= ( others => '0' );
					else
						if cntval = CNTENDVAL then
							cntval<= ( others => '0' );
						else
							cntval <= cntval + 1;
						end if;
					end if;
				end if;
			end process;

			-- Assign output clock
			dclk <= cntval(15);

end Behavioral;

