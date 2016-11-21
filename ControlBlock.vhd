----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:10:16 11/17/2016 
-- Design Name: 
-- Module Name:    ControlBlock - Behavioral 
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
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ControlBlock is
    Port ( Instruction : in  STD_LOGIC_VECTOR(15 downto 0);
           Finish : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           PCControl : out  STD_LOGIC_VECTOR(2 downto 0);
           RAControl : out  STD_LOGIC_VECTOR(4 downto 0);
           RamControl : out  STD_LOGIC_VECTOR(2 downto 0);
			  DYP : out STD_LOGIC_VECTOR(6 downto 0);
			  OutPeriod: out STD_LOGIC_VECTOR(3 downto 0));
end ControlBlock;

architecture Behavioral of ControlBlock is

component DigitLights is
    Port ( L : out  STD_LOGIC_VECTOR (6 downto 0);
           NUMBER : in  INTEGER);
end component;

signal Period : INTEGER RANGE 0 TO 15 := 1;--??
signal Runable : STD_LOGIC := '1';

begin
	DL: DigitLights port map (DYP, Period);
	OutPeriod <= CONV_STD_LOGIC_VECTOR(Period,4);

	process(Finish)
	begin
		if(Finish'event and Finish='1') then--??
			Runable <= '0';
		elsif(Instruction = "1111111111111111") then
			Runable <= '1';
			--RamControl <= "001";
		end if;
	end process;

	process(CLK,Finish)
	begin
		if(CLK'event and CLK = '0') then
			if(Runable = '1') then
				Period <= 4;
			elsif(Instruction(15 downto 11) = "10011" or Instruction(15 downto 11) = "10010") then
				if(Period = 1) then
					Period <= 2;
				elsif(Period = 2) then
					Period <= 3;
				elsif(Period = 3) then
					Period <= 4;
				elsif(Period = 4) then
					if(Finish='0') then--??
						Period <= 5;
					end if;
				elsif(Period = 5) then
					Period <= 6;
				elsif(Period = 6) then
					Period <= 1;
				else
				end if;
			elsif(Instruction(15 downto 11) = "11011" or Instruction(15 downto 11) = "11010") then
				if(Period = 1) then
					Period <= 2;
				elsif(Period = 2) then
					Period <= 3;
				elsif(Period = 3) then
					Period <= 4;
				elsif(Period = 4) then
					if(Finish='0') then--??
						Period <= 5;
					end if;
				elsif(Period = 5) then
					Period <= 1;
				else
				end if;
--			elsif(Instruction(15 downto 11) = "11101" and Instruction(7 downto 0) = "01000000") then
--				if(Period = 1) then
--					Period <= 2;
--				elsif(Period = 2) then
--					Period <= 3;
--				elsif(Period = 3) then
--					Period <= 4;
--				elsif(Period = 4) then
--					Period <= 5;
--				elsif(Period = 5) then
--					Period <= 1;
--				else
--				end if;
			else
				if(Period = 1) then
					Period <= 2;
				elsif(Period = 2) then
					Period <= 3;
				elsif(Period = 3) then
					Period <= 4;
				elsif(Period = 4) then
					Period <= 1;
				end if;
			end if;
		end if;
		
	end process;
	
	process(Period,Instruction)
	begin
--		if(CLK'event and CLK ='1') then
			
			if(Period = 1) then
				RAControl <= "00000";
				--RamControl <= "011";
			elsif(Period = 2) then
				case Instruction(15 downto 11) is
					when "00000" => 								-- 28.ADDSP3
						PCControl <= "001";
						RAControl <= "00100";
					when "00001" => 								-- 19.NOP
						PCControl <= "001";
					when "00010" => 								-- 6.B
						PCControl <= "010";
					when "00100" => 								-- 7.BEQZ
						PCControl <= "011";
					when "00101" => 								-- 8.BNEZ
						PCControl <= "100";
					when "00110" =>
						case Instruction(1 downto 0) is
							when "00" => 							-- 21.SLL
								PCControl <= "001";
								RAControl <= "10100";
							when "11" => 							-- 22.SRA
								PCControl <= "001";
								RAControl <= "10110";
							when others =>
						end case;
					when "01000" => 								-- 2.ADDIU3
						PCControl <= "001";
						RAControl <= "00010";
					when "01001" => 								-- 1.ADDIU
						PCControl <= "001";
						RAControl <= "00001";
					when "01100" =>
						case Instruction(10 downto 8) is
							when "011" => 							-- 3.ADDSP
								PCControl <= "001";
								RAControl <= "00011";
							when "000" => 							-- 9.BTEQZ
								PCControl <= "101";
							when "100" => 							-- 18.MTSP
								PCControl <= "001";
								RAControl <= "10001";
							when others =>
						end case;
					when "01101" => 								-- 12.LI
						PCControl <= "001";
						RAControl <= "01010";
					when "01110" => 								-- 29.CMPI
						PCControl <= "001";
						RAControl <= "01000";
					when "01111" => 								-- 26.MOVE
						PCControl <= "001";
						RAControl <= "01111";
					when "10010" => 								-- 14.LW_SP
						PCControl <= "001";
						RAControl <= "01100";
					when "10011" => 								-- 13.LW
						PCControl <= "001";
						RAControl <= "01011";
					when "11010" => 								-- 25.SW_SP
						PCControl <= "001";
						RAControl <= "01100";
					when "11011" => 								-- 24.SW
						PCControl <= "001";
						RAControl <= "01011";
					when "11100" => 								
						case Instruction(1 downto 0) is
							when "01" =>							-- 4.ADDU
								PCControl <= "001";
								RAControl <= "00101";
							when "11" =>							-- 23.SUBU
								PCControl <= "001";
								RAControl <= "10111";
							when others =>
						end case;
					when "11101" =>
						case Instruction(4 downto 0) is
							when "01100" =>						-- 5.AND
								PCControl <= "001";
								RAControl <= "00110";
							when "01010" =>						-- 10.CMP
								PCControl <= "001";
								RAControl <= "00111";
							when "00000" =>						
								case Instruction(7 downto 5) is
									when "000" =>					-- 11.JR
										PCControl <= "110";
										RAControl <= "01001";--??
									when "010" =>					-- 16.MFPC
										PCControl <= "001";
										RAControl <= "01110";
									when others =>
								end case;
							when "01101" =>						-- 20.OR
								PCControl <= "001";
								RAControl <= "10011";
							when "00100" =>						-- 27.SLLV
								PCControl <= "001";
								RAControl <= "10101";
							when "01011" =>						-- 30.NEG
								PCControl <= "001";
								RAControl <= "10010";
							when others =>
						end case;
					when "11110" => 								
						case Instruction(7 downto 0) is
							when "00000000" =>					-- 15.MFIH
								PCControl <= "001";
								RAControl <= "01101";
							when "00000001" =>					-- 17.MTIH
								PCControl <= "001";
								RAControl <= "10000";
							when others =>
						end case;
					when others =>
				end case;
			elsif(Period = 3) then
				RAControl <= "11110";
				PCControl <= "111";
			elsif(Period = 4) then
				RAControl <= "00000";
			elsif(Period = 5) then
				if(Instruction(15 downto 11) = "10011") then
					RAControl <= "11001";
				elsif(Instruction(15 downto 11) = "10010") then
					RAControl <= "11000";
				else
				end if;
			elsif(Period = 6) then
				if(Instruction(15 downto 11) = "10011" or Instruction(15 downto 11) = "10010") then
					RAControl <= "11110";
				end if;
			end if;
--		end if;
	end process;
	
	process(Period,Instruction)
	begin
--		if(Runable = '1') then
--			RamControl <= "001";
--		if(CLK'EVENT and CLK = '1') then
			if(Period = 1) then
				RamControl <= "011";
			elsif(Period = 2) then
				RamControl <= "000";
			elsif(Period = 3) then
				case Instruction(15 downto 11) is
					when "10011" =>--LW
						RamControl <= "010";
					when "10010" => --LW_SP
						RamControl <= "010";
					when "11011" =>--SW
						RamControl <= "101";
					when "11010" =>
						RamControl <= "110";
					when others =>
				end case;
			elsif(Period = 4) then
				case Instruction(15 downto 11) is
					when "10011" =>--LW
						RamControl <= "100";
					when "10010" => --LW_SP
						RamControl <= "100";
					when "11011" =>--SW
						RamControl <= "111";
					when "11010" =>
						RamControl <= "111";
					when "11101" =>
						case Instruction(4 downto 0) is
							when "00000" =>						
								case Instruction(7 downto 5) is
									when "010" =>					-- 16.MFPC
									when others =>
								end case;
							when others=>
						end case;
					when others =>
						RamControl <= "001";
				end case;
			elsif(Period = 5) then
				case Instruction(15 downto 11) is
					when "11101" =>
						case Instruction(4 downto 0) is
							when "00000" =>						
								case Instruction(7 downto 5) is
									when "010" =>					-- 16.MFPC
										RamControl <= "001";
									when others =>
								end case;
							when others=>
						end case;
					when others =>
				end case;
			elsif(Period = 6) then
				RamControl <= "001";
			else
			end if;
--		end if;
	end process;


end Behavioral;

