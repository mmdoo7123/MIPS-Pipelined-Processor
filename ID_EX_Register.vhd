library ieee;
use ieee.std_logic_1164.all;

entity ID_EX_Register is
    port(
        Enable, GClock, GReset : in  std_logic;
        i_flush                : in  std_logic;

        -- EX group
        i_ALUSrc               : in  std_logic;
        i_ALUOp                : in  std_logic_vector(1 downto 0);
        i_RegDst               : in  std_logic;

        o_ALUSrc               : out std_logic;
        o_ALUOp                : out std_logic_vector(1 downto 0);
        o_RegDst               : out std_logic;

        -- M group (Branch signals removed as they are handled in ID)
        i_MemRead              : in  std_logic;
        i_MemWrite             : in  std_logic;

        o_MemRead              : out std_logic;
        o_MemWrite             : out std_logic;

        -- WB group
        i_RegWrite             : in  std_logic;
        i_MemToReg             : in  std_logic;

        o_RegWrite             : out std_logic;
        o_MemToReg             : out std_logic;

        -- Data Path Signals
        i_PCAdd4               : in  std_logic_vector(31 downto 0);
        o_PCAdd4               : out std_logic_vector(31 downto 0);

        i_ReadData1            : in  std_logic_vector(31 downto 0);
        i_ReadData2            : in  std_logic_vector(31 downto 0);

        o_ReadData1            : out std_logic_vector(31 downto 0);
        o_ReadData2            : out std_logic_vector(31 downto 0);

        i_SignExtend           : in  std_logic_vector(31 downto 0);
        o_SignExtend           : out std_logic_vector(31 downto 0);

        -- Register address fields
        i_RS                   : in  std_logic_vector(4 downto 0);
        i_RT                   : in  std_logic_vector(4 downto 0);
        i_RD                   : in  std_logic_vector(4 downto 0);

        o_RS                   : out std_logic_vector(4 downto 0);
        o_RT                   : out std_logic_vector(4 downto 0);
        o_RD                   : out std_logic_vector(4 downto 0);
		  Instruction               : in  std_logic_vector(31 downto 0);
        InstructionOut            : out std_logic_vector(31 downto 0)
    );
end ID_EX_Register;

architecture rtl of ID_EX_Register is

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

    signal w_controlResetBar : std_logic;
    signal w_dataResetBar    : std_logic;

begin

    -- Control signals reset on GReset OR i_flush (to insert NOP bubble)
    w_controlResetBar <= GReset AND (NOT i_flush); 

    -- Data signals ONLY reset on GReset (preserved during stall)
    w_dataResetBar    <= GReset;

    ---------------------------------------------------------------------------
    -- CONTROL SIGNALS (Cleared on Stall/Flush)
    ---------------------------------------------------------------------------
    ALUSrcff: enARdFF_2 port map(w_controlResetBar, i_ALUSrc, Enable, GClock, o_ALUSrc);
    ALUOp0ff: enARdFF_2 port map(w_controlResetBar, i_ALUOp(0), Enable, GClock, o_ALUOp(0));
    ALUOp1ff: enARdFF_2 port map(w_controlResetBar, i_ALUOp(1), Enable, GClock, o_ALUOp(1));
    RegDstff: enARdFF_2 port map(w_controlResetBar, i_RegDst, Enable, GClock, o_RegDst);

    MRff:     enARdFF_2 port map(w_controlResetBar, i_MemRead, Enable, GClock, o_MemRead);
    MWRff:    enARdFF_2 port map(w_controlResetBar, i_MemWrite, Enable, GClock, o_MemWrite);

    RWff:     enARdFF_2 port map(w_controlResetBar, i_RegWrite, Enable, GClock, o_RegWrite);
    MtRff:    enARdFF_2 port map(w_controlResetBar, i_MemToReg, Enable, GClock, o_MemToReg);

    ---------------------------------------------------------------------------
    -- DATA SIGNALS (Preserved on Stall)
    ---------------------------------------------------------------------------
    PCAdd4Reg:  genericRegister generic map(32) port map(GClock, w_dataResetBar, Enable, i_PCAdd4, o_PCAdd4); 
    RD1Reg:     genericRegister generic map(32) port map(GClock, w_dataResetBar, Enable, i_ReadData1, o_ReadData1); 
    RD2Reg:     genericRegister generic map(32) port map(GClock, w_dataResetBar, Enable, i_ReadData2, o_ReadData2); 
    SignExtReg: genericRegister generic map(32) port map(GClock, w_dataResetBar, Enable, i_SignExtend, o_SignExtend); 

    -- Register Addresses (5-bit)
    RS_Reg:     genericRegister generic map(5)  port map(GClock, w_dataResetBar, Enable, i_RS, o_RS); 
    RT_Reg:     genericRegister generic map(5)  port map(GClock, w_dataResetBar, Enable, i_RT, o_RT); 
    RD_Reg:     genericRegister generic map(5)  port map(GClock, w_dataResetBar, Enable, i_RD, o_RD);
	 instReg: genericRegister
        generic map(n => 32)
        port map(
            i_clock    => GClock,
            i_resetBar => w_dataResetBar,
            i_load     => Enable,
            i_data     => Instruction,
            o_q        => InstructionOut
        ); 

end rtl;