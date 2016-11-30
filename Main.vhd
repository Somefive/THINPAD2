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
			  PS2KB_CLOCK : in STD_LOGIC;
			  PS2KB_DATA : in STD_LOGIC);
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

component DCM5 is
   port ( CLKIN_IN   : in    std_logic; 
          RST_IN     : in    std_logic; 
          CLKFX_OUT  : out   std_logic; 
          CLK0_OUT   : out   std_logic; 
          CLK2X_OUT  : out   std_logic; 
          LOCKED_OUT : out   std_logic);
end component;

signal CLK_CPU: std_logic;
shared variable count: integer := 0;
signal mode: std_logic_vector(1 downto 0):="00";
shared variable max: integer := 1000000;

signal CLK0:std_logic;
signal CLKFX:std_logic;
signal CLK2X:std_logic;
signal LOCKED_OUT:std_logic;
signal GND0:std_logic:='0';

begin

	DCM_ENTITY: DCM5 port map(CLK1,GND0,CLKFX,CLK0,CLK2X,LOCKED_OUT);
	
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
	
	process(CLK1)
	begin
		if(mode="00")then
			CLK_CPU <= CLK_FROM_KEY;
		elsif(mode<="10")then
			CLK_CPU <= CLK1;
		elsif(mode<="11")then
			CLK_CPU <= CLKFX;
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
		CLK1,
		CLK_CPU,
		CLK_FROM_KEY,
		RESET,
		hs,
		vs,
		redOut,
		greenOut,
		blueOut,
		Flash_byte,
		Flash_vpen,
		Flash_ce,
		Flash_oe,
		Flash_we ,
		Flash_rp ,
		Flash_addr,
		Flash_data,
		PS2KB_CLOCK,
		PS2KB_DATA);

end Behavioral;

