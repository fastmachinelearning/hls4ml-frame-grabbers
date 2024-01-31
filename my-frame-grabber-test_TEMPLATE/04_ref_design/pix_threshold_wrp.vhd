--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: pix_threshold_wrp
--    File: pix_threshold_wrp.vhd
--    Date: 2019-06-25
--     Rev: 0.3
--  Author: PP
--------------------------------------------------------------------------------
-- Reference Design: HLS Threshold
--   This module computes a threshold for all input pixels based on the threshold
--   level value.
--------------------------------------------------------------------------------
-- 0.1, 2019-03-06, XC, Initial release
-- 0.2, 2019-04-02, PP, Integrated into CustomLogic release package
-- 0.3, 2019-06-25, PP, Added USER_WIDTH generic
--                      Modified reset mechanism
--                      Removed Metadata record
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pix_threshold_wrp is
	generic (
		DATA_WIDTH 					: natural := 256;
		USER_WIDTH 					: natural := 4
	);
    port (
        -- Clock/Reset
		clk							: in  std_logic;	-- Clock 250 MHz
		srst						: in  std_logic;	-- Synchronous Reset (PCIe reset)
        -- Control
		HlsThreshold_bypass			: in  std_logic;	-- Bypass data and control
		HlsThreshold_level			: in  std_logic_vector(7 downto 0);	-- Threshold level
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
end entity pix_threshold_wrp;

architecture behav of pix_threshold_wrp is

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
	signal reset_n				: std_logic;
    signal reset_n_s   			: std_logic_vector(5 downto 0) := (others => '0');
	
	signal s_axis_tready_i		: std_logic;

    signal pixth_start   		: std_logic;
	signal pixth_tvalid			: std_logic;
	signal pixth_tready			: std_logic;
	signal pixth_tdata			: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal pixth_tuser			: std_logic_vector(USER_WIDTH - 1 downto 0);
	signal pixth_StreamId		: std_logic_vector( 7 downto 0);
	signal pixth_SourceTag		: std_logic_vector(15 downto 0);
	signal pixth_Xsize			: std_logic_vector(23 downto 0);
	signal pixth_Xoffs			: std_logic_vector(23 downto 0);
	signal pixth_Ysize			: std_logic_vector(23 downto 0);
	signal pixth_Yoffs			: std_logic_vector(23 downto 0);
	signal pixth_DsizeL			: std_logic_vector(23 downto 0);
	signal pixth_PixelF			: std_logic_vector(15 downto 0);
	signal pixth_TapG			: std_logic_vector(15 downto 0);
	signal pixth_Flags			: std_logic_vector( 7 downto 0);
	signal pixth_Timestamp		: std_logic_vector(31 downto 0);
	signal pixth_PixProcFlgs	: std_logic_vector( 7 downto 0);
	signal pixth_Status			: std_logic_vector(31 downto 0);

	
	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------
    -- attribute mark_debug : string;
    -- attribute mark_debug of HlsThreshold_level	: signal is "true";
    -- attribute mark_debug of pixth_tvalid			: signal is "true";


begin
	
	-- HLS Generated IP
	iPixThreshold : entity work.pix_threshold
        port map (
            ap_clk   						=> clk,
            ap_rst_n 						=> reset_n,
            ap_start 						=> pixth_start,
            ap_done  						=> open,
            ap_idle  						=> open,
            ap_ready 						=> open,
            threshold_value_V 				=> HlsThreshold_level,
            VideoIn_TDATA  					=> s_axis_tdata,
            VideoIn_TVALID 					=> s_axis_tvalid,
            VideoIn_TREADY 					=> s_axis_tready_i,
            VideoIn_TUSER  					=> s_axis_tuser,
            MetaIn_StreamId  				=> s_mdata_StreamId,
            MetaIn_StreamId_ap_vld 			=> s_axis_tvalid,
            MetaIn_SourceTag 				=> s_mdata_SourceTag,
            MetaIn_SourceTag_ap_vld 		=> s_axis_tvalid,
            MetaIn_Xsize_V   				=> s_mdata_Xsize,
            MetaIn_Xsize_V_ap_vld 			=> s_axis_tvalid,
            MetaIn_Xoffs_V   				=> s_mdata_Xoffs,
            MetaIn_Xoffs_V_ap_vld 			=> s_axis_tvalid,
            MetaIn_Ysize_V   				=> s_mdata_Ysize,
            MetaIn_Ysize_V_ap_vld 			=> s_axis_tvalid,
            MetaIn_Yoffs_V   				=> s_mdata_Yoffs,
            MetaIn_Yoffs_V_ap_vld 			=> s_axis_tvalid,
            MetaIn_DsizeL_V  				=> s_mdata_DsizeL,
            MetaIn_DsizeL_V_ap_vld 			=> s_axis_tvalid,
            MetaIn_PixelF    				=> s_mdata_PixelF,
            MetaIn_PixelF_ap_vld 			=> s_axis_tvalid,
            MetaIn_TapG      				=> s_mdata_TapG,
            MetaIn_TapG_ap_vld 				=> s_axis_tvalid,
            MetaIn_Flags     				=> s_mdata_Flags,
            MetaIn_Flags_ap_vld	 			=> s_axis_tvalid,
            MetaIn_Timestamp 				=> s_mdata_Timestamp,
            MetaIn_Timestamp_ap_vld 		=> s_axis_tvalid,
            MetaIn_PixProcessingFlgs 		=> s_mdata_PixProcFlgs,
            MetaIn_PixProcessingFlgs_ap_vld => s_axis_tvalid,
            MetaIn_ModPixelF 				=> (others=>'0'),
            MetaIn_ModPixelF_ap_vld 		=> s_axis_tvalid,
            MetaIn_Status    				=> s_mdata_Status,
            MetaIn_Status_ap_vld 			=> s_axis_tvalid,
            VideoOut_TDATA  				=> pixth_tdata,
            VideoOut_TVALID 				=> pixth_tvalid,
            VideoOut_TREADY 				=> pixth_tready,
            VideoOut_TUSER  				=> pixth_tuser,
            MetaOut_StreamId  				=> pixth_StreamId,
            MetaOut_SourceTag 				=> pixth_SourceTag,
            MetaOut_Xsize_V   				=> pixth_Xsize,
            MetaOut_Xoffs_V   				=> pixth_Xoffs,
            MetaOut_Ysize_V   				=> pixth_Ysize,
            MetaOut_Yoffs_V   				=> pixth_Yoffs,
            MetaOut_DsizeL_V  				=> pixth_DsizeL,
            MetaOut_PixelF    				=> pixth_PixelF,
            MetaOut_TapG      				=> pixth_TapG,
            MetaOut_Flags     				=> pixth_Flags,
            MetaOut_Timestamp 				=> pixth_Timestamp,
            MetaOut_PixProcessingFlgs 		=> pixth_PixProcFlgs,
            MetaOut_ModPixelF 				=> open,
            MetaOut_Status    				=> pixth_Status
        );   

	s_axis_tready 	<= m_axis_tready when HlsThreshold_bypass = '1' else s_axis_tready_i;
	pixth_tready 	<= m_axis_tready;
	
	-- Reset generation
    pReset : process(clk)
	begin
		if rising_edge(clk) then
			reset_n_s 	<= reset_n_s(4 downto 0) & '1';
			pixth_start <= reset_n_s(5);
			if srst='1' or s_axis_resetn='0' then
				reset_n_s 	<= (others=>'0');
				pixth_start <= '0';
			end if;
		end if;
	end process;
	reset_n <= reset_n_s(5);
	
	-- Output Bypass
    pBypass : process(clk)
	begin
		if rising_edge(clk) then
			if m_axis_tready = '1' then
				m_axis_tvalid	<= pixth_tvalid;
				m_axis_tuser	<= (others=>'0');
				if pixth_tvalid = '1' then
					m_axis_tdata <= pixth_tdata;
					m_axis_tuser <= pixth_tuser;
				end if;
				m_mdata_StreamId	<= pixth_StreamId;
				m_mdata_SourceTag	<= pixth_SourceTag;
				m_mdata_Xsize		<= pixth_Xsize;
				m_mdata_Xoffs		<= pixth_Xoffs;
				m_mdata_Ysize		<= pixth_Ysize;
				m_mdata_Yoffs		<= pixth_Yoffs;
				m_mdata_DsizeL		<= pixth_DsizeL;
				m_mdata_PixelF		<= pixth_PixelF;
				m_mdata_TapG		<= pixth_TapG;
				m_mdata_Flags		<= pixth_Flags;
				m_mdata_Timestamp	<= pixth_Timestamp;
				m_mdata_PixProcFlgs	<= pixth_PixProcFlgs;
				m_mdata_Status		<= pixth_Status;
				if HlsThreshold_bypass = '1' then
					m_axis_tvalid		<= s_axis_tvalid;
					m_axis_tdata		<= s_axis_tdata;
					m_axis_tuser		<= s_axis_tuser;
					m_mdata_StreamId	<= s_mdata_StreamId;
					m_mdata_SourceTag	<= s_mdata_SourceTag;
					m_mdata_Xsize		<= s_mdata_Xsize;
					m_mdata_Xoffs		<= s_mdata_Xoffs;
					m_mdata_Ysize		<= s_mdata_Ysize;
					m_mdata_Yoffs		<= s_mdata_Yoffs;
					m_mdata_DsizeL		<= s_mdata_DsizeL;
					m_mdata_PixelF		<= s_mdata_PixelF;
					m_mdata_TapG		<= s_mdata_TapG;
					m_mdata_Flags		<= s_mdata_Flags;
					m_mdata_Timestamp	<= s_mdata_Timestamp;
					m_mdata_PixProcFlgs	<= s_mdata_PixProcFlgs;
					m_mdata_Status		<= s_mdata_Status;
				end if;
			end if;
			if reset_n = '0' then
				m_axis_tvalid	<= '0';
			end if;
		end if;
	end process;

end behav;
