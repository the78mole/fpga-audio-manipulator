-------------------------------------------------------------------------------
-- Title      : Microcontroller Interface
-- Project    : 
-------------------------------------------------------------------------------
-- File       : uc_interface.vhd
-- Author     : Daniel Glaser
-- Company    : 
-- Created    : 2007-08-07
-- Last update: 2008-01-24
-- Platform   : XC3S500E
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This module holds the coefficients for the polynomial that
--              affects the characteristc curve of the analog to digital
--              converter.
--
-- The registers are organized as follows:
--
-- +------------+-------------------------------------------------------+
-- | ADDR       | Description                                           |
-- +------------+-------------------------------------------------------+
-- | 0          | Control Register                                 (rw) |
-- |            | +-----+------+-----+-----+-----+-----+-----+-----+    |
-- |            | |  7  |   6  |  5  |  4  |  3  |  2  |  1  |  0  |    |
-- |            | +-----+------+-----+-----+-----+-----+-----+-----+    |
-- |            | | SMP | HDEN | DEN | NEN | PBY | SBY | DAC | ADC |    |
-- |            | +-----+------+-----+-----+-----+-----+-----+-----+    |
-- |            |                                                       |
-- |            | ADC  : Enable the Analog-To-Digital-Converter         |
-- |            | DAC  : Enable the Digital-To-Analog-Converter         |
-- |            | SBY  : Bypass the serial data (I2S)                   |
-- |            | PBY  : Bypass the parallel data                       |
-- |            | NEN  : Noise enable                                   |
-- |            | DEN  : Distortion enable (simple offset and gain)     |
-- |            | HDEN : High order Distortion enable                   |
-- |            | SMP  : Sample next valid ADC value and DAC value      |
-- |            |        related to this ADC value (nyi)                |
-- +------------+-------------------------------------------------------+
-- | 1          | Status                                           (ro) |
-- |            | +-----+-----+-----+-----+-----+-----+-----+-----+     |
-- |            | |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |     |
-- |            | +-----+-----+-----+-----+-----+-----+-----+-----+     |
-- |            | | SFN |  -  |  -  |  -  |  -  |  -  |  -  |  -  |     |
-- |            | +-----+-----+-----+-----+-----+-----+-----+-----+     |
-- |            |                                                       |
-- |            | SFN : Sample ADC and DAC value finished               |
-- +------------+-------------------------------------------------------+
-- | 2,3        | Input Amplifiction                               (rw) |
-- +------------+-------------------------------------------------------+
-- | 4,5        | Output Amplifiction                              (rw) |
-- +------------+-------------------------------------------------------+
-- | 6,7        | Noise level                                      (rw) |
-- +------------+-------------------------------------------------------+
-- | 8          | Initialization register                          (rw) |
-- |            |                                                       |
-- |            | To initialize the FPGA and to enable read access to   |
-- |            | the register file (FPGA has to drive AD lines), write |
-- |            | the HW Rev (Reg. 31) to this register and FPGA will   |
-- |            | be allowed to drive the lines while RD is low and     |
-- |            | latched Address is within range 0x8000 and 0xFFFF     |
-- +------------+-------------------------------------------------------+
-- | 9 - 30     | reserved                                         (rw) |
-- +------------+-------------------------------------------------------+
-- | 31         | Hardware Ver. (7-6: Main, 5-4: Sub, 3-0: Patch)  (ro) |
-- +------------+-------------------------------------------------------+
-- | 32,33      | Sampled left channel ADC value                   (ro) |
-- +------------+-------------------------------------------------------+
-- | 34,35      | Sampled right channel ADC value                  (ro) |
-- +------------+-------------------------------------------------------+
-- | 36,37      | Sampled left channel DAC value                   (ro) |
-- +------------+-------------------------------------------------------+
-- | 38,39      | Sampled right channel DAC value                  (ro) |
-- +------------+-------------------------------------------------------+
-- | 40 - 63    | reserved                                         (ro) |
-- +============+=======================================================+
-- | 64, 65     | x^0 Coefficient Lo- and Hi-Byte         (offest) (rw) |
-- +------------+-------------------------------------------------------+
-- | 66, 67     | x^1 Coefficient Lo- and Hi-Byte           (gain) (rw) |
-- +------------+-------------------------------------------------------+
-- | 68, 69     | x^2 Coefficient Lo- and Hi-Byte       (2. order) (rw) |
-- +------------+-------------------------------------------------------+
-- | 70, 71     | x^3 Coefficient Lo- and Hi-Byte       (3. order) (rw) |
-- +------------+-------------------------------------------------------+
-- | 72, 73     | x^4 Coefficient Lo- and Hi-Byte                  (rw) |
-- +------------+-------------------------------------------------------+
-- | 74, 75     | x^5 Coefficient Lo- and Hi-Byte                  (rw) |
-- +------------+-------------------------------------------------------+
-- | 76, 77     | x^6 Coefficient Lo- and Hi-Byte                  (rw) |
-- +------------+-------------------------------------------------------+
-- | 78, 79     | x^7 Coefficient Lo- and Hi-Byte                  (rw) |
-- +------------+-------------------------------------------------------+
--
-- Amplification values are treated as 16-bit unsigned integers.
-- Coefficients are signed 16-bit integers in twos-complement format
--
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2007-08-07  1.0.0    sidaglas        Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity uc_interface is

  generic (
    BASE_ADDR : std_logic_vector(15 downto 0) := x"8000";
    MASK_ADDR : std_logic_vector(15 downto 0) := x"FF80");
  port (
    -- UC interface
    CLK_IN : in  std_logic;
    nRESET : in  std_logic;
    ALE    : in  std_logic;
    WR     : in  std_logic;
    RD     : in  std_logic;
    AD_IN  : in  std_logic_vector(15 downto 0);
    AD_OUT : out std_logic_vector(7 downto 0);
    AD_OE  : out std_logic;

    -- Hardware interface
    CONTROL         : out std_logic_vector(7 downto 0);
    NOISE_LEVEL     : out std_logic_vector(15 downto 0);
    INPUT_AMP       : out std_logic_vector(15 downto 0);
    OUTPUT_AMP      : out std_logic_vector(15 downto 0);
    COEFF_ADDR      : in  std_logic_vector(4 downto 0);
    COEFF_DATA      : out std_logic_vector(15 downto 0);
    CURRENT_ADDRESS : out std_logic_vector(15 downto 0);
    ADDRESS_MATCHED : out std_logic);

end uc_interface;

architecture behavioral of uc_interface is

  subtype tv_regs is std_logic_vector(7 downto 0);
  type tav_regfile is array (0 to 127) of tv_regs;

  signal sav_regfile : tav_regfile;

  constant cv_version : tv_regs := "01000000";

  constant cn_reg_control : natural := 0;
  constant cn_reg_status  : natural := 1;
  constant cn_reg_inamp   : natural := 2;
  constant cn_reg_outamp  : natural := 4;
  constant cn_reg_noise   : natural := 6;
  constant cn_reg_init    : natural := 8;
  constant cn_reg_version : natural := 31;
  constant cn_reg_adc_val : natural := 32;
  constant cn_reg_dac_val : natural := 36;
  constant cn_reg_coeffs  : natural := 64;

  signal sl_addr_matched : std_logic;

begin  -- behavioral

  proc_uc_access : process (CLK_IN, nRESET)
    variable vv_adr_hi, vv_adr_lo : std_logic_vector(7 downto 0);
    variable vv_cur_addr          : std_logic_vector(15 downto 0);
    variable vv_reg_addr_wide     : std_logic_vector(15 downto 0);
    variable vv_reg_addr          : std_logic_vector(6 downto 0);
    variable vn_reg_addr          : natural range 0 to 2**7-1;
--    variable vl_ale               : std_logic := '0';
  begin  -- process proc_uc_access
    if nRESET = '0' then                -- asynchronous reset (active low)
      sav_regfile(0 to cn_reg_version-1)                <= (others => (others => '0'));
      sav_regfile(cn_reg_version)                       <= cv_version;
      sav_regfile(cn_reg_version+1 to sav_regfile'high) <= (others => (others => '0'));
      sl_addr_matched                                   <= '0';
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      if ALE = '1' then
        vv_adr_lo        := AD_IN(7 downto 0);
        vv_adr_hi        := AD_IN(15 downto 8);
        vv_cur_addr      := vv_adr_hi & vv_adr_lo;
        vv_reg_addr_wide := vv_cur_addr and (not MASK_ADDR);
        vv_reg_addr      := vv_reg_addr_wide(6 downto 0);
        -- We make sure that we don't drive any output while latching address
        sl_addr_matched  <= '0';
      elsif (vv_cur_addr and MASK_ADDR) = (BASE_ADDR and MASK_ADDR) then
        sl_addr_matched <= '1';
        vn_reg_addr     := conv_integer('0' & vv_reg_addr);
        if WR = '0' then
          if (vn_reg_addr <= 30 or vn_reg_addr >= 64) and vn_reg_addr /= 1 then
            -- Status Register (1) and value regs are read only
            sav_regfile(vn_reg_addr) <= AD_IN(7 downto 0);
          end if;
        end if;

        AD_OUT(7 downto 0) <= sav_regfile(vn_reg_addr);

      else
        -- Another (unknown) part is addressed
        sl_addr_matched <= '0';
      end if;

      CURRENT_ADDRESS <= vv_cur_addr;
      ADDRESS_MATCHED <= sl_addr_matched;

--      vl_ale := ALE;

    end if;
  end process proc_uc_access;

  -- Make sure that we only drive when uC wants to read data and we are initiaized
  AD_OE <= '1' when RD = '0' and sl_addr_matched = '1' and ALE = '0' else
           '0';

  proc_hw_access : process (CLK_IN, nRESET)
    variable vv_coeff_addr : std_logic_vector(4 downto 0);
    variable vn_reg_addr   : natural range 64 to 127 := 64;
  begin  -- process proc_hw_access
    if nRESET = '0' then                -- asynchronous reset (active low)
      CONTROL     <= (others => '0');
      NOISE_LEVEL <= (others => '0');
      INPUT_AMP   <= (others => '0');
      OUTPUT_AMP  <= (others => '0');
      COEFF_DATA  <= (others => '0');
      vn_reg_addr := 64;
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      CONTROL       <= sav_regfile(cn_reg_control);
      NOISE_LEVEL   <= sav_regfile(cn_reg_noise + 1) & sav_regfile(cn_reg_noise);
      INPUT_AMP     <= sav_regfile(cn_reg_inamp + 1) & sav_regfile(cn_reg_inamp);
      OUTPUT_AMP    <= sav_regfile(cn_reg_outamp + 1) & sav_regfile(cn_reg_outamp);
      vv_coeff_addr := COEFF_ADDR;
      vn_reg_addr   := conv_integer('0' & vv_coeff_addr & '0') + cn_reg_coeffs;
      COEFF_DATA    <= sav_regfile(vn_reg_addr + 1) & sav_regfile(vn_reg_addr);
    end if;
  end process proc_hw_access;
  
end behavioral;
