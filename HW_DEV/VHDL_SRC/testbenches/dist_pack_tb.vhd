-------------------------------------------------------------------------------
-- Title      : Distortion Package Testbench
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dist_pack_tb.vhd
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
-- Date        Version  Author          Description
-- 2007-09-25  1.0      sidaglas	Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity dist_pkg_tb is
  
end dist_pkg_tb;


architecture dist_pack_test of dist_pkg_tb is

  signal sv_fixed_3_13 : std_logic_vector(15 downto 0);
  signal sv_fixed_5_15 : std_logic_vector(19 downto 0);
  signal sv_fixed_1_10 : std_logic_vector(10 downto 0);
  
begin  -- dist_pack_tb

  

end dist_pack_test;


