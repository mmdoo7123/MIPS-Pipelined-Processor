LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY thirtytwoBit8to1Mux IS
    port (
        data_in0   : in  std_logic_vector(31 downto 0);
        data_in1   : in  std_logic_vector(31 downto 0);
        data_in2   : in  std_logic_vector(31 downto 0);
        data_in3   : in  std_logic_vector(31 downto 0);
        data_in4   : in  std_logic_vector(31 downto 0);
        data_in5   : in  std_logic_vector(31 downto 0);
        data_in6   : in  std_logic_vector(31 downto 0);
        data_in7   : in  std_logic_vector(31 downto 0);
        select_in  : in  std_logic_vector(2 downto 0);
        mux_out    : out std_logic_vector(31 downto 0)
    );
END thirtytwoBit8to1Mux;

ARCHITECTURE rtl OF thirtytwoBit8to1Mux IS
begin
    with select_in select
        mux_out <= data_in0 when "000",
                   data_in1 when "001",
                   data_in2 when "010",
                   data_in3 when "011",
                   data_in4 when "100",
                   data_in5 when "101",
                   data_in6 when "110",
                   data_in7 when "111",
                   (others => '0') when others;
END rtl;