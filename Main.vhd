----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:35:31 11/17/2016 
-- Design Name: 
-- Module Name:    Main - Behavioral 
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

entity Main is
    Port ( SW_DIP : in  STD_LOGIC_VECTOR (15 downto 0);
           CLK1 : in  STD_LOGIC;
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
           CLK_FROM_KEY : in  STD_LOGIC;
           RESET : in  STD_LOGIC);
end Main;

architecture Behavioral of Main is

component CPU is
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
end component;

signal tA,tB: STD_LOGIC_VECTOR(2 downto 0);
signal tC: STD_LOGIC;

begin

	with SW_DIP(15 downto 13) select tA <=
		"000" when "000",
		"001" when "001",
		"010" when others;
	
	with SW_DIP(15 downto 13) select tB <=
		"000" when "000",
		"001" when "001",
		"010" when others;
		
	process(tA,tB,CLK_FROM_KEY)
	begin
	if(CLK_FROM_KEY'event and CLK_FROM_KEY='0')then
		if(tA=tB)then
			tC<='1';
		else
			tC<='0';
		end if;
	end if;
	end process;

	CPU_ENTITY: CPU port map ( 
		SW_DIP,
		RAM1DATA,
		RAM2DATA,
		RAM1ADDR,
		RAM2ADDR,
		RAM1_EN,
		RAM1_OE,
		RAM1_RW,
		RAM2_EN,
		RAM2_OE,
		RAM2_RW,
		FPGA_LED,
		DYP0,
		DYP1,
		DATA_READY,
		RDN,
		TBRE,
		TSRE,
		WRN,
		CLK1,
		CLK_FROM_KEY,
		RESET);

end Behavioral;

