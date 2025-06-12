LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
--
ENTITY mainmicro IS 
PORT (
	start			: in  STD_LOGIC;		-- Nut bat dau
	clk		    	: in  STD_LOGIC;
	z_out			: OUT SIGNED (15 downto 0);
	x_in 			: IN SIGNED (15 downto 0);	-- Du lieu vao
	Kp,Ki,Kd 		: IN SIGNED (15 downto 0);	-- Du lieu vao	
	done 	    		: out STD_LOGIC 
 );
END mainmicro;


ARCHITECTURE main OF mainmicro IS 

signal fld_A, fld_B, fld_C   : unsigned(3 downto 0);
signal alu_op                : unsigned(1 downto 0);
signal ldR_in, ldR_out       : std_logic;
signal ldRF, done_internal   : std_logic;
signal selR_in               : unsigned(2 downto 0);
signal ld_Kp, ld_Ki, ld_Kd   : std_logic;
signal control_con           : std_logic;
signal cy, neg, zero         : std_logic;

component microdata is 
PORT( 
	clk			: IN STD_LOGIC;
	x_in 			: IN SIGNED (15 downto 0);
	Kp, Ki, Kd 		: IN SIGNED (15 downto 0);
	fld_A, fld_B, fld_C	: IN UNSIGNED (3 downto 0);
	alu_op			: IN UNSIGNED (1 downto 0);
	ldR_in, ldKp, ldKi, ldKd: IN STD_LOGIC;
	ldRF, ldR_out		: IN STD_LOGIC;
	selR_in			: IN UNSIGNED (2 downto 0);
	control_con		: IN  STD_LOGIC;
	cy, neg, zero		: OUT STD_LOGIC;
	z_out			: OUT SIGNED (15 downto 0) 
);
end component;

component microcontrol is
PORT (
	start, zero, neg, cy	: in  STD_LOGIC;
	clk		    	: in  STD_LOGIC;
	fld_A, fld_B, fld_C	: out UNSIGNED(3 DOWNTO 0);
	alu_op 		    	: out UNSIGNED(1 DOWNTO 0);
	ldr_in, ldr_out	    	: out STD_LOGIC;
	ldRF, done 	    	: out STD_LOGIC;
	selR_in 	    	: out UNSIGNED(2 DOWNTO 0);
	ld_Kp, ld_Ki, ld_Kd     : out STD_LOGIC;
	control_con	    	: out STD_LOGIC 
);
end component;

begin

u1: microdata
port map(
	clk => clk,
	x_in => x_in,
	Kp => Kp,
	Ki => Ki,
	Kd => Kd,
	fld_A => fld_A,
	fld_B => fld_B,
	fld_C => fld_C,
	alu_op => alu_op,
	ldR_in => ldR_in,
	ldKp => ld_Kp,
	ldKi => ld_Ki,
	ldKd => ld_Kd,
	ldRF => ldRF,
	ldR_out => ldR_out,
	selR_in => selR_in,
	control_con => control_con,
	cy => cy,
	neg => neg,
	zero => zero,
	z_out => z_out
);

u2: microcontrol
port map(
	start => start,
	zero => zero,
	neg => neg,
	cy => cy,
	clk => clk,
	fld_A => fld_A,
	fld_B => fld_B,
	fld_C => fld_C,
	alu_op => alu_op,
	ldr_in => ldR_in,
	ldr_out => ldR_out,
	ldRF => ldRF,
	done => done,
	selR_in => selR_in,
	ld_Kp => ld_Kp,
	ld_Ki => ld_Ki,
	ld_Kd => ld_Kd,
	control_con => control_con
);

end main;
