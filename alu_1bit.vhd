library ieee;
use ieee.std_logic_1164.all;

entity alu_1bit is
    port(
        A        : in  std_logic;
        B        : in  std_logic;
        Cin      : in  std_logic;
        Binvert  : in  std_logic;
        Op       : in  std_logic_vector(1 downto 0);
        Result   : out std_logic;
        Cout     : out std_logic
    );
end entity;

architecture rtl of alu_1bit is

    component full_adder is
        port(
            A    : in  std_logic;
            B    : in  std_logic;
            Cin  : in  std_logic;
            Sum  : out std_logic;
            Cout : out std_logic
        );
    end component;

    signal B_eff   : std_logic;
    signal and_out : std_logic;
    signal or_out  : std_logic;
    signal add_out : std_logic;

begin

    B_eff   <= B xor Binvert;
    and_out <= A and B_eff;
    or_out  <= A or  B_eff;

    fa: full_adder
        port map(
            A    => A,
            B    => B_eff,
            Cin  => Cin,
            Sum  => add_out,
            Cout => Cout
        );

    with Op select
        Result <= and_out when "00",  -- AND
                  or_out  when "01",  -- OR
                  add_out when "10",  -- ADD or SUB
                  '0'     when others;

end architecture;