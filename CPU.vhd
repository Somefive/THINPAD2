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
			  CLK_50M : in STD_LOGIC;
           CLK : in  STD_LOGIC;
			  CLK_KEY : in STD_LOGIC;
           RESET : in  STD_LOGIC;
			  hs,vs : out std_logic;
			  redOut, greenOut, blueOut : out std_logic_vector(2 downto 0);
			  Flash_byte : OUT STD_LOGIC := '1';
			  Flash_vpen : OUT STD_LOGIC := '1';
			  Flash_ce : OUT STD_LOGIC := '0';
			  Flash_oe : OUT STD_LOGIC := '1';
			  Flash_we : OUT STD_LOGIC := '1';
			  Flash_rp : OUT STD_LOGIC := '1';      
			  Flash_addr : OUT STD_LOGIC_VECTOR(22 downto 0) := "00000000000000000000000";
			  Flash_data : INOUT STD_LOGIC_VECTOR(15 downto 0) := "ZZZZZZZZZZZZZZZZ";
			  PS2KB_CLOCK : IN STD_LOGIC;
			  PS2KB_DATA : IN STD_LOGIC);
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
			  Flash_byte : OUT STD_LOGIC := '1';
			  Flash_vpen : OUT STD_LOGIC := '1';
			  Flash_ce : OUT STD_LOGIC := '0';
			  Flash_oe : OUT STD_LOGIC := '1';
			  Flash_we : OUT STD_LOGIC := '1';
			  Flash_rp : OUT STD_LOGIC := '1';      
			  Flash_addr : OUT STD_LOGIC_VECTOR(22 downto 0) := "00000000000000000000000";
			  Flash_data : INOUT STD_LOGIC_VECTOR(15 downto 0) := "ZZZZZZZZZZZZZZZZ";
			  KB_RDN: out STD_LOGIC := '1';
			  KB_DATA_READY: in STD_LOGIC;
			  KB_DATA_VALUE: in STD_LOGIC_VECTOR(7 downto 0));
end component;

component PCBlock is
    Port ( RegX : in  STD_LOGIC_VECTOR (15 downto 0);
           T : in  STD_LOGIC;
           ImmLong : in  STD_LOGIC_VECTOR (10 downto 0);
           PCControl : in  STD_LOGIC_VECTOR (2 downto 0);
           PC : buffer  STD_LOGIC_VECTOR (15 downto 0);
			  CLK : in STD_LOGIC;
			  PCError: out STD_LOGIC);
end component;

component ControlBlock is
    Port ( Instruction : in  STD_LOGIC_VECTOR(15 downto 0);
           Finish : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           PCControl : out  STD_LOGIC_VECTOR(2 downto 0);
           RAControl : out  STD_LOGIC_VECTOR(4 downto 0);
           RamControl : out  STD_LOGIC_VECTOR(2 downto 0);
			  DYP : out STD_LOGIC_VECTOR(6 downto 0);
			  OutPeriod: out STD_LOGIC_VECTOR(3 downto 0);
			  PCError: in STD_LOGIC);
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
			  CLK : in STD_LOGIC;
			  Reg0_out : out STD_LOGIC_VECTOR (15 downto 0);
			  Reg1_out : out STD_LOGIC_VECTOR (15 downto 0);
			  Reg2_out : out STD_LOGIC_VECTOR (15 downto 0);
			  Reg3_out : out STD_LOGIC_VECTOR (15 downto 0);
			  Reg4_out : out STD_LOGIC_VECTOR (15 downto 0);
			  Reg5_out : out STD_LOGIC_VECTOR (15 downto 0);
			  Reg6_out : out STD_LOGIC_VECTOR (15 downto 0);
			  Reg7_out : out STD_LOGIC_VECTOR (15 downto 0);
			  RegSP_out : out STD_LOGIC_VECTOR (15 downto 0);
			  RegIH_out : out STD_LOGIC_VECTOR (15 downto 0);
			  RegT_out : out STD_LOGIC_VECTOR(3 downto 0));
end component;

component VGA_Controller is
	port (
	--VGA Side
		hs,vs	: out std_logic;		--行同步、场同步信号
		oRed	: out std_logic_vector (2 downto 0);
		oGreen	: out std_logic_vector (2 downto 0);
		oBlue	: out std_logic_vector (2 downto 0);
	--RAM side
--		R,G,B	: in  std_logic_vector (9 downto 0);
--		addr	: out std_logic_vector (18 downto 0);

	-- data
		r0: in std_logic_vector(15 downto 0);
		r1: in std_logic_vector(15 downto 0);
		r2: in std_logic_vector(15 downto 0);
		r3: in std_logic_vector(15 downto 0);
		r4: in std_logic_vector(15 downto 0);
		r5: in std_logic_vector(15 downto 0);
		r6: in std_logic_vector(15 downto 0);
		r7 : in std_logic_vector(15 downto 0);
		PCControl : in  STD_LOGIC_VECTOR(2 downto 0);
	   RAControl : in  STD_LOGIC_VECTOR(4 downto 0);
	   RamControl : in  STD_LOGIC_VECTOR(2 downto 0);
	-- font rom
		romAddr : out std_logic_vector(10 downto 0);
		romData : in std_logic_vector(7 downto 0);
	--
		pc : in std_logic_vector(15 downto 0);
		cm : in std_logic_vector(15 downto 0);
		tdata : in std_logic_vector(3 downto 0);
	--Control Signals
		reset	: in  std_logic;
		CLK_in	: in  std_logic			--100M时钟输入
	);		
end component;

component fontRom IS
	port (
	clka: in std_logic;
	addra: in std_logic_vector(10 downto 0);
	douta: out std_logic_vector(7 downto 0));
END component;

component KeyboardBlock is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC;
			  rdn : in STD_LOGIC;
           data_ready : out  STD_LOGIC;
           key_value : out  STD_LOGIC_VECTOR (7 downto 0));
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

signal Reg0 : STD_LOGIC_VECTOR (15 downto 0);
signal Reg1 : STD_LOGIC_VECTOR (15 downto 0);
signal Reg2 : STD_LOGIC_VECTOR (15 downto 0);
signal Reg3 : STD_LOGIC_VECTOR (15 downto 0);
signal Reg4 : STD_LOGIC_VECTOR (15 downto 0);
signal Reg5 : STD_LOGIC_VECTOR (15 downto 0);
signal Reg6 : STD_LOGIC_VECTOR (15 downto 0);
signal Reg7 : STD_LOGIC_VECTOR (15 downto 0);
signal RegSP : STD_LOGIC_VECTOR (15 downto 0);
signal RegIH : STD_LOGIC_VECTOR (15 downto 0);

signal RegT : STD_LOGIC_VECTOR(3 downto 0);

signal fontRomAddr : std_logic_vector(10 downto 0);
signal fontRomData : std_logic_vector(7 downto 0);

signal OutPeriod: STD_LOGIC_VECTOR(3 downto 0);

signal PCError: STD_LOGIC;

signal key_data_ready : STD_LOGIC;
signal key_value : std_logic_vector(7 downto 0);
signal key_rdn : std_logic := '0';
begin

	PCBlock_Entity: PCBlock port map (
		RegX,
		T,
		Ins(10 downto 0),
		PCControl,
		PC,
		CLK,
		PCError
	);
	
	ControlBlock_Entity: ControlBlock port map( 
		Ins,
		Finish,
		CLK,
		PCControl,
		RAControl,
		RamControl,
		DYP0,
		OutPeriod,
		PCError
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
		Flash_byte,
		Flash_vpen,
		Flash_ce,
		Flash_oe,
		Flash_we ,
		Flash_rp, 
		Flash_addr,
		Flash_data,
		key_rdn,
		key_data_ready,
		key_value
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
		CLK,
		Reg0,
		Reg1,
		Reg2,
		Reg3,
		Reg4,
		Reg5,
		Reg6,
		Reg7,
		RegSP,
		RegIH,
		RegT
	);
	
	VGA_Entity : VGA_Controller port map(
	--VGA Side
		hs,
		vs,
		redOut,	
		greenOut,
		blueOut,
	--RAM side

	-- data
		Reg0,
		Reg1,
		Reg2,
		Reg3,
		Reg4,
		Reg5,
		Reg6,
		Reg7,
		PCControl,
	   RAControl,
	   RamControl,
	-- font rom
		fontRomAddr,
		fontRomData,
	--
		PC,
		Ins,
		RegT,
	--Control Signals
		RESET,
		CLK_50M
	);		
	
	FontRom_Entity : fontRom port map(
		CLK,
		fontRomAddr,
		fontRomData
	);
	
	PS2Keyboard_Entity : KeyboardBlock port map(
		CLK_50M,
		RESET,
		PS2KB_CLOCK,
		PS2KB_DATA,
		key_rdn,
		key_data_ready,
		key_value
	);
	
	with SW_DIP(15 downto 0) select FPGA_LED <=
		"00000000"&key_value when "0000000000000001",
		"000000000000000"&key_data_ready when "0000000000000010",
		"000000000000000"&key_rdn when "0000000000000100",
		"1010101010101010" when others;
--		PC     when "0000000000000001",
--		ALU    when "0000000000000010",
--		RegX   when "0000000000000100",
--		RegY   when "0000000000001000",
--		"000000000000000"&T when "0000000000010000",
--		Output when "0000000000100000",
--		Ins    when "0000000001000000",
--		"00000000000"&RAControl      when "0000000010000000",
--		"0000000000000"&RamControl   when "0000000100000000",
--		"0000000000000"&PCControl    when "0000001000000000",
--		"000000000000000"&Finish     when "0000010000000000",
--		"000000000000000"&DATA_READY when "0000100000000000",
--		"1010101010101010" when others;
--		RamControl&Finish&ALU(11 downto 0) when others;
--		RAControl&RamControl&PCControl&ALU(4 downto 0) when others;
--		PC when "0001",
--		Ins when "0010",
--		ALU when "0011",
--		Output when others;
	
	
end Behavioral;

