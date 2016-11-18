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

signal RegX: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal RegY: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal ALU: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal PC: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal RamControl: STD_LOGIC_VECTOR(2 downto 0):="000";
signal Finish: STD_LOGIC;
signal Ins: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";
signal Output: STD_LOGIC_VECTOR(15 downto 0):="0000000000000000";

signal state: integer range 0 to 15:=0;

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
		DYP0,
		CLK_KEY
	);

	
	
end Behavioral;

