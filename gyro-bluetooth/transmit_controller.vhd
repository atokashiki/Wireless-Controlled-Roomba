----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:40:02 03/03/2017 
-- Design Name: 
-- Module Name:    transmit_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity transmit_controller is
  Port (
    N_SW : in  STD_LOGIC_VECTOR (4 downto 0);
    BTN : in  STD_LOGIC_VECTOR (4 downto 0);
    N_SEG : inout STD_LOGIC_VECTOR (6 downto 0);
    N_SEG_AN: out STD_LOGIC_VECTOR (3 downto 0);
    UART_TXD : out  STD_LOGIC;
    PMODBT_RST : out  STD_LOGIC;
    PMODBT_CTS : out STD_LOGIC;
    JA : inout  STD_LOGIC_VECTOR (3 downto 0);
    CLK : in std_logic);
end transmit_controller;

architecture Behavioral of transmit_controller is

-- ==============================================================================
-- 									Component Declarations
-- ==============================================================================

component PmodGYRO_Demo
    port ( sw: in  std_logic_vector (4 downto 0);
			  clk: in std_logic;
           an: out  std_logic_vector (3 downto 0);
           seg: out  std_logic_vector (6 downto 0);
           dp: out  std_logic;
           JA: inout  std_logic_vector (3 downto 0);
           z_axis_data: inout std_logic_vector (15 downto 0));
end component;

component GPIO_demo
    port ( SW : in  std_logic_vector (7 downto 0);
           BTN : in  std_logic_vector (4 downto 0);
           CLK : in  std_logic;
           LED : out  std_logic_vector (7 downto 0);
           SSEG_CA : out  std_logic_vector (7 downto 0);
           SSEG_AN : out  std_logic_vector (3 downto 0);
           UART_TXD : out  std_logic;
           PMODBT_RST : out  std_logic;
           PMODBT_CTS : out  std_logic;
           Z_DIRECTION : in STD_LOGIC_VECTOR (15 downto 0));
end component;

-- ==============================================================================
-- 								  Signals, Constants, Types
-- ==============================================================================
signal an: std_logic_vector (3 downto 0);
signal seg: std_logic_vector (6 downto 0);
signal dp: std_logic;
-- signal ja: std_logic_vector (3 downto 0);
signal sw2 : std_logic_vector (7 downto 0);

signal led : std_logic_vector (7 downto 0);
signal sseg_ca : std_logic_vector (7 downto 0);
signal sseg_an : std_logic_vector (3 downto 0);
signal Z_AXIS : std_logic_vector (15 downto 0);

-- ==============================================================================
-- 										  Implementation
-- ==============================================================================

begin

GYRO : PmodGYRO_Demo port map (
  sw => n_sw,
  clk => clk,
  an => n_seg_an,
  seg => n_seg,
  dp => dp,
  JA => ja,
  z_axis_data => Z_AXIS
);

BLUETOOTH : GPIO_demo port map (
  SW => sw2,
  BTN => btn,
  CLK => clk,
  LED => led,
  SSEG_CA => sseg_ca,
  SSEG_AN => sseg_an,
  UART_TXD => uart_txd,
  PMODBT_RST => pmodbt_rst,
  PMODBT_CTS => pmodbt_cts,
  Z_DIRECTION => Z_AXIS  
);

end Behavioral;

