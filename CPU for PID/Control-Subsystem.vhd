LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
--
ENTITY microcontrol IS 
GENERIC (cssize: NATURAL := 17);
PORT (
-- Nut bat dau, cac co dau, nho, zero
	start, zero, neg, cy: in  STD_LOGIC:='0';		
	clk		    : in  STD_LOGIC;
-- Dia chi cua cac thanh ghi RF dua toi port A, B, C
	fld_A, fld_B, fld_C : out UNSIGNED(3 DOWNTO 0):= (others => '0'); 
-- Cac phep toan trong ALU: SUB: 01, ADD: 00, MUL:10, MOV:11 
	alu_op 		    : out UNSIGNED(1 DOWNTO 0):= (others => '0'); 
-- Bit kiem soat tin hieu ra, vao X_in, R_out
	ldr_in, ldr_out	    : out STD_LOGIC:='0' ;	
-- Bit kiem soat khoi RF	
	ldRF, done 	    : out STD_LOGIC:='0' ;              
-- Bit lua chon tin hieu dua cho port C
	selR_in 	    : out UNSIGNED(2 DOWNTO 0):= (others => '0');
-- Bit kiem soat cac hang Kp, Ki, Kd 
	ld_Kp, ld_Ki, ld_Kd    : out STD_LOGIC:='0' ;	
	control_con	    : out STD_LOGIC :='0');
END microcontrol;
--
ARCHITECTURE behav_microprogram OF microcontrol IS 
	signal csar	    : NATURAL;
-- do dai bit trong cac mang
	signal uinstr 	    : UNSIGNED(25 DOWNTO 0);	
	alias  mode 	    : STD_LOGIC IS uinstr(25);
	alias  condition    : UNSIGNED(1 DOWNTO 0) IS uinstr(24 DOWNTO 23);
	alias  cond_val     : STD_LOGIC IS uinstr (22);
--
BEGIN   
PROCESS(clk)
	variable index: UNSIGNED(21 DOWNTO 0);
BEGIN 
  IF (clk'EVENT AND clk = '1') THEN 
    IF (mode = '0') then csar <= csar + 1;
    ELSE 
    CASE condition is
	WHEN "00" => IF (start = cond_val) THEN 
			index := uinstr(21 DOWNTO 0);
			csar <= CONV_INTEGER(index);
		     ELSE csar <= csar + 1 ;
		     END IF ;
	WHEN "01" => IF (zero = cond_val) THEN 
			index := uinstr(21 DOWNTO 0);
			csar <= CONV_INTEGER(index);
		     ELSE csar <= csar + 1 ;	
		     END IF ;
	WHEN "10" => IF (neg = cond_val) THEN 
			index := uinstr(21 DOWNTO 0);
			csar <= CONV_INTEGER(index);
		     ELSE csar <= csar + 1 ;	
		     END IF ;	
	WHEN "11" => IF (cy = cond_val) THEN 
			index := uinstr(21 DOWNTO 0);
			csar <= CONV_INTEGER(index);
		     ELSE csar <= csar + 1 ;	
		     END IF ;
	WHEN OTHERS => NULL;
    END CASE;
    END IF;
  END IF; 
END PROCESS;

PROCESS(csar)
  TYPE csarray IS ARRAY(0 TO cssize-1) OF UNSIGNED(25 DOWNTO 0);
  VARIABLE cs: csarray
     :=(0=> "00101000100010010000010001",
	1=> "10000000000000000000000001",
	2=> "00000000000000001011100001",
	3=> "00000000000000110000000001",
	4=> "00000000000011110000000101",
	5=> "00000000000011010000001001",
	6=> "00000000000010110000001101",
	7=> "01001010001100110000010001",
	8=> "01001100010101010000010001",
	9=> "00010100100001110000010001",
	10=> "00100010010101110000010001",
	11=> "01001111011110010000010001",
	12=> "00000111001110110000010001",
	13=> "00011011100100010100010001",
	14=> "01100010000001010000010001",
	15=> "01100110000010010000010010",
	16=> "10010000000000000000000001"
);
---- 
BEGIN 
  uinstr <= cs(csar);
  control_con <= uinstr(25);
CASE( uinstr(25)) IS
  WHEN '0' => 	alu_op <= uinstr(24 DOWNTO 23);
	   	fld_A  <= uinstr(22 DOWNTO 19);
		fld_B  <= uinstr(18 DOWNTO 15);
		fld_C  <= uinstr(14 DOWNTO 11);
		ldrF   <= uinstr(10);
		ldr_in <= uinstr(9);
		ld_Kd  <= uinstr(5);
		ld_Ki  <= uinstr(6);
		ld_Kp  <= uinstr(7);
		ldr_out<= uinstr(8);
		selR_in<= uinstr(4 DOWNTO 2);
  IF (uinstr(1) =  '1' ) then done <= '1', '0' after 50 ns; 
  END IF ;
  IF (uinstr(0) = '1' ) then done <= '0';
  END IF;
  WHEN '1' =>	ldrF   <= '0';
		ldr_in <= '0';
		ld_Kd  <= '0';
		ld_Ki  <= '0';
		ld_Kp  <= '0';
		ldr_out<= '0';
  WHEN OTHERS => NULL;
END CASE; 
END PROCESS;
END behav_microprogram;
  

