--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    08/16/2011
-- Module Name:    PmodGYRO_Demo
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: This demo configures the PmodGYRO to output data at a rate of 100 Hz
-- 				 with 8.75 mdps/digit at 250 dps maximum.  SPI mode 3 is used for data
--					 communication with the PmodGYRO.
--
--					 Switches SW3 and SW2 are used to select temperature or axis data that is 
--					 to be displayed on the seven segment display (SSD).  For details about
--					 selecting data see below.
--
--						SW3  |  SW2  |  Display Data
--						----------------------------
--						 0   |   0   |  X axis data
--						 0	  |   1   |  Y axis data
--						 1   |   0   |  Z axis data
--						 1   |   1   |  Temperature
--
--  Inputs:
--		clk 						Base system clock of 100 MHz
--		sw[0]						Reset signal
--		sw[1] 					Start tied to external user input
--		sw[2]						Data select bit 0
--		sw[3]						Data select bit 1
--		sw[4]						Select hex display or decimal display
--		JA[2] 					Master in slave out (MISO)
--		
--  Outputs:
--		JA[0]						Slave select (SS)
--		JA[1]						Master out slave in (MOSI)
--		JA[3]						Serial clock (SCLK)
--		seg						Cathodes on SSD
--		dp							Decimal on SSD
--		an							Anodes on SSD
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
entity PmodGYRO_Demo is
    Port ( sw : in  STD_LOGIC_VECTOR (4 downto 0);
			  clk : in STD_LOGIC;
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           seg : out  STD_LOGIC_VECTOR (6 downto 0);
           dp : out  STD_LOGIC;
           JA : inout  STD_LOGIC_VECTOR (3 downto 0);
           z_axis_data: inout STD_LOGIC_VECTOR (15 downto 0));
end PmodGYRO_Demo;

architecture Behavioral of PmodGYRO_Demo is

-- ==============================================================================
-- 									Component Declarations
-- ==============================================================================
			
			component master_interface
				port ( begin_transmission : out std_logic;
						 recieved_data : in std_logic_vector(7 downto 0);
						 end_transmission : in std_logic;
						 clk : in std_logic;
						 rst : in std_logic;
						 start : in std_logic;
						 slave_select : out std_logic;
						 send_data : out std_logic_vector(7 downto 0);
						 temp_data : out std_logic_vector(7 downto 0);
						 x_axis_data : out std_logic_vector(15 downto 0);
						 y_axis_data : out std_logic_vector(15 downto 0);
						 z_axis_data : out std_logic_vector(15 downto 0));
			end component;


			component spi_interface
				port ( begin_transmission : in std_logic;
						 slave_select : in std_logic;
						 send_data : in std_logic_vector(7 downto 0);
						 miso : in std_logic;
						 clk : in std_logic;
						 rst : in std_logic;
						 recieved_data : out std_logic_vector( 7 downto 0);
						 end_transmission : out std_logic;
						 mosi : out std_logic;
						 sclk : out std_logic);
			end component;


			component display_controller
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
			end component;

-- ==============================================================================
-- 								  Signals, Constants, Types
-- ==============================================================================

			signal begin_transmission : std_logic;
			signal end_transmission : std_logic;
			signal send_data : std_logic_vector(7 downto 0);
			signal recieved_data : std_logic_vector(7 downto 0);
			signal temp_data : std_logic_vector(7 downto 0);
			signal x_axis_data : std_logic_vector(15 downto 0);
			signal y_axis_data : std_logic_vector(15 downto 0);
			-- signal z_axis_data : std_logic_vector(15 downto 0);
			signal slave_select : std_logic;

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			----------------------------------------
			--		Serial Port Interface Controller
			----------------------------------------
			C0 : master_interface port map (
						begin_transmission => begin_transmission,
						end_transmission => end_transmission,
						send_data => send_data,
						recieved_data => recieved_data,
						clk => clk,
						rst => sw(0),
						slave_select => slave_select,
						start => sw(1),
						temp_data => temp_data,
						x_axis_data => x_axis_data,
						y_axis_data => y_axis_data,
						z_axis_data => z_axis_data
			);

			----------------------------------------
			--		    Serial Port Interface
			----------------------------------------
			C1 : spi_interface port map (
						begin_transmission => begin_transmission,
						slave_select => slave_select,
						send_data => send_data,
						recieved_data => recieved_data,
						miso => JA(2),
						clk => clk,
						rst => sw(0),
						end_transmission => end_transmission,
						mosi => JA(1),
						sclk => JA(3)
			);


			----------------------------------------
			--		      Display Controller
			----------------------------------------
			C2 : display_controller port map (
						clk => clk,
						rst => sw(0),
						sel => sw(3 downto 2),
						temp_data => temp_data,
						x_axis => x_axis_data(15 downto 0),
						y_axis => y_axis_data(15 downto 0),
						z_axis => z_axis_data(15 downto 0),
						dp => dp,
						an => an,
						seg => seg,
						display_sel => sw(4)
			); 

			--  Assign slave select output
			JA(0) <= slave_select;


end Behavioral;

