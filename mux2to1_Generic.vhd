library ieee;
use ieee.std_logic_1164.all;

entity mux2to1_Generic is
    generic (
        N : integer := 32
    );
    port (
        A : in  std_logic_vector(N-1 downto 0);
        B : in  std_logic_vector(N-1 downto 0);
        S : in  std_logic;
        Y : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture rtl of mux2to1_Generic is
begin
    Y <= A when S = '0' else B;
end architecture rtl;
