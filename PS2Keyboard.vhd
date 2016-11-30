----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:19:39 11/30/2016 
-- Design Name: 
-- Module Name:    ps2keyboard - Behavioral 
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

entity PS2Keyboard is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           ps2clk : in  STD_LOGIC;
           ps2data : in  STD_LOGIC;
           keyCode : out  STD_LOGIC_VECTOR (7 downto 0));
end PS2Keyboard;

architecture Behavioral of PS2Keyboard is
type stateType is (
	start,
	dataInput,
	odd,
	finish
);
signal state : stateType;							--状态

signal clk1, clk2, kclk, kdata : std_logic;  --毛刺处理内部信号
signal check : std_logic;							--校验位
signal dataBuffer : std_logic_vector(7 downto 0);
signal pos : integer range 0 to 7 := 0;
begin
	----------------------------------滤波------------------------------------------
	clk1 <= ps2clk when rising_edge(clk);
	clk2 <= clk1 when rising_edge(clk);
	kclk <= (not clk1) and clk2;
	kdata <= ps2data when rising_edge(clk);
	--------------------------------------------------------------------------------
	
	check <= '1' xor dataBuffer(0) xor dataBuffer(1) xor dataBuffer(2) xor dataBuffer(3) xor dataBuffer(4) xor dataBuffer(5) xor dataBuffer(6) xor dataBuffer(7);  --校验位计算
	
	process(clk)
	begin
		if(rst='0')then
			state <= start;
			keyCode <= (others => '0');
			pos <= 0;
		elsif(clk'event and clk='1')then
			if(kclk='1')then
				case state is
					when start =>				--起始状态
						pos <= 0;
						if(kdata='0')then
							state <= dataInput;
						else
							state <= start;
						end if;
					when dataInput => 		--数据状态
						dataBuffer(pos) <= kdata;
						if(pos = 7)then
							state <= odd;
						else
							state <= dataInput;
						end if;
						pos <= pos + 1;
					when odd => 				--校验状态
						if(check=kdata)then
							state <= finish;
						else
							state <= start;
						end if;
					when finish => 			-- 结束状态
						if(kdata='1')then
							keyCode <= dataBuffer;
						else
							keyCode <= (others => '0');
						end if;
						state <= start;
					when others => 
						state <= start;
				end case;
			end if;
		end if;
	end process;
end Behavioral;

