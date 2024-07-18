library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity myproject_axi_wrp is
  generic (
    DATA_WIDTH           : natural := 256;
    USER_WIDTH           : natural := 4
  );
    port (
        -- Clock/Reset
    clk              : in  std_logic;  -- Clock 250 MHz
    srst            : in  std_logic;  -- Synchronous Reset (PCIe reset)
        -- Control
    -- AXI Stream Slave Interface
    s_axis_resetn        : in  std_logic;  -- AXI Stream Interface reset
    s_axis_tvalid        : in  std_logic;
    s_axis_tready        : out std_logic;
    s_axis_tdata        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_axis_tuser        : in  std_logic_vector(USER_WIDTH - 1 downto 0);
    -- Metadata Slave Interface
    s_mdata_StreamId      : in  std_logic_vector( 7 downto 0);
    s_mdata_SourceTag      : in  std_logic_vector(15 downto 0);
    s_mdata_Xsize        : in  std_logic_vector(23 downto 0);
    s_mdata_Xoffs        : in  std_logic_vector(23 downto 0);
    s_mdata_Ysize        : in  std_logic_vector(23 downto 0);
    s_mdata_Yoffs        : in  std_logic_vector(23 downto 0);
    s_mdata_DsizeL        : in  std_logic_vector(23 downto 0);
    s_mdata_PixelF        : in  std_logic_vector(15 downto 0);
    s_mdata_TapG        : in  std_logic_vector(15 downto 0);
    s_mdata_Flags        : in  std_logic_vector( 7 downto 0);
    s_mdata_Timestamp      : in  std_logic_vector(31 downto 0);
    s_mdata_PixProcFlgs      : in  std_logic_vector( 7 downto 0);
    s_mdata_Status        : in  std_logic_vector(31 downto 0);
    -- AXI Stream Master Interface
    m_axis_tvalid        : out std_logic;
    m_axis_tready        : in  std_logic;
    m_axis_tdata        : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    m_axis_tuser        : out std_logic_vector(USER_WIDTH - 1 downto 0);
    -- Metadata Master Interface
    m_mdata_StreamId      : out std_logic_vector( 7 downto 0);
    m_mdata_SourceTag      : out std_logic_vector(15 downto 0);
    m_mdata_Xsize        : out std_logic_vector(23 downto 0);
    m_mdata_Xoffs        : out std_logic_vector(23 downto 0);
    m_mdata_Ysize        : out std_logic_vector(23 downto 0);
    m_mdata_Yoffs        : out std_logic_vector(23 downto 0);
    m_mdata_DsizeL        : out std_logic_vector(23 downto 0);
    m_mdata_PixelF        : out std_logic_vector(15 downto 0);
    m_mdata_TapG        : out std_logic_vector(15 downto 0);
    m_mdata_Flags        : out std_logic_vector( 7 downto 0);
    m_mdata_Timestamp      : out std_logic_vector(31 downto 0);
    m_mdata_PixProcFlgs      : out std_logic_vector( 7 downto 0);
    m_mdata_Status        : out std_logic_vector(31 downto 0);
    user_output_ctrl      : out std_logic_vector( 15 downto 0));
end entity myproject_axi_wrp;

architecture behav of myproject_axi_wrp is

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
  signal reset_n        : std_logic;
  signal reset_n_s         : std_logic_vector(5 downto 0) := (others => '0');

  signal s_axis_tready_i    : std_logic;
  signal s_axis_tdata_i    : std_logic_vector(DATA_WIDTH*2 - 1 downto 0);

  signal pixth_start       : std_logic;

  signal pixth_tvalid      : std_logic;
  signal pixth_tready      : std_logic;
  signal pixth_tdata_i    : std_logic_vector(DATA_WIDTH*2 - 1 downto 0);
  signal pixth_tdata      : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal pixth_tuser      : std_logic_vector(USER_WIDTH - 1 downto 0);
  signal pixth_StreamId    : std_logic_vector( 7 downto 0);
  signal pixth_SourceTag    : std_logic_vector(15 downto 0);
  signal pixth_Xsize      : std_logic_vector(23 downto 0);
  signal pixth_Xoffs      : std_logic_vector(23 downto 0);
  signal pixth_Ysize      : std_logic_vector(23 downto 0);
  signal pixth_Yoffs      : std_logic_vector(23 downto 0);
  signal pixth_DsizeL      : std_logic_vector(23 downto 0);
  signal pixth_PixelF      : std_logic_vector(15 downto 0);
  signal pixth_TapG      : std_logic_vector(15 downto 0);
  signal pixth_Flags      : std_logic_vector( 7 downto 0);
  signal pixth_Timestamp    : std_logic_vector(31 downto 0);
  signal pixth_PixProcFlgs  : std_logic_vector( 7 downto 0);
  signal pixth_Status      : std_logic_vector(31 downto 0);

  signal s_mdata        : std_logic_vector(287 downto 0);
  signal pixth_mdata      : std_logic_vector(287 downto 0);

  -- signal Result_V         : std_logic_vector(159 downto 0);
  signal Result_V_ap_vld  : std_logic;

  signal UO0 : std_logic_vector(1 downto 0);
  signal UO1 : std_logic_vector(1 downto 0);
  signal UO2 : std_logic_vector(1 downto 0);
  signal UO3 : std_logic_vector(1 downto 0);
  signal UO4 : std_logic_vector(1 downto 0);
  signal UO5 : std_logic_vector(1 downto 0);

  ----------------------------------------------------------------------------
  -- Debug
  ----------------------------------------------------------------------------
    -- attribute mark_debug : string;
    -- attribute mark_debug of HlsThreshold_level  : signal is "true";
    -- attribute mark_debug of pixth_tvalid      : signal is "true";


begin

  -- Define user output bit fields
  user_output_ctrl(1 downto 0) <= UO0;
  user_output_ctrl(3 downto 2) <= UO1;
  user_output_ctrl(5 downto 4) <= UO2;
  user_output_ctrl(7 downto 6) <= UO3;
  user_output_ctrl(9 downto 8) <= UO4;
  user_output_ctrl(11 downto 10) <= UO5;
  
  -- HLS Generated IP
  iMyProjectAXI : entity work.myproject_axi
        port map (
            ap_clk               => clk,
            ap_rst_n             => reset_n,
            ap_start             => pixth_start,
            ap_done              => open,
            ap_idle              => open,
            ap_ready             => open,
            VideoIn_TDATA            => s_axis_tdata_i,
            -- VideoIn_TDATA            => s_axis_tdata,
            VideoIn_TVALID           => s_axis_tvalid,
            VideoIn_TREADY           => s_axis_tready_i,
            -- VideoIn_TUSER            => s_axis_tuser,
            -- MetaIn_StreamId          => s_mdata_StreamId,
            -- MetaIn_StreamId_ap_vld       => s_axis_tvalid,
            -- MetaIn_SourceTag         => s_mdata_SourceTag,
            -- MetaIn_SourceTag_ap_vld     => s_axis_tvalid,
            -- MetaIn_Xsize_V           => s_mdata_Xsize,
            -- MetaIn_Xsize_V_ap_vld       => s_axis_tvalid,
            -- MetaIn_Xoffs_V           => s_mdata_Xoffs,
            -- MetaIn_Xoffs_V_ap_vld       => s_axis_tvalid,
            -- MetaIn_Ysize_V           => s_mdata_Ysize,
            -- MetaIn_Ysize_V_ap_vld       => s_axis_tvalid,
            -- MetaIn_Yoffs_V           => s_mdata_Yoffs,
            -- MetaIn_Yoffs_V_ap_vld       => s_axis_tvalid,
            -- MetaIn_DsizeL_V          => s_mdata_DsizeL,
            -- MetaIn_DsizeL_V_ap_vld       => s_axis_tvalid,
            -- MetaIn_PixelF            => s_mdata_PixelF,
            -- MetaIn_PixelF_ap_vld       => s_axis_tvalid,
            -- MetaIn_TapG              => s_mdata_TapG,
            -- MetaIn_TapG_ap_vld         => s_axis_tvalid,
            -- MetaIn_Flags             => s_mdata_Flags,
            -- MetaIn_Flags_ap_vld         => s_axis_tvalid,
            -- MetaIn_Timestamp         => s_mdata_Timestamp,
            -- MetaIn_Timestamp_ap_vld     => s_axis_tvalid,
            -- MetaIn_PixProcessingFlgs     => s_mdata_PixProcFlgs,
            -- MetaIn_PixProcessingFlgs_ap_vld => s_axis_tvalid,
            -- MetaIn_ModPixelF         => (others=>'0'),
            -- MetaIn_ModPixelF_ap_vld     => s_axis_tvalid,
            -- MetaIn_Status            => s_mdata_Status,
            -- MetaIn_Status_ap_vld       => s_axis_tvalid,
            VideoOut_TDATA          => pixth_tdata_i,
            -- VideoOut_TDATA          => pixth_tdata,
            VideoOut_TVALID         => pixth_tvalid,
            VideoOut_TREADY         => pixth_tready,
            -- VideoOut_TUSER          => pixth_tuser,
            -- MetaOut_StreamId          => pixth_StreamId,
            -- MetaOut_SourceTag         => pixth_SourceTag,
            -- MetaOut_Xsize_V           => pixth_Xsize,
            -- MetaOut_Xoffs_V           => pixth_Xoffs,
            -- MetaOut_Ysize_V           => pixth_Ysize,
            -- MetaOut_Yoffs_V           => pixth_Yoffs,
            -- MetaOut_DsizeL_V          => pixth_DsizeL,
            -- MetaOut_PixelF            => pixth_PixelF,
            -- MetaOut_TapG              => pixth_TapG,
            -- MetaOut_Flags             => pixth_Flags,
            -- MetaOut_Timestamp         => pixth_Timestamp,
            -- MetaOut_PixProcessingFlgs => pixth_PixProcFlgs,
            -- MetaOut_ModPixelF         => open,
            -- MetaOut_Status            => pixth_Status,
            MetaIn                 => s_mdata,
            MetaIn_ap_vld           => s_axis_tvalid,
            MetaOut                 => pixth_mdata,
            ModelOutFirst            => open,
            ModelOutFirst_ap_vld     => Result_V_ap_vld
        );

  iSignalInference : entity work.signal_inference
        port map (
            clk                        => clk,
            HlsPixTh_tvalid            => s_axis_tvalid,
            Result_vld                 => Result_V_ap_vld,
            UserOutput                 => UO0
        );


  s_axis_tdata_i(DATA_WIDTH - 1 downto 0         ) <= s_axis_tdata;
  s_axis_tdata_i(DATA_WIDTH + 3 downto DATA_WIDTH) <= s_axis_tuser;
  s_axis_tready       <= s_axis_tready_i;
  pixth_tdata        <= pixth_tdata_i(DATA_WIDTH - 1 downto 0         );
  pixth_tuser        <= pixth_tdata_i(DATA_WIDTH + 3 downto DATA_WIDTH);
  pixth_tready       <= m_axis_tready;
  s_mdata(255 downto 0)  <= s_mdata_StreamId    &
                 s_mdata_SourceTag  &
                 s_mdata_Xsize    &
                 s_mdata_Xoffs    &
                 s_mdata_Ysize    &
                 s_mdata_Yoffs    &
                 s_mdata_DsizeL    &
                 s_mdata_PixelF    &
                 s_mdata_TapG      &
                 s_mdata_Flags    &
                 s_mdata_Timestamp  &
                 s_mdata_PixProcFlgs  &
                 s_mdata_Status;

  pixth_StreamId      <= pixth_mdata(255 downto 248);
  pixth_SourceTag      <= pixth_mdata(247 downto 232);
  pixth_Xsize        <= pixth_mdata(231 downto 208);
  pixth_Xoffs        <= pixth_mdata(207 downto 184);
  pixth_Ysize        <= pixth_mdata(183 downto 160);
  pixth_Yoffs        <= pixth_mdata(159 downto 136);
  pixth_DsizeL      <= pixth_mdata(135 downto 112);
  pixth_PixelF      <= pixth_mdata(111 downto 96);
  pixth_TapG        <= pixth_mdata(95 downto 80);
  pixth_Flags        <= pixth_mdata(79 downto 72);
  pixth_Timestamp      <= pixth_mdata(71 downto 40);
  pixth_PixProcFlgs    <= pixth_mdata(39 downto 32);
  pixth_Status      <= pixth_mdata(31 downto 0);





  -- s_axis_tready   <= m_axis_tready when HlsThreshold_bypass = '1' else s_axis_tready_i;
  -- s_axis_tready   <= s_axis_tready_i;
  -- pixth_tready   <= m_axis_tready;

  -- Reset generation
    pReset : process(clk)
  begin
    if rising_edge(clk) then
      reset_n_s   <= reset_n_s(4 downto 0) & '1';
      pixth_start <= reset_n_s(5);
      if srst='1' or s_axis_resetn='0' then
        reset_n_s   <= (others=>'0');
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
        m_axis_tvalid  <= pixth_tvalid;
        m_axis_tuser  <= (others=>'0');
        if pixth_tvalid = '1' then
          m_axis_tdata <= pixth_tdata;
          m_axis_tuser <= pixth_tuser;
        end if;
        m_mdata_StreamId  <= pixth_StreamId;
        m_mdata_SourceTag  <= pixth_SourceTag;
        m_mdata_Xsize    <= pixth_Xsize;
        m_mdata_Xoffs    <= pixth_Xoffs;
        m_mdata_Ysize    <= pixth_Ysize;
        m_mdata_Yoffs    <= pixth_Yoffs;
        m_mdata_DsizeL    <= pixth_DsizeL;
        m_mdata_PixelF    <= pixth_PixelF;
        m_mdata_TapG    <= pixth_TapG;
        m_mdata_Flags    <= pixth_Flags;
        m_mdata_Timestamp  <= pixth_Timestamp;
        m_mdata_PixProcFlgs  <= pixth_PixProcFlgs;
        m_mdata_Status    <= pixth_Status;
        -- if HlsThreshold_bypass = '1' then
        --   m_axis_tvalid    <= s_axis_tvalid;
        --   m_axis_tdata    <= s_axis_tdata;
        --   m_axis_tuser    <= s_axis_tuser;
        --   m_mdata_StreamId  <= s_mdata_StreamId;
        --   m_mdata_SourceTag  <= s_mdata_SourceTag;
        --   m_mdata_Xsize    <= s_mdata_Xsize;
        --   m_mdata_Xoffs    <= s_mdata_Xoffs;
        --   m_mdata_Ysize    <= s_mdata_Ysize;
        --   m_mdata_Yoffs    <= s_mdata_Yoffs;
        --   m_mdata_DsizeL    <= s_mdata_DsizeL;
        --   m_mdata_PixelF    <= s_mdata_PixelF;
        --   m_mdata_TapG    <= s_mdata_TapG;
        --   m_mdata_Flags    <= s_mdata_Flags;
        --   m_mdata_Timestamp  <= s_mdata_Timestamp;
        --   m_mdata_PixProcFlgs  <= s_mdata_PixProcFlgs;
        --   m_mdata_Status    <= s_mdata_Status;
        -- end if;
      end if;
      if reset_n = '0' then
        m_axis_tvalid  <= '0';
      end if;
    end if;
  end process;
end behav;