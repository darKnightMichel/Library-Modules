library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.all;
	use ieee.numeric_std.all;


entity j1 is
port (
	sys_clk_i	: in  std_logic;
	sys_rst_i	: in  std_logic;
	io_data_i	: in  std_logic_vector(15 downto 0);
	io_rd_o		: out std_logic;
	io_wr_o		: out std_logic;
	io_addr_o	: out std_logic_vector(15 downto 0);
	io_data_o	: out std_logic_vector(15 downto 0)
	);
end entity j1;

architecture rtl of j1 is
	signal insn		: std_logic_vector(15 downto 0);
	signal immediate	: std_logic_vector(15 downto 0);
	
	signal ramrd		: std_logic_vector(15 downto 0);
	
	signal dsp		: std_logic_vector(4 downto 0);		-- Data stack pointer
	signal dsp_sig		: std_logic_vector(4 downto 0);
	signal st0		: std_logic_vector(15 downto 0);	-- Return stack pointer
	signal st0_sig		: std_logic_vector(15 downto 0);
	signal dstkW_sig	: std_logic;				-- D stack write
	
	signal pc		: std_logic_vector(12 downto 0);
	signal pc_sig		: std_logic_vector(12 downto 0);
	signal rsp		: std_logic_vector(4 downto 0);
	signal rsp_sig		: std_logic_vector(4 downto 0);
	signal rstkW_sig	: std_logic;				-- R stack write
	signal rstkD_sig	: std_logic_vector(15 downto 0);
	signal ramWE_sig 	: std_logic;				-- RAM write enable
	
	signal pc_plus_1	: std_logic_vector(15 downto 0);
	
	-- The D and R stacks
	signal d00,d01,d02,d03	: std_logic_vector(15 downto 0);
	signal d04,d05,d06,d07	: std_logic_vector(15 downto 0);
	signal d08,d09,d0a,d0b	: std_logic_vector(15 downto 0);
	signal d0c,d0d,d0e,d0f	: std_logic_vector(15 downto 0);
	signal d10,d11,d12,d13	: std_logic_vector(15 downto 0);
	signal d14,d15,d16,d17	: std_logic_vector(15 downto 0);
	signal d18,d19,d1a,d1b	: std_logic_vector(15 downto 0);
	signal d1c,d1d,d1e,d1f	: std_logic_vector(15 downto 0);
	
	signal r00,r01,r02,r03	: std_logic_vector(15 downto 0);
	signal r04,r05,r06,r07	: std_logic_vector(15 downto 0);
	signal r08,r09,r0a,r0b	: std_logic_vector(15 downto 0);
	signal r0c,r0d,r0e,r0f	: std_logic_vector(15 downto 0);
	signal r10,r11,r12,r13	: std_logic_vector(15 downto 0);
	signal r14,r15,r16,r17	: std_logic_vector(15 downto 0);
	signal r18,r19,r1a,r1b	: std_logic_vector(15 downto 0);
	signal r1c,r1d,r1e,r1f	: std_logic_vector(15 downto 0);
	
	signal st1		: std_logic_vector(15 downto 0);
	signal rst0		: std_logic_vector(15 downto 0);
	signal st0sel		: std_logic_vector(3 downto 0);
	signal is_alu		: std_logic;
	signal is_lit		: std_logic;
	
	signal dd		: std_logic_vector(1 downto 0);		-- D stack delta
	signal rd		: std_logic_vector(1 downto 0);		-- R stack delta

begin

	ram: entity work.j1ram
	port map (
		address_a	=> pc_sig,
		address_b	=> st0_sig(12 downto 0),
		clock		=> sys_clk_i,
		data_a	 	=> (others => '0'),
		data_b	 	=> st1,
		wren_a	 	=> '0',
		wren_b	 	=> ramWE_sig,
		q_a	 	=> insn,
		q_b	 	=> ramrd);

	immediate <= '0' & insn(14 downto 0);
	pc_plus_1 <= ("000" & pc) + 1;
	
	process (sys_clk_i)
	begin
		if sys_clk_i'event and sys_clk_i = '1' then
			if dstkW_sig = '1' then
				case dsp_sig is
					when "00000" => d00 <= st0;
					when "00001" => d01 <= st0;
					when "00010" => d02 <= st0;
					when "00011" => d03 <= st0;
					when "00100" => d04 <= st0;
					when "00101" => d05 <= st0;
					when "00110" => d06 <= st0;
					when "00111" => d07 <= st0;
					when "01000" => d08 <= st0;
					when "01001" => d09 <= st0;
					when "01010" => d0a <= st0;
					when "01011" => d0b <= st0;
					when "01100" => d0c <= st0;
					when "01101" => d0d <= st0;
					when "01110" => d0e <= st0;
					when "01111" => d0f <= st0;
					when "10000" => d10 <= st0;
					when "10001" => d11 <= st0;
					when "10010" => d12 <= st0;
					when "10011" => d13 <= st0;
					when "10100" => d14 <= st0;
					when "10101" => d15 <= st0;
					when "10110" => d16 <= st0;
					when "10111" => d17 <= st0;
					when "11000" => d18 <= st0;
					when "11001" => d19 <= st0;
					when "11010" => d1a <= st0;
					when "11011" => d1b <= st0;
					when "11100" => d1c <= st0;
					when "11101" => d1d <= st0;
					when "11110" => d1e <= st0;
					when "11111" => d1f <= st0;
					when others => null;
				end case;
			end if;
		end if;
		case dsp is
			when "00000" => st1 <= d00;
			when "00001" => st1 <= d01;
			when "00010" => st1 <= d02;
			when "00011" => st1 <= d03;
			when "00100" => st1 <= d04;
			when "00101" => st1 <= d05;
			when "00110" => st1 <= d06;
			when "00111" => st1 <= d07;
			when "01000" => st1 <= d08;
			when "01001" => st1 <= d09;
			when "01010" => st1 <= d0a;
			when "01011" => st1 <= d0b;
			when "01100" => st1 <= d0c;
			when "01101" => st1 <= d0d;
			when "01110" => st1 <= d0e;
			when "01111" => st1 <= d0f;
			when "10000" => st1 <= d10;
			when "10001" => st1 <= d11;
			when "10010" => st1 <= d12;
			when "10011" => st1 <= d13;
			when "10100" => st1 <= d14;
			when "10101" => st1 <= d15;
			when "10110" => st1 <= d16;
			when "10111" => st1 <= d17;
			when "11000" => st1 <= d18;
			when "11001" => st1 <= d19;
			when "11010" => st1 <= d1a;
			when "11011" => st1 <= d1b;
			when "11100" => st1 <= d1c;
			when "11101" => st1 <= d1d;
			when "11110" => st1 <= d1e;
			when "11111" => st1 <= d1f;
			when others => null;
		end case;
	end process;

	process (sys_clk_i)
	begin
		if sys_clk_i'event and sys_clk_i = '1' then
			if rstkW_sig = '1' then
				case rsp_sig is
					when "00000" => r00 <= rstkD_sig;
					when "00001" => r01 <= rstkD_sig;
					when "00010" => r02 <= rstkD_sig;
					when "00011" => r03 <= rstkD_sig;
					when "00100" => r04 <= rstkD_sig;
					when "00101" => r05 <= rstkD_sig;
					when "00110" => r06 <= rstkD_sig;
					when "00111" => r07 <= rstkD_sig;
					when "01000" => r08 <= rstkD_sig;
					when "01001" => r09 <= rstkD_sig;
					when "01010" => r0a <= rstkD_sig;
					when "01011" => r0b <= rstkD_sig;
					when "01100" => r0c <= rstkD_sig;
					when "01101" => r0d <= rstkD_sig;
					when "01110" => r0e <= rstkD_sig;
					when "01111" => r0f <= rstkD_sig;
					when "10000" => r10 <= rstkD_sig;
					when "10001" => r11 <= rstkD_sig;
					when "10010" => r12 <= rstkD_sig;
					when "10011" => r13 <= rstkD_sig;
					when "10100" => r14 <= rstkD_sig;
					when "10101" => r15 <= rstkD_sig;
					when "10110" => r16 <= rstkD_sig;
					when "10111" => r17 <= rstkD_sig;
					when "11000" => r18 <= rstkD_sig;
					when "11001" => r19 <= rstkD_sig;
					when "11010" => r1a <= rstkD_sig;
					when "11011" => r1b <= rstkD_sig;
					when "11100" => r1c <= rstkD_sig;
					when "11101" => r1d <= rstkD_sig;
					when "11110" => r1e <= rstkD_sig;
					when "11111" => r1f <= rstkD_sig;
					when others => null;
				end case;
			end if;
		end if;
		case rsp is
			when "00000" => rst0 <= r00;
			when "00001" => rst0 <= r01;
			when "00010" => rst0 <= r02;
			when "00011" => rst0 <= r03;
			when "00100" => rst0 <= r04;
			when "00101" => rst0 <= r05;
			when "00110" => rst0 <= r06;
			when "00111" => rst0 <= r07;
			when "01000" => rst0 <= r08;
			when "01001" => rst0 <= r09;
			when "01010" => rst0 <= r0a;
			when "01011" => rst0 <= r0b;
			when "01100" => rst0 <= r0c;
			when "01101" => rst0 <= r0d;
			when "01110" => rst0 <= r0e;
			when "01111" => rst0 <= r0f;
			when "10000" => rst0 <= r10;
			when "10001" => rst0 <= r11;
			when "10010" => rst0 <= r12;
			when "10011" => rst0 <= r13;
			when "10100" => rst0 <= r14;
			when "10101" => rst0 <= r15;
			when "10110" => rst0 <= r16;
			when "10111" => rst0 <= r17;
			when "11000" => rst0 <= r18;
			when "11001" => rst0 <= r19;
			when "11010" => rst0 <= r1a;
			when "11011" => rst0 <= r1b;
			when "11100" => rst0 <= r1c;
			when "11101" => rst0 <= r1d;
			when "11110" => rst0 <= r1e;
			when "11111" => rst0 <= r1f;
			when others => null;
		end case;
	end process;
	
	-- st0sel is the ALU operation.  For branch and call the operation
	-- is T, for 0branch it is N.  For ALU ops it is loaded from the instruction
	-- field.
	process (insn)
	begin
		case insn(14 downto 13) is
			when "00" => st0sel <= "0000";			-- ubranch
			when "10" => st0sel <= "0000";			-- call
			when "01" => st0sel <= "0001";			-- 0branch
			when "11" => st0sel <= insn(11 downto 8);	-- ALU
			when others => st0sel <= "XXXX";
		end case;
	end process;

	-- Compute the new value of T.
	process (insn, immediate, st0sel, st0, st1, rst0, io_data_i, ramrd, rsp, dsp)
	begin
		if insn(15) = '1' then
			st0_sig <= immediate;
		else
			case st0sel is
				when "0000" => st0_sig <= st0;					-- T
				when "0001" => st0_sig <= st1;					-- N
				when "0010" => st0_sig <= st0 + st1;				-- T + N
				when "0011" => st0_sig <= st0 and st1;				-- T and N
				when "0100" => st0_sig <= st0 or st1;				-- T or N
				when "0101" => st0_sig <= st0 xor st1;				-- T xor N
				when "0110" => st0_sig <= not st0;				-- not T
				when "0111" =>
					if st1 = st0 then					-- T = N ?
						st0_sig <= (others => '1');
					else
						st0_sig <= (others => '0');
					end if;
				when "1000" =>
					if signed(st1) < signed(st0) then			-- T < N ?
						st0_sig <= (others => '1');
					else
						st0_sig <= (others => '0');
					end if;
				when "1001" =>
					case st0(3 downto 0) is					-- N rshift T
						when "0000" => st0_sig <= st1(15 downto 0);
						when "0001" => st0_sig <= st1( 0)          & st1(15 downto  1);
						when "0010" => st0_sig <= st1( 1 downto 0) & st1(15 downto  2);
						when "0011" => st0_sig <= st1( 2 downto 0) & st1(15 downto  3);
						when "0100" => st0_sig <= st1( 3 downto 0) & st1(15 downto  4);
						when "0101" => st0_sig <= st1( 4 downto 0) & st1(15 downto  5);
						when "0110" => st0_sig <= st1( 5 downto 0) & st1(15 downto  6);
						when "0111" => st0_sig <= st1( 6 downto 0) & st1(15 downto  7);
						when "1000" => st0_sig <= st1( 7 downto 0) & st1(15 downto  8);
						when "1001" => st0_sig <= st1( 8 downto 0) & st1(15 downto  9);
						when "1010" => st0_sig <= st1( 9 downto 0) & st1(15 downto 10);
						when "1011" => st0_sig <= st1(10 downto 0) & st1(15 downto 11);
						when "1100" => st0_sig <= st1(11 downto 0) & st1(15 downto 12);
						when "1101" => st0_sig <= st1(12 downto 0) & st1(15 downto 13);
						when "1110" => st0_sig <= st1(13 downto 0) & st1(15 downto 14);
						when "1111" => st0_sig <= st1(14 downto 0) & st1(15);
						when others => null;
					end case;
				when "1010" => st0_sig <= st0 - 1;				-- T - 1
				when "1011" => st0_sig <= rst0;					-- R
				when "1100" =>
					if st0(15 downto 14) /= "00" then			-- [T]
						st0_sig <= io_data_i;
					else
						st0_sig <= ramrd;
					end if;
				when "1101" =>
					case st0(3 downto 0) is					-- N lshift T
						when "0000" => st0_sig <= st1(15 downto 0);
						when "0001" => st0_sig <= st1(14 downto 0) & st1(15);
						when "0010" => st0_sig <= st1(13 downto 0) & st1(15 downto 14);
						when "0011" => st0_sig <= st1(12 downto 0) & st1(15 downto 13);
						when "0100" => st0_sig <= st1(11 downto 0) & st1(15 downto 12);
						when "0101" => st0_sig <= st1(10 downto 0) & st1(15 downto 11);
						when "0110" => st0_sig <= st1( 9 downto 0) & st1(15 downto 10);
						when "0111" => st0_sig <= st1( 8 downto 0) & st1(15 downto  9);
						when "1000" => st0_sig <= st1( 7 downto 0) & st1(15 downto  8);
						when "1001" => st0_sig <= st1( 6 downto 0) & st1(15 downto  7);
						when "1010" => st0_sig <= st1( 5 downto 0) & st1(15 downto  6);
						when "1011" => st0_sig <= st1( 4 downto 0) & st1(15 downto  5);
						when "1100" => st0_sig <= st1( 3 downto 0) & st1(15 downto  4);
						when "1101" => st0_sig <= st1( 2 downto 0) & st1(15 downto  3);
						when "1110" => st0_sig <= st1( 1 downto 0) & st1(15 downto  2);
						when "1111" => st0_sig <= st1( 0)          & st1(15 downto  1);
						when others => null;
					end case;
				when "1110" => st0_sig <= ("000" & (rsp & "000" & dsp));	-- depth
				when "1111" =>
					if st1 < st0 then					-- (T < N) ?
						st0_sig <= (others => '1');
					else
						st0_sig <= (others => '0');
					end if;
				when others => st0_sig <= (others => 'X');
			end case;
		end if;
	end process;
	
	is_alu	  <= not(insn(15)) and insn(14) and insn(13);
	is_lit	  <= insn(15);
	
	io_rd_o	  <= is_alu and (insn(11) and insn(10) and not(insn(9)) and not(insn(8)));
	io_wr_o	  <= is_alu and insn(5) and (st0_sig(15) or st0_sig(15));
	io_addr_o <= st0;
	io_data_o <= st1;
	
	ramWE_sig <= is_alu and insn(5) and not(st0_sig(15) or st0_sig(15));
	dstkW_sig <= is_lit or (is_alu and insn(7));
	
	dd        <= insn(1 downto 0);				-- D stack delta
	rd        <= insn(3 downto 2);				-- R stack delta
	
	process (is_lit, dsp, rsp, pc_sig, is_alu, dd, rd, insn, st0, pc_plus_1, pc_sig)
	begin
		if is_lit = '1' then				-- literal
			dsp_sig   <= dsp + "00001";
			rsp_sig   <= rsp;
			rstkW_sig <= '0';
			rstkD_sig <= ("000" & pc_sig);
		elsif is_alu = '1' then
			dsp_sig   <= dsp + (dd(1) & dd(1) & dd(1) & dd);
			rsp_sig   <= rsp + (rd(1) & rd(1) & rd(1) & rd);
			rstkW_sig <= insn(6);
			rstkD_sig <= st0;			-- jump/call
		else
			-- predicated jump is like DROP
			if insn(15 downto 13) = "001" then
				dsp_sig <= dsp - "00001";
			else
				dsp_sig <= dsp;
			end if;
			if insn(15 downto 13) = "010" then	-- call
				rsp_sig   <= rsp + "00001";
				rstkW_sig <= '1';
				rstkD_sig <= (pc_plus_1(14 downto 0) & '0');
			else
				rsp_sig   <= rsp;
				rstkW_sig <= '0';
				rstkD_sig <= ("000" & pc_sig);
			end if;
		end if;
	end process;
	
	process (sys_rst_i, pc, insn, st0, is_alu, rst0, pc_plus_1)
	begin
		if sys_rst_i = '1' then
			pc_sig <= pc;
		elsif (insn(15 downto 13) = "000") or ((insn(15 downto 13) = "001") and (st0 = 0)) or (insn(15 downto 13) = "010") then
			pc_sig <= insn(12 downto 0);
		elsif (is_alu and insn(12)) = '1' then
			pc_sig <= rst0(13 downto 1);
		else
			pc_sig <= pc_plus_1(12 downto 0);
		end if;
	end process;
	
	process (sys_clk_i)
	begin
		if sys_clk_i'event and sys_clk_i = '1' then
			if sys_rst_i = '1' then
				pc  <= (others => '0');
				dsp <= (others => '0');
				st0 <= (others => '0');
				rsp <= (others => '0');
			else
				dsp <= dsp_sig;
				pc  <= pc_sig;
				st0 <= st0_sig;
				rsp <= rsp_sig;
			end if;
		end if;
	end process;
	
end architecture rtl; -- j1