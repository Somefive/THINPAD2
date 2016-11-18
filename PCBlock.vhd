----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:06:14 11/17/2016 
-- Design Name: 
-- Module Name:    PCBlock - Behavioral 
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
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PCBlock is
    Port ( RegX : in  STD_LOGIC_VECTOR (15 downto 0);
           T : in  STD_LOGIC;
           ImmLong : in  STD_LOGIC_VECTOR (10 downto 0);
           PCControl : in  STD_LOGIC_VECTOR (2 downto 0);
           PC : buffer  STD_LOGIC_VECTOR (15 downto 0);
			  CLK : in STD_LOGIC);
end PCBlock;

architecture Behavioral of PCBlock is
--signal RegPC : std_logic_vector(15 downto 0):="0000000000000111";
begin

	process(CLK, PCControl)
	begin
		if(CLK'event and CLK='1')then
			case PCControl is
				when "001" =>
					PC <= PC + '1';
				when "010" =>
					PC <= PC + std_logic_vector(resize(signed(ImmLong(10 downto 0)), 16));
				when "011" =>
					if(RegX = "0000000000000000") then
						PC <= PC + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					end if;
				when "100" =>
					if(RegX /= "0000000000000000") then
						PC <= PC + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					end if;
				when "101" =>
					if(T = '0') then
						PC <= PC + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					end if;
				when "110" =>
					PC <= RegX;
				when others =>
			end case;
		end if;
	end process;
	
--	process(CLK)
--	begin
--		if(CLK'event and CLK='0')then
--			RegPC <= PC;
--		end if;
--	end process;
	
end Behavioral;

