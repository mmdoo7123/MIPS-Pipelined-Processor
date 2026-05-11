 library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instructionmemory is
    port (
        clk     : in  std_logic;                     -- Clock signal
        rst   : in  std_logic;                     -- Active-low reset
        address : in  std_logic_vector(7 downto 0);
        q       : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of instructionmemory is
begin
    process(clk, rst)
    begin
        if rst = '0' then
            -- Asynchronous active-low reset
            q <= (others => '0');
        elsif rising_edge(clk) then
            -- Synchronous read logic
            case address is
                when x"04" => q <= x"8C020000"; -- lw $2, 0($0)
                when x"08" => q <= x"8C030001"; -- lw $3, 1($0)
                when x"0C" => q <= x"00430820"; -- add $1, $2, $3
                when x"10" => q <= x"AC010003"; -- sw $1, 3($0)
                when x"14" => q <= x"1022FFFF"; -- beq $1, $2, -1
                when x"18" => q <= x"1021FFFA"; -- beq $1, $1, -6
                when others => q <= x"00000000"; 
            end case;
        end if;
    end process;
end architecture;