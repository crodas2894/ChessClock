library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ChessClock is
	port (
		button : in std_logic_vector(4 downto 0);
		switches : in std_logic_vector(7 downto 0);
		clk : in std_logic;
		seg1 : out std_logic_vector(6 downto 0);
		seg2 : out std_logic_vector(6 downto 0);
		seg3 : out std_logic_vector(6 downto 0);
		seg4 : out std_logic_vector(6 downto 0);
		LED : out std_logic_vector(7 downto 0);
		CAT1 : out std_logic;
		CAT2 : out std_logic;
		CAT3 : out std_logic;
		CAT4 : out std_logic);
end ChessClock;

architecture Behavioral of ChessClock is

	component ClockAdjust is
		port (
			clk : in STD_LOGIC;
			clk_out : out STD_LOGIC;
			clk_1hz : out STD_LOGIC);
	end component;

	component SEV_SEG is
		port (
			clk : in std_logic;
			p1_time : in STD_LOGIC_VECTOR (15 downto 0);
			p2_time : in STD_LOGIC_VECTOR (15 downto 0);
			seg1 : out std_logic_vector(6 downto 0);
			seg2 : out std_logic_vector(6 downto 0);
			seg3 : out std_logic_vector(6 downto 0);
			seg4 : out std_logic_vector(6 downto 0);
			seg5 : out std_logic_vector(6 downto 0);
			seg6 : out std_logic_vector(6 downto 0);
			seg7 : out std_logic_vector(6 downto 0);
			seg8 : out std_logic_vector(6 downto 0));
	end component;

	component debouncer is
		port (
			data : in std_logic;--input signal to be debounced 
			clk : in std_logic;--input clock 
			out_data : out std_logic); --debounced signal
	end component;
	--Delay signals
	signal wait_count : integer := 0;
	constant waiting : integer := 100000000; --1 second
	signal idle_wait : integer := 0;
	signal clksig, clk_1hz : std_logic := '0';
	signal db_north, db_south, db_center, db_east, db_west : std_logic := '0';
	--States
	type State_type is (reset, idle, player1, player2, pause, chess_initial, chess_set, chess_idle, chess_time, fchess_initial, fchess_idle, fchess_set, fchess_delay, fchess_time, fplayer1start1, fplayer2start1, fplayer1, fplayer2, fpause);
	signal cur_state, next_state : State_type := idle;
	--Regular Chess Clock
	signal p1_t, p2_t : integer := 0;
	signal time_adjust : integer := 0;
	signal disp_p1, disp_p2 : integer := 0;
	signal timer, count1, count2 : integer := 0;
	signal c1, c2 : std_logic_vector(15 downto 0);
	--Fischer Chess Clock
	signal fp1_t, fp2_t : integer := 0;
	signal f_delay : integer := 0;
	signal ftimer, ftime_adjust : integer := 0;

	--Seven Segment
	signal sevseg1, sevseg2, sevseg3, sevseg4, sevseg5, sevseg6, sevseg7, sevseg8 : std_logic_vector(6 downto 0);
	--LED
	signal led_out : std_logic_vector(7 downto 0) := "10101010";
	signal p1_tup : std_logic_vector(7 downto 0) := "11110000";
	signal p2_tip : std_logic_vector(7 downto 0) := "00001111";
	signal flash : integer := 50000000;
	signal zero : integer := 0;

begin
	clocks : ClockAdjust port map(clk => clk, clk_out => clksig, clk_1hz => clk_1hz);
	SevSeg : SEV_SEG port map(clk => clk, p1_time => c1, p2_time => c2, seg1 => sevseg1, seg2 => sevseg2, seg3 => sevseg3, seg4 => sevseg4, seg5 => sevseg5, seg6 => sevseg6, seg7 => sevseg7, seg8 => sevseg8);
	North : debouncer port map(
		data => button(4),
		clk => clk,
		out_data => db_north);
	South : debouncer port map(
		data => button(1),
		clk => clk,
		out_data => db_south);
	East : debouncer port map(
		data => button(3),
		clk => clk,
		out_data => db_east);
	West : debouncer port map(
		data => button(2),
		clk => clk,
		out_data => db_west);
	Center : debouncer port map(
		data => button(0),
		clk => clk,
		out_data => db_center);
	LED <= led_out;

	--FSM Code
	process (clk)
	begin
		if (rising_edge(clk)) then
			cur_state <= next_state;
		end if;
	end process;

	process (clksig)
	begin
		if (rising_edge(clk)) then

			case cur_state is

				when reset =>
					led_out <= "10101010";
					wait_count <= wait_count + 1;
					if (wait_count > waiting) then
						next_state <= idle;
						wait_count <= 0;
					end if;

				when idle =>
					if (idle_wait = 100000000) then
						led_out <= led_out(0) & led_out(7 downto 1); -- rotate right by one bit
						idle_wait <= 0;
					else
						idle_wait <= idle_wait + 1;
					end if;
					if (switches(7) = '1') then
						next_state <= chess_initial;
					elsif (switches(6) = '1') then
						next_state <= fchess_initial;
					end if;

				when chess_initial =>
					if (switches(7) = '0') then
						next_state <= reset;
					end if;
					time_adjust <= 0;
					wait_count <= wait_count + 1;
					if (wait_count > waiting) then
						next_state <= chess_idle;
						wait_count <= 0;
					end if;

				when chess_set =>
					if (switches(7) = '0') then
						next_state <= reset;
					end if;
					wait_count <= wait_count + 1;
					if (wait_count > waiting) then
						next_state <= chess_idle;
						wait_count <= 0;
					end if;

				when chess_idle =>
					led_out <= "11111111";
					if (switches(7) = '0') then
						next_state <= reset;
					elsif (switches(0) = '1') then
						next_state <= chess_time;
					elsif (db_west = '1') then
						next_state <= player1;
					elsif (db_east = '1') then
						next_state <= player2;
					end if;

				when chess_time =>
					led_out <= "00011000";
					if (switches(0) = '0') then
						next_state <= chess_set;
					elsif (switches(7) = '0') then
						next_state <= reset;
					elsif (db_north = '1') then
						time_adjust <= time_adjust + 300; --increase by 5 minutes
					elsif (db_south = '1') then
						time_adjust <= time_adjust + 60; --increase by 1 minute
					elsif (db_east = '1') then
						time_adjust <= time_adjust + 15; --increase by 15 seconds
					elsif (db_west = '1') then
						time_adjust <= time_adjust + 1; --increase by 1 second
					elsif (db_center = '1') then
						time_adjust <= 0; --Reset to zero
					end if;

				when player1 =>
					led_out <= "11110000";
					if (switches(7) = '0') then
						next_state <= reset;
					elsif (db_west = '1') then
						next_state <= player2;
					elsif (db_center = '1') then
						next_state <= pause;
					end if;

				when player2 =>
					led_out <= "00001111";
					if (switches(7) = '0') then
						next_state <= reset;
					elsif (db_east = '1') then
						next_state <= player1;
					elsif (db_center = '1') then
						next_state <= pause;
					end if;

				when pause =>
					if (switches(7) = '0') then
						next_state <= reset;
					elsif (db_north = '1') then
						next_state <= chess_set;
					elsif (db_east = '1') then
						next_state <= player2;
					elsif (db_west = '1') then
						next_state <= player1;
					end if;

				when fchess_initial =>
					if (switches(6) = '0') then
						next_state <= reset;
					end if;
					f_delay <= 0;
					ftime_adjust <= 0;
					wait_count <= wait_count + 1;
					if (wait_count > waiting) then
						next_state <= fchess_idle;
						wait_count <= 0;
					end if;

				when fchess_set =>
					if (switches(6) = '0') then
						next_state <= reset;
					end if;
					wait_count <= wait_count + 1;
					if (wait_count > waiting) then
						next_state <= fchess_idle;
						wait_count <= 0;
					end if;

				when fchess_idle =>
					led_out <= "11111111";
					if (switches(6) = '0') then
						next_state <= reset;
					elsif (switches(1) = '1' and switches(0) = '1') then
						next_state <= fchess_time;
					elsif (db_west = '1') then
						next_state <= fplayer1start1;
					elsif (db_east = '1') then
						next_state <= fplayer2start1;
					end if;

				when fchess_time =>
					led_out <= "00011000";
					if (switches(1) = '0') then
						next_state <= fchess_delay;
					elsif (switches(6) = '0') then
						next_state <= reset;
					elsif (db_north = '1') then
						ftime_adjust <= ftime_adjust + 300; --increase by 5 minutes
					elsif (db_south = '1') then
						ftime_adjust <= ftime_adjust + 60; --increase by 1 minute
					elsif (db_east = '1') then
						ftime_adjust <= ftime_adjust + 15; --increase by 15 seconds
					elsif (db_west = '1') then
						ftime_adjust <= ftime_adjust + 1; --increase by 1 second
					elsif (db_center = '1') then
						ftime_adjust <= 0; --Reset to zero
					end if;

				when fchess_delay =>
					led_out <= "00001000";
					if (switches(0) = '0') then
						next_state <= fchess_set;
					elsif (switches(6) = '0') then
						next_state <= reset;
					elsif (db_north = '1') then
						f_delay <= f_delay + 5; --increase by 5 seconds
					elsif (db_south = '1') then
						f_delay <= f_delay + 1; --increase by 1 second
					elsif (db_center = '1') then
						f_delay <= 0; --Reset to zero
					end if;

				when fplayer1start1 =>
					led_out <= "11110000";
					if (switches(6) = '0') then
						next_state <= reset;
					elsif (db_west = '1') then
						next_state <= fplayer2;
					elsif (db_center = '1') then
						next_state <= fpause;
					end if;

				when fplayer2start1 =>
					led_out <= "00001111";
					if (switches(6) = '0') then
						next_state <= reset;
					elsif (db_east = '1') then
						next_state <= fplayer1;
					elsif (db_center = '1') then
						next_state <= fpause;
					end if;
				when fplayer1 =>
					led_out <= "11110000";
					if (switches(6) = '0') then
						next_state <= reset;
					elsif (db_west = '1') then
						next_state <= fplayer2;
					elsif (db_center = '1') then
						next_state <= fpause;
					end if;

				when fplayer2 =>
					led_out <= "00001111";
					if (switches(6) = '0') then
						next_state <= reset;
					elsif (db_east = '1') then
						next_state <= fplayer1;
					elsif (db_center = '1') then
						next_state <= fpause;
					end if;

				when fpause =>
					if (switches(6) = '0') then
						next_state <= reset;
					elsif (db_north = '1') then
						next_state <= fchess_set;
					elsif (db_east = '1') then
						next_state <= fplayer2;
					elsif (db_west = '1') then
						next_state <= fplayer1;
					end if;
			end case;
		end if;
	end process;

	process (clk_1hz)
	begin
		if (rising_edge(clk_1hz)) then
			case cur_state is
				when reset =>

				when idle =>
					disp_p1 <= 0;
					disp_p2 <= 0;
				when chess_initial =>
					disp_p1 <= 300;
					disp_p2 <= 300;
					timer <= 300;
					p1_t <= 300;
					p2_t <= 300;
					count1 <= 0;
					count2 <= 0;

				when chess_idle =>
					disp_p1 <= p1_t;
					disp_p2 <= p2_t;

				when chess_time =>
					disp_p1 <= time_adjust;
					disp_p2 <= time_adjust;

				when chess_set =>
					if (time_adjust = 0) then
						timer <= 300;
						p1_t <= 300;
						p2_t <= 300;
						disp_p1 <= 300;
						disp_p2 <= 300;
						count1 <= 0;
						count2 <= 0;
					else
						timer <= time_adjust;
						p1_t <= time_adjust;
						p2_t <= time_adjust;
						disp_p1 <= time_adjust;
						disp_p2 <= time_adjust;
						count1 <= 0;
						count2 <= 0;
					end if;

				when player1 =>
					count2 <= 0;
					if (p1_t = 0) then
						disp_p1 <= p1_t;
					else
						if (count1 = 0) then
							disp_p2 <= p2_t;
							disp_p1 <= p1_t;
							p1_t <= p1_t - 1;
						else
							disp_p2 <= p2_t;
							disp_p1 <= p1_t;
							p1_t <= p1_t - 1;
						end if;
						count1 <= count1 + 1;
					end if;

				when player2 =>
					count1 <= 0;
					if (p2_t = 0) then
						disp_p2 <= p2_t;
					else
						if (count2 = 0) then
							disp_p1 <= p1_t;
							disp_p2 <= p2_t;
							p2_t <= p2_t - 1;
						else
							disp_p1 <= p1_t;
							disp_p2 <= p2_t;
							p2_t <= p2_t - 1;
						end if;
						count2 <= count2 + 1;
					end if;

				when pause =>
					disp_p1 <= p1_t;
					disp_p2 <= p2_t;

				when fchess_initial =>
					disp_p1 <= 300;
					disp_p2 <= 300;
					ftimer <= 300;
					fp1_t <= 300;
					fp2_t <= 300;
					count1 <= 0;
					count2 <= 0;

				when fchess_idle =>
					disp_p1 <= fp1_t;
					disp_p2 <= fp2_t;

				when fchess_time =>
					disp_p1 <= ftime_adjust;
					disp_p2 <= ftime_adjust;

				when fchess_delay =>
					disp_p1 <= f_delay;
					disp_p2 <= f_delay;

				when fchess_set =>
					if (ftime_adjust = 0) then
						disp_p1 <= 300;
						disp_p2 <= 300;
						ftimer <= 300;
						fp1_t <= 300;
						fp2_t <= 300;
						count1 <= 0;
						count2 <= 0;
					else
						ftimer <= ftime_adjust;
						fp1_t <= ftime_adjust;
						fp2_t <= ftime_adjust;
						disp_p1 <= ftime_adjust;
						disp_p2 <= ftime_adjust;
						count1 <= 0;
						count2 <= 0;
					end if;

				when fplayer1start1 =>
					count2 <= 0;
					if (fp1_t = 0) then
						disp_p1 <= fp1_t;
					else
						if (count1 = 0) then
							disp_p2 <= fp2_t;
							disp_p1 <= fp1_t;
							fp1_t <= fp1_t - 1;
						else
							disp_p2 <= fp2_t;
							disp_p1 <= fp1_t;
							fp1_t <= fp1_t - 1;
						end if;
						count1 <= count1 + 1;
					end if;

				when fplayer2start1 =>
					count1 <= 0;
					if (fp2_t = 0) then
						disp_p1 <= fp2_t;
					else
						if (count2 = 0) then
							disp_p1 <= fp1_t;
							disp_p2 <= fp2_t;
							fp2_t <= fp2_t - 1;
						else
							disp_p1 <= fp1_t;
							disp_p2 <= fp2_t;
							fp2_t <= fp2_t - 1;
						end if;
						count2 <= count2 + 1;
					end if;

				when fplayer1 =>
					count2 <= 0;
					if (fp1_t = 0) then
						disp_p1 <= fp1_t;
					else
						if (count1 = 0) then
							fp2_t <= fp2_t + f_delay;
							disp_p2 <= fp2_t;
							disp_p1 <= fp1_t;
							fp1_t <= fp1_t - 1;
						else
							disp_p2 <= fp2_t;
							disp_p1 <= fp1_t;
							fp1_t <= fp1_t - 1;
						end if;
						count1 <= count1 + 1;
					end if;

				when fplayer2 =>
					count1 <= 0;
					if (fp2_t = 0) then
						disp_p1 <= fp2_t;
					else
						if (count2 = 0) then
							fp1_t <= fp1_t + f_delay;
							disp_p1 <= fp1_t;
							disp_p2 <= fp2_t;
							fp2_t <= fp2_t - 1;
						else
							disp_p1 <= fp1_t;
							disp_p2 <= fp2_t;
							fp2_t <= fp2_t - 1;
						end if;
						count2 <= count2 + 1;
					end if;

				when fpause =>
					disp_p1 <= fp1_t;
					disp_p2 <= fp2_t;

			end case;
		end if;
	end process;

	c1 <= std_logic_vector(to_unsigned(disp_p1, 16));
	c2 <= std_logic_vector(to_unsigned(disp_p2, 16));

	process (clksig, clk)
	begin
		if (rising_edge(clk)) then
			if (clksig = '0') then
				seg1 <= sevseg1;
				CAT1 <= '0';
				seg2 <= sevseg3;
				CAT2 <= '0';
				seg3 <= sevseg5;
				CAT3 <= '0';
				seg4 <= sevseg7;
				CAT4 <= '0';
			else
				seg1 <= sevseg2;
				CAT1 <= '1';
				seg2 <= sevseg4;
				CAT2 <= '1';
				seg3 <= sevseg6;
				CAT3 <= '1';
				seg4 <= sevseg8;
				CAT4 <= '1';
			end if;
		end if;
	end process;
end Behavioral;