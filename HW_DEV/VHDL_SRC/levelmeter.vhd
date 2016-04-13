-------------------------------------------------------------------------------
-- Title      : Levelmeter
-- Project    : Praktikum zu Test Integrierter Schaltungen
-------------------------------------------------------------------------------
-- File       : levelmeter.vhd
-- Author     : Daniel Glaser
-- Company    : Chaintronics
-- Created    : 2006-11-01
-- Last update: 2007-09-21
-- Platform   : LFECP20E
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This module calculates the mean square of an audio signal. Be
--              careful with the output signal. It is an unsigned vector.
-------------------------------------------------------------------------------
-- Copyright (c) 2007 Daniel Glaser
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2006-11-01  1.0      sidaglas        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity levelmeter is
  
  generic (
    DATA_WIDTH        : positive := 8;
    INTEGRATION_WIDTH : positive := 10;
    INVERT_OUTPUT     : boolean  := false);

  port (
    CLK_IN   : in  std_logic;
    nRESET   : in  std_logic;
    DIN_VAL  : in  std_logic;
    DOUT_VAL : out std_logic;
    DATA_IN  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DATA_OUT : out std_logic_vector(DATA_WIDTH-1 downto 0));

end levelmeter;

architecture behavioral of levelmeter is

  -- Musterloesung Anfang
  constant cn_integration_time : natural := (2**INTEGRATION_WIDTH)-1;

  constant ci_data_min : integer := -(2**(DATA_WIDTH-1));
  constant ci_data_max : integer := (2**(DATA_WIDTH-1))-1;

  constant ci_square_min : integer := ci_data_min;
  constant ci_square_max : integer := ci_data_max;

--  constant ci_square_min : integer := -(2**(2*(DATA_WIDTH-1)-1));
--  constant ci_square_max : integer := (2**(2*(DATA_WIDTH-1)-1))-1;

  constant ci_acc_min : integer := -(2**(DATA_WIDTH+INTEGRATION_WIDTH-1));
  constant ci_acc_max : integer := (2**(DATA_WIDTH+INTEGRATION_WIDTH-1))-1;

--  constant ci_acc_min : integer := -(2**(2*(DATA_WIDTH+INTEGRATION_WIDTH-1)-1));
--  constant ci_acc_max : integer := (2**(2*(DATA_WIDTH+INTEGRATION_WIDTH-1)-1))-1;

  constant cn_acc_width : natural := DATA_WIDTH+INTEGRATION_WIDTH-1;

  signal sl_clear_intreg : std_logic;
  signal sl_reg_input    : std_logic;

  signal si_input_data : integer range ci_data_min to ci_data_max;

  -- pragma synthesis_off
  signal si_square     : integer range ci_square_min to ci_square_max;
  signal si_square_acc : integer range ci_acc_min to ci_acc_max;
  -- pragma synthesis_on

  -- Musterloesung Ende
  
begin  -- behavioral

  assert DATA_WIDTH < 17
    report "DATA_WIDTH must be equal or less than 16"
    severity error;
  assert INTEGRATION_WIDTH + DATA_WIDTH < 33
    report "DATA_WIDTH or INTEGRATION_WIDTH to large. DATA_WIDTH + INTEGRATION_WIDTH must be equal or less 32"
    severity error;
  -- Musterloesung Anfang
  proc_count_indata : process (CLK_IN, nRESET)
    variable vn_count        : natural range 0 to cn_integration_time;
    variable vl_dval_in_edge : std_logic := '0';
  begin  -- process proc_count_indata
    if nRESET = '0' then                -- asynchronous reset (active low)
      vn_count      := 1;
      si_input_data <= 0;
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      if vl_dval_in_edge = '0' and DIN_VAL = '1' then
        if vn_count = 0 then
          vn_count        := cn_integration_time;
          sl_clear_intreg <= '1';
        else
          sl_clear_intreg <= '0';
          vn_count        := vn_count - 1;
        end if;
        sl_reg_input  <= '1';
        si_input_data <= conv_integer(DATA_IN);
      else
        sl_reg_input <= '0';
      end if;
    end if;
  end process proc_count_indata;

  proc_square_and_acc_data : process (CLK_IN, nRESET)
    variable vi_square     : integer range ci_square_min to ci_square_max;
    variable vi_square_acc : integer range ci_acc_min to ci_acc_max;
    variable vv_output     : std_logic_vector(cn_acc_width-1 downto 0);
  begin  -- process proc_square_and_acc_data
    if nRESET = '0' then                -- asynchronous reset (active low)
      vi_square     := 0;
      vi_square_acc := 0;
      vv_output     := (others => '0');
      if INVERT_OUTPUT then
        DATA_OUT <= (others => '1');
      else
        DATA_OUT <= (others => '0');                    
      end if;
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      
      if sl_reg_input = '1' then
        if sl_clear_intreg = '1' then
          -- The following order of vv_output is intended
          vv_output := conv_std_logic_vector(vi_square_acc, cn_acc_width);
          for i in vv_output'left downto vv_output'left-DATA_WIDTH+1 loop
            if i /= 0 then
              vv_output(i-1) := vv_output(i-1) or vv_output(i);
            end if;
          end loop;  -- i
          -- Throwing away the first bit, because it's only the sign and so
          -- never set
          if INVERT_OUTPUT then
            DATA_OUT <= not vv_output(vv_output'left downto vv_output'left-DATA_WIDTH+1);
          else
            DATA_OUT <= vv_output(vv_output'left downto vv_output'left-DATA_WIDTH+1);
          end if;
          vi_square_acc := vi_square;
          DOUT_VAL      <= '1';
        else
          DOUT_VAL      <= '0';
          vi_square_acc := vi_square_acc + vi_square;
        end if;
        vi_square     := ((si_input_data * si_input_data)-1)/(2**(DATA_WIDTH-1));
        -- pragma synthesis_off
        si_square     <= vi_square;
        si_square_acc <= vi_square_acc;
        -- pragma synthesis_on
      end if;
      
    end if;
  end process proc_square_and_acc_data;
  -- Musterloesung Ende
  
end behavioral;

