library ieee;
use ieee.std_logic_1164.all;

entity addAlu is
    port(
        A          : in  std_logic_vector(31 downto 0);
        B          : in  std_logic_vector(31 downto 0);
		  Result     : out std_logic_vector(31 downto 0)

    );
end addAlu;

architecture rtl of addAlu is

    component full_adder is
        port(
            A    : in  std_logic;
            B    : in  std_logic;
            Cin  : in  std_logic;
            Sum  : out std_logic;
            Cout : out std_logic
        );
    end component;
    
    signal carry   : std_logic_vector(32 downto 0);
    signal result_i: std_logic_vector(31 downto 0);

begin

    carry(0) <= '0';  -- initialize carry

    gen_alu: for i in 0 to 31 generate
        bit_inst: full_adder
            port map(
                A    => A(i),
                B    => B(i),
                Cin  => carry(i),
                Sum  => result_i(i),
                Cout => carry(i+1)
            );
    end generate;

    Result <= result_i;

end architecture;