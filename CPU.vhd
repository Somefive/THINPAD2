----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:45:02 11/17/2016 
-- Design Name: 
-- Module Name:    CPU - Behavioral 
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

entity CPU is
    Port ( SW_DIP : in  STD_LOGIC_VECTOR (15 downto 0);
           RAM1DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM2DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
           RAM1ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM2ADDR : out  STD_LOGIC_VECTOR (17 downto 0);
           RAM1_EN : out  STD_LOGIC;
           RAM1_OE : out  STD_LOGIC;
           RAM1_RW : out  STD_LOGIC;
           RAM2_EN : out  STD_LOGIC;
           RAM2_OE : out  STD_LOGIC;
           RAM2_RW : out  STD_LOGIC;
           FPGA_LED : out  STD_LOGIC_VECTOR (15 downto 0);
			  DYP0 : out  STD_LOGIC_VECTOR (6 downto 0);
           DYP1 : out  STD_LOGIC_VECTOR (6 downto 0);
			  DATA_READY : in  STD_LOGIC;
           RDN : out  STD_LOGIC;
           TBRE : in  STD_LOGIC;
           TSRE : in  STD_LOGIC;
           WRN : out  STD_LOGIC;
           CLK : in  STD_LOGIC;
			  CLK_KEY : in STD_LOGIC;
           RESET : in  STD_LOGIC);
end CPU;

architecture Behavioral of CPU is

component DigitLights is
    Port ( L : out  STD_LOGIC_VECTOR (6 downto 0);
           NUMBER : in  INTEGER);
end component;

component RamBlock is
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
           CLK : in  STD_LOGIC);
end component;

component PCBlock is
    Port ( RegX : in  STD_LOGIC_VECTOR (15 downto 0);
           T : in  STD_LOGIC;
           ImmLong : in  STD_LOGIC_VECTOR (10 downto 0);
           PCControl : in  STD_LOGIC_VECTOR (2 downto 0);
           PC : buffer  STD_LOGIC_VECTOR (15 downto 0);
			  CLK : in STD_LOGIC);
end component;

component ControlBlock is
    Port ( Instruction : in  STD_LOGIC_VECTOR(15 downto 0);
           Finish : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           PCControl : out  STD_LOGIC_VECTOR(2 downto 0);
           RAControl : out  STD_LOGIC_VECTOR(4 downto 0);
           RamControl : out  STD_LOGIC_VECTOR(2 downto 0));
end component;

component RABlock2 is
    Port ( ImmLong : in  STD_LOGIC_VECTOR (10 downto 0);
           PC : in  STD_LOGIC_VECTOR (15 downto 0);
           Data : in  STD_LOGIC_VECTOR (15 downto 0);
           RAControl : in  STD_LOGIC_VECTOR (4 downto 0);
           RegX : out  STD_LOGIC_VECTOR (15 downto 0);
           RegY : out  STD_LOGIC_VECTOR (15 downto 0);
           T : out  STD_LOGIC;
           ALU : out  STD_LOGIC_VECTOR (15 downto 0);
			  CLK : in STD_LOGIC);
end component;

signal RamControl: STD_LOGIC_VECTOR(2 downto 0):="000";
signal PCControl: STD_LOGIC_VECTOR(2 downto 0):="000";
signal RAControl: STD_LOGIC_VECTOR(4 downto 0):="00000";

signal RegX: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal RegY: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal ALU: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal PC: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";

signal Finish: STD_LOGIC;
signal Ins: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal Output: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal T: STD_LOGIC:='0';


signal state: integer range 0 to 63:=0;
signal fake_ins: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";

signal start: STD_LOGIC:='0';
shared variable count: integer range 0 to 63:=0;

--Test RABlock2
signal Data : std_logic_vector(15 downto 0):="0000000000000000";
signal RABlock_Ins : std_logic_vector(10 downto 0) := "00000000000";
signal RABlock_PC : std_logic_vector(15 downto 0) := "0000000000000000";


begin

	DL: DigitLights port map (DYP1, state);

	RamBlock_Entity: RamBlock port map (
		RegX,
		RegY,
		ALU,
		PC,
		RamControl,
		Finish,
		Output,
		fake_ins,
		RAM1ADDR,
		RAM1DATA,
		RAM1_EN,
		RAM1_OE,
		RAM1_RW,
		RAM2ADDR,
		RAM2DATA,
		RAM2_EN,
		RAM2_OE,
		RAM2_RW,
		DATA_READY,
		RDN,
		TBRE,
		TSRE,
		WRN,
		DYP0,
		CLK_KEY
	);
	
	PCBlock_Entity: PCBlock port map (
		RegX,
		T,
		fake_ins(10 downto 0),
		PCControl,
		PC,
		CLK_KEY
	);
	
--	ControlBlock_Entity: ControlBlock port map( 
--		Ins,
--		Finish,
--		CLK_KEY,
--		PCControl,
--		RAControl,
--		RamControl
--	);
	
	RABlock_Entity: RABlock2 port map(
		RABlock_Ins,
		RABlock_PC,
		Data,
		RAControl,
		RegX,
		RegY,
		T,
		ALU,
		CLK_KEY);
		
		
--	process(start,finish)
--	begin
--		if(finish'event and finish='1')then
--			start<='1';
--		end if;
--	end process;
	
--	process(CLK_KEY)
--	begin
--		if(start='0')then
			
--		elsif(CLK_KEY'event and CLK_KEY='1')then
--			case state is
--				when 0 =>
--					RamControl <= "000";
--					state <= 1;
--				when 1 =>
--					FPGA_LED <= fake_ins;
--					RamControl <= "001";
--					PC <= "0000000000000000"+count;
--					state <= 2;
--				when 2 =>
--					RamControl <= "011";
--					count := count+1;
--					state <= 0;
--				when others =>
--			end case;
--		end if;
--	end process;
	
	process(CLK_KEY)
	begin
		if(CLK_KEY'event and CLK_KEY='0')then
			case state is
				when 0 =>
					RAControl <= "00001";
					RABlock_Ins  <= SW_DIP(10 downto 0);
					RABlock_PC   <= "0000000000001001";
					Data         <= "0000000000000110";
					state <= 1;
				when 1 =>
					RAControl <= "00010";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 2;
				when 2 =>
					RAControl <= "00011";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 3;
				when 3 =>
					RAControl <= "00100";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 4;
				when 4 =>
					RAControl <= "00101";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 5;
				when 5 =>
					RAControl <= "00110";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 6;
				when 6 =>
					RAControl <= "00111";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 7;
				when 7 =>
					RAControl <= "01000";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 8;
				when 8 =>
					RAControl <= "01001";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 9;
				when 9 =>
					RAControl <= "01010";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 10;
				when 10 =>
					RAControl <= "01011";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 11;
				when 11 =>
					RAControl <= "01100";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 12;
				when 12 =>
					RAControl <= "01101";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 13;
				when 13 =>
					RAControl <= "01110";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 14;
				when 14 =>
					RAControl <= "01111";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 15;
				when 15 =>
					RAControl <= "10000";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 16;
				when 16 =>
					RAControl <= "10001";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 17;
				when 17 =>
					RAControl <= "10010";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 18;
				when 18 =>
					RAControl <= "10011";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 19;
				when 19 =>
					RAControl <= "10100";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 20;
				when 20 =>
					RAControl <= "10101";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 21;
				when 21 =>
					RAControl <= "10110";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 22;
				when 22 =>
					RAControl <= "10111";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 23;
				when 23 =>
					RAControl <= "11000";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 24;
				when 24 =>
					RAControl <= "11001";
					RABlock_Ins <= SW_DIP(10 downto 0);
					state <= 25;
				when others =>
					state <= 0;
			end case;
		end if;
	end process;
	FPGA_LED(15 downto 11) <= RegX(4 downto 0);
	FPGA_LED(10 downto 6) <= RegY(4 downto 0);
	FPGA_LED(5 downto 1) <= ALU(4 downto 0); 
	FPGA_LED(0) <= T;
end Behavioral;

