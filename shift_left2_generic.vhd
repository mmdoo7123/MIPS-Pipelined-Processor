library ieee;
use ieee.std_logic_1164.all;

entity shift_left2_generic is
    generic (
        N : integer := 32
    );
    port(
        A : in  std_logic_vector(N-1 downto 0);
        Y : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture structural of shift_left2_generic is
begin

    Y(0) <= '0';
    Y(1) <= '0';

    GEN_SHIFT: for i in 2 to N-1 generate
        Y(i) <= A(i-2);
    end generate;

end architecture;