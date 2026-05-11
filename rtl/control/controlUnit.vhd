library ieee;
use ieee.std_logic_1164.all;

entity ControlUnit is
    port(
        opcode     : in  std_logic_vector(5 downto 0);  -- instruction[31:26]
        RegDst     : out std_logic;
        Jump       : out std_logic;
        Branch     : out std_logic;
        BranchNEQ  : out std_logic;  
        MemtoReg   : out std_logic;
        ALUSrc     : out std_logic;
        MemRead    : out std_logic;
        MemWrite   : out std_logic;
        RegWrite   : out std_logic;
        Flush      : out std_logic; 
        ALUOp      : out std_logic_vector(1 downto 0)
    );
end ControlUnit;

architecture structural of ControlUnit is
    signal rFormat : std_logic;
    signal lw      : std_logic;
    signal sw      : std_logic;
    signal beq     : std_logic;
    signal bne     : std_logic;
    signal jumpsig : std_logic;
    signal nop5, nop4, nop3, nop2, nop1, nop0 : std_logic;
begin

    nop5 <= not opcode(5);
    nop4 <= not opcode(4);
    nop3 <= not opcode(3);
    nop2 <= not opcode(2);
    nop1 <= not opcode(1);
    nop0 <= not opcode(0);

    rFormat <= nop5 and nop4 and nop3 and nop2 and nop1 and nop0;  
    lw      <= opcode(5) and nop4 and nop3 and nop2 and opcode(1) and opcode(0);  
    sw      <= opcode(5) and nop4 and opcode(3) and nop2 and opcode(1) and opcode(0);  
    beq     <= nop5 and nop4 and nop3 and opcode(2) and nop1 and nop0;  
    bne     <= nop5 and nop4 and nop3 and opcode(2) and nop1 and opcode(0);  
    jumpsig <= nop5 and nop4 and nop3 and nop2 and opcode(1) and nop0;  

    RegDst    <= rFormat;
    Jump      <= jumpsig;
    Branch    <= beq;
    BranchNEQ <= bne;
    ALUSrc    <= lw or sw;
    MemtoReg  <= lw;
    RegWrite  <= lw or rFormat;
    MemRead   <= lw;
    MemWrite  <= sw;
    ALUOp(1)  <= rFormat;
    ALUOp(0)  <= beq or bne;

   
    Flush     <= beq or bne or jumpsig;

end architecture;