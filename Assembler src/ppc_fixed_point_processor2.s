	ifne	powerf
cmpip:	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_cmpi
	bsr	ops_ignored
ops_ok_cmpi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate

	bsr.l	get_four
	tst.w	d1
	beq.s	cmpi_ok
	addq.l	#4,sp
	rts
cmpi_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne.l	bad_first	*must be a number
	tst.w	d2
	bmi.l	bad_cr	*between 0 and
	cmpi.w	#7,d2
	bgt.l	bad_cr	*7
	
	cmpi.w	#3,second_type(a5)
	bne.l	bad_second	*must be either 1 or 0
	tst.w	d3
	bmi.l	bad_second
	cmpi.w	#1,d3
	bgt.l	bad_second
	
	tst.w	third_type(a5)	*must be a gpr
	bne.l	bad_third

	cmpi.w	#3,fourth_type(a5)
	bne.l	bad_fourth
	qmove.l	(sp)+,d1
	cmpi.l	#$ffff,d5
	bgt	datasize_err	*too big
	cmpi.l	#-32768,d5
	blt	datasize_err
	andi.l	#$ffff,d5
**mix in fields
	lsl.l	#7,d2	*crx
	swap	d1
	or.l	d2,d1
	or.l	d4,d1
	swap	d1
	or.l	d5,d1
	tst.w	d3
	beq.s	not_64_cmpi
	qbset	#21,d1
	bsr	sixty_four_warn
not_64_cmpi:
	qbsr.l	put_ppc
	rts_	"CMPI"
**Extended CMPI's
cmpwi:
	qmove.l	d1,-(sp)	   *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_cmpwi
	bsr	ops_ignored
ops_ok_cmpwi:
	cmpi.w	#2,d1
	beq	cr_is_zero	*only two ops...
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate

	bsr.l	get_three
	tst.w	d1
	beq.s	cmpwi_ok
	addq.l	#4,sp
	rts
cmpwi_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne.l	bad_first	*must be a number
	tst.w	d2
	bmi.l	bad_cr	*between 0 and
	cmpi.w	#7,d2
	bgt.l	bad_cr	*7
	
	tst.w	second_type(a5)
	bne.l	bad_second	*must be either 1 or 0
	
	cmpi.w	#3,third_type(a5)
	bne.l	bad_third
	qmove.l	(sp)+,d1
	cmpi.l	#$ffff,d4
	bgt	datasize_err	*too big
	cmpi.l	#-32768,d4
	blt	datasize_err
	andi.l	#$ffff,d4
**mix in fields
	lsl.l	#7,d2	*crx
	swap	d1
	or.l	d2,d1
	or.l	d3,d1
	swap	d1
	or.l	d4,d1
	qbsr.l	put_ppc
	rts_	"CMPWI"

cr_is_zero:	
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#1,ppc_immediate_data_operand(a5)	*op2 is immediate

	bsr.l	get_two
	tst.w	d1
	beq.s	ciz_ok
	addq.l	#4,sp
	rts
ciz_ok:
	tst.w	first_type(a5)
	bne.l	bad_first	*must be gpr
	cmpi.w	#3,second_type(a5)
	bne.l	bad_second
	qmove.l	(sp)+,d1
	cmpi.l	#$ffff,d3
	bgt	datasize_err	*too big
	cmpi.l	#-32768,d3
	blt	datasize_err
	andi.l	#$ffff,d3
**mix in fields
;	lsl.l	#7,d2	*crx
	swap	d1
;	or.l	d2,d1
	or.l	d2,d1
	swap	d1
	or.l	d3,d1
	qbsr.l	put_ppc
	rts_	"CMPWI_no_cr"

cmpp:	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_cmp
	bsr	ops_ignored
ops_ok_cmp:
	bsr.l	get_four
	tst.w	d1
	beq.s	cmp_ok
	addq.l	#4,sp
	rts
cmp_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne.l	bad_first	*must be a number
	tst.w	d2
	bmi.l	bad_cr	*between 0 and
	cmpi.w	#7,d2
	bgt.l	bad_cr	*7
	
	cmpi.w	#3,second_type(a5)
	bne.l	bad_second	*must be either 1 or 0
	tst.w	d3
	bmi.l	bad_second
	cmpi.w	#1,d3
	bgt.l	bad_second
	
	tst.w	third_type(a5)	*must be a gpr
	bne.l	bad_third

	tst.w	fourth_type(a5)	*must be a gpr
	bne.l	bad_fourth
	qmove.l	(sp)+,d1
**mix in fields
	lsl.l	#7,d2	*crx
	swap	d1
	or.l	d2,d1
	or.l	d4,d1
	swap	d1
	lsl.w	#8,d5
	lsl.w	#3,d5
	or.l	d5,d1
	tst.w	d3
	beq.s	not_64_cmp
	qbset	#21,d1
	bsr	sixty_four_warn
not_64_cmp:
	qbsr.l	put_ppc
	rts_	"CMP"

**Extended CMP's
cmpw:
	qmove.l	d1,-(sp)	   *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_cmpw
	bsr	ops_ignored
ops_ok_cmpw:
	cmpi.w	#2,d1
	beq.s	cr_is_zerocmp	*only two ops...
	bsr.l	get_three
	tst.w	d1
	beq.s	cmpw_ok
	addq.l	#4,sp
	rts
cmpw_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne.l	bad_first	*must be a number
	tst.w	d2
	bmi.l	bad_cr	*between 0 and
	cmpi.l	#7,d2
	bgt.l	bad_cr	*7
	
	tst.w	second_type(a5)
	bne.l	bad_second	*must be gpr
	
	tst.w	third_type(a5)
	bne.l	bad_third
	qmove.l	(sp)+,d1
**mix in fields
	lsl.l	#7,d2	*crx
	swap	d1
	or.l	d2,d1
	or.l	d3,d1
	swap	d1
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.l	d4,d1
	qbsr.l	put_ppc
	rts_	"CMPW"

cr_is_zerocmp:	
	bsr.l	get_two
	tst.w	d1
	beq.s	ciz_okcmp
	addq.l	#4,sp
	rts
ciz_okcmp:
	tst.w	first_type(a5)
	bne.l	bad_first	*must be gpr
	tst.w	second_type(a5)
	bne.l	bad_second
	move.l	(sp)+,d1
	cmpi.l	#$ffff,d3
**mix in fields
;	lsl.l	#7,d2	*crx
	swap	d1
;	or.l	d2,d1
	or.l	d2,d1
	swap	d1
	lsl.w	#8,d3
	lsl.w	#3,d3
	or.l	d3,d1
	qbsr.l	put_ppc
	rts_	"CMPW_no_cr"

*************************************************
sixty_four_warn:
	btst	#3,flags7(a5)
	bne.s	no_64_warn
	save_all
	lea	sixty_four_warning3(pc),a0
	bsr.l	pass1_warning
	restore_all
no_64_warn:
	rts_	"Sixty_four_warn"
*************************************************
sixty_four_warning3:	dc.b	"***WARNING***WARNING***WARNING***",13
	dc.b	"This compare is a 64 bit instruction. "
	dc.b	"It is an illegal instruction on 32 bit processors such as the 601 and 603.",13,0
	align
	
	global	cmpip,cmpwi,sixty_four_warn,cmpp,cmpw
	extern	get_four,bad_first,bad_second,bad_third,bad_fourth,get_ops_ppc
	extern	pass1_warning,put_ppc,datasize_err,bad_cr,ops_ignored,get_three
	extern	get_two
	else
dummy1
	nop
	global	dummy1
	endif
		