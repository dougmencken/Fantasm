
**********************************E X G**************************************
exg:
***first we need to find out what regs we're talking about by calling
***get datadd.
 bsr.l get_ops
 bsr.s get_datadd
 tst.w d6
 bmi illegal_err 	*bad operand
 beq.s add_add 		*2 address regs
 cmpi.w #1,d6
 beq.s addr_data
 cmpi.w #2,d6
 beq.s data_addr
**must be 2 data regs
 qmove.w #$c140,d1 	 *basic for data data
do_exg1: 		*other modes enter here
 or.w d2,d1 		*mix in dest reg from get_datadd
 lea source_op(a5)(pc),a3
 bsr.l get_mode
 lsl.w #8,d2
 lsl.w #1,d2
 or.w d2,d1 		*mix in source reg
 bra.s do_exg

add_add:
 qmove.w #$c148,d1
 bra.s do_exg1
 
data_addr:
 qmove.w #$c188,d1
 bra.s do_exg1

addr_data:
 qmove.w #$c188,d1
 lsl.w #8,d2
 lsl.w #1,d2
 or.w d2,d1
 lea source_op(a5),a3
 bsr.l get_mode
 or.w d2,d1
 bra.s do_exg
do_exg:
 qmove.w #2,size(a5)
 qmove.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"exg"
 	align
 
 
get_datadd:
 clr.w d6
 lea source_op(a5),a3
 bsr.l get_mode
 tst.w d0
 beq.s source_data
 cmpi.w #1,d0
 bne.s illegal_reg
 bra.s check_dest
source_data:
 qbset #1,d6 	 	 *1st reg is data
check_dest:
 lea dest_op(a5),a3
 bsr.l get_mode
 tst.w d0
 beq.s dest_data
 cmpi.w #1,d0
 bne.s illegal_reg
 rts
dest_data:
 qbset #0,d6
 rts
illegal_reg:
 moveq #-1,d6
 rts_	"exg_dr"
 	align
*****************************j s r******************************************
jsr:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s jsr1
 qbset #5,flags(a5)
jsr1:
 tst.w d0
 beq illegal_err
 cmpi.w #1,d0
 beq illegal_err
 cmpi.w #3,d0
 beq illegal_err
 cmpi.w #4,d0
 beq illegal_err
 cmpi.w #7,d0
 bne.s jsr_mode_ok
 cmpi.w #4,d2
 bge illegal_err
jsr_mode_ok:
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1
 move.l d3,extension(a5)
 qmove.w d4,size(a5)
 qmove.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"jsr"
 
lsl:
 qmove.w #$0200,scratch_6(a5) 	 *if memory form this is used in 9-11
 bsr type14
 rts_	"lsl"

lsr:
 qmove.w #$0200,scratch_6(a5)
 bsr type14
 rts_	"lsr"


*********************************o r***************************************
or:
 bsr.l get_size12 	  *get size in d0 0=byte,1=long,2=word
 qmove.w d0,size(a5) 	 *for use later in add #xxxx,xxx
 qmove.w d0,d1 		 *get size in d1
 lsl.w #6,d1
 or.w #$8000,d1 	*basic instruction
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s or1
 qbset #5,flags(a5)
or1:
 cmpi.w #1,d0 		*mode 1 source?
 beq or_err 		*all the other modes are the same as add.

 bsr.l make_inst1 	  *form xxxxregdszmodreg
 rts_	"or"
 
********************************o r i*************************************
ori:
 qmove.w d1,d6
 bsr immediate
 rts_	"ori"
 
********************************p e a*************************************
pea:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 cmpi.w #2,d0
 beq.s pea_ok
 cmpi.w	#5,d0
 beq.s	pea_ok
 cmpi.w #6,d0
 beq.s pea_ok
 cmpi.w #4,d2
 blt.s pea_ok
 bra illegal_err
pea_ok:
 btst #4,flags(a5)
 beq.s pea1
 qbset #5,flags(a5)
pea1:
 qmove.w #$4840,d1
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1
 qmove.w d4,size(a5)
 qmove.l d3,extension(a5)
 qmove.w #2,size2(a5)
 bsr.l insert_inst
 rts_		"pea"

asl:
 qmove.w #$0000,scratch_6(a5)
 bsr type14
 rts_	"asl"

asr:
 clr.w	scratch_6(a5)
 bsr type14
 rts_	"asr"
 	
rol:
 qmove.w #$0600,scratch_6(a5)
 bsr type14
 rts_	"rol"
 
ror:
 qmove.w #$0600,scratch_6(a5)
 bsr type14
 rts_	"ror"

*****************************************************************************
or_err:
 lea or_text(pc),a0
 bsr.l pass1_error
 rts_	"op_err"
 	
*******************************************************************************
or_text:	dc.b	"Cant use an address register as source op for OR"
	dc.b	" instruction.",13,13,0
	align
	public	exg,jsr,lsl,lsr,or,ori,pea,asl,asr,rol,ror
	
	extern	get_ops,illegal_err,source_op,get_mode,insert_inst,type14
	extern	make_inst1,immediate,pass1_error,dest_op,get_size12