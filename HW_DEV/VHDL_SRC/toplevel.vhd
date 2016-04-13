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

  generic (
    SP_DATA_WIDTH : positive := 24;
    AD_DATA_WIDTH : positive := 16;
    DA_DATA_WIDTH : positive := 16;
    INT_RESET     : boolean  := true);
  port (
    CLK_8_IN  : in  std_logic;
    CLK_18_IN : in  std_logic;
--    NRESET         : in    std_logic;
    -- User interface
    BARGRAPH_LEFT  : out   std_logic_vector(6 downto 0);
--    BARGRAPH_RIGHT : out   std_logic_vector(6 downto 0);
--    DIP_SWITCHES   : in    std_logic_vector(7 downto 0);
    -- ADU interface
    AD_CLK    : out std_logic;
--    AD_RST         : out   std_logic;
--    AD_TAG         : in    std_logic;
--    AD_LRCK        : in    std_logic;
--    AD_WCLK        : in    std_logic;
--    AD_BCLK        : in    std_logic;
--    AD_SOUT        : in    std_logic;
--    AD_RDEDGE      : out   std_logic;
--    AD_SnM         : out   std_logic;
--    AD_MSBDLY      : out   std_logic;
--    AD_384_256     : out   std_logic;
--    AD_RLJUST      : out   std_logic;
    -- DAU interface
--    DA_MCLK        : out   std_logic;
--    DA_PD_RST      : out   std_logic;
--    DA_BCLK        : out   std_logic;
--    DA_LRCK        : out   std_logic;
--    DA_SDATA       : out   std_logic;
--    DA_MODE        : out   std_logic;
--    DA_DEEMP       : out   std_logic;
--    DA_MUTE        : out   std_logic;
--    DA_384_256     : out   std_logic;
    -- ATE interface
--    ATE_RDY        : out   std_logic;
--    ATE_DVAL       : out   std_logic;
--    ATE_DATA       : out   std_logic_vector(13 downto 0);
    -- Microcontroller interface
    UC_CLK    : out std_logic           --;
--    UC_AD          : inout std_logic_vector(15 downto 0);
--    UC_ALE         : in    std_logic;
--    UC_nRD         : in    std_logic;
--    UC_nWR         : in    std_logic
    );

  attribute LOC         : string;
  attribute SIG_ISCLOCK : string;
  attribute DUTY_CYCLE  : string;
  attribute PERIOD      : string;
  attribute MAXDELAY    : string;
  attribute IOSTANDARD  : string;
  attribute SLEW        : string;
  attribute DRIVE       : string;
  attribute PULLUP      : string;

  attribute LOC of CLK_8_IN  : signal is "P77";
  attribute LOC of CLK_18_IN : signal is "P78";
--  attribute LOC of NRESET         : signal is "P100";
  attribute LOC of BARGRAPH_LEFT  : signal is "P171, P172, P177, P178, P180, P181, P189";
--  attribute LOC of BARGRAPH_RIGHT : signal is "P203, P202, P199, P197, P196, P192, P190";
--  attribute LOC of DIP_SWITCHES   : signal is "P168, P167, P165, P164, P163, P162, P161, P160";

  attribute LOC of AD_CLK : signal is "P2";
--  attribute LOC of AD_RST     : signal is "P16";
--  attribute LOC of AD_TAG     : signal is "P4";
--  attribute LOC of AD_LRCK    : signal is "P3";
--  attribute LOC of AD_WCLK    : signal is "P8";
--  attribute LOC of AD_BCLK    : signal is "P9";
--  attribute LOC of AD_SOUT    : signal is "P11";
--  attribute LOC of AD_RDEDGE  : signal is "P12";
--  attribute LOC of AD_SnM     : signal is "P15";
--  attribute LOC of AD_MSBDLY  : signal is "P19";
--  attribute LOC of AD_384_256 : signal is "P18";
--  attribute LOC of AD_RLJUST  : signal is "P33";

--  attribute LOC of DA_MCLK    : signal is "P153";
--  attribute LOC of DA_PD_RST  : signal is "P151";
--  attribute LOC of DA_BCLK    : signal is "P150";
--  attribute LOC of DA_LRCK    : signal is "P146";
--  attribute LOC of DA_SDATA   : signal is "P152";
--  attribute LOC of DA_MODE    : signal is "P147";
--  attribute LOC of DA_DEEMP   : signal is "P145";
--  attribute LOC of DA_MUTE    : signal is "P140";
--  attribute LOC of DA_384_256 : signal is "P144";

--  attribute LOC of ATE_DATA : signal is "P24,P25,P30,P31,P33,P34,P39,P40,P41,P42,P35,P36,P3,P2";
--  attribute LOC of ATE_DVAL : signal is "P19";
--  attribute LOC of ATE_RDY  : signal is "P15";

  attribute LOC of UC_CLK : signal is "P97";
--  attribute LOC of UC_AD  : signal is "P74,P75,P76,P82,P83,P89,P90,P93,P68,P65,P64,P63,P62,P61,P60,P55";
--  attribute LOC of UC_ALE : signal is "P69";
--  attribute LOC of UC_nRD : signal is "P94";
--  attribute LOC of UC_nWR : signal is "P96";

  attribute SIG_ISCLOCK of CLK_8_IN : signal is "yes";
  attribute DUTY_CYCLE of CLK_8_IN  : signal is "50%";
  attribute PERIOD of CLK_8_IN      : signal is "125 ns";

  attribute SIG_ISCLOCK of CLK_18_IN : signal is "yes";
  attribute DUTY_CYCLE of CLK_18_IN  : signal is "50%";
  attribute PERIOD of CLK_18_IN      : signal is "54 ns";

  attribute IOSTANDARD of others : signal is "LVCMOS33";

--  attribute DRIVE of BARGRAPH_LEFT  : signal is "12";
--  attribute DRIVE of BARGRAPH_RIGHT : signal is "12";
--  attribute DRIVE of ATE_DATA       : signal is "12";
--  attribute DRIVE of ATE_DVAL       : signal is "12";
--  attribute DRIVE of ATE_RDY        : signal is "12";
  attribute DRIVE of UC_CLK : signal is "12";

--  attribute SLEW of BARGRAPH_LEFT  : signal is "SLOW";
--  attribute SLEW of BARGRAPH_RIGHT : signal is "SLOW";
  attribute SLEW of others : signal is "FAST";

--  attribute PULLUP of DIP_SWITCHES : signal is "TRUE";
-- Bus Keeper in ATmega enabled, so not pulling AD lines high
--  attribute PULLUP of UC_AD        : signal is "TRUE"; 
--  attribute PULLUP of UC_nWR       : signal is "TRUE";
--  attribute PULLUP of UC_nRD       : signal is "TRUE";
--  attribute PULLUP of UC_ALE       : signal is "TRUE";
--  attribute PULLUP of ATE_DATA     : signal is "TRUE";
--  attribute PULLUP of ATE_DVAL     : signal is "TRUE";
--  attribute PULLUP of ATE_RDY      : signal is "TRUE";
  attribute PULLUP of others : signal is "FALSE";
  
end toplevel;

architecture behavioral of toplevel is

  -----------------------------------------------------------------------------
  -- The clocks
  -----------------------------------------------------------------------------

  -- Component for generating the missing clock 8 or 18 MHz
  component clk_gen_184_8
    port (
      CLK_IN_8        : in  std_logic;
      CLK_IN_18       : in  std_logic;
      CLKIN_IBUFG_OUT : out std_logic;
      RESET           : in  std_logic;
      CLK_18_OUT      : out std_logic;
      CLK_8_OUT       : out std_logic;
      LOCKED          : out std_logic);
  end component;

  signal sl_clk_8  : std_logic;
  signal sl_clk_18 : std_logic;
  signal sl_locked : std_logic;

begin  -- behavioral

  clk_gen_184_8_1 : clk_gen_184_8
    port map (
      CLK_IN_8        => CLK_8_IN,
      CLK_IN_18       => CLK_18_IN,
      CLKIN_IBUFG_OUT => open,
      RESET           => '0',
      CLK_18_OUT      => sl_clk_18,
      CLK_8_OUT       => sl_clk_8,
      LOCKED          => sl_locked);

  UC_CLK <= sl_clk_8;
  AD_CLK <= sl_clk_18;

  BARGRAPH_LEFT(0)          <= not sl_locked;
  BARGRAPH_LEFT(6 downto 1) <= (others => '1');
  
end behavioral;
