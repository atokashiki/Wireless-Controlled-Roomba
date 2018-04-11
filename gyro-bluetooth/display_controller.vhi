
-- VHDL Instantiation Created from source file display_controller.vhd -- 15:32:54 03/07/2017
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT display_controller
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		sel : IN std_logic_vector(1 downto 0);
		temp_data : IN std_logic_vector(7 downto 0);
		x_axis : IN std_logic_vector(15 downto 0);
		y_axis : IN std_logic_vector(15 downto 0);
		z_axis : IN std_logic_vector(15 downto 0);
		display_sel : IN std_logic;          
		dp : OUT std_logic;
		an : OUT std_logic_vector(3 downto 0);
		seg : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;

	Inst_display_controller: display_controller PORT MAP(
		clk => ,
		rst => ,
		sel => ,
		temp_data => ,
		x_axis => ,
		y_axis => ,
		z_axis => ,
		dp => ,
		an => ,
		seg => ,
		display_sel => 
	);


