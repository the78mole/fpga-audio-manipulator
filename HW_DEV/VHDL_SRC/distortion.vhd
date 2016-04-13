-------------------------------------------------------------------------------
-- Title      : Distortion
-- Project    : 
-------------------------------------------------------------------------------
-- File       : distortion.vhd
-- Author     : Daniel Glaser
-- Company    : 
-- Created    : 2007-09-21
-- Last update: 2008-01-23
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2007-09-21  1.0      sidaglas        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library work;
--use work.dist_pack.all;
  
entity distortion is
  
  generic (
    MAX_ORDER   : natural  := 7;
    ORDER_WIDTH : positive := 3;
    DATA_WIDTH  : positive := 16);

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

end distortion;

architecture behavioral of distortion is

  type tai_shift_amount is array (0 to MAX_ORDER) of integer;
  -- align values to max(cai_shift_amount)=0 to get best precision
  constant cai_shift_amount      : tai_shift_amount := (-1, 0, 0, 0, 0, 0, 0, 0);
  -- Set this to the reduction level of the output precision
  constant ci_shift_out          : integer          := -11;
  constant cn_shift_amount_width : natural          := 5;

  component ila_dist
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      data    : in std_logic_vector(222 downto 0);
      trig0   : in std_logic_vector(9 downto 0));
  end component;

  signal sv_cs_trigger : std_logic_vector(9 downto 0);
  signal sv_cs_data    : std_logic_vector(222 downto 0);

  component power_multiplier
    port (
      a : in  std_logic_vector(15 downto 0);
      b : in  std_logic_vector(15 downto 0);
      p : out std_logic_vector(31 downto 0));
  end component;

  signal sv_dval_pipe : std_logic_vector(MAX_ORDER+3 downto 0);

  signal sv_power_product, sv_power_product_reg : std_logic_vector(2*DATA_WIDTH-1 downto 0);
  signal sv_coeff_product, sv_coeff_product_reg : std_logic_vector(2*DATA_WIDTH-1 downto 0);
  signal sv_power_factor_a, sv_power_factor_b   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sv_coeff_factor_a, sv_coeff_factor_b   : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal sv_mac_sum  : std_logic_vector(2*DATA_WIDTH-1 downto 0);
  signal sv_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal sv_reg_data_in, sv_reg_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sv_pow_a_mux                    : std_logic_vector(1 downto 0);
  signal sl_add_a_mux                    : std_logic;
  signal sl_counter_state                : std_logic;

  signal sl_dval_out : std_logic;

begin  -- behavioral

  ila_dist_1 : ila_dist
    port map (
      control => DEBUG,
      clk     => CLK_IN,
      data    => sv_cs_data,
      trig0   => sv_cs_trigger);

  sv_cs_trigger(0)          <= DVAL_IN;
  sv_cs_trigger(9 downto 1) <= (others => '0');

  sv_cs_data(15 downto 0)    <= DATA_IN;
  sv_cs_data(16)             <= DVAL_IN;
  sv_cs_data(32 downto 17)   <= sv_power_factor_a;
  sv_cs_data(48 downto 33)   <= sv_power_factor_b;
  sv_cs_data(80 downto 49)   <= sv_power_product_reg;
  sv_cs_data(96 downto 81)   <= sv_coeff_factor_a;
  sv_cs_data(112 downto 97)  <= sv_coeff_factor_b;
  sv_cs_data(144 downto 113) <= sv_coeff_product_reg;
  sv_cs_data(160 downto 145) <= COEFF_DATA;
  sv_cs_data(192 downto 161) <= sv_mac_sum;
  sv_cs_data(203 downto 193) <= sv_dval_pipe;
  sv_cs_data(204)            <= sl_dval_out;
  sv_cs_data(220 downto 205) <= sv_data_out;
--  sv_cs_data(222 downto 221) <= COUNTER;

  power_multiplier_1 : power_multiplier
    port map (
      a => sv_power_factor_a,
      b => sv_power_factor_b,
      p => sv_power_product);

  proc_power : process (CLK_IN, nRESET)
    variable vl_dval_pre : std_logic;
  begin  -- process proc_power
    if nRESET = '0' then                -- asynchronous reset (active low)
      sv_power_factor_a <= (others => '0');
      sv_power_factor_b <= (others => '0');
      vl_dval_pre       := '0';
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      if (vl_dval_pre xor DVAL_IN) = '1' then
        sv_power_factor_a <= DATA_IN;
        sv_power_factor_b <= DATA_IN;
      else
        if sv_power_product(15) = '1' then
          sv_power_factor_a <= sv_power_product(31 downto 16) + 1;
        else
          sv_power_factor_a <= sv_power_product(31 downto 16);
        end if;
      end if;

      sv_power_product_reg <= sv_power_product;

      vl_dval_pre := DVAL_IN;
    end if;
  end process proc_power;

  coefficient_multiplier : power_multiplier
    port map (
      a => sv_coeff_factor_a,
      b => sv_coeff_factor_b,
      p => sv_coeff_product);

  proc_coeff_mult : process (CLK_IN, nRESET)
  begin  -- process proc_coeff_mult
    if nRESET = '0' then                -- asynchronous reset (active low)
      sv_coeff_factor_a    <= (others => '0');
      sv_coeff_factor_b    <= (others => '0');
      sv_coeff_product_reg <= (others => '0');
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      if ((sv_power_product_reg(DATA_WIDTH-1) = '1')
          and (not sv_power_product_reg(2*DATA_WIDTH-1 downto DATA_WIDTH) /= 0))  then
        -- Do some symmetric rounding
        sv_coeff_factor_a <= sv_power_product_reg(2*DATA_WIDTH-1 downto DATA_WIDTH) + 1;
      else
        sv_coeff_factor_a <= sv_power_product_reg(2*DATA_WIDTH-1 downto DATA_WIDTH);
      end if;
      sv_coeff_factor_b    <= COEFF_DATA;
      sv_coeff_product_reg <= sv_coeff_product;
    end if;
  end process proc_coeff_mult;

  proc_mac : process (CLK_IN, nRESET)
    constant ci_mac_sum_min    : integer := conv_integer(sv_mac_sum'low);
    constant ci_mac_sum_max    : integer := conv_integer(sv_mac_sum'high);
    constant ci_coeff_prod_min : integer := conv_integer(sv_coeff_product'low);
    constant ci_coeff_prod_max : integer := conv_integer(sv_coeff_product'high);
    variable vn_shift_index    : natural range 0 to MAX_ORDER;
    variable vn_shift_amount   : natural range 0 to 2**cn_shift_amount_width-1;
    variable vi_ouflow         : integer range -MAX_ORDER to MAX_ORDER;
    variable vi_mac_sum        : integer range ci_mac_sum_min to ci_mac_sum_max;
    variable vv_data_out       : std_logic_vector(DATA_OUT'range);
    variable vi_coeff_product  : integer range ci_coeff_prod_min to ci_coeff_prod_max;
    variable vv_shift_amount   : std_logic_vector(cn_shift_amount_width-1 downto 0);
    variable vv_mac_sum        : std_logic_vector(sv_mac_sum'range);
    variable vv_coeff_product  : std_logic_vector(sv_coeff_product'range);
  begin  -- process proc_mac
    if nRESET = '0' then                -- asynchronous reset (active low)
      sv_mac_sum <= (others => '0');
      vi_ouflow  := 0;
    elsif rising_edge(CLK_IN) then      -- rising clock edge

      -------------------------------------------------------------------------
      -- First align the coeff product correctly
      -------------------------------------------------------------------------

      -- Reset or count the coefficient index
      if sv_dval_pipe(1) = '1' then
        vn_shift_index := 0;
      elsif sv_dval_pipe(MAX_ORDER+2 downto 3) /= 0 then
        vn_shift_index := vn_shift_index + 1;
      end if;

      -- For shifting, we need vectors
      -- (defined in std_logic_signed: wrapper for SHL(SIGNED, UNSIGNED))
      vn_shift_amount := abs(cai_shift_amount(vn_shift_index));
      vv_shift_amount := conv_std_logic_vector(vn_shift_amount, cn_shift_amount_width);

      -- If x^0, we just need the coefficient, for others the product
      if sv_dval_pipe(0) = '1' then
        vv_coeff_product := SXT(COEFF_DATA & "000000", vv_coeff_product'length);  -- Virtually multiply with 1.000
      elsif sv_dval_pipe(MAX_ORDER+2 downto 3) /= 0 then
        vv_coeff_product := sv_coeff_product_reg;
      end if;

      -- We need a barrel shifter if synthesis doesn't evaluate the constants
      -- Perhaps we do it in a self expanded loop later
      if cai_shift_amount(vn_shift_index) < 0 then
        vv_coeff_product := SHR(vv_coeff_product, vv_shift_amount);
      elsif cai_shift_amount(vn_shift_index) > 0 then
        vv_coeff_product := SHL(vv_coeff_product, vv_shift_amount);
      end if;

      -------------------------------------------------------------------------
      -- Next feed it to the mac_sum
      -------------------------------------------------------------------------

      vi_coeff_product := conv_integer(vv_coeff_product);
      vi_mac_sum       := conv_integer(vv_mac_sum);

      if sv_dval_pipe(0) = '1' then
        vv_mac_sum := (others => '0');
        vi_ouflow  := 0;
--      elsif sv_dval_pipe(MAX_ORDER+2 downto 2) /= 0 then
      elsif sv_dval_pipe(1) = '1' or (sv_dval_pipe(MAX_ORDER+2 downto 3) /= 0) then
        if (((vi_coeff_product < 0) and ((ci_mac_sum_min - vi_coeff_product) < vi_mac_sum))
            or ((vi_coeff_product > 0) and ((ci_mac_sum_max - vi_coeff_product) > vi_mac_sum))) then
          -- We count the overflows, to see if it's in range [-1,1[ at the end
          if vi_coeff_product >= 0 then
            -- It's an overflow
            vi_ouflow := vi_ouflow + 1;
          else
            -- Seems to be an underflow
            vi_ouflow := vi_ouflow - 1;
            -- else it is the correct value
          end if;
          vv_mac_sum := vv_mac_sum - vv_coeff_product;
        else
          vv_mac_sum := vv_mac_sum + vv_coeff_product;
        end if;
      elsif sv_dval_pipe(MAX_ORDER+3) = '1' then
        if vi_ouflow < 0 then
          vv_mac_sum := conv_std_logic_vector(ci_mac_sum_min, vv_mac_sum'length);
        elsif vi_ouflow > 0 then
          vv_mac_sum := conv_std_logic_vector(ci_mac_sum_max, vv_mac_sum'length);
        end if;
        -- Align it correctly for output (reuse of vv_shift_amount)
        vv_shift_amount := conv_std_logic_vector(abs(ci_shift_out), cn_shift_amount_width);
        -- Round the result if won't get bigger than max
        if ((vv_mac_sum(conv_integer('0' & vv_shift_amount)-1) = '1')
            and (vv_shift_amount < 0)
            and ((not vv_mac_sum(vv_mac_sum'left downto conv_integer('0' & vv_shift_amount))) /= 0)) then
          vv_mac_sum := vv_mac_sum + 1;
        end if;
        if ci_shift_out > 0 then
          vv_data_out := SHL(vv_mac_sum, vv_shift_amount);
        elsif ci_shift_out < 0 then
          vv_data_out := SHR(vv_mac_sum, vv_shift_amount);
        end if;
      end if;

      -------------------------------------------------------------------------
      -- Last step, push it out
      -------------------------------------------------------------------------

      sv_mac_sum  <= vv_mac_sum;
      sv_data_out <= vv_data_out(DATA_OUT'range);  -- We hope it works as expected
      
    end if;
  end process proc_mac;

  sv_data_out <= sv_data_out;

  proc_dval : process (CLK_IN, nRESET)
    variable vl_dval_edge, vl_dval_pre : std_logic;
  begin  -- process proc_dval
    if nRESET = '0' then                -- asynchronous reset (active low)
      sv_dval_pipe <= (others => '0');
      vl_dval_pre  := '0';
    elsif rising_edge(CLK_IN) then      -- rising clock edge

      -------------------------------------------------------------------------
      -- PIPE
      --              EDGE      >>>>>>>>>SHIFT>>>>>>>>>
      --             +-----+   +---+---+-   ---+---+---+   +---+
      --             | ^   |   |   |   |       |   |   +---+>  |--> DVAL_OUT
      -- DVAL_IN >-+-+ | | +->-+   |   | ....  |   |   |   |   |
      --           | |   v |   |   |   |       |   |   | +-+ D |
      --           | +-----+   +---+---+---   -+---+---+ | +---+
      --           |                                     |
      --           +-------------------------------------+
      -------------------------------------------------------------------------

      -- Delay one to have absolutely stable data
      -- (not really needed, but reduces complexity for synthesis)
      DVAL_OUT <= sl_dval_out;

      if sv_dval_pipe(MAX_ORDER+3) = '1' then
        sl_dval_out <= DVAL_IN;
      end if;

      if (vl_dval_pre xor DVAL_IN) = '1' then
        vl_dval_edge := '1';
      else
        vl_dval_edge := '0';
      end if;

      sv_dval_pipe <= sv_dval_pipe(MAX_ORDER+2 downto 0) & vl_dval_edge;

      vl_dval_pre := DVAL_IN;
    end if;
  end process proc_dval;

  proc_addr_counter : process (CLK_IN, nRESET)
    variable vv_count    : std_logic_vector(COEFF_ADDR'range);
    variable vl_dval_pre : std_logic;
  begin  -- process proc_addr_counter
    if nRESET = '0' then                -- asynchronous reset (active low)
      vl_dval_pre := '0';
      vv_count    := (others => '0');
      COEFF_ADDR  <= (others => '0');
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      
      if (vl_dval_pre xor DVAL_IN) = '1' then
        vv_count := conv_std_logic_vector(1, vv_count'length);
      elsif vv_count /= conv_std_logic_vector(0, vv_count'length) then
        vv_count := vv_count + 1;
      end if;
      COEFF_ADDR                 <= vv_count;
      sv_cs_data(222 downto 221) <= vv_count(1 downto 0);

      vl_dval_pre := DVAL_IN;
      
    end if;
  end process proc_addr_counter;

end behavioral;
