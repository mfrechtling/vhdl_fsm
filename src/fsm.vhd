library ieee;
use ieee.std_logic_1164.all;

entity fsm is
	port(
		-- GLOBAL SIGNALS:
		clk				: in std_logic;
		reset			: in std_logic;
		-- COMMAND INTERFACE:
		data_in_vld		: in std_logic;
		data_in 		: in std_logic_vector(7 downto 0);
		data_out_vld	: out std_logic;
		data_out 		: out std_logic_vector(7 downto 0);
		--REGISTER ACCESS INTERFACE:
		rd_ack			: in std_logic;
		rd_data			: in std_logic_vector(31 downto 0);
		wr_en			: out std_logic;
		rd_en			: out std_logic;
		addr			: out std_logic_vector(15 downto 0);
		wr_data			: out std_logic_vector(31 downto 0));
end entity;

architecture behaviour of fsm is
	type state is (IDLE, CMD, RD, WR, RSP, BRK, ADDR_0, ADDR_1, ADDR_2, ADDR_3, DATA_0, DATA_1, DATA_2, DATA_3, READ_DATA, READ_ACK, RSP_SPC, RSP_CMD);

	signal fsm_state		: state := IDLE;
	signal prev_fsm_state	: state := IDLE;
	signal current_state	: state := IDLE;
	signal next_state		: state := IDLE;
	signal state_buffer 	: state := IDLE;
	signal addr_reg			: std_logic_vector(31 downto 0) := (others => '0');
	signal data_reg			: std_logic_vector(31 downto 0) := (others => '0');

	signal fsm_sig			: std_logic_vector(7 downto 0);
	signal prev_fsm_sig		: std_logic_vector(7 downto 0);
	signal current_sig		: std_logic_vector(7 downto 0);
	signal next_sig			: std_logic_vector(7 downto 0);
	signal rd_cntr			: integer := 0;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				fsm_state <= IDLE;
				current_state <= IDLE;
				prev_fsm_state <= IDLE;
			else
				case fsm_state is
					when IDLE =>
						if (data_in_vld = '1' and data_in = x"e7") then
							fsm_state <= CMD;
						end if;
						current_state <= IDLE;
					when CMD =>
						if (data_in_vld = '1') then
							case data_in is
								when x"13" =>
									fsm_state <= RD;
									current_state <= ADDR_3;
								when x"23" =>
									fsm_state <= WR;
									current_state <= ADDR_3;		
								when x"e7" =>
									fsm_state <= prev_fsm_state;
									current_state <= next_state;
								when others =>
									fsm_state <= IDLE;
									current_state <= IDLE;
							end case;
						end if;
					when others =>
						if (data_in_vld = '1' and data_in = x"e7") then
							prev_fsm_state <= fsm_state;
							fsm_state <= CMD;
							current_state <= CMD;
						elsif (next_state = BRK) then
							if (fsm_state = BRK) then
								fsm_state <= IDLE;
								current_state <= IDLE;
							else
								fsm_state <= BRK;
								current_state <= RSP_SPC;
							end if;
						elsif (next_state = READ_DATA) then
							if (rd_ack = '1') then
								fsm_state <= RSP;
								current_state <= READ_ACK;
								rd_cntr <= 0;
							elsif (rd_cntr >= 3) then
								fsm_state <= BRK;
								current_state <= RSP_SPC;
								rd_cntr <= 0;
							else
								current_state <= next_state;
								rd_cntr <= rd_cntr + 1;
							end if;
						elsif (next_state = fsm_state) then
							fsm_state <= IDLE;
							current_state <= next_state;
						else
							current_state <= next_state;
						end if;
				end case;
			end if;
		end if;
	end process;

	process(current_state)
	begin
		rd_en <= '0';
		wr_en <= '0';
		addr <= (others => '0');
		wr_data <= (others => '0');
		data_out_vld <= '0';
		data_out <= (others => '0');
		case current_state is
			when IDLE =>
				next_state <= IDLE;
			when ADDR_3 =>
				if (data_in_vld = '1') then
					addr_reg(31 downto 24) <= data_in;
					next_state <= ADDR_2;
				end if;
			when ADDR_2 =>
				if (data_in_vld = '1') then
					addr_reg(23 downto 16) <= data_in;
					next_state <= ADDR_1;
				end if;
			when ADDR_1 =>
				if (data_in_vld = '1') then
					addr_reg(15 downto 8) <= data_in;
					next_state <= ADDR_0;
				end if;
			when ADDR_0 =>
				if (data_in_vld = '1') then
					addr_reg(7 downto 0) <= data_in;
					case fsm_state is
						when RD => 
							next_state <= READ_DATA;
						when WR => 
							next_state <= DATA_3;
						when others => null;
					end case;
				end if;
			when DATA_3 =>
				case fsm_state is
					when WR =>
						if (data_in_vld = '1') then
							data_reg(31 downto 24) <= data_in;
							next_state <= DATA_2;
						end if;
					when RSP =>
						data_out_vld <= '1';
						data_out <= data_reg(31 downto 24);
						if (data_reg(31 downto 24) = x"e7") then
							next_state <= RSP_SPC;
							state_buffer <= DATA_2;
						else
							next_state <= DATA_2;
						end if;
					when others => null;
				end case;
			when DATA_2 =>
				case fsm_state is
					when WR =>
						if (data_in_vld = '1') then
							data_reg(23 downto 16) <= data_in;
							next_state <= DATA_1;
						end if;
					when RSP =>
						data_out_vld <= '1';
						data_out <= data_reg(23 downto 16);
						if (data_reg(23 downto 16) = x"e7") then
							next_state <= RSP_SPC;
							state_buffer <= DATA_1;
						else
							next_state <= DATA_1;
						end if;
					when others => null;
				end case;
			when DATA_1 =>
				case fsm_state is
					when WR =>
						if (data_in_vld = '1') then
							data_reg(15 downto 8) <= data_in;
							next_state <= DATA_0;
						end if;
					when RSP =>
						data_out_vld <= '1';
						data_out <= data_reg(15 downto 8);
						if (data_reg(15 downto 8) = x"e7") then
							next_state <= RSP_SPC;
							state_buffer <= DATA_0;
						else
							next_state <= DATA_0;
						end if;
					when others => null;
				end case;
			when DATA_0 =>
				case fsm_state is
					when WR =>
						if (data_in_vld = '1') then
							data_reg(7 downto 0) <= data_in;
							next_state <= WR;
						end if;
					when RSP =>
						data_out_vld <= '1';
						data_out <= data_reg(7 downto 0);
						if (data_reg(7 downto 0) = x"e7") then
							next_state <= RSP_SPC;
							state_buffer <= RSP;
						else
							next_state <= RSP;
						end if;
					when others => null;
				end case;
			when READ_DATA =>
				rd_en <= '1';
				addr <= addr_reg(15 downto 0);
			when READ_ACK =>
				data_reg <= rd_data;
				next_state <= RSP_SPC;
			when WR =>
				wr_en <= '1';
				addr <= addr_reg(15 downto 0);
				wr_data <= data_reg;
				next_state <= IDLE;
			when RSP_SPC =>
				data_out_vld <= '1';
				data_out <= x"e7";
				if (state_buffer = IDLE) then
					next_state <= RSP_CMD;
				else
					next_state <= state_buffer;
				end if;
				state_buffer <= IDLE;
			when RSP_CMD =>
				data_out_vld <= '1';
				case fsm_state is
					when RSP => 
						data_out <= x"03";
						next_state <= DATA_3;
					when BRK => 
						data_out <= x"55";
						next_state <= BRK;
					when others => null;
				end case;
			when others => null;
		end case;
	end process;
end architecture;