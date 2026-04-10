LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY genericRegister IS
    GENERIC (
        n : integer := 8 
    );
    PORT(
        i_clock    : IN  STD_LOGIC;
        i_resetBar : IN  STD_LOGIC;
        i_load     : IN  STD_LOGIC; 
        i_data     : IN  STD_LOGIC_VECTOR(n-1 downto 0);
        o_q        : OUT STD_LOGIC_VECTOR(n-1 downto 0)
    );
END genericRegister;

ARCHITECTURE structural OF genericRegister IS
    COMPONENT enARdFF_2
        PORT(
            i_resetBar : IN  STD_LOGIC;
            i_d        : IN  STD_LOGIC;
            i_enable   : IN  STD_LOGIC;
            i_clock    : IN  STD_LOGIC;
            o_q, o_qBar : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL w_unusedQbar : STD_LOGIC_VECTOR(n-1 downto 0);
BEGIN
    gen_reg: FOR i IN n-1 DOWNTO 0 GENERATE
        bit_inst: enARdFF_2
            PORT MAP (
                i_resetBar => i_resetBar,
                i_clock    => i_clock,
                i_enable   => i_load,
                i_d        => i_data(i),
                o_q        => o_q(i),
                o_qBar     => w_unusedQbar(i)
            );
    END GENERATE;
END structural;