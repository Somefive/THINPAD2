----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:18:57 11/30/2016 
-- Design Name: 
-- Module Name:    KeyboardBlock - Behavioral 
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

entity KeyboardBlock is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC;
			  data_ready : OUT STD_LOGIC;
			  key_value : out  STD_LOGIC_VECTOR (15 downto 0));
end KeyboardBlock;

architecture Behavioral of KeyboardBlock is
component PS2Keyboard is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC;
           keyCode : out  STD_LOGIC_VECTOR (7 downto 0));
end component;
signal state : std_logic_vector(1 downto 0);
signal keyCode : std_logic_vector(7 downto 0);
signal lock_keyCode : std_logic_vector(7 downto 0);
signal hold_time : integer range 0 to 15;
begin
	key_value(15 downto 6) <= (others => '0');
	with lock_keyCode select
		key_value(5 downto 0) <= 
			"000001" when "00011100" , -- A
			"000010" when "00110010" , -- B
			"000011" when "00100001" , -- C
			"000100" when "00100011" , -- D 
			"000101" when "00100100" , -- E
			"000110" when "00101011" , -- F
			"000111" when "00110100" , -- G
			"001000" when "00110011" , -- H
			"001001" when "01000011" , -- I
			"001010" when "00111011" , -- J
			"001011" when "01000010" , -- K
			"001100" when "01001011" , -- L
			"001101" when "00111010" , -- M
			"001110" when "00110001" , -- N
			"001111" when "01000100" , -- O
			"010000" when "01001101" , -- P
			"010001" when "00010101" , -- Q
			"010010" when "00101101" , -- R
			"010011" when "00011011" , -- S
			"010100" when "00101100" , -- T
			"010101" when "00111100" , -- U
			"010110" when "00101010" , -- V
			"010111" when "00011101" , -- W
			"011000" when "00100010" , -- X
			"011001" when "00110101" , -- Y
			"011010" when "00011010" , -- Z
			"011011" when "01000001" , -- ,
			"011100" when "01001001" , -- .
			
			"110000" when "01000101" , -- 0
			"110001" when "00010110" , -- 1
			"110010" when "00011110" , -- 2
			"110011" when "00100110" , -- 3
			"110100" when "00100101" , -- 4
			"110101" when "00101110" , -- 5
			"110110" when "00110110" , -- 6
			"110111" when "00111101" , -- 7
			"111000" when "00111110" , -- 8
			"111001" when "01000110" , -- 9
			
			"100100" when "01001110" , -- -
			"100101" when "01010101" , -- =
			"100110" when "01110110" , -- ESC
			"100111" when "01100110" , -- BKSP
			"011110" when "01011010" , -- ENTER
			"000000" when "00101001" , -- SPACE
			"111111" when others;

	keyboard_entity : PS2Keyboard port map(
		clk,
		rst,
		ps2clk,
		ps2data,
		keyCode
	);
	
	process(rst, clk)
	begin
		if(rst='0')then
			state <= "00";
			data_ready <= '0';
			lock_keyCode <= (others => '0');
		elsif(clk'event and clk='1')then
			if(hold_time>0) then
				hold_time <= hold_time - 1;
				data_ready <= '1';
			else
				data_ready <= '0';
			end if;
			
			case state is
				when "00" =>
					if(keyCode = "11110000")then
						state <= "01";
					end if;
				when "01" =>
					if(keyCode="11110000")then
						state <= "01";
					else
						lock_keyCode <= keyCode;
						state <= "00";
						hold_time <= 8;
					end if;
				when others =>
			end case;
		end if;
	end process;
end Behavioral;

