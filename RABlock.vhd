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

entity RABlock is
    Port ( ImmLong : in  STD_LOGIC_VECTOR (10 downto 0);
           PC : in  STD_LOGIC_VECTOR (15 downto 0);
           Data : in  STD_LOGIC_VECTOR (15 downto 0);
           RAControl : in  STD_LOGIC_VECTOR (4 downto 0);
           RegX : buffer  STD_LOGIC_VECTOR (15 downto 0);
           RegY : buffer  STD_LOGIC_VECTOR (15 downto 0);
           T : buffer  STD_LOGIC;
           ALU : buffer  STD_LOGIC_VECTOR (15 downto 0);
			  CLK : in STD_LOGIC);
end RABlock;

architecture Behavioral of RABlock is

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
--signal RegT : STD_LOGIC := '0';

--signal Rx: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";
--signal Ry: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";

--shared variable ALUResult : std_logic_vector(15 downto 0):="0000000000000000";
shared variable DestReg   : std_logic_vector(3 downto 0):="1111";

begin
	with ImmLong(10 downto 8) select RegX <=
			Reg0 when "000",
			Reg1 when "001",
			Reg2 when "010",
			Reg3 when "011",
			Reg4 when "100",
			Reg5 when "101",
			Reg6 when "110",
			Reg7 when "111",
			"0000000000000000" when others;
			
	with ImmLong(7 downto 5) select RegY <=
			Reg0 when "000",
			Reg1 when "001",
			Reg2 when "010",
			Reg3 when "011",
			Reg4 when "100",
			Reg5 when "101",
			Reg6 when "110",
			Reg7 when "111",
			"0000000000000000" when others;
	
	process(RAControl)
	begin
		if(CLK'event and CLK='0')then
			case RAControl is
				when "00001" =>	--ADDIU
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= RegX + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
				when "00010" =>	--ADDIU3
					DestReg := '0'&ImmLong(7 downto 5);
					ALU <= RegX + std_logic_vector(resize(signed(ImmLong(3 downto 0)), 16));
				when "00011" =>	--ADDSP
					DestReg := "1001";--RegSP
					ALU <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
				when "00100" =>	--ADDSP3
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
				when "00101" =>	--ADDU
					DestReg := '0'&ImmLong(4 downto 2);
					ALU <= RegX + RegY;
				when "00110" =>	--AND
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= RegX and RegY;
				when "00111" =>	--CMP
					DestReg := "1010";--RegT
					if(RegX = RegY)then
						T <= '0';
					else
						T <= '1';
					end if;
				when "01000" =>	--CMPI
					DestReg := "1010";--RegT
					if(RegX = std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16))) then
						T <= '0';
					else
						T <= '1';
					end if;
				when "01001" =>	--JR
					DestReg := "1011"; -- RegX
				when "01010" =>	--LI
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= "00000000"&ImmLong(7 downto 0);
				when "01011" =>	--LW | SW
					DestReg := "1100"; --ALU
					ALU <= RegX + std_logic_vector(resize(signed(ImmLong(4 downto 0)), 16));
				when "01100" =>	--LW_SP | SW_SP
					DestReg := "1100"; --ALU
					ALU <= RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
				when "01101" =>	--MFIH
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= RegIH;
				when "01110" =>	--MFPC
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= PC + 1;
				when "01111" =>	--MOVE
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= RegY;
				when "10000" =>	--MTIH
					DestReg := "1101"; --RegIH
					ALU <= RegX;
				when "10001" =>	--MTSP
					DestReg := "1001"; --RegSP
					ALU <= RegY;
				when "10010" =>	--NEG
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= "0000000000000000" - RegY;
				when "10011" =>	--OR
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= RegX or RegY;
				when "10100" =>	--SLL
					DestReg := '0'&ImmLong(10 downto 8);
					if(ImmLong(4 downto 2) = "000")then
						ALU <= to_stdlogicvector(to_bitvector(RegY) sll 8);
					else
						ALU <= to_stdlogicvector(to_bitvector(RegY) sll conv_integer(ImmLong(4 downto 2)));
					end if;
				when "10101" =>	--SLLV
					DestReg := '0'&ImmLong(7 downto 5);
					ALU <= to_stdlogicvector(to_bitvector(RegY) sll conv_integer(RegX));
				when "10110" =>	--SRA
					DestReg := '0'&ImmLong(10 downto 8);
					if(ImmLong(4 downto 2) = "000")then
						ALU <= to_stdlogicvector(to_bitvector(RegY) sra 8);
					else
						ALU <= to_stdlogicvector(to_bitvector(RegY) sra conv_integer(ImmLong(4 downto 2)));
					end if;
				when "10111" =>	--SUBU
					DestReg := '0'&ImmLong(4 downto 2);
					ALU <= RegX - RegY;
				when "11000" =>	--MEMX
					DestReg := '0'&ImmLong(10 downto 8);
					ALU <= Data;
				when "11001" =>	--MEMY
					DestReg := '0'&ImmLong(7 downto 5);
					ALU <= Data;
				when others =>
					DestReg := "1111";
			end case;
		end if;
	end process;
	
	process(CLK)
	begin
		if(CLK'event and CLK='1' and RAControl="11110")then
			case DestReg is
				when "0000" =>
					Reg0 <= ALU;
				when "0001" =>
					Reg1 <= ALU;
				when "0010" =>
					Reg2 <= ALU;
				when "0011" =>
					Reg3 <= ALU;
				when "0100" =>
					Reg4 <= ALU;
				when "0101" =>
					Reg5 <= ALU;
				when "0110" =>
					Reg6 <= ALU;
				when "0111" =>
					Reg7 <= ALU;
				when "1001" =>
					RegSP <= ALU;
				when "1010" =>
					--RegT <= T;
				when "1011" =>
					--RegX <= Rx;
				when "1100" =>
					--ALU <= ALU;
				when "1101" =>
					RegIH <= ALU;
				when others =>
			end case;
		end if;
	end process;
end Behavioral;

