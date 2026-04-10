library ieee;
use ieee.std_logic_1164.all;

entity pc_inc_alu is
    port(
        pc_in  : in  std_logic_vector(31 downto 0);
        pc_out : out std_logic_vector(31 downto 0)
    );
end pc_inc_alu;

architecture rtl of pc_inc_alu is

    component full_adder is
        port(
            A    : in  std_logic;
            B    : in  std_logic;
            Cin  : in  std_logic;
            Sum  : out std_logic;
            Cout : out std_logic
        );
    end component;

    signal carry : std_logic_vector(32 downto 0);
    
    signal addend : std_logic_vector(31 downto 0) := (2 => '1', others => '0');

begin

    carry(0) <= '0';

    gen_adder: for i in 0 to 31 generate
        bit_inst: full_adder
            port map(
                A    => pc_in(i),
                B    => addend(i),
                Cin  => carry(i),
                Sum  => pc_out(i),
                Cout => carry(i+1)
            );
    end generate;

end architecture;