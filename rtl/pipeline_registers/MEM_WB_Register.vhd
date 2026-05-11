-- =============================================================================
-- MEM_WB_Register
-- CEG3156 Lab 3 - Pipelined MIPS Processor
-- =============================================================================
-- Registers all signals between the MEM and WB pipeline stages.
--
-- Signal groups:
--   WB  : RegWrite, MemToReg     (control for write-back stage)
--   Data: ReadData  (32-bit)     → MemToReg mux input 1 (lw result)
--         ALUResult (32-bit)     → MemToReg mux input 0 (R-type / I-type result)
--         RegisterRd (5-bit)     → register file write address
--
-- Instruction passthrough removed — all needed fields were extracted in ID/EX.
-- Enable tied to '1' in top-level — MEM/WB never stalls.
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity MEM_WB_Register is
    port(
        Enable, GClock, GResetBar : in  std_logic;

        -- ---------------------------------------------------------------
        -- WB control
        -- ---------------------------------------------------------------
        i_RegWrite             : in  std_logic;
        i_MemToReg             : in  std_logic;

        o_RegWrite             : out std_logic;
        o_MemToReg             : out std_logic;

        -- ---------------------------------------------------------------
        -- Data memory read result (32-bit) — from data_memory ReadData
        -- Selected by MemToReg mux when instruction is LW
        -- ---------------------------------------------------------------
        i_ReadData             : in  std_logic_vector(31 downto 0);
        o_ReadData             : out std_logic_vector(31 downto 0);

        -- ---------------------------------------------------------------
        -- ALU result (32-bit) — from EX/MEM o_ALUResult
        -- Selected by MemToReg mux for R-type and I-type (non-load)
        -- Also forwarding source back to ForwardA/B muxes
        -- ---------------------------------------------------------------
        i_ALUResult            : in  std_logic_vector(31 downto 0);
        o_ALUResult            : out std_logic_vector(31 downto 0);

        -- ---------------------------------------------------------------
        -- Destination register (5-bit) — from EX/MEM o_RegisterRd
        -- Wired to register file i_WriteReg
        -- ---------------------------------------------------------------
        i_RegisterRd           : in  std_logic_vector(4 downto 0);
        o_RegisterRd           : out std_logic_vector(4 downto 0);
		  Instruction               : in  std_logic_vector(31 downto 0);
        InstructionOut            : out std_logic_vector(31 downto 0)
    );
end MEM_WB_Register;

architecture rtl of MEM_WB_Register is

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
    -- WB control
    -- =========================================================================
    RWff:  enARdFF_2 port map(
        i_resetBar => GResetBar, i_d => i_RegWrite,
        i_enable => Enable, i_clock => GClock,
        o_q => o_RegWrite, o_qBar => open);

    MtRff: enARdFF_2 port map(
        i_resetBar => GResetBar, i_d => i_MemToReg,
        i_enable => Enable, i_clock => GClock,
        o_q => o_MemToReg, o_qBar => open);

    -- =========================================================================
    -- Data memory read result (32-bit)
    -- =========================================================================
    ReadDataReg: genericRegister
        generic map(n => 32)
        port map(
            i_clock => GClock, i_resetBar => GResetBar,
            i_load  => Enable,
            i_data  => i_ReadData,
            o_q     => o_ReadData);

    -- =========================================================================
    -- ALU result (32-bit)
    -- =========================================================================
    ALUResultReg: genericRegister
        generic map(n => 32)
        port map(
            i_clock => GClock, i_resetBar => GResetBar,
            i_load  => Enable,
            i_data  => i_ALUResult,
            o_q     => o_ALUResult);

    -- =========================================================================
    -- RegisterRd (5-bit)
    -- =========================================================================
    gen_RegRd: for k in 4 downto 0 generate
        RegRdff: enARdFF_2 port map(
            i_resetBar => GResetBar, i_d => i_RegisterRd(k),
            i_enable => Enable, i_clock => GClock,
            o_q => w_RegRd_q(k), o_qBar => open);
    end generate;
	 	 	 instReg: genericRegister
        generic map(n => 32)
        port map(
            i_clock    => GClock,
            i_resetBar => GResetBar,
            i_load     => Enable,
            i_data     => Instruction,
            o_q        => InstructionOut
        ); 
    o_RegisterRd <= w_RegRd_q;

end rtl;