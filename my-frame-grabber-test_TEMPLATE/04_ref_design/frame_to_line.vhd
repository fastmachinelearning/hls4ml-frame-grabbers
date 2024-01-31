--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: frame_to_line
--    File: frame_to_line.vhd
--    Date: 2019-06-25
--     Rev: 0.2
--  Author: PP
--------------------------------------------------------------------------------
-- Reference Design: Frame to Line converter
--   This module outputs one line from each input frame. The line index increments
--   for each input frame. The size of the resulting frame is equivalent to the
--   size of the input frame.
--------------------------------------------------------------------------------
-- 0.1, 2018-01-26, PP, Initial release
-- 0.2, 2019-06-25, PP, Added USER_WIDTH generic
--                      Modified reset mechanism
--                      Removed Metadata record
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_to_line is
	generic (
		DATA_WIDTH 					: natural := 256;
		USER_WIDTH 					: natural := 4
	);
	port (
		-- Clock/Reset
		clk			 				: in  std_logic;	-- Clock 250 MHz
		srst						: in  std_logic;	-- Synchronous Reset (PCIe reset)
		-- Control
		Frame2Line_bypass			: in  std_logic;
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
end entity frame_to_line;

architecture behav of frame_to_line is

	----------------------------------------------------------------------------
	-- Constants
	----------------------------------------------------------------------------

    
	----------------------------------------------------------------------------
	-- Types
	----------------------------------------------------------------------------


	----------------------------------------------------------------------------
	-- Functions
	----------------------------------------------------------------------------

    
	----------------------------------------------------------------------------
	-- Components
	----------------------------------------------------------------------------
	
	
	----------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------
    -- Global Reset
	signal reset				: std_logic;
	
    -- TUSER decoding
	signal s_axis_tuser_sof		: std_logic;
	signal s_axis_tuser_sol		: std_logic;
	signal s_axis_tuser_eol		: std_logic;
	signal s_axis_tuser_eof		: std_logic;
	
	-- Frame and Line Counters
	signal input_line_cnt		: std_logic_vector(23 downto 0);
	signal input_frame_cnt		: std_logic_vector(31 downto 0);
	signal output_frame_cnt		: std_logic_vector(23 downto 0);

	---- Pipeline Stage 0 ------------------------------------------------------
	-- Video Stream Pipeline
	signal s0_axis_tvalid		: std_logic;
	signal s0_axis_tdata		: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal s0_axis_tuser		: std_logic_vector(USER_WIDTH - 1 downto 0);
	signal s0_axis_tuser_sol	: std_logic;
	signal s0_axis_tuser_eol	: std_logic;
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

	-- Line Selector
	signal s0_output_line_en	: std_logic;

	-- Output Frame Flags
	signal s0_output_sof		: std_logic;
	signal s0_output_eof		: std_logic;
	
	---- Pipeline Stage 1 ------------------------------------------------------
	-- Video Stream Pipeline
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

	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------    
	-- attribute mark_debug : string;
    -- attribute mark_debug of s_axis_tuser_sof	: signal is "true";
    -- attribute mark_debug of s_axis_tuser_eof	: signal is "true";
   
    
begin
    
    ---- Global Reset ----------------------------------------------------------
	reset <= not s_axis_resetn or srst;
	
    ---- TUSER decoding --------------------------------------------------------
	s_axis_tuser_sof <= s_axis_tuser(0);
	s_axis_tuser_sol <= s_axis_tuser(1);
	s_axis_tuser_eol <= s_axis_tuser(2);
	s_axis_tuser_eof <= s_axis_tuser(3);
	
	---- Frame and Line Counters -----------------------------------------------
    pCounters : process(clk) is
	begin
		if rising_edge(clk) then
			if m_axis_tready='1' and s_axis_tvalid='1' and s_axis_tuser_eol='1' then
				input_line_cnt <= std_logic_vector(unsigned(input_line_cnt) + 1);
			end if;
			if m_axis_tready='1' and s_axis_tvalid='1' and s_axis_tuser_eof='1' then
				input_line_cnt  	<= (others=>'0');
				input_frame_cnt		<= std_logic_vector(unsigned(input_frame_cnt) + 1);
				output_frame_cnt	<= std_logic_vector(unsigned(output_frame_cnt) + 1);
				if unsigned(output_frame_cnt) = unsigned(s0_Ysize) - 1 then
					output_frame_cnt <= (others=>'0');
				end if;
			end if;
			if reset = '1' then
				input_line_cnt  	<= (others=>'0');
				input_frame_cnt		<= (others=>'0');
				output_frame_cnt 	<= (others=>'0');
			end if;
		end if;
	end process;
	
	----------------------------------------------------------------------------
	-- Pipeline Stage 0
	----------------------------------------------------------------------------
	---- Video Stream Pipeline -------------------------------------------------
	pStreamPipeline_s0 : process(clk) is
	begin
		if rising_edge(clk) then
			if m_axis_tready='1' then
				s0_axis_tvalid	<= s_axis_tvalid;
				s0_axis_tdata	<= s_axis_tdata;
				s0_axis_tuser	<= s_axis_tuser;
				-- Latch Image Header
				if s_axis_tvalid='1' and s_axis_tuser_sof='1' then
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
				end if;
			end if;
			if reset = '1' then
				s0_axis_tvalid <= '0';
			end if;
		end if;
	end process;
	
	---- Line Selector ---------------------------------------------------------
	pLineSelector_s0 : process(clk) is
	begin
		if rising_edge(clk) then
			if m_axis_tready='1' and s0_axis_tvalid='1' and s0_axis_tuser_eol='1' then
				s0_output_line_en <= '0';
			end if;
			if m_axis_tready='1' and s_axis_tvalid='1' and s_axis_tuser_sol='1' then
				if output_frame_cnt = input_line_cnt then
					s0_output_line_en <= '1';
				end if;
			end if;
			if reset = '1' then
				s0_output_line_en <= '0';
			end if;
		end if;
	end process;
	
	s0_axis_tuser_sol <= s0_axis_tuser(1);
	s0_axis_tuser_eol <= s0_axis_tuser(2);
	
	---- Output Frame Flags ----------------------------------------------------
	pOutputFrameFlags_s0 : Process(clk) is
	begin
		if rising_edge(clk) then
			if m_axis_tready='1' and s0_axis_tvalid='1' and s0_axis_tuser_sol='1' then
				if unsigned(output_frame_cnt) = 0 then
					s0_output_sof <= '0';
				end if;
			end if;
			if m_axis_tready='1' and s_axis_tvalid='1' and s_axis_tuser_eol='1' then
				if (unsigned(output_frame_cnt) = unsigned(s0_Ysize) - 1) and
				   (unsigned(input_line_cnt)  = unsigned(s0_Ysize) - 1) then
						s0_output_eof <= '1';
				end if;
			end if;
			if m_axis_tready='1' and s0_axis_tvalid='1' and s0_axis_tuser_eol='1' and s0_output_eof = '1' then
				s0_output_eof <= '0';
				s0_output_sof <= '1';
			end if;
			if reset = '1' then
				s0_output_sof <= '1';
				s0_output_eof <= '0';
			end if;
		end if;
	end process;
	
	----------------------------------------------------------------------------
	-- Pipeline Stage 1
	----------------------------------------------------------------------------
	---- Video Stream Pipeline -------------------------------------------------
	pStreamPipeline_s1 : process(clk) is
	begin
		if rising_edge(clk) then
			if m_axis_tready='1' then
				s1_axis_tvalid		<= s0_axis_tvalid and s0_output_line_en;
				s1_axis_tdata		<= s0_axis_tdata;
				s1_axis_tuser(0)	<= s0_output_sof;
				s1_axis_tuser(1)	<= s0_axis_tuser_sol;
				s1_axis_tuser(2)	<= s0_axis_tuser_eol;
				s1_axis_tuser(3)	<= s0_output_eof;
				s1_StreamId			<= s0_StreamId;
                s1_SourceTag		<= s0_SourceTag;
	            s1_Xsize			<= s0_Xsize;
	            s1_Xoffs			<= s0_Xoffs;
	            s1_Ysize			<= s0_Ysize;
                s1_Yoffs			<= s0_Yoffs;
                s1_DsizeL			<= s0_DsizeL;
                s1_PixelF			<= s0_PixelF;
                s1_TapG				<= s0_TapG;
	            s1_Flags			<= s0_Flags;
				s1_Timestamp		<= s0_Timestamp;
				s1_PixProcFlgs		<= s0_PixProcFlgs;
				s1_Status			<= input_frame_cnt;
				if Frame2Line_bypass = '1' then
					s1_axis_tvalid 	<= s0_axis_tvalid;
					s1_axis_tuser	<= s0_axis_tuser;
				end if;
			end if;
			if reset = '1' then
				s1_axis_tvalid <= '0';
			end if;
		end if;
	end process;
	
	----------------------------------------------------------------------------
	-- Output Mapping
	----------------------------------------------------------------------------
	m_axis_tvalid				<= s1_axis_tvalid;
	s_axis_tready				<= m_axis_tready;
	m_axis_tdata				<= s1_axis_tdata;
	m_axis_tuser				<= s1_axis_tuser;
	m_mdata_StreamId			<= s1_StreamId;
	m_mdata_SourceTag			<= s1_SourceTag;
	m_mdata_Xsize				<= s1_Xsize;
	m_mdata_Xoffs				<= s1_Xoffs;
	m_mdata_Ysize				<= s1_Ysize;
	m_mdata_Yoffs				<= s1_Yoffs;
	m_mdata_DsizeL				<= s1_DsizeL;
	m_mdata_PixelF				<= s1_PixelF;
	m_mdata_TapG				<= s1_TapG;
	m_mdata_Flags				<= s1_Flags;
	m_mdata_Timestamp			<= s1_Timestamp;
	m_mdata_PixProcFlgs			<= s1_PixProcFlgs;
	m_mdata_Status				<= s1_Status;

end behav; 
