library	ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
entity VGA_Controller is
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
		CLK_in	: in  std_logic;			--100M时钟输入
		
		font_value : in std_logic_vector(7 downto 0);
		wrn : in std_logic
	);		
end entity VGA_Controller;

architecture behave of VGA_Controller is

--VGA
	signal CLK,CLK_2,CLK_4	: std_logic;
	signal rt,gt,bt	: std_logic_vector (2 downto 0);
	signal hst,vst	: std_logic;
	signal x		: std_logic_vector (9 downto 0);		--X坐标
	signal y		: std_logic_vector (8 downto 0);		--Y坐标
	
	shared variable dx : integer range 0 to 7;
	shared variable inty,tmp : integer range 0 to 500;
--输入数组
	type matrix_type is array(9 downto 0) of std_logic_vector(10 downto 0);
	signal matrix_input : matrix_type;
	signal romAddrBuffer : std_logic_vector(10 downto 0);
	signal font_addr : std_logic_vector(10 downto 0);
	signal count : integer :=0;
begin
--reset<=not reset_in;
	font_addr <= conv_std_logic_vector(conv_integer(font_value)*8,11);
	romAddrBuffer <= font_addr when wrn='0';
	process(wrn)
	begin
		if(wrn'event and wrn='1')then
			if(romAddrBuffer = "00000000000")then
				count <= 0;
			elsif(romAddrBuffer = "00001000000")then
				if(count > 0)then
					count <= count - 1;
				end if;
			else
				if(count < 10)then
					matrix_input(count) <= romAddrBuffer;
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;
CLK<=CLK_2;
 -----------------------------------------------------------------------
	process (CLK_in)
	begin
		if CLK_in'event and CLK_in = '1' then	--对100M输入信号二分频
			CLK_2 <= not CLK_2;
		end if;
	end process;
	
	process (CLK_2)
	begin
		if CLK_2'event and CLK_2 = '1' then
			CLK_4 <= not CLK_4;
		end if;
	end process;	

 -----------------------------------------------------------------------
	process (CLK, reset)	--行区间像素数（含消隐区）
	begin
		if reset = '0' then
			x <= (others => '0');
		elsif CLK'event and CLK = '1' then
			if x = 799 then
				x <= (others => '0');
			else
				x <= x + 1;
			end if;
		end if;
	end process;

  -----------------------------------------------------------------------
	 process (CLK, reset)	--场区间行数（含消隐区）
	 begin
	  	if reset = '0' then
	   		y <= (others => '0');
	  	elsif CLK'event and CLK = '1' then
	   		if x = 799 then
	    		if y = 524 then
	     			y <= (others => '0');
	    		else
	     			y <= y + 1;
	    		end if;
	   		end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process (CLK, reset)	--行同步信号产生（同步宽度96，前沿16）
	 begin
		  if reset = '0' then
		   hst <= '1';
		  elsif CLK'event and CLK = '1' then
		   	if x >= 656 and x < 752 then
		    	hst <= '0';
		   	else
		    	hst <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process (CLK, reset)	--场同步信号产生（同步宽度2，前沿10）
	 begin
	  	if reset = '0' then
	   		vst <= '1';
	  	elsif CLK'event and CLK = '1' then
	   		if y >= 490 and y< 492 then
	    		vst <= '0';
	   		else
	    		vst <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process (CLK, reset)	--行同步信号输出
	 begin
	  	if reset = '0' then
	   		hs <= '0';
	  	elsif CLK'event and CLK = '1' then
	   		hs <=  hst;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process (CLK, reset)	--场同步信号输出
	 begin
	  	if reset = '0' then
	   		vs <= '0';
	  	elsif CLK'event and CLK='1' then
	   		vs <=  vst;
	  	end if;
	 end process;

------------------------------------------------------------------------
--	process (CLK, reset) -- XY坐标定位控制
--	begin	  	
--		if reset = '1' then
--			rt		<=	(others => '0');
--			gt		<=	(others => '0');
--			bt		<=	(others => '0');
--			addr	<=	(others => '0');
--	  	elsif CLK'event and CLK='1' then
--			addr	<=	x&y;
--			rt		<=	R;
--			gt		<=	G;
--			bt		<=	B;
--	  	end if;
--	end process;
-----------------------------------------------------------------------	
-----------------------------------------------------------------------
-----------------------------------------------------------------------
	process(reset,clk,x,y) -- XY坐标定位控制
	begin  
		if reset='0' then
			        rt   <= "000";
					gt	<= "000";
					bt	<= "000";	
		elsif(clk'event and clk='1')then 
		--	if x>0 and x<213 then   -- X方向控制,分为3列，	
			--	rt <="000";				  	
			--	bt <="111";
			--elsif x>=213 and x<426 then
			--	rt <="111";
			--	bt <="000";
			--else
			--	rt <="111";
			--	bt <="111";
			--end if;
		    
			--if y<240 then				-- Y方向控制，分为2行
			 --   gt   <="111";
			--else
			 --   gt	<= "000";
			--end if;		
			if (x >= 39 and x <= 47) then
				if (y >= 64 and y <= 71) or (y >= 80 and y <= 87) or (y >= 96 and y <= 103) or (y >= 112 and y <= 119)
					or (y >= 128 and y <= 135) or (y >= 144 and y <= 151) or (y >= 160 and y <= 167) or (y >= 176 and y<= 183)
					then
					if x = 39 then
						inty := conv_integer(y);
						romAddr <= conv_std_logic_vector(82 * 8 + inty mod 8,11);--R
					else
						dx := 7 - (conv_integer(x) - 40);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif(y>=192 and y<=199)then
					if(count > 0)then
						if(x=39)then
							inty := conv_integer(y);
							romAddr <= matrix_input(0) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 49 and x <= 57) then
				if (y >= 64 and y <= 71) or (y >= 80 and y <= 87) or (y >= 96 and y <= 103) or (y >= 112 and y <= 119)
					or (y >= 128 and y <= 135) or (y >= 144 and y <= 151) or (y >= 160 and y <= 167) or (y >= 176 and y<= 183)
					then -- 0 ~ 7
					if (x = 49) then
						inty := conv_integer(y);
						romAddr <= conv_std_logic_vector(((inty - 64) / 16  + 48) * 8 + inty mod 8, 11);
					else
						dx := 7 - (conv_integer(x) - 50);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif(y>=192 and y<=199)then
					if(count > 1)then
						if(x=49)then
							inty := conv_integer(y);
							romAddr <= matrix_input(1) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 59 and x <= 67)then
				if(y>=192 and y<=199)then
					if(count > 2)then
						if(x=59)then
							inty := conv_integer(y);
							romAddr <= matrix_input(2) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				end if;
			elsif (x >= 69 and x <= 77) then
				if (y >= 64 and y <= 71) then -- r0 3
					if (x = 69) then 
						inty := conv_integer(y);
						tmp := conv_integer(r0(15 downto 12));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 70);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --r1 3
					if (x = 69) then 
						inty := conv_integer(y);
						tmp := conv_integer(r1(15 downto 12));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 70);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 96 and y<= 103) then --r2 3
					if (x = 69) then 
						inty := conv_integer(y);
						tmp := conv_integer(r2(15 downto 12));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 70);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 112 and y<= 119) then -- r3 3
					if (x = 69) then 
						inty := conv_integer(y);
						tmp := conv_integer(r3(15 downto 12));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 70);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 128 and y<= 135) then --r4 3
					if (x = 69) then 
						inty := conv_integer(y);
						tmp := conv_integer(r4(15 downto 12));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 70);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- r5 3
					if (x = 69) then 
						inty := conv_integer(y);
						tmp := conv_integer(r5(15 downto 12));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 70);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 160 and y <= 167) then -- r6 3
					if (x = 69) then 
						inty := conv_integer(y);
						tmp := conv_integer(r6(15 downto 12));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 70);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 176 and y <= 183) then -- r7 3
					if (x = 69) then 
						inty := conv_integer(y);
						tmp := conv_integer(r7(15 downto 12));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 70);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif(y>=192 and y<=199)then
					if(count > 3)then
						if(x=69)then
							inty := conv_integer(y);
							romAddr <= matrix_input(3) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 79 and x <= 87) then
				if (y >= 64 and y <= 71) then -- r0 2
					if (x = 79) then 
						inty := conv_integer(y);
						tmp := conv_integer(r0(11 downto 8));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 80);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --r1 2
					if (x = 79) then 
						inty := conv_integer(y);
						tmp := conv_integer(r1(11 downto 8));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 80);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 96 and y<= 103) then --r2 2
					if (x = 79) then 
						inty := conv_integer(y);
						tmp := conv_integer(r2(11 downto 8));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 80);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 112 and y<= 119) then -- r3 2
					if (x = 79) then 
						inty := conv_integer(y);
						tmp := conv_integer(r3(11 downto 8));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 80);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 128 and y<= 135) then --r4 2
					if (x = 79) then 
						inty := conv_integer(y);
						tmp := conv_integer(r4(11 downto 8));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 80);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- r5 2
					if (x = 79) then 
						inty := conv_integer(y);
						tmp := conv_integer(r5(11 downto 8));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 80);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 160 and y <= 167) then -- r6 2
					if (x = 79) then 
						inty := conv_integer(y);
						tmp := conv_integer(r6(11 downto 8));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 80);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 176 and y <= 183) then -- r7 2
					if (x = 79) then 
						inty := conv_integer(y);
						tmp := conv_integer(r7(11 downto 8));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 80);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif(y>=192 and y<=199)then
					if(count > 4)then
						if(x=79)then
							inty := conv_integer(y);
							romAddr <= matrix_input(4) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 89 and x <= 97) then
				if (y >= 64 and y <= 71) then -- r0 1
					if (x = 89) then 
						inty := conv_integer(y);
						tmp := conv_integer(r0(7 downto 4));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 90);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --r1 1
					if (x = 89) then 
						inty := conv_integer(y);
						tmp := conv_integer(r1(7 downto 4));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 90);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 96 and y<= 103) then --r2 1
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r2(7 downto 4));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 90);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 112 and y<= 119) then -- r3 1
					if (x = 89) then 
						inty := conv_integer(y);
						tmp := conv_integer(r3(7 downto 4));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 90);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 128 and y<= 135) then --r4 1
					if (x = 89) then 
						inty := conv_integer(y);
						tmp := conv_integer(r4(7 downto 4));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 90);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- r5 1
					if (x = 89) then 
						inty := conv_integer(y);
						tmp := conv_integer(r5(7 downto 4));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 90);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 160 and y <= 167) then -- r6 1
					if (x = 89) then 
						inty := conv_integer(y);
						tmp := conv_integer(r6(7 downto 4));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 90);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 176 and y <= 183) then -- r7 1
					if (x = 89) then 
						inty := conv_integer(y);
						tmp := conv_integer(r7(7 downto 4));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 90);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif(y>=192 and y<=199)then
					if(count > 5)then
						if(x=89)then
							inty := conv_integer(y);
							romAddr <= matrix_input(5) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 99 and x <= 107) then
				if (y >= 64 and y <= 71) then -- r0 0
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r0(3 downto 0));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 100);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then --r1 0
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r1(3 downto 0));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 100);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 96 and y<= 103) then --r2 0
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r2(3 downto 0));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 100);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 112 and y<= 119) then -- r3 0
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r3(3 downto 0));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 100);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 128 and y<= 135) then --r4 0
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r4(3 downto 0));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 100);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 144 and y <= 151) then -- r5 0
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r5(3 downto 0));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 100);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 160 and y <= 167) then -- r6 0
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r6(3 downto 0));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 100);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 176 and y <= 183) then -- r7 0
					if (x = 99) then 
						inty := conv_integer(y);
						tmp := conv_integer(r7(3 downto 0));
						if ( tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8,11);
						else 
							romAddr <= conv_std_logic_vector((tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 100);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif(y>=192 and y<=199)then
					if(count > 6)then
						if(x=99)then
							inty := conv_integer(y);
							romAddr <= matrix_input(6) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 109 and x <= 117) then
				if(y>=192 and y<=199)then
					if(count > 7)then
						if(x=109)then
							inty := conv_integer(y);
							romAddr <= matrix_input(7) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 119 and x <= 127) then
				if(y>=192 and y<=199)then
					if(count > 8)then
						if(x=119)then
							inty := conv_integer(y);
							romAddr <= matrix_input(8) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 129 and x <= 137) then
				if(y>=192 and y<=199)then
					if(count > 9)then
						if(x=129)then
							inty := conv_integer(y);
							romAddr <= matrix_input(9) + inty mod 8;
						else
							dx := 7 - (conv_integer(x) - 40);
							rt <= (others => romData(dx));
							gt <= (others => romData(dx));
							bt <= (others => romData(dx));
						end if;
					else
						rt <= (others => '0');
						gt <= (others => '0');
						bt <= (others => '0');
					end if;
				else
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 149 and x <= 157) then 
				if ( y >= 64 and y <= 71) then --P
					if (x = 149) then
						inty := conv_integer(y);
						romAddr <= conv_std_logic_vector( 80 * 8 + inty mod 8, 11);
					else
						dx := 7 - (conv_integer(x) - 150);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif ( y >= 80 and y <= 87) then -- C
					if (x = 149) then
						inty := conv_integer(y);
						romAddr <= conv_std_logic_vector( 67 * 8 + inty mod 8, 11);
					else
						dx := 7 - (conv_integer(x) - 150);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 159 and x <= 167) then 
				if ( y >= 64 and y <= 71) then --C
					if (x = 159) then
						inty := conv_integer(y);
						romAddr <= conv_std_logic_vector( 67 * 8 + inty mod 8, 11);
					else
						dx := 7 - (conv_integer(x) - 160);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then -- M
					if (x = 159) then
						inty := conv_integer(y);
						romAddr <= conv_std_logic_vector( 77 * 8 + inty mod 8, 11);
					else
						dx := 7 - (conv_integer(x) - 160);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 96 and y <= 103) then --T
					if (x = 159) then
						inty := conv_integer(y);
						romAddr <= conv_std_logic_vector( 84 * 8 + inty mod 8, 11);
					else
						dx := 7 - (conv_integer(x) - 160);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif ( x >= 179 and x <= 187) then 
				if ( y >= 64 and y <= 71) then --pc 3
					if (x = 179) then
						inty := conv_integer(y);
						tmp := conv_integer(pc(15 downto 12));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 180);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then -- cm 3
					if (x = 179) then
						inty := conv_integer(y);
						tmp := conv_integer(cm(15 downto 12));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 180);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 189 and x <= 197) then
				if ( y >= 64 and y <= 71) then --pc 2
					if (x = 189) then
						inty := conv_integer(y);
						tmp := conv_integer(pc(11 downto 8));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 190);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif (y >= 80 and y <= 87) then
					if (x = 189) then
						inty := conv_integer(y);
						tmp := conv_integer(cm(11 downto 8));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 190);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 199 and x <= 207) then
				if ( y >= 64 and y <= 71) then --pc 1
					if (x = 199) then
						inty := conv_integer(y);
						tmp := conv_integer(pc(7 downto 4));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 200);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif ( y >= 80 and y <= 87) then -- cm1
					if (x = 199) then
						inty := conv_integer(y);
						tmp := conv_integer(cm(7 downto 4));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 200);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif ( y >= 144 and y <= 151) then --RAControl 1
					if (x = 209) then
						inty := conv_integer(y);
						tmp := conv_integer(RAControl(4));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 210);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			elsif (x >= 209 and x<= 217) then
				if ( y >= 64 and y <= 71) then --pc 0
					if (x = 209) then
						inty := conv_integer(y);
						tmp := conv_integer(pc(3 downto 0));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 210);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif ( y >= 80 and y <= 87) then -- cm0
					if (x = 209) then
						inty := conv_integer(y);
						tmp := conv_integer(cm(3 downto 0));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 210);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif ( y >= 96 and y <= 103) then --T 0
					if (x = 209) then
						inty := conv_integer(y);
						tmp := conv_integer(tdata(3 downto 0));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 210);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif ( y >= 112 and y <= 119) then --PCControl
					if (x = 209) then
						inty := conv_integer(y);
						tmp := conv_integer(PCControl(2 downto 0));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 210);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif ( y >= 128 and y <= 135) then --RamControl
					if (x = 209) then
						inty := conv_integer(y);
						tmp := conv_integer(RamControl(2 downto 0));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 210);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				elsif ( y >= 144 and y <= 151) then --RAControl 0
					if (x = 209) then
						inty := conv_integer(y);
						tmp := conv_integer(RAControl(3 downto 0));
						if (tmp <= 9) then
							romAddr <= conv_std_logic_vector( (tmp + 48) * 8 + inty mod 8, 11);
						else 
							romAddr <= conv_std_logic_vector( (tmp - 10 + 65) * 8 + inty mod 8, 11);
						end if;
					else
						dx := 7 - (conv_integer(x) - 210);
						rt <= (others => romData(dx));
						gt <= (others => romData(dx));
						bt <= (others => romData(dx));
					end if;
				else 
					rt <= (others => '0');
					gt <= (others => '0');
					bt <= (others => '0');
				end if;
			else
				rt <= (others => '0');
				gt <= (others => '0');
				bt <= (others => '0');
			end if;
			
		end if;
end process;	
		
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
	process (hst, vst, rt, gt, bt)	--色彩输出
	begin
		if hst = '1' and vst = '1' then
			oRed	<= rt;
			oGreen	<= gt;
			oBlue	<= bt;
		else
			oRed	<= (others => '0');
			oGreen	<= (others => '0');
			oBlue	<= (others => '0');
		end if;
	end process;

end behave;