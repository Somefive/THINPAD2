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
			  Flash_byte : OUT STD_LOGIC := '1';
			  Flash_vpen : OUT STD_LOGIC := '1';
			  Flash_ce : OUT STD_LOGIC := '0';
			  Flash_oe : OUT STD_LOGIC := '1';
			  Flash_we : OUT STD_LOGIC := '1';
			  Flash_rp : OUT STD_LOGIC := '1';      
			  Flash_addr : OUT STD_LOGIC_VECTOR(22 downto 0) := "00000000000000000000000";
			  Flash_data : INOUT STD_LOGIC_VECTOR(15 downto 0) := "ZZZZZZZZZZZZZZZZ");
end RamBlock;

architecture Behavioral of RamBlock is

component DigitLights is
    Port ( L : out  STD_LOGIC_VECTOR (6 downto 0);
           NUMBER : in  INTEGER);
end component;


signal state: integer range 0 to 7:=0;
shared variable uart_buf: STD_LOGIC_VECTOR (7 downto 0) := "00000000";
signal boot: STD_LOGIC := '1';
shared variable count: integer range 0 to 63:=0;

shared variable CLK_Flash : integer := 0;
signal Pro_addr : STD_LOGIC_VECTOR(15 downto 0) := "0000000000000000";
signal Flash_runable : STD_LOGIC := '0';
signal flash_state : integer range 0 to 10 := 1;

begin
	
	DL: DigitLights port map (DYP, flash_state);
	
	RAM2_EN <= '1';
	RAM2_OE <= '1';
	RAM2_WE <= '1';
	RAM2ADDR <= (others => '0');
	RAM2DATA <= (others => 'Z');
	
	process(RamControl,CLK)
	begin
		if(CLK'event and CLK='1')then
			if(Flash_runable = '0')then
				CLK_Flash := CLK_Flash + 1;
				WRN <= '1';
				RDN <= '1';
				if(CLK_Flash = 5) then
					CLK_Flash := 0;
					
					case flash_state is
						when  1=>
							Flash_we <= '0';
							Flash_oe <= '1';
							Flash_ce <= '0';
							Flash_rp <= '1';
							Flash_byte <= '1';
							Flash_vpen <= '1';
							RAM1_EN <= '0';
							RAM1_OE <= '1';
							RAM1_WE <= '0';
							flash_state <= 2;
						when 2 =>
							Flash_data <= x"00FF";
							RAM1ADDR <= "00" & Pro_addr;
							flash_state <= 3;
						when 3 =>
							Flash_we <= '1';
							flash_state <= 4;
						when 4 =>
							Flash_addr <= "000000" & Pro_addr &'0';
							Flash_data <= "ZZZZZZZZZZZZZZZZ";
							Flash_oe <= '0';
							flash_state <= 5;
						when 5 =>
							RAM1DATA <= Flash_data;
							Flash_oe <= '1';
							flash_state <= 6;
						when 6 =>
							--RAM1_WE <= '0';
							Pro_addr <= Pro_addr + '1';
							RAM1_WE <= '1';
							flash_state <= 1;
						when others =>
						
					end case;
					if(Pro_addr > x"0400") then
						flash_state <= 9;
						Flash_runable <= '1';
					end if;
				end if;
			elsif(boot='1')then
				case state is
					when 0 =>
						WRN<='1';
						RDN<='1';
						RAM1_WE<='1';
						RAM1_OE<='1';
						RAM1_EN<='0';
						if(count=0)then
							state<=2;
						else
							state <= 1;
						end if;
						Finish<= '0';
					when 1 =>
						RAM1ADDR <= "0000000000000000"+count;
						case count is
--							when 0 => RAM1DATA <= "01101"&"000"&"01000001"; --LI R0 0X41
--							when 1 => RAM1DATA <= "01101"&"001"&"01000101"; --LI R1 0X45
--							WHEN 2 => RAM1DATA <= "01111"&"010"&"000"&"00000";	--MOVE R2 R0
--							when 3 => RAM1DATA <= "11101"&"010"&"000"&"01011"; --NEG R2 R0
--							when 4 => RAM1DATA <= "00001"&"00000000000"; --NOP 
--							when 5 => RAM1DATA <= "11101"&"000"&"001"&"01101"; --OR R0 R1
--							when 6 => RAM1DATA <= "00110"&"000"&"001"&"001"&"00"; --SLL R0 R1 0X01
--							when 7 => RAM1DATA <= "11101"&"001"&"01000000"; --MFPC R1
--							WHEN 8 => RAM1DATA <= "01101"&"010"&"00000001"; --LI R2 0X01
--							WHEN 9 => RAM1DATA <= "11101"&"010"&"001"&"00100"; --SLLV R2 R1
--							WHEN 10 => RAM1DATA <= "00110"&"000"&"001"&"000"&"11"; --SRA R0 R1 0
--							WHEN 11 => RAM1DATA <= "11100"&"000"&"001"&"000"&"11"; --SUBU R0 R1 R0
--							WHEN 12 => RAM1DATA <= "01101"&"000"&"01000001"; -- LI R0 0X41
--							WHEN 13 => RAM1DATA <= "01100100"&"000"&"00000"; --MTSP R0
--							WHEN 14 => RAM1DATA <= "11010"&"000"&"00000001"; --SW_SP R0 0X01
--							WHEN 15 => RAM1DATA <= "10010"&"000"&"00000001"; --LW_SP R0 0X01
							
							
							--when 6 => RAM1DATA <= "11101"&"000"&"01000000"; --MFPC R0
							--when 3 => RAM1DATA <= "00010"&"00000000001"; --B 0x01
							--when 4 => RAM1DATA <= "00010"&"00000000001"; --B 0x01
							when others => RAM1DATA <= (others => '1');
						end case;
						state <= 2;
					when 2 =>
						RAM1_WE <= '0';
						if(count=0)then
							state <= 3;
						else
							state <= 0;
						end if;
						count := count+1;
					when 3 =>
						RAM1_WE <= '1';
						state <= 4;
					when 4 =>
						RAM1ADDR <= "00"&PC;
						RAM1DATA <= (others => 'Z');
						RAM1_OE <= '0';
						RAM1_EN <= '0';
						RAM1_WE <= '1';
						WRN <= '1';
						RDN <= '1';
						state <= 5;
					when others =>
						state <= 0;
						boot <= '0';
						finish <= '1';
				end case;
			else
				case RamControl is
					when "001" => -- Read Ins
						RAM1ADDR <= "00"&PC;
						RAM1DATA <= (others => 'Z');
						RAM1_OE <= '0';
						RAM1_EN <= '0';
						RAM1_WE <= '1';
						WRN <= '1';
						RDN <= '1';
					when "011" => -- Finish Read Ins
						Ins <= RAM1DATA;
						RAM1_OE <= '1';
						RAM1_EN <= '1';
					when "010" => -- Read Data
						RAM1DATA <= (others => 'Z');
						FINISH <= '0';
						if(ALU(15 downto 0)="1011111100000000")then -- UART Read
							RAM1_EN <= '1';
							RAM1_OE <= '1';
							RAM1_WE <= '1';
							WRN <= '1';
							RDN <= '1';
							state <= 1;
						elsif(ALU(15 downto 0)="1011111100000001")then -- UART Read DATA_READY
							RAM1_EN <= '1';
							RAM1_OE <= '1';
							RAM1_WE <= '1';
							WRN <= '1';
							RDN <= '1';
							FINISH <= '0';
							state <= 3;
						else -- Ram Read
							RAM1ADDR <= "00"&ALU;
							RAM1_EN <= '0';
							RAM1_OE <= '0';
							RAM1_WE <= '1';
							WRN <= '1';
							RDN <= '1';
							state <= 0;
						end if;
					when "100" => -- Finish Read Data
						RAM1_EN <= '1';
						RAM1_OE <= '1';
						RAM1_WE <= '1';
						WRN <= '1';
						case state is
							when 0 => -- RAM Read Finish
								Output <= RAM1DATA;
								RDN <= '1';
								FINISH <= '1';
							when 1 => -- UART Reading
								if(DATA_READY='0')then -- Not Ready
									RDN<='1';
									RAM1DATA <= (others => 'Z');
								else -- Ready
									RDN<='0';
									state <= 2;
								end if;
							when 2 => -- UART Output
								Output <= "00000000"&RAM1DATA(7 downto 0);
								RDN <= '1';
								FINISH <= '1';
							when 3 =>
								Output <= "00000000000000"&DATA_READY&'1';
								FINISH <= '1';
							when others =>
						end case;
					when "101" => --Write RegX
						FINISH <= '0';
						if(ALU(15 downto 1)="101111110000000")then --UART Write
							RAM1_EN <= '1';
							RAM1_OE <= '1';
							RAM1_WE <= '1';
							RDN <= '1';
							WRN <= '1';
							if(ALU(0)='0')then
								uart_buf := RegX(7 downto 0);
							else
								uart_buf := "0000000"&DATA_READY;
							end if;
							state <= 1;
						else -- Ram Write
							RAM1ADDR <= "00"&ALU;
							RAM1DATA <= RegX;
							RAM1_EN <= '0';
							RAM1_OE <= '1';
							RAM1_WE <= '0';
							RDN <= '1';
							WRN <= '1';
							state <= 0;
						end if;
					when "110" => --Write RegY
						FINISH <= '0';
						if(ALU(15 downto 1)="101111110000000")then --UART Write
							RAM1_EN <= '1';
							RAM1_OE <= '1';
							RAM1_WE <= '1';
							RDN <= '1';
							WRN <= '1';
							if(ALU(0)='0')then
								uart_buf := RegY(7 downto 0);
							else
								uart_buf := "0000000"&DATA_READY;
							end if;
							state <= 1;
						else -- Ram Write
							RAM1ADDR <= "00"&ALU;
							RAM1DATA <= RegY;
							RAM1_EN <= '0';
							RAM1_OE <= '1';
							RAM1_WE <= '0';
							RDN <= '1';
							WRN <= '1';
							state <= 0;
						end if;
					when "111" => --Finish Write Reg
						RAM1_WE <= '1';
						RAM1_EN <= '1';
						RAM1_OE <= '1';
						RDN <= '1';
						case state is
							when 0 => -- Finish Write
								WRN <= '1';
								FINISH <= '1';
							when 1 =>
								WRN <= '0';
								RAM1DATA(7 downto 0) <= uart_buf;
								state <= 2;
							when 2 =>
								WRN <= '1';
								state <= 3;
							when 3 => -- UART Writing
								if(TBRE='1')then
									state <= 4;
								end if;
							when 4 => -- UART Writing
								if(TSRE='1')then
									WRN <= '1';
									FINISH <= '1';
								end if;
							when others =>
						end case;
					when others =>
						RAM1_WE <= '1';
						RAM1_OE <= '1';
						RAM1_EN <= '1';
						WRN <= '1';
						RDN <= '1';
						FINISH <= '0';
				end case;
			end if;
		end if;
	end process;
	
	

end Behavioral;

