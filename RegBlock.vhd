----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:01:47 11/17/2016 
-- Design Name: 
-- Module Name:    RegBlock - Behavioral 
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

entity RegBlock is
    Port ( ImmLong : in  STD_LOGIC_VECTOR (10 downto 0);
           PC : in  STD_LOGIC_VECTOR (15 downto 0);
           ALU : in  STD_LOGIC_VECTOR (15 downto 0);
           Data : in  STD_LOGIC_VECTOR (15 downto 0);
           RegControl : in  STD_LOGIC_VECTOR (0 downto 0);
           T : out  STD_LOGIC;
           SP : out  STD_LOGIC_VECTOR (15 downto 0);
           RegX : out  STD_LOGIC_VECTOR (15 downto 0);
           RegY : out  STD_LOGIC_VECTOR (15 downto 0));
end RegBlock;

architecture Behavioral of RegBlock is

signal Reg0: STD_LOGIC_VECTOR (15 downto 0);
signal Reg1: STD_LOGIC_VECTOR (15 downto 0);
signal Reg2: STD_LOGIC_VECTOR (15 downto 0);
signal Reg3: STD_LOGIC_VECTOR (15 downto 0);
signal Reg4: STD_LOGIC_VECTOR (15 downto 0);
signal Reg5: STD_LOGIC_VECTOR (15 downto 0);
signal Reg6: STD_LOGIC_VECTOR (15 downto 0);
signal Reg7: STD_LOGIC_VECTOR (15 downto 0);

signal RegIH: STD_LOGIC_VECTOR (15 downto 0);
signal RegSP: STD_LOGIC_VECTOR (15 downto 0);
signal RegT: STD_LOGIC;

begin


end Behavioral;

