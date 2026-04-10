LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY genericComparator IS
    GENERIC (
        n : integer := 8 -- Default width is 8, can be overridden
    );
    PORT(
        i_Ai, i_Bi            : IN    STD_LOGIC_VECTOR(n-1 downto 0);
        o_GT, o_LT, o_EQ      : OUT   STD_LOGIC
    );
END genericComparator;

ARCHITECTURE structural OF genericComparator IS
    SIGNAL int_GT, int_LT : STD_LOGIC_VECTOR(n-1 downto 0);
    SIGNAL gnd : STD_LOGIC;

    COMPONENT oneBitComparator
    PORT(
        i_GTPrevious, i_LTPrevious    : IN    STD_LOGIC;
        i_Ai, i_Bi                    : IN    STD_LOGIC;
        o_GT, o_LT                    : OUT   STD_LOGIC
    );
    END COMPONENT;

BEGIN
    gnd <= '0';

    comp_msb: oneBitComparator
        PORT MAP (
            i_GTPrevious => gnd, 
            i_LTPrevious => gnd,
            i_Ai         => i_Ai(n-1),
            i_Bi         => i_Bi(n-1),
            o_GT         => int_GT(n-1),
            o_LT         => int_LT(n-1)
        );

    gen_comp: FOR i IN n-2 DOWNTO 0 GENERATE
        comp: oneBitComparator
            PORT MAP (
                i_GTPrevious => int_GT(i+1), 
                i_LTPrevious => int_LT(i+1),
                i_Ai         => i_Ai(i),
                i_Bi         => i_Bi(i),
                o_GT         => int_GT(i),
                o_LT         => int_LT(i)
            );
    END GENERATE;

    o_GT <= int_GT(0);
    o_LT <= int_LT(0);
    
    o_EQ <= int_GT(0) NOR int_LT(0);

END structural;