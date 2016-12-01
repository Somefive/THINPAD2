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
			  rdn : in STD_LOGIC;
			  data_ready : OUT STD_LOGIC;
			  key_value : out  STD_LOGIC_VECTOR (7 downto 0));
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
signal codeBuffer : std_logic_vector(7 downto 0);
begin
	lock_keyCode <= codeBuffer when rdn = '0';
	with lock_keyCode select
		key_value(7 downto 0) <= 
			"01000001" when "00011100" , -- A
			"01000010" when "00110010" , -- B
			"01000011" when "00100001" , -- C
			"01000100" when "00100011" , -- D 
			"01000101" when "00100100" , -- E
			"01000110" when "00101011" , -- F
			"01000111" when "00110100" , -- G
			"01001000" when "00110011" , -- H
			"01001001" when "01000011" , -- I
			"01001010" when "00111011" , -- J
			"01001011" when "01000010" , -- K
			"01001100" when "01001011" , -- L
			"01001101" when "00111010" , -- M
			"01001110" when "00110001" , -- N
			"01001111" when "01000100" , -- O
			"01010000" when "01001101" , -- P
			"01010001" when "00010101" , -- Q
			"01010010" when "00101101" , -- R
			"01010011" when "00011011" , -- S
			"01010100" when "00101100" , -- T
			"01010101" when "00111100" , -- U
			"01010110" when "00101010" , -- V
			"01010111" when "00011101" , -- W
			"01011000" when "00100010" , -- X
			"01011001" when "00110101" , -- Y
			"01011010" when "00011010" , -- Z
			"00101100" when "01000001" , -- ,
			"00101110" when "01001001" , -- .
			
			"00110000" when "01000101" , -- 0
			"00110001" when "00010110" , -- 1
			"00110010" when "00011110" , -- 2
			"00110011" when "00100110" , -- 3
			"00110100" when "00100101" , -- 4
			"00110101" when "00101110" , -- 5
			"00110110" when "00110110" , -- 6
			"00110111" when "00111101" , -- 7
			"00111000" when "00111110" , -- 8
			"00111001" when "01000110" , -- 9
			
			"00101101" when "01001110" , -- -
			"00111101" when "01010101" , -- =
			"00011011" when "01110110" , -- ESC
			"00001000" when "01100110" , -- BKSP
			"00001101" when "01011010" , -- ENTER
			"00100000" when "00101001" , -- SPACE
			
			"01110000" when "00000101" , -- F1
			"01110001" when "00000110" , -- F2
			"01110010" when "00000100" , -- F3
			"01110011" when "00001100" , -- F4
			"01110100" when "00000011" , -- F5
			"01110101" when "00001011" , -- F6
			"01110110" when "10000011" , -- F7
			"01110111" when "00001010" , -- F8
			"01111000" when "00000001" , -- F9
			"01111001" when "00001001" , -- F10
			"01111010" when "01111000" , -- F11
			"01111011" when "00000111" , -- F12
			"11111111" when others;

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
			codeBuffer <= (others => '0');
		elsif(clk'event and clk='1')then
			case state is
				when "00" =>
					if(keyCode = "11110000")then
						state <= "01";
					end if;
				when "01" =>
					if(keyCode="11110000")then
						state <= "01";
					else
						codeBuffer <= keyCode;
						state <= "00";
					end if;
				when others =>
			end case;
		end if;
	end process;
	
	process(state, rdn)
	begin
		if(rdn='0')then
			data_ready <= '0';
		else
			if(state(0)'event and state(0)='0')then
				data_ready <= '1';
			end if;
		end if;
	end process;
end Behavioral;

