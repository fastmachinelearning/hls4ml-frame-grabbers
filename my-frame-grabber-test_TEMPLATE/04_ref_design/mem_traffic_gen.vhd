--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: mem_traffic_gen
--    File: mem_traffic_gen.vhd
--    Date: 2018-01-22
--     Rev: 0.1
--  Author: PP
--------------------------------------------------------------------------------
-- Reference Design: Memory Traffic Generator for AXI4 Master Interface
--------------------------------------------------------------------------------
-- 0.1, 2018-01-22, PP, Initial release
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mem_traffic_gen is
	generic (
		DATA_WIDTH 				: natural := 256
	);
	port (
		-- Clock
		clk						: in  std_logic;
		-- Control/Status
		MemTrafficGen_en		: in  std_logic;
		Wraparound_pls			: out std_logic;
		Wraparound_cnt			: out std_logic_vector(31 downto 0);
		-- AXI4 Master Interface
		m_axi_resetn			: in  std_logic; 	-- AXI 4 Interface reset
		m_axi_awaddr 			: out std_logic_vector( 31 downto 0);
		m_axi_awlen 			: out std_logic_vector(  7 downto 0);
		m_axi_awsize 			: out std_logic_vector(  2 downto 0);
		m_axi_awburst 			: out std_logic_vector(  1 downto 0);
		m_axi_awlock 			: out std_logic;
		m_axi_awcache 			: out std_logic_vector(  3 downto 0);
		m_axi_awprot 			: out std_logic_vector(  2 downto 0);
		m_axi_awqos 			: out std_logic_vector(  3 downto 0);
		m_axi_awvalid 			: out std_logic;
		m_axi_awready 			: in  std_logic;
		m_axi_wdata 			: out std_logic_vector(DATA_WIDTH   - 1 downto 0);
		m_axi_wstrb 			: out std_logic_vector(DATA_WIDTH/8 - 1 downto 0);
		m_axi_wlast 			: out std_logic;
		m_axi_wvalid 			: out std_logic;
		m_axi_wready 			: in  std_logic;
		m_axi_bresp 			: in  std_logic_vector(  1 downto 0);
		m_axi_bvalid 			: in  std_logic;
		m_axi_bready 			: out std_logic;
		m_axi_araddr 			: out std_logic_vector( 31 downto 0);
		m_axi_arlen 			: out std_logic_vector(  7 downto 0);
		m_axi_arsize 			: out std_logic_vector(  2 downto 0);
		m_axi_arburst 			: out std_logic_vector(  1 downto 0);
		m_axi_arlock 			: out std_logic;
		m_axi_arcache 			: out std_logic_vector(  3 downto 0);
		m_axi_arprot 			: out std_logic_vector(  2 downto 0);
		m_axi_arqos 			: out std_logic_vector(  3 downto 0);
		m_axi_arvalid 			: out std_logic;
		m_axi_arready 			: in  std_logic;
		m_axi_rdata 			: in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		m_axi_rresp 			: in  std_logic_vector(  1 downto 0);
		m_axi_rlast 			: in  std_logic;
		m_axi_rvalid 			: in  std_logic;
		m_axi_rready 			: out std_logic
	);
end entity mem_traffic_gen;

architecture behav of mem_traffic_gen is

	----------------------------------------------------------------------------
	-- Constants
	----------------------------------------------------------------------------
	constant MEM_SIZE_BYTE		: unsigned(31 downto 0) := x"40000000";	-- 1 GB
	constant MEM_BASE_ADDRESS	: unsigned(31 downto 0) := x"00000000";
	constant NB_OF_PIXELS		: natural := DATA_WIDTH/8;

    
	----------------------------------------------------------------------------
	-- Types
	----------------------------------------------------------------------------
	-- AXI Write state
    type awr_state_t is (
        AWR_START_NEW_CYCLE,
        AWR_WRITE_ADDR,
        AWR_WRITE_DATA,
        AWR_WAIT_RD_LAST
    );
    
	-- AXI Read state
    type ard_state_t is (
        ARD_START_NEW_CYCLE,
        ARD_WAIT_BVALID,
        ARD_WRITE_ADDR,
        ARD_READ_DATA
    );    

	type b8_a is array (natural range <>) of unsigned(7 downto 0);


	----------------------------------------------------------------------------
	-- Functions
	----------------------------------------------------------------------------

    
	----------------------------------------------------------------------------
	-- Components
	----------------------------------------------------------------------------
	
	
	----------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------
    ---- Finite State Machines -------------------------------------------------
	-- AXI Write FSM
    signal awr_state        : awr_state_t;
    -- AXI Read FSM
    signal ard_state        : ard_state_t;
	
    ---- Burst Config ----------------------------------------------------------
	signal axlen			: std_logic_vector(  7 downto 0);
	signal axsize			: std_logic_vector(  2 downto 0);
	signal wlast_cnt		: unsigned		  (  7 downto 0);
	
    ---- AXI Write side --------------------------------------------------------
	signal m_axi_awaddr_i	: std_logic_vector( 31 downto 0);
	signal m_axi_awvalid_i	: std_logic;
	signal m_axi_wlast_i	: std_logic;
	signal m_axi_wvalid_i	: std_logic;
	signal m_axi_wdata_i	: std_logic_vector(DATA_WIDTH   - 1 downto 0) := (others=>'0');
	signal wdata_cnt		: b8_a			  (DATA_WIDTH/8 - 1 downto 0);
	signal wburst_cnt		: unsigned		  (  7 downto 0);
	signal awr_cycle_done	: std_logic;
	
	signal Wraparound_pls_i : std_logic;
	signal Wraparound_cnt_i : std_logic_vector( 31 downto 0) := (others=>'0');

    ---- AXI Read side ---------------------------------------------------------
	signal m_axi_arvalid_i	: std_logic;
	signal m_axi_araddr_i	: std_logic_vector( 31 downto 0);
	signal ard_cycle_done	: std_logic;

	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------
    -- attribute mark_debug : string;
	-- attribute mark_debug of ard_state 		: signal is "true";
	-- attribute mark_debug of awr_state 		: signal is "true";
    
    
begin

	---------------------------------------------------------------------------------------
	-- Burst Config
	---------------------------------------------------------------------------------------
	gBurstConfig_128 : if DATA_WIDTH = 128 generate
		axlen 		<= x"3F";
		axsize		<= "100";
		wlast_cnt	<= unsigned(axlen) - 1;
	end generate;
	
	gBurstConfig_256 : if DATA_WIDTH = 256 generate
		axlen 		<= x"1F";
		axsize		<= "101";
		wlast_cnt	<= unsigned(axlen) - 1;
	end generate;		

    
	---------------------------------------------------------------------------------------
	-- AXI Write side
	---------------------------------------------------------------------------------------

	-- AXI Write FSM
	pAxiWriteFsm : process(clk) is
	begin
		if rising_edge(clk) then
			awr_cycle_done <= '0';
			case awr_state is
				when AWR_START_NEW_CYCLE =>
					if MemTrafficGen_en = '1' then
						awr_state <= AWR_WRITE_ADDR;
					end if;
				when AWR_WRITE_ADDR =>
					m_axi_awvalid_i <= '1';
					if m_axi_awready='1' and m_axi_awvalid_i='1' then
						m_axi_awvalid_i <= '0';
						awr_state     	<= AWR_WRITE_DATA;
					end if;
				when AWR_WRITE_DATA =>
					m_axi_wvalid_i <= '1';
					if m_axi_wready='1' and m_axi_wlast_i='1' then
						m_axi_wvalid_i 	<= '0';
						awr_state    	<= AWR_WAIT_RD_LAST;
					end if;
				when AWR_WAIT_RD_LAST =>
					if m_axi_arready='1' and m_axi_arvalid_i='1' then
						awr_cycle_done <= '1';
						awr_state 	   <= AWR_START_NEW_CYCLE;
					end if;
			end case;
			if m_axi_resetn = '0' then
				m_axi_awvalid_i	<= '0';
				m_axi_wvalid_i  <= '0';
				awr_state 	  	<= AWR_START_NEW_CYCLE;
			end if;
		end if;
	end process;
	
	pAxiWriteAddress : process(clk) is
	begin
		if rising_edge(clk) then
			Wraparound_pls_i <= '0';
			if awr_cycle_done = '1' then
				m_axi_awaddr_i <= std_logic_vector(unsigned(m_axi_awaddr_i) + 1024);
				if unsigned(m_axi_awaddr_i) >= MEM_SIZE_BYTE - 1024 then
					m_axi_awaddr_i <= (others=>'0');
					Wraparound_pls_i <= '1';
				end if;
			end if;
			if m_axi_resetn = '0' then
				m_axi_awaddr_i <= (others=>'0');
			end if;
		end if;
	end process;
	
	pAxiWriteData : process(clk) is
	begin
		if rising_edge(clk) then
			if m_axi_wready='1' and m_axi_wvalid_i='1' then
				for i in 0 to NB_OF_PIXELS-1 loop
					wdata_cnt(i) <= wdata_cnt(i) + NB_OF_PIXELS;
				end loop;
				wburst_cnt <= wburst_cnt + 1;
				m_axi_wdata_i <= std_logic_vector(unsigned(m_axi_wdata_i) + 1);
			end if;
			m_axi_wlast_i <= '0';
			if wburst_cnt = wlast_cnt then
				m_axi_wlast_i <= '1';
			end if;
			if m_axi_wready='1' and m_axi_wvalid_i='1' and m_axi_wlast_i='1' then
				wburst_cnt <= (others=>'0');
				for i in 0 to NB_OF_PIXELS-1 loop
					wdata_cnt(i) <= to_unsigned(i,8);
				end loop;
			end if;
			if m_axi_resetn = '0' then
				m_axi_wlast_i	<= '0';
				wburst_cnt		<= (others=>'0');
				for i in 0 to NB_OF_PIXELS-1 loop
					wdata_cnt(i) <= to_unsigned(i,8);
				end loop;
			end if;			
		end if;
	end process;
	
	-- pWriteDataMapping : process(wdata_cnt) is
	-- begin
		-- for i in 0 to NB_OF_PIXELS-1 loop
			-- m_axi_wdata_i(i*8 + 7 downto i*8) <= std_logic_vector(wdata_cnt(i));
		-- end loop;
	-- end process;
	
	pWraparoundCounter : process(clk) is
	begin
		if rising_edge(clk) then
			if Wraparound_pls_i = '1' then
				Wraparound_cnt_i <= std_logic_vector(unsigned(Wraparound_cnt_i) + 1 );
			end if;
		end if;
	end process;
	
	Wraparound_pls <= Wraparound_pls_i;
	Wraparound_cnt <= Wraparound_cnt_i;
    
	---- AXI write side output mapping -----------------------------------------
	-- Write address channel
	m_axi_awaddr	<= m_axi_awaddr_i;
	m_axi_awlen    	<= axlen;	-- Burst_Length = AxLEN[7:0] + 1
	m_axi_awsize   	<= axsize;	-- Burst_Size = 2 ^ AxSIZE[2:0]
	m_axi_awburst  	<= "01";  	-- Burst_Type: "00" = FIXED; "01" = INCR; "10" = WRAP
	m_axi_awcache  	<= "0011";	-- Memory_Attributes: AxCACHE[0] Bufferable
		                        --					  AxCACHE[1] Cacheable
		                        --					  AxCACHE[2] Read-allocate
		                        --					  AxCACHE[3] Write-allocate
	m_axi_awprot   	<= "010"; 	-- Access_Permissions: AxPROT[0] Privileged
		                        --					   AxPROT[1] Non-secure
		                        --					   AxPROT[2] Instruction
	m_axi_awlock   	<= '0';   	-- Atomic_Access: '0' Normal; '1' Exclusive
	m_axi_awqos    	<= "0000";	-- Quality_of_Service: Priority level
	m_axi_awvalid	<= m_axi_awvalid_i;
	
	-- Write data channel
	m_axi_wdata		<= m_axi_wdata_i;
	m_axi_wstrb		<= (others=>'1');
	m_axi_wlast		<= m_axi_wlast_i;
	m_axi_wvalid	<= m_axi_wvalid_i;

	-- Write response channel
    m_axi_bready   	<= '1';
	
	
	---------------------------------------------------------------------------------------
	-- AXI Read side
	---------------------------------------------------------------------------------------

	-- AXI Read FSM
	pAxiReadFsm : process(clk) is
	begin
		if rising_edge(clk) then
			ard_cycle_done <= '0';
			case ard_state is
				when ARD_START_NEW_CYCLE =>
					if MemTrafficGen_en = '1' then
						ard_state <= ARD_WAIT_BVALID;
					end if;
				when ARD_WAIT_BVALID =>
					if m_axi_bvalid = '1' then
						ard_state <= ARD_WRITE_ADDR;
					end if;
				when ARD_WRITE_ADDR =>
					m_axi_arvalid_i <= '1';
					if m_axi_arready='1' and m_axi_arvalid_i='1' then
						m_axi_arvalid_i	<= '0';
						ard_state    	<= ARD_READ_DATA;
					end if;
				when ARD_READ_DATA =>
					ard_cycle_done <= '1';
					ard_state 	   <= ARD_START_NEW_CYCLE;
			end case;
			if m_axi_resetn = '0' then
				m_axi_arvalid_i	<= '0';
				ard_state 	  	<= ARD_START_NEW_CYCLE;
			end if;
		end if;
	end process;
	
	pAxiReadAddress : process(clk) is
	begin
		if rising_edge(clk) then
			if ard_cycle_done = '1' then
				m_axi_araddr_i <= std_logic_vector(unsigned(m_axi_araddr_i) + 1024);
				if unsigned(m_axi_araddr_i) >= MEM_SIZE_BYTE - 1024 then
					m_axi_araddr_i <= (others=>'0');
				end if;
			end if;
			if m_axi_resetn = '0' then
				m_axi_araddr_i <= (others=>'0');
			end if;
		end if;
	end process;
	
	---- AXI read side output mapping -----------------------------------------
	-- Read address channel
	m_axi_araddr 	<= m_axi_araddr_i;
	m_axi_arlen 	<= axlen;	-- Burst_Length = AxLEN[7:0] + 1
	m_axi_arsize 	<= axsize;	-- Burst_Size = 2 ^ AxSIZE[2:0]
	m_axi_arburst 	<= "01";	-- Burst_Type: "00" = FIXED; "01" = INCR; "10" = WRAP
	m_axi_arcache 	<= "0011";	-- Memory_Attributes: AxCACHE[0] Bufferable
								--					  AxCACHE[1] Cacheable
								--					  AxCACHE[2] Read-allocate
								--					  AxCACHE[3] Write-allocate
	m_axi_arprot 	<= "010";	-- Access_Permissions: AxPROT[0] Privileged
								--					   AxPROT[1] Non-secure
								--					   AxPROT[2] Instruction
	m_axi_arlock 	<= '0';		-- Atomic_Access: '0' Normal; '1' Exclusive
	m_axi_arqos 	<= "0000";	-- Quality_of_Service: Priority level
	m_axi_arvalid 	<= m_axi_arvalid_i;
	
	-- Read data channel
	m_axi_rready 	<= '1';
    
end behav; 
