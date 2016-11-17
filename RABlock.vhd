----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:25:06 11/17/2016 
-- Design Name: 
-- Module Name:    RABlock - Behavioral 
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

entity RABlock is
    Port ( ImmLong : in  STD_LOGIC_VECTOR (10 downto 0);
           PC : in  STD_LOGIC_VECTOR (15 downto 0);
           Data : in  STD_LOGIC_VECTOR (15 downto 0);
           RAControl : in  STD_LOGIC_VECTOR (0 downto 0);
           RegX : out  STD_LOGIC_VECTOR (15 downto 0);
           RegY : out  STD_LOGIC_VECTOR (15 downto 0);
           T : out  STD_LOGIC;
           ALU : out  STD_LOGIC_VECTOR (15 downto 0));
end RABlock;

architecture Behavioral of RABlock is
signal Rx,Ry: STD_LOGIC_VECTOR (15 downto 0);
begin
	
	with ImmLong(10 downto 8) select Rx <=
			Reg0 when "000",
			Reg1 when "001",
			Reg2 when "010",
			Reg3 when "011",
			Reg4 when "100",
			Reg5 when "101",
			Reg6 when "110",
			Reg7 when "111",
			"0000000000000000" when others;
			
	with ImmLong(7 downto 5) select Ry <=
			Reg0 when "000",
			Reg1 when "001",
			Reg2 when "010",
			Reg3 when "011",
			Reg4 when "100",
			Reg5 when "101",
			Reg6 when "110",
			Reg7 when "111",
			"0000000000000000" when others;

end Behavioral;

