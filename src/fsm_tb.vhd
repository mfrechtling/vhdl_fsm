library ieee;
use ieee.std_logic_1164.all;

entity fsm_tb is
end entity;

architecture testbench of fsm_tb is

	component fsm is
		port(
			-- GLOBAL SIGNALS:
			clk				: in std_logic;
			reset			: in std_logic;
			-- COMMAND INTERFACE:
			data_in_vld		: in std_logic;
			data_in 		: in std_logic_vector(7 downto 0);
			data_out_vld	: out std_logic;
			data_out 		: out std_logic_vector(7 downto 0);
			-- REGISTER ACCESS INTERFACE:
			rd_ack			: in std_logic;
			rd_data			: in std_logic_vector(31 downto 0);
			wr_en			: out std_logic;
			rd_en			: out std_logic;
			addr			: out std_logic_vector(15 downto 0);
			wr_data			: out std_logic_vector(31 downto 0));
	end component;

	component mem_bank is
		port(clk		: in std_logic;
			reset		: in std_logic;
			wr_en		: in std_logic;
			rd_en		: in std_logic;
			rd_ack		: out std_logic;
			addr		: in std_logic_vector(15 downto 0);
			wr_data		: in std_logic_vector(31 downto 0);
			rd_data		: out std_logic_vector(31 downto 0));
	end component;

	signal tb_clk			: std_logic := '0';
	signal tb_reset			: std_logic := '0';
	signal tb_data_in_vld	: std_logic := '0';
	signal tb_data_in		: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_data_out_vld	: std_logic := '0';
	signal tb_data_out		: std_logic_vector(7 downto 0) := (others => '0');
	signal tb_rd_ack		: std_logic := '0';
	signal tb_rd_data		: std_logic_vector(31 downto 0) := (others => '0');
	signal tb_wr_en			: std_logic := '0';
	signal tb_rd_en			: std_logic := '0';
	signal tb_addr			: std_logic_vector(15 downto 0) := (others => '0');
	signal tb_wr_data		: std_logic_vector(31 downto 0) := (others => '0');

begin

	tb_clk <= not tb_clk after 10 ns;

	fsm0: fsm port map(clk => tb_clk,
		reset => tb_reset,
		data_in_vld => tb_data_in_vld,
		data_in => tb_data_in,
		data_out_vld => tb_data_out_vld,
		data_out => tb_data_out,
		rd_ack => tb_rd_ack,
		rd_data => tb_rd_data,
		wr_en => tb_wr_en,
		rd_en => tb_rd_en,
		addr => tb_addr,
		wr_data => tb_wr_data);

	mem0: mem_bank port map(clk => tb_clk,
		reset => tb_reset,
		wr_en => tb_wr_en,
		rd_en => tb_rd_en,
		rd_ack => tb_rd_ack,
		addr => tb_addr,
		wr_data => tb_wr_data,
		rd_data => tb_rd_data);

	process
		type pattern_type is record
			-- GLOBAL SIGNALS:
			reset			: std_logic;
			-- COMMAND INTERFACE:
			data_in_vld		: std_logic;
			data_in 		: std_logic_vector(7 downto 0);
			data_out_vld	: std_logic;
			data_out 		: std_logic_vector(7 downto 0);
		end record;
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns	: pattern_array :=
			(('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP

			-- TEST 1:
			('0', '1', x"e7", '0', x"00"),		-- SPECIAL
			('0', '1', x"13", '0', x"00"),		-- CMD READ
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"03", '0', x"00"),		-- ADDR
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '1', x"e7"),		-- SPECIAL
			('0', '0', x"00", '1', x"03"),		-- CMD RD RSP
			('0', '0', x"00", '1', x"10"),		-- DATA
			('0', '0', x"00", '1', x"20"),		-- DATA
			('0', '0', x"00", '1', x"30"),		-- DATA
			('0', '0', x"00", '1', x"40"),		-- DATA
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP

			-- TEST 2:
			('0', '1', x"e7", '0', x"00"),		-- SPECIAL
			('0', '1', x"13", '0', x"00"),		-- CMD READ
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"e7", '0', x"00"),		-- ADDR
			('0', '1', x"e7", '0', x"00"),		-- ADDR
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '1', x"e7"),		-- SPECIAL
			('0', '0', x"00", '1', x"03"),		-- CMD RD RSP
			('0', '0', x"00", '1', x"de"),		-- DATA
			('0', '0', x"00", '1', x"ad"),		-- DATA
			('0', '0', x"00", '1', x"be"),		-- DATA
			('0', '0', x"00", '1', x"ef"),		-- DATA
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP

			-- TEST 3:
			('0', '1', x"e7", '0', x"00"),		-- SPECIAL
			('0', '1', x"23", '0', x"00"),		-- CMD WRITE
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"02", '0', x"00"),		-- ADDR
			('0', '1', x"aa", '0', x"00"),		-- DATA
			('0', '1', x"e7", '0', x"00"),		-- DATA
			('0', '1', x"e7", '0', x"00"),		-- DATA
			('0', '1', x"55", '0', x"00"),		-- DATA
			('0', '1', x"aa", '0', x"00"),		-- DATA
			('0', '1', x"e7", '0', x"00"),		-- SPECIAL
			('0', '1', x"13", '0', x"00"),		-- CMD READ
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"02", '0', x"00"),		-- ADDR
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '1', x"e7"),		-- SPECIAL
			('0', '0', x"00", '1', x"03"),		-- CMD RD RSP
			('0', '0', x"00", '1', x"aa"),		-- DATA
			('0', '0', x"00", '1', x"e7"),		-- DATA
			('0', '0', x"00", '1', x"e7"),		-- DATA
			('0', '0', x"00", '1', x"55"),		-- DATA
			('0', '0', x"00", '1', x"aa"),		-- DATA
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP

			-- TEST 4:
			('0', '1', x"e7", '0', x"00"),		-- SPECIAL
			('0', '1', x"23", '0', x"00"),		-- CMD WRITE
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"01", '0', x"00"),		-- ADDR
			('0', '1', x"aa", '0', x"00"),		-- DATA
			('0', '1', x"e7", '0', x"00"),		-- SPECIAL
			('0', '1', x"55", '0', x"00"),		-- CMD BREAK
			('0', '1', x"e7", '0', x"00"),		-- SPECIAL
			('0', '1', x"13", '0', x"00"),		-- CMD READ
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"00", '0', x"00"),		-- ADDR
			('0', '1', x"01", '0', x"00"),		-- ADDR
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '1', x"e7"),		-- SPECIAL
			('0', '0', x"00", '1', x"03"),		-- CMD RD RSP
			('0', '0', x"00", '1', x"89"),		-- DATA
			('0', '0', x"00", '1', x"ab"),		-- DATA
			('0', '0', x"00", '1', x"cd"),		-- DATA
			('0', '0', x"00", '1', x"e7"),		-- DATA
			('0', '0', x"00", '1', x"e7"),		-- DATA
			('0', '0', x"00", '0', x"00"),		-- NOOP
			('0', '0', x"00", '0', x"00"));		-- NOOP
	begin
		assert false report "Start of test." severity note;
			for i in patterns'range loop
				wait until rising_edge(tb_clk);
				tb_reset <= patterns(i).reset;
				tb_data_in_vld <= patterns(i).data_in_vld;
				tb_data_in <= patterns(i).data_in;
				wait for 1 ns;
				assert tb_data_out_vld = patterns(i).data_out_vld
					report "Bad data_out_vld value." severity error;
				assert tb_data_out = patterns(i).data_out
					report "Bad data_out value." severity error;
			end loop;
		assert false report "End of test." severity note;
		wait;
	end process;

end architecture;