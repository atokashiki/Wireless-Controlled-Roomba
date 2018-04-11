--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    07/11/2012
-- Module Name:    seven_seg_decoder
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: Produces cathode signals for displaying digits on the SSD.
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
entity seven_seg_decoder is
    Port ( num_in : in  STD_LOGIC_VECTOR (3 downto 0);
			  control : in STD_LOGIC_VECTOR (1 downto 0);
           seg_out : out  STD_LOGIC_VECTOR (6 downto 0);
			  display_sel : in STD_LOGIC);
end seven_seg_decoder;

architecture Behavioral of seven_seg_decoder is

-- ==============================================================================
-- 								  Signals, Constants, Types
-- ==============================================================================

			signal seg_out_bcd : std_logic_vector(6 downto 0);
			signal seg_out_hex : std_logic_vector(6 downto 0);
			signal seg_out_buf : std_logic_vector(6 downto 0);

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			-- If displaying hex, then make digit 4 on the SSD be an "H"
			seg_out <= "0001001" when control = "11" and display_sel = '0' else seg_out_buf;

			-- Select either the HEX data or Dec. data to display on the SSD.
			with display_sel select
				seg_out_buf <= seg_out_bcd when '1',
									seg_out_hex when others;

			-- Decimal decoder
			with num_in select
				seg_out_bcd <=   "1000000" when "0000", --0
									  "1111001" when "0001", --1
									  "0100100" when "0010", --2
									  "0110000" when "0011", --3
									  "0011001" when "0100", --4
									  "0010010" when "0101", --5
									  "0000010" when "0110", --6
									  "1111000" when "0111", --7
									  "0000000" when "1000", --8
									  "0010000" when "1001", --9
									  "1111111" when "1010", --nothing when positive
									  "1000110" when "1011", --C for temperature reading
									  "0111111" when others; --minus sign

			-- Hex decoder
			with num_in select
				seg_out_hex <=   "1000000" when "0000", --0
									  "1111001" when "0001", --1
									  "0100100" when "0010", --2
									  "0110000" when "0011", --3
									  "0011001" when "0100", --4
									  "0010010" when "0101", --5
									  "0000010" when "0110", --6
									  "1111000" when "0111", --7
									  "0000000" when "1000", --8
									  "0010000" when "1001", --9
									  "0001000" when "1010", --A
									  "0000011" when "1011", --B
									  "1000110" when "1100", --C
									  "0100001" when "1101", --D
									  "0000110" when "1110", --E
									  "0001110" when others; --F
end Behavioral;
