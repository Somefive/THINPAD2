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
			  DYP : out STD_LOGIC_VECTOR(6 downto 0));
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

	process(Finish)
	begin
		if(Finish'event and Finish='1') then--??
			Runable <= '0';
			--RamControl <= "001";
		end if;
	end process;

	process(CLK,Finish)
	begin
		if(CLK'event and CLK = '1') then
			--if(Runable = '1') then
				--Period <= 4;
			if(Instruction(15 downto 11) = "10011" or Instruction(15 downto 11) = "10010") then
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
			elsif(Instruction(15 downto 11) = "11101" and Instruction(7 downto 0) = "01000000") then
				if(Period = 1) then
					Period <= 2;
				elsif(Period = 2) then
					Period <= 3;
				elsif(Period = 3) then
					Period <= 4;
				elsif(Period = 4) then
					Period <= 1;
				else
				end if;
			else
				if(Period = 1) then
						Period <= 2;
					elsif(Period = 2) then
						Period <= 3;
					elsif(Period = 3) then
						Period <= 1;
					end if;
			end if;
		end if;
		
	end process;
	
	process(Period)
	begin
		if(Period = 1) then
			RAControl <= "00000";
		elsif(Period = 2) then
			case Instruction(15 downto 11) is
				when "00000" => 								-- 28.ADDSP3
					PCControl <= "001";
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
						when "11" => 							-- 22.SRA
							PCControl <= "001";
						when others =>
					end case;
				when "01000" => 								-- 2.ADDIU3
					PCControl <= "001";
				when "01001" => 								-- 1.ADDIU
					PCControl <= "001";
				when "01100" =>
					case Instruction(10 downto 8) is
						when "011" => 							-- 3.ADDSP
							PCControl <= "001";
						when "000" => 							-- 9.BTEQZ
							PCControl <= "101";
						when "100" => 							-- 18.MTSP
							PCControl <= "001";
						when others =>
					end case;
				when "01101" => 								-- 12.LI
					PCControl <= "001";
				when "01110" => 								-- 29.CMPI
					PCControl <= "001";
				when "01111" => 								-- 26.MOVE
					PCControl <= "001";
				when "10010" => 								-- 14.LW_SP
					
				when "10011" => 								-- 13.LW
					
				when "11010" => 								-- 25.SW_SP
					
				when "11011" => 								-- 24.SW
					
				when "11100" => 								
					case Instruction(1 downto 0) is
						when "01" =>							-- 4.ADDU
							PCControl <= "001";
						when "11" =>							-- 23.SUBU
							PCControl <= "001";
						when others =>
					end case;
				when "11101" =>
					case Instruction(4 downto 0) is
						when "01100" =>						-- 5.AND
							PCControl <= "001";
						when "01010" =>						-- 10.CMP
							PCControl <= "001";
						when "00000" =>						
							case Instruction(7 downto 5) is
								when "000" =>					-- 11.JR
									PCControl <= "110";
								when "010" =>					-- 16.MFPC

								when others =>
							end case;
						when "01101" =>						-- 20.OR
							PCControl <= "001";
						when "00100" =>						-- 27.SLLV
							PCControl <= "001";
						when "01011" =>						-- 30.NEG
							PCControl <= "001";
						when others =>
					end case;
				when "11110" => 								
					case Instruction(7 downto 0) is
						when "00000000" =>					-- 15.MFIH
							PCControl <= "001";
						when "00000001" =>					-- 17.MTIH
							PCControl <= "001";
						when others =>
					end case;
				when others =>
			end case;
		elsif(Period = 3) then
			case Instruction(15 downto 11) is
				when "00000" => 								-- 28.ADDSP3
					RAControl <= "00100";
					--PCControl <= "001";
				when "00001" => 								-- 19.NOP
					--PCControl <= "001";
				when "00010" => 								-- 6.B
					--PCControl <= "010";
				when "00100" => 								-- 7.BEQZ
					--PCControl <= "011";
				when "00101" => 								-- 8.BNEZ
					--PCControl <= "100";
				when "00110" =>
					case Instruction(1 downto 0) is
						when "00" => 							-- 21.SLL
							RAControl <= "10100";
							--PCControl <= "001";
						when "11" => 							-- 22.SRA
							RAControl <= "10110";
							--PCControl <= "001";
						when others =>
					end case;
				when "01000" => 								-- 2.ADDIU3
					RAControl <= "00010";
					--PCControl <= "001";
				when "01001" => 								-- 1.ADDIU
					RAControl <= "00001";
					--PCControl <= "001";
				when "01100" =>
					case Instruction(10 downto 8) is
						when "011" => 							-- 3.ADDSP
							RAControl <= "00011";
							--PCControl <= "001";
						when "000" => 							-- 9.BTEQZ
							--PCControl <= "101";
						when "100" => 							-- 18.MTSP
							RAControl <= "10001";
							--PCControl <= "001";
						when others =>
					end case;
				when "01101" => 								-- 12.LI
					RAControl <= "01010";
					--PCControl <= "001";
				when "01110" => 								-- 29.CMPI
					RAControl <= "01000";
					--PCControl <= "001";
				when "01111" => 								-- 26.MOVE
					RAControl <= "01111";
					--PCControl <= "001";
				when "10010" => 								-- 14.LW_SP
					RAControl <= "01100";
				when "10011" => 								-- 13.LW
					RAControl <= "01011";
				when "11010" => 								-- 25.SW_SP
					RAControl <= "01100";
				when "11011" => 								-- 24.SW
					RAControl <= "01011";
				when "11100" => 								
					case Instruction(1 downto 0) is
						when "01" =>							-- 4.ADDU
							RAControl <= "00101";
							--PCControl <= "001";
						when "11" =>							-- 23.SUBU
							RAControl <= "10111";
							--PCControl <= "001";
						when others =>
					end case;
				when "11101" =>
					case Instruction(4 downto 0) is
						when "01100" =>						-- 5.AND
							RAControl <= "00110";
							--PCControl <= "001";
						when "01010" =>						-- 10.CMP
							RAControl <= "00111";
							--PCControl <= "001";
						when "00000" =>						
							case Instruction(7 downto 5) is
								when "000" =>					-- 11.JR
									RAControl <= "01001";--??
									--PCControl <= "110";
								when "010" =>					-- 16.MFPC
									RAControl <= "01110";
								when others =>
							end case;
						when "01101" =>						-- 20.OR
							RAControl <= "10011";
							--PCControl <= "001";
						when "00100" =>						-- 27.SLLV
							RAControl <= "10101";
							--PCControl <= "001";
						when "01011" =>						-- 30.NEG
							RAControl <= "10010";
							--PCControl <= "001";
						when others =>
					end case;
				when "11110" => 								
					case Instruction(7 downto 0) is
						when "00000000" =>					-- 15.MFIH
							RAControl <= "01101";
							--PCControl <= "001";
						when "00000001" =>					-- 17.MTIH
							RAControl <= "10000";
							--PCControl <= "001";
						when others =>
					end case;
				when others =>
			end case;
		elsif(Period = 4) then
			case Instruction(15 downto 11) is
				when "00000" =>						
					case Instruction(7 downto 5) is
						when "010" =>					-- 16.MFPC
							PCControl <= "001";
						when others =>
					end case;
				when others =>
			end case;
		elsif(Period = 5) then
		elsif(Period = 6) then
			case Instruction(15 downto 11) is
				when "10011" =>--LW
					RAControl <= "11001";
					PCControl <= "001";
				when "10010" => --LW_SP
					RAControl <= "11000";
					PCControl <= "001";
				when others =>
			end case;
		else
		end if;
	end process;
	
	process(Period)
	begin
		--if(Runable = '1') then
			--RamControl <= "001";
		if(Period = 1) then
			RamControl <= "011";
		elsif(Period = 2) then
		
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
				when others =>
			end case;
		elsif(Period = 5) then
		
		elsif(Period = 6) then
			RamControl <= "001";--???不是所有经过
		else
		end if;
	end process;
	

end Behavioral;

