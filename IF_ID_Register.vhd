library ieee;
use ieee.std_logic_1164.all;

entity IF_ID_Register is
    port(
        Enable, GClock, GResetBar : in  std_logic;
        i_flush                   : in  std_logic;
        PCAdd4                    : in  std_logic_vector( 31 downto 0);
        Instruction               : in  std_logic_vector(31 downto 0);
        PCAdd4Out                 : out std_logic_vector( 31 downto 0);
        InstructionOut            : out std_logic_vector(31 downto 0)
    );
end IF_ID_Register;

architecture rtl of IF_ID_Register is

    component genericRegister
        generic(n : integer := 32);
        port(
            i_clock    : in  std_logic;
            i_resetBar : in  std_logic;
            i_load     : in  std_logic;
            i_data     : in  std_logic_vector(n-1 downto 0);
            o_q        : out std_logic_vector(n-1 downto 0)
        );
    end component;

    signal w_resetBar : std_logic;

begin

    w_resetBar <= GResetBar AND (NOT i_flush);

    PCadd4Reg: genericRegister
        generic map(n => 32)
        port map(
            i_clock    => GClock,
            i_resetBar => w_resetBar,
            i_load     => Enable,
            i_data     => PCAdd4,
            o_q        => PCAdd4Out
        );

    instReg: genericRegister
        generic map(n => 32)
        port map(
            i_clock    => GClock,
            i_resetBar => w_resetBar,
            i_load     => Enable,
            i_data     => Instruction,
            o_q        => InstructionOut
        );

end rtl;