-------------------------------------------------------------------------------
-- Title      : Toplevel for Test laboratory
-- Project    : Test Laboratory
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Daniel Glaser
-- Company    : LRS, Chair for Computer Assisted Circuit Design
-- Created    : 2007-08-07
-- Last update: 2009-03-14
-- Platform   : XC3S500E
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This Project aims at developing a test laboratory for testing
--              the non-ideal effects of analog to digital converters like
--              differential and integral nonlinearity, noise and other
--              characteristic curve deviations. The board is made of an fpga
--              from Xilinxs' Spartan 3E series of fpgas and an Atmel ATMega64
--              for controlling the behavior of distortions and noise.
-------------------------------------------------------------------------------
-- Copyright (c) 2007 LRS, Daniel Glaser
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2007-08-07  1.0      sidaglas        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

-- pragma translate_off
library XilinxCoreLib;

library unisim;
use unisim.vcomponents.all;
-- pragma translate_on

entity toplevel is

  port (
    CLK_8_IN   : in  std_logic;
    CLK_18_IN  : in  std_logic;
    -- ATE interface
    ATE_RDY    : out std_logic;
    ATE_DVAL   : out std_logic;
    ATE_DATA   : out std_logic_vector(13 downto 0);
    -- Microcontroller interface
    LED_CLK_8  : out std_logic;
    LED_CLK_18 : out std_logic;
    LED_LOCKED : out std_logic
    );

  attribute LOC         : string;
  attribute SIG_ISCLOCK : string;
  attribute DUTY_CYCLE  : string;
  attribute PERIOD      : string;
  attribute IOSTANDARD  : string;
  attribute SLEW        : string;
  attribute DRIVE       : string;
  attribute PULLUP      : string;

  attribute LOC of CLK_8_IN   : signal is "P77";
  attribute LOC of CLK_18_IN  : signal is "P78";
  attribute LOC of LED_CLK_8  : signal is "P171";
  attribute LOC of LED_CLK_18 : signal is "P172";
  attribute LOC of LED_LOCKED : signal is "P181";

  attribute LOC of ATE_DATA : signal is "P24,P25,P30,P31,P33,P34,P39,P40,P41,P42,P35,P36,P3,P2";
  attribute LOC of ATE_DVAL : signal is "P19";
  attribute LOC of ATE_RDY  : signal is "P15";

  attribute SIG_ISCLOCK of CLK_8_IN : signal is "yes";
  attribute DUTY_CYCLE of CLK_8_IN  : signal is "50%";
  attribute PERIOD of CLK_8_IN      : signal is "125 ns";

  attribute SIG_ISCLOCK of CLK_18_IN : signal is "yes";
  attribute DUTY_CYCLE of CLK_18_IN  : signal is "50%";
  attribute PERIOD of CLK_18_IN      : signal is "54.348 ns";

  attribute DRIVE of ATE_DATA : signal is "12";
  attribute DRIVE of ATE_DVAL : signal is "12";
  attribute DRIVE of ATE_RDY  : signal is "12";

  attribute DRIVE of LED_CLK_8  : signal is "12";
  attribute DRIVE of LED_CLK_18 : signal is "12";
  attribute DRIVE of LED_LOCKED : signal is "12";

  attribute PULLUP of ATE_DATA : signal is "TRUE";
  attribute PULLUP of ATE_DVAL : signal is "TRUE";
  attribute PULLUP of ATE_RDY  : signal is "TRUE";

end toplevel;

architecture behavioral of toplevel is

  -----------------------------------------------------------------------------
  -- The clocks
  -----------------------------------------------------------------------------
--  component clk_18_mini
--    port(
--      CLKIN_IN        : in  std_logic;
--      CLKIN_IBUFG_OUT : out std_logic;
--      CLK0_OUT        : out std_logic;
--      LOCKED_OUT      : out std_logic
--      );
--  end component;

  component clk_synth_18_8_adj
    port (
      U1_CLKIN_IN        : in  std_logic;
      U2_CLKIN_IN        : in  std_logic;
      RESET_IN           : in  std_logic;
      U1_CLKIN_IBUFG_OUT : out std_logic;
      U2_CLKIN_IBUFG_OUT : out std_logic;
      LOCKED_OUT         : out std_logic;
      CLK_8_OUT          : out std_logic;
      CLK_18_OUT         : out std_logic);
  end component;

  signal sl_clk_8, sl_clk_18    : std_logic := '0';
  signal sl_ad_clk, sl_da_clk   : std_logic := '0';
  signal sl_fpga_clk, sl_uc_clk : std_logic := '0';
  signal sl_nreset              : std_logic := '0';
  signal sl_reset               : std_logic := '1';
  -----------------------------------------------------------------------------
  -- End clocks
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Connection to the ATE
  -----------------------------------------------------------------------------
  signal sv_tester_data : std_logic_vector(13 downto 0);
  signal sl_tester_dval : std_logic;
  signal sl_tester_rdy  : std_logic;
  -----------------------------------------------------------------------------
  -- End Connection to the ATE
  -----------------------------------------------------------------------------
  
begin  -- behavioral

  -----------------------------------------------------------------------------
  -- Tester Testing
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Clock Management
  -----------------------------------------------------------------------------
--  Inst_clk_18_mini : clk_18_mini
--    port map(
--      CLKIN_IN        => CLK_IN_EXT,
--      CLKIN_IBUFG_OUT => open,
--      CLK0_OUT        => sl_clk_18,
--      LOCKED_OUT      => sl_nreset
--      );

  clk_synth_18_8_1 : clk_synth_18_8_adj
    port map (
      U1_CLKIN_IN        => CLK_8_IN,
      U2_CLKIN_IN        => CLK_18_IN,
      RESET_IN           => '0',
      U1_CLKIN_IBUFG_OUT => open,
      U2_CLKIN_IBUFG_OUT => open,
      LOCKED_OUT         => sl_nreset,
      CLK_8_OUT          => sl_clk_8,
      CLK_18_OUT         => sl_clk_18);

  sl_fpga_clk <= sl_clk_18;
  sl_ad_clk   <= sl_clk_18;
  sl_reset    <= not sl_nreset;
  -----------------------------------------------------------------------------
  -- End Clock Management
  -----------------------------------------------------------------------------

  proc_ramp : process (sl_fpga_clk, sl_nreset)
    variable vn_counter       : natural range 0 to 383        := 383;
    variable vn_reset_counter : natural range 0 to 511        := 511;
    variable vv_ramp          : std_logic_vector(13 downto 0) := "10000000000000";
  begin  -- process proc_ramp
    if sl_nreset = '0' then              -- asynchronous reset (active low)
      sv_tester_data   <= (others => '0');
      sl_tester_rdy    <= '0';
      sl_tester_dval   <= '0';
      vn_reset_counter := 511;
      vn_counter       := 383;
    elsif rising_edge(sl_fpga_clk) then  -- rising clock edge
      if vn_counter = 0 then
        sl_tester_dval <= '0';
        sv_tester_data <= "01010101010101";
        vv_ramp        := vv_ramp + 1;
      elsif vn_counter = 191 then
        sl_tester_dval <= '1';
        sv_tester_data <= vv_ramp;
      end if;
      -- Counting the data valid
      if vn_counter = 0 then
        vn_counter := 383;
      elsif vn_reset_counter = 0 then
        vn_counter := vn_counter - 1;
      end if;
      -- Counting the reset waiter
      if vn_reset_counter /= 0 then
        vn_reset_counter := vn_reset_counter - 1;
      end if;
    end if;
  end process proc_ramp;

  ATE_DATA <= sv_tester_data;

  ATE_DVAL <= sl_tester_dval;
  ATE_RDY  <= sl_tester_rdy;

  -----------------------------------------------------------------------------
  -- Debug
  -----------------------------------------------------------------------------
  LED_CLK_8  <= sl_clk_8;
  LED_CLK_18 <= sl_clk_18;
  LED_LOCKED <= sl_nreset;
end behavioral;
