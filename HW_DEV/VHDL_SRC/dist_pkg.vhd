-------------------------------------------------------------------------------
-- Title      : Distortion tools package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dist_pkg.vhd
-- Author     : Daniel Glaser
-- Company    : 
-- Created    : 2007-09-25
-- Last update: 2009-02-19
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2007-09-25  1.0      sidaglas        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

package dist_pack is

  function SHIFT_ROUND (
    INVECT : std_logic_vector;
    COUNT  : integer) return std_logic_vector;

  function fixed_to_fixed (
    INVECT                        : std_logic_vector;
    INT_IN_WIDTH, INT_OUT_WIDTH   : positive;
    FRAC_IN_WIDTH, FRAC_OUT_WIDTH : natural) return std_logic_vector;

--  function mul_fixed(
--    FACTOR1, FACTOR2              : std_logic_vector;
--    INT_IN_WIDTH, INT_OUT_WIDTH   : positive;
--    FRAC_IN_WIDTH, FRAC_OUT_WIDTH : natural) return std_logic_vector;

--  function add_fixed(
--    SUM1, SUM2                    : std_logic_vector;
--    INT_IN_WIDTH, INT_OUT_WIDTH   : positive;
--    FRAC_IN_WIDTH, FRAC_OUT_WIDTH : natural) return std_logic_vector;

end dist_pack;

package body dist_pack is

  function max (in1, in2 : integer) return integer is
    variable result : integer;
  begin
    if in1 < in2 then
      result := in2;
    else
      result := in1;
    end if;
    return result;
  end;

  function SHIFT_ROUND (INVECT : std_logic_vector; COUNT : integer) return std_logic_vector is
    variable vv_tmp : std_logic_vector(INVECT'range);
    variable vn_tmp : natural;
  begin
    vn_tmp := abs(COUNT);
    if COUNT = 0 then
      vv_tmp := INVECT;
    elsif COUNT < 0 then
      vv_tmp := SHR_ROUND(INVECT, vn_tmp);
    elsif COUNT > 0 then
      vv_tmp := SHL_ROUND(INVECT, vn_tmp);
    end if;
    return vv_tmp;
  end;

  function SHR_ROUND (INVECT : std_logic_vector; COUNT : natural) return std_logic_vector is
    variable vv_tmp : std_logic_vector(INVECT'range);
  begin  -- SHR_ROUND
    assert INVECT'length > COUNT
      report "SHR_ROUND: Count is greater than vector, makes no sense"
      severity warning;
    vv_tmp := INVECT;
    for i in 0 to COUNT-1 loop
      if vv_tmp(0) = '1' and (not vv_tmp(vv_tmp'left-1 downto 1)) = 0 then
        vv_tmp(vv_tmp'left-1 downto 1) := vv_tmp(vv_tmp'left-1 downto 1) + 1;
      end if;
      vv_tmp := vv_tmp(vv_tmp'left) & vv_tmp(vv_tmp'left) & vv_tmp(vv_tmp'left-1 downto 1);
    end loop;  -- i
    return vv_tmp;
  end SHR_ROUND;

  function SHL_ROUND (INVECT : std_logic_vector, COUNT : natural) return std_logic_vector is
    variable vv_tmp : std_logic_vector(INVECT'range);
  begin  -- SHL_ROUND
    assert INVECT'length > COUNT
      report "SHL_ROUND: Count is greater than vector, makes no sense"
      severity warning;
    vv_tmp := INVECT;
    for i in 0 to COUNT-1 loop
      if (vv_tmp(vv_tmp'left) = '1' and vv_tmp(vv_tmp'left-1) = '1') then
        vv_tmp := (others => '1');
      else
        vv_tmp := vv_tmp(vv_tmp'left) & vv_tmp(vv_tmp'left-2 downto 0) & vv_tmp(0);
      end if;
    end loop;  -- i
    return vv_tmp;
  end SHL_ROUND;
  
  function fixed_to_fixed(
    INVECT                        : std_logic_vector;
    INT_IN_WIDTH, INT_OUT_WIDTH   : positive;
    FRAC_IN_WIDTH, FRAC_OUT_WIDTH : natural) return std_logic_vector is

    variable vv_int_in   : std_logic_vector(INT_IN_WIDTH-1 downto 0);
    variable vv_int_out  : std_logic_vector(INT_OUT_WIDTH-1 downto 0);
    variable vl_round_up : std_logic;
    variable vv_frac_in  : std_logic_vector(FRAC_IN_WIDTH-1 downto 0);
    variable vv_frac_out : std_logic_vector(FRAC_OUT_WIDTH-1 downto 0);
    variable vv_tmp      : std_logic_vector(INT_OUT_WIDTH+FRAC_OUT_WIDTH-1 downto 0);
  begin
    assert INT_IN_WIDTH+FRAC_IN_WIDTH = INVECT'length
      report "fixed_to_fixed: INVECT is not the length as specified by INT and FRAC sizes"
      severity warning;
    
    vv_int_in  := INVECT(INVECT'left downto INVECT'length-INT_IN_WIDTH);
    vv_frac_in := INVECT(FRAC_IN_WIDTH-1 downto 0);

    -- Handling integer part of the fixed number
    if INT_OUT_WIDTH > INT_IN_WIDTH then
      -- Extend the integer (no further processing needed)
      vv_int_out := SXT(vv_int_in, vv_int_out'length);
    elsif INT_OUT_WIDTH < INT_IN_WIDTH then
      -- Reduce the integer (avoid roll over, means: limit the values)
      if (not vv_int_in(vv_int_in'left-1 downto vv_int_out'length)) = 0 then
        vv_int_out(vv_int_out'left) := vv_int_in(vv_int_in'left);
        if vv_int_in(vv_int_out'left) = '1' then
          -- maximize negative value ("10000...")
          vv_int_out(vv_int_out'left-1 downto 0) := (others => '0');
        else
          -- maximize positive value ("01111...")
          vv_int_out(vv_int_out'left-1 downto 0) := (others => '1');
        end if;
      else
        vv_int_out := vv_int_in(vv_int_in'left) & vv_int_in(vv_int_out'left-1 downto 0);
      end if;
    else
      -- Same int length, no conversion
      vv_int_out := vv_int_in
    end if;

    -- Handling the fractional part
    if FRAC_OUT_WIDTH > FRAC_IN_WIDTH then
      -- Extend and shift left without sign
      vv_frac_out                                                           := (others => '0');
      vv_frac_out(vv_frac_out'left downto vv_frac_out'length-FRAC_IN_WIDTH) := vv_frac_in;
    elsif FRAC_OUT_WIDTH < FRAC_IN_WIDTH then
      -- Reduce the size and round
      vv_frac_out := vv_frac_in(vv_frac_in'left downto vv_frac_in'length-FRAC_OUT_WIDTH);
      if ((vv_frac_in(vv_frac_in'left-FRAC_IN_WIDTH) = '1')
          and ((not vv_frac_out) /= 0)) then
        vv_frac_out := vv_frac_out + 1;
      end if;
    else
      -- Same fractional length, no conversion
      vv_frac_out := vv_frac_in;
    end if;

    vv_tmp := vv_int_out & vv_frac_out;

    return vv_tmp;
    
  end;
  
end dist_pack;
