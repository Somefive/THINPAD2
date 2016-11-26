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
           CLK : in  STD_LOGIC;
			  START : in STD_LOGIC);
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
           RamControl : out  STD_LOGIC_VECTOR(2 downto 0);
			  DYP : out STD_LOGIC_VECTOR(6 downto 0);
			  START: in STD_LOGIC);
end component;

component RABlock is
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

signal Finish: STD_LOGIC := '1';
signal Ins: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal Output: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal T: STD_LOGIC:='0';

signal START: STD_LOGIC:='0';
--signal state: integer;
--signal st_low:integer:=1;
--signal st_high:integer:=2;
begin
--	DL: DigitLights port map(DYP0,state);
--	with CLK_KEY select state <=
--		st_low when '0',
--		st_high when others;
--	process(CLK_KEY)
--	begin
--		if(START='0')then
--			st_low<=1;
--		elsif(CLK_KEY'event and CLK_KEY='0')then
--			st_low<=st_high+1;
--		end if;
--	end process;
--	
--	process(CLK_KEY)
--	begin
--		if(START='0')then
--			st_high<=2;
--		elsif(CLK_KEY'event and CLK_KEY='1')then
--			st_high<=st_low+1;
--		end if;
--	end process;
--	
--	process(state)
--	begin
--		if(START='0')then
--		else
--		case state is
--			when 4 =>
--				ALU <= "0100000000000000";
--				RegX <= "0000000010000000";
--				RegY <= "0000000000001000";
--				RamControl <= "101";
--			when 5 =>
--				RamControl <= "111";
--			when 6 =>
--				ALU <= "1011111100000001";
--				RamControl <= "010";
--			when 7 =>
--				RamControl <= "100";
--				FPGA_LED <= Output;
--			when 8 =>
--				ALU <= "1011111100000000";
--				RegX <= "0000000010000000";
--				RegY <= "0000000000001000";
--				RamControl <= "110";
--			when 9 =>
--				RamControl <= "111";
--			when others =>
--		end case;
--		end if;
--	end process;

	PCBlock_Entity: PCBlock port map (
		RegX,
		T,
		Ins(10 downto 0),
		PCControl,
		PC,
		CLK
	);
	
	ControlBlock_Entity: ControlBlock port map( 
		Ins,
		Finish,
		CLK,
		PCControl,
		RAControl,
		RamControl,
		DYP0,
		START
	);
	
	RamBlock_Entity: RamBlock port map(
		RegX,
		RegY,
		ALU,
		PC,
		RamControl,
		Finish,
		Output,
		Ins,
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
		DYP1,
		CLK,
		START
	);
	
	RABlock_Entity : RABlock port map(
		Ins(10 downto 0),
		PC,
		Output,
		RAControl,
		RegX,
		RegY,
		T,
		ALU,
		CLK
	);
		
	with SW_DIP select FPGA_LED <=
		PC     when "0000000000000001",
		ALU    when "0000000000000010",
		RegX   when "0000000000000100",
		RegY   when "0000000000001000",
		"000000000000000"&T when "0000000000010000",
		Output when "0000000000100000",
		Ins    when "0000000001000000",
		"00000000000"&RAControl      when "0000000010000000",
		"0000000000000"&RamControl   when "0000000100000000",
		"0000000000000"&PCControl    when "0000001000000000",
		"000000000000000"&Finish     when "0000010000000000",
		"00000000000000"&DATA_READY&(TBRE and TSRE) when "0000100000000000",
		"000000000000000"&START      when "0001000000000000",
		"1010101010101010" when others;
		
	process(RESET)
	begin
		if(START='1')then
		elsif(RESET'event and RESET='1')then
			START <= '1';
		end if;
	end process;
	
end Behavioral;

