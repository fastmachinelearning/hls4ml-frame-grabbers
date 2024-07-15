--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: tb_top
--    File: tb_top.vhd
--    Date: 2023-03-07
--     Rev: 0.4
--  Author: PP
--------------------------------------------------------------------------------
-- CustomLogic testbench - Top level
--------------------------------------------------------------------------------
-- 0.1, 2019-08-21, PP, Initial release
-- 0.2, 2019-10-24, PP, Added General Purpose I/O Interface
-- 0.3, 2021-03-05, PP, Added *mem_base and *mem_size ports into the On-Board
--                      Memory interface
-- 0.4, 2023-03-07, MH, Added CustomLogic output control
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- NOTE: THIS FILE SHALL NOT BE MODIFIED.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CustomLogic_tb_pkg.all;
use work.SimulationCtrl_tb_pkg.all;

entity tb_top is
end entity tb_top;

architecture behav of tb_top is

	----------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------
	---- CustomLogic Common Interfaces -----------------------------------------
	-- Clock/Reset
	signal clk250						: std_logic;	-- Clock 250 MHz
	signal srst250						: std_logic; 	-- Global reset (PCIe reset)
	-- General Purpose I/O Interface
	signal user_output_ctrl				: std_logic_vector( 15 downto 0);
	signal user_output_status			: std_logic_vector(  7 downto 0);
	signal standard_io_set1_status		: std_logic_vector(  9 downto 0);
	signal standard_io_set2_status		: std_logic_vector(  9 downto 0);
	signal module_io_set_status			: std_logic_vector( 39 downto 0);
	signal qdc1_position_status			: std_logic_vector( 31 downto 0);
	signal qdc2_position_status			: std_logic_vector( 31 downto 0);
	signal qdc3_position_status			: std_logic_vector( 31 downto 0);
	signal qdc4_position_status			: std_logic_vector( 31 downto 0);
	signal custom_logic_output_ctrl		: std_logic_vector( 31 downto 0);
	signal reserved						: std_logic_vector(511 downto 0);
	-- Control Slave Interface
	signal s_ctrl_addr					: std_logic_vector( 15 downto 0);
	signal s_ctrl_data_wr_en			: std_logic;
	signal s_ctrl_data_wr				: std_logic_vector( 31 downto 0);
	signal s_ctrl_data_rd				: std_logic_vector( 31 downto 0);
    -- On-Board Memory - Parameters
	signal onboard_mem_base				: std_logic_vector( 31 downto 0);
	signal onboard_mem_size				: std_logic_vector( 31 downto 0);
    -- On-Board Memory - AXI 4 Master Interface
	signal m_axi_resetn 				: std_logic;	-- AXI 4 Interface reset
	signal m_axi_awaddr 				: std_logic_vector( 31 downto 0);
	signal m_axi_awlen 					: std_logic_vector(  7 downto 0);
	signal m_axi_awsize 				: std_logic_vector(  2 downto 0);
	signal m_axi_awburst 				: std_logic_vector(  1 downto 0);
	signal m_axi_awlock 				: std_logic;
	signal m_axi_awcache 				: std_logic_vector(  3 downto 0);
	signal m_axi_awprot 				: std_logic_vector(  2 downto 0);
	signal m_axi_awqos 					: std_logic_vector(  3 downto 0);
	signal m_axi_awvalid 				: std_logic;
	signal m_axi_awready 				: std_logic;
	signal m_axi_wdata 					: std_logic_vector(MEMORY_DATA_WIDTH   - 1 downto 0);
	signal m_axi_wstrb 					: std_logic_vector(MEMORY_DATA_WIDTH/8 - 1 downto 0);
	signal m_axi_wlast 					: std_logic;
	signal m_axi_wvalid 				: std_logic;
	signal m_axi_wready 				: std_logic;
	signal m_axi_bresp 					: std_logic_vector(  1 downto 0);
	signal m_axi_bvalid 				: std_logic;
	signal m_axi_bready 				: std_logic;
	signal m_axi_araddr 				: std_logic_vector( 31 downto 0);
	signal m_axi_arlen 					: std_logic_vector(  7 downto 0);
	signal m_axi_arsize 				: std_logic_vector(  2 downto 0);
	signal m_axi_arburst 				: std_logic_vector(  1 downto 0);
	signal m_axi_arlock 				: std_logic;
	signal m_axi_arcache 				: std_logic_vector(  3 downto 0);
	signal m_axi_arprot 				: std_logic_vector(  2 downto 0);
	signal m_axi_arqos 					: std_logic_vector(  3 downto 0);
	signal m_axi_arvalid 				: std_logic;
	signal m_axi_arready 				: std_logic;
	signal m_axi_rdata 					: std_logic_vector(MEMORY_DATA_WIDTH - 1 downto 0);
	signal m_axi_rresp 					: std_logic_vector(  1 downto 0);
	signal m_axi_rlast 					: std_logic;
	signal m_axi_rvalid 				: std_logic;
	signal m_axi_rready 				: std_logic;
	---- CustomLogic Device/Channel Interfaces ---------------------------------
    -- AXI Stream Slave Interface
	signal s_axis_resetn				: std_logic_vector(NB_OF_DEVICES    - 1 downto 0);	-- AXI Stream Interface reset
	signal s_axis_tvalid				: std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
	signal s_axis_tready				: std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
	signal s_axis_tdata					: std_logic_vector(NB_OF_DEVICES*STREAM_DATA_WIDTH - 1 downto 0);
	signal s_axis_tuser					: std_logic_vector(NB_OF_DEVICES*4 	- 1 downto 0);
    -- Metadata Slave Interface
	signal s_mdata_StreamId				: std_logic_vector(NB_OF_DEVICES*8  - 1 downto 0);
	signal s_mdata_SourceTag			: std_logic_vector(NB_OF_DEVICES*16 - 1 downto 0);
	signal s_mdata_Xsize				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal s_mdata_Xoffs				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal s_mdata_Ysize				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal s_mdata_Yoffs				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal s_mdata_DsizeL				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal s_mdata_PixelF				: std_logic_vector(NB_OF_DEVICES*16 - 1 downto 0);
	signal s_mdata_TapG					: std_logic_vector(NB_OF_DEVICES*16 - 1 downto 0);
	signal s_mdata_Flags				: std_logic_vector(NB_OF_DEVICES*8  - 1 downto 0);
	signal s_mdata_Timestamp			: std_logic_vector(NB_OF_DEVICES*32 - 1 downto 0);
	signal s_mdata_PixProcFlgs			: std_logic_vector(NB_OF_DEVICES*8  - 1 downto 0);
	signal s_mdata_Status				: std_logic_vector(NB_OF_DEVICES*32 - 1 downto 0);
    -- AXI Stream Master Interface
	signal m_axis_tvalid				: std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
	signal m_axis_tready				: std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
	signal m_axis_tdata					: std_logic_vector(NB_OF_DEVICES*STREAM_DATA_WIDTH - 1 downto 0);
	signal m_axis_tuser					: std_logic_vector(NB_OF_DEVICES*4 	- 1 downto 0);
    -- Metadata Master Interface
	signal m_mdata_StreamId				: std_logic_vector(NB_OF_DEVICES*8  - 1 downto 0);
	signal m_mdata_SourceTag			: std_logic_vector(NB_OF_DEVICES*16 - 1 downto 0);
	signal m_mdata_Xsize				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal m_mdata_Xoffs				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal m_mdata_Ysize				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal m_mdata_Yoffs				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal m_mdata_DsizeL				: std_logic_vector(NB_OF_DEVICES*24 - 1 downto 0);
	signal m_mdata_PixelF				: std_logic_vector(NB_OF_DEVICES*16 - 1 downto 0);
	signal m_mdata_TapG					: std_logic_vector(NB_OF_DEVICES*16 - 1 downto 0);
	signal m_mdata_Flags				: std_logic_vector(NB_OF_DEVICES*8  - 1 downto 0);
	signal m_mdata_Timestamp			: std_logic_vector(NB_OF_DEVICES*32 - 1 downto 0);
	signal m_mdata_PixProcFlgs			: std_logic_vector(NB_OF_DEVICES*8  - 1 downto 0);
	signal m_mdata_Status				: std_logic_vector(NB_OF_DEVICES*32 - 1 downto 0);
    -- Memento Master Interface
	signal m_memento_event				: std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
	signal m_memento_arg0				: std_logic_vector(NB_OF_DEVICES*32 - 1 downto 0);
	signal m_memento_arg1				: std_logic_vector(NB_OF_DEVICES*32 - 1 downto 0);
	-- Simulation Control/Status
	signal cxl_status      				: cxl_status_type_a	(NB_OF_DEVICES    - 1 downto 0);
	signal cxl_ctrl						: cxl_ctrl_type_a	(NB_OF_DEVICES    - 1 downto 0);
	signal cxl_onboard_mem				: cxl_onboard_mem_type;

	
begin
	
	iSimulationCtrl_tb : entity work.SimulationCtrl_tb
		generic map (
			CL_NB_OF_DEVICES	=> NB_OF_DEVICES
		)
		port map (
			clk			=> clk250,
			status  	=> cxl_status,
			ctrl		=> cxl_ctrl,
			onboard_mem	=> cxl_onboard_mem
		);
	
	iCoaxlinkCore : entity work.CoaxlinkCore_tb
		generic map (
			CL_STREAM_DATA_WIDTH		=> STREAM_DATA_WIDTH,
			CL_MEMORY_DATA_WIDTH		=> MEMORY_DATA_WIDTH,
			CL_NB_OF_DEVICES			=> NB_OF_DEVICES
		)
		port map (
			---- CustomLogic Simulation Control --------------------------------
			cxl_status  				=> cxl_status,
			cxl_ctrl					=> cxl_ctrl,
			cxl_onboard_mem				=> cxl_onboard_mem,
			---- CustomLogic Common Interfaces ---------------------------------
			-- Clock/Reset
			clk250						=> clk250,		-- Clock 250 MHz
			clk250_i					=> clk250,
			srst250						=> srst250, 	-- Global reset (PCIe reset)
			-- General Purpose I/O Interface
			user_output_ctrl			=> user_output_ctrl,
			user_output_status			=> user_output_status,
			standard_io_set1_status		=> standard_io_set1_status,
			standard_io_set2_status		=> standard_io_set2_status,
			module_io_set_status		=> module_io_set_status,
			qdc1_position_status		=> qdc1_position_status,
			qdc2_position_status		=> qdc2_position_status,
			qdc3_position_status		=> qdc3_position_status,
			qdc4_position_status		=> qdc4_position_status,
			custom_logic_output_ctrl	=> custom_logic_output_ctrl,
			reserved					=> reserved,
			-- Control Master Interface
			m_ctrl_addr					=> s_ctrl_addr,
			m_ctrl_data_wr_en			=> s_ctrl_data_wr_en,
			m_ctrl_data_wr				=> s_ctrl_data_wr,
			m_ctrl_data_rd				=> s_ctrl_data_rd,
		    -- On-Board Memory - Parameters
			onboard_mem_base			=> onboard_mem_base,
			onboard_mem_size			=> onboard_mem_size,
			-- On-Board Memory - AXI 4 Master Interface
			s_axi_resetn 				=> m_axi_resetn,	-- AXI 4 Interface reset
			s_axi_awaddr 				=> m_axi_awaddr,
			s_axi_awlen 				=> m_axi_awlen,
			s_axi_awsize 				=> m_axi_awsize,
			s_axi_awburst 				=> m_axi_awburst,
			s_axi_awlock 				=> m_axi_awlock,
			s_axi_awcache 				=> m_axi_awcache,
			s_axi_awprot 				=> m_axi_awprot,
			s_axi_awqos 				=> m_axi_awqos,
			s_axi_awvalid 				=> m_axi_awvalid,
			s_axi_awready 				=> m_axi_awready,
			s_axi_wdata 				=> m_axi_wdata,
			s_axi_wstrb 				=> m_axi_wstrb,
			s_axi_wlast 				=> m_axi_wlast,
			s_axi_wvalid 				=> m_axi_wvalid,
			s_axi_wready 				=> m_axi_wready,
			s_axi_bresp 				=> m_axi_bresp,
			s_axi_bvalid 				=> m_axi_bvalid,
			s_axi_bready 				=> m_axi_bready,
			s_axi_araddr 				=> m_axi_araddr,
			s_axi_arlen 				=> m_axi_arlen,
			s_axi_arsize 				=> m_axi_arsize,
			s_axi_arburst 				=> m_axi_arburst,
			s_axi_arlock 				=> m_axi_arlock,
			s_axi_arcache 				=> m_axi_arcache,
			s_axi_arprot 				=> m_axi_arprot,
			s_axi_arqos 				=> m_axi_arqos,
			s_axi_arvalid 				=> m_axi_arvalid,
			s_axi_arready 				=> m_axi_arready,
			s_axi_rdata 				=> m_axi_rdata,
			s_axi_rresp 				=> m_axi_rresp,
			s_axi_rlast 				=> m_axi_rlast,
			s_axi_rvalid 				=> m_axi_rvalid,
			s_axi_rready 				=> m_axi_rready,
			---- CustomLogic Device/Channel Interfaces -------------------------
			-- AXI Stream Master Interface
			m_axis_resetn				=> s_axis_resetn,	-- AXI Stream Interface reset
			m_axis_tvalid				=> s_axis_tvalid,
			m_axis_tready				=> s_axis_tready,
			m_axis_tdata				=> s_axis_tdata,
			m_axis_tuser				=> s_axis_tuser,
			-- Metadata Master Interface
			m_mdata_StreamId			=> s_mdata_StreamId,
			m_mdata_SourceTag			=> s_mdata_SourceTag,
			m_mdata_Xsize				=> s_mdata_Xsize,
			m_mdata_Xoffs				=> s_mdata_Xoffs,
			m_mdata_Ysize				=> s_mdata_Ysize,
			m_mdata_Yoffs				=> s_mdata_Yoffs,
			m_mdata_DsizeL				=> s_mdata_DsizeL,
			m_mdata_PixelF				=> s_mdata_PixelF,
			m_mdata_TapG				=> s_mdata_TapG,
			m_mdata_Flags				=> s_mdata_Flags,
			m_mdata_Timestamp			=> s_mdata_Timestamp,
			m_mdata_PixProcFlgs			=> s_mdata_PixProcFlgs,
			m_mdata_Status				=> s_mdata_Status,
			-- AXI Stream Slave Interface
			s_axis_tvalid				=> m_axis_tvalid,
			s_axis_tready				=> m_axis_tready,
			s_axis_tdata				=> m_axis_tdata,
			s_axis_tuser				=> m_axis_tuser,
			-- Metadata Slave Interface
			s_mdata_StreamId			=> m_mdata_StreamId,
			s_mdata_SourceTag			=> m_mdata_SourceTag,
			s_mdata_Xsize				=> m_mdata_Xsize,
			s_mdata_Xoffs				=> m_mdata_Xoffs,
			s_mdata_Ysize				=> m_mdata_Ysize,
			s_mdata_Yoffs				=> m_mdata_Yoffs,
			s_mdata_DsizeL				=> m_mdata_DsizeL,
			s_mdata_PixelF				=> m_mdata_PixelF,
			s_mdata_TapG				=> m_mdata_TapG,
			s_mdata_Flags				=> m_mdata_Flags,
			s_mdata_Timestamp			=> m_mdata_Timestamp,
			s_mdata_PixProcFlgs			=> m_mdata_PixProcFlgs,
			s_mdata_Status				=> m_mdata_Status,
			-- Memento Slave Interface
			s_memento_event				=> m_memento_event,
			s_memento_arg0				=> m_memento_arg0,
			s_memento_arg1				=> m_memento_arg1
		);
		
	iCustomLogic : entity work.CustomLogic
		generic map (
			STREAM_DATA_WIDTH			=> STREAM_DATA_WIDTH,
			MEMORY_DATA_WIDTH			=> MEMORY_DATA_WIDTH
		)
		port map (
			---- CustomLogic Common Interfaces ---------------------------------
			-- Clock/Reset
			clk250						=> clk250,		-- Clock 250 MHz
			srst250						=> srst250, 	-- Global reset (PCIe reset)
			-- General Purpose I/O Interface
			user_output_ctrl			=> user_output_ctrl,
			user_output_status			=> user_output_status,
			standard_io_set1_status		=> standard_io_set1_status,
			standard_io_set2_status		=> standard_io_set2_status,
			module_io_set_status		=> module_io_set_status,
			qdc1_position_status		=> qdc1_position_status,
			custom_logic_output_ctrl	=> custom_logic_output_ctrl,
			reserved					=> reserved,
			-- Control Slave Interface
			s_ctrl_addr					=> s_ctrl_addr,
			s_ctrl_data_wr_en			=> s_ctrl_data_wr_en,
			s_ctrl_data_wr				=> s_ctrl_data_wr,
			s_ctrl_data_rd				=> s_ctrl_data_rd,
		    -- On-Board Memory - Parameters
			onboard_mem_base			=> onboard_mem_base,
			onboard_mem_size			=> onboard_mem_size,
			-- On-Board Memory - AXI 4 Master Interface
			m_axi_resetn 				=> m_axi_resetn,	-- AXI 4 Interface reset
			m_axi_awaddr 				=> m_axi_awaddr,
			m_axi_awlen 				=> m_axi_awlen,
			m_axi_awsize 				=> m_axi_awsize,
			m_axi_awburst 				=> m_axi_awburst,
			m_axi_awlock 				=> m_axi_awlock,
			m_axi_awcache 				=> m_axi_awcache,
			m_axi_awprot 				=> m_axi_awprot,
			m_axi_awqos 				=> m_axi_awqos,
			m_axi_awvalid 				=> m_axi_awvalid,
			m_axi_awready 				=> m_axi_awready,
			m_axi_wdata 				=> m_axi_wdata,
			m_axi_wstrb 				=> m_axi_wstrb,
			m_axi_wlast 				=> m_axi_wlast,
			m_axi_wvalid 				=> m_axi_wvalid,
			m_axi_wready 				=> m_axi_wready,
			m_axi_bresp 				=> m_axi_bresp,
			m_axi_bvalid 				=> m_axi_bvalid,
			m_axi_bready 				=> m_axi_bready,
			m_axi_araddr 				=> m_axi_araddr,
			m_axi_arlen 				=> m_axi_arlen,
			m_axi_arsize 				=> m_axi_arsize,
			m_axi_arburst 				=> m_axi_arburst,
			m_axi_arlock 				=> m_axi_arlock,
			m_axi_arcache 				=> m_axi_arcache,
			m_axi_arprot 				=> m_axi_arprot,
			m_axi_arqos 				=> m_axi_arqos,
			m_axi_arvalid 				=> m_axi_arvalid,
			m_axi_arready 				=> m_axi_arready,
			m_axi_rdata 				=> m_axi_rdata,
			m_axi_rresp 				=> m_axi_rresp,
			m_axi_rlast 				=> m_axi_rlast,
			m_axi_rvalid 				=> m_axi_rvalid,
			m_axi_rready 				=> m_axi_rready,
			---- CustomLogic Device/Channel Interfaces -------------------------
			-- AXI Stream Slave Interface
			s_axis_resetn				=> s_axis_resetn(0),	-- AXI Stream Interface reset
			s_axis_tvalid				=> s_axis_tvalid(0),
			s_axis_tready				=> s_axis_tready(0),
			s_axis_tdata				=> s_axis_tdata,
			s_axis_tuser				=> s_axis_tuser,
			-- Metadata Slave Interface
			s_mdata_StreamId			=> s_mdata_StreamId,
			s_mdata_SourceTag			=> s_mdata_SourceTag,
			s_mdata_Xsize				=> s_mdata_Xsize,
			s_mdata_Xoffs				=> s_mdata_Xoffs,
			s_mdata_Ysize				=> s_mdata_Ysize,
			s_mdata_Yoffs				=> s_mdata_Yoffs,
			s_mdata_DsizeL				=> s_mdata_DsizeL,
			s_mdata_PixelF				=> s_mdata_PixelF,
			s_mdata_TapG				=> s_mdata_TapG,
			s_mdata_Flags				=> s_mdata_Flags,
			s_mdata_Timestamp			=> s_mdata_Timestamp,
			s_mdata_PixProcFlgs			=> s_mdata_PixProcFlgs,
			s_mdata_Status				=> s_mdata_Status,
			-- AXI Stream Master Interface
			m_axis_tvalid				=> m_axis_tvalid(0),
			m_axis_tready				=> m_axis_tready(0),
			m_axis_tdata				=> m_axis_tdata,
			m_axis_tuser				=> m_axis_tuser,
			-- Metadata Master Interface
			m_mdata_StreamId			=> m_mdata_StreamId,
			m_mdata_SourceTag			=> m_mdata_SourceTag,
			m_mdata_Xsize				=> m_mdata_Xsize,
			m_mdata_Xoffs				=> m_mdata_Xoffs,
			m_mdata_Ysize				=> m_mdata_Ysize,
			m_mdata_Yoffs				=> m_mdata_Yoffs,
			m_mdata_DsizeL				=> m_mdata_DsizeL,
			m_mdata_PixelF				=> m_mdata_PixelF,
			m_mdata_TapG				=> m_mdata_TapG,
			m_mdata_Flags				=> m_mdata_Flags,
			m_mdata_Timestamp			=> m_mdata_Timestamp,
			m_mdata_PixProcFlgs			=> m_mdata_PixProcFlgs,
			m_mdata_Status				=> m_mdata_Status,
			-- Memento Master Interface
			m_memento_event				=> m_memento_event(0),
			m_memento_arg0				=> m_memento_arg0,
			m_memento_arg1				=> m_memento_arg1
		);

end behav;
