
-- VHDL Instantiation Created from source file GPIO_demo.vhd -- 16:15:54 03/14/2017
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT GPIO_demo
	PORT(
		SW : IN std_logic_vector(7 downto 0);
		BTN : IN std_logic_vector(4 downto 0);
		CLK : IN std_logic;
		Z_DIRECTION : IN std_logic_vector(15 downto 0);          
		LED : OUT std_logic_vector(7 downto 0);
		SSEG_CA : OUT std_logic_vector(7 downto 0);
		SSEG_AN : OUT std_logic_vector(3 downto 0);
		UART_TXD : OUT std_logic;
		PMODBT_RST : OUT std_logic;
		PMODBT_CTS : OUT std_logic
		);
	END COMPONENT;

	Inst_GPIO_demo: GPIO_demo PORT MAP(
		SW => ,
		BTN => ,
		CLK => ,
		LED => ,
		SSEG_CA => ,
		SSEG_AN => ,
		UART_TXD => ,
		PMODBT_RST => ,
		PMODBT_CTS => ,
		Z_DIRECTION => 
	);


