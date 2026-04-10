library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port(
        clk      : in  std_logic;
        MemRead  : in  std_logic;
        MemWrite : in  std_logic;
        Address  : in  std_logic_vector(7 downto 0);   -- bottom 8 bits of ALU result
        WriteData: in  std_logic_vector(31 downto 0);  -- data to store (from ReadData2)
        ReadData : out std_logic_vector(31 downto 0)   -- data to load (to MemtoReg mux)
    );
end entity;

architecture rtl of data_memory is

    type mem_array is array(0 to 255) of std_logic_vector(31 downto 0);

    signal mem : mem_array := (
        0       => x"00000055",   -- address 0x00 = 0x55
        1       => x"000000AA",   -- address 0x01 = 0xAA
        others  => x"00000000"
    );

begin

    -- ASYNCHRONOUS READ (combinatorial, no clock)
    -- Required for single-cycle operation
    ReadData <= mem(to_integer(unsigned(Address))) when MemRead = '1'
                else (others => '0');

    -- SYNCHRONOUS WRITE (registered on rising edge)
    process(clk)
    begin
        if rising_edge(clk) then
            if MemWrite = '1' then
                mem(to_integer(unsigned(Address))) <= WriteData;
            end if;
        end if;
    end process;

end architecture;