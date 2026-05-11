LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY PC IS
    GENERIC (
        n : integer := 32
    );
    PORT(
        i_clock    : IN  STD_LOGIC;
        i_resetBar : IN  STD_LOGIC;
        i_PCWrite  : IN  STD_LOGIC;  -- from hazard detection unit; 0 = freeze PC
        i_data     : IN  STD_LOGIC_VECTOR(n-1 downto 0);
        o_q        : OUT STD_LOGIC_VECTOR(n-1 downto 0)
    );
END PC;

ARCHITECTURE structural OF PC IS

    COMPONENT enARdFF_2
        PORT(
            i_resetBar  : IN  STD_LOGIC;
            i_d         : IN  STD_LOGIC;
            i_enable    : IN  STD_LOGIC;
            i_clock     : IN  STD_LOGIC;
            o_q, o_qBar : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL w_enable      : STD_LOGIC;
    SIGNAL w_unusedQbar  : STD_LOGIC_VECTOR(n-1 downto 0);

BEGIN

    -- PC only advances when both load is asserted AND hazard unit permits it
    w_enable <= i_PCWrite;

    gen_reg: FOR i IN n-1 DOWNTO 0 GENERATE
        bit_inst: enARdFF_2
            PORT MAP (
                i_resetBar => i_resetBar,
                i_clock    => i_clock,
                i_enable   => w_enable,
                i_d        => i_data(i),
                o_q        => o_q(i),
                o_qBar     => w_unusedQbar(i)
            );
    END GENERATE;

END structural;