	ifne	powerf
icbi:
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_icbi
	bsr	ops_ignored
ops_ok_icbi:
	bsr.l	get_two
	tst.w	d1
	beq.s	icbi_ok
	addq.l	#4,sp
	rts
icbi_ok:
	
**check types is ok
	tst.w	first_type(a5)
	bne.l	bad_first	*must be gpr
	tst.w	second_type(a5)
	bne.l	bad_second	*must be gpr
*8get upper 4 bits of d2 in d3
	qmove.l	(sp)+,d1
	swap	d1
	or.w	d2,d1
	swap	d1
	lsl.w	#8,d3
	lsl.w	#3,d3
	or.w	d3,d1
	qbsr.l	put_ppc
	rts_	"icbi"
	align
	global	icbi
	
	extern	put_ppc,bad_first,bad_second,ops_ignored,get_two,get_ops_ppc
	
	else
dummy6
	nop
	global	dummy6
	endif
	align