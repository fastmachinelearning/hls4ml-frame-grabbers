--------------------------------------------------------------------------------
-- Project: CustomLogic
--------------------------------------------------------------------------------
--  Module: control_registers
--    File: control_registers.vhd
--    Date: 2019-10-24
--     Rev: 0.3
--  Author: PP
--------------------------------------------------------------------------------
-- Reference Design: Control Registers decoder
--   This module shows how to use the CustomLogic Control Interface as a register
--   map decoder.
--------------------------------------------------------------------------------
-- 0.1, 2018-06-04, PP, Initial release
-- 0.2, 2019-06-24, PP, Added multi-device/pipeline support
-- 0.3, 2019-10-24, PP, Added General Purpose I/O Interface
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity control_registers is
	generic (
		NB_OF_DEVICES				: natural := 1
	);
	port (
		-- Clock / Reset
		clk							: in  std_logic;
		srst						: in  std_logic;
        -- Control Interface
		s_ctrl_addr					: in  std_logic_vector(15 downto 0);
		s_ctrl_data_wr_en			: in  std_logic;
		s_ctrl_data_wr				: in  std_logic_vector(31 downto 0);
		s_ctrl_data_rd				: out std_logic_vector(31 downto 0);
        -- Registers
		MemTrafficGen_en			: out std_logic;
		UserOutput_ctrl				: out std_logic_vector( 15 downto 0);
		UserOutput_status			: in  std_logic_vector(  7 downto 0);
		StandardIoSet1_status		: in  std_logic_vector(  9 downto 0);
		StandardIoSet2_status		: in  std_logic_vector(  9 downto 0);
		ModuleIoSet_status			: in  std_logic_vector( 39 downto 0);
		Qdc1Position_status			: in  std_logic_vector( 31 downto 0) := (others=>'0');
		Qdc2Position_status			: in  std_logic_vector( 31 downto 0) := (others=>'0');
		Qdc3Position_status			: in  std_logic_vector( 31 downto 0) := (others=>'0');
		Qdc4Position_status			: in  std_logic_vector( 31 downto 0) := (others=>'0');
		Frame2Line_bypass			: out std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
		MementoEvent_en				: out std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
		MementoEvent_arg0			: out std_logic_vector(NB_OF_DEVICES*32 - 1 downto 0);
		PixelLut_bypass				: out std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
		PixelLut_coef_start			: out std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
		PixelLut_coef_vld			: out std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
		PixelLut_coef				: out std_logic_vector(NB_OF_DEVICES*8  - 1 downto 0);
		PixelLut_coef_done			: in  std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
		PixelThreshold_bypass		: out std_logic_vector(NB_OF_DEVICES    - 1 downto 0);
		PixelThreshold_level		: out std_logic_vector(NB_OF_DEVICES*8  - 1 downto 0)
	);
end entity control_registers;

architecture behav of control_registers is

	----------------------------------------------------------------------------
	-- Constants
	----------------------------------------------------------------------------
	-- Common addresses
	constant ADDR_SCRATCHPAD		: std_logic_vector(15 downto 0) := x"0000";
	constant ADDR_MEMTRAFFICGEN		: std_logic_vector(15 downto 0) := x"0001";
	constant ADDR_USEROUTCTRL		: std_logic_vector(15 downto 0) := x"0002";
	constant ADDR_USEROUTSTATUS		: std_logic_vector(15 downto 0) := x"0003";
	constant ADDR_IOSET1STATUS		: std_logic_vector(15 downto 0) := x"0004";
	constant ADDR_IOSET2STATUS		: std_logic_vector(15 downto 0) := x"0005";
	constant ADDR_MIOSETASTATUS		: std_logic_vector(15 downto 0) := x"0006";
	constant ADDR_MIOSETBSTATUS		: std_logic_vector(15 downto 0) := x"0007";
	constant ADDR_QDC1POSSTATUS		: std_logic_vector(15 downto 0) := x"0010";
	constant ADDR_QDC2POSSTATUS		: std_logic_vector(15 downto 0) := x"0011";
	constant ADDR_QDC3POSSTATUS		: std_logic_vector(15 downto 0) := x"0012";
	constant ADDR_QDC4POSSTATUS		: std_logic_vector(15 downto 0) := x"0013";
	
	-- Channel (n) addresses
	-- Address = Offset + 1000h + (n)*100h
	-- Obs.: "n" is the device/pipeline channel
	constant ADDR_FRAME2LINE		: std_logic_vector(7 downto 0) := x"00";
	constant ADDR_MEMENTOEVENT		: std_logic_vector(7 downto 0) := x"01";
	constant ADDR_PIXELLUT		    : std_logic_vector(7 downto 0) := x"02";
	constant ADDR_PIXELLUTCOEF		: std_logic_vector(7 downto 0) := x"03";
	constant ADDR_PIXELTHRESHOLD	: std_logic_vector(7 downto 0) := x"04";

    
	----------------------------------------------------------------------------
	-- Types
	----------------------------------------------------------------------------
	type cl_stdlv_8b_a	is array (natural range <>) of std_logic_vector( 7 downto 0);
	type cl_stdlv_32b_a	is array (natural range <>) of std_logic_vector(31 downto 0);
	

	----------------------------------------------------------------------------
	-- Functions
	----------------------------------------------------------------------------
	pure function get_channel(addr : std_logic_vector(15 downto 0)) return integer is
	begin
        return to_integer(unsigned(addr(11 downto 8)));
	end function;

    
	----------------------------------------------------------------------------
	-- Components
	----------------------------------------------------------------------------
	
	
	----------------------------------------------------------------------------
	-- Signals
	----------------------------------------------------------------------------
	signal channel_addr				: integer;
	
    -- Registers
	signal scratchpad_reg			: std_logic_vector(31 downto 0);
	signal memtrafficgen_en_reg		: std_logic;
	signal user_output_ctrl_reg		: std_logic_vector(15 downto 0);
	signal frame2line_bypass_reg	: std_logic_vector(NB_OF_DEVICES - 1 downto 0);
	signal mementoevent_en_reg		: std_logic_vector(NB_OF_DEVICES - 1 downto 0);
	signal mementoevent_reg			: cl_stdlv_32b_a  (NB_OF_DEVICES - 1 downto 0);
	signal pixellut_coef_start_reg	: std_logic_vector(NB_OF_DEVICES - 1 downto 0);
	signal pixellut_coef_vld_reg	: std_logic_vector(NB_OF_DEVICES - 1 downto 0);
	signal pixellut_bypass_reg		: std_logic_vector(NB_OF_DEVICES - 1 downto 0);
	signal pixellut_coef_reg		: cl_stdlv_8b_a   (NB_OF_DEVICES - 1 downto 0);
	signal hls_pixth_bypass_reg		: std_logic_vector(NB_OF_DEVICES - 1 downto 0);
	signal hls_pixth_level_reg		: cl_stdlv_8b_a   (NB_OF_DEVICES - 1 downto 0);
	

	----------------------------------------------------------------------------
	-- Debug
	----------------------------------------------------------------------------
    -- attribute mark_debug : string;
    -- attribute mark_debug of s_ctrl_data_wr_en	: signal is "true";
    -- attribute mark_debug of s_ctrl_addr			: signal is "true";
   
    
begin

	channel_addr <= get_channel(s_ctrl_addr);
    
    ---- Write decoding --------------------------------------------------------
    pWrite : process(clk) is
	begin
		if rising_edge(clk) then
			-- Auto-clear registers
			for DEVICE in 0 to NB_OF_DEVICES - 1 loop
				mementoevent_en_reg		(DEVICE) <= '0';
				pixellut_coef_start_reg	(DEVICE) <= '0';
				pixellut_coef_vld_reg	(DEVICE) <= '0';
			end loop;
			
			-- Common addresses
			if s_ctrl_data_wr_en = '1' then
				case s_ctrl_addr is
					when ADDR_SCRATCHPAD =>
						scratchpad_reg <= s_ctrl_data_wr;
					when ADDR_MEMTRAFFICGEN =>
						memtrafficgen_en_reg <= s_ctrl_data_wr(0);
					when ADDR_USEROUTCTRL =>
						user_output_ctrl_reg <= s_ctrl_data_wr(15 downto 0);
					when others =>
				end case;
			end if;

			-- Channel addresses
			if s_ctrl_data_wr_en='1' and s_ctrl_addr(15 downto 12)=x"1" then
				case s_ctrl_addr(7 downto 0) is
					when ADDR_FRAME2LINE =>
						case s_ctrl_data_wr(1 downto 0) is
							when "01" => frame2line_bypass_reg(channel_addr) <= '1';
							when "10" => frame2line_bypass_reg(channel_addr) <= '0';
							when others =>
						end case;
					when ADDR_MEMENTOEVENT =>
						mementoevent_en_reg		(channel_addr) <= '1';
						mementoevent_reg		(channel_addr) <= s_ctrl_data_wr;
					when ADDR_PIXELLUT =>
						pixellut_coef_start_reg	(channel_addr) <= s_ctrl_data_wr(0);
						case s_ctrl_data_wr(9 downto 8) is
							when "01" => pixellut_bypass_reg(channel_addr) <= '1';
							when "10" => pixellut_bypass_reg(channel_addr) <= '0';
							when others =>
						end case;
					when ADDR_PIXELLUTCOEF =>
						pixelLut_coef_vld_reg	(channel_addr) <= '1';
						pixellut_coef_reg		(channel_addr) <= s_ctrl_data_wr(7 downto 0);
					when ADDR_PIXELTHRESHOLD =>
						if s_ctrl_data_wr(7 downto 0) /= x"00" then
							hls_pixth_level_reg (channel_addr) <= s_ctrl_data_wr(7 downto 0);
						end if;
						case s_ctrl_data_wr(9 downto 8) is
							when "01" => hls_pixth_bypass_reg(channel_addr) <= '1';
							when "10" => hls_pixth_bypass_reg(channel_addr) <= '0';
							when others =>
						end case;
					when others =>
				end case;
			end if;

			if srst = '1' then
				scratchpad_reg			<= (others=>'0');
				memtrafficgen_en_reg	<= '0';
				user_output_ctrl_reg	<= (others=>'0');
				for DEVICE in 0 to NB_OF_DEVICES - 1 loop
					frame2line_bypass_reg 	(DEVICE) <= '1';
					mementoevent_reg 		(DEVICE) <= (others=>'0');
					pixellut_coef_reg		(DEVICE) <= (others=>'0');
					pixellut_bypass_reg		(DEVICE) <= '1';
					hls_pixth_bypass_reg	(DEVICE) <= '1';
					hls_pixth_level_reg		(DEVICE) <= x"01";
				end loop;
			end if;
		end if;
	end process;
	
    ---- Read decoding ---------------------------------------------------------
    pRead : process(clk) is
	begin
		if rising_edge(clk) then
			s_ctrl_data_rd <= (others=>'0');
			
			-- Common addresses
			case s_ctrl_addr is
				when ADDR_SCRATCHPAD =>
					s_ctrl_data_rd <= scratchpad_reg;
				when ADDR_MEMTRAFFICGEN =>
					s_ctrl_data_rd(0) <= memtrafficgen_en_reg;
				when ADDR_USEROUTCTRL =>
					s_ctrl_data_rd(15 downto 0) <= user_output_ctrl_reg;
				when ADDR_USEROUTSTATUS =>
					s_ctrl_data_rd( 7 downto 0) <= UserOutput_status;
				when ADDR_IOSET1STATUS =>
					s_ctrl_data_rd( 9 downto 0) <= StandardIoSet1_status;
				when ADDR_IOSET2STATUS =>
					s_ctrl_data_rd( 9 downto 0) <= StandardIoSet2_status;
				when ADDR_MIOSETASTATUS =>
					s_ctrl_data_rd(31 downto 0) <= ModuleIoSet_status(31 downto 0);
				when ADDR_MIOSETBSTATUS =>
					s_ctrl_data_rd( 7 downto 0) <= ModuleIoSet_status(39 downto 32);
				when ADDR_QDC1POSSTATUS =>
					s_ctrl_data_rd(31 downto 0) <= Qdc1Position_status(31 downto 0);
				when ADDR_QDC2POSSTATUS =>
					s_ctrl_data_rd(31 downto 0) <= Qdc2Position_status(31 downto 0);
				when ADDR_QDC3POSSTATUS =>
					s_ctrl_data_rd(31 downto 0) <= Qdc3Position_status(31 downto 0);
				when ADDR_QDC4POSSTATUS =>
					s_ctrl_data_rd(31 downto 0) <= Qdc4Position_status(31 downto 0);
				when others =>
			end case;
			
			-- Channel addresses
			if s_ctrl_addr(15 downto 12) = x"1" then
				case s_ctrl_addr(7 downto 0) is
					when ADDR_FRAME2LINE =>
						s_ctrl_data_rd(0) 	<= frame2line_bypass_reg(channel_addr);
					when ADDR_MEMENTOEVENT =>
						s_ctrl_data_rd 		<= mementoevent_reg(channel_addr);
					when ADDR_PIXELLUT =>
						s_ctrl_data_rd(4) 	<= PixelLut_coef_done(channel_addr);
						case pixellut_bypass_reg(channel_addr) is
							when '1' => s_ctrl_data_rd(9 downto 8) <= "01";
							when '0' => s_ctrl_data_rd(9 downto 8) <= "10";
							when others =>
						end case;
					when ADDR_PIXELTHRESHOLD =>
						s_ctrl_data_rd(7 downto 0) <= hls_pixth_level_reg(channel_addr);
						case hls_pixth_bypass_reg(channel_addr) is
							when '1' => s_ctrl_data_rd(9 downto 8) <= "01";
							when '0' => s_ctrl_data_rd(9 downto 8) <= "10";
							when others =>
						end case;
					when others =>
				end case;
			end if;
		end if;
	end process;
	
	---- Output Register Mapping -----------------------------------------------
	MemTrafficGen_en 	<= memtrafficgen_en_reg;
	UserOutput_ctrl 	<= user_output_ctrl_reg;
	
	gOutputMapping : for DEVICE in 0 to NB_OF_DEVICES - 1 generate 
		Frame2Line_bypass	    (DEVICE) <= frame2line_bypass_reg	(DEVICE);
		MementoEvent_en			(DEVICE) <= mementoevent_en_reg		(DEVICE);
		MementoEvent_arg0	    (DEVICE*32 + 31 downto DEVICE*32) <= mementoevent_reg	(DEVICE);
		PixelLut_coef_start		(DEVICE) <= pixellut_coef_start_reg	(DEVICE);
		PixelLut_coef_vld		(DEVICE) <= pixellut_coef_vld_reg	(DEVICE);
		PixelLut_bypass		    (DEVICE) <= pixellut_bypass_reg		(DEVICE);
		PixelLut_coef		    (DEVICE*8 + 7 downto DEVICE*8) <= pixellut_coef_reg		(DEVICE);
		PixelThreshold_bypass	(DEVICE) <= hls_pixth_bypass_reg	(DEVICE);
		PixelThreshold_level	(DEVICE*8 + 7 downto DEVICE*8) <= hls_pixth_level_reg	(DEVICE);
	end generate;
    
end behav; 
