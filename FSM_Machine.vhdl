LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--Initializing inputs and outputs
ENTITY control_logic IS
	PORT (
		--inputs
		CLK : IN std_logic;
		RESET : IN std_logic;
		CPU_REQ
		BLK_VALID
		CACHE_HIT
		BLK_DIRTY
		MEM_READY
		--outputs
		CACHE_READY : OUT std_logic;
		MEM_ENABLE : OUT std_logic;
		MEM_RW : OUT std_logic
	);
END control_logic;
ARCHITECTURE Behavioral OF control_logic IS
	--Defining states for the circuit. Type command used to show the state names in the waveform.
	TYPE t_control_logic_fsm IS (
	IDLE, COMPARE_TAG, WRITE_BACK, ALLOCA TE);
	SIGNAL present_state : t_control_logic_fsm;
	SIGNAL next_state : t_control_logic_fsm;
BEGIN
	-- basic flop definition with async reset.
	IN std_logic;
	IN std_logic; : IN std_logic; : IN std_logic;
	IN std_logic;
	9
	p_state : PROCESS (CLK, RESET) BEGIN
		IF (RESET = '1') THEN
			present_state <= IDLE;
		ELSIF (rising_edge(CLK)) THEN
			present_state <= next_state;
		END IF;
	END PROCESS p_state;
	-- p_comb defines all the state transitions depending upon the inputs and the previous state.
	p_comb : PROCESS (
		present_state, CPU_REQ, BLK_V ALID, CACHE_HIT, BLK_DIRTY, MEM_READY)
	BEGIN
		-- Case of present_state
		CASE present_state IS
			WHEN IDLE => 
				IF (CPU_REQ = '1') THEN
					next_state <= COMPARE_TAG;
				ELSE
					next_state <= IDLE;
				END IF;
			WHEN COMPARE_TAG => 
				IF (BLK_VALID = '0') THEN
					next_state <= ALLOCATE;
				ELSIF (CACHE_HIT = '0') AND (BLK_DIRTY = '0') THEN
					next_state <= ALLOCATE;
				ELSIF (CACHE_HIT = '0') AND (BLK_DIRTY = '1') THEN
					10

					next_state <= WRITE_BACK;
				ELSIF (CACHE_HIT = '1') THEN
					next_state <= IDLE;
				ELSE
					next_state <= COMPARE_TAG;
				END IF;
			WHEN WRITE_BACK => 
				IF (MEM_READY = '1') THEN
					next_state <= ALLOCATE;
				ELSE
					next_state <= WRITE_BACK;
				END IF;
			WHEN ALLOCATE => 
				IF (MEM_READY = '1') THEN
					next_state <= IDLE;
				ELSE
					next_state <= ALLOCATE;
				END IF;
		END CASE;
	END PROCESS p_comb;
	11

	-- p_state_out includes the definition of output depending on the present state.
	p_state_out : PROCESS (CLK, RESET)
	BEGIN
		IF (RESET = '1') THEN
			CACHE_READY <= '0';
			MEM_ENABLE <= '0';
			MEM_RW <= '0';
		ELSIF (rising_edge(CLK)) THEN
			CASE present_state IS
				WHEN IDLE => 
					CACHE_READY <= '1';
					MEM_ENABLE <= '0';
					MEM_RW <= 'X';
				WHEN COMPARE_TAG => 
					CACHE_READY <= '0';
					MEM_ENABLE <= '0';
					MEM_RW <= 'X';
				WHEN WRITE_BACK => 
					CACHE_READY <= '0';
					MEM_ENABLE <= '1';
					MEM_RW <= '1';
				WHEN ALLOCATE => 
					CACHE_READY <= '0';
					MEM_ENABLE <= '1';
					MEM_RW <= '0';
			END CASE;
		END IF;
	END PROCESS p_state_out;
	END Behavioral;
	12

	VI. Appendix - [ B ] Test_Bench code : 
	USE IEEE.STD_LOGIC_1164.ALL;
	ENTITY tb_control_logic IS END tb_control_logic;
		ARCHITECTURE Behavioral OF tb_control_logic IS COMPONENT control_logic IS
			PORT (
				CLK : IN std_logic;
				RESET : IN std_logic;
				CPU_REQBLK_VALID
				CACHE_HITBLK_DIRTY
				MEM_READY CACHE_READY : OUT std_logic;
				MEM_ENABLE : OUT std_logic;
				MEM_RW : OUT std_logic
			);
		END COMPONENT;
		SIGNAL clk, reset, cpu_req, blk_valid, cache_hit, blk_dirty, mem_ready, cache_ready, mem_enable, mem_rw : std_logic;
	BEGIN
		dut : control_logic
		PORT MAP(
			CLK => clk, 
			RESET => reset, 
			CPU_REQ => cpu_req, BLK_VALID => blk_valid, CACHE_HIT => cache_hit, BLK_DIRTY => blk_dirty, MEM_READY => mem_ready, CACHE_READY => cache_ready, MEM_ENABLE => mem_ready, MEM_RW => mem_rw
		);
		IN std_logic;
		IN std_logic; : IN std_logic; : IN std_logic;
		IN std_logic;
		13

		clock : PROCESS BEGIN
			clk <= '0';
			WAIT FOR 2 ns;
			clk <= '1';
			WAIT FOR 2 ns;
		END PROCESS clock;
		PROCESS
	BEGIN
		reset <= '1', '0' AFTER 1 ns;
		WAIT UNTIL (reset = '0');
		cpu_req <= '1';
		WAIT FOR 4 ns;
		cpu_req <= '0';
		blk_valid <= '1';
		cache_hit <= '1';
		WAIT FOR 4 ns;
		cpu_req <= '1';
		WAIT FOR 4 ns;
		blk_valid <= '0';
		cache_hit <= '0';
		blk_dirty <= '0';
		WAIT FOR 4 ns;
		mem_ready <= '1';
		WAIT FOR 4 ns;
		cpu_req <= '1';
		WAIT FOR 4 ns;
		blk_valid <= '1';
		cache_hit <= '0';
		blk_dirty <= '1';
		WAIT FOR 4 ns;
		mem_ready <= '1';
		WAIT FOR 8 ns;
		WAIT;
