----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:07:08 11/17/2016 
-- Design Name: 
-- Module Name:    RamBlock - Behavioral 
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

entity RamBlock is
    Port ( RegX : in STD_LOGIC_VECTOR (15 downto 0);
			  RegY : in STD_LOGIC_VECTOR (15 downto 0);
			  ALU : in STD_LOGIC_VECTOR(15 downto 0);
			  PC : in STD_LOGIC_VECTOR(15 downto 0);
			  RamControl : in STD_LOGIC_VECTOR(2 downto 0);
			  Finish : out STD_LOGIC;
			  Output : out STD_LOGIC_VECTOR(15 downto 0);
			  Ins : out STD_LOGIC_VECTOR(15 downto 0);
			  RAM1ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM1DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM1_EN : out  STD_LOGIC;
           RAM1_OE : out  STD_LOGIC;
           RAM1_WE : out  STD_LOGIC;
			  RAM2ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM2DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM2_EN : out  STD_LOGIC;
           RAM2_OE : out  STD_LOGIC;
           RAM2_WE : out  STD_LOGIC;
			  DATA_READY : in  STD_LOGIC;
           RDN : out  STD_LOGIC;
           TBRE : in  STD_LOGIC;
           TSRE : in  STD_LOGIC;
           WRN : out  STD_LOGIC;
			  DYP : out STD_LOGIC_VECTOR(6 downto 0);
           CLK : in  STD_LOGIC;
			  START : in STD_LOGIC);
end RamBlock;

architecture Behavioral of RamBlock is

component DigitLights is
    Port ( L : out  STD_LOGIC_VECTOR (6 downto 0);
           NUMBER : in  INTEGER);
end component;

signal state: integer range 0 to 7:=0;
shared variable uart_buf: STD_LOGIC_VECTOR (7 downto 0) := "00000000";

begin
	
	DL: DigitLights port map (DYP, state);
	
	RAM2_EN <= '1';
	RAM2_OE <= '1';
	RAM2_WE <= '1';
	RAM2ADDR <= (others => '0');
	RAM2DATA <= (others => 'Z');

	process(RamControl,CLK)
	begin
		if(CLK'event and CLK='1' and RamControl="001")then
			Ins<=RAM1DATA;
		end if;
	end process;
	
	process(RamControl,CLK)
	begin
		if(CLK'event and CLK='0' and RamControl="010")then
			case state is
				when 0 => -- RAM Read
					Output <= RAM1DATA;
				when 1 => -- UART Data Read
					Output <= "00000000"&RAM1DATA(7 downto 0);
				when 2 => -- UART State Read
					Output <= "00000000000000"&DATA_READY&(TBRE and TSRE);
				when others =>
			end case;
		end if;
	end process;
	
	process(RamControl,CLK)
	begin
		if(START='0')then
			RAM1_EN <= '1';
			RAM1_OE <= '1';
			RAM1_WE <= '1';
			RAM1ADDR <= (others => '0');
			RAM1DATA <= (others => 'Z');
			WRN <= '1';
			RDN <= '1';
			state <= 0;
			uart_buf:="00000000";
		elsif(CLK='0')then
			case RamControl is
				when "001" => -- Read Ins
					RAM1ADDR <= "00"&PC;
					RAM1DATA <= (others => 'Z');
					RAM1_OE <= '0';
					RAM1_EN <= '0';
					RAM1_WE <= '1';
					WRN <= '1';
					RDN <= '1';
				when "100" => -- Finish Read Data
					RAM1_EN <= '1';
					RAM1_OE <= '1';
					RAM1_WE <= '1';
					WRN <= '1';
					RDN <= '1';
					FINISH <= '1';
				when "111" => --Finish Write Reg
					RAM1_WE <= '1';
					RAM1_EN <= '1';
					RAM1_OE <= '1';
					RDN <= '1';
					FINISH <= '1';
					case state is
						when 0 => -- Finish Write
							WRN <= '1';
						when 1 =>
							WRN <= '0';
							RAM1DATA(7 downto 0) <= uart_buf;
						when others =>
					end case;
				when others =>
					RAM1_WE <= '1';
					RAM1_EN <= '1';
					RAM1_OE <= '1';
					WRN <= '1';
					RDN <= '1';
					FINISH <= '0';
			end case;
		else
			case RamControl is
				when "011" => -- Finish Read Ins
					RAM1_OE <= '1';
					RAM1_EN <= '1';
				when "010" => -- Read Data
					RAM1DATA <= (others => 'Z');
					RAM1_WE <= '1';
					WRN <= '1';
					FINISH <= '0';
					if(ALU(15 downto 1)="101111110000000")then -- UART Read
						RAM1_EN <= '1';
						RAM1_OE <= '1';
						if(ALU(0)='0')then
							RDN <= '0';
							state <= 1; -- UART Data Read
						else
							RDN <= '1';
							state <= 2; -- UART State Read
						end if;
					else -- Ram Read
						RDN <= '1';
						RAM1ADDR <= "00"&ALU;
						RAM1_EN <= '0';
						RAM1_OE <= '0';
						state <= 0; -- Ram Read
					end if;
				when "101"|"110" => --Write Reg
					FINISH <= '0';
					RAM1_OE <= '1';
					RDN <= '1';
					WRN <= '1';
					if(ALU(15 downto 1)="101111110000000")then --UART Write
						RAM1_EN <= '1';
						RAM1_WE <= '1';
						if(ALU(0)='0')then
							if(RamControl="101")then
								uart_buf := RegX(7 downto 0);
							else
								uart_buf := RegY(7 downto 0);
							end if;
						else
							uart_buf := "000000"&DATA_READY&(TBRE and TSRE);
						end if;
						state <= 1; -- UART Write
					else -- Ram Write
						RAM1ADDR <= "00"&ALU;
						if(RamControl="101")then
							RAM1DATA <= RegX;
						else
							RAM1DATA <= RegY;
						end if;
						RAM1_EN <= '0';
						RAM1_WE <= '0';
						state <= 0; -- Ram Write
					end if;
				when others =>
					RAM1_WE <= '1';
					RAM1_EN <= '1';
					RAM1_OE <= '1';
					WRN <= '1';
					RDN <= '1';
					FINISH <= '0';
			end case;
		end if;
	end process;
	
--	process(RamControl,CLK)
--	begin
--		if(CLK'event and CLK='1')then
--			if(boot='1')then
--				case state is
--					when 0 =>
--						WRN<='1';
--						RDN<='1';
--						RAM1_WE<='1';
--						RAM1_OE<='1';
--						RAM1_EN<='0';
--						if(count=0)then
--							state<=2;
--						else
--							state <= 1;
--						end if;
--						Finish<= '0';
--					when 1 =>
--						RAM1ADDR <= "0000000000000000"+count;
--						case count is
--							when others => RAM1DATA <= (others => '1');
--						end case;
--						state <= 2;
--					when 2 =>
--						RAM1_WE <= '0';
--						if(count=0)then
--							state <= 3;
--						else
--							state <= 0;
--						end if;
--						count := count+1;
--					when 3 =>
--						RAM1_WE <= '1';
--						state <= 4;
--					when 4 =>
--						RAM1ADDR <= "00"&PC;
--						RAM1DATA <= (others => 'Z');
--						RAM1_OE <= '0';
--						RAM1_EN <= '0';
--						RAM1_WE <= '1';
--						WRN <= '1';
--						RDN <= '1';
--						state <= 5;
--					when others =>
--						state <= 0;
--						boot <= '0';
--						finish <= '1';
--				end case;
--			else
--				case RamControl is
--					when "001" => -- Read Ins
--						RAM1ADDR <= "00"&PC;
--						RAM1DATA <= (others => 'Z');
--						RAM1_OE <= '0';
--						RAM1_EN <= '0';
--						RAM1_WE <= '1';
--						WRN <= '1';
--						RDN <= '1';
--					when "011" => -- Finish Read Ins
--						Ins <= RAM1DATA;
--						RAM1_OE <= '1';
--						RAM1_EN <= '1';
--					when "010" => -- Read Data
--						RAM1DATA <= (others => 'Z');
--						FINISH <= '0';
--						if(ALU(15 downto 0)="1011111100000000")then -- UART Read
--							RAM1_EN <= '1';
--							RAM1_OE <= '1';
--							RAM1_WE <= '1';
--							WRN <= '1';
--							RDN <= '1';
--							state <= 1;
--						elsif(ALU(15 downto 0)="1011111100000001")then -- UART Read DATA_READY
--							RAM1_EN <= '1';
--							RAM1_OE <= '1';
--							RAM1_WE <= '1';
--							WRN <= '1';
--							RDN <= '1';
--							FINISH <= '0';
--							state <= 3;
--						else -- Ram Read
--							RAM1ADDR <= "00"&ALU;
--							RAM1_EN <= '0';
--							RAM1_OE <= '0';
--							RAM1_WE <= '1';
--							WRN <= '1';
--							RDN <= '1';
--							state <= 0;
--						end if;
--					when "100" => -- Finish Read Data
--						RAM1_EN <= '1';
--						RAM1_OE <= '1';
--						RAM1_WE <= '1';
--						WRN <= '1';
--						case state is
--							when 0 => -- RAM Read Finish
--								Output <= RAM1DATA;
--								RDN <= '1';
--								FINISH <= '1';
--							when 1 => -- UART Reading
--								if(DATA_READY='0')then -- Not Ready
--									RDN<='1';
--									RAM1DATA <= (others => 'Z');
--								else -- Ready
--									RDN<='0';
--									state <= 2;
--								end if;
--							when 2 => -- UART Output
--								Output <= "00000000"&RAM1DATA(7 downto 0);
--								RDN <= '1';
--								FINISH <= '1';
--							when 3 =>
--								Output <= "00000000000000"&DATA_READY&'1';
--								FINISH <= '1';
--							when others =>
--						end case;
--					when "101" => --Write RegX
--						FINISH <= '0';
--						if(ALU(15 downto 1)="101111110000000")then --UART Write
--							RAM1_EN <= '1';
--							RAM1_OE <= '1';
--							RAM1_WE <= '1';
--							RDN <= '1';
--							WRN <= '1';
--							if(ALU(0)='0')then
--								uart_buf := RegX(7 downto 0);
--							else
--								uart_buf := "0000000"&DATA_READY;
--							end if;
--							state <= 1;
--						else -- Ram Write
--							RAM1ADDR <= "00"&ALU;
--							RAM1DATA <= RegX;
--							RAM1_EN <= '0';
--							RAM1_OE <= '1';
--							RAM1_WE <= '0';
--							RDN <= '1';
--							WRN <= '1';
--							state <= 0;
--						end if;
--					when "110" => --Write RegY
--						FINISH <= '0';
--						if(ALU(15 downto 1)="101111110000000")then --UART Write
--							RAM1_EN <= '1';
--							RAM1_OE <= '1';
--							RAM1_WE <= '1';
--							RDN <= '1';
--							WRN <= '1';
--							if(ALU(0)='0')then
--								uart_buf := RegY(7 downto 0);
--							else
--								uart_buf := "0000000"&DATA_READY;
--							end if;
--							state <= 1;
--						else -- Ram Write
--							RAM1ADDR <= "00"&ALU;
--							RAM1DATA <= RegY;
--							RAM1_EN <= '0';
--							RAM1_OE <= '1';
--							RAM1_WE <= '0';
--							RDN <= '1';
--							WRN <= '1';
--							state <= 0;
--						end if;
--					when "111" => --Finish Write Reg
--						RAM1_WE <= '1';
--						RAM1_EN <= '1';
--						RAM1_OE <= '1';
--						RDN <= '1';
--						case state is
--							when 0 => -- Finish Write
--								WRN <= '1';
--								FINISH <= '1';
--							when 1 =>
--								WRN <= '0';
--								RAM1DATA(7 downto 0) <= uart_buf;
--								state <= 2;
--							when 2 =>
--								WRN <= '1';
--								state <= 3;
--							when 3 => -- UART Writing
--								if(TBRE='1')then
--									state <= 4;
--								end if;
--							when 4 => -- UART Writing
--								if(TSRE='1')then
--									WRN <= '1';
--									FINISH <= '1';
--								end if;
--							when others =>
--						end case;
--					when others =>
--						RAM1_WE <= '1';
--						RAM1_OE <= '1';
--						RAM1_EN <= '1';
--						WRN <= '1';
--						RDN <= '1';
--						FINISH <= '0';
--				end case;
--			end if;
--		end if;
--	end process;

end Behavioral;

