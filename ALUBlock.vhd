----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:07:41 11/17/2016 
-- Design Name: 
-- Module Name:    ALUBlock - Behavioral 
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

entity ALUBlock is
    Port ( RegX : in  STD_LOGIC_VECTOR (15 downto 0);
           RegY : in  STD_LOGIC_VECTOR (15 downto 0);
           SP : in  STD_LOGIC_VECTOR (15 downto 0);
           ImmMid : in  STD_LOGIC_VECTOR (7 downto 0);
           ALUControl : in  STD_LOGIC_VECTOR (0 downto 0);
           ALU : out  STD_LOGIC_VECTOR (15 downto 0));
end ALUBlock;

architecture Behavioral of ALUBlock is

begin


end Behavioral;

