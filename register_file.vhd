-- =============================================================================
-- register_file
-- CEG3156 Lab 3 - Pipelined MIPS Processor
-- =============================================================================
-- 8 registers x 32-bit.
-- 5-bit port widths match the full MIPS instruction field (IF/ID outputs).
-- Internally uses lower 3 bits for addressing (8-register file).
-- Register $0 hardwired to zero — writes ignored.
-- Read ports: asynchronous (combinatorial mux).
-- Write port: synchronous rising-edge, active-low async reset.
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port(
        i_clock     : in  std_logic;
        i_resetBar  : in  std_logic;                      -- active-low async reset
        i_RegWrite  : in  std_logic;
        i_ReadReg1  : in  std_logic_vector(4 downto 0);   -- RS from IF/ID [25:21]
        i_ReadReg2  : in  std_logic_vector(4 downto 0);   -- RT from IF/ID [20:16]
        i_WriteReg  : in  std_logic_vector(4 downto 0);   -- destination from MEM/WB
        i_WriteData : in  std_logic_vector(31 downto 0);  -- WBData from MemToReg mux
        o_ReadData1 : out std_logic_vector(31 downto 0);
        o_ReadData2 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture structural of register_file is

    component genericRegister is
        generic(n : integer := 8);
        port(
            i_clock    : in  std_logic;
            i_resetBar : in  std_logic;
            i_load     : in  std_logic;
            i_data     : in  std_logic_vector(n-1 downto 0);
            o_q        : out std_logic_vector(n-1 downto 0)
        );
    end component;

    component thirtytwoBit8to1Mux is
        port(
            data_in0  : in  std_logic_vector(31 downto 0);
            data_in1  : in  std_logic_vector(31 downto 0);
            data_in2  : in  std_logic_vector(31 downto 0);
            data_in3  : in  std_logic_vector(31 downto 0);
            data_in4  : in  std_logic_vector(31 downto 0);
            data_in5  : in  std_logic_vector(31 downto 0);
            data_in6  : in  std_logic_vector(31 downto 0);
            data_in7  : in  std_logic_vector(31 downto 0);
            select_in : in  std_logic_vector(2 downto 0);
            mux_out   : out std_logic_vector(31 downto 0)
        );
    end component;

    type reg_array_t is array(0 to 7) of std_logic_vector(31 downto 0);
    signal w_reg_q    : reg_array_t;
    signal w_we       : std_logic_vector(7 downto 0);
    signal w_ReadReg1 : std_logic_vector(2 downto 0);
    signal w_ReadReg2 : std_logic_vector(2 downto 0);
    signal w_WriteReg : std_logic_vector(2 downto 0);

begin

    -- Use lower 3 bits of 5-bit MIPS register fields for 8-register addressing
    w_ReadReg1 <= i_ReadReg1(2 downto 0);
    w_ReadReg2 <= i_ReadReg2(2 downto 0);
    w_WriteReg <= i_WriteReg(2 downto 0);

    -- Write enable: one-hot decoder, $0 never written
    gen_we: for i in 0 to 7 generate
        w_we(i) <= i_RegWrite
                   when (unsigned(w_WriteReg) = to_unsigned(i, 3) and i /= 0)
                   else '0';
    end generate;

    -- $0 hardwired to zero
    w_reg_q(0) <= (others => '0');

    -- Registers $1..$7
    gen_regs: for i in 1 to 7 generate
        u_reg: genericRegister
            generic map(n => 32)
            port map(
                i_clock    => i_clock,
                i_resetBar => i_resetBar,
                i_load     => w_we(i),
                i_data     => i_WriteData,
                o_q        => w_reg_q(i)
            );
    end generate;

    -- Read port 1 (asynchronous)
    u_MUX_RD1: thirtytwoBit8to1Mux
        port map(
            data_in0 => w_reg_q(0), data_in1 => w_reg_q(1),
            data_in2 => w_reg_q(2), data_in3 => w_reg_q(3),
            data_in4 => w_reg_q(4), data_in5 => w_reg_q(5),
            data_in6 => w_reg_q(6), data_in7 => w_reg_q(7),
            select_in => w_ReadReg1,
            mux_out   => o_ReadData1
        );

    -- Read port 2 (asynchronous)
    u_MUX_RD2: thirtytwoBit8to1Mux
        port map(
            data_in0 => w_reg_q(0), data_in1 => w_reg_q(1),
            data_in2 => w_reg_q(2), data_in3 => w_reg_q(3),
            data_in4 => w_reg_q(4), data_in5 => w_reg_q(5),
            data_in6 => w_reg_q(6), data_in7 => w_reg_q(7),
            select_in => w_ReadReg2,
            mux_out   => o_ReadData2
        );

end architecture;