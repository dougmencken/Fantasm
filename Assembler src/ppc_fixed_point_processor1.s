***PPC_fixed_point_processor#1
	ifne	powerf
**no operands form
no_operands:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	tst.w	d1
	beq.s	no_ops_ok
	bsr	ops_ignored	
no_ops_ok:
	qmove.l	(sp)+,d1
	qbsr.l	put_ppc
	rts_	"No_operand_inst"
		
**LSWI form
lswi:
	qmove.l	d1,-(sp)	*save inst
	bsr	move_mult_warn0	*issue little endian advice
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_lswi
	bsr	ops_ignored	
ops_ok_lswi:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	lswi_ok
	addq.l	#4,sp
	rts
lswi_ok:
**now simply mix in t,a,b
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	cmpi.w	#3,third_type(a5)
	bne	op3_must_be_num
	cmpi.w	#5,d2		*check for prefered form
	beq.s	rst_ok
	bsr	move_mult_warn	*advice on speed up
rst_ok:
**Check if ra is in range
	qmove.l	d4,d0	*number of bytes
	subq.l	#1,d0
	lsr.l	#2,d0	*div 4
	add.l	d2,d0	*ending register
	cmp.w	d2,d3
	blt.s	ra_ok	*less than  start of range
	cmp.w	d0,d3
	bgt.s	ra_ok	*greater than end of range
	bra	move_mult_error	*ra is in range
ra_ok:		
	tst.w	d2
	bne.s	ra_ok1		*check for rt=ra=0 (As it happens, previous error picks it up :-))
	tst.w	d3
	bne.s	ra_ok1
	bra	move_mult_error1
ra_ok1:
	cmpi.w	#32,d4
	bne.s	not_max_bytes
	qmove.l	#0,d4		*make 32
not_max_bytes:
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
	rts_	"lswi"

**LSWx form
lswx:
	qmove.l	d1,-(sp)	*save inst
	bsr	move_mult_warn0	*issue little endian advice
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_lswx
	bsr	ops_ignored	
ops_ok_lswx:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	lswx_ok
	addq.l	#4,sp
	rts
lswx_ok:
**now simply mix in t,a,b
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	tst.w	third_type(a5)
	bne	op3_must_be_reg
	cmpi.w	#5,d2		*check for prefered form
	beq.s	rsx_ok
	bsr	move_mult_warn	*advice on speed up
rsx_ok:
	bsr	move_mult_warn3	*Cant range check this		
	tst.w	d2
	bne.s	rsa_ok1		*check for rt=ra=0 (As it happens, previous error picks it up :-))
	tst.w	d3
	bne.s	rsa_ok1
	bra	move_mult_error1
rsa_ok1:
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
	rts_	"lswx"

**STSWI form
stswi:
	qmove.l	d1,-(sp)	*save inst
	bsr	move_mult_warn0	*issue little endian advice
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_stswi
	bsr	ops_ignored	
ops_ok_stswi:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	stswi_ok
	addq.l	#4,sp
	rts
stswi_ok:
**now simply mix in t,a,b
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	cmpi.w	#3,third_type(a5)
	bne	op3_must_be_num
	cmpi.w	#5,d2		*check for prefered form
	beq.s	wst_ok
	bsr	move_mult_warn	*advice on speed up
wst_ok:
	cmpi.w	#32,d4
	bne.s	not_max_bytess
	qmove.l	#0,d4		*make 32
not_max_bytess:
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
	rts_	"stswi"

**LBZ I form
lbzx:
	section
	bsr	check_dot
	tst.l	d0
	beq	.dot_ok
	rts
.dot_ok:

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
	tst.w	first_type(a5)
	bne	op1_must_be_reg
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
	rts_	"lbzx"

stwcx:

	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_stwcx
	bsr	ops_ignored	
ops_ok_stwcx:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	stwcx_ok
	addq.l	#4,sp
	rts
stwcx_ok:
**now simply mix in t,a,b
	tst.w	first_type(a5)
	bne	op1_must_be_reg
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
	qbclr	#0,postfix_flags(a5)	*so we dont get a dot warning!
	rts_	"stwcx"

**STBUX form
stbux:
	section
	bsr	check_dot
	tst.l	d0
	beq	.dot_ok
	rts
.dot_ok:


	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_stbux
	bsr	ops_ignored	
ops_ok_stbux:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	stbux_ok
	addq.l	#4,sp
	rts
stbux_ok:
**now simply mix in t,a,b
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	tst.w	third_type(a5)
	bne	op3_must_be_reg
	lsl.l	#5,d2		*rt
	qmove.l	(sp)+,d1
	tst.w	d3
	beq	stux_error
	swap	d2
	or.l	d2,d1		*mix in rt
	swap	d3
	or.l	d3,d1		*mix in ra
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.l	d4,d1		*mix in rb
	qbsr.l	put_ppc
	rts_	"stbux"

**LBZ uI form
lbzux:
	section
	bsr	check_dot
	tst.l	d0
	beq	.dot_ok
	rts
.dot_ok:

	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_lbzux
	bsr	ops_ignored	
ops_ok_lbzux:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	lbzux_ok
	addq.l	#4,sp
	rts
lbzux_ok:
**now simply mix in t,a,b
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	tst.w	third_type(a5)
	bne	op3_must_be_reg
	move.l	(sp)+,d1
	tst.w	d3		*if ra=0 or ra=rt then invalid
	beq	invalid_ui
	cmp.w	d2,d3
	beq	invalid_ui	
	lsl.l	#5,d2		*rt
	swap	d2
	or.l	d2,d1		*mix in rt
	swap	d3
	or.l	d3,d1		*mix in ra
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.l	d4,d1		*mix in rb
	qbsr.l	put_ppc
	rts_	"lbzux"
check_dot:
	clr.l	d0
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_lbz
**Cant dot addi
	lea	cant_dot_inst(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
no_dot_lbz:
	rts	
**LBZ D form
lbz:
	section
	bsr	check_dot
	tst.l	d0
	beq	.dot_ok
	rts
.dot_ok:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_lbz
	bsr	ops_ignored		*warning, too many ops
ops_ok_lbz:
	bsr.l	get_two		*d2=d1,d3=3
	tst.w	d1
	beq.s	lbz_ok
lbz_end:
	addq.l	#4,sp
	rts
lbz_ok:
**op 1 must be rx

	tst.w	first_type(a5)
	bne	op1_must_be_reg
	cmpi.w	#3,second_type(a5)	*is it xx(rx) or just (rx)
	beq.s	no_off_lbz
	qmove.l	#0,d3
no_off_lbz:		
**Check d3 for mod 4
	qmove.w	d3,d6
	andi.w	#%11,d6
	beq.s	mod4_ok
	bsr	mod4_warn
mod4_ok:

**mix in op1
	qmove.l	(sp)+,d1
	swap	d1
	lsl.l	#5,d2
	or.w	d2,d1
	swap	d1
**mix in offset
**check offset
	cmpi.l	#32767,d3
	bgt	offset_err
	cmpi.l	#-32768,d3
	blt	offset_err

	qmove.l	d1,d4		*check for 64 bit bits :-)
	swap	d4
	andi.w	#$e800,d4
	cmpi.w	#$E800,d4	*64 bitter?
	bne.s	no_64
	andi.w	#$fffc,d3	*64 bit uses bits 30 and 31
no_64:	or.w	d3,d1
*get index register
	lea	dest_op(a5),a1
**find (Rx
	clr.l	d0
find_open:
	move.b	(a1)+,d0
	beq	open_bracks_expected
	cmpi.l	#"(",d0
	bne.s	find_open
**A1->(Rx)
	qmoveq	#2,d0		*in case it is rtoc
	cmpi.l	#"RTOC",(a1)
	beq.s	got_toc1
	cmpi.l	#"rtoc",(a1)
	beq.s	got_toc1
	qmoveq	#1,d0		*in case it is sp
	cmpi.w	#"SP",(a1)
	beq.s	got_toc1
	cmpi.w	#"sp",(a1)
	beq.s	got_toc1

	cmpi.b	#"R",(a1)
	beq.s	got_R
	cmpi.b	#"r",(a1)
	bne	op2_index_reg_expected
got_R:	qmove.l	d1,-(sp)
	addq.l	#1,a1	*skip R
	qmove.l	#0,d1
	bsr.l	get_op_code_num
	tst.l	d1
	beq.s	converted_ok
	addq.l	#4,sp
	rts
converted_ok:
	qmove.l	(sp)+,d1
**check offset
	cmpi.l	#31,d0
	bgt	op2_reg_err
	tst.w	d0
	bmi	op2_reg_err
got_toc1:
	swap	d0
	or.l	d0,d1	
	qbsr.l	put_ppc
	rts_	"load_byte_and_zero"

**LBZ Dwith update form
lbzdu:
	section
	bsr	check_dot
	tst.l	d0
	beq	.dot_ok
	rts
.dot_ok:


	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_lbzdu
	bsr	ops_ignored		*warning, too many ops
ops_ok_lbzdu:
	bsr.l	get_two		*d2=d1,d3=3
	tst.w	d1
	beq.s	lbzdu_ok
	addq.l	#4,sp
	rts
lbzdu_ok:
**op 1 must be rx
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	cmpi.w	#3,second_type(a5)	*is it xx(rx) or just (rx)
	beq.s	no_off_lbzdu
	qmove.l	#0,d3
no_off_lbzdu:		
**Check d3 for mod 4
	qmove.w	d3,d6
	andi.w	#%11,d6
	beq.s	mod4u_ok
	bsr	mod4_warn
mod4u_ok:

**mix in op1
	qmove.l	(sp)+,d1
	swap	d1
	qmove.l	d2,d7	*save for later
	lsl.l	#5,d2
	or.w	d2,d1
	swap	d1
**mix in offset
**check offset
	cmpi.l	#32767,d3
	bgt	offset_err
	cmpi.l	#-32768,d3
	blt	offset_err

	qmove.l	d1,d4		*check for 64 bit bits :-)
	swap	d4
	andi.w	#$e800,d4
	cmpi.w	#$E800,d4	*64 bitter?
	bne.s	no_64du
	andi.w	#$fffc,d3	*64 bit uses bits 30 and 31
no_64du:	or.w	d3,d1
*get index register
	lea	dest_op(a5),a1
**find (Rx
find_opendu:
	move.b	(a1)+,d0
	beq	open_bracks_expected
	cmpi.b	#"(",d0
	bne.s	find_opendu
**A1->(Rx)
	qmoveq	#2,d0		*in case it is rtoc
	cmpi.l	#"RTOC",(a1)
	beq.s	got_toc2
	cmpi.l	#"rtoc",(a1)
	beq.s	got_toc2

	moveq	#1,d0		*in case it is sp
	cmpi.w	#"SP",(a1)
	beq.s	got_toc2
	cmpi.w	#"sp",(a1)
	beq.s	got_toc2

	cmpi.b	#"r",(a1)
	beq.s	got_r1
	cmpi.b	#"R",(a1)
	bne	op2_index_reg_expected
got_r1:	qmove.l	d1,-(sp)
	addq.l	#1,a1	*skip R
	qmove.l	#0,d1
	qmove.l	d7,-(sp)	*save first op
	bsr.l	get_op_code_num
	qmove.l	(sp)+,d7
	tst.l	d1
	beq.s	converted_okdu
	addq.l	#4,sp
	rts
converted_okdu:
	qmove.l	(sp)+,d1
**check offset
	cmpi.l	#31,d0
	bgt	op2_reg_err
	tst.w	d0
	bmi	op2_reg_err
**check for ra=0 or ra=rt = invalid
	tst.w	d0
	beq	invalid_ui
got_toc2:
	cmp.w	d7,d0
	beq	invalid_ui
	swap	d0
	or.l	d0,d1	
	qbsr.l	put_ppc
	rts_	"load_byte_and_zero_du"


**SB Dwith update form
sbdu:
	section
	bsr	check_dot
	tst.l	d0
	beq	.dot_ok
	rts
.dot_ok:

	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_sbdu
	bsr	ops_ignored		*warning, too many ops
ops_ok_sbdu:
	bsr.l	get_two		*d2=d1,d3=3
	tst.w	d1
	beq.s	sbdu_ok
	addq.l	#4,sp
	rts
sbdu_ok:
**op 1 must be rx

	tst.w	first_type(a5)
	bne	op1_must_be_reg
	cmpi.w	#3,second_type(a5)	*is it xx(rx) or just (rx)
	beq.s	no_off_sbdu
	qmove.l	#0,d3
no_off_sbdu:		
**mix in op1
	qmove.l	(sp)+,d1
**check for ra=0 or ra=rt = invalid
	swap	d1
;	move.l	d2,d7	*save for later
	lsl.l	#5,d2
	or.w	d2,d1
	swap	d1
**mix in offset
**check offset
	cmpi.l	#32767,d3
	bgt	offset_err
	cmpi.l	#-32768,d3
	blt	offset_err

	qmove.l	d1,d4		*check for 64 bit bits :-)
	swap	d4
	andi.w	#$e800,d4
	cmpi.w	#$E800,d4	*64 bitter?
	bne.s	no_64sbu
	andi.w	#$fffc,d3	*64 bit uses bits 30 and 31
no_64sbu:	or.w	d3,d1
*get index register
	lea	dest_op(a5),a1
**find (Rx
find_opendsu:
	move.b	(a1)+,d0
	beq	open_bracks_expected
	cmpi.b	#"(",d0
	bne.s	find_opendsu
**A1->(Rx)
	qmoveq	#2,d0		*in case it is rtoc
	cmpi.l	#"RTOC",(a1)
	beq.s	got_toc3
	cmpi.l	#"rtoc",(a1)
	beq.s	got_toc3

	qmoveq	#1,d0		*in case it is sp
	cmpi.w	#"SP",(a1)
	beq.s	got_toc3
	cmpi.w	#"sp",(a1)
	beq.s	got_toc3

	cmpi.b	#"r",(a1)
	beq.s	got_r3
	cmpi.b	#"R",(a1)
	bne	op2_index_reg_expected
got_r3:	move.l	d1,-(sp)
	addq.l	#1,a1	*skip R
	qmove.l	#0,d1
	bsr.l	get_op_code_num
	tst.l	d1
	beq.s	converted_oksu
	addq.l	#4,sp
	rts
converted_oksu:
	qmove.l	(sp)+,d1
**check offset
	cmpi.l	#31,d0
	bgt	op2_reg_err
	tst.w	d0
	bmi	op2_reg_err
**check for ra=0 or ra=rt = invalid
got_toc3:
	tst.w	d0
	beq	invalid_stbu
	swap	d0
	or.l	d0,d1	
	qbsr.l	put_ppc
	rts_	"SBDU"

*******************************LOGICAL**************************************
**logici does rs,ra,UI
logici:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_logici
	bsr	ops_ignored		*warning, too many ops
ops_ok_logici:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate

	bsr.l	get_three		*d2=op1,d3=op2,d4=op3
	tst.w	d1
	beq.s	logici_ok
	addq.l	#4,sp
	rts
logici_ok:
**check ops
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	cmpi.w	#3,third_type(a5)
	bne	op3_must_be_num
**mix in ops
	qmove.l	(sp)+,d1
**check data fits
	cmpi.l	#65536,d4
	bge	datasize_err	*max unsigned
	cmpi.l	#-32768,d4
	blt	datasize_err	*max signed	
	or.w	d4,d1		*mix in si
	swap	d1
	or.l	d2,d1		*mix in ra
	lsl.l	#5,d3
	or.l	d3,d1
	swap	d1
	qbsr.l	put_ppc
	rts_	"LOGICI"

**logici does rs,ra,UI
logici_dot:
	qbclr	#0,postfix_flags(a5)
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_logicid
	bsr	ops_ignored		*warning, too many ops
ops_ok_logicid:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate

	bsr.l	get_three		*d2=op1,d3=op2,d4=op3
	tst.w	d1
	beq.s	logici_okd
	addq.l	#4,sp
	rts
logici_okd:
**check ops
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	cmpi.w	#3,third_type(a5)
	bne	op3_must_be_num
**mix in ops
	qmove.l	(sp)+,d1
**check data fits
	cmpi.l	#65536,d4
	bge	datasize_err	*max unsigned
	cmpi.l	#-32768,d4
	blt	datasize_err	*max signed	
	or.w	d4,d1		*mix in si
	swap	d1
	or.l	d2,d1		*mix in ra
	lsl.l	#5,d3
	or.l	d3,d1
	swap	d1
	qbsr.l	put_ppc
	rts_	"LOGICId"

**andx does rs,ra,rb (.)
andx:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_andx
	bsr	ops_ignored		*warning, too many ops
ops_ok_andx:
	bsr.l	get_three		*d2=op1,d3=op2,d4=op3
	tst.w	d1
	beq.s	andx_ok
	addq.l	#4,sp
	rts
andx_ok:
**check ops
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	tst.w	third_type(a5)
	bne	op3_must_be_reg
**mix in ops
	qmove.l	(sp)+,d1
**Check for .
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_andx
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

no_dot_andx:
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.w	d4,d1		*mix in si
	swap	d1
	or.l	d2,d1		*mix in ra
	lsl.l	#5,d3
	or.l	d3,d1
	swap	d1
	qbsr.l	put_ppc
	rts_	"andx"

**mr does rx,ry
mr:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_mr
	bsr	ops_ignored		*warning, too many ops
ops_ok_mr:
	bsr.l	get_two		*d2=op1,d3=op2,d4=op3
	tst.w	d1
	beq.s	mr_ok
	addq.l	#4,sp
	rts
mr_ok:
**check ops
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
**mix in ops
	qmove.l	(sp)+,d1
**Check for .
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_mr
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

no_dot_mr:

	qmove.l	d3,d4	
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1		*mix in si
	swap	d1
	or.l	d2,d1		*mix in ra
	lsl.l	#5,d3
	or.l	d3,d1
	swap	d1
	qbsr.l	put_ppc
	rts_	"mr"

**extsb does ra,rs(.)
extsb:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_extsb
	bsr	ops_ignored		*warning, too many ops
ops_ok_extsb:
	bsr.l	get_two		*d2=op1,d3=op2,d4=op3
	tst.w	d1
	beq.s	extsb_ok
	addq.l	#4,sp
	rts
extsb_ok:
**check ops
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
**mix in ops
	qmove.l	(sp)+,d1
**Check for .
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_extsb
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

no_dot_extsb:
	swap	d1
	or.l	d2,d1		*mix in ra
	lsl.l	#5,d3
	or.l	d3,d1
	swap	d1
	qbsr.l	put_ppc
	rts_	"extsb"

******************************FIXED MATHEMATICS*****************************
**ADDI does rt,ra,IS
addip:
**Check for addic
	qmove.l	d1,d0
	swap	d0
	cmpi.w	#$3000,d0	*addic?
	bne.s	not_addic
	btst	#0,postfix_flags(a5)
	beq.s	not_addic
	qbset	#26,d1		*make addic.
	qbclr	#0,postfix_flags(a5)
	bra.s	is_addic	
not_addic:
**this is a straight addi
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_addi
**Cant dot addi
	lea	cant_dot_addi(pc),a0
	bsr.l	pass1_error
	bra	addi_end
no_dot_addi:
is_addic:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_addi
	bsr	ops_ignored		*warning, too many ops
ops_ok_addi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	bsr.l	get_three		*d2=op1,d3=op2,d4=op3
	tst.w	d1
	beq.s	addi_ok
	addq.l	#4,sp
	rts
addi_ok:
**check ops
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	cmpi.w	#3,third_type(a5)
	bne	op3_must_be_num
**mix in ops
	qmove.l	(sp)+,d1
**check data fits
	cmpi.l	#65536,d4
	bge	datasize_err	*max unsigned
	cmpi.l	#-32768,d4
	blt	datasize_err	*max signed	
	or.w	d4,d1		*mix in si
	swap	d1
	or.l	d3,d1		*mix in ra
	lsl.l	#5,d2
	or.l	d2,d1
	swap	d1
	qbsr.l	put_ppc
addi_end:	rts_	"ADDI"

**subi does rt,ra,IS
subip:
**Check for subic 
	qmove.l	d1,d0
	swap	d0
	cmpi.w	#$3000,d0	*addic?
	bne.s	not_subic
	btst	#0,postfix_flags(a5)
	beq.s	not_subic
	qbset	#26,d1		*make addic.	
	qbclr	#0,postfix_flags(a5)
	bra	is_subic
not_subic:
**this is a straight addi
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_subi
**Cant dot addi
	lea	cant_dot_subi(pc),a0
	bsr.l	pass1_error
	bra	subi_end
no_dot_subi:
is_subic:

	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_subi
	bsr	ops_ignored		*warning, too many ops
ops_ok_subi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate

	bsr.l	get_three		*d2=op1,d3=op2,d4=op3
	tst.w	d1
	beq.s	subi_ok
	addq.l	#4,sp
	rts
subi_ok:
**check ops
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	cmpi.w	#3,third_type(a5)
	bne	op3_must_be_num
**mix in ops
	qmove.l	(sp)+,d1
	neg.l	d4		*the only diff between addi and subi
**check data fits
	cmpi.l	#65536,d4
	bge	datasize_err	*max unsigned
	cmpi.l	#-32768,d4
	blt	datasize_err	*max signed	
	or.w	d4,d1		*mix in si
	swap	d1
	or.l	d3,d1		*mix in ra
	lsl.l	#5,d2
	or.l	d2,d1
	swap	d1
	qbsr.l	put_ppc
subi_end:
	rts_	"SUBI"

**LOAD IMMEDIATE
li:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc	*in source op, dest op,op3 etc
	cmpi.l	#2,d1
	ble.s	ops_ok_li
	bsr	ops_ignored		*warning, too many ops
ops_ok_li:
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_li
**Cant dot addi
	lea	cant_dot_li(pc),a0
	bsr.l	pass1_error
	bra	li_end
no_dot_li:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#1,ppc_immediate_data_operand(a5)	*op2 is immediate
	bsr.l	get_two		*d2=op1,d3=op2
	tst.w	d1
	beq.s	li_ok
li_end:
	addq.l	#4,sp
	rts
li_ok:
**check ops
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	cmpi.w	#3,second_type(a5)
	bne	op2_must_be_num
**mix in ops
	qmove.l	(sp)+,d1
**check data fits
	cmpi.l	#65536,d3
	bge	datasize_err	*max unsigned
	cmpi.l	#-32768,d3
	blt	datasize_err	*max signed	
	or.w	d3,d1		*mix in si
	swap	d1
;	or.l	d3,d1		*mix in ra - = zero in this case!
	lsl.l	#5,d2
	or.l	d2,d1
	swap	d1
	qbsr.l	put_ppc
	rts_	"LI"

**ADDXO form
addxo:
	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_addxo
	bsr	ops_ignored	
ops_ok_addxo:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	addxo_ok
	addq.l	#4,sp
	rts
addxo_ok:
**now simply mix in t,a,b
	tst.w	first_type(a5)
	bne	op1_must_be_reg
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
**check for .
	btst	#0,postfix_flags(a5)
	beq.s	no_dot
	qbset	#0,d1		*set sc
	qbclr	#0,postfix_flags(a5)	
no_dot:	qbsr.l	put_ppc
	rts_	"addxo"

**ext sub 
ext_sub:
	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_es
	bsr	ops_ignored	
ops_ok_es:
	bsr.l	get_three	*in d2,d3,d4
	tst.w	d1
	beq.s	es_ok
	addq.l	#4,sp
	rts
es_ok:
**now simply mix in t,a,b
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	tst.w	third_type(a5)
	bne	op3_must_be_reg
	lsl.l	#5,d2		*rt
	qmove.l	(sp)+,d1
	exg	d3,d4		*thats the difference!
	swap	d2
	or.l	d2,d1		*mix in rt
	swap	d3
	or.l	d3,d1		*mix in ra
	
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.l	d4,d1		*mix in rb
**check for .
	btst	#0,postfix_flags(a5)
	beq.s	no_dotes
	qbset	#0,d1		*set sc
	qbclr	#0,postfix_flags(a5)	
no_dotes:	qbsr.l	put_ppc
	rts_	"ext_sub"

**ADDme form
addme:
	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_addme
	bsr	ops_ignored	
ops_ok_addme:
	bsr.l	get_two	*in d2,d3,d4
	tst.w	d1
	beq.s	addme_ok
	addq.l	#4,sp
	rts
addme_ok:
**now simply mix in t,a
	tst.w	first_type(a5)
	bne	op1_must_be_reg
	tst.w	second_type(a5)
	bne	op2_must_be_reg
	lsl.l	#5,d2		*rt
	qmove.l	(sp)+,d1
	swap	d2
	or.l	d2,d1		*mix in rt
	swap	d3
	or.l	d3,d1		*mix in ra

**check for .
	btst	#0,postfix_flags(a5)
	beq.s	no_dotme
	qbset	#0,d1		*set sc
	qbclr	#0,postfix_flags(a5)	
no_dotme:
	qbsr.l	put_ppc
	rts_	"addme"
		
*****************************************ERRORS*************************	
move_mult_warn:
	save_all		*issue optimisation warning for lswi
	lea	mm_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	rts_	"Move_mult_advice"
move_mult_warn0:
;	save_all		*issue optimisation warning for lswi
;	lea	mm_warn(pc),a0
;	bsr.l	pass1_warning
;	restore_all
	rts_	"move_mult_warn0"

move_mult_warn3:
	save_all		*issue optimisation warning for lswi
	lea	mm_warn3(pc),a0
	bsr.l	pass1_advice
	restore_all
	rts_	"move_mult_warn3"

ops_ignored:
	lea	ops_ignored_text(pc),a0
	bsr.l	pass1_warning
	rts_	"Ops_ignored_warning"
op1_must_be_reg:
	addq.l	#4,sp		*inst is on stack
	lea	op1_reg(pc),a0
	bsr.l	pass1_error
	rts_	"op1_must_be_reg"
op2_must_be_reg:
	addq.l	#4,sp		*inst is on stack
	lea	op2_reg(pc),a0
	bsr.l	pass1_error
	rts_	"op2_must_be_reg"
op3_must_be_reg:
	addq.l	#4,sp		*inst is on stack
	lea	op3_reg(pc),a0
	bsr.l	pass1_error
	rts_	"op3_must_be_reg"
op3_must_be_num:
	addq.l	#4,sp		*inst is on stack
	lea	op3_num(pc),a0
	bsr.l	pass1_error
	rts_	"op3_must_be_num"

op2_must_be_num:
	addq.l	#4,sp		*inst is on stack
	lea	op2_num(pc),a0
	bsr.l	pass1_error
	rts_	"op2_must_be_num"

open_bracks_expected:
	lea	open_expected(pc),a0
	bsr.l	pass1_error
	rts_	"Open_bracks_expected"
op2_index_reg_expected:
	lea	op2_index(pc),a0
	bsr.l	pass1_error
	rts_	"op2_index_err"

op2_reg_err:
	lea	reg2_text(pc),a0
	bsr.l	pass1_error
	rts_	"op2_reg_err"
datasize_err:
	lea	sixteen_text(pc),a0
	bsr.l	pass2_error
	rts_	"datasize_err"

offset_err:
	lea	branch_text(pc),a0
	bsr.l	pass2_error
	rts_	"offset_err"
invalid_ui:
	lea	ui_text(pc),a0
	bsr.l	pass1_error
	rts_	"Open_bracks_expected"
invalid_stbu:
	lea	stbu_text(pc),a0
	bsr.l	pass1_error
	rts_	"Invalid_stbu"
stux_error:
	lea	stux_text(pc),a0
	bsr.l	pass1_error
	rts_	"Invalid_stbu"

move_mult_error:
	addq.l	#4,sp
	lea	mmerr_text(pc),a0
	bsr.l	pass1_error
	rts_	"Move_mult_err"
move_mult_error1:
	addq.l	#4,sp
	lea	mmerr_text1(pc),a0
	bsr.l	pass1_error
	rts_	"Move_mult_err1"
		
**data
mmerr_text:	dc.b	"Invalid instruction.",13
		dc.b	"RA (second operand) is in the range of registers to be loaded/stored.",13,0
		align
mmerr_text1:	dc.b	"Invalid instruction.",13
		dc.b	"RT (first operand) and RA (second operand) = 0",13,0
		align

mm_warn:	dc.b	"***ADVICE** On systems running in Little-Endian mode, the Load/Store "
	dc.b	"string instructions cause the system alignement handler to be invoked!",13,0
	
mm_warn3:	dc.b	"***ADVICE*** Can't range check this string move as the number of "
	dc.b	" bytes to move are held at run time in XER 25:31.",13,0
	
mm_text:	dc.b	"**ADVICE** For maximum speed out of the Load/Store string instructions,"
	dc.b	" the start register should be 5 and the last register no greater than 12.",13,0
	align
	
ui_text:	dc.b	"This instruction is invalid.",13,"For Update Indexed (and algebraic) loads, if either "
	dc.b	"the second operand is R0 (RA) or the first operand (RT) is the same as the second "
	dc.b	"operand, then the instruction is deemed invalid.",13,"Invalid examples:",13
	dc.b	"lbzux   r10,r10,r11 - invalid because RT=RA.",13
	dc.b	"lbzu    r10,20(r0)  - invalid because RA=0.",13,0
	align
stbu_text:	dc.b	"This instruction is invalid.",13
	dc.b	"Store with update instructions specify that if the base register for the"
	dc.b	" displacement is zero, then the instruction is invalid.",13,0

stux_text:	dc.b	"Invalid instruction.",13
	dc.b	"Stores with update index are invalid if RA (the second operand) is zero.",13,0
		
reg2_text:	dc.b	"Bad register number in second operand. r0->r31 allowed.",13
	dc.b	"You may use decimal, hexadecimal or binary number for registers, such as:",13
	dc.b	"R10, R$A, R0xA, R%1010 - these all indicate R10.",13,0
	
branch_text:	dc.b	"Error in second operand. The displacement is too"
	dc.b	" large to fit in 16 bits.",13
	dc.b	"-32768 to +32767 allowed.",13,0
	align	 
sixteen_text:	dc.b	"The data is too"
	dc.b	" large to fit in 16 bits.",13
	dc.b	"For signed numbers the range is -32768 to +32767.",13
	dc.b	"For unsigned numbers 0 to +65535 allowed.",13,0

	align	 

op2_index:	dc.b	"Index register expected in second operand, such as 16(r22).",13,0
open_expected:	dc.b	"Open brackets expected.",13,0
	
ops_ignored_text:	dc.b	 "**WARNING** - too many operands. The extra operand(s) have been ignored.",13,0
op1_reg:	dc.b	"First operand must be a General Purpose Register for this instruction."
	dc.b	" E.G. r20.",13
	dc.b	"You may use r0->r31, but see the Fantasm Users Guide (PowerPCª) for Macintoshª specific "
	dc.b	"register usage. ",13,0
	align
op2_reg:	dc.b	"Second operand must be a General Purpose Register for this instruction."
	dc.b	" E.G. r13.",13,0

op3_reg:	dc.b	"Third operand must be a General Purpose Register for this instruction."
	dc.b	" E.G. r15.",13,0
	align

op3_num:	dc.b	"Third operand must be a number.",13,0
	align
op2_num:	dc.b	"Second operand must be a number for this instruction.",13,0
	align
cant_dot_addi:	cstring	"Error: addi does not accept the dotted form.",13
	align
cant_dot_subi:	cstring	"Error: subi does not accept the dotted form.",13
	align
cant_dot_li:	cstring	"Error: li does not accept the dotted form.",13	
	align	
cant_dot_inst:	cstring	"Error: This load/store instruction does not accept a dot.",13
	align

	global	lbz,lbzdu,lbzx,lbzux,sbdu,stbux,lswi,stswi,lswx,no_operands,addip,li
	global	subip,addxo,addme,datasize_err,ops_ignored
	global	logici,andx,mr,extsb,open_bracks_expected,op2_index_reg_expected
	global	offset_err,op2_reg_err,op2_must_be_reg,op3_must_be_reg,stwcx,ext_sub
	global	logici_dot
	extern	put_ppc,pass1_warning,get_ops_ppc,get_two,get_op_code_num,pass1_error
	extern	get_three,mod4_warn,pass1_advice,pass2_error
	else
dummy2
	nop
	global	dummy2
	endif