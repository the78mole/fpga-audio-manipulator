-------------------------------------------------------------------------------
-- Title      : Reset Generator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : reset_gen.vhd
-- Author     : Daniel Glaser
-- Company    : 
-- Created    : 2008-01-22
-- Last update: 2008-01-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This module generates a power-up reset
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2008-01-22  1.0      sidaglas        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity reset_gen is
  
  generic (
    CLK_HOLD : natural := 65535);

  port (
    CLK_IN    : in  std_logic;
    NRESET_IN : in  std_logic;
    NRESET    : out std_logic;
    RESET     : out std_logic);

end reset_gen;

architecture behavioral of reset_gen is

-- pragma translate_off
  signal sv_init_counter : std_logic_vector(23 downto 0);
-- pragma translate_on
  
begin  -- behavioral

  gen_reset : process (CLK_IN, NRESET_IN)
    variable vv_init_counter : std_logic_vector(23 downto 0) := (others => '0');
  begin  -- process gen_reset
    if NRESET_IN = '0' then
      vv_init_counter := (others => '0');
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      if vv_init_counter /= conv_std_logic_vector(CLK_HOLD, 24) then
        vv_init_counter := vv_init_counter + 1;
        -- pragma translate_off
        -- For simulation we do reset very fast
        if vv_init_counter < conv_std_logic_vector(7*(CLK_HOLD/8), 24) then
          vv_init_counter := vv_init_counter + conv_std_logic_vector(CLK_HOLD/8, 24);
        else
          vv_init_counter := conv_std_logic_vector(CLK_HOLD, 24);
        end if;
        -- pragma translate_on
        NRESET <= '0';
        RESET  <= '1';
      else
        NRESET <= '1';
        RESET  <= '0';
      end if;
      -- pragma translate_off
      sv_init_counter <= vv_init_counter;
      -- pragma translate_on
    end if;
  end process gen_reset;

end behavioral;
