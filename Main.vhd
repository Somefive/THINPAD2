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
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

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

signal CLK_CPU: std_logic;
shared variable count: integer := 0;
signal mode: std_logic_vector(1 downto 0):="00";
shared variable max: integer := 1000000;

begin
	
	process(RESET)
	begin
		if(RESET'event and RESET='1')then
			case SW_DIP(3 downto 0) is
				when "1101" => mode <= "01";
				when "1110" => mode <= "10";
				when "1111" => mode <= "11";
				when others => mode <= "00";
			end case;
		end if;
	end process;
	
	process(mode)
	begin
		if(mode="01")then
			max:=1;
		elsif(mode="11")then
			max:=200000;
		end if;
	end process;
	
	process(CLK1)
	begin
		if(mode="00")then
			CLK_CPU <= CLK_FROM_KEY;
		elsif(mode<="10")then
			CLK_CPU <= CLK1;
		elsif(CLK1'event and CLK1='1')then
			if(count>max)then
				count:=0;
				CLK_CPU <= not CLK_CPU;
			else
				count:=count+1;
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
		CLK_CPU,
		CLK_FROM_KEY,
		RESET);

end Behavioral;

