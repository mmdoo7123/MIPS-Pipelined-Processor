library ieee;
use ieee.std_logic_1164.all;
entity sign_ext is
    port(
        imm16 : in  std_logic_vector(15 downto 0);
        imm32 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture structural of sign_ext is
    signal signbit : std_logic;
begin
    signbit <= imm16(15);

    imm32(15 downto 0) <= imm16(15 downto 0);

    imm32(16) <= signbit;
    imm32(17) <= signbit;
    imm32(18) <= signbit;
    imm32(19) <= signbit;
    imm32(20) <= signbit;
    imm32(21) <= signbit;
    imm32(22) <= signbit;
    imm32(23) <= signbit;
    imm32(24) <= signbit;
    imm32(25) <= signbit;
    imm32(26) <= signbit;
    imm32(27) <= signbit;
    imm32(28) <= signbit;
    imm32(29) <= signbit;
    imm32(30) <= signbit;
    imm32(31) <= signbit;
end architecture;