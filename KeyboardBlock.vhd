----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:24:58 11/29/2016 
-- Design Name: 
-- Module Name:    keyboard - Behavioral 
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

entity keyboard is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC;
           data_ready : out  STD_LOGIC;
           keyValue : out  STD_LOGIC_VECTOR (15 downto 0));
end keyboard;

architecture Behavioral of keyboard is

component PS2Keyboard is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC;
           keycode : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

signal keycode : std_logic_vector(7 downto 0);
signal holdtime : integer range 0 to 8:=0;
signal state : std_logic_vector(1 downto 0);
signal lock_key_code : std_logic_vector(7 downto 0);
begin
	PS2Keyboard_Entity : PS2Keyboard port map (clk,rst,ps2clk,ps2data,keycode);
	
	keyValue(15 downto 6) <= (others => '0');
	
	with lock_key_code select keyValue(5 downto 0) <=
		"000001" when "00011100" , -- a
		"000010" when "00110010" , 
		"000011" when "00100001" , 
		"000100" when "00100011" , 
		"000101" when "00100100" , 
		"000110" when "00101011" , 
		"000111" when "00110100" , 
		"001000" when "00110011" , 
		"001001" when "01000011" , 
		"001010" when "00111011" , 
		"001011" when "01000010" , 
		"001100" when "01001011" , 
		"001101" when "00111010" , 
		"001110" when "00110001" , 
		"001111" when "01000100" , 
		"010000" when "01001101" , 
		"010001" when "00010101" , 
		"010010" when "00101101" , 
		"010011" when "00011011" , 
		"010100" when "00101100" , 
		"010101" when "00111100" , 
		"010110" when "00101010" , 
		"010111" when "00011101" , 
		"011000" when "00100010" , 
		"011001" when "00110101" , 
		"011010" when "00011010" , -- z
		"011011" when "01000001" , -- ,
		"011100" when "01001001" , -- .
		
		"110000" when "01000101" , -- 0
		"110001" when "00010110" , 
		"110010" when "00011110" , 
		"110011" when "00100110" , 
		"110100" when "00100101" , 
		"110101" when "00101110" , 
		"110110" when "00110110" , 
		"110111" when "00111101" , 
		"111000" when "00111110" , 
		"111001" when "01000110" , -- 9
		
		"100100" when "01001110" , -- -
		"100101" when "01010101" , -- =
		"100110" when "01110110" , -- ESC
		"100111" when "01100110" , -- BKSP
		"011110" when "01011010" , -- ENTER
		"000000" when "00101001" , -- SPACE
		"111111" when others; 
	process(clk,rst)
	begin
		if(rst='0')then
			state <= "00";
			data_ready <= '0';
			lock_key_code <= (others => '0');
		elsif(clk'event and clk='1')then
			if(holdtime > 0)then
				holdtime <= holdtime - 1;
				data_ready <= '1';
			else
				data_ready <= '0';
			end if;
			
			case state is
				when "00" =>
					if(keycode = "11110000")then
						state <= "01";
					end if;
				when "01" =>
					if(keycode = "11110000")then
						state <= "01";
					else
						if(keycode /= "00000000")then
							lock_key_code <= keycode;
							state <= "00";
							holdtime <= 8;
						end if;
					end if;
				when others =>
					state <= "00";
			end case;
		end if;
	end process;

end Behavioral;

