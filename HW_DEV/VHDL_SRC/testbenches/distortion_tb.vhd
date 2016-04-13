-------------------------------------------------------------------------------
-- Title      : Testbench for design "distortion"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : distortion_tb.vhd
-- Author     : Daniel Glaser
-- Company    : 
-- Created    : 2007-09-25
-- Last update: 2007-09-25
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-09-25  1.0      sidaglas	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity distortion_tb is

end distortion_tb;

-------------------------------------------------------------------------------

architecture dist_test of distortion_tb is

  component distortion
    generic (
      MAX_ORDER   : natural;
      ORDER_WIDTH : positive;
      DATA_WIDTH  : positive);
    port (
      CLK_IN     : in  std_logic;
      nRESET     : in  std_logic;
      DVAL_IN    : in  std_logic;
      DVAL_OUT   : out std_logic;
      DATA_IN    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      COEFF_ADDR : out std_logic_vector(ORDER_WIDTH-1 downto 0);
      COEFF_DATA : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      DATA_OUT   : out std_logic_vector(DATA_WIDTH-1 downto 0);
      DEBUG      : in  std_logic_vector(35 downto 0));
  end component;

  -- component generics
  constant MAX_ORDER   : natural  := 7;
  constant ORDER_WIDTH : positive := 3;
  constant DATA_WIDTH  : positive := 16;

  -- component ports
  signal CLK_IN     : std_logic;
  signal nRESET     : std_logic;
  signal DVAL_IN    : std_logic;
  signal DVAL_OUT   : std_logic;
  signal DATA_IN    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal COEFF_ADDR : std_logic_vector(ORDER_WIDTH-1 downto 0);
  signal COEFF_DATA : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal DATA_OUT   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal DEBUG      : std_logic_vector(35 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- dist_test

  -- component instantiation
  DUT: distortion
    generic map (
      MAX_ORDER   => MAX_ORDER,
      ORDER_WIDTH => ORDER_WIDTH,
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      CLK_IN     => CLK_IN,
      nRESET     => nRESET,
      DVAL_IN    => DVAL_IN,
      DVAL_OUT   => DVAL_OUT,
      DATA_IN    => DATA_IN,
      COEFF_ADDR => COEFF_ADDR,
      COEFF_DATA => COEFF_DATA,
      DATA_OUT   => DATA_OUT,
      DEBUG      => DEBUG);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    
    wait until Clk = '1';
  end process WaveGen_Proc;

  

end dist_test;

-------------------------------------------------------------------------------

configuration distortion_tb_dist_test_cfg of distortion_tb is
  for dist_test
  end for;
end distortion_tb_dist_test_cfg;

-------------------------------------------------------------------------------
