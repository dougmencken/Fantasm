	ifne	powerf
fmr:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_fmr
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_fmr:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_fmr
	bsr	ops_ignored
ops_ok_fmr:
	bsr	get_two
	tst.w	d1
	beq.s	fmr_ok
	addq.l	#4,sp
	rts
fmr_ok:
**check types is ok
	cmpi.w	#1,first_type(a5)
	bne	bad_first	*must be a fpr
	cmpi.w	#1,second_type(a5)
	bne	bad_second
**d2=op1, d3=op2
	qmove.l	(sp)+,d1
	swap	d1
	lsl.w	#5,d2
	or.w	d2,d1
	swap	d1
	lsl.w	#8,d3
	lsl.w	#3,d3
	or.w	d3,d1
	qbsr	put_ppc
	rts_	"FMR"

fadd:
	btst	#0,postfix_flags(a5)
	beq.s	not_dot_fadd
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_fadd:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_fadd
	bsr	ops_ignored
ops_ok_fadd:
	bsr	get_three
	tst.w	d1
	beq.s	fadd_ok
	addq.l	#4,sp
	rts
fadd_ok:
**check types is ok
	cmpi.w	#1,first_type(a5)
	bne	bad_first	*must be a fpr
	cmpi.w	#1,second_type(a5)
	bne	bad_second
	cmpi.w	#1,third_type(a5)
	bne	bad_third
	
**d2=op1, d3=op2 etc
	qmove.l	(sp)+,d1
	lsl.l	#5,d2	*rt
	swap	d1
	or.w	d2,d1
	or.w	d3,d1
	swap	d1
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1
	qbsr	put_ppc
	rts
			
fmul:
	btst	#0,postfix_flags(a5)
	beq.s	not_dot_fmul
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_fmul:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_fmul
	bsr	ops_ignored
ops_ok_fmul:
	bsr	get_three
	tst.w	d1
	beq.s	fmul_ok
	addq.l	#4,sp
	rts
fmul_ok:
**check types is ok
	cmpi.w	#1,first_type(a5)
	bne	bad_first	*must be a fpr
	cmpi.w	#1,second_type(a5)
	bne	bad_second
	cmpi.w	#1,third_type(a5)
	bne	bad_third
	
**d2=op1, d3=op2 etc
	qmove.l	(sp)+,d1
	lsl.l	#5,d2	*rt
	swap	d1
	or.w	d2,d1
	or.w	d3,d1
	swap	d1
	lsl.l	#6,d4
	or.w	d4,d1
	qbsr	put_ppc
	rts_	"FMUL"

	
		
fmadd:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_fmadd
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_fmadd:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_fmadd
	bsr	ops_ignored
ops_ok_fmadd:
	bsr	get_four
	tst.w	d1
	beq.s	fmadd_ok
	addq.l	#4,sp
	rts
fmadd_ok:
**check types is ok
	cmpi.w	#1,first_type(a5)
	bne	bad_first	*must be a fpr
	cmpi.w	#1,second_type(a5)
	bne	bad_second
	cmpi.w	#1,third_type(a5)
	bne	bad_third
	cmpi.w	#1,fourth_type(a5)
	bne	bad_fourth	
**d2=op1, d3=op2 etc
	qmove.l	(sp)+,d1
	lsl.w	#5,d2	*rt
	swap	d1
	or.w	d2,d1
	or.w	d3,d1
	swap	d1
	lsl.w	#8,d5
	lsl.w	#3,d5
	or.w	d5,d1
	lsl.w	#6,d4
	or.w	d4,d1
	qbsr	put_ppc
	rts_	"FmADD"
cmpf:
	qmove.l	d1,-(sp)	   *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_cmpw
	bsr	ops_ignored
ops_ok_cmpw:
	bsr	get_three
	tst.w	d1
	beq.s	cmpw_ok
	addq.l	#4,sp
	rts
cmpw_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a number
	tst.w	d2
	bmi	bad_cr	*between 0 and
	cmpi.w	#7,d2
	bgt	bad_cr	*7
	
	cmpi.w	#1,second_type(a5)
	bne	bad_second	*must be fpr
	
	cmpi.w	#1,third_type(a5)
	bne	bad_third
	move.l	(sp)+,d1
**mix in fields
	lsl.l	#7,d2	*crx
	swap	d1
	or.l	d2,d1
	or.l	d3,d1
	swap	d1
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.l	d4,d1
	qbsr	put_ppc
	rts_	"CMPF"

mffs:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_mffs
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_mffs:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mffs
	bsr	ops_ignored
ops_ok_mffs:
	bsr	get_one
	tst.w	d1
	beq.s	mffs_ok
	addq.l	#4,sp
	rts
mffs_ok:
**check types is ok
	cmpi.w	#1,first_type(a5)
	bne	bad_first	*must be a fpr
**d2=op1, d3=op2 etc
	qmove.l	(sp)+,d1
	lsl.l	#5,d2	*rt
	swap	d1
	or.w	d2,d1
	swap	d1
	qbsr	put_ppc
	rts_	"mffs"

mcrfs:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_mcrfs
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_mcrfs:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_mcrfs
	bsr	ops_ignored
ops_ok_mcrfs:
	bsr	get_two
	tst.w	d1
	beq.s	mcrfs_ok
	addq.l	#4,sp
	rts
mcrfs_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a cr
	cmpi.w	#3,second_type(a5)
	bne	bad_second	*must be a cr
	tst.w	d2
	bmi	bad_cr	*between 0 and
	cmpi.w	#7,d2
	bgt	bad_cr	*7
	tst.w	d3
	bmi	bad_cr	*between 0 and
	cmpi.w	#7,d3
	bgt	bad_cr	*7
	
**d2=op1, d3=op2 etc
	qmove.l	(sp)+,d1
	lsl.w	#7,d2	*crf
	lsl.w	#2,d3	*fcrf
	swap	d1
	or.w	d2,d1
	or.w	d3,d1
	swap	d1
	qbsr	put_ppc
	rts_	"mcrfs"

mtfsfi:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_mtfsfi
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_mtfsfi:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_mtfsfi
	bsr	ops_ignored
ops_ok_mtfsfi:
	bsr	get_two
	tst.w	d1
	beq.s	mtfsfi_ok
	addq.l	#4,sp
	rts
mtfsfi_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a cr
	cmpi.w	#3,second_type(a5)
	bne	bad_second	*must be a number
	tst.w	d2
	bmi	bad_cr	*between 0 and
	cmpi.w	#7,d2
	bgt	bad_cr	*7
	tst.w	d3
	bmi	bad_field	*between 0 and
	cmpi.w	#15,d3
	bgt	bad_field	*31
	
**d2=op1, d3=op2 etc
	qmove.l	(sp)+,d1
	lsl.w	#7,d2	*bfa
	lsl.w	#4,d3	*u
	lsl.w	#8,d3
	swap	d1
	or.w	d2,d1
	swap	d1
	or.w	d3,d1
	qbsr	put_ppc
	rts_	"mtfsfi"

mtfsf:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_mtfsf
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_mtfsf:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_mtfsf
	bsr	ops_ignored
ops_ok_mtfsf:
	bsr	get_two
	tst.w	d1
	beq.s	mtfsf_ok
	addq.l	#4,sp
	rts
mtfsf_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a cr
	cmpi.w	#1,second_type(a5)
	bne	bad_second	*must be an fpr
	tst.w	d2
	bmi	bad_mask	*between 0 and
	cmpi.w	#255,d2
	bgt	bad_mask	*7
	
**d2=op1, d3=op2 etc
	qmove.l	(sp)+,d1
	lsl.w	#1,d2	*mask
	lsl.w	#3,d3	*fpr
	lsl.w	#8,d3
	swap	d1
	or.w	d2,d1
	swap	d1
	or.w	d3,d1
	qbsr	put_ppc
	rts_	"mtfsf"

mtfsb0:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_mtfsb0
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_mtfsb0:
	qmove.l	d1,-(sp)	     *save ins
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mtfsb0
	bsr	ops_ignored
ops_ok_mtfsb0:
	bsr	get_one
	tst.w	d1
	beq.s	mtfsb0_ok
	addq.l	#4,sp
	rts
mtfsb0_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a number
	tst.w	d2
	bmi	bad_bit
	cmpi.l	#31,d2
	bgt	bad_bit
**d2=op1, d3=op2 etc
	qmove.l	(sp)+,d1
	lsl.l	#5,d2	*bt
	swap	d1
	or.w	d2,d1
	swap	d1
	qbsr	put_ppc
	rts_	"mtfsb0"
**************************************************
**LOADS
**LBZ D form
lfs:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_lbz
	bsr	ops_ignored		*warning, too many ops
ops_ok_lbz:
	bsr.l	get_two		*d2=d1,d3=3
	tst.w	d1
	beq.s	lbz_ok
	addq.l	#4,sp
	rts
lbz_ok:
**op 1 must be fx

	cmpi.w	#1,first_type(a5)
	bne	op1_must_be_fp
	cmpi.w	#3,second_type(a5)	*is it xx(rx) or just (rx)
	beq.s	no_off_lbz
	qmove.l	#0,d3
no_off_lbz:		
**Check d3 for mod 4
	move.w	d3,d6
	andi.w	#%11,d6
	beq.s	mod4_ok
	bsr	mod4_warn
mod4_ok:
**mix in op1
	qmove.l	(sp)+,d1
	swap	d1
	lsl.w	#5,d2
	or.w	d2,d1
	swap	d1
**mix in offset
**check offset
	cmpi.l	#32767,d3
	bgt.l	offset_err
	cmpi.l	#-32768,d3
	blt.l	offset_err
	or.w	d3,d1
*get index register
	lea	dest_op(a5),a1
**find (Rx
find_open:
	move.b	(a1)+,d0
	beq.l	open_bracks_expected
	cmpi.b	#"(",d0
	bne.s	find_open
**A1->(Rx)
	qmoveq	#2,d0		*in case it is rtoc
	cmpi.l	#"RTOC",(a1)
	beq.s	got_toc6
	cmpi.l	#"rtoc",(a1)
	beq.s	got_toc6

	moveq	#1,d0		*in case it is sp
	cmpi.w	#"SP",(a1)
	beq.s	got_toc6
	cmpi.w	#"sp",(a1)
	beq.s	got_toc6

	cmpi.b	#"R",(a1)
	beq.s	got_reg
	cmpi.b	#"r",(a1)
	bne.l	op2_index_reg_expected
got_reg:
	qmove.l	d1,-(sp)
	addq.l	#1,a1	*skip R
	clr.l	d1
	bsr.l	get_op_code_num
	tst.l	d1
	beq.s	converted_ok
	addq.l	#4,sp
	rts
converted_ok:

	qmove.l	(sp)+,d1
**check offset
	cmpi.l	#31,d0
	bgt.l	op2_reg_err
	tst.w	d0
	bmi.l	op2_reg_err
got_toc6:
	swap	d0
	or.l	d0,d1	
	qbsr.l	put_ppc
	rts_	"lfs"


**LBZ I form
lfsx:
	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_lbzx
	bsr	ops_ignored	
ops_ok_lbzx:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	lbzx_ok
	addq.l	#4,sp
	rts
lbzx_ok:
**now simply mix in t,a,b
	cmpi.w	#1,first_type(a5)
	bne.s	op1_must_be_fp
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	tst.w	third_type(a5)
	bne	op3_must_be_reg
	lsl.l	#5,d2		*rt
	qmove.l	(sp)+,d1
	swap	d2
	or.l	d2,d1		*mix in rt
	swap	d3
	or.l	d3,d1		*mix in ra
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.l	d4,d1		*mix in rb
	qbsr.l	put_ppc
	rts_	"lfsx"

**************************************************
mod4_warn:
;	save_all
;	lea	mod4_text(pc),a0
;	bsr.l	pass1_advice
;	restore_all
	rts_	"op1_fp"

op1_must_be_fp:
	addq.l	#4,sp		*inst is on stack
	lea	op1_fp_text(pc),a0
	bsr.l	pass1_error
	rts_	"op1_fp"

bad_bit:
	addq.l	#4,sp		*inst is on stack
	lea	bad_bit_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_field"


bad_field:
	addq.l	#4,sp		*inst is on stack
	lea	bad_field_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_field"
bad_mask:
	addq.l	#4,sp		*inst is on stack
	lea	bad_mask_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_mask"

;mod4_text:	dc.b	"***ADVICE*** The offset should be at least a multiple of 4, and "
;	dc.b	"preferably a multiple of 8. However if you know that the base register (2nd "
;	dc.b	"operand) will make the displacement PowerPCª friendly...",13,0
;	even	
op1_fp_text:	dc.b	"The first operand must be an FPR - i.e. f10.",13,0

bad_bit_text:	dc.b	"The FPSCR bit number (operand #1) is illegal. It must be in the range of 0 to 31.",13,0
bad_field_text:	dc.b	"The field value being moved (second operand) into the floating point status"
	dc.b	" register field (first operand) must be a 4 bit value (i.e. in the range 0 to 15).",13,0
bad_mask_text:	dc.b	"The field mask specified by the first operand is invalid."
	dc.b	" The mask specifies which FPSCR fields are to be written to. "
	dc.b	"Where a bit is set to 1 in the mask, that field in the FPSCR is updated. "
	dc.b	"**TIP** Use a binary number for the mask. E.G. %10001000 - update fields 0 and 4.",13,0
	
	align
	global	fmr,fadd,fmul,fmadd,cmpf,mffs,mcrfs,mtfsfi,mtfsf,mtfsb0,lfs,mod4_warn
	global	lfsx
	extern	get_ops_ppc,get_two,ops_ignored,bad_first,bad_second,get_three,bad_third
	extern	put_ppc,bad_fourth,get_four,bad_cr,get_one,pass1_error,op2_reg_error
	extern	get_op_code_num,op2_index_reg_expected,open_bracks_expected,offset_err
	extern	op2_reg_err,pass1_warning,op2_must_be_reg,op3_must_be_reg,pass1_advice
	else
dummy3:
	nop
	global	dummy3
	endif
	