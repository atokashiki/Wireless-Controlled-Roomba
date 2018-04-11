--/////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    08/16/2011
-- Module Name:    display_controller
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: This module formats all data received from the PmodGYRO and
--					 displays it on the seven segment display (SSD).
--
-- Revision History: 
-- 						Revision 0.01 - File Created (Andrew Skreen)
--							Revision 1.00 - Added Comments and Converted to VHDL (Josh Sackos)
--/////////////////////////////////////////////////////////////////////////////////////
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ==============================================================================
-- 										  Define Module
-- ==============================================================================
entity display_controller is
    Port ( clk : in  STD_LOGIC;
			  rst : in  STD_LOGIC;
			  sel : in STD_LOGIC_VECTOR (1 downto 0);
			  temp_data : in STD_LOGIC_VECTOR (7 downto 0);
           x_axis : in  STD_LOGIC_VECTOR (15 downto 0);
           y_axis : in  STD_LOGIC_VECTOR (15 downto 0);
           z_axis : in  STD_LOGIC_VECTOR (15 downto 0);
			  dp : out  STD_LOGIC;
			  an : out  STD_LOGIC_VECTOR (3 downto 0);
			  seg : out  STD_LOGIC_VECTOR (6 downto 0);
			  display_sel : in STD_LOGIC);
end display_controller;

architecture Behavioral of display_controller is


-- ==============================================================================
-- 									Component Declarations
-- ==============================================================================

			Component data_controller
				Port(  display_sel : in STD_LOGIC;
						 sel : in STD_LOGIC_VECTOR(1 downto 0);
						 data : in STD_LOGIC_VECTOR (15 downto 0);
						 D1 : out STD_LOGIC_VECTOR (3 downto 0);
						 D2 : out STD_LOGIC_VECTOR (3 downto 0);
						 D3 : out STD_LOGIC_VECTOR (3 downto 0);
						 D4 : out STD_LOGIC_VECTOR (3 downto 0));
			End Component;


			Component display_clk
				Port(  clk : in STD_LOGIC;
						 rst : in STD_LOGIC;
						 dclk : out STD_LOGIC);
			End Component;


			Component anode_decoder
				Port(  control : in STD_LOGIC_VECTOR (1 downto 0);
						 anode : out STD_LOGIC_VECTOR (3 downto 0));
			End Component;


			Component seven_seg_decoder
				Port(  num_in : in STD_LOGIC_VECTOR (3 downto 0);
						 control : in STD_LOGIC_VECTOR (1 downto 0);
						 seg_out : out STD_LOGIC_VECTOR (6 downto 0);
						 display_sel : in STD_LOGIC);
			End Component;


			Component two_bit_counter
				Port(  dclk : in STD_LOGIC;
						 rst : in STD_LOGIC;
						 control : out STD_LOGIC_VECTOR (1 downto 0));
			End Component;


			Component digit_select
				Port(  D1 : in STD_LOGIC_VECTOR (3 downto 0);
						 D2 : in STD_LOGIC_VECTOR (3 downto 0);
						 D3 : in STD_LOGIC_VECTOR (3 downto 0);
						 D4 : in STD_LOGIC_VECTOR (3 downto 0);
						 control : in STD_LOGIC_VECTOR (1 downto 0);
						 digit : out STD_LOGIC_VECTOR (3 downto 0));
			End Component;


			Component decimal_select
				Port(  control : in STD_LOGIC_VECTOR (1 downto 0);
						 dp : out STD_LOGIC);
			End Component;


			Component data_select
				Port(  x_axis : in STD_LOGIC_VECTOR (15 downto 0);
						 y_axis : in STD_LOGIC_VECTOR (15 downto 0);
						 z_axis : in STD_LOGIC_VECTOR (15 downto 0);
						 temp_data : in STD_LOGIC_VECTOR (7 downto 0);
						 data : out STD_LOGIC_VECTOR (15 downto 0);
						 sel : in STD_LOGIC_VECTOR (1 downto 0));
			End Component;

-- ==============================================================================
-- 								  Signals, Constants, Types
-- ==============================================================================

			signal control : STD_LOGIC_VECTOR (1 downto 0);
			signal dclk : STD_LOGIC;
			signal D1 : STD_LOGIC_VECTOR (3 downto 0);
			signal D2 : STD_LOGIC_VECTOR (3 downto 0);
			signal D3 : STD_LOGIC_VECTOR (3 downto 0);
			signal D4 : STD_LOGIC_VECTOR (3 downto 0);
			signal digit : STD_LOGIC_VECTOR (3 downto 0);
			signal data : STD_LOGIC_VECTOR (15 downto 0);
			signal anodes : STD_LOGIC_VECTOR (3 downto 0);

			signal dispSel : STD_LOGIC;

-- ==============================================================================
-- 										Implementation
-- ==============================================================================
begin

			-----------------------------------------------------
			-- 		Formats data received from PmodGYRO
			-----------------------------------------------------
			C0 : data_controller port map (
						display_sel => dispSel,
						sel => sel,
						data => data,
						D1 => D1,
						D2 => D2,
						D3 => D3,
						D4 => D4
			);

			-----------------------------------------------------
			-- 		  Clock for display components
			-----------------------------------------------------
			C1 : display_clk port map(
						clk => clk,
						rst => rst,
						dclk => dclk
			);

			-----------------------------------------------------
			-- Produces anode pattern to illuminate digit on SSD
			-----------------------------------------------------
			C2 : anode_decoder port map(
						anode => anodes,
						control => control
			);

			-----------------------------------------------------
			-- Produces cathode pattern to dipslay digits on SSD
			-----------------------------------------------------
			C3 : seven_seg_decoder port map(
						num_in => digit,
						control => control,
						seg_out => seg,
						display_sel => dispSel
			);

			-----------------------------------------------------
			--			    Provides select/control signal
			-----------------------------------------------------
			C4 : two_bit_counter port map(
						dclk => dclk,
						rst => rst,
						control => control
			);

			-----------------------------------------------------
			-- 			         Digit data mux
			-----------------------------------------------------
			C5 : digit_select port map(
						D1 => D1,
						D2 => D2,
						D3 => D3,
						D4 => D4,
						control => control,
						digit => digit
			);

			-----------------------------------------------------
			--				   Anode for the decimal on SSD
			-----------------------------------------------------
			C6 : decimal_select port map(
						control => control,
						dp => dp
			);

			-----------------------------------------------------
			--    Select temperature or axis data to display
			-----------------------------------------------------
			C7 : data_select port map(
						x_axis => x_axis,
						y_axis => y_axis,
						z_axis => z_axis,
						temp_data => temp_data,
						sel => sel,
						data => data
			);

			-- Both select bits asserted, temperature selected, display decimal value
			dispSel <= '1' when (display_sel = '1' OR sel = "11") else '0';

			-- Do not display anything if reset
			an <= "1111" when rst = '1' else anodes;

end Behavioral;

