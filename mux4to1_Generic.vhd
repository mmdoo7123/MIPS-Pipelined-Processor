library ieee;
use ieee.std_logic_1164.all;

entity mux4to1_Generic is
    generic (
        N : integer := 32
    );
    port (
        A : in  std_logic_vector(N-1 downto 0);
        B : in  std_logic_vector(N-1 downto 0);
        C : in  std_logic_vector(N-1 downto 0);
        D : in  std_logic_vector(N-1 downto 0);
        S : in  std_logic_vector(1 downto 0);
        Y : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture rtl of mux4to1_Generic is
begin
    Y <= A when S = "00" else
         B when S = "01" else
         C when S = "10" else
         D when S = "11" else
         (others => '0');
end architecture;