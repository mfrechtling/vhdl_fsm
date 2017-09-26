library ieee;
use ieee.std_logic_1164.all;

entity mem_bank is
	port(	clk			:	in std_logic,
			rst			:	in std_logic,
			wr_en		:	in std_logic,
			rd_en		:	in std_logic,
			rd_ack		:	out std_logic,
			addr 		:	in std_logic_vector(15 downto 0),
			wr_data		:	in std_logic_vector(31 downto 0),
			rd_data		:	out std_logic_vector(31 downto 0));
end entity;

architecture rtl of mem_bank is
	type reg_array is array (4 downto 0) of std_logic_vector(31 downto 0);

	function init_reg_array return reg_array is
		variable result	:	reg_array;
	begin
		result(0)	:=	x"01234567";
		result(1)	:=	x"89abcde7";
		result(2)	:=	x"0a0b0c0d";
		result(3)	:=	x"10203040";
		result(4)	:=	x"deadbeef";
		return result;
	end init_reg_array;

	signal mem_bank		:	reg_array := init_reg_array;
	signal true_addr	:	std_logic_vector(15 downto 0);
	signal addr_valid	:	std_logic;
begin

	with addr select 
		true_addr <= 	x"0000" when x"0000",
						x"0001" when x"0001",
						x"0002" when x"0002",
						x"0003" when x"0003",
						x"0004" when x"00e7",
						x"8000" when others;

	addr_valid <= not true_addr(15);

	process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
				rd_ack <= '0';
				rd_data <= (others => '0');
				mem_bank <=	init_reg_array;
			elsif (wr_en = '1' and addr_valid) then
				rd_ack <= '0';
				rd_data <= (others => '0');
				mem_bank(unsigned(true_addr)) <= wr_data;
			elsif (rd_en = '1' and addr_valid) then
				rd_data <= mem_bank(unsigned(true_addr));
				rd_ack <= '1';
			end if;
		end if;
	end process;

end architecture rtl;