library ieee;
use ieee.std_logic_1164.all;

entity NOPMUX is
    port(
        i_Stall      : in  std_logic;  
        i_RegWrite   : in  std_logic;
        i_MemToReg   : in  std_logic;
        i_Branch     : in  std_logic;
        i_BranchNEQ  : in  std_logic;
        i_MemRead    : in  std_logic;
        i_MemWrite   : in  std_logic;
        i_RegDst     : in  std_logic;
        i_ALUSrc     : in  std_logic;
        i_ALUOp      : in  std_logic_vector(1 downto 0);
        o_RegWrite   : out std_logic;
        o_MemToReg   : out std_logic;
        o_Branch     : out std_logic;
        o_BranchNEQ  : out std_logic;
        o_MemRead    : out std_logic;
        o_MemWrite   : out std_logic;
        o_RegDst     : out std_logic;
        o_ALUSrc     : out std_logic;
        o_ALUOp      : out std_logic_vector(1 downto 0)
    );
end NOPMUX;

architecture rtl of NOPMUX is
    signal w_notStall : std_logic;
begin

    w_notStall <= NOT i_Stall;

    o_RegWrite  <= i_RegWrite  AND w_notStall;
    o_MemToReg  <= i_MemToReg  AND w_notStall;
    o_Branch    <= i_Branch    AND w_notStall;
    o_BranchNEQ <= i_BranchNEQ AND w_notStall;
    o_MemRead   <= i_MemRead   AND w_notStall;
    o_MemWrite  <= i_MemWrite  AND w_notStall;
    o_RegDst    <= i_RegDst    AND w_notStall;
    o_ALUSrc    <= i_ALUSrc    AND w_notStall;
    o_ALUOp(0)  <= i_ALUOp(0)  AND w_notStall;
    o_ALUOp(1)  <= i_ALUOp(1)  AND w_notStall;

end rtl;