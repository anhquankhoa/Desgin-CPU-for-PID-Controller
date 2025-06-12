library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

ENTITY microdata IS
PORT( 	clk			: IN STD_LOGIC;
	x_in 			: IN SIGNED (15 downto 0);	-- Du lieu vao
	Kp,Ki,Kd 		: IN SIGNED (15 downto 0);	-- Du lieu vao
	fld_A,fld_B,fld_C	: IN UNSIGNED (3 downto 0);	-- Dia chi cua cong A,B,C
	alu_op			: IN UNSIGNED (1 downto 0);	-- Lua chon phep tinh thuc hien cua ALU
	ldR_in,ldKp,ldKi,ldKd	: IN STD_LOGIC;			-- Cho phep doc x_in, Kp,Ki,Kd
	ldRF,ldR_out		: IN STD_LOGIC;			-- Cho phep doc cong C va alu_out
	selR_in			: IN UNSIGNED (2 downto 0);	-- Lua chon du lieu nhap vao cong C
	control_con		: IN  STD_LOGIC;
	cy,neg,zero		: OUT STD_LOGIC;		-- Cac co cua ALU
	z_out			: OUT SIGNED (15 downto 0) );	-- Du lieu ra
END microdata;

ARCHITECTURE microdata_arch OF microdata IS
	TYPE reg_fileT IS ARRAY(0 TO 15) OF SIGNED(15 downto 0);	-- Kieu mang 16 phan tu kieu SIGNED 16 bit
	SIGNAL RF 		:reg_fileT:=(X"0010",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",
					     X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000",X"0000");			
	SIGNAL R_in,K_p,K_i,K_d	: SIGNED(15 downto 0);
--------------------------------Khai bao chuong trinh con ALU----------------------------------------------
PROCEDURE alu (	A,B		: IN SIGNED(15 downto 0);	-- Du lieu vao 
		alu_op		: IN UNSIGNED(1 downto 0);	
		zzero,nneg,ccy	: OUT STD_LOGIC;
		alu_out		: OUT SIGNED(15 downto 0) ) IS
	VARIABLE alu_out_reg	: SIGNED(16 downto 0);
	VARIABLE alu_out_mul	: SIGNED(31 downto 0);
	VARIABLE overflow	: STD_LOGIC;
	VARIABLE B_bu2		: SIGNED(15 downto 0);
BEGIN
	CASE alu_op IS
		WHEN "00" => 	alu_out_reg := ("0"&A)+("0"&B);	--add
				overflow:= (A(15)and B(15) and not(alu_out_reg(15))) or (not(A(15)) and not(B(15)) and alu_out_reg(15));
			     	ccy:= alu_out_reg(16);
			     	IF (alu_out_reg(15 downto 0))= 0 then zzero:='1';
			     	ELSE zzero:= '0';
			     	END IF;
				IF overflow='1' THEN
					IF alu_out_reg(16)='1' THEN
						alu_out:= X"8000";
						nneg:= '1';
					ELSE 
						alu_out:= X"7FFF";
						nneg:= '0';
					END IF;
				ELSE
					alu_out:= alu_out_reg(15 downto 0);
					nneg := alu_out_reg(15);
				END IF;
		WHEN "01" => 	B_bu2:= -B;			--sub
				alu_out_reg := ("0"&A)+("0"&B_bu2);	--add
				overflow:= (A(15)and B_bu2(15) and not(alu_out_reg(15))) or (not(A(15)) and not(B_bu2(15)) and alu_out_reg(15));
			     	ccy:= alu_out_reg(16);
			     	IF (alu_out_reg(15 downto 0))= 0 then zzero:='1';
			     	ELSE zzero:= '0';
			     	END IF;
				IF overflow='1' THEN
					IF alu_out_reg(16)='1' THEN
						alu_out:= X"8000";
						nneg:= '1';
					ELSE 
						alu_out:= X"7FFF";
						nneg:= '0';
					END IF;
				ELSE
					alu_out:= alu_out_reg(15 downto 0);
					nneg := alu_out_reg(15);
				END IF;
		WHEN "10" => 	alu_out_mul:= A*B;		--mull
				alu_out:= alu_out_mul(30 downto 15);
		WHEN "11" =>	alu_out:= A;			-- MOVE A
		WHEN OTHERS => 	null;
	END CASE;
END alu;
---------------------------------------------------------------------------
BEGIN
	PROCESS(clk)
		VARIABLE A,B,C		: SIGNED (15 downto 0);
		VARIABLE alu_out	: SIGNED (15 downto 0);
		VARIABLE zzero,nneg,ccy	: STD_LOGIC;
	BEGIN
		A:= RF(CONV_INTEGER(fld_A));		-- Read port A
		B:= RF(CONV_INTEGER(fld_B));		-- Read port A
	IF control_con = '0' THEN	
		U_ALU: alu( 	A=> A,B => B,		-- Khai bao su dung ALU
				alu_op => alu_op,
				zzero => zzero,
				nneg => nneg,
				ccy => ccy,
				alu_out => alu_out);
		zero <= zzero; neg <= nneg; cy <= ccy;	
	END IF;
		IF clk'event and clk='1' then
			IF ldR_in='1' 	THEN R_in <= x_in; 			END IF;
			IF ldkp='1' 	THEN K_p <= Kp; 			END IF;
			IF ldki='1' 	THEN K_i <= Ki; 			END IF;
			IF ldkd='1' 	THEN K_d <= Kd; 			END IF;
			IF ldR_out='1' 	THEN z_out <= alu_out; 			END IF;
			IF ldRF='1' 	THEN RF(CONV_INTEGER(fld_C)) <= C; 	END IF;
		END IF;
		CASE selR_in IS				-- Chon du lieu nhap vao cong C
			WHEN "100" => C:= alu_out;
			WHEN "000" => C:= R_in;
			WHEN "011" => C:= K_p;
			WHEN "010" => C:= K_i;
			WHEN "001" => C:= K_d;
			WHEN OTHERS => null;
		END CASE;
	END PROCESS;
END microdata_arch;	