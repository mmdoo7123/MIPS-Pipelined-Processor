library ieee;
use ieee.std_logic_1164.all;

entity zeroALU is
    port(
        A          : in  std_logic_vector(31 downto 0);
        B          : in  std_logic_vector(31 downto 0);
        ALUControl : in  std_logic_vector(2 downto 0);
        Zero       : out std_logic;
		  Result     : out std_logic_vector(31 downto 0)

    );
end zeroALU;

architecture rtl of zeroALU is

    component alu_1bit is
        port(
            A       : in  std_logic;
            B       : in  std_logic;
            Cin     : in  std_logic;
            Binvert : in  std_logic;
            Op      : in  std_logic_vector(1 downto 0);
            Result  : out std_logic;
            Cout    : out std_logic
        );
    end component;
	 
	 component genericComparator is
        generic(n : integer := 8);
        port(
            i_Ai          : in  std_logic_vector(n-1 downto 0);
            i_Bi          : in  std_logic_vector(n-1 downto 0);
            o_GT, o_LT, o_EQ : out std_logic
        );
    end component;

    signal carry   : std_logic_vector(32 downto 0);
    signal result_i: std_logic_vector(31 downto 0);
    signal Binvert : std_logic;
    signal Op      : std_logic_vector(1 downto 0);
	 signal unused_GT, unused_LT : std_logic;


begin
    Binvert  <= ALUControl(2);
    Op       <= ALUControl(1 downto 0);
    carry(0) <= Binvert;

    gen_alu: for i in 0 to 31 generate
        bit_inst: alu_1bit
            port map(
                A       => A(i),
                B       => B(i),
                Cin     => carry(i),
                Binvert => Binvert,
                Op      => Op,
                Result  => result_i(i),
                Cout    => carry(i+1)
            );
    end generate;

    Result <= result_i;

	 zero_check: genericComparator
			  generic map(n => 32)
			  port map(
					i_Ai  => result_i,
					i_Bi  => (others => '0'),
					o_GT  => unused_GT,
					o_LT  => unused_LT,
					o_EQ  => Zero
        );
end architecture;