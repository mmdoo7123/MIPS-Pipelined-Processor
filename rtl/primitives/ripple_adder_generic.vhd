library ieee;
use ieee.std_logic_1164.all;

entity ripple_adder_generic is
    generic(
        N : integer := 32
    );
    port(
        A    : in  std_logic_vector(N-1 downto 0);
        B    : in  std_logic_vector(N-1 downto 0);
        Cin  : in  std_logic;
        Sum  : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end entity;

architecture structural of ripple_adder_generic is

    component full_adder
        port(
            A    : in  std_logic;
            B    : in  std_logic;
            Cin  : in  std_logic;
            Sum  : out std_logic;
            Cout : out std_logic
        );
    end component;

    signal carry : std_logic_vector(N downto 0);

begin

    carry(0) <= Cin;

    GEN_ADD: for i in 0 to N-1 generate
        FA: full_adder
            port map(
                A    => A(i),
                B    => B(i),
                Cin  => carry(i),
                Sum  => Sum(i),
                Cout => carry(i+1)
            );
    end generate;

    Cout <= carry(N);

end architecture;