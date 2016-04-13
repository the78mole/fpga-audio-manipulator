-------------------------------------------------------------------------------
-- Title      : Testbench for design "toplevel"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : toplevel_tb.vhd
-- Author     : Daniel Glaser
-- Company    : 
-- Created    : 2008-01-24
-- Last update: 2008-01-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008-01-24  1.0      sidaglas        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity toplevel_tb is

end toplevel_tb;

-------------------------------------------------------------------------------

architecture tb_behavioral of toplevel_tb is

  component toplevel
    generic (
      SP_DATA_WIDTH : positive;
      AD_DATA_WIDTH : positive;
      DA_DATA_WIDTH : positive;
      INT_RESET     : boolean);
    port (
      CLK_IN         : in    std_logic;
      NRESET         : in    std_logic;
      BARGRAPH_LEFT  : out   std_logic_vector(6 downto 0);
      BARGRAPH_RIGHT : out   std_logic_vector(6 downto 0);
      DIP_SWITCHES   : in    std_logic_vector(7 downto 0);
      AD_CLK         : out   std_logic;
      AD_RST         : out   std_logic;
      AD_TAG         : in    std_logic;
      AD_LRCK        : in    std_logic;
      AD_WCLK        : in    std_logic;
      AD_BCLK        : in    std_logic;
      AD_SOUT        : in    std_logic;
      AD_RDEDGE      : out   std_logic;
      AD_SnM         : out   std_logic;
      AD_MSBDLY      : out   std_logic;
      AD_384_256     : out   std_logic;
      AD_RLJUST      : out   std_logic;
      DA_MCLK        : out   std_logic;
      DA_PD_RST      : out   std_logic;
      DA_BCLK        : out   std_logic;
      DA_LRCK        : out   std_logic;
      DA_SDATA       : out   std_logic;
      DA_MODE        : out   std_logic;
      DA_DEEMP       : out   std_logic;
      DA_MUTE        : out   std_logic;
      DA_384_256     : out   std_logic;
      UC_AD          : inout std_logic_vector(15 downto 0);
      UC_ALE         : in    std_logic;
      UC_nRD         : in    std_logic;
      UC_nWR         : in    std_logic);
  end component;

  -- component generics
  constant SP_DATA_WIDTH : positive := 24;
  constant AD_DATA_WIDTH : positive := 16;
  constant DA_DATA_WIDTH : positive := 16;
  constant INT_RESET     : boolean  := true;

  -- component ports
  signal CLK_IN         : std_logic;
  signal NRESET         : std_logic;
  signal BARGRAPH_LEFT  : std_logic_vector(6 downto 0);
  signal BARGRAPH_RIGHT : std_logic_vector(6 downto 0);
  signal DIP_SWITCHES   : std_logic_vector(7 downto 0);
  signal AD_CLK         : std_logic;
  signal AD_RST         : std_logic;
  signal AD_TAG         : std_logic;
  signal AD_LRCK        : std_logic;
  signal AD_WCLK        : std_logic;
  signal AD_BCLK        : std_logic;
  signal AD_SOUT        : std_logic;
  signal AD_RDEDGE      : std_logic;
  signal AD_SnM         : std_logic;
  signal AD_MSBDLY      : std_logic;
  signal AD_384_256     : std_logic;
  signal AD_RLJUST      : std_logic;
  signal DA_MCLK        : std_logic;
  signal DA_PD_RST      : std_logic;
  signal DA_BCLK        : std_logic;
  signal DA_LRCK        : std_logic;
  signal DA_SDATA       : std_logic;
  signal DA_MODE        : std_logic;
  signal DA_DEEMP       : std_logic;
  signal DA_MUTE        : std_logic;
  signal DA_384_256     : std_logic;
  signal UC_AD          : std_logic_vector(15 downto 0);
  signal UC_ALE         : std_logic;
  signal UC_nRD         : std_logic;
  signal UC_nWR         : std_logic;

  -- clock
  signal Clk : std_logic := '1';

  component i2s_transmitter
    generic (
      DATA_WIDTH     : positive;
      CLK_IN_PER_BCK : positive;
      BCK_PER_LRCK   : positive);
    port (
      CLK_IN : in  std_logic;
      nRESET : in  std_logic;
      LRCK   : out std_logic;
      BCK    : out std_logic;
      DOUT   : out std_logic;
      GAIN   : in  std_logic_vector(15 downto 0);
      DINL   : in  std_logic_vector(15 downto 0);
      DINR   : in  std_logic_vector(15 downto 0);
      DVAL   : in  std_logic);
  end component;

  signal sl_dval                   : std_logic;
  signal sv_gain, sv_dinl, sv_dinr : std_logic_vector(15 downto 0);
  
begin  -- tb_behavioral

  i2s_transmitter_1 : i2s_transmitter
    generic map (
      DATA_WIDTH     => 16,
      CLK_IN_PER_BCK => 6,
      BCK_PER_LRCK   => 64)
    port map (
      CLK_IN => CLK_IN,
      nRESET => NRESET,
      LRCK   => AD_LRCK,
      BCK    => AD_BCLK,
      DOUT   => AD_SOUT,
      GAIN   => conv_std_logic_vector(512, 16),
      DINL   => sv_dinl,
      DINR   => sv_dinr,
      DVAL   => sl_dval);

  -- component instantiation
  DUT : toplevel
    generic map (
      SP_DATA_WIDTH => SP_DATA_WIDTH,
      AD_DATA_WIDTH => AD_DATA_WIDTH,
      DA_DATA_WIDTH => DA_DATA_WIDTH,
      INT_RESET     => INT_RESET)
    port map (
      CLK_IN         => CLK_IN,
      NRESET         => NRESET,
      BARGRAPH_LEFT  => BARGRAPH_LEFT,
      BARGRAPH_RIGHT => BARGRAPH_RIGHT,
      DIP_SWITCHES   => DIP_SWITCHES,
      AD_CLK         => AD_CLK,
      AD_RST         => AD_RST,
      AD_TAG         => AD_TAG,
      AD_LRCK        => AD_LRCK,
      AD_WCLK        => AD_WCLK,
      AD_BCLK        => AD_BCLK,
      AD_SOUT        => AD_SOUT,
      AD_RDEDGE      => AD_RDEDGE,
      AD_SnM         => AD_SnM,
      AD_MSBDLY      => AD_MSBDLY,
      AD_384_256     => AD_384_256,
      AD_RLJUST      => AD_RLJUST,
      DA_MCLK        => DA_MCLK,
      DA_PD_RST      => DA_PD_RST,
      DA_BCLK        => DA_BCLK,
      DA_LRCK        => DA_LRCK,
      DA_SDATA       => DA_SDATA,
      DA_MODE        => DA_MODE,
      DA_DEEMP       => DA_DEEMP,
      DA_MUTE        => DA_MUTE,
      DA_384_256     => DA_384_256,
      UC_AD          => UC_AD,
      UC_ALE         => UC_ALE,
      UC_nRD         => UC_nRD,
      UC_nWR         => UC_nWR);

  -- clock generation
  Clk    <= not Clk after 20 ns;
  CLK_IN <= Clk;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    NRESET <= '1';
    wait until DA_MUTE = '0';
    wait for 42 ns;
    UC_AD <= (others => '0');
    UC_ALE <= '0';
    UC_nWR <= '1';
    UC_nRD <= '1';
    wait for 40 ns;
    UC_AD <= "1000000000000000";
    wait for 100 ns;
    UC_ALE <= '1';
    wait for 100 ns;
    UC_ALE <= '0';
    wait for 100 ns;
    UC_AD(7 downto 0) <= "00000111";
    wait for 100 ns;
    UC_nWR <= '0';
    wait for 100 ns;
    UC_nWR <= '1';
    
    wait;
  end process WaveGen_Proc;

  

end tb_behavioral;

-------------------------------------------------------------------------------

configuration toplevel_tb_tb_behavioral_cfg of toplevel_tb is
  for tb_behavioral
  end for;
end toplevel_tb_tb_behavioral_cfg;

-------------------------------------------------------------------------------
