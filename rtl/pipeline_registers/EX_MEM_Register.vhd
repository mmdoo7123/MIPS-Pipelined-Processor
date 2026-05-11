-- =============================================================================
-- EX_MEM_Register
-- CEG3156 Lab 3 - Pipelined MIPS Processor
-- =============================================================================
-- Registers all signals between the EX and MEM pipeline stages.
--
-- Signal groups:
--   WB  : RegWrite, MemToReg       (continue to MEM/WB before use)
--   M   : Branch, BranchNEQ,       (used in MEM stage for PCSrc)
--          MemRead, MemWrite, Zero
--   Data: ALUResult (32-bit)       → data memory address + forwarding
--         ReadData2 (32-bit)       → data memory write data (SW)
--         RegisterRd (5-bit)       → write-back destination register
--
-- No flush input: EX/MEM does not need zeroing on stall.
-- The NOP bubble is injected one stage earlier at ID/EX.
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity EX_MEM_Register is
    port(
        Enable, GClock, GResetBAR : in  std_logic;

        -- ---------------------------------------------------------------
        -- WB group (pass-through to MEM/WB)
        -- ---------------------------------------------------------------
        i_RegWrite             : in  std_logic;
        i_MemToReg             : in  std_logic;

        o_RegWrite             : out std_logic;
        o_MemToReg             : out std_logic;

        -- ---------------------------------------------------------------
        -- M group (used in MEM stage)
        -- ---------------------------------------------------------------
        i_Branch               : in  std_logic;
        i_BranchNEQ            : in  std_logic;
        i_MemRead              : in  std_logic;
        i_MemWrite             : in  std_logic;
        i_Zero                 : in  std_logic;  -- ALU zero flag from EX

        o_Branch               : out std_logic;
        o_BranchNEQ            : out std_logic;
        o_MemRead              : out std_logic;
        o_MemWrite             : out std_logic;
        o_Zero                 : out std_logic;  -- registered: matched to branch in MEM

        -- ---------------------------------------------------------------
        -- Data: ALU result (32-bit)
        -- Used as: data memory address, forwarding source, WB data
        -- ---------------------------------------------------------------
        i_ALUResult            : in  std_logic_vector(31 downto 0);
        o_ALUResult            : out std_logic_vector(31 downto 0);

        -- ---------------------------------------------------------------
        -- Data: Store data (32-bit)
        -- This is the ForwardB mux output (w_ALU_B_pre in top-level),
        -- NOT raw ReadData2. Forwarding has already been applied so SW
        -- writes the correct (possibly forwarded) value to memory.
        -- ---------------------------------------------------------------
        i_StoreData            : in  std_logic_vector(31 downto 0);
        o_StoreData            : out std_logic_vector(31 downto 0);

        -- ---------------------------------------------------------------
        -- Register destination (5-bit)
        -- Output of RegDst mux in EX: either RT (I-type) or RD (R-type)
        -- Travels to MEM/WB then to register file write port
        -- ---------------------------------------------------------------
        i_RegisterRd           : in  std_logic_vector(4 downto 0);
        o_RegisterRd           : out std_logic_vector(4 downto 0);
		  Instruction               : in  std_logic_vector(31 downto 0);
        InstructionOut            : out std_logic_vector(31 downto 0)
    );
end EX_MEM_Register;

architecture rtl of EX_MEM_Register is

    component enARdFF_2
        port(
            i_resetBar  : in  std_logic;
            i_d         : in  std_logic;
            i_enable    : in  std_logic;
            i_clock     : in  std_logic;
            o_q, o_qBar : out std_logic
        );
    end component;

    component genericRegister
        generic(n : integer := 8);
        port(
            i_clock    : in  std_logic;
            i_resetBar : in  std_logic;
            i_load     : in  std_logic;
            i_data     : in  std_logic_vector(n-1 downto 0);
            o_q        : out std_logic_vector(n-1 downto 0)
        );
    end component;

    signal w_RegRd_q : std_logic_vector(4 downto 0);

begin

    -- =========================================================================
    -- WB group
    -- =========================================================================
    RWff:  enARdFF_2 port map(
        i_resetBar => GResetBAR, i_d => i_RegWrite,
        i_enable => Enable, i_clock => GClock,
        o_q => o_RegWrite, o_qBar => open);

    MtRff: enARdFF_2 port map(
        i_resetBar => GResetBAR, i_d => i_MemToReg,
        i_enable => Enable, i_clock => GClock,
        o_q => o_MemToReg, o_qBar => open);

    -- =========================================================================
    -- M group
    -- =========================================================================
    Brff:   enARdFF_2 port map(
        i_resetBar => GResetBAR, i_d => i_Branch,
        i_enable => Enable, i_clock => GClock,
        o_q => o_Branch, o_qBar => open);

    BNEQff: enARdFF_2 port map(
        i_resetBar => GResetBAR, i_d => i_BranchNEQ,
        i_enable => Enable, i_clock => GClock,
        o_q => o_BranchNEQ, o_qBar => open);

    MRff:   enARdFF_2 port map(
        i_resetBar => GResetBAR, i_d => i_MemRead,
        i_enable => Enable, i_clock => GClock,
        o_q => o_MemRead, o_qBar => open);

    MWRff:  enARdFF_2 port map(
        i_resetBar => GResetBAR, i_d => i_MemWrite,
        i_enable => Enable, i_clock => GClock,
        o_q => o_MemWrite, o_qBar => open);

    -- Zero registered here so PCSrc sees the zero flag that belongs to
    -- the branch instruction now in MEM, not the live ALU output from EX
    Zeroff: enARdFF_2 port map(
        i_resetBar => GResetBAR, i_d => i_Zero,
        i_enable => Enable, i_clock => GClock,
        o_q => o_Zero, o_qBar => open);

    -- =========================================================================
    -- ALU result (32-bit)
    -- =========================================================================
    ALUResultReg: genericRegister
        generic map(n => 32)
        port map(
            i_clock => GClock, i_resetBar => GResetBAR,
            i_load  => Enable,
            i_data  => i_ALUResult,
            o_q     => o_ALUResult);

    -- =========================================================================
    -- Store data (32-bit) — ForwardB mux output, feeds data memory WriteData
    -- =========================================================================
    StoreDataReg: genericRegister
        generic map(n => 32)
        port map(
            i_clock => GClock, i_resetBar => GResetBAR,
            i_load  => Enable,
            i_data  => i_StoreData,
            o_q     => o_StoreData);

    -- =========================================================================
    -- RegisterRd (5-bit) — RegDst mux output
    -- =========================================================================
    gen_RegRd: for k in 4 downto 0 generate
        RegRdff: enARdFF_2 port map(
            i_resetBar => GResetBAR, i_d => i_RegisterRd(k),
            i_enable => Enable, i_clock => GClock,
            o_q => w_RegRd_q(k), o_qBar => open);
    end generate;
	 	 instReg: genericRegister
        generic map(n => 32)
        port map(
            i_clock    => GClock,
            i_resetBar => GResetBAR,
            i_load     => Enable,
            i_data     => Instruction,
            o_q        => InstructionOut
        ); 
    o_RegisterRd <= w_RegRd_q;

end rtl;