library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use work.float_pkg.all;
use work.constantspackage.all;
use work.vpfrecords.all;
use work.portspackage.all;
entity Filters is
generic (
    F_TES                 : boolean := false;
    F_LUM                 : boolean := false;
    F_TRM                 : boolean := false;
    F_RGB                 : boolean := false;
    F_SHP                 : boolean := false;
    F_BLU                 : boolean := false;
    F_EMB                 : boolean := false;
    F_YCC                 : boolean := false;
    F_SOB                 : boolean := false;
    F_CGA                 : boolean := false;
    F_HSV                 : boolean := false;
    F_HSL                 : boolean := false;
    M_SOB_LUM             : boolean := false;
    M_SOB_TRM             : boolean := false;
    M_SOB_RGB             : boolean := false;
    M_SOB_SHP             : boolean := false;
    M_SOB_BLU             : boolean := false;
    M_SOB_YCC             : boolean := false;
    M_SOB_CGA             : boolean := false;
    M_SOB_HSV             : boolean := false;
    M_SOB_HSL             : boolean := false;
    F_CGA_TO_CGA          : boolean := false;
    F_CGA_TO_HSL          : boolean := false;
    F_CGA_TO_HSV          : boolean := false;
    F_CGA_TO_YCC          : boolean := false;
    F_CGA_TO_SHP          : boolean := false;
    F_CGA_TO_BLU          : boolean := false;
    F_SHP_TO_SHP          : boolean := false;
    F_SHP_TO_HSL          : boolean := false;
    F_SHP_TO_HSV          : boolean := false;
    F_SHP_TO_YCC          : boolean := false;
    F_SHP_TO_CGA          : boolean := false;
    F_SHP_TO_BLU          : boolean := false;
    F_BLU_TO_BLU          : boolean := false;
    F_BLU_TO_HSL          : boolean := false;
    F_BLU_TO_HSV          : boolean := false;
    F_BLU_TO_YCC          : boolean := false;
    F_BLU_TO_CGA          : boolean := false;
    F_BLU_TO_SHP          : boolean := false;
    img_width             : integer := 4096;
    img_height            : integer := 4096;
    i_data_width          : integer := 8);
port (
    clk                : in std_logic;
    rst_l              : in std_logic;
    txCord             : in coord;
    lumThreshold       : in  std_logic_vector(7 downto 0);
    iRgb               : in channel;
    iKcoeff            : in kernelCoeff;
    edgeValid          : out std_logic;
    oRgb               : out frameColors);
end Filters;
architecture Behavioral of Filters is
signal rgbImageKernel   : colors;
constant init_channel   : channel := (valid => lo, red => black, green => black, blue => black);
signal location         : cord := (x => 40, y => 10);
signal fRgb             : frameColors;
signal sEdgeValid       : std_logic;
begin
    edgeValid           <= sEdgeValid;
    oRgb                <= fRgb;
ImageKernelInst: Kernel
generic map(
    INRGB_FRAME         => F_RGB,
    RGBLP_FRAME         => F_LUM,
    RGBTR_FRAME         => F_TRM,
    SHARP_FRAME         => F_SHP,
    BLURE_FRAME         => F_BLU,
    EMBOS_FRAME         => F_EMB,
    YCBCR_FRAME         => F_YCC,
    SOBEL_FRAME         => F_SOB,
    CGAIN_FRAME         => F_CGA,
    HSV_FRAME           => F_HSV,
    HSL_FRAME           => F_HSL,
    img_width           => img_width,
    img_height          => img_height,
    i_data_width        => i_data_width)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    txCord              => txCord,
    lumThreshold        => lumThreshold,
    iRgb                => iRgb,
    iKcoeff             => iKcoeff,
    oEdgeValid          => sEdgeValid,
    oRgb                => rgbImageKernel);
CGA_TO_FILTRS1_FRAME_ENABLE: if (F_CGA_TO_HSV = true) or (F_CGA_TO_HSL = true) or (F_CGA_TO_YCC = true)  or (F_CGA_TO_SHP = true) or (F_CGA_TO_BLU = true) or (F_CGA_TO_CGA = true)generate
signal fRgb1             : colors;
begin
ImageKernelInst: Kernel
generic map(
    INRGB_FRAME         => false,
    RGBLP_FRAME         => F_LUM,
    RGBTR_FRAME         => F_TRM,
    SHARP_FRAME         => F_CGA_TO_SHP,
    BLURE_FRAME         => F_CGA_TO_BLU,
    EMBOS_FRAME         => false,
    YCBCR_FRAME         => F_CGA_TO_YCC,
    SOBEL_FRAME         => false,
    CGAIN_FRAME         => F_CGA_TO_CGA,
    HSV_FRAME           => F_CGA_TO_HSV,
    HSL_FRAME           => F_CGA_TO_HSL,
    img_width           => img_width,
    img_height          => img_height,
    i_data_width        => i_data_width)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    txCord              => txCord,
    lumThreshold        => lumThreshold,
    iRgb                => rgbImageKernel.cgain,
    iKcoeff             => iKcoeff,
    oEdgeValid          => sEdgeValid,
    oRgb                => fRgb1);
    fRgb.cgainToHsl     <= fRgb1.hsl;
    fRgb.cgainToHsv     <= fRgb1.hsv;
    fRgb.cgainToYcbcr   <= fRgb1.ycbcr;
    fRgb.cgainToShp     <= fRgb1.sharp;
    fRgb.cgainToBlu     <= fRgb1.blur;
    fRgb.cgainToCgain   <= fRgb1.cgain;
end generate CGA_TO_FILTRS1_FRAME_ENABLE;
SHP_TO_FILTRS2_FRAME_ENABLE: if (F_SHP_TO_HSV = true) or (F_SHP_TO_HSL = true) or (F_SHP_TO_YCC = true)  or (F_SHP_TO_SHP = true) or (F_SHP_TO_BLU = true) or (F_SHP_TO_CGA = true) generate
signal fRgb2             : colors;
begin
ImageKernelInst: Kernel
generic map(
    INRGB_FRAME         => false,
    RGBLP_FRAME         => F_LUM,
    RGBTR_FRAME         => F_TRM,
    SHARP_FRAME         => F_SHP_TO_SHP,
    BLURE_FRAME         => F_SHP_TO_BLU,
    EMBOS_FRAME         => false,
    YCBCR_FRAME         => F_SHP_TO_YCC,
    SOBEL_FRAME         => false,
    CGAIN_FRAME         => F_SHP_TO_CGA,
    HSV_FRAME           => F_SHP_TO_HSV,
    HSL_FRAME           => F_SHP_TO_HSL,
    img_width           => img_width,
    img_height          => img_height,
    i_data_width        => i_data_width)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    txCord              => txCord,
    lumThreshold        => lumThreshold,
    iRgb                => rgbImageKernel.sharp,
    iKcoeff             => iKcoeff,
    oEdgeValid          => sEdgeValid,
    oRgb                => fRgb2);
    fRgb.shpToHsl       <= fRgb2.hsl;
    fRgb.shpToHsv       <= fRgb2.hsv;
    fRgb.shpToYcbcr     <= fRgb2.ycbcr;
    fRgb.shpToShp       <= fRgb2.sharp;
    fRgb.shpToBlu       <= fRgb2.blur;
    fRgb.shpToCgain     <= fRgb2.cgain;
end generate SHP_TO_FILTRS2_FRAME_ENABLE;
BLU_TO_FILTRS3_FRAME_ENABLE: if (F_BLU_TO_HSV = true) or (F_BLU_TO_HSL = true) or (F_BLU_TO_YCC = true)  or (F_BLU_TO_SHP = true) or (F_BLU_TO_BLU = true) or (F_BLU_TO_CGA = true) generate
signal fRgb3             : colors;
begin
ImageKernelInst: Kernel
generic map(
    INRGB_FRAME         => false,
    RGBLP_FRAME         => F_LUM,
    RGBTR_FRAME         => F_TRM,
    SHARP_FRAME         => F_BLU_TO_SHP,
    BLURE_FRAME         => F_BLU_TO_BLU,
    EMBOS_FRAME         => false,
    YCBCR_FRAME         => F_BLU_TO_YCC,
    SOBEL_FRAME         => false,
    CGAIN_FRAME         => F_BLU_TO_CGA,
    HSV_FRAME           => F_BLU_TO_HSV,
    HSL_FRAME           => F_BLU_TO_HSL,
    img_width           => img_width,
    img_height          => img_height,
    i_data_width        => i_data_width)
port map(
    clk                 => clk,
    rst_l               => rst_l,
    txCord              => txCord,
    lumThreshold        => lumThreshold,
    iRgb                => rgbImageKernel.sharp,
    iKcoeff             => iKcoeff,
    oEdgeValid          => sEdgeValid,
    oRgb                => fRgb3);
    fRgb.bluToHsl       <= fRgb3.hsl;
    fRgb.bluToHsv       <= fRgb3.hsv;
    fRgb.bluToYcc       <= fRgb3.ycbcr;
    fRgb.bluToShp       <= fRgb3.sharp;
    fRgb.bluToBlu       <= fRgb3.blur;
    fRgb.bluToCga       <= fRgb3.cgain;
end generate BLU_TO_FILTRS3_FRAME_ENABLE;
TEST_FRAME_ENABLE: if (F_TES = true) generate
    signal ChannelSelect      : integer := 0;
    signal rgbSum             : tpRgb;
begin
frameTestPatternInst: frameTestPattern
generic map(
    s_data_width        => s_data_width)
port map(   
    clk                 => clk,
    iValid              => iRgb.valid,
    iCord               => txCord,
    oRgb                => rgbSum);
process (clk) begin
    if rising_edge(clk) then
        if(ChannelSelect = 0)then
            fRgb.tPattern.valid     <= rgbSum.valid;
            fRgb.tPattern.red       <= rgbSum.red(7 downto 0);
            fRgb.tPattern.green     <= rgbSum.green(7 downto 0);
            fRgb.tPattern.blue      <= rgbSum.blue(7 downto 0);
        elsif(ChannelSelect = 1)then
            fRgb.tPattern.valid     <= rgbSum.valid;
            fRgb.tPattern.red       <= x"0" & rgbSum.red(3 downto 0);
            fRgb.tPattern.green     <= x"0" & rgbSum.green(7 downto 4);
            fRgb.tPattern.blue      <= x"0" & rgbSum.blue(11 downto 8);
        elsif(ChannelSelect = 2)then
            fRgb.tPattern.valid     <= rgbSum.valid;
            fRgb.tPattern.red       <= rgbSum.red(7 downto 0);
            fRgb.tPattern.green     <= x"0" & rgbSum.green(7 downto 4);
            fRgb.tPattern.blue      <= x"0" & rgbSum.blue(11 downto 8);
        elsif(ChannelSelect = 3)then
            fRgb.tPattern.valid     <= rgbSum.valid;
            fRgb.tPattern.red       <= x"0" & rgbSum.red(3 downto 0);
            fRgb.tPattern.green     <= rgbSum.green(7 downto 0);
            fRgb.tPattern.blue      <= x"0" & rgbSum.blue(11 downto 8);
        else
            fRgb.tPattern.valid     <= rgbSum.valid;
            fRgb.tPattern.red       <= x"0" & rgbSum.red(3 downto 0);
            fRgb.tPattern.green     <= x"0" & rgbSum.green(7 downto 4);
            fRgb.tPattern.blue      <= rgbSum.blue(7 downto 0);
        end if;
    end if;
end process;
end generate TEST_FRAME_ENABLE;
MASK_SOB_CGA_FRAME_ENABLE: if (M_SOB_CGA = true) generate
    signal cgain2t    : channel;
    signal tp2        : std_logic_vector(23 downto 0) := (others => '0');
    signal tpValid    : std_logic  := lo;
begin
TapsControllerSobCgaInst: TapsController
generic map(
    img_width    => img_width,
    tpDataWidth  => 24)
port map(
    clk          => clk,
    rst_l        => rst_l,
    iRgb         => rgbImageKernel.cgain,
    tpValid      => tpValid,
    tp0          => open,
    tp1          => open,
    tp2          => tp2);
process (clk,rst_l) begin
    if (rst_l = lo) then
        cgain2t.red   <= (others => '0');
        cgain2t.green <= (others => '0');
        cgain2t.blue  <= (others => '0');
        cgain2t.valid <= lo;
    elsif rising_edge(clk) then
        cgain2t.red   <= tp2(23 downto 16);
        cgain2t.green <= tp2(15 downto 8);
        cgain2t.blue  <= tp2(7 downto 0);
        cgain2t.valid <= tpValid;
    end if; 
end process;
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => cgain2t,
    oRgb        => fRgb.maskSobelCga);
end generate MASK_SOB_CGA_FRAME_ENABLE;
MASK_SOB_TRM_FRAME_ENABLE: if (M_SOB_TRM = true) generate
begin
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.colorTrm,
    oRgb        => fRgb.maskSobelTrm);
end generate MASK_SOB_TRM_FRAME_ENABLE; 
MASK_SOB_HSL_FRAME_ENABLE: if (M_SOB_HSL = true) generate
begin
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.hsl,
    oRgb        => fRgb.maskSobelHsl);
end generate MASK_SOB_HSL_FRAME_ENABLE;  
MASK_SOB_HSV_FRAME_ENABLE: if (M_SOB_HSV = true) generate
begin
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.hsv,
    oRgb        => fRgb.maskSobelHsv);
end generate MASK_SOB_HSV_FRAME_ENABLE; 
MASK_SOB_YCC_FRAME_ENABLE: if (M_SOB_YCC = true) generate
begin
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.ycbcr,
    oRgb        => fRgb.maskSobelYcc);
end generate MASK_SOB_YCC_FRAME_ENABLE;   
MASK_SOB_SHP_FRAME_ENABLE: if (M_SOB_SHP = true) generate
begin
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.sharp,
    oRgb        => fRgb.maskSobelShp);
end generate MASK_SOB_SHP_FRAME_ENABLE;
MASK_SOB_RGB_FRAME_ENABLE: if (M_SOB_RGB = true) generate
begin
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.inrgb,
    oRgb        => fRgb.maskSobelRgb);
end generate MASK_SOB_RGB_FRAME_ENABLE;
MASK_SOB_LUM_FRAME_ENABLE: if (M_SOB_LUM = true) generate
begin
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.colorLmp,
    oRgb        => fRgb.maskSobelLum);
end generate MASK_SOB_LUM_FRAME_ENABLE;
MASK_SOB_BLU_FRAME_ENABLE: if (M_SOB_BLU = true) generate
begin
FrameMaskInst: FrameMask
generic map (
    eBlack       => true)
port map(            
    clk         => clk,
    iEdgeValid  => sEdgeValid,
    i1Rgb       => rgbImageKernel.sobel,
    i2Rgb       => rgbImageKernel.blur,
    oRgb        => fRgb.maskSobelBlu);
end generate MASK_SOB_BLU_FRAME_ENABLE;
INRGB_FRAME_ENABLE: if (F_RGB = true) generate
begin
TextGenInrgbInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "INRGB")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.inrgb,
    oRgb     => fRgb.inrgb);
end generate INRGB_FRAME_ENABLE;
YCBCR_FRAME_ENABLE: if (F_YCC = true) generate
begin
TextGenYcbcrInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "YCBCR")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.ycbcr,
    oRgb     => fRgb.ycbcr);
end generate YCBCR_FRAME_ENABLE;
SHARP_FRAME_ENABLE: if (F_SHP = true) generate
begin
TextGenSharpInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "SHARP")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.sharp,
    oRgb     => fRgb.sharp);
end generate SHARP_FRAME_ENABLE;
BLURE_FRAME_ENABLE: if (F_BLU = true) generate
begin
TextGenBlurInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "BLUR")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.blur,
    oRgb     => fRgb.blur);
end generate BLURE_FRAME_ENABLE;
EMBOS_FRAME_ENABLE: if (F_EMB = true) generate
begin
TextGenEmbossInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "EMBOSS")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.embos,
    oRgb     => fRgb.embos);
end generate EMBOS_FRAME_ENABLE;
SOBEL_FRAME_ENABLE: if (F_SOB = true) generate
begin
TextGenSobelInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "SOBEL")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.sobel,
    oRgb     => fRgb.sobel);
end generate SOBEL_FRAME_ENABLE;
CGAIN_FRAME_ENABLE: if (F_CGA = true) generate
begin
TextGenCgainInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "CGAIN")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.cgain,
    oRgb     => fRgb.cgain);
end generate CGAIN_FRAME_ENABLE;
HSL_FRAME_ENABLE: if (F_HSL = true) generate
begin
TextGenHslInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "HSL")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.hsl,
    oRgb     => fRgb.hsl);
end generate HSL_FRAME_ENABLE;
HSV_FRAME_ENABLE: if (F_HSV = true) generate
begin
TextGenHsvInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "HSV")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.hsv,
    oRgb     => fRgb.hsv);
end generate HSV_FRAME_ENABLE;
LUM_FRAME_ENABLE: if (F_LUM = true) generate
begin
TextGenHsvInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "LUM")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.colorLmp,
    oRgb     => fRgb.colorLmp);
end generate LUM_FRAME_ENABLE;
TRM_FRAME_ENABLE: if (F_TRM = true) generate
begin
TextGenTrmInst: TextGen
generic map (
    img_width     => img_width,
    img_height    => img_height,
    displayText   => "TRM")
port map(            
    clk      => clk,
    rst_l    => rst_l,
    txCord   => txCord,
    location => location,
    iRgb     => rgbImageKernel.colorTrm,
    oRgb     => fRgb.colorTrm);
end generate TRM_FRAME_ENABLE;
MASK_SOB_CGA_FRAME_DISABLED: if (M_SOB_CGA = false) generate
    fRgb.maskSobelCga  <= init_channel;
end generate MASK_SOB_CGA_FRAME_DISABLED;
MASK_SOB_TRM_FRAME_DISABLED: if (M_SOB_TRM = false) generate
    fRgb.maskSobelTrm  <= init_channel;
end generate MASK_SOB_TRM_FRAME_DISABLED;
MASK_SOB_HSL_FRAME_DISABLED: if (M_SOB_HSL = false) generate
    fRgb.maskSobelHsl  <= init_channel;
end generate MASK_SOB_HSL_FRAME_DISABLED;
MASK_SOB_HSV_FRAME_DISABLED: if (M_SOB_HSV = false) generate
    fRgb.maskSobelHsv  <= init_channel;
end generate MASK_SOB_HSV_FRAME_DISABLED;
MASK_SOB_YCC_FRAME_DISABLED: if (M_SOB_YCC = false) generate
    fRgb.maskSobelYcc  <= init_channel;
end generate MASK_SOB_YCC_FRAME_DISABLED;
MASK_SOB_SHP_FRAME_DISABLED: if (M_SOB_SHP = false) generate
    fRgb.maskSobelShp  <= init_channel;
end generate MASK_SOB_SHP_FRAME_DISABLED;
MASK_SOB_RGB_FRAME_DISABLED: if (M_SOB_RGB = false) generate
    fRgb.maskSobelRgb  <= init_channel;
end generate MASK_SOB_RGB_FRAME_DISABLED;
MASK_SOB_LUM_FRAME_DISABLED: if (M_SOB_LUM = false) generate
    fRgb.maskSobelLum  <= init_channel;
end generate MASK_SOB_LUM_FRAME_DISABLED;
MASK_SOB_BLU_FRAME_DISABLED: if (M_SOB_BLU = false) generate
    fRgb.maskSobelBlu  <= init_channel;
end generate MASK_SOB_BLU_FRAME_DISABLED;
LUM_FRAME_DISABLED: if (F_LUM = false) generate
    fRgb.colorLmp  <= init_channel;
end generate LUM_FRAME_DISABLED;
TRM_FRAME_DISABLED: if (F_TRM = false) generate
    fRgb.colorTrm  <= init_channel;
end generate TRM_FRAME_DISABLED;
INRGB_FRAME_DISABLED: if (F_RGB = false) generate
    fRgb.inrgb     <= init_channel;
end generate INRGB_FRAME_DISABLED;
YCBCR_FRAME_DISABLED: if (F_YCC = false) generate
    fRgb.ycbcr     <= init_channel;
end generate YCBCR_FRAME_DISABLED;
SHARP_FRAME_DISABLED: if (F_SHP = false) generate
    fRgb.sharp     <= init_channel;
end generate SHARP_FRAME_DISABLED;
BLURE_FRAME_DISABLED: if (F_BLU = false) generate
    fRgb.blur     <= init_channel;
end generate BLURE_FRAME_DISABLED;
EMBOS_FRAME_DISABLED: if (F_EMB = false) generate
    fRgb.embos     <= init_channel;
end generate EMBOS_FRAME_DISABLED;
SOBEL_FRAME_DISABLED: if (F_SOB = false) generate
    fRgb.sobel     <= init_channel;
end generate SOBEL_FRAME_DISABLED;
CGAIN_FRAME_DISABLED: if (F_CGA = false) generate
    fRgb.cgain     <= init_channel;
end generate CGAIN_FRAME_DISABLED;
HSL_FRAME_DISABLED: if (F_HSL = false) generate
    fRgb.hsl     <= init_channel;
end generate HSL_FRAME_DISABLED;
HSV_FRAME_DISABLED: if (F_HSV = false) generate
    fRgb.hsv     <= init_channel;
end generate HSV_FRAME_DISABLED;
end Behavioral;