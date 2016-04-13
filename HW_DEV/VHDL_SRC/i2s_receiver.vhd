-------------------------------------------------------------------------------
-- Title      : i2c receiver 
-- Project    : Praktikum zu Architekturen der Digitalen Signalverarbeitung
-------------------------------------------------------------------------------
-- File       : i2s_receiver.vhd
-- Author     : Daniel Glaser
-- Company    : LTE, FAU Erlangen-Nuremberg, Germany
-- Created    : 2006-09-01
-- Last update: 2007-09-21
-- Platform   : LFECP20E
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: The task of this module is to receive serial adc data and
--              present it in parallel to the toplevel
--
-- Information: Give this module some I2S circuit in master mode and it will
--              receive the stereo audio information from it. CLK_IN must be at
--              least twice BCK frequency for proper function. The DVAL output
--              toogles each time, new data is incoming. It has the same
--              meaning as LRCK. If low LRCK means left channel data from audio
--              circuit, left parallel data is just valid, when dval goes down.
--              Left channel parallel data is valid as long as DVAL stays low.
--              It is valid until short before (3 BCK cycles) next high
--              to low edge. This allows to sample left and right data as well
--              at high to low edge of DVAL and vice versa.
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

entity i2s_receiver is
  
  generic (
    DATA_WIDTH : positive := 16);

  port (
    CLK_IN : in  std_logic;
    nRESET : in  std_logic;
    LRCK   : in  std_logic;
    BCK    : in  std_logic;
    WCLK   : in  std_logic;
    DIN    : in  std_logic;
    GAIN   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DOUTL  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    DOUTR  : out std_logic_vector(DATA_WIDTH-1 downto 0);
    DVAL   : out std_logic;
    DEBUG  : out std_logic_vector(7 downto 0));

end i2s_receiver;

architecture behavioral of i2s_receiver is
  
  signal sl_val_l, sl_val_r         : std_logic;
  signal sl_val_l_pre, sl_val_r_pre : std_logic;
  signal sl_bck_pre, sl_lrck_pre    : std_logic;
  signal sl_wclk_pre                : std_logic;

  signal sv_shiftreg : std_logic_vector(DATA_WIDTH-1 downto 0);

  component gain_multiplier
    port (
      clk : in  std_logic;
      a   : in  std_logic_vector(15 downto 0);
      b   : in  std_logic_vector(15 downto 0);
      p   : out std_logic_vector(15 downto 0));
  end component;

  signal sv_left_in, sv_right_in   : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal sv_left_out, sv_right_out : std_logic_vector(DATA_WIDTH-1 downto 0);
  
begin  -- behavioral

  gain_multiplier_left : gain_multiplier
    port map (
      clk => CLK_IN,
      a   => sv_left_in,
      b   => GAIN,
      p   => sv_left_out);

  DOUTL <= sv_left_out;

  gain_multiplier_right : gain_multiplier
    port map (
      clk => CLK_IN,
      a   => sv_right_in,
      b   => GAIN,
      p   => sv_right_out);

  DOUTR <= sv_right_out;

  proc_rec : process (CLK_IN, nRESET)
  begin  -- process proc_rec
    if nRESET = '0' then                -- asynchronous reset (active low)
      sv_shiftreg <= (others => '0');
    elsif rising_edge(CLK_IN) then      -- rising clock edge
      if BCK = '1' and sl_bck_pre = '0' then
        if WCLK = '1' then
          DEBUG(3) <= '1';
          sv_shiftreg <= sv_shiftreg(DATA_WIDTH-2 downto 0) & DIN;
        end if;
        if WCLK = '0' and sl_wclk_pre = '1' then
          if LRCK = '1' then
            DEBUG(1) <= '1';
            sv_left_in <= sv_shiftreg;
            DVAL       <= '0';
          else
            DEBUG(2) <= '1';
            sv_right_in <= sv_shiftreg;
            DVAL        <= '1';
          end if;
        end if;
        sl_wclk_pre <= WCLK;
        DEBUG(0) <= '1';
      else
        DEBUG <= (others => '0');
      end if;      
      sl_bck_pre <= BCK;
    end if;
    
  end process proc_rec;

--  -- purpose: This process handles the receiption of serial data
--  -- type   : sequential
--  -- inputs : CLK_IN, nRESET
--  -- outputs: 
--  proc_rec : process (CLK_IN, nRESET)
--    variable vv_shiftreg_l, vv_shiftreg_r : std_logic_vector(DATA_WIDTH-1 downto 0);
--    variable vn_count_l, vn_count_r       : natural range 0 to DATA_WIDTH;
--    variable vv_data_l, vv_data_r         : std_logic_vector(2*DATA_WIDTH-1 downto 0);
--  begin  -- process proc_rec
--    if nRESET = '0' then                -- asynchronous reset (active low)

--      vv_shiftreg_l := (others => '0');
--      vv_shiftreg_r := (others => '0');
--      sl_val_l      <= '0';
--      sl_val_l_pre  <= '0';
--      sl_val_r      <= '0';
--      sl_val_r_pre  <= '0';
--      vn_count_l    := 0;
--      vn_count_r    := 0;
--      sl_bck_pre    <= '0';
--      sl_lrck_pre   <= '0';

--    elsif rising_edge(CLK_IN) then      -- rising clock edge

--      DEBUG(0) <= BCK;
--      DEBUG(1) <= sl_bck_pre;
--      DEBUG(2) <= LRCK;
--      DEBUG(3) <= sl_lrck_pre;
--      DEBUG(4) <= sl_val_l;
--      DEBUG(5) <= sl_val_l_pre;
--      DEBUG(4) <= sl_val_r;
--      DEBUG(5) <= sl_val_r_pre;

--      -- This defines the rising clock edge of BCK
--      if sl_bck_pre = '0' and BCK = '1' then

--        if vn_count_l /= 0 then
--          vv_shiftreg_l(DATA_WIDTH-1 downto 1) := vv_shiftreg_l(DATA_WIDTH-2 downto 0);
--          vv_shiftreg_l(0)                     := DIN;
--        end if;

--        if vn_count_r /= 0 then
--          vv_shiftreg_r(DATA_WIDTH-1 downto 1) := vv_shiftreg_r(DATA_WIDTH-2 downto 0);
--          vv_shiftreg_r(0)                     := DIN;
--        end if;

--        -- The sequence LRCK '1' => '0' defines the left channel
--        if vn_count_l = 0 and LRCK = '0' and sl_lrck_pre = '1' then
--          vn_count_l := vn_count_l + 1;
--        elsif vn_count_l = DATA_WIDTH then
--          vn_count_l := 0;
--        elsif vn_count_l /= 0 then
--          vn_count_l := vn_count_l + 1;
--        end if;

--        -- The sequence LRCK '0' => '1' defines the right channel
--        if vn_count_r = 0 and LRCK = '1' and sl_lrck_pre = '0' then
--          vn_count_r := vn_count_r + 1;
--        elsif vn_count_r = DATA_WIDTH then
--          vn_count_r := 0;
--        elsif vn_count_r /= 0 then
--          vn_count_r := vn_count_r + 1;
--        end if;

--        if LRCK = '1' and sl_lrck_pre = '0' then
--          sl_val_l <= '0';
--        elsif sl_val_l = '0' and sl_val_l_pre = '1' then
--          sv_left_in <= vv_shiftreg_l;
--        elsif sl_val_l_pre = '0' then
--          sl_val_l <= '1';
--        end if;

--        if LRCK = '0' and sl_lrck_pre = '1' then
--          sl_val_r <= '0';
--        elsif sl_val_r = '0' and sl_val_r_pre = '1' then
--          sv_right_in <= vv_shiftreg_r;
--        elsif sl_val_r_pre = '0' then
--          sl_val_r <= '1';
--        end if;

--        sl_val_r_pre <= sl_val_r;
--        sl_val_l_pre <= sl_val_l;

--        sl_lrck_pre <= LRCK;

--        -- pragma translate_off
--        sn_count_r    <= vn_count;
--        sv_shiftreg_r <= vv_shiftreg;
--        sn_count_l    <= vn_count;
--        sv_shiftreg_l <= vv_shiftreg;
--        -- pragma translate_on

--      end if;

--      sl_bck_pre <= BCK;

--    end if;

--  end process proc_rec;


--  -- purpose: Makes the valid signal DVAL changing level each time a channel
--  --          has new data according to the finished data (e.g. left means low)
--  -- type   : sequential
--  -- inputs : CLK, nRESET
--  -- outputs: 
--  valid_toggle : process (CLK_IN, nRESET)
--    variable vl_dval : std_logic;
--  begin  -- process valid_toggle
--    if nRESET = '0' then                -- asynchronous reset (active low)
--      DVAL    <= '0';
--      vl_dval := '0';
--    elsif rising_edge(CLK_IN) then      -- rising clock edge
--      if (sl_val_l and sl_val_r) = '1' and vl_dval = '0' then
--        DVAL <= not LRCK;
--      end if;
--      vl_dval := sl_val_l and sl_val_r;
--    end if;
--  end process valid_toggle;

end behavioral;

