-------------------------------------------------------------------------------
-- Title      : i2s transmitter 
-- Project    : Praktikum zu Architekturen der Digitalen Signalverarbeitung
-------------------------------------------------------------------------------
-- File       : i2s_transmitter.vhd
-- Author     : Daniel Glaser
-- Company    : LTE, FAU Erlangen-Nuremberg, Germany
-- Created    : 2006-09-04
-- Last update: 2007-09-20
-- Platform   : LFECP20E
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: The task of this module is to receive serial adc data and
--              present it in parallel to the toplevel
--
-- Information: Give this module some I2S circuit in slave mode and it will
--              transmit the stereo audio information to it. CLK_IN must be at
--              least twice BCK frequency for proper function. If DVAL input
--              toogles, new data is accepted. It has the same meaning as LRCK.
--              If low LRCK means left channel data from audio circuit, left
--              parallel data is just valid, when dval goes down.
--              If no new data arrives, before next transmission cycle,
--              transmission continues with old data to not disturb proper
--              protocol function.
-------------------------------------------------------------------------------
-- Copyright (c) 2006 LTE, FAU Erlangen-Nuremberg, Germany
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2006-09-01  1.0      sidaglas        Created
-- 2006-11-23  1.1      sidaglas        Fixed some comments
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity i2s_transmitter is
  
  generic (
    DATA_WIDTH     : positive := 24;
    CLK_IN_PER_BCK : positive := 8;
    BCK_PER_LRCK   : positive := 48);

  port (
    CLK_IN : in  std_logic;
    nRESET : in  std_logic;
    LRCK   : out std_logic;
    BCK    : out std_logic;
    DOUT   : out std_logic;
    GAIN   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DINL   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DINR   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DVAL   : in  std_logic);

end i2s_transmitter;

architecture behavioral of i2s_transmitter is

  signal sl_dout                  : std_logic;
  signal sl_bck, sl_lrck, sl_sync : std_logic;
  signal sv_inreg_l, sv_inreg_r   : std_logic_vector(DATA_WIDTH-1 downto 0);

  -- pragma translate_off
  signal sn_count_bck, sn_count_lrck, sn_count_transmit : natural;
  signal sv_shiftreg                                    : std_logic_vector(DATA_WIDTH-1 downto 0);
  -- pragma translate_on

  component gain_multiplier
    port (
      clk : in  std_logic;
      a   : in  std_logic_vector(15 downto 0);
      b   : in  std_logic_vector(15 downto 0);
      p   : out std_logic_vector(15 downto 0));
  end component;

  signal sv_left, sv_right : std_logic_vector(DATA_WIDTH-1 downto 0);
  
begin  -- behavioral

  gain_multiplier_left : gain_multiplier
    port map (
      clk => CLK_IN,
      a   => DINL,
      b   => GAIN,
      p   => sv_left);

  gain_multiplier_right : gain_multiplier
    port map (
      clk => CLK_IN,
      a   => DINR,
      b   => GAIN,
      p   => sv_right);

  -- purpose: This process stores the incoming data in some register
  -- type   : sequential
  -- inputs : CLK_IN, nRESET
  -- outputs: 
  reg_inputs : process (CLK_IN, nRESET)
    variable vl_dval              : std_logic := '0';
    variable vi_data_l, vi_data_r : integer;
  begin  -- process reg_inputs
    if nRESET = '0' then                -- asynchronous reset (active low)
      
      sv_inreg_l <= (others => '0');
      sv_inreg_r <= (others => '0');
      vl_dval    := '0';
      
    elsif rising_edge(CLK_IN) then      -- rising clock edge

      if DVAL /= vl_dval then
        sv_inreg_l <= sv_left;
        sv_inreg_r <= sv_right;
      end if;

      vl_dval := DVAL;
      
    end if;
  end process reg_inputs;

  -- purpose: This process generates the BCK signal
  -- type   : sequential
  -- inputs : CLK_IN, nRESET          
  -- outputs: sl_bck    This is the bitclock for DAC
  --          sl_sync   This toggles one CLK_IN before bck falling edge
  bck_gen : process (CLK_IN, nRESET)
    variable vn_count : natural range 0 to CLK_IN_PER_BCK-1 := 0;
  begin  -- process bck_gen
    if nRESET = '0' then                -- asynchronous reset (active low)

      sl_bck   <= '0';
      sl_sync  <= '0';
      vn_count := 0;
      
    elsif rising_edge(CLK_IN) then      -- rising clock edge

      if vn_count = 0 then
        sl_bck <= '0';
      elsif vn_count = 1 then
        sl_sync <= not sl_sync;
      elsif vn_count = (CLK_IN_PER_BCK/2) then
        sl_bck <= '1';
      end if;

      if vn_count = 0 then
        vn_count := CLK_IN_PER_BCK-1;
      else
        vn_count := vn_count - 1;
      end if;

      -- pragma translate_off
      sn_count_bck <= vn_count;
      -- pragma translate_on
      
    end if;
  end process bck_gen;

  BCK <= sl_bck;

  -- purpose: This process generates the lrck signal
  -- type   : sequential
  -- inputs : CLK_IN, nRESET
  --          sl_sync
  -- outputs: sl_lrck
  lrck_gen : process (CLK_IN, nRESET)
    variable vn_count : natural range 0 to BCK_PER_LRCK-1;
    variable vl_sync  : std_logic := '0';
  begin  -- process lrck_gen
    if nRESET = '0' then                -- asynchronous reset (active low)

      sl_lrck  <= '0';
      vl_sync  := '0';
      vn_count := 0;
      LRCK     <= '0';
      
    elsif rising_edge(CLK_IN) then      -- rising clock edge

      if (sl_sync xor vl_sync) = '1' then

        if vn_count = 0 then
          sl_lrck <= '0';               -- '1'->'0' identifies left channel
        elsif vn_count = (BCK_PER_LRCK/2 - 1) then
          sl_lrck <= '1';               -- '0'->'1' identifies right channel
        end if;

        if vn_count = 0 then
          vn_count := BCK_PER_LRCK-1;
        else
          vn_count := vn_count - 1;
        end if;

        vl_sync := sl_sync;

        LRCK <= sl_lrck;                -- This will be delayed one bck cycle

      end if;

      -- pragma translate_off
      sn_count_lrck <= vn_count;
      -- pragma translate_on
      
    end if;
  end process lrck_gen;

  -- purpose: This process shifts the registers and puts out the serial data
  -- type   : sequential
  -- inputs : CLK_IN, nRESET,
  --          sv_shiftreg_l, sv_shiftreg_r, sl_sync, sl_lrck
  -- outputs: sl_dout
  shift_regs_and_output : process (CLK_IN, nRESET)
    variable vv_shiftreg      : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable vl_sync, vl_lrck : std_logic                       := '0';
    variable vn_count         : natural range 0 to DATA_WIDTH-1 := 0;
  begin  -- process shift_regs
    if nRESET = '0' then                -- asynchronous reset (active low)
      
      vv_shiftreg := (others => '0');
      vl_sync     := '0';
      vn_count    := 0;
      vl_lrck     := '0';
      sl_dout     <= '0';
      
    elsif rising_edge(CLK_IN) then      -- rising clock edge

      if (sl_sync xor vl_sync) = '1' then
        -- We are only active when BCK does '1' -> '0'


        if vn_count = 0 then
          -- We have finished transmission and return signal to '0' waiting
          -- for another transfer cycle
          if sl_lrck = '0' and vl_lrck = '1' then
            -- We will copy the left regin to shiftreg

            vv_shiftreg := sv_inreg_l;
            vn_count    := DATA_WIDTH-1;
            
          elsif sl_lrck = '1' and vl_lrck = '0' then
            -- We will copy the right regin to shiftreg

            vv_shiftreg := sv_inreg_r;
            vn_count    := DATA_WIDTH-1;
            
          end if;

          -- pragma translate_off
          sv_shiftreg <= vv_shiftreg;
          -- pragma translate_on

          sl_dout <= '0';
          
        elsif vn_count /= 0 then
          -- We put out the topmost bit and shift the register

          sl_dout                            <= vv_shiftreg(DATA_WIDTH-1);
          vv_shiftreg(DATA_WIDTH-1 downto 0) := vv_shiftreg(DATA_WIDTH-2 downto 0) & '0';
          vn_count                           := vn_count - 1;
          
        end if;

        vl_lrck := sl_lrck;
        vl_sync := sl_sync;

      end if;

      -- pragma translate_off
      sn_count_transmit <= vn_count;
      -- pragma translate_on

    end if;
  end process shift_regs_and_output;

  DOUT <= sl_dout;
  
end behavioral;

