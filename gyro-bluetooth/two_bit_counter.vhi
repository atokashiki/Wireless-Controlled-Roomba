
-- VHDL Instantiation Created from source file two_bit_counter.vhd -- 15:34:41 03/07/2017
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT two_bit_counter
	PORT(
		dclk : IN std_logic;
		rst : IN std_logic;          
		control : OUT std_logic_vector(1 downto 0)
		);
	END COMPONENT;

	Inst_two_bit_counter: two_bit_counter PORT MAP(
		dclk => ,
		rst => ,
		control => 
	);


