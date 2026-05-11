library ieee;
use ieee.std_logic_1164.all;

entity alu_control is
    port(
        ALUOp      : in  std_logic_vector(1 downto 0); 
        instruction      : in  std_logic_vector(5 downto 0);  
        ALUControl : out std_logic_vector(2 downto 0)  
    );
end entity;

architecture structural of alu_control is



	 signal or2f : std_logic;
	 signal op1andf1 : std_logic;


	 
    signal not_op1      : std_logic;
    signal not_funct2   : std_logic;

    signal and_op1_f1   : std_logic;
    signal and_op1_nf2  : std_logic;
    signal and_op1_f0   : std_logic;

begin

    -- 
	     not_funct2 <= not instruction(2);
		  not_op1    <= not ALUOp(1);

	 
	 or2f <= instruction(0) or instruction(3);
	 op1andf1 <= instruction(1) and ALUOp(1);
	 ALUControl(0) <= or2f and ALUOp(1);
	 ALUControl(1) <= not_op1 or not_funct2;
	 ALUControl(2) <= ALUOp(0) or op1andf1;
	 
	

end architecture;