--////////////////////////////////////////////////////////////////////////////////////////
-- Company: Digilent Inc.
-- Engineer: Andrew Skreen
-- 
-- Create Date:    07/11/2012
-- Module Name:    spi_interface
-- Project Name: 	 PmodGYRO_Demo
-- Target Devices: Nexys3
-- Tool versions:  ISE 14.1
-- Description: This module is the main interface to the PmodGYRO, it produces
--					 slave select (SS), master out slave in (MOSI), and serial clock (SCLK)
--					 signals used in SPI communcation.  Data is read on the master in slave out
--					 (MISO) input.  SPI mode 3 is used.
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
entity spi_interface is
	port ( send_data : in std_logic_vector(7 downto 0);
			 begin_transmission : in std_logic;
			 slave_select : in std_logic;
			 miso : in std_logic;
			 clk : in std_logic;
			 rst : in std_logic;
			 recieved_data : out std_logic_vector( 7 downto 0);
			 end_transmission : out std_logic;
			 mosi : out std_logic;
			 sclk : out std_logic);
end spi_interface;

architecture Behavioral of spi_interface is

-- ==============================================================================
-- 								  Signals, Constants, Types
-- ==============================================================================

			constant SPI_CLK_COUNT_MAX : std_logic_vector(11 downto 0) := X"FFF";
			signal spi_clk_count : std_logic_vector(11 downto 0);

			signal sclk_buffer : std_logic;
			signal sclk_previous : std_logic;

			constant RX_COUNT_MAX : std_logic_vector(3 downto 0) := X"8";
			signal rx_count : std_logic_vector(3 downto 0);

			signal shift_register : std_logic_vector(7 downto 0);

			type RxTxTYPE is (idle , rx_tx , hold);
			signal RxTxSTATE : RxTxTYPE;
			
-- ==============================================================================
-- 										  Implementation
-- ==============================================================================
begin

			-- operates in SPI mode3
			tx_rx_process : process( clk ) begin
			if rising_edge( clk ) then
				if RST = '1' then 
					mosi <= '1';
					RxTxSTATE <= idle;
					recieved_data <= ( others => '0' );
					shift_register <= ( others => '0' );
				else
					case RxTxSTATE is
						
						-- idle
						when idle =>
						end_transmission <= '0';
							if begin_transmission = '1' then
								RxTxSTATE <= rx_tx;
								rx_count <= ( others => '0' );
								shift_register <= send_data;
							end if;

						-- rx_tx
						when rx_tx =>
							--send bit
							if rx_count < RX_COUNT_MAX then
								if sclk_previous = '1' and sclk_buffer = '0' then
									mosi <= shift_register(7);
								--recieve bit
								elsif sclk_previous = '0' and sclk_buffer = '1' then
									shift_register(7 downto 1) <= shift_register(6 downto 0) ;
									shift_register(0) <= miso;
									rx_count <= rx_count + 1;
								end if;
							else 
								RxTxSTATE <= hold;
								end_transmission <='1';
								recieved_data <= shift_register;
							end if;

						-- hold
						when hold =>
							end_transmission <= '0';
							if slave_select = '1' then
								mosi <= '1';
								RxTxSTATE <= idle;
							elsif begin_transmission = '1' then
								RxTxSTATE <= rx_tx;
								rx_count <= ( others => '0' );
								shift_register <= send_data;
							end if;

						-- default
						when others =>
							null;
					end case;
				end if;
			end if;
			end process;

			-----------------------------------------------------
			-- 					   Serial Clock
			-----------------------------------------------------
			spi_clk_generation : process( clk ) begin
			if rising_edge( clk ) then 
				if RST = '1' then
					sclk_previous <= '1';
					sclk_buffer <= '1';
					spi_clk_count <= ( others => '0' );
				
				elsif RxTxSTATE = rx_tx then
					if spi_clk_count = SPI_CLK_COUNT_MAX then
						sclk_buffer <= not sclk_buffer;
						spi_clk_count <= ( others => '0' );
					else
						sclk_previous <= sclk_buffer;
						spi_clk_count <= spi_clk_count + 1;
					end if;
				else 
					sclk_previous <= '1';
				end if;
			end if;
			end process;

			-- Assign serial clock output
			sclk <= sclk_previous;

end Behavioral;

