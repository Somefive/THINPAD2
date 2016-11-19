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
           RegX : out  STD_LOGIC_VECTOR (15 downto 0);
           RegY : out  STD_LOGIC_VECTOR (15 downto 0);
           T : out  STD_LOGIC;
           ALU : out  STD_LOGIC_VECTOR (15 downto 0);
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
signal RegT : STD_LOGIC := '0';

signal Rx: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";
signal Ry: STD_LOGIC_VECTOR (15 downto 0):="0000000000000000";

shared variable ALUResult : std_logic_vector(15 downto 0):="0000000000000000";
shared variable DestReg   : std_logic_vector(3 downto 0):="1111";

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
	
	process(RAControl)
	begin
		if(CLK'event and CLK='1')then
			case RAControl is
				when "00001" =>	--ADDIU
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := Rx + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
				when "00010" =>	--ADDIU3
					DestReg := '0'&ImmLong(7 downto 5);
					ALUResult := Rx + std_logic_vector(resize(signed(ImmLong(3 downto 0)), 16));
				when "00011" =>	--ADDSP
					DestReg := "1001";--RegSP
					ALUResult := RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
				when "00100" =>	--ADDSP3
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
				when "00101" =>	--ADDU
					DestReg := '0'&ImmLong(4 downto 2);
					ALUResult := Rx + Ry;
				when "00110" =>	--AND
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := Rx and Ry;
				when "00111" =>	--CMP
					DestReg := "1010";--RegT
					if(Rx = Ry)then
						ALUResult := "0000000000000000";
					else
						ALUResult := "0000000000000001";
					end if;
				when "01000" =>	--CMPI
					DestReg := "1010";--RegT
					if(Rx = std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16))) then
						ALUResult := "0000000000000000";
					else
						ALUResult := "0000000000000001";
					end if;
				when "01001" =>	--JR
					DestReg := "1011"; -- RegX
					ALUResult := Rx;
				when "01010" =>	--LI
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := "00000000"&ImmLong(7 downto 0);
				when "01011" =>	--LW | SW
					DestReg := "1100"; --ALU
					ALUResult := Rx + std_logic_vector(resize(signed(ImmLong(4 downto 0)), 16));
				when "01100" =>	--LW_SP | SW_SP
					DestReg := "1100"; --ALU
					ALUResult := RegSP + std_logic_vector(resize(signed(ImmLong(7 downto 0)), 16));
				when "01101" =>	--MFIH
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := RegIH;
				when "01110" =>	--MFPC
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := PC;
				when "01111" =>	--MOVE												--??
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := Ry;
				when "10000" =>	--MTIH
					DestReg := "1101"; --RegIH
					ALUResult := Rx;
				when "10001" =>	--MTSP
					DestReg := "1001"; --RegSP
					ALUResult := Rx;
				when "10010" =>	--NEG
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := "0000000000000000" - Ry;
				when "10011" =>	--OR												--??
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := Rx or Ry;
				when "10100" =>	--SLL												--??
					DestReg := '0'&ImmLong(10 downto 8);
					if(ImmLong(4 downto 2) = "000")then
						ALUResult := to_stdlogicvector(to_bitvector(Ry) sll 8);
					else
						ALUResult := to_stdlogicvector(to_bitvector(Ry) sll conv_integer(ImmLong(4 downto 2)));
					end if;
				when "10101" =>	--SLLV											--??
					DestReg := '0'&ImmLong(7 downto 5);
					ALUResult := to_stdlogicvector(to_bitvector(Ry) sll conv_integer(Rx));
				when "10110" =>	--SRA
					DestReg := '0'&ImmLong(10 downto 8);
					if(ImmLong(4 downto 2) = "000")then
						ALUResult := to_stdlogicvector(to_bitvector(Ry) sra 8);
					else
						ALUResult := to_stdlogicvector(to_bitvector(Ry) sra conv_integer(ImmLong(4 downto 2)));
					end if;
				when "10111" =>	--SUBU
					DestReg := '0'&ImmLong(4 downto 2);
					ALUResult := Rx - Ry;
				when "11000" =>	--MEMX
					DestReg := '0'&ImmLong(10 downto 8);
					ALUResult := Data;
				when "11001" =>	--MEMY
					DestReg := '0'&ImmLong(7 downto 5);
					ALUResult := Data;
				when others =>
					DestReg := "1111";
					ALUResult := "0000000000000000";
			end case;
		end if;
	end process;
	
	process(CLK)
	begin
		if(CLK'event and CLK='0')then
			case DestReg is
				when "0000" =>
					Reg0 <= ALUResult;
				when "0001" =>
					Reg1 <= ALUResult;
				when "0010" =>
					Reg2 <= ALUResult;
				when "0011" =>
					Reg3 <= ALUResult;
				when "0100" =>
					Reg4 <= ALUResult;
				when "0101" =>
					Reg5 <= ALUResult;
				when "0110" =>
					Reg6 <= ALUResult;
				when "0111" =>
					Reg7 <= ALUResult;
				when "1001" =>
					RegSP <= ALUResult;
				when "1010" =>
					RegT <= ALUResult(0);
				when "1011" =>
					--RegX <= ALUResult;
				when "1100" =>
					ALU <= ALUResult;
				when "1101" =>
					RegIH <= ALUResult;
				when others =>
			end case;
			T <= RegT;
			RegY <= Ry;
			RegX <= Rx;
		end if;
	end process;
end Behavioral;

