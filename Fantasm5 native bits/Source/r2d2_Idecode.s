	include	r2d2_support_macros
*******************************************************************************
*Project:       R2D2                                                          *
*Author:        Rob'n'Stu                                                     *
*Filename:      Untitled 1                                                    *
*Version:       1                                                             *
*Date started:  10:47:42 on 24th August 1997                                  *
*Rev. History:  1                                                             *
*                                                                             *
*                                                                             *
*******************************************************************************
*in - none
;pipeR_instruction:	equ 0
;pipeR_reg1:		 	 equ	4
;pipeR_reg2:		 	 equ	8
;pipeR_reg3:		 	 equ	12
;pipeR_cc:	 	 	 equ	16
;pipeR_float:	 	 equ	20		 	 ; 1=floating point 0=integer
;pipeR_instr_class:	equ	24
;pipeR_spare1:	 	 equ	28
;pipeR_spare2:	 	 equ	32
;pipeR_spare3:	 	 equ	36
;pipeR_field1:	 	 equ	40
;pipeR_field2:	 	 equ pipeR_field1+field_size
;pipeR_field3:	 	 equ	pipeR_field2+field_size
;
;pipeR_size:		 	 equ	pipeR_field3+field_size+64

	macs_last
r2d2_Idecode:
	sub_in

;	find_insert_record	r20
;	lwz	r21,pipeR_instruction(r20)

**clear pipe avec -1's
	find_insert_record	r20
	mr	r21,r20
	li	r3,pipeR_size/4-1	*so we dont touch valid
	mtctr	r3
	li	r4,-1
clr_pipe:
	stw	r4,(r20)
	addi	r20,r20,4
	bdnz	clr_pipe
	mr	r20,r21
**get primary op code in r22
	lwz	r21,the_instruction(`bss)
	stw	r21,pipeR_instruction(r20)	*store instruction
	
	srwi	r22,r21,26	*top 6 bits are primary op code
**get primary decoder in ctr
	slwi	r22,r22,2	*times 4 for each branch
	lwz	r4,[t]primary_decode_table(rtoc)
	add	r4,r4,r22	*point to right branch
	mtctr	r4
	bctrl		*branch to decoder and come back here
	sub_out
	global	r2d2_Idecode
***************************************
primary_decode:
	global	primary_decode
**primary decode table
primary_decode_table:	toc_routine
;	global	primary_decode_table
	b	p_illegal	*0
	extern	p_illegal
	b	p_illegal	*1
	b	p_2	*2
	extern	p_2
	b	p_3	*3
	extern	p_3
	b	p_illegal	*4
	b	p_illegal	*5
	b	p_illegal	*6
	b	p_7	*7
	extern	p_7
	b	p_8	*8
	extern	p_8
	b	p_illegal
	b	p_10
	extern	p_10
	b	p_11
	extern	p_11
	b	p_12
	extern	p_12
	b	p_13
	extern	p_13
	b	p_14
	extern	p_14
	b	p_15
	extern	p_15
	b	p_16
	extern	p_16
	b	p_17
	extern	p_17
	b	p_18
	extern	p_18
	b	p_19
	extern	p_19
	b	p_20
	extern	p_20
	b	p_21
	extern	p_21
	b	p_illegal
	b	p_23
	extern	p_23
	b	p_24
	extern	p_24
	b	p_25
	extern	p_25
	b	p_26
	extern	p_26
	b	p_27
	extern	p_27
	b	p_28
	extern	p_28
	b	p_29
	extern	p_29
	b	p_30
	extern	p_30
	b	p_31
	extern	p_31
	b	p_32
	extern	p_32
	b	p_33
	extern	p_33
	b	p_34
	extern	p_34
	b	p_35
	extern	p_35
	b	p_36
	extern	p_36
	b	p_37
	extern	p_37
	b	p_38
	extern	p_38
	b	p_39
	extern	p_39
	b	p_40
	extern	p_40
	b	p_41
	extern	p_41
	b	p_42
	extern	p_42
	b	p_43
	extern	p_43
	b	p_44
	extern	p_44
	b	p_45
	extern	p_45
	b	p_46
	extern	p_46
	b	p_47
	extern	p_47
	b	p_48
	extern	p_48
	b	p_49
	extern	p_49
	b	p_50
	extern	p_50
	b	p_51
	extern	p_51
	b	p_52
	extern	p_52
	b	p_53
	extern	p_53
	b	p_54
	extern	p_54
	b	p_55
	extern	p_55
	b	p_illegal	*no 56,57
	b	p_illegal
	b	p_58
	extern	p_58
	b	p_59
	extern	p_59
	b	p_illegal	*no 60, 61
	b	p_illegal
	b	p_62
	extern	p_62
	b	p_63
	extern	p_63
	