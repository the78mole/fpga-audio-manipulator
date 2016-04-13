-------------------------------------------------------------------------------
-- Title      : Toplevel for Test laboratory
-- Project    : Test Laboratory
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Daniel Glaser
-- Company    : LRS, Chair for Computer Assisted Circuit Design
-- Created    : 2007-08-07
-- Last update: 2009-02-27
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

  generic (
    SP_DATA_WIDTH : positive := 24;
    AD_DATA_WIDTH : positive := 16;
    DA_DATA_WIDTH : positive := 16;
    INT_RESET     : boolean  := true);
  port (
    CLK_IN         : in    std_logic;
    CLK_IN_EXT     : in    std_logic;
    NRESET         : in    std_logic;
    -- User interface
    BARGRAPH_LEFT  : out   std_logic_vector(6 downto 0);
    BARGRAPH_RIGHT : out   std_logic_vector(6 downto 0);
    DIP_SWITCHES   : in    std_logic_vector(7 downto 0);
    -- ADU interface
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
    -- DAU interface
    DA_MCLK        : out   std_logic;
    DA_PD_RST      : out   std_logic;
    DA_BCLK        : out   std_logic;
    DA_LRCK        : out   std_logic;
    DA_SDATA       : out   std_logic;
    DA_MODE        : out   std_logic;
    DA_DEEMP       : out   std_logic;
    DA_MUTE        : out   std_logic;
    DA_384_256     : out   std_logic;
    -- ATE interface
    ATE_RDY        : out   std_logic;
    ATE_DVAL       : out   std_logic;
    ATE_DATA       : out   std_logic_vector(13 downto 0);
    -- Microcontroller interface
    UC_CLK         : out   std_logic;
    UC_AD          : inout std_logic_vector(15 downto 0);
    UC_ALE         : in    std_logic;
    UC_nRD         : in    std_logic;
    UC_nWR         : in    std_logic);

  attribute LOC         : string;
  attribute SIG_ISCLOCK : string;
  attribute DUTY_CYCLE  : string;
  attribute PERIOD      : string;
  attribute MAXDELAY    : string;
  attribute IOSTANDARD  : string;
  attribute SLEW        : string;
  attribute DRIVE       : string;
  attribute PULLUP      : string;

  attribute LOC of CLK_IN         : signal is "P77";
  attribute LOC of CLK_IN_EXT     : signal is "P78";
  attribute LOC of NRESET         : signal is "P100";
  attribute LOC of BARGRAPH_LEFT  : signal is "P171, P172, P177, P178, P180, P181, P189";
  attribute LOC of BARGRAPH_RIGHT : signal is "P203, P202, P199, P197, P196, P192, P190";
  attribute LOC of DIP_SWITCHES   : signal is "P168, P167, P165, P164, P163, P162, P161, P160";

  attribute LOC of AD_CLK     : signal is "P2";
  attribute LOC of AD_RST     : signal is "P16";
  attribute LOC of AD_TAG     : signal is "P4";
  attribute LOC of AD_LRCK    : signal is "P3";
  attribute LOC of AD_WCLK    : signal is "P8";
  attribute LOC of AD_BCLK    : signal is "P9";
  attribute LOC of AD_SOUT    : signal is "P11";
  attribute LOC of AD_RDEDGE  : signal is "P12";
  attribute LOC of AD_SnM     : signal is "P15";
  attribute LOC of AD_MSBDLY  : signal is "P19";
  attribute LOC of AD_384_256 : signal is "P18";
  attribute LOC of AD_RLJUST  : signal is "P33";

  attribute LOC of DA_MCLK    : signal is "P153";
  attribute LOC of DA_PD_RST  : signal is "P151";
  attribute LOC of DA_BCLK    : signal is "P150";
  attribute LOC of DA_LRCK    : signal is "P146";
  attribute LOC of DA_SDATA   : signal is "P152";
  attribute LOC of DA_MODE    : signal is "P147";
  attribute LOC of DA_DEEMP   : signal is "P145";
  attribute LOC of DA_MUTE    : signal is "P140";
  attribute LOC of DA_384_256 : signal is "P144";

  attribute LOC of ATE_DATA : signal is "P24,P25,P30,P31,P33,P34,P39,P40,P41,P42,P35,P36,P3,P2";
  attribute LOC of ATE_DVAL : signal is "P19";
  attribute LOC of ATE_RDY  : signal is "P15";

  attribute LOC of UC_CLK : signal is "P97";
  attribute LOC of UC_AD  : signal is "P74,P75,P76,P82,P83,P89,P90,P93,P68,P65,P64,P63,P62,P61,P60,P55";
  attribute LOC of UC_ALE : signal is "P69";
  attribute LOC of UC_nRD : signal is "P94";
  attribute LOC of UC_nWR : signal is "P96";


  attribute SIG_ISCLOCK of CLK_IN : signal is "yes";
  attribute DUTY_CYCLE of CLK_IN  : signal is "50%";
  attribute PERIOD of CLK_IN      : signal is "50 ns";

  attribute DRIVE of BARGRAPH_LEFT  : signal is "12";
  attribute DRIVE of BARGRAPH_RIGHT : signal is "12";
  attribute DRIVE of ATE_DATA       : signal is "12";
  attribute DRIVE of ATE_DVAL       : signal is "12";
  attribute DRIVE of ATE_RDY        : signal is "12";
  attribute DRIVE of UC_CLK         : signal is "12";

--  attribute SLEW of BARGRAPH_LEFT  : signal is "SLOW";
--  attribute SLEW of BARGRAPH_RIGHT : signal is "SLOW";

  attribute PULLUP of DIP_SWITCHES : signal is "TRUE";
-- Bus Keeper in ATmega enabled, so not pulling AD lines high
--  attribute PULLUP of UC_AD        : signal is "TRUE"; 
  attribute PULLUP of UC_nWR       : signal is "TRUE";
  attribute PULLUP of UC_nRD       : signal is "TRUE";
  attribute PULLUP of UC_ALE       : signal is "TRUE";
  attribute PULLUP of ATE_DATA     : signal is "TRUE";
  attribute PULLUP of ATE_DVAL     : signal is "TRUE";
  attribute PULLUP of ATE_RDY      : signal is "TRUE";

  attribute PULLUP of others     : signal is "FALSE";
  attribute IOSTANDARD of others : signal is "LVCMOS33";
  attribute SLEW of others       : signal is "SLOW";

end toplevel;

architecture behavioral of toplevel is

--  component clkgen
--    port (
--      CLKIN_IN        : in  std_logic;
--      RST_IN          : in  std_logic;
--      CLKFX_OUT       : out std_logic;
--      CLKIN_IBUFG_OUT : out std_logic;
--      CLK0_OUT        : out std_logic;
--      CLK2X_OUT       : out std_logic;
--      LOCKED_OUT      : out std_logic);
--  end component;

  signal sl_reset, sl_intgen_reset   : std_logic := '1';
  signal sl_nreset, sl_intgen_nreset : std_logic := '0';

  signal sv_counter : std_logic_vector(6 downto 0);

  -----------------------------------------------------------------------------
  -- The clocks
  -----------------------------------------------------------------------------
--  component clk_gen_184_8
--    port (
--      CLK_IN_8        : in  std_logic;
--      CLK_IN_18       : in  std_logic;
--      CLKIN_IBUFG_OUT : out std_logic;
--      RESET           : in  std_logic;
--      CLK_18_OUT      : out std_logic;
--      CLK_8_OUT       : out std_logic;
--      LOCKED          : out std_logic);
--  end component;

--  component clk_18_mini
--    port(
--      CLKIN_IN        : in  std_logic;
--      CLKIN_IBUFG_OUT : out std_logic;
--      CLK0_OUT        : out std_logic;
--      LOCKED_OUT      : out std_logic
--      );
--  end component;

--  component clk_8_mini
--    port(
--      CLKIN_IN        : in  std_logic;
--      CLKIN_IBUFG_OUT : out std_logic;
--      CLK0_OUT        : out std_logic;
--      LOCKED_OUT      : out std_logic
--      );
--  end component;

  signal sl_ibufg_clk_in                    : std_logic := '0';
  signal sl_clk_locked                      : std_logic := '0';
  signal sl_clk_8, sl_clk_18                : std_logic := '0';
  signal sl_conv_clk, sl_ucclk, sl_fpga_clk : std_logic := '0';
  -----------------------------------------------------------------------------
  -- End clocks
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Reset Generator
  -----------------------------------------------------------------------------
  component reset_gen
    generic (
      CLK_HOLD : natural);
    port (
      CLK_IN    : in  std_logic;
      NRESET_IN : in  std_logic;
      NRESET    : out std_logic;
      RESET     : out std_logic);
  end component;
  -----------------------------------------------------------------------------
  -- End Reset Generator
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
  -- Clock Generator 8 -> 18 and 18 -> 8 selected by DIP 8 (7)
  -----------------------------------------------------------------------------
--  clk_gen_184_8_1 : clk_gen_184_8
--    port map (
--      CLK_IN_8        => CLK_IN,
--      CLK_IN_18       => CLK_IN_EXT,
--      CLKIN_IBUFG_OUT => sl_ibufg_clk_in,
--      RESET           => sl_intgen_reset,
--      CLK_18_OUT      => sl_clk_18,
--      CLK_8_OUT       => sl_clk_8,
--      LOCKED          => sl_clk_locked);


--  Inst_clk_18_mini : clk_18_mini port map(
--    CLKIN_IN        => CLK_IN,
--    CLKIN_IBUFG_OUT => open,
--    CLK0_OUT        => sl_clk_18,
--    LOCKED_OUT      => sl_clk_locked
--    );


--  Inst_clk_8_mini : clk_8_mini port map(
--    CLKIN_IN        => CLK_IN,
--    CLKIN_IBUFG_OUT => open,
--    CLK0_OUT        => sl_clk_8,
--    LOCKED_OUT      => open
--    );

  sl_clk_8 <= CLK_IN_EXT;
  sl_clk_18  <= CLK_IN;

  sl_nreset <= sl_clk_locked;
  sl_reset  <= not sl_clk_locked;

  sl_conv_clk <= sl_clk_18;
  sl_fpga_clk <= sl_clk_18;
  sl_ucclk    <= sl_clk_8;

  -----------------------------------------------------------------------------
  -- RESET GENERATOR
  -----------------------------------------------------------------------------

  gen_int_reset : if INT_RESET generate

    reset_gen_1 : reset_gen
      generic map (
        CLK_HOLD => 512)
      port map (
        CLK_IN    => sl_ibufg_clk_in,
        NRESET_IN => NRESET,
        NRESET    => sl_intgen_nreset,
        RESET     => sl_intgen_reset);

  end generate gen_int_reset;

  gen_ext_reset : if not INT_RESET generate
    sl_intgen_reset  <= NRESET;
    sl_intgen_nreset <= not NRESET;
  end generate gen_ext_reset;

  -----------------------------------------------------------------------------
  -- Tester Testing
  -----------------------------------------------------------------------------

  proc_ramp : process (sl_conv_clk, sl_nreset)
    variable vl_counter : natural range 0 to 383        := 383;
    variable vv_ramp    : std_logic_vector(13 downto 0) := "10000000000000";
  begin  -- process proc_ramp
    if sl_nreset = '0' then             -- asynchronous reset (active low)
      sv_tester_data <= (others => '0');
      sl_tester_rdy  <= '0';
      sl_tester_dval <= '0';
    elsif sl_conv_clk'event and sl_conv_clk = '1' then  -- rising clock edge
      if vl_counter = 0 then
        sl_tester_dval <= '0';
        sv_tester_data <= "01010101010101";
        vv_ramp        := vv_ramp + 1;
      elsif vl_counter = 191 then
        sl_tester_dval <= '1';
        sv_tester_data <= vv_ramp;
      end if;
      if vl_counter = 0 then
        vl_counter := 383;
      else
        vl_counter := vl_counter - 1;
      end if;
    end if;
  end process proc_ramp;

  ATE_DATA <= sv_tester_data;

  ATE_DVAL <= sl_tester_dval;
  ATE_RDY  <= sl_tester_rdy;

  BARGRAPH_RIGHT(6) <= DIP_SWITCHES(0);


  proc_something : process (sl_fpga_clk, sl_nreset)
  begin  -- process proc_something
    if sl_nreset = '0' then             -- asynchronous reset (active low)
      BARGRAPH_LEFT(6 downto 1)  <= DIP_SWITCHES(6 downto 1);
      BARGRAPH_RIGHT(5 downto 0) <= DIP_SWITCHES(7 downto 2);
      -- ADU interface
      AD_CLK                     <= '0';
      AD_RST                     <= '0';
      AD_RDEDGE                  <= '0';
      AD_SnM                     <= '0';
      AD_MSBDLY                  <= '0';
      AD_384_256                 <= '0';
      AD_RLJUST                  <= '0';
      -- DAU interface
      DA_MCLK                    <= '0';
      DA_PD_RST                  <= '0';
      DA_BCLK                    <= '0';
      DA_LRCK                    <= '0';
      DA_SDATA                   <= '0';
      DA_MODE                    <= '0';
      DA_DEEMP                   <= '0';
      DA_MUTE                    <= '0';
      DA_384_256                 <= '0';
      -- Microcontroller interface
      UC_CLK                     <= sl_ucclk;
      UC_AD                      <= (others => 'Z');
      BARGRAPH_LEFT(0)           <= '0';

    elsif rising_edge(sl_fpga_clk) then  -- rising clock edge
      BARGRAPH_LEFT(6 downto 1)  <= DIP_SWITCHES(6 downto 1);
      BARGRAPH_RIGHT(5 downto 0) <= DIP_SWITCHES(7 downto 2);
      -- ADU interface
      AD_CLK                     <= '0';
      AD_RST                     <= AD_TAG and AD_LRCK and AD_WCLK and AD_BCLK and AD_SOUT;
      AD_RDEDGE                  <= '0';
      AD_SnM                     <= '0';
      AD_MSBDLY                  <= '0';
      AD_384_256                 <= '0';
      AD_RLJUST                  <= '0';
      -- DAU interface
      DA_MCLK                    <= '0';
      DA_PD_RST                  <= '0';
      DA_BCLK                    <= '0';
      DA_LRCK                    <= '0';
      DA_SDATA                   <= '0';
      DA_MODE                    <= '0';
      DA_DEEMP                   <= '0';
      DA_MUTE                    <= '0';
      DA_384_256                 <= '0';
      -- Microcontroller interface
      UC_CLK                     <= sl_ucclk;
      UC_AD                      <= (others => 'Z');
      BARGRAPH_LEFT(0)           <= UC_ALE and UC_nRD and UC_nWR;

    end if;
  end process proc_something;
  
end behavioral;
