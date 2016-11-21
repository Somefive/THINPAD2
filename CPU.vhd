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
           RamControl : out  STD_LOGIC_VECTOR(2 downto 0);
			  DYP : out STD_LOGIC_VECTOR(6 downto 0));
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


signal state: integer range 0 to 15:=1;
signal next_state:integer range 0 to 15 := 2;
signal fake_ins: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";

signal start: STD_LOGIC:='0';
shared variable count: integer range 0 to 63:=0;

begin

	DL: DigitLights port map (DYP1, state);

--	RamBlock_Entity: RamBlock port map (
--		RegX,
--		RegY,
--		ALU,
--		PC,
--		RamControl,
--		Finish,
--		Output,
--		fake_ins,
--		RAM1ADDR,
--		RAM1DATA,
--		RAM1_EN,
--		RAM1_OE,
--		RAM1_RW,
--		RAM2ADDR,
--		RAM2DATA,
--		RAM2_EN,
--		RAM2_OE,
--		RAM2_RW,
--		DATA_READY,
--		RDN,
--		TBRE,
--		TSRE,
--		WRN,
--		DYP0,
--		CLK_KEY
--	);
	
	PCBlock_Entity: PCBlock port map (
		RegX,
		T,
		Ins(10 downto 0),
		PCControl,
		PC,
		CLK_KEY
	);
	
	ControlBlock_Entity: ControlBlock port map( 
		Ins,
		Finish,
		CLK_KEY,
		PCControl,
		RAControl,
		RamControl,
		DYP0
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
		CLK_KEY
	);
	
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

	FPGA_LED(15 downto 13) <= PCControl;
	FPGA_LED(12 downto 8) <= RAControl;
	FPGA_LED(7 downto 5) <= RamControl;
	FPGA_LED(4) <= Finish;
	FPGA_LED(3 downto 0) <= PC(3 downto 0);

	process(CLK_KEY)
	begin
		if(CLK_KEY'event and CLK_KEY='0')then
			case state is
				when 1 =>
					Ins <= SW_DIP;
				when 2 =>
					
				when 3 =>
				when 4 =>
				when 5 =>
				when 6 =>
				when others=>
			end case;
			state <= next_state;
		end if;
	end process;
	
	process(state)
	begin
		
--			if(Runable = '1') then
--				state <= 4;
			if(Ins(15 downto 11) = "10011" or Ins(15 downto 11) = "10010") then
				if(state = 1) then
					next_state <= 2;
				elsif(state = 2) then
					next_state <= 3;
				elsif(state = 3) then
					next_state <= 4;
				elsif(state = 4) then
					if(Finish='0') then--??
						next_state <= 5;
					end if;
				elsif(state = 5) then
					next_state <= 6;
				elsif(state = 6) then
					next_state <= 1;
				else
				end if;
			elsif(Ins(15 downto 11) = "11011" or Ins(15 downto 11) = "11010") then
				if(state = 1) then
					next_state <= 2;
				elsif(state = 2) then
					next_state <= 3;
				elsif(state = 3) then
					next_state <= 4;
				elsif(state = 4) then
					if(Finish='0') then--??
						next_state <= 5;
					end if;
				elsif(state = 5) then
					next_state <= 1;
				else
				end if;
			elsif(Ins(15 downto 11) = "11101" and Ins(7 downto 0) = "01000000") then
				if(state = 1) then
					next_state <= 2;
				elsif(state = 2) then
					next_state <= 3;
				elsif(state = 3) then
					next_state <= 4;
				elsif(state = 4) then
					next_state <= 5;
				elsif(state = 5) then
					next_state <= 1;
				else
				end if;
			else
				if(state = 1) then
						next_state <= 2;
					elsif(state = 2) then
						next_state <= 3;
					elsif(state = 3) then
						next_state <= 4;
					elsif(state = 4) then
						next_state <= 1;
					end if;
			end if;

	end process;
	
end Behavioral;

