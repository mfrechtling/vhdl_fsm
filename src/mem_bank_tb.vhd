library ieee;
use ieee.std_logic_1164.all;

entity mem_bank_tb is
end entity;

architecture test_bench of mem_bank_tb is
	component mem_bank is
		port(clk		:	in std_logic;
			reset		:	in std_logic;
			wr_en		:	in std_logic;
			rd_en		:	in std_logic;
			rd_ack		:	out std_logic;
			addr		:	in std_logic_vector(15 downto 0);
			wr_data		:	in std_logic_vector(31 downto 0);
			rd_data		:	out std_logic_vector(31 downto 0));
	end component;

	signal tb_clk		:	std_logic := '0';
	signal tb_reset		:	std_logic := '0';		
	signal tb_wr_en		:	std_logic := '0';
	signal tb_rd_en		:	std_logic := '0';
	signal tb_rd_ack	:	std_logic := '0';
	signal tb_addr		:	std_logic_vector(15 downto 0) := (others => '0');
	signal tb_wr_data	:	std_logic_vector(31 downto 0) := (others => '0');
	signal tb_rd_data	:	std_logic_vector(31 downto 0) := (others => '0');

begin

	tb_clk <= not tb_clk after 10 ns;

	mem_bank_0:	mem_bank port map(clk => tb_clk,
							reset => tb_reset,
							wr_en => tb_wr_en,
							rd_en => tb_rd_en,
							rd_ack => tb_rd_ack,
							addr => tb_addr,
							wr_data => tb_wr_data,
							rd_data => tb_rd_data);

	process
		type pattern_type is record
			--inputs
			reset	:	std_logic;
			wr_en	:	std_logic;
			rd_en	:	std_logic;
			addr	:	std_logic_vector(15 downto 0);
			wr_data	:	std_logic_vector(31 downto 0);
			--outputs
			rd_ack	:	std_logic;
			rd_data	:	std_logic_vector(31 downto 0);
		end record;
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns	:	pattern_array :=
			(('0', '1', '0', x"0000", x"aaaaaaaa", '0', x"00000000"),
			('0', '1', '0', x"0001", x"bbbbbbbb", '0', x"00000000"),
			('0', '1', '0', x"0002", x"cccccccc", '0', x"00000000"),
			('0', '1', '0', x"0003", x"dddddddd", '0', x"00000000"),
			('0', '1', '0', x"00e7", x"eeeeeeee", '0', x"00000000"),
			('0', '0', '0', x"0000", x"00000000", '0', x"00000000"),
			('0', '0', '1', x"0000", x"00000000", '0', x"00000000"),
			('0', '0', '1', x"0001", x"00000000", '1', x"aaaaaaaa"),
			('0', '0', '1', x"0002", x"00000000", '1', x"bbbbbbbb"),
			('0', '0', '1', x"0003", x"00000000", '1', x"cccccccc"),
			('0', '0', '1', x"00e7", x"00000000", '1', x"dddddddd"),
			('0', '0', '0', x"0000", x"00000000", '1', x"eeeeeeee"),
			('0', '0', '0', x"0000", x"00000000", '0', x"00000000"),
			('1', '0', '0', x"0000", x"00000000", '0', x"00000000"),
			('0', '0', '1', x"0000", x"00000000", '0', x"00000000"),
			('0', '0', '1', x"0001", x"00000000", '1', x"01234567"),
			('0', '0', '1', x"0002", x"00000000", '1', x"89abcde7"),
			('0', '0', '1', x"0003", x"00000000", '1', x"0a0b0c0d"),
			('0', '0', '1', x"00e7", x"00000000", '1', x"10203040"),
			('0', '0', '0', x"0000", x"00000000", '1', x"deadbeef"),
			('0', '0', '0', x"0000", x"00000000", '0', x"00000000"));
	begin
		assert false report "Start of test." severity note;
		for i in patterns'range loop
			wait until rising_edge(tb_clk);
			tb_reset <= patterns(i).reset;
			tb_wr_en <= patterns(i).wr_en;
			tb_rd_en <= patterns(i).rd_en;
			tb_addr <= patterns(i).addr;
			tb_wr_data <= patterns(i).wr_data;
			wait for 1 ns;
			assert tb_rd_ack = patterns(i).rd_ack
				report "Bad rd_ack value." severity error;
			assert tb_rd_data = patterns(i).rd_data
				report "Bad rd_data value." severity error;
		end loop;
		assert false report "End of test." severity note;
		wait;
	end process;
end test_bench;