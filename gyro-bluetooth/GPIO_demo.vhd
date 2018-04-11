----------------------------------------------------------------------------
--	GPIO_demo.vhd -- Nexys3 GPIO/UART Demonstration Project
----------------------------------------------------------------------------
-- Author:  Sam Bobrowicz
--          Copyright 2011 Digilent, Inc.
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
--	The GPIO/UART Demo project demonstrates a simple usage of the Nexys3's 
-- GPIO and UART in an ISE design. The behavior is as follows:
--
--	      *The 8 User LEDs are tied to the 8 User Switches. While the center
--			 User button is pressed, the LEDs are instead tied to GND
--	      *The 7-Segment display counts from 0 to 9 on each of it 4
--        digits. This count is reset when the center button is pressed.
--        Also, single anodes of the 7-Segment display are blanked by
--	       holding BTNU, BTNL, BTND, or BTNR. Holding the center button 
--        blanks all the 7-Segment anodes.
--       *An introduction message is sent across the UART when the device
--        is finished being configured, and after the center User button
--        is pressed.
--       *A message is sent over UART whenever BTNU, BTNL, BTND, or BTNR is
--        pressed.
--       *Note that the center user button behaves as a user reset button
--        and is referred to as such in the code comments below
--        
--	All UART communication can be captured by attaching the UART port to a
-- computer running a Terminal program with 9600 Baud Rate, 8 data bits, no 
-- parity, and 1 stop bit.																
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
-- Revision History:
--  08/08/2011(SamB): Created using Xilinx Tools 13.2
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL; 

--The IEEE.std_logic_unsigned contains definitions that allow 
--std_logic_vector types to be used with the + operator to instantiate a 
--counter.
use IEEE.std_logic_unsigned.all;

entity GPIO_demo is
    Port ( SW : in  STD_LOGIC_VECTOR (7 downto 0);
           BTN : in  STD_LOGIC_VECTOR (4 downto 0);
           CLK : in  STD_LOGIC;
           LED : out  STD_LOGIC_VECTOR (7 downto 0);
           SSEG_CA : out  STD_LOGIC_VECTOR (7 downto 0);
			  SSEG_AN : out  STD_LOGIC_VECTOR (3 downto 0);
           UART_TXD : out  STD_LOGIC;
           PMODBT_RST : out  STD_LOGIC;
           PMODBT_CTS : out  STD_LOGIC;
           Z_DIRECTION : in STD_LOGIC_VECTOR (15 downto 0));
end GPIO_demo;

architecture Behavioral of GPIO_demo is

component UART_TX_CTRL
Port(
	SEND : in std_logic;
	DATA : in std_logic_vector(7 downto 0);
	CLK : in std_logic;          
	READY : out std_logic;
	UART_TX : out std_logic
	);
end component;

component btn_debounce
Port(
		BTN_I : in std_logic_vector(4 downto 0);
		CLK : in std_logic;          
		BTN_O : out std_logic_vector(4 downto 0)
		);
end component;

component data_interpreter
Port (
  DATA : in STD_LOGIC_VECTOR(15 downto 0);
  D1 : out STD_LOGIC_VECTOR(3 downto 0);
  D2 : out STD_LOGIC_VECTOR(3 downto 0);
  D3 : out STD_LOGIC_VECTOR(3 downto 0);
  D4 : out STD_LOGIC_VECTOR(3 downto 0)  
  );
end component;

component Data_Converter
Port (
   D1 : in  STD_LOGIC_VECTOR (3 downto 0);
   D2 : in  STD_LOGIC_VECTOR (3 downto 0);
   D3 : in  STD_LOGIC_VECTOR (3 downto 0);
   D4 : in  STD_LOGIC_VECTOR (3 downto 0);
   RESULT : out STD_LOGIC_VECTOR(10 downto 0)
  );
end component;
--The type definition for the UART state machine type. Here is a description of what
--occurs during each state:
-- RST_REG     -- Do Nothing. This state is entered after configuration or a user reset.
--                The state is set to LD_INIT_STR.
-- LD_INIT_STR -- The Welcome String is loaded into the sendStr variable and the strIndex
--                variable is set to zero. The welcome string length is stored in the StrEnd
--                variable. The state is set to SEND_CHAR.
-- SEND_CHAR   -- uartSend is set high for a single clock cycle, signaling the character
--                data at sendStr(strIndex) to be registered by the UART_TX_CTRL at the next
--                cycle. Also, strIndex is incremented (behaves as if it were post 
--                incremented after reading the sendStr data). The state is set to RDY_LOW.
-- RDY_LOW     -- Do nothing. Wait for the READY signal from the UART_TX_CTRL to go low, 
--                indicating a send operation has begun. State is set to WAIT_RDY.
-- WAIT_RDY    -- Do nothing. Wait for the READY signal from the UART_TX_CTRL to go high, 
--                indicating a send operation has finished. If READY is high and strEnd = 
--                StrIndex then state is set to WAIT_BTN, else if READY is high and strEnd /=
--                StrIndex then state is set to SEND_CHAR.
-- WAIT_BTN    -- Do nothing. Wait for a button press on BTNU, BTNL, BTND, or BTNR. If a 
--                button press is detected, set the state to LD_BTN_STR.
-- LD_BTN_STR  -- The Button String is loaded into the sendStr variable and the strIndex
--                variable is set to zero. The button string length is stored in the StrEnd
--                variable. The state is set to SEND_CHAR.
type UART_STATE_TYPE is (RST_REG, LD_INIT_STR, SEND_CHAR, RDY_LOW, WAIT_RDY, WAIT_BTN, LD_BTN_STR, LD_UP_STR, LD_DOWN_STR, LD_LEFT_STR, LD_RIGHT_STR);

--The CHAR_ARRAY type is a variable length array of 8 bit std_logic_vectors. 
--Each std_logic_vector contains an ASCII value and represents a character in
--a string. The character at index 0 is meant to represent the first
--character of the string, the character at index 1 is meant to represent the
--second character of the string, and so on.
type CHAR_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0);

constant TMR_CNTR_MAX : std_logic_vector(26 downto 0) := "101111101011110000100000000"; --"100,000,000 = clk cycles per second
constant TMR_VAL_MAX : std_logic_vector(3 downto 0) := "1001"; --9

constant MAX_STR_LEN : integer := 20;

constant RESET_STR_LEN : natural := 9;
constant BTN_STR_LEN : natural := 3;
constant Z_STR_LEN : natural := 18;

--Welcome string definition. Note that the values stored at each index
--are the ASCII values of the indicated character.
constant RESET_STR : CHAR_ARRAY(0 to 8) := (X"0A",  --\n
															  X"0D",  --\r
															  X"52",  --R
                                X"45",  --E
															  X"53",  --S
                                X"45",  --E                                
															  X"54",  --T
															  X"0A",  --\n
															  X"0D"); --\r
															  
--Button press string definition.
constant BTN_STR : CHAR_ARRAY(0 to 2) :=     
                               (X"63",  --c
															  X"0A",  --\n
															  X"0D"); --\r
                                
constant UP_STR : CHAR_ARRAY(0 to 2) :=     
                               (X"75",  --u
															  X"0A",  --\n
															  X"0D"); --\r
                                
constant DOWN_STR : CHAR_ARRAY(0 to 2) :=     
                               (X"64",  --d
															  X"0A",  --\n
															  X"0D"); --\r   

constant LEFT_STR : CHAR_ARRAY(0 to 2) :=     
                               (X"6C",  --l
															  X"0A",  --\n
															  X"0D"); --\r

constant RIGHT_STR : CHAR_ARRAY(0 to 2) :=     
                               (X"72",  --r
															  X"0A",  --\n
															  X"0D"); --\r                         


function blah( x : std_logic ) return std_logic_vector is
				variable ans : std_logic_vector(7 downto 0) := (others => '0');
begin
  if (x > '0') then
    ans := X"31";
  else
    ans := x"30";
  end if;
  
  return ans;
end blah;


--This is used to determine when the 7-segment display should be
--incremented
signal tmrCntr : std_logic_vector(26 downto 0) := (others => '0');

--This counter keeps track of which number is currently being displayed
--on the 7-segment.
signal tmrVal : std_logic_vector(3 downto 0) := (others => '0');

--Contains the current string being sent over uart.
signal sendStr : CHAR_ARRAY(0 to (MAX_STR_LEN - 1));

--Contains the length of the current string being sent over uart.
signal strEnd : natural;

--Contains the index of the next character to be sent over uart
--within the sendStr variable.
signal strIndex : natural;

--Used to determine when a button press has occured
signal btnReg : std_logic_vector (3 downto 0) := "0000";
signal btnDetect : std_logic;
signal btnDetectUp : std_logic;
signal btnDetectDown : std_logic;
signal btnDetectLeft : std_logic;
signal btnDetectRight : std_logic;

--UART_TX_CTRL control signals
signal uartRdy : std_logic;
signal uartSend : std_logic := '0';
signal uartData : std_logic_vector (7 downto 0):= "00000000";
signal uartTX : std_logic;

--Current uart state signal
signal uartState : UART_STATE_TYPE := RST_REG;

--Debounced btn signals used to prevent single button presses
--from being interpreted as multiple button presses.
signal btnDeBnc : std_logic_vector(4 downto 0);

--data interpreter signal
signal Z_D1 : std_logic_vector(3 downto 0);
signal Z_D2 : std_logic_vector(3 downto 0);
signal Z_D3 : std_logic_vector(3 downto 0);
signal Z_D4 : std_logic_vector(3 downto 0);
signal result : std_logic_vector(10 downto 0);

begin

PMODBT_RST <= '1';
PMODBT_CTS <= '0';

with BTN(4) select
	LED <= SW 			when '0',
			 "00000000" when others;

with BTN(4) select
	SSEG_AN <= btnDeBnc(3 downto 0)	when '0',
				  "1111" 			when others;

--This process controls the counter that triggers the 7-segment
--to be incremented. It counts 100,000,000 and then resets.		  
timer_counter_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if ((tmrCntr = TMR_CNTR_MAX) or (BTN(4) = '1')) then
			tmrCntr <= (others => '0');
		else
			tmrCntr <= tmrCntr + 1;
		end if;
	end if;
end process;

--This process increments the digit being displayed on the 
--7-segment display every second.
timer_inc_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (BTN(4) = '1') then
			tmrVal <= (others => '0');
		elsif (tmrCntr = TMR_CNTR_MAX) then
			if (tmrVal = TMR_VAL_MAX) then
				tmrVal <= (others => '0');
			else
				tmrVal <= tmrVal + 1;
			end if;
		end if;
	end if;
end process;

--This select statement encodes the value of tmrVal to the necessary
--cathode signals to display it on the 7-segment
with tmrVal select
	SSEG_CA <= "11000000" when "0000",
				  "11111001" when "0001",
				  "10100100" when "0010",
				  "10110000" when "0011",
				  "10011001" when "0100",
				  "10010010" when "0101",
				  "10000010" when "0110",
				  "11111000" when "0111",
				  "10000000" when "1000",
				  "10010000" when "1001",
				  "11111111" when others;

btn_reg_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		btnReg <= btnDeBnc(3 downto 0);
	end if;
end process;

--btnDetect goes high for a single clock cycle when a btn press is
--detected. This triggers a UART message to begin being sent.
btnDetect <= '1' when (false) else
				  '0';
btnDetectUp <= '1' when ((btnReg(3)='0' and btnDeBnc(3)='1')) else
				  '0';
btnDetectDown <= '1' when ((btnReg(1)='0' and btnDeBnc(1)='1')) else
				  '0';
btnDetectLeft <= '1' when ((to_integer(signed(Z_DIRECTION)) > 1000)) else
				  '0';
btnDetectRight <= '1' when ((to_integer(signed(Z_DIRECTION)) < -1000)) else
				  '0';          
				  

--Next Uart state logic (states described above)
next_uartState_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (btnDeBnc(4) = '1') then
			uartState <= RST_REG;
    elsif (btnDetectUp = '1') then
      uartState <= LD_UP_STR;
    elsif (btnDetectDown = '1') then
      uartState <= LD_DOWN_STR;      
		else	
			case uartState is 
			when RST_REG =>
				uartState <= LD_INIT_STR;
			when LD_INIT_STR =>
				uartState <= SEND_CHAR;
			when SEND_CHAR =>
				uartState <= RDY_LOW;
			when RDY_LOW =>
				uartState <= WAIT_RDY;
			when WAIT_RDY =>
				if (uartRdy = '1') then
					if (strEnd = strIndex) then
						uartState <= WAIT_BTN;
					else
						uartState <= SEND_CHAR;
					end if;
				end if;
			when WAIT_BTN =>
				if (btnDetect = '1') then
					uartState <= LD_BTN_STR;
        elsif (btnDetectLeft = '1') then
          uartState <= LD_LEFT_STR;
        elsif (btnDetectRight = '1') then
          uartState <= LD_RIGHT_STR;
				end if;
			when LD_BTN_STR =>
				uartState <= SEND_CHAR;
      when LD_UP_STR =>
				uartState <= SEND_CHAR;
      when LD_DOWN_STR =>
				uartState <= SEND_CHAR;        
      when LD_LEFT_STR =>
				uartState <= SEND_CHAR;
      when LD_RIGHT_STR =>
				uartState <= SEND_CHAR;
			when others=> --should never be reached
				uartState <= RST_REG;
			end case;
		end if ;
	end if;
end process;

--Loads the sendStr and strEnd signals when a LD state is
--is reached.
string_load_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (uartState = LD_INIT_STR) then
			sendStr(0 to 8) <= RESET_STR;
			strEnd <= RESET_STR_LEN;
		elsif (uartState = LD_BTN_STR) then
			sendStr(0 to 2) <= BTN_STR;
			strEnd <= BTN_STR_LEN;
    elsif (uartState = LD_UP_STR) then
			sendStr(0 to 2) <= UP_STR;
			strEnd <= BTN_STR_LEN;
    elsif (uartState = LD_DOWN_STR) then
			sendStr(0 to 2) <= DOWN_STR;
			strEnd <= BTN_STR_LEN;
    elsif (uartState = LD_LEFT_STR) then
			sendStr(0 to 2) <= LEFT_STR;
			strEnd <= BTN_STR_LEN;
--      sendStr(0 to 17) <= (blah(Z_DIRECTION(15)),blah(Z_DIRECTION(14)), blah(Z_DIRECTION(13)), blah(Z_DIRECTION(12)), 
--                          blah(Z_DIRECTION(11)),blah(Z_DIRECTION(10)), blah(Z_DIRECTION(9)), blah(Z_DIRECTION(8)), 
--                          blah(Z_DIRECTION(7)),blah(Z_DIRECTION(6)), blah(Z_DIRECTION(5)), blah(Z_DIRECTION(4)), 
--                          blah(Z_DIRECTION(3)),blah(Z_DIRECTION(2)), blah(Z_DIRECTION(1)), blah(Z_DIRECTION(0)), 
--                          X"0A",  X"0D");
--			strEnd <= Z_STR_LEN;
    elsif (uartState = LD_RIGHT_STR) then
			sendStr(0 to 2) <= RIGHT_STR;
      strEnd <= BTN_STR_LEN;
--      sendStr(0 to 17) <= (blah(Z_DIRECTION(15)),blah(Z_DIRECTION(14)), blah(Z_DIRECTION(13)), blah(Z_DIRECTION(12)), 
--                          blah(Z_DIRECTION(11)),blah(Z_DIRECTION(10)), blah(Z_DIRECTION(9)), blah(Z_DIRECTION(8)), 
--                          blah(Z_DIRECTION(7)),blah(Z_DIRECTION(6)), blah(Z_DIRECTION(5)), blah(Z_DIRECTION(4)), 
--                          blah(Z_DIRECTION(3)),blah(Z_DIRECTION(2)), blah(Z_DIRECTION(1)), blah(Z_DIRECTION(0)), 
--                          X"0A",  X"0D");
--			strEnd <= Z_STR_LEN;
		end if;
	end if;
end process;

--Conrols the strIndex signal so that it contains the index
--of the next character that needs to be sent over uart
char_count_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (uartState = LD_INIT_STR or uartState = LD_BTN_STR or uartState = LD_UP_STR or uartState = LD_DOWN_STR or uartState = LD_LEFT_STR or uartState = LD_RIGHT_STR) then
			strIndex <= 0;
		elsif (uartState = SEND_CHAR) then
			strIndex <= strIndex + 1;
		end if;
	end if;
end process;

--Controls the UART_TX_CTRL signals
char_load_process : process (CLK)
begin
	if (rising_edge(CLK)) then
		if (uartState = SEND_CHAR) then
			uartSend <= '1';
			uartData <= sendStr(strIndex);
		else
			uartSend <= '0';
		end if;
	end if;
end process;

--Debounces btn signals
Inst_btn_debounce: btn_debounce port map(
		BTN_I => BTN,
		CLK => CLK,
		BTN_O => btnDeBnc
	);

--Component used to send a byte of data over a UART line.
Inst_UART_TX_CTRL: UART_TX_CTRL port map(
		SEND => uartSend,
		DATA => uartData,
		CLK => CLK,
		READY => uartRdy,
		UART_TX => uartTX 
	);

UART_TXD <= uartTX;

--data interpreter takes data and creates int
interpreter: data_interpreter port map(
    data => Z_DIRECTION,
    D1 => Z_D1,
    D2 => Z_D2,
    D3 => Z_D3,
    D4 => Z_D4
    );
    
converter: Data_Converter port map(
    D1 => Z_D1,
    D2 => Z_D2,
    D3 => Z_D3,
    D4 => Z_D4,
    result => result
  );
end Behavioral;

