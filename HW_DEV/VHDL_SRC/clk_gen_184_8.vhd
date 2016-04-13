-------------------------------------------------------------------------------
-- Title      : Clock Generator for 18.4 and 8 MHz
-- Project    : 
-------------------------------------------------------------------------------
-- File       : clk_gen_184_8.vhd
-- Author     : 
-- Company    : 
-- Created    : 2009-02-27
-- Last update: 2009-03-14
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2009 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2009-02-27  1.0      glaser  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity clk_gen_184_8 is
  
  port (
    CLK_IN_8        : in  std_logic;
    CLK_IN_18       : in  std_logic;
    CLKIN_IBUFG_OUT : out std_logic;
    RESET           : in  std_logic;
    CLK_18_OUT      : out std_logic;
    CLK_8_OUT       : out std_logic;
    LOCKED          : out std_logic);

end clk_gen_184_8;

architecture behavioral of clk_gen_184_8 is

  component clk_gen_18_4_to_8
    port(
      CLKIN_IN        : in  std_logic;
      RST_IN          : in  std_logic;
      CLKFX_OUT       : out std_logic;
      CLKIN_IBUFG_OUT : out std_logic;
      CLK0_OUT        : out std_logic;
      LOCKED_OUT      : out std_logic
      );
  end component;

  signal sl_clkfx_8  : std_logic;
  signal sl_clk0_184 : std_logic;
  signal sl_locked_8 : std_logic;

  component clk_gen_8_to_18_4
    port(
      CLKIN_IN        : in  std_logic;
      RST_IN          : in  std_logic;
      CLKFX_OUT       : out std_logic;
      CLKIN_IBUFG_OUT : out std_logic;
      CLK0_OUT        : out std_logic;
      LOCKED_OUT      : out std_logic
      );
  end component;

  signal sl_clkfx_184  : std_logic;
  signal sl_clk0_8     : std_logic;
  signal sl_locked_184 : std_logic;

begin  -- behavioral

  clk_gen_18_4_to_8_inst1 : clk_gen_18_4_to_8
    port map (
      CLKIN_IN        => CLK_IN_18,
      RST_IN          => RESET,
      CLKFX_OUT       => sl_clkfx_8,
      CLKIN_IBUFG_OUT => CLKIN_IBUFG_OUT,
      CLK0_OUT        => sl_clk0_184,
      LOCKED_OUT      => sl_locked_8);

  clk_gen_8_to_18_4_inst1 : clk_gen_8_to_18_4
    port map (
      CLKIN_IN        => CLK_IN_8,
      RST_IN          => RESET,
      CLKFX_OUT       => sl_clkfx_184,
      CLKIN_IBUFG_OUT => open,
      CLK0_OUT        => sl_clk0_8,
      LOCKED_OUT      => sl_locked_184);


  -- BUFGMUX: Global Clock Buffer 2-to-1 MUX
  --          Virtex-II/II-Pro/4/5, Spartan-3/3E/3A
  -- Xilinx HDL Language Template, version 10.1.3

  BUFGMUX_a : BUFGMUX
    port map (
      O  => CLK_18_OUT,                          -- Clock MUX output
      I0 => sl_clkfx_184,                         -- Clock0 input
      I1 => sl_clk0_184,                         -- Clock1 input
      S  => sl_locked_184                           -- Clock select input
      );

  BUFGMUX_b : BUFGMUX
    port map (
      O  => CLK_8_OUT,                          -- Clock MUX output
      I0 => sl_clkfx_8,                         -- Clock0 input
      I1 => sl_clk0_8,                         -- Clock1 input
      S  => sl_locked_8                           -- Clock select input
      );


--  CLK_18_OUT <= sl_clkfx_184 when sl_locked_184 = '1' else sl_clk0_184;
--  CLK_8_OUT  <= sl_clkfx_8   when sl_locked_8 = '1' else sl_clk0_8;
  LOCKED     <= sl_locked_8 or sl_locked_184;
  
end behavioral;
