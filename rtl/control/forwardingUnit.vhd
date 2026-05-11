-- =============================================================================
-- Forwarding Unit
-- CEG3156 Lab 3 - Pipelined MIPS Processor
-- =============================================================================
-- Equations:
--   E_A = EX/MEM.RegWrite AND (EX/MEM.RegisterRd /= 0) AND (EX/MEM.RegisterRd = ID/EX.RegisterRs)
--   M_A = MEM/WB.RegWrite AND (MEM/WB.RegisterRd /= 0) AND (MEM/WB.RegisterRd = ID/EX.RegisterRs)
--   E_B = EX/MEM.RegWrite AND (EX/MEM.RegisterRd /= 0) AND (EX/MEM.RegisterRd = ID/EX.RegisterRt)
--   M_B = MEM/WB.RegWrite AND (MEM/WB.RegisterRd /= 0) AND (MEM/WB.RegisterRd = ID/EX.RegisterRt)
--
--   ForwardA(1) = E_A
--   ForwardA(0) = (NOT E_A) AND M_A
--   ForwardB(1) = E_B
--   ForwardB(0) = (NOT E_B) AND M_B
--
-- Fix: all register ID comparisons widened from 3-bit to 5-bit.
--   With 3-bit, registers $0 and $8 aliased (both "000"), causing missed
--   forwards and false forwards across the full 32-register file.
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity forwardingUnit is
    port(
        i_EXMEM_RegWrite   : in  std_logic;
        i_EXMEM_RegisterRd : in  std_logic_vector(4 downto 0);  -- from EX/MEM RegisterRdOut
        i_MEMWB_RegWrite   : in  std_logic;
        i_MEMWB_RegisterRd : in  std_logic_vector(4 downto 0);  -- from MEM/WB RegisterRdOut
        i_IDEX_RegisterRs  : in  std_logic_vector(4 downto 0);  -- from ID/EX o_RS (full 5-bit)
        i_IDEX_RegisterRt  : in  std_logic_vector(4 downto 0);  -- from ID/EX o_RT (full 5-bit)
        o_ForwardA         : out std_logic_vector(1 downto 0);
        o_ForwardB         : out std_logic_vector(1 downto 0)
    );
end forwardingUnit;

architecture structural of forwardingUnit is

    component genericComparator
        generic(n : integer := 8);
        port(
            i_Ai, i_Bi       : in  std_logic_vector(n-1 downto 0);
            o_GT, o_LT, o_EQ : out std_logic
        );
    end component;

    constant zero5 : std_logic_vector(4 downto 0) := (others => '0');

    signal w_EQ_EXMEM_zero : std_logic;
    signal w_EQ_MEMWB_zero : std_logic;
    signal w_EQ_EXMEM_Rs   : std_logic;
    signal w_EQ_MEMWB_Rs   : std_logic;
    signal w_EQ_EXMEM_Rt   : std_logic;
    signal w_EQ_MEMWB_Rt   : std_logic;

    signal w_NEQ_EXMEM : std_logic;
    signal w_NEQ_MEMWB : std_logic;

    signal w_E_A : std_logic;
    signal w_M_A : std_logic;
    signal w_E_B : std_logic;
    signal w_M_B : std_logic;

begin

    -- EX/MEM.RegisterRd vs $0
    comp_EXMEM_zero: genericComparator
        generic map(n => 5)
        port map(i_Ai => i_EXMEM_RegisterRd, i_Bi => zero5,
                 o_GT => open, o_LT => open, o_EQ => w_EQ_EXMEM_zero);

    -- MEM/WB.RegisterRd vs $0
    comp_MEMWB_zero: genericComparator
        generic map(n => 5)
        port map(i_Ai => i_MEMWB_RegisterRd, i_Bi => zero5,
                 o_GT => open, o_LT => open, o_EQ => w_EQ_MEMWB_zero);

    -- EX/MEM.RegisterRd vs ID/EX.RS
    comp_EXMEM_Rs: genericComparator
        generic map(n => 5)
        port map(i_Ai => i_EXMEM_RegisterRd, i_Bi => i_IDEX_RegisterRs,
                 o_GT => open, o_LT => open, o_EQ => w_EQ_EXMEM_Rs);

    -- MEM/WB.RegisterRd vs ID/EX.RS
    comp_MEMWB_Rs: genericComparator
        generic map(n => 5)
        port map(i_Ai => i_MEMWB_RegisterRd, i_Bi => i_IDEX_RegisterRs,
                 o_GT => open, o_LT => open, o_EQ => w_EQ_MEMWB_Rs);

    -- EX/MEM.RegisterRd vs ID/EX.RT
    comp_EXMEM_Rt: genericComparator
        generic map(n => 5)
        port map(i_Ai => i_EXMEM_RegisterRd, i_Bi => i_IDEX_RegisterRt,
                 o_GT => open, o_LT => open, o_EQ => w_EQ_EXMEM_Rt);

    -- MEM/WB.RegisterRd vs ID/EX.RT
    comp_MEMWB_Rt: genericComparator
        generic map(n => 5)
        port map(i_Ai => i_MEMWB_RegisterRd, i_Bi => i_IDEX_RegisterRt,
                 o_GT => open, o_LT => open, o_EQ => w_EQ_MEMWB_Rt);

    -- /= 0 checks
    w_NEQ_EXMEM <= not w_EQ_EXMEM_zero;
    w_NEQ_MEMWB <= not w_EQ_MEMWB_zero;

    -- Forwarding conditions
    w_E_A <= i_EXMEM_RegWrite and w_NEQ_EXMEM and w_EQ_EXMEM_Rs;
    w_M_A <= i_MEMWB_RegWrite and w_NEQ_MEMWB and w_EQ_MEMWB_Rs;
    w_E_B <= i_EXMEM_RegWrite and w_NEQ_EXMEM and w_EQ_EXMEM_Rt;
    w_M_B <= i_MEMWB_RegWrite and w_NEQ_MEMWB and w_EQ_MEMWB_Rt;

    -- ForwardA: "10" = forward from EX/MEM, "01" = forward from MEM/WB, "00" = no forward
    o_ForwardA(1) <= w_E_A;
    o_ForwardA(0) <= (not w_E_A) and w_M_A;

    -- ForwardB: same encoding
    o_ForwardB(1) <= w_E_B;
    o_ForwardB(0) <= (not w_E_B) and w_M_B;

end structural;