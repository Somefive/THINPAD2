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
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RABlock2 is
    Port ( ImmLong : in  STD_LOGIC_VECTOR (10 downto 0);
           PC : in  STD_LOGIC_VECTOR (15 downto 0);
           Data : in  STD_LOGIC_VECTOR (15 downto 0);
           RAControl : in  STD_LOGIC_VECTOR (4 downto 0);
           RegX : out  STD_LOGIC_VECTOR (15 downto 0);
           RegY : out  STD_LOGIC_VECTOR (15 downto 0);
           T : out  STD_LOGIC;
           ALU : out  STD_LOGIC_VECTOR (15 downto 0));
end RABlock2;

architecture Behavioral of RABlock2 is

signal Reg0: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal Reg1: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal Reg2: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal Reg3: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal Reg4: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal Reg5: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal Reg6: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal Reg7: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal RegSP  : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal RegIH  : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
signal RegT : STD_LOGIC := '0';

signal Rx: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";
signal Ry: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";
signal ShiftImmediate : STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";

shared variable ALUResult : std_logic_vector(15 downto 0):="0000000000000000";
shared variable DestReg   : std_logic_vector(3 downto 0):="0000";

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
	
	RegX <= Rx;
	RegY <= Ry;
	T <= RegT;
	
	process(RAControl, Rx, RY)
	begin
		case RAControl is
			when "00001" =>
				DestReg := '0'&ImmLong(10 downto 8);
				ALUResult := Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
			when "00010" =>
				DestReg := '0'&ImmLong(7 downto 5);
				ALUResult := Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
			when "00011" =>
				DestReg := "1001";
				ALUResult := std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
			when "00100" =>
				DestReg := '0'&ImmLong(10 downto 8);
				ALUResult := RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
			when "00101" =>
				DestReg := '0'&ImmLong(4 downto 2);
				ALUResult := Rx + Ry;
			when "00110" =>
				DestReg := '0'&ImmLong(10 downto 8);
				ALUResult := Rx and Ry;
			when "00111" =>
				DestReg := "1010";
				if(Rx = Ry)then
					ALUResult := '0';
				else
					ALUResult := '1';
				end if;
			when "01000" =>
				DestReg := "1010";
				if(Rx = std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16))) then
					ALUResult := '0';
				else
					ALUResult := '1';
				end if;
			when "01001" =>
				DestReg := "1011"; -- RegX
				ALUResult := Rx;
			when "01010" =>
				DestReg := '0'&ImmLong(10 downto 8);
				ALUResult := "00000000"&ImmLong(7 downto 0);
			when "01011" =>
				DestReg := "1100"; --ALU
				ALUResult := Rx + std_logic_vector(resize(signed(ImmLong(4 downto 0)), 16));
			when "01100" =>
			when "01101" =>
			when "01110" =>
			when "01111" =>
			when "10000" =>
			when "10001" =>
			when "10010" =>
			when "10011" =>
			when "10100" =>
			
			when others =>
			
	end process;
	process(RAControl, Rx, Ry)
	begin
		case RAControl is
			when "00001" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "001" =>
						Reg1 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "010" =>
						Reg2 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "011" =>
						Reg3 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "100" =>
						Reg4 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "101" =>
						Reg5 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "110" =>
						Reg6 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "111" =>
						Reg7 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when others =>
						
				end case;
			when "00010" =>
				case ImmLong(7 downto 5) is
					when "000" =>
						Reg0 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "001" =>
						Reg1 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "010" =>
						Reg2 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "011" =>
						Reg3 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "100" =>
						Reg4 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "101" =>
						Reg5 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "110" =>
						Reg6 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "111" =>
						Reg7 <= Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when others =>
						
				end case;
			when "00011" =>
				RegSP <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
			when "00100" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "001" =>
						Reg1 <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "010" =>
						Reg2 <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "011" =>
						Reg3 <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "100" =>
						Reg4 <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "101" =>
						Reg5 <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "110" =>
						Reg6 <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when "111" =>
						Reg7 <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
					when others =>
						
				end case;
			when "00101" =>
				case ImmLong(4 downto 2) is
					when "000" =>
						Reg0 <= Rx + Ry;
					when "001" =>
						Reg1 <= Rx + Ry;
					when "010" =>
						Reg2 <= Rx + Ry;
					when "011" =>
						Reg3 <= Rx + Ry;
					when "100" =>
						Reg4 <= Rx + Ry;
					when "101" =>
						Reg5 <= Rx + Ry;
					when "110" =>
						Reg6 <= Rx + Ry;
					when "111" =>
						Reg7 <= Rx + Ry;
					when others =>
					
				end case;
			when "00110" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= Rx and Ry;
					when "001" =>
						Reg1 <= Rx and Ry;
					when "010" =>
						Reg2 <= Rx and Ry;
					when "011" =>
						Reg3 <= Rx and Ry;
					when "100" =>
						Reg4 <= Rx and Ry;
					when "101" =>
						Reg5 <= Rx and Ry;
					when "110" =>
						Reg6 <= Rx and Ry;
					when "111" =>
						Reg7 <= Rx and Ry;
					when others =>
						
				end case;
			when "00111" =>
				if(Rx = Ry)then
					RegT <= '0';
				else
					RegT <= '1';
				end if;
			when "01000" =>
				if(Rx = std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16))) then
					RegT <= '0';
				else
					RegT <= '1';
				end if;
			when "01001" =>
				RegX <= Rx;
			when "01010" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= "00000000"&ImmLong(7 downto 0);
					when "001" =>
						Reg1 <= "00000000"&ImmLong(7 downto 0);
					when "010" =>
						Reg2 <= "00000000"&ImmLong(7 downto 0);
					when "011" =>
						Reg3 <= "00000000"&ImmLong(7 downto 0);
					when "100" =>
						Reg4 <= "00000000"&ImmLong(7 downto 0);
					when "101" =>
						Reg5 <= "00000000"&ImmLong(7 downto 0);
					when "110" =>
						Reg6 <= "00000000"&ImmLong(7 downto 0);
					when "111" =>
						Reg7 <= "00000000"&ImmLong(7 downto 0);
					when others =>
						
				end case;
			when "01011" =>
				ALU <= Rx + std_logic_vector(resize(signed(ImmLong(4 downto 0)), 16));
			when "01100" =>
				ALU <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
			when "01101" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= RegIH;
					when "001" =>
						Reg1 <= RegIH;
					when "010" =>
						Reg2 <= RegIH;
					when "011" =>
						Reg3 <= RegIH;
					when "100" =>
						Reg4 <= RegIH;
					when "101" =>
						Reg5 <= RegIH;
					when "110" =>
						Reg6 <= RegIH;
					when "111" =>
						Reg7 <= RegIH;
					when others =>
						
				end case;
			when "01110" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= PC;
					when "001" =>
						Reg1 <= PC;
					when "010" =>
						Reg2 <= PC;
					when "011" =>
						Reg3 <= PC;
					when "100" =>
						Reg4 <= PC;
					when "101" =>
						Reg5 <= PC;
					when "110" =>
						Reg6 <= PC;
					when "111" =>
						Reg7 <= PC;
					when others =>
						
				end case;
			when "01111" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= Ry;
					when "001" =>
						Reg1 <= Ry;
					when "010" =>
						Reg2 <= Ry;
					when "011" =>
						Reg3 <= Ry;
					when "100" =>
						Reg4 <= Ry;
					when "101" =>
						Reg5 <= Ry;
					when "110" =>
						Reg6 <= Ry;
					when "111" =>
						Reg7 <= Ry;
					when others =>
						
				end case;
			when "10000" =>
				RegIH <= Rx;
			when "10001" =>
				RegSP <= Rx;
			when "10010" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= "0000000000000000" - Ry;
					when "001" =>
						Reg1 <= "0000000000000000" - Ry;
					when "010" =>
						Reg2 <= "0000000000000000" - Ry;
					when "011" =>
						Reg3 <= "0000000000000000" - Ry;
					when "100" =>
						Reg4 <= "0000000000000000" - Ry;
					when "101" =>
						Reg5 <= "0000000000000000" - Ry;
					when "110" =>
						Reg6 <= "0000000000000000" - Ry;
					when "111" =>
						Reg7 <= "0000000000000000" - Ry;
					when others =>
						
				end case;
			when "10011" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= Rx or Ry;
					when "001" =>
						Reg1 <= Rx or Ry;
					when "010" =>
						Reg2 <= Rx or Ry;
					when "011" =>
						Reg3 <= Rx or Ry;
					when "100" =>
						Reg4 <= Rx or Ry;
					when "101" =>
						Reg5 <= Rx or Ry;
					when "110" =>
						Reg6 <= Rx or Ry;
					when "111" =>
						Reg7 <= Rx or Ry;
					when others =>
						
				end case;
			when "10100" =>
				if(ImmLong(4 downto 2) = "000")then
					ShiftImmediate <= "0000000000001000";
				else
					ShiftImmediate <= "0000000000000"&ImmLong(4 downto 2);
				end if;
				
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= to_stdlogicvector(to_bitvector(Rx) sll conv_integer(ShiftImmediate));
					when "001" =>
						Reg1 <= to_stdlogicvector(to_bitvector(Rx) sll conv_integer(ShiftImmediate));
					when "010" =>
						Reg2 <= to_stdlogicvector(to_bitvector(Rx) sll conv_integer(ShiftImmediate));
					when "011" =>
						Reg3 <= to_stdlogicvector(to_bitvector(Rx) sll conv_integer(ShiftImmediate));
					when "100" =>
						Reg4 <= to_stdlogicvector(to_bitvector(Rx) sll conv_integer(ShiftImmediate));
					when "101" =>
						Reg5 <= to_stdlogicvector(to_bitvector(Rx) sll conv_integer(ShiftImmediate));
					when "110" =>
						Reg6 <= to_stdlogicvector(to_bitvector(Rx) sll conv_integer(ShiftImmediate));
					when "111" =>
						Reg7 <= to_stdlogicvector(to_bitvector(Rx) sll conv_integer(ShiftImmediate));
					when others =>
						
				end case;
			when "10101" =>
				case ImmLong(7 downto 5) is
					when "000" =>
						Reg0 <= to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
					when "001" =>
						Reg1 <= to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
					when "010" =>
						Reg2 <= to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
					when "011" =>
						Reg3 <= to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
					when "100" =>
						Reg4 <= to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
					when "101" =>
						Reg5 <= to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
					when "110" =>
						Reg6 <= to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
					when "111" =>
						Reg7 <= to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
					when others =>
						
				end case;
			when "10110" =>
				if(ImmLong(4 downto 2) = "000")then
					ShiftImmediate <= "0000000000001000";
				else
					ShiftImmediate <= "0000000000000"&ImmLong(4 downto 2);
				end if;
				
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= to_stdlogicvector(to_bitvector(Rx) sra conv_integer(ShiftImmediate));
					when "001" =>
						Reg1 <= to_stdlogicvector(to_bitvector(Rx) sra conv_integer(ShiftImmediate));
					when "010" =>
						Reg2 <= to_stdlogicvector(to_bitvector(Rx) sra conv_integer(ShiftImmediate));
					when "011" =>
						Reg3 <= to_stdlogicvector(to_bitvector(Rx) sra conv_integer(ShiftImmediate));
					when "100" =>
						Reg4 <= to_stdlogicvector(to_bitvector(Rx) sra conv_integer(ShiftImmediate));
					when "101" =>
						Reg5 <= to_stdlogicvector(to_bitvector(Rx) sra conv_integer(ShiftImmediate));
					when "110" =>
						Reg6 <= to_stdlogicvector(to_bitvector(Rx) sra conv_integer(ShiftImmediate));
					when "111" =>
						Reg7 <= to_stdlogicvector(to_bitvector(Rx) sra conv_integer(ShiftImmediate));
					when others =>
						
				end case;
			when "10111" =>
				case ImmLong(4 downto 2) is
					when "000" =>
						Reg0 <= Rx - Ry;
					when "001" =>
						Reg1 <= Rx - Ry;
					when "010" =>
						Reg2 <= Rx - Ry;
					when "011" =>
						Reg3 <= Rx - Ry;
					when "100" =>
						Reg4 <= Rx - Ry;
					when "101" =>
						Reg5 <= Rx - Ry;
					when "110" =>
						Reg6 <= Rx - Ry;
					when "111" =>
						Reg7 <= Rx - Ry;
					when others =>
					
				end case;
			when "11000" =>
				case ImmLong(10 downto 8) is
					when "000" =>
						Reg0 <= Data;
					when "001" =>
						Reg1 <= Data;
					when "010" =>
						Reg2 <= Data;
					when "011" =>
						Reg3 <= Data;
					when "100" =>
						Reg4 <= Data;
					when "101" =>
						Reg5 <= Data;
					when "110" =>
						Reg6 <= Data;
					when "111" =>
						Reg7 <= Data;
					when others =>
						
				end case;
			when "11001" =>
				case ImmLong(7 downto 5) is
					when "000" =>
						Reg0 <= Data;
					when "001" =>
						Reg1 <= Data;
					when "010" =>
						Reg2 <= Data;
					when "011" =>
						Reg3 <= Data;
					when "100" =>
						Reg4 <= Data;
					when "101" =>
						Reg5 <= Data;
					when "110" =>
						Reg6 <= Data;
					when "111" =>
						Reg7 <= Data;
					when others =>
						
				end case;
			when others =>
		end case;
	end process;
	
	T <= RegT;
end Behavioral;

