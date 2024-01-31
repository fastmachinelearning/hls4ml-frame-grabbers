--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: pix_lut8b
--    File: pix_lut8b.vhd
--    Date: 2019-06-25
--     Rev: 0.2
--  Author: PP
--------------------------------------------------------------------------------
-- Reference Design: Pixel LUT 8-bit
--   This module provides lookup table capabilities to compute gamma correction,
--   thresholding, inversion, etc. 
--------------------------------------------------------------------------------
-- 0.1, 2019-03-06, PP, Initial release
-- 0.2, 2019-06-25, PP, Added USER_WIDTH generic
--                      Modified reset mechanism
--                      Removed Metadata record
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pix_lut8b is
	generic (
		DATA_WIDTH					: natural := 256;
		USER_WIDTH					: natural := 4
	);
	port (
		-- Clock/Reset
		clk			 				: in  std_logic;	-- Clock 250 MHz
		srst						: in  std_logic;	-- Synchronous Reset (PCIe reset)
        -- Control
		PixelLut_bypass				: in  std_logic;
		PixelLut_coef_start			: in  std_logic;
		PixelLut_coef				: in  std_logic_vector(7 downto 0);
		PixelLut_coef_vld			: in  std_logic;
		PixelLut_coef_done			: out std_logic;
		-- AXI Stream Slave Interface
		s_axis_resetn				: in  std_logic;	-- AXI Stream Interface reset
		s_axis_tvalid				: in  std_logic;
		s_axis_tready				: out std_logic;
		s_axis_tdata				: in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		s_axis_tuser				: in  std_logic_vector(USER_WIDTH - 1 downto 0);
		-- Metadata Slave Interface
		s_mdata_StreamId			: in  std_logic_vector( 7 downto 0);
		s_mdata_SourceTag			: in  std_logic_vector(15 downto 0);
		s_mdata_Xsize				: in  std_logic_vector(23 downto 0);
		s_mdata_Xoffs				: in  std_logic_vector(23 downto 0);
		s_mdata_Ysize				: in  std_logic_vector(23 downto 0);
		s_mdata_Yoffs				: in  std_logic_vector(23 downto 0);
		s_mdata_DsizeL				: in  std_logic_vector(23 downto 0);
		s_mdata_PixelF				: in  std_logic_vector(15 downto 0);
		s_mdata_TapG				: in  std_logic_vector(15 downto 0);
		s_mdata_Flags				: in  std_logic_vector( 7 downto 0);
		s_mdata_Timestamp			: in  std_logic_vector(31 downto 0);
		s_mdata_PixProcFlgs			: in  std_logic_vector( 7 downto 0);
		s_mdata_Status				: in  std_logic_vector(31 downto 0);
		-- AXI Stream Master Interface
		m_axis_tvalid				: out std_logic;
		m_axis_tready				: in  std_logic;
		m_axis_tdata				: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		m_axis_tuser				: out std_logic_vector(USER_WIDTH - 1 downto 0);
		-- Metadata Master Interface
		m_mdata_StreamId			: out std_logic_vector( 7 downto 0);
		m_mdata_SourceTag			: out std_logic_vector(15 downto 0);
		m_mdata_Xsize				: out std_logic_vector(23 downto 0);
		m_mdata_Xoffs				: out std_logic_vector(23 downto 0);
		m_mdata_Ysize				: out std_logic_vector(23 downto 0);
		m_mdata_Yoffs				: out std_logic_vector(23 downto 0);
		m_mdata_DsizeL				: out std_logic_vector(23 downto 0);
		m_mdata_PixelF				: out std_logic_vector(15 downto 0);
		m_mdata_TapG				: out std_logic_vector(15 downto 0);
		m_mdata_Flags				: out std_logic_vector( 7 downto 0);
		m_mdata_Timestamp			: out std_logic_vector(31 downto 0);
		m_mdata_PixProcFlgs			: out std_logic_vector( 7 downto 0);
		m_mdata_Status				: out std_logic_vector(31 downto 0)
	);
end entity pix_lut8b;

architecture behav of pix_lut8b is

	----------------------------------------------------------------------------
	-- Constants
	----------------------------------------------------------------------------
	constant PIXEL_WIDTH 	: natural := 8;
	constant NB_OF_PIXELS 	: natural := DATA_WIDTH / PIXEL_WIDTH;

    
	----------------------------------------------------------------------------
	-- Types
	----------------------------------------------------------------------------
	type pixel_a_type is array (natural range <>) of std_logic_vector(PIXEL_WIDTH - 1 downto 0);

	----------------------------------------------------------------------------
	-- Functions
	----------------------------------------------------------------------------

    
	----------------------------------------------------------------------------
	-- Components
	----------------------------------------------------------------------------
	COMPONENT lut_bram_8x256
		PORT (
			clka 	: IN  STD_LOGIC;
			wea 	: IN  STD_LOGIC_VECTOR(0 downto 0);
			addra 	: IN  STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 downto 0);
			dina 	: IN  STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 downto 0);
			clkb 	: IN  STD_LOGIC;
			enb 	: IN  STD_LOGIC;
			addrb 	: IN  STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 downto 0);
			doutb 	: OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 downto 0)
		);
	END COMPONENT;
	
	
	----------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------
	-- Lookup Table
	signal lut_bram_wea			: std_logic_vector(0 downto 0);
	signal lut_bram_addra		: std_logic_vector(PIXEL_WIDTH - 1 downto 0);
	signal lut_bram_dina		: std_logic_vector(PIXEL_WIDTH - 1 downto 0);
	signal lut_bram_enb			: std_logic;
	signal lut_bram_addrb		: pixel_a_type(NB_OF_PIXELS - 1 downto 0);
	signal lut_bram_doutb		: pixel_a_type(NB_OF_PIXELS - 1 downto 0);
	signal lut_bram_ready		: std_logic;
	signal lut_bram_done		: std_logic;
    
	-- Vector to Array
	signal s_axis_tdata_a		: pixel_a_type(NB_OF_PIXELS - 1 downto 0);
	
	-- Video Stream Pipeline (compensate BRAM latency)
	signal s0_axis_tvalid		: std_logic;
	signal s0_axis_tuser		: std_logic_vector(USER_WIDTH - 1 downto 0);
	signal s0_StreamId			: std_logic_vector( 7 downto 0);
	signal s0_SourceTag			: std_logic_vector(15 downto 0);
	signal s0_Xsize				: std_logic_vector(23 downto 0);
	signal s0_Xoffs				: std_logic_vector(23 downto 0);
	signal s0_Ysize				: std_logic_vector(23 downto 0);
	signal s0_Yoffs				: std_logic_vector(23 downto 0);
	signal s0_DsizeL			: std_logic_vector(23 downto 0);
	signal s0_PixelF			: std_logic_vector(15 downto 0);
	signal s0_TapG				: std_logic_vector(15 downto 0);
	signal s0_Flags				: std_logic_vector( 7 downto 0);
	signal s0_Timestamp			: std_logic_vector(31 downto 0);
	signal s0_PixProcFlgs		: std_logic_vector( 7 downto 0);
	signal s0_Status			: std_logic_vector(31 downto 0);
	signal s1_axis_tvalid		: std_logic;
	signal s1_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal s1_axis_tuser		: std_logic_vector(USER_WIDTH - 1 downto 0);
	signal s1_StreamId			: std_logic_vector( 7 downto 0);
	signal s1_SourceTag			: std_logic_vector(15 downto 0);
	signal s1_Xsize				: std_logic_vector(23 downto 0);
	signal s1_Xoffs				: std_logic_vector(23 downto 0);
	signal s1_Ysize				: std_logic_vector(23 downto 0);
	signal s1_Yoffs				: std_logic_vector(23 downto 0);
	signal s1_DsizeL			: std_logic_vector(23 downto 0);
	signal s1_PixelF			: std_logic_vector(15 downto 0);
	signal s1_TapG				: std_logic_vector(15 downto 0);
	signal s1_Flags				: std_logic_vector( 7 downto 0);
	signal s1_Timestamp			: std_logic_vector(31 downto 0);
	signal s1_PixProcFlgs		: std_logic_vector( 7 downto 0);
	signal s1_Status			: std_logic_vector(31 downto 0);
	
	-- Video Stream Pipeline (bypass)
	signal s2_axis_tvalid		: std_logic;
	signal s2_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal s2_axis_tuser		: std_logic_vector(USER_WIDTH - 1 downto 0);
	signal s2_StreamId			: std_logic_vector( 7 downto 0);
	signal s2_SourceTag			: std_logic_vector(15 downto 0);
	signal s2_Xsize				: std_logic_vector(23 downto 0);
	signal s2_Xoffs				: std_logic_vector(23 downto 0);
	signal s2_Ysize				: std_logic_vector(23 downto 0);
	signal s2_Yoffs				: std_logic_vector(23 downto 0);
	signal s2_DsizeL			: std_logic_vector(23 downto 0);
	signal s2_PixelF			: std_logic_vector(15 downto 0);
	signal s2_TapG				: std_logic_vector(15 downto 0);
	signal s2_Flags				: std_logic_vector( 7 downto 0);
	signal s2_Timestamp			: std_logic_vector(31 downto 0);
	signal s2_PixProcFlgs		: std_logic_vector( 7 downto 0);
	signal s2_Status			: std_logic_vector(31 downto 0);
	

	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------
    -- attribute mark_debug : string;
    -- attribute mark_debug of lut_bram_ready	: signal is "true";
    -- attribute mark_debug of lut_bram_done	: signal is "true";
   
    
begin
	
    ---- Lookup Table Control --------------------------------------------------
    pLutBramWrite : process(clk) is
	begin
		if rising_edge(clk) then
			if PixelLut_coef_start = '1' then
				lut_bram_addra 	<= (others=>'0');
				lut_bram_ready	<= '1';
				lut_bram_done  	<= '0';
			end if;
			if lut_bram_ready='1' and PixelLut_coef_vld='1' then
				lut_bram_addra <= std_logic_vector(unsigned(lut_bram_addra) + 1);
				if lut_bram_addra = x"FF" then
					lut_bram_ready <= '0';
					lut_bram_done  <= '1';
				end if;
			end if;
			if srst = '1' then
				lut_bram_ready  <= '0';
				lut_bram_done  	<= '0';
			end if;
		end if;
	end process;	
	
	lut_bram_wea(0)		<= PixelLut_coef_vld and lut_bram_ready;
	lut_bram_dina		<= PixelLut_coef;
	PixelLut_coef_done	<= lut_bram_done;

    ---- Lookup Table BRAM -----------------------------------------------------
    pInputVector2Array : process(s_axis_tdata) is
	begin
		for n in 0 to NB_OF_PIXELS - 1 loop
			s_axis_tdata_a(n) <= s_axis_tdata(PIXEL_WIDTH*(n + 1) - 1 downto PIXEL_WIDTH * n);
		end loop;
	end process;
	
	lut_bram_enb	<= m_axis_tready;
	lut_bram_addrb 	<= s_axis_tdata_a;
	
	gLutBram : for n in 0 to NB_OF_PIXELS - 1 generate
		iLutBram : lut_bram_8x256
		port map (
			clka 	=> clk,
			wea 	=> lut_bram_wea,
			addra 	=> lut_bram_addra,
			dina 	=> lut_bram_dina,
			clkb 	=> clk,
			enb 	=> lut_bram_enb,
			addrb 	=> lut_bram_addrb(n),
			doutb 	=> lut_bram_doutb(n)
		);
	end generate;
	
    pOutputArray2Vector : process(lut_bram_doutb) is
	begin
		for n in 0 to NB_OF_PIXELS - 1 loop
			s1_axis_tdata(PIXEL_WIDTH*(n + 1) - 1 downto PIXEL_WIDTH * n) <= lut_bram_doutb(n);
		end loop;
	end process;
	
	-- Compensate BRAM latency
    pLutBramLatency : process(clk) is
	begin
		if rising_edge(clk) then
			if m_axis_tready = '1' then
				-- Stage 0
				s0_axis_tvalid 	<= s_axis_tvalid;
				s0_axis_tuser	<= s_axis_tuser;
				s0_StreamId		<= s_mdata_StreamId;
				s0_SourceTag	<= s_mdata_SourceTag;
				s0_Xsize		<= s_mdata_Xsize;
				s0_Xoffs		<= s_mdata_Xoffs;
				s0_Ysize		<= s_mdata_Ysize;
				s0_Yoffs		<= s_mdata_Yoffs;
				s0_DsizeL		<= s_mdata_DsizeL;
				s0_PixelF		<= s_mdata_PixelF;
				s0_TapG			<= s_mdata_TapG;
				s0_Flags		<= s_mdata_Flags;
				s0_Timestamp	<= s_mdata_Timestamp;
				s0_PixProcFlgs	<= s_mdata_PixProcFlgs;
				s0_Status		<= s_mdata_Status;
				
				--Stage 1
				s1_axis_tvalid 	<= s0_axis_tvalid;
				s1_axis_tuser	<= s0_axis_tuser;
				s1_StreamId		<= s0_StreamId;
                s1_SourceTag	<= s0_SourceTag;
	            s1_Xsize		<= s0_Xsize;
	            s1_Xoffs		<= s0_Xoffs;
	            s1_Ysize		<= s0_Ysize;
                s1_Yoffs		<= s0_Yoffs;
                s1_DsizeL		<= s0_DsizeL;
                s1_PixelF		<= s0_PixelF;
                s1_TapG			<= s0_TapG;
	            s1_Flags		<= s0_Flags;
				s1_Timestamp	<= s0_Timestamp;
				s1_PixProcFlgs	<= s0_PixProcFlgs;
				s1_Status		<= s0_Status;
			end if;
			if s_axis_resetn = '0' then
				s0_axis_tvalid  <= '0';
				s1_axis_tvalid 	<= '0';
			end if;
		end if;
	end process;
	
	-- Bypass
    pLutBramBypass : process(clk) is
	begin
		if rising_edge(clk) then
			if m_axis_tready = '1' then
				s2_axis_tvalid 	<= s1_axis_tvalid;
				s2_axis_tdata	<= s1_axis_tdata;
				s2_axis_tuser	<= s1_axis_tuser;
				s2_StreamId		<= s1_StreamId;
                s2_SourceTag	<= s1_SourceTag;
	            s2_Xsize		<= s1_Xsize;
	            s2_Xoffs		<= s1_Xoffs;
	            s2_Ysize		<= s1_Ysize;
                s2_Yoffs		<= s1_Yoffs;
                s2_DsizeL		<= s1_DsizeL;
                s2_PixelF		<= s1_PixelF;
                s2_TapG			<= s1_TapG;
	            s2_Flags		<= s1_Flags;
				s2_Timestamp	<= s1_Timestamp;
				s2_PixProcFlgs	<= s1_PixProcFlgs;
				s2_Status		<= s1_Status;
				if PixelLut_bypass = '1' then
					s2_axis_tvalid 	<= s_axis_tvalid;
					s2_axis_tdata	<= s_axis_tdata;
					s2_axis_tuser	<= s_axis_tuser;
					s2_StreamId		<= s_mdata_StreamId;
					s2_SourceTag	<= s_mdata_SourceTag;
					s2_Xsize		<= s_mdata_Xsize;
					s2_Xoffs		<= s_mdata_Xoffs;
					s2_Ysize		<= s_mdata_Ysize;
					s2_Yoffs		<= s_mdata_Yoffs;
					s2_DsizeL		<= s_mdata_DsizeL;
					s2_PixelF		<= s_mdata_PixelF;
					s2_TapG			<= s_mdata_TapG;
					s2_Flags		<= s_mdata_Flags;
					s2_Timestamp	<= s_mdata_Timestamp;
					s2_PixProcFlgs	<= s_mdata_PixProcFlgs;
					s2_Status		<= s_mdata_Status;
				end if;
			end if;
			if s_axis_resetn = '0' then
				s2_axis_tvalid  <= '0';
			end if;
		end if;
	end process;
	
	----------------------------------------------------------------------------
	-- Output Mapping
	----------------------------------------------------------------------------
	m_axis_tvalid				<= s2_axis_tvalid;
	s_axis_tready				<= m_axis_tready;
	m_axis_tdata				<= s2_axis_tdata;
	m_axis_tuser				<= s2_axis_tuser;
	m_mdata_StreamId			<= s2_StreamId;
	m_mdata_SourceTag			<= s2_SourceTag;
	m_mdata_Xsize				<= s2_Xsize;
	m_mdata_Xoffs				<= s2_Xoffs;
	m_mdata_Ysize				<= s2_Ysize;
	m_mdata_Yoffs				<= s2_Yoffs;
	m_mdata_DsizeL				<= s2_DsizeL;
	m_mdata_PixelF				<= s2_PixelF;
	m_mdata_TapG				<= s2_TapG;
	m_mdata_Flags				<= s2_Flags;
	m_mdata_Timestamp			<= s2_Timestamp;
	m_mdata_PixProcFlgs			<= s2_PixProcFlgs;
	m_mdata_Status				<= s2_Status;

end behav; 
