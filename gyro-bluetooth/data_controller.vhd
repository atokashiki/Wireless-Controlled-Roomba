--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    07/11/2012
-- Module Name:    data_controller
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ==============================================================================
-- 										  Define Module
-- ==============================================================================
entity data_controller is
    Port ( display_sel : in  STD_LOGIC;
			  sel : in STD_LOGIC_VECTOR (1 downto 0);
			  data : in  STD_LOGIC_VECTOR (15 downto 0);
           D1 : out  STD_LOGIC_VECTOR (3 downto 0);
           D2 : out  STD_LOGIC_VECTOR (3 downto 0);
           D3 : out  STD_LOGIC_VECTOR (3 downto 0);
           D4 : out  STD_LOGIC_VECTOR (3 downto 0));
end data_controller;

architecture Behavioral of data_controller is

-- ==============================================================================
-- 										    Functions
-- ==============================================================================

			function binary_to_bcd( unsigned_data : std_logic_vector(15 downto 0) ) return std_logic_vector is
				variable i : integer := 0;
				variable bcd : std_logic_vector(19 downto 0) := (others => '0');
				variable init_bin : std_logic_vector(15 downto 0) := unsigned_data;

			begin

				for i in 0 to 15 loop
					bcd(19 downto 1) := bcd(18 downto 0);
					bcd(0) := init_bin(15);
					init_bin(15 downto 1) := init_bin(14 downto 0);
					init_bin(0) := '0';
					
					if (i < 15 and bcd(3 downto 0) > "0100") then
						bcd(3 downto 0) := bcd(3 downto 0) + "0011";
					end if;
					
					if (i < 15 and bcd(7 downto 4) > "0100") then
						bcd(7 downto 4) := bcd(7 downto 4) + "0011";
					end if;
					
					if (i < 15 and bcd(11 downto 8) > "0100") then
						bcd(11 downto 8) := bcd(11 downto 8) + "0011";
					end if;
					
					if (i < 15 and bcd(15 downto 12) > "0100") then
						bcd(15 downto 12) := bcd(15 downto 12) + "0011";
					end if;
					
					if (i < 15 and bcd(19 downto 16) > "0100") then
						bcd(19 downto 16) := bcd(19 downto 16) + "0011";
					end if;
					
				end loop;
				
				return bcd;

			end binary_to_bcd;

-- ==============================================================================
-- 								 Signals, Constants, Types
-- ==============================================================================

			signal bcd_buf : std_logic_vector(19 downto 0);
			signal temp : std_logic_vector(19 downto 0);
			signal unsigned_data : std_logic_vector( 15 downto 0);
			signal unsigned_scaled_data : std_logic_vector(19 downto 0);
			signal bcd : std_logic_vector(15 downto 0);

-- ==============================================================================
-- 										Implementation
-- ==============================================================================
begin

			D1 <= bcd(15 downto 12) when display_sel = '1' else "0000";
			D2 <= bcd(11 downto 8) when display_sel = '1' else data(15 downto 12);
			D3 <= bcd(7 downto 4) when display_sel = '1' else data(11 downto 8);
			D4 <= bcd(3 downto 0)when display_sel = '1' else data(7 downto 4);

			-- Determine sign of data, if shown BCD data is zero, don't have a negative sign
			bcd(15 downto 12) <= "1111" when ( data(15) = '1' and (bcd(11 downto 0) /= 0 )) else "1010";

			-- Two's complement of data
			unsigned_data <= ( not(data) + 1 ) when data(15) = '1' else data;

			-- Scale value
			temp <= ( unsigned_data * "1001" ) when sel /= "11" else "0000" & ( 25 - (data - 25) ); 
			unsigned_scaled_data <= "0000000000" & temp(19 downto 10) when sel /= "11" else temp;

			bcd_buf <= binary_to_bcd( unsigned_scaled_data(15 downto 0) );

			with sel select
				bcd(11 downto 0) <= bcd_buf(7 downto 0) & "1011" when "11",
										  bcd_buf(11 downto 0) when others;
	

end Behavioral;
