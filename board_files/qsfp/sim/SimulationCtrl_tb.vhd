--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: SimulationCtrl_tb
--    File: SimulationCtrl_tb.vhd
--    Date: 2023-03-07
--     Rev: 0.5
--  Author: PP
--------------------------------------------------------------------------------
-- Simulation Control
--------------------------------------------------------------------------------
-- 0.1, 2019-08-21, PP, Initial release
-- 0.2, 2019-10-25, PP, Added Clock port for reference
--                      Added Ref_UserOutputReg_set command
-- 0.3, 2021-02-25, PP, Added onboard_mem port to define On-Board Memory type
-- 0.4, 2022-05-31, MH, Added read-file option to FrameRequest command
-- 0.5, 2023-03-07, MH, Added Ref_CLogicOutputReg_set command
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.SimulationCtrl_tb_pkg.all;

entity SimulationCtrl_tb is
	generic (
		CL_NB_OF_DEVICES	: natural := 1
	);
	port (
		-- Clock
		clk			: in  std_logic;
		-- Control/Status ports
		status		: in  cxl_status_type_a	(CL_NB_OF_DEVICES-1 downto 0);
		ctrl		: out cxl_ctrl_type_a	(CL_NB_OF_DEVICES-1 downto 0) := (others=>cxl_ctrl_init);
		onboard_mem	: out cxl_onboard_mem_type
	);
end entity SimulationCtrl_tb;

architecture behav of SimulationCtrl_tb is
	
begin

	----------------------------------------------------------------------------
	-- List of general commands to control the CustomLogic simulation framework
	----------------------------------------------------------------------------
	--	CtrlInt_rd
	--	----------
	-- 		Description: 
	--			Control Interface READ command.
	--		Syntax:
	--			CtrlInt_rd(clk,status,ctrl, <address>);
	--		Arguments:
	--			<address>	: Type='std_logic_vector(15 downto 0)', Range=(x"0000" to x"FFFF")
	--		Example:
	--			CtrlInt_rd(clk,status,ctrl, x"000A");
	--
	--	CtrlInt_wr
	--	----------
	-- 		Description: 
	--			Control Interface WRITE command.
	--		Syntax:
	--			CtrlInt_wr(clk,status,ctrl, <address>, <data>);
	--		Arguments:
	--			<address>	: Type='std_logic_vector(15 downto 0)', Range=(x"0000" to x"FFFF")
	--			<data>		: Type='std_logic_vector(31 downto 0)', Range=(x"00000000" to x"FFFFFFFF")
	--		Example:
	--			CtrlInt_wr(clk,status,ctrl, x"000A", x"12345678");
	--
	--	EnableDataStream
	--	----------------
	-- 		Description: 
	--			Enable Data Stream command. Starts the Coaxlink front-end and back-end
	--			to be ready to grab images.
	--		Syntax:
	--			EnableDataStream(clk,status,ctrl, <channel>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--		Example:
	--			EnableDataStream(clk,status,ctrl, 1);
	--
	--	DisableDataStream
	--	-----------------
	-- 		Description: 
	--			Disable Data Stream command. Stops the Coaxlink front-end and back-end
	--			and clears the CustomLogic data-path.
	--		Syntax:
	--			DisableDataStream(clk,status,ctrl, <channel>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--		Example:
	--			DisableDataStream(clk,status,ctrl, 1);
	--
	-- 	FrameRequest
	--	------------
	-- 		Description: 
	--			Request frames from the Coaxlink front-end. The Data Stream must be enabled
	--			beforehand. The front-end can provide the Data Stream with image data from an external file
	--			or with internally generated data. Obs.: <nb_frames> = 0  for infinite frames (Free-run).
	--		Syntax:
	--			FrameRequest(clk,status,ctrl, <channel>, <nb_frames>, <xsize>, <ysize>, <pixelf>, <read_file>, <big_endian>, <file_path>);
	--		Arguments:
	--			<channel>		: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--			<nb_frames>		: Type='integer', Range=(0 to 1000), Obs.: Value 0 for infinite frames (Free-run).
	--			<xsize>			: Type='integer', Range=(64 to 8.192), Obs.: <xsize> must be a multiple of 32.
	--			<ysize>			: Type='integer', Range=(1 to 8.192)
	--			<pixelf>		: Type='enum', Values=Mono8,Mono16
	--			<read_file> 	: Type='boolean', Values=FALSE,TRUE, Obs.: Enable read image data from file.
	--			<big_endian> 	: Type='boolean', Values=FALSE,TRUE, Obs.: Read Mono16 pixel data from file in the big-endian format. Default is little-endian.
	--			<file_path> 	: Type='string', Maximum length of string: 200, Obs.: Absolute path to the file containing the image data.
	--		Example:
	--			FrameRequest(clk,status,ctrl, 1, 10, 512, 20, Mono8, TRUE, FALSE, "C:/Documents/Image_Data.dat");
	--
	-- 	GlobalReset
	--	-----------
	-- 		Description: 
	--			Generates a Global reset.
	--		Syntax:
	--			GlobalReset(clk,status,ctrl);
	--		Example:
	--			GlobalReset(clk,status,ctrl);

	----------------------------------------------------------------------------
	-- Reference design commands
	-- 	These commands are specific to the 'Control Registers' available in the 
	--  CustomLogic reference design.
	----------------------------------------------------------------------------
	-- 	Ref_Scratchpad_wr
	--	-----------------
	--		Description:
	--			Write into the scratchpad register.
	--		Syntax:
	-- 			Ref_Scratchpad_wr(clk,status,ctrl, <data>);
	--		Arguments:
	--			<data>		: Type='std_logic_vector(31 downto 0)', Range=(x"00000000" to x"FFFFFFFF")
	--		Example:
	-- 			Ref_Scratchpad_wr(clk,status,ctrl, x"12345678");
	--
	-- 	Ref_Scratchpad_rd
	--	-----------------
	--		Description:
	--			Read from the scratchpad register.
	--		Syntax:
	-- 			Ref_Scratchpad_rd(clk,status,ctrl);
	--		Example:
	-- 			Ref_Scratchpad_rd(clk,status,ctrl);
	--
	-- 	Ref_MemTrafficGen_on
	--	--------------------
	--		Description:
	--			Activate the Memory Traffic Generator module.
	--		Syntax:
	-- 			Ref_MemTrafficGen_on(clk,status,ctrl);
	--		Example:
	-- 			Ref_MemTrafficGen_on(clk,status,ctrl);
	--
	-- 	Ref_MemTrafficGen_off
	--	---------------------
	--		Description:
	--			Deactivate the Memory Traffic Generator module.
	--		Syntax:
	-- 			Ref_MemTrafficGen_off(clk,status,ctrl);
	--		Example:
	-- 			Ref_MemTrafficGen_off(clk,status,ctrl);
	--
	-- 	Ref_UserOutputReg_set
	--	---------------------
	--		Description:
	--			Set the User Output Register
	--		Syntax:
	-- 			Ref_UserOutputReg_set(clk,status,ctrl, <user_out>);
	--		Arguments:
	--			<user_out>	: Type='std_logic_vector(15 downto 0)', Range=(x"0000" to x"FFFF"), Obs.: Please refer to the User Guide for the <user_out> encoding.
	--		Example:
	-- 			Ref_UserOutputReg_set(clk,status,ctrl, x"6666");
	--
	-- 	Ref_CLogicOutputReg_set
	--	---------------------
	--		Description:
	--			Set the CustomLogic Output Register
	--		Syntax:
	-- 			Ref_CLogicOutputReg_set(clk,status,ctrl, <clogic_out>);
	--		Arguments:
	--			<clogic_out>	: Type='std_logic_vector(31 downto 0)', Range=(x"00000000" to x"FFFFFFFF")
	--		Example:
	-- 			Ref_CLogicOutputReg_set(clk,status,ctrl, x"AAAAAAAA");
	--
	-- 	Ref_Frame2Line_on
	--	-----------------
	--		Description:
	--			Activate the Frame-to-Line Converter module.
	--		Syntax:
	-- 			Ref_Frame2Line_on(clk,status,ctrl, <channel>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--		Example:
	-- 			Ref_Frame2Line_on(clk,status,ctrl, 0);
	--
	-- 	Ref_Frame2Line_off
	--	------------------
	--		Description:
	--			Deactivate the Frame-to-Line Converter module.
	--		Syntax:
	-- 			Ref_Frame2Line_off(clk,status,ctrl, <channel>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--		Example:
	-- 			Ref_Frame2Line_off(clk,status,ctrl, 0);
	--
	-- 	Ref_MementoEvent_gen
	--	--------------------
	--		Description:
	--			Generates a Memento Event.
	--		Syntax:
	-- 			Ref_MementoEvent_gen(clk,status,ctrl, <channel>, <data>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--			<data>		: Type='std_logic_vector(31 downto 0)', Range=(x"00000000" to x"FFFFFFFF")
	--		Example:
	-- 			Ref_MementoEvent_gen(clk,status,ctrl, 2, x"12345678");
	--
	-- 	Ref_PixelLut_Negative_on
	--	--------------------
	--		Description:
	--			Activate the Pixel LUT 8-bit module with a Negative LUT.
	--		Syntax:
	-- 			Ref_PixelLut_Negative_on(clk,status,ctrl, <channel>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--		Example:
	-- 			Ref_PixelLut_Negative_on(clk,status,ctrl, 0);
	--
	-- 	Ref_PixelLut_off
	--	--------------------
	--		Description:
	--			Deactivate the Pixel LUT 8-bit module.
	--		Syntax:
	-- 			Ref_PixelLut_off(clk,status,ctrl, <channel>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--		Example:
	-- 			Ref_PixelLut_off(clk,status,ctrl, 0);
	--
	-- 	Ref_PixelThreshold_on
	--	--------------------
	--		Description:
	--			Activate the Pixel Threshold module.
	--		Syntax:
	-- 			Ref_PixelThreshold_on(clk,status,ctrl, <channel>, <threshold>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--			<threshold>	: Type='integer', Range=(1 to 255)
	--		Example:
	-- 			Ref_PixelThreshold_on(clk,status,ctrl, 0, 128);
	--
	-- 	Ref_PixelThreshold_off
	--	--------------------
	--		Description:
	--			Deactivate the Pixel Threshold module.
	--		Syntax:
	-- 			Ref_PixelThreshold_off(clk,status,ctrl, <channel>);
	--		Arguments:
	--			<channel>	: Type='integer', Range=(0 to 7), Obs.: The range allowed range depends on CustomLogic variant in use.
	--		Example:
	-- 			Ref_PixelThreshold_off(clk,status,ctrl, 0);
	--

	onboard_mem <= DDR4_2GB;	-- Valid values: DDR4_2GB or DDR4_4GB

	Simulation : process
	begin
		-- Place your sequence of commands within the 'Simulation' process.

		Ref_MementoEvent_gen	(clk,status,ctrl, 0, x"AAAAAAAA");
		Ref_PixelLut_Negative_on(clk,status,ctrl, 0);
		EnableDataStream		(clk,status,ctrl, 0);
		FrameRequest			(clk,status,ctrl, 0, 5, 256, 10, Mono8, FALSE);

		-- To read image data from a file, change the absolute path here below to locate the file containing the data.
		-- In addition, Linux users must update the FILE_PATH_LENGTH constant in Simulation_FileIO_pkg.vhd
		-- to specify the length of the absolute path locating the image data file.
		-- FrameRequest			(clk,status,ctrl, 0, 5, 256, 10, Mono8, TRUE, FALSE, "C:/Documents/Image_Data.dat");

		DisableDataStream		(clk,status,ctrl, 0);
		Ref_PixelLut_off		(clk,status,ctrl, 0);
		GlobalReset				(clk,status,ctrl);
		Ref_MementoEvent_gen	(clk,status,ctrl, 0, x"BBBBBBBB");
		
		std.env.finish;
	end process;

end behav;
