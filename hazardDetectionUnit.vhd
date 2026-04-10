-- =============================================================================
-- Hazard Detection Unit
-- CEG3156 Lab 3 - Pipelined MIPS Processor
-- =============================================================================
-- Detects load-use hazards:
--
--   IF (ID/EX.MemRead AND
--       ((ID/EX.RegisterRt = IF/ID.RegisterRs) OR
--        (ID/EX.RegisterRt = IF/ID.RegisterRt))) THEN
--       o_Stall   = 1   -> freezes IF/ID (Enable=0) and PC (PCWrite=0)
--       o_PCWrite = 0
--   ELSE
--       o_Stall   = 0
--       o_PCWrite = 1
--
-- All register comparisons are 5-bit (full MIPS register field width).
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity hazardDetectionUnit is
    port(
        i_IDEX_MemRead : in  std_logic;
        i_IDEX_RT      : in  std_logic_vector(4 downto 0); 
        i_IFID_RS      : in  std_logic_vector(4 downto 0);  
        i_IFID_RT      : in  std_logic_vector(4 downto 0);  
        o_PCWrite      : out std_logic;
        o_Stall        : out std_logic
    );
end hazardDetectionUnit;

architecture structural of hazardDetectionUnit is

    component genericComparator
        generic(n : integer := 8);
        port(
            i_Ai, i_Bi       : in  std_logic_vector(n-1 downto 0);
            o_GT, o_LT, o_EQ : out std_logic
        );
    end component;

    signal w_EQ_RT_RS  : std_logic;
    signal w_EQ_RT_RT  : std_logic;
    signal w_OR_result : std_logic;
    signal w_Stall     : std_logic;

begin

    -- Compare ID/EX.RT vs IF/ID.RS (5-bit)
    comp_RS: genericComparator
        generic map(n => 5)
        port map(
            i_Ai => i_IDEX_RT,
            i_Bi => i_IFID_RS,
            o_GT => open,
            o_LT => open,
            o_EQ => w_EQ_RT_RS
        );

    -- Compare ID/EX.RT vs IF/ID.RT (5-bit)
    comp_RT: genericComparator
        generic map(n => 5)
        port map(
            i_Ai => i_IDEX_RT,
            i_Bi => i_IFID_RT,
            o_GT => open,
            o_LT => open,
            o_EQ => w_EQ_RT_RT
        );

    w_OR_result <= w_EQ_RT_RS OR w_EQ_RT_RT;
    w_Stall     <= i_IDEX_MemRead AND w_OR_result;

    o_Stall   <= w_Stall;
    o_PCWrite <= NOT w_Stall;

end structural;