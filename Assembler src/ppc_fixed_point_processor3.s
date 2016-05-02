**********************************************
**PPC_fixed_point_processor#3 - traps
**
	if	powerf
tdi:	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_tdi
	bsr	ops_ignored
ops_ok_tdi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate

	bsr	get_three
	tst.w	d1
	beq.s	tdi_ok
	addq.l	#4,sp
	rts
tdi_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a number
	tst.w	d2
	bmi	bad_to	*between 0 and
	cmpi.l	#31,d2
	bgt	bad_to	*31
	
	tst.w	second_type(a5)
	bne	bad_second	*must be gpr
	
	cmpi.w	#3,third_type(a5)	*must be a number
	bne	bad_third

**mix in fields
	cmpi.l	#$ffff,d4
	bgt	datasize_err	*too big
	cmpi.l	#-32768,d4
	blt	datasize_err
	andi.l	#$ffff,d4

	move.l	(sp)+,d1
	lsl.l	#5,d2	*to field
	swap	d1
	or.w	d2,d1
	or.w	d3,d1
	swap	d1
	or.w	d4,d1
	qbsr	put_ppc
	rts_	"TDI"
**EXTENDED
twei:	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_twei
	bsr	ops_ignored
ops_ok_twei:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#1,ppc_immediate_data_operand(a5)	*op2 is immediate

	bsr	get_two
	tst.w	d1
	beq.s	twei_ok
	addq.l	#4,sp
	rts
twei_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a reg
			
	cmpi.w	#3,second_type(a5)	*must be a number
	bne	bad_second

**mix in fields
	cmpi.l	#$ffff,d3
	bgt	datasize_err	*too big
	cmpi.l	#-32768,d3
	blt	datasize_err
	andi.l	#$ffff,d3

	move.l	(sp)+,d1
	swap	d1
	or.w	d2,d1
	swap	d1
	or.w	d3,d1
	qbsr	put_ppc
	rts_	"TWEI_and_Bring_back_Red_Dwarf!"

twe:	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_twe
	bsr	ops_ignored
ops_ok_twe:
	bsr	get_two
	tst.w	d1
	beq.s	twe_ok
	addq.l	#4,sp
	rts
twe_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a reg
			
	tst.w	second_type(a5)	*must be a reg
	bne	bad_second

**mix in fields
	move.l	(sp)+,d1
	swap	d1
	or.w	d2,d1
	swap	d1
	lsl.l	#8,d3
	lsl.l	#3,d3
	or.w	d3,d1
	qbsr	put_ppc
	rts_	"TWE__Craig_was_innocent!!"
	
td:	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_td
	bsr	ops_ignored
ops_ok_td:
	bsr	get_three
	tst.w	d1
	beq.s	td_ok
	addq.l	#4,sp
	rts
td_ok:
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a number
	tst.w	d2
	bmi	bad_to	*between 0 and
	cmpi.w	#31,d2
	bgt	bad_to	*31
	
	tst.w	second_type(a5)
	bne	bad_second	*must be gpr
	
	tst.w	third_type(a5)	   *must be a number
	bne	bad_third

**mix in fields
	move.l	(sp)+,d1
	lsl.w	#5,d2	*to field
	swap	d1
	or.w	d2,d1
	or.w	d3,d1
	swap	d1
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.w	d4,d1
	qbsr	put_ppc
	rts_	"TD"

******************64BIT SHIFT/ROTS*************************
rldicl:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_rld
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_rld:
	qmove.l	d1,-(sp)	     *save inst
	bsr	sh_warning
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_rld
	bsr	ops_ignored
ops_ok_rld:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate

	bsr	get_four
	tst.w	d1
	beq.s	rld_ok
	addq.l	#4,sp
	rts
rld_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_sh
	cmpi.w	#3,fourth_type(a5)
	bne	bad_mask
**check sh and mask are in the range 0-63 (d4 and d5)
	tst.w	d4
	bmi	bad_sh
	cmpi.w	#63,d4
	bgt	bad_sh
	tst.w	d5
	bmi	bad_mask
	cmpi.w	#63,d5
	bgt	bad_mask
	andi.w	#$3f,d4
	andi.w	#$3f,d5
**NOW mix in to d1
	qmove.l	(sp)+,d1
	btst	#0,d4
	beq.s	no_sh_l
	qbset	#1,d1	*set lsb of shift
no_sh_l:
	lsr.w	#1,d4	*now make 5 bits
	swap	d1
	or.w	d2,d1	*ra
	lsl.w	#5,d3
	or.w	d3,d1
	swap	d1
	lsl.w	#5,d5
	or.w	d5,d1
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.w	d4,d1
	qbsr	put_ppc
	rts_	"RLDICL_phew!"
***SRADI
sradi:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_sradi
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_sradi:
	qmove.l	d1,-(sp)	     *save inst
	bsr	sh_warning
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_srad
	bsr	ops_ignored
ops_ok_srad:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	bsr	get_three
	tst.w	d1
	beq.s	srad_ok
	addq.l	#4,sp
	rts
srad_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_sh
**check sh and mask are in the range 0-63 (d4 and d5)
	tst.w	d4
	bmi	bad_sh
	cmpi.w	#63,d4
	bgt	bad_sh
	andi.w	#$3f,d4
**NOW mix in to d1
	qmove.l	(sp)+,d1
	btst	#0,d4
	beq.s	no_sh_srad
	qbset	#1,d1	*set lsb of shift
no_sh_srad:
	lsr.w	#1,d4	*now make 5 bits
	swap	d1
	or.w	d2,d1	*ra
	lsl.w	#5,d3
	or.w	d3,d1
	swap	d1
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.w	d4,d1
	qbsr	put_ppc
	rts_	"SRADI_phew!"

***SRAWI
srawi:	btst	#0,postfix_flags(a5)
	beq.s	not_dot_srawi
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_srawi:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_sraw
	bsr	ops_ignored
ops_ok_sraw:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	bsr	get_three
	tst.w	d1
	beq.s	sraw_ok
	addq.l	#4,sp
	rts
sraw_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_sh
**check sh and mask are in the range 0-63 (d4 and d5)
	tst.w	d4
	bmi	bad_shw
	cmpi.l	#31,d4
	bgt	bad_shw
	andi.l	#$1f,d4
**NOW mix in to d1
	qmove.l	(sp)+,d1
	swap	d1
	or.w	d2,d1	*ra
	lsl.l	#5,d3
	or.w	d3,d1
	swap	d1
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1
	qbsr	put_ppc
	rts_	"SRAWI"

**Word rotates
rlwinm:	
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_rlw
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_rlw:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#5,d1
	ble.s	ops_ok_rlw
	bsr	ops_ignored
ops_ok_rlw:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate
	qbset	#4,ppc_immediate_data_operand(a5)	*op5 is immediate

	bsr	get_five
	tst.w	d1
	beq.s	rlw_ok
	addq.l	#4,sp
	rts
rlw_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second	*gpr
	cmpi.w	#3,third_type(a5)
	bne	bad_sh		*immediate
	cmpi.w	#3,fourth_type(a5)
	bne	bad_mask_start	*immediate
	cmpi.w	#3,fifth_type(a5)
	bne	bad_mask_end	*immediate
**Check shift,ms,me
	tst.w	d4
	bmi	bad_shw
	cmpi.w	#31,d4
	bgt	bad_shw
	tst.w	d5
	bmi	bad_mask_start
	cmpi.w	#31,d5
	bgt	bad_mask_start
	tst.w	d6
	bmi	bad_mask_end
	cmpi.w	#31,d5
	bgt	bad_mask_end

**Now mix in operands
	qmove.l	(sp)+,d1
	swap	d1
	or.w	d2,d1	*ra
	lsl.w	#5,d3
	or.w	d3,d1	*rs
	swap	d1
	lsl.w	#8,d4
	lsl.w	#3,d4
	or.w	d4,d1	*SH
	lsl.w	#6,d5
	or.w	d5,d1	*MB
	lsl.w	#1,d6
	or.w	d6,d1	*ME
	qbsr	put_ppc
	rts_	"RLWINMx"

rlwnm:		**Exactly the same as the above, except op3 is a reg	
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_rlwn
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_rlwn:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#5,d1
	ble.s	ops_ok_rlwn
	bsr	ops_ignored
ops_ok_rlwn:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate
	qbset	#4,ppc_immediate_data_operand(a5)	*op5 is immediate

	bsr	get_five
	tst.w	d1
	beq.s	rlwn_ok
	addq.l	#4,sp
	rts
rlwn_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	tst.w	third_type(a5)
	bne	bad_third
	cmpi.w	#3,fourth_type(a5)
	bne	bad_mask_start
	cmpi.w	#3,fifth_type(a5)
	bne	bad_mask_end
**Check shift,ms,me
	tst.w	d4
	bmi	bad_sh
	cmpi.w	#63,d4
	bgt	bad_sh
	tst.w	d5
	bmi	bad_mask_start
	cmpi.w	#31,d5
	bgt	bad_mask_start
	tst.w	d6
	bmi	bad_mask_end
	cmpi.w	#31,d5
	bgt	bad_mask_end

**Now mix in operands
**Extendeds enter here.
do_rlwinm:
	qmove.l	(sp)+,d1
	swap	d1
	or.w	d2,d1	*ra
	lsl.l	#5,d3
	or.w	d3,d1	*rs
	swap	d1
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1	*SH
	lsl.l	#6,d5
	or.w	d5,d1	*MB
	lsl.l	#1,d6
	or.w	d6,d1	*ME
	qbsr	put_ppc
	rts_	"RLWNMx"

***Extended rots
* BF extracts

extlwi:		**ra,rs,n,b	b is bit posiion, n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_elwi
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_elwi:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_elwi
	bsr	ops_ignored
ops_ok_elwi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate

	bsr	get_four
	tst.w	d1
	beq.s	elwi_ok
	addq.l	#4,sp
	rts
elwi_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
	cmpi.w	#3,fourth_type(a5)
	bne	bad_fourth
**Check shift,ms,me
	tst.w	d4
	ble	bad_field_width1
	cmpi.w	#31,d4
	bgt	bad_field_width1
	tst.w	d5
	bmi	bad_field_start
	cmpi.w	#31,d5
	bgt	bad_field_start
**now translate to:ra=ra, rs=rs, sh=b, mb=0,me=n-1
**                 d2=d2, d3=d3, d4=d5,d5=0,d6=d4
**Check if field is greater than bits to left
	qmove.w	d5,d0
	addq.w	#1,d0	*31-b=field width
;	cmp.w	d0,d4	*d4=number of bits
;	blt.s	field_oke2		*change for 5.21 - was ble
;	bsr	trunc_warning
;field_oke2:
	qmove.w	d4,d6
	subq.w	#1,d6
	andi.w	#$1f,d6	*mod 32
	qmove.l	d5,d4
	qmoveq	#0,d5
	bra	do_rlwinm	
	rts_	"EXTLWI"
**	
extrwi:		**ra,rs,n,b	b is bit posiion, n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_erwi
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_erwi:
	move.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_erwi
	bsr	ops_ignored
ops_ok_erwi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate

	bsr	get_four
	tst.w	d1
	beq.s	erwi_ok
	addq.l	#4,sp
	rts
erwi_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
	cmpi.w	#3,fourth_type(a5)
	bne	bad_fourth
**Check shift,ms,me
	tst.w	d4
	ble	bad_field_width1
	cmpi.w	#31,d4
	bgt	bad_field_width1
	tst.w	d5
	bmi	bad_field_start
	cmpi.w	#31,d5
	bgt	bad_field_start
**now translate to:ra=ra, rs=rs, sh=b+n, mb=32-n,me=31
**                 d2=d2, d3=d3,d4=d4+d5,d5=32-d5,d6=31
**Check if field is greater than bits to left

;	move.w	d5,d0
;	addq.w	#1,d0	*b=field width

;	cmp.w	d0,d4	*width is <=number of bits
;	blt.s	field_oke1	*change for 5.21 
;	bsr	trunc_warning
;field_oke1:
	qmoveq	#32,d0
	sub.w	d4,d0	*32-n
	add.w	d5,d4	*b+n
	qmove.l	d0,d5	*32-n
	qmoveq	#31,d6	*31
	bra	do_rlwinm	
	rts_	"EXTRWI"
****
clrlslwi:		**ra,rs,b,n	b is bit posiion, n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_clwi
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_clwi:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_clwi
	bsr	ops_ignored
ops_ok_clwi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate

	bsr	get_four
	tst.w	d1
	beq.s	clwi_ok
	addq.l	#4,sp
	rts
clwi_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
	cmpi.w	#3,fourth_type(a5)
	bne	bad_fourth
**Check shift,ms,me
	tst.w	d4
	bmi	bad_field_width
	cmpi.w	#31,d4
	bgt	bad_field_width
	tst.w	d5
	bmi	bad_field_start
	cmpi.w	#31,d5
	bgt	bad_field_start
	cmp.w	d4,d5
	bgt	op4_lt_op3
**now translate to:ra=ra, rs=rs, sh=b+n, mb=32-n,me=31
**                 d2=d2, d3=d3,d4=d4+d5,d5=32-d5,d6=31
**Check if field is greater than bits to lef
	qmove.w	#31,d6	*31
	sub.w	d5,d6	*31-n
	qmove.w	d4,d0
	sub.w	d5,d0	*b-n
	qmove.w	d5,d4	*n
	qmove.w	d0,d5	*b-n
	bra	do_rlwinm	
	rts_	"CLRLSLWI"

****
inslwi:		**ra,rs,n,b	b is bit posiion, n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_inslwi
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_inslwi:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_inslwi
	bsr	ops_ignored
ops_ok_inslwi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate

	bsr	get_four
	tst.w	d1
	beq.s	inslwi_ok
	addq.l	#4,sp
	rts
inslwi_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
	cmpi.w	#3,fourth_type(a5)
	bne	bad_fourth
**Check shift,ms,me
	tst.w	d4
	ble	bad_field_width1
	cmpi.w	#31,d4
	bgt	bad_field_width1
	tst.w	d5
	bmi	bad_field_start
	cmpi.w	#31,d5
	bgt	bad_field_start
**Check that field is not going to be truncated
**IF 31-b<N+1 then warning
;	move.w	#31,d0
;	sub.w	d5,d0	31-b
	qmove.w	d5,d0
	addq.w	#1,d0	account for bit zero
;	move.w	d4,d1
;	addq.w	#1,d1
	cmp.w	d4,d0
	bge.s	field_ok
	bsr	trunc_warning
**now translate to:ra=ra, rs=rs, sh=32-b, mb=b,me=(b+n)-1
field_ok:
	qmove.w	d4,d6	*n
	add.w	d5,d6	*+b
	andi.w	#$1f,d6
	subq.w	#1,d6	*-1
*d5 is b!
	qmove.w	#32,d4
	sub.w	d5,d4	*32-b
	andi.w	#$1f,d4
	bra	do_rlwinm
	rts_	"INSLWI"

****
insrwi:		**ra,rs,n,b	b is bit posiion, n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_insrwi
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_insrwi:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#4,d1
	ble.s	ops_ok_insrwi
	bsr	ops_ignored
ops_ok_insrwi:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	qbset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate

	bsr	get_four
	tst.w	d1
	beq.s	insrwi_ok
	addq.l	#4,sp
	rts
insrwi_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
	cmpi.w	#3,fourth_type(a5)
	bne	bad_fourth
**Check shift,ms,me
	tst.w	d4
	ble	bad_field_width1
	cmpi.w	#31,d4
	bgt	bad_field_width1
	tst.w	d5
	bmi	bad_field_start
	cmpi.w	#31,d5
	bgt	bad_field_start
**Check that field is not going to be truncated
**IF b+1<31-n then warning
	qmove.w	d5,d0
	addq.w	#1,d0	*b+1
;	move.w	#31,d1
;	sub.w	d4,d1	31-n	*right justified field
	
	cmp.w	d4,d0
	bge.s	field_okr
	bsr	trunc_warning
**now translate to:ra=ra, rs=rs, sh=32-b, mb=b,me=(b+n)-1
field_okr:
	qmove.w	d4,d6	*n
	add.w	d5,d6	*+b
	andi.w	#$1f,d6
	subq.w	#1,d6	*-1
*d5 is b!
;	move.w	#32,d4
	qmove.w	d5,d0	*b
	add.w	d4,d0	*b+n
	qmove.w	#32,d4
	sub.w	d0,d4	*32-(b+n)
	andi.w	#$1f,d4
	bra	do_rlwinm
	rts_	"INSRWI"

****
rotlwi:		**ra,rs,n	n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_rotli
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_rotli:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_rotli
	bsr	ops_ignored
ops_ok_rotli:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	bsr	get_three
	tst.w	d1
	beq.s	rotli_ok
	addq.l	#4,sp
	rts
rotli_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
**Check shift,ms,me
	tst.w	d4
	bne.s	shiftl_ok
	bsr	rotate_zero_warning
shiftl_ok:
	tst.w	d4
	blt	bad_rotl_warning
	cmpi.l	#31,d4
	bgt	bad_rotl_warning
done_rotl:			*warnings return here
	andi.l	#$1f,d4
	clr.l	d5
	qmoveq	#31,d6
	bra	do_rlwinm
	rts_	"ROTLWI"

****
rotrwi:		**ra,rs,n	n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_rotri
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_rotri:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_rotri
	bsr	ops_ignored
ops_ok_rotri:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate

	bsr.l	get_three
	tst.w	d1
	beq.s	rotri_ok
	addq.l	#4,sp
	rts
rotri_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
**Check shift,ms,me
	tst.w	d4
	bne.s	shiftr_ok
	bsr	rotate_zero_warning
shiftr_ok:
	tst.w	d4
	blt	bad_rotr_warning
	cmpi.l	#31,d4
	bgt	bad_rotr_warning
done_rotr:
	andi.l	#$1f,d4
	qmoveq	#32,d0
	sub.l	d4,d0
	qmove.w	d0,d4
	andi.w	#$1f,d4
	clr.l	d5
	qmoveq	#31,d6
	bra	do_rlwinm
	rts_	"ROTRWI"
****
rotlw:		**ra,rs,rb	n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_rotl
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_rotl:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_rotl
	bsr	ops_ignored
ops_ok_rotl:
	bsr.l	get_three
	tst.w	d1
	beq.s	rotl_ok
	addq.l	#4,sp
	rts
rotl_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	tst.w	third_type(a5)
	bne	bad_third
	clr.l	d5
	qmoveq	#31,d6
	bra	do_rlwinm
	rts_	"ROTLW"
	
****
slwi:		**ra,rs,n	n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_sli
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_sli:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_sli
	bsr	ops_ignored
ops_ok_sli:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	bsr.l	get_three
	tst.w	d1
	beq.s	sli_ok
	addq.l	#4,sp
	rts
sli_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
**Check shift,ms,me
	tst.w	d4
	bne.s	sl_ok
	bsr	shift_zero_warning
sl_ok:
	tst.w	d4
	blt	bad_shl_warning
	cmpi.l	#31,d4
	bgt	bad_shl_warning
done_shlw:
	andi.l	#$1f,d4
	clr.l	d5
	qmoveq	#31,d6
	sub.l	d4,d6
	andi.l	#$1f,d6
	bra	do_rlwinm
	rts_	"SLWI"
****
****
srwi:		**ra,rs,n	n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_sri
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_sri:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_sri
	bsr	ops_ignored
ops_ok_sri:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate

	bsr.l	get_three
	tst.w	d1
	beq.s	sri_ok
	addq.l	#4,sp
	rts
sri_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
**Check shift,ms,me
	tst.w	d4
	bne.s	sr_ok
	bsr	shift_zero_warning
sr_ok:
	tst.w	d4
	blt	bad_shr_warning
	cmpi.l	#31,d4
	bgt	bad_shr_warning
done_shrw:
	andi.l	#$1f,d4
	qmove.w	d4,d5
	qmoveq	#32,d0
	sub.l	d4,d0
	qmove.w	d0,d4
	qmoveq	#31,d6
	bra	do_rlwinm
	rts_	"SRWI"	
****
clrlwi:		**ra,rs,n	n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_clrli
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_clrli:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_clrli
	bsr	ops_ignored
ops_ok_clrli:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	bsr.l	get_three
	tst.w	d1
	beq.s	clrli_ok
	addq.l	#4,sp
	rts
clrli_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
**Check shift,ms,me
	tst.w	d4
	blt	bad_clrl_warning
	cmpi.l	#31,d4
	bgt	bad_clrl_warning
clrl_ok:
	andi.l	#$1f,d4
	qmove.w	d4,d5
	clr.l	d4
	qmoveq	#31,d6
	bra	do_rlwinm
	rts_	"CLRLWI"	

****
clrrwi:		**ra,rs,n	n is number of bits to extract
	btst	 #0,postfix_flags(a5)
	beq.s	not_dot_clrri
	qbset	#0,d1
	qbclr	#0,postfix_flags(a5)	

not_dot_clrri:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	ble.s	ops_ok_clrri
	bsr	ops_ignored
ops_ok_clrri:
	clr.b	ppc_immediate_data_operand(a5)
	qbset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate

	bsr.l	get_three
	tst.w	d1
	beq.s	clrri_ok
	addq.l	#4,sp
	rts
clrri_ok:
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	tst.w	second_type(a5)
	bne	bad_second
	cmpi.w	#3,third_type(a5)
	bne	bad_third
**Check shift,ms,me
	tst.l	d4
	blt	bad_clrr_warning
	cmpi.l	#31,d4
	bgt	bad_clrr_warning
clrr_ok:
	andi.l	#$1f,d4
	qmoveq	#31,d6
	sub.l	d4,d6
	andi.l	#$1f,d6
	clr.l	d4	
	qmove.l	d4,d5
	bra	do_rlwinm
	rts_	"CLRRWI"	

****
**It is possible to code op1 (the spr) as a number or as its name, hence we
**may get a bad first type. We don't want to put the labels in the equs as this will
**Slow the whole caboosh down, so we have a specific search for them. If a supervisor
**mode reg is found, we issue a warning if allowed.
**This all means we have to hand manage the ops.
mtspr:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_mtspr
	bsr	ops_ignored
ops_ok_mtspr:
	lea	source_op(a5),a3	*number of name?
	qmove.b	(a3),d0			*check first char
	cmpi.b	#"0",d0
	blt.s	poss_name
	cmpi.b	#"9",d0
	bgt.s	poss_name
** op1 (SPR) is a number
	bsr	get_one			*in d2
	bra.s	got_spr
poss_name:
**Here we have an spr name, so we use the old gpsearch to find it...
	lea	sprs(pc),a2
	bsr.l	inst_search	*in search_labs.s
	bmi	not_spr		*unidentified
	lea	spr_table(pc),a1 
**LXT change
	qpush1	a1
	lsl.l	#1,d0
	add.l	d0,a1
	qcmove.w	(a1),d2
	qpop1	a1
;	move.w	0(a1,d0.l*2),d2	*get spr code (.w)

got_spr:
	cmpi.l	#256,d2
	beq.s	not_priv	*vrsave

	cmpi.l	#9,d2		*check for priv
	ble.s	not_priv
	bsr	priv_warn
not_priv:
	cmpi.w	#280,d2
	bne.s	not_64r
	bsr	spr_64_warn
not_64r:
	cmpi.w	#287,d2
	bne.s	not_write_pvr
	bra	pvr_err	*cant write to pvr
not_write_pvr:
**Now get reg number
	lea	dest_op(a5),a1
	qmoveq	#2,d0		*in case it is rtoc
	cmpi.l	#"RTOC",(a1)
	beq.s	got_toc4
	cmpi.l	#"rtoc",(a1)
	beq.s	got_toc4
	qmoveq	#1,d0		*in case it is sp
	cmpi.w	#"SP",(a1)
	beq.s	got_toc4
	cmpi.w	#"sp",(a1)
	beq.s	got_toc4

	cmpi.b	#"R",(a1)
	beq.s	got_second		*must be Rx
	cmpi.b	#"r",(a1)
	bne	bad_second
got_second:
	qmove.l	d2,-(sp)		*save spr
	addq.l	#1,a1
	bsr.l	get_op_code_num		*in d0 with d1=0 or d1=-1 if error
	qmove.l	(sp)+,d2		*restore spr	
	tst.w	d1
	bmi	bad_second
	tst.w	d0
	bmi	bad_second	
	cmpi.w	#31,d0
	bgt	bad_second
**Now we have the spr in d2, and the gpr in d0
**We have to swap the two 5 bit halfs of d2
**Could use a bitfield, but...
**All extended move to's come here.
**needs spr in d2, and reg. in d0
got_toc4:
move_to_ent:
	qmove.w	d2,d3
	andi.w	#%11111,d2
	lsr.w	#5,d3
	andi.w	#%11111,d3	*d3=lsb
	qmove.l	(sp)+,d1
	swap	d1
	lsl.w	#5,d0
	or.w	d0,d1		*gprx
	or.w	d2,d1
	swap	d1
	lsl.w	#8,d3
	lsl.w	#3,d3
	or.w	d3,d1
	qbsr	put_ppc
	
	rts_	"MTSPR"
	
mfspr:
	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_mfspr
	bsr	ops_ignored
ops_ok_mfspr:
	lea	dest_op(a5),a3		*number of name?
	qmove.b	(a3),d0			*check first char
	cmpi.b	#"0",d0
	blt.s	poss_namef
	cmpi.b	#"9",d0
	bgt.s	poss_namef
** op1 (SPR) is a number
	bsr	get_two			*in d2
	qmove.w	d3,d2
	bra.s	got_sprf
poss_namef:
**Here we have an spr name, so we use the old gpsearch to find it...
	lea	sprs(pc),a2
	bsr.l	inst_search	*in search_labs.s
	bmi	not_spr		*unidentified
	lea	spr_table(pc),a1 
**LXT change
	qpush1	a1
	lsl.l	#1,d0
	add.l	d0,a1
	qcmove.w	(a1),d2
	qpop1	a1
;	move.w	0(a1,d0.l*2),d2	*get spr code (.w)

got_sprf:
	cmpi.w	#284,d2
	beq.s	not_privf
	cmpi.w	#285,d2
	beq.s	not_privf	*check for tbr
	cmpi.w	#256,d2
	beq.s	not_privf
	cmpi.l	#937,d2
	beq.s	not_privf	*UPMC1
	cmpi.l	#938,d2
	beq.s	not_privf	*UPMC1
	cmpi.l	#941,d2
	beq.s	not_privf	*UPMC1
	cmpi.l	#942,d2
	beq.s	not_privf	*UPMC1
	cmpi.l	#939,d2
	beq.s	not_privf	*USIA
	cmpi.l	#936,d2
	beq.s	not_privf	*UMMCR0
	cmpi.l	#940,d2
	beq.s	not_privf	*UMMCR1
	cmpi.w	#9,d2		*check for priv
	ble.s	not_privf
	bsr	priv_warnf
not_privf:
	cmpi.w	#280,d2
	bne.s	not_64rf
	bsr	spr_64_warn
not_64rf:
**Now get reg number
	lea	source_op(a5),a1
	qmoveq	#2,d0		*in case it is rtoc
	cmpi.l	#"RTOC",(a1)
	beq.s	got_toc5
	cmpi.l	#"rtoc",(a1)
	beq.s	got_toc5

	qmoveq	#1,d0		*in case it is sp
	cmpi.w	#"SP",(a1)
	beq.s	got_toc5
	cmpi.w	#"sp",(a1)
	beq.s	got_toc5

	cmpi.b	#"R",(a1)
	beq.s	got_first
	cmpi.b	#"r",(a1)
	bne	bad_first		*must be Rx
got_first:
	qmove.l	d2,-(sp)		*save spr
	addq.l	#1,a1
	bsr.l	get_op_code_num		*in d0 with d1=0 or d1=-1 if error
	move.l	(sp)+,d2		*restore spr	
	tst.w	d1
	bmi	bad_first
	tst.w	d0
	bmi	bad_first
	cmpi.w	#31,d0
	bgt	bad_first
**Now we have the spr in d2, and the gpr in d0
**We have to swap the two 5 bit halfs of d2
**Could use a bitfield, but...
got_toc5:
move_from_ent:
	qmove.w	d2,d3
	andi.w	#%11111,d2
	lsr.w	#5,d3
	andi.w	#%11111,d3	*d3=lsb
	qmove.l	(sp)+,d1
	swap	d1
	lsl.w	#5,d0
	or.w	d0,d1		*gprx
	or.w	d2,d1
	swap	d1
	lsl.w	#8,d3
	lsl.w	#3,d3
	or.w	d3,d1
	qbsr	put_ppc
	
	rts_	"MFSPR"

**Extended move to's from's
**handles both
mtxer:	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mtxer
	bsr	ops_ignored
ops_ok_mtxer:
	bsr	get_one		*in d2
	qmove.l	d2,d0
	moveq	#1,d2
	bra	move_to_ent
	rts_	"MTXER"

mtvrsave:	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mtvrsave
	bsr	ops_ignored
ops_ok_mtvrsave:
	bsr	get_one		*in d2
	qmove.l	d2,d0
	qmove.l	#256,d2
	bra	move_to_ent
	rts_	"MTvrsave"
	global	mtvrsave
**Extended move to's from's
**handles both
mtlr:	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mtlr
	bsr	ops_ignored
ops_ok_mtlr:
	bsr	get_one		*in d2
	qmove.l	d2,d0
	qmoveq	#8,d2
	bra	move_to_ent
	rts_	"MTlr"
mtctr:	move.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mtctr
	bsr	ops_ignored
ops_ok_mtctr:
	bsr	get_one		*in d2
	qmove.w	d2,d0
	qmoveq	#9,d2
	bra	move_to_ent
	rts_	"MTctr"

**Mftb and mftbu
mftb:	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mftb
	bsr	ops_ignored
ops_ok_mftb:
	bsr	get_one		*in d2
	tst.w	first_type(a5)
	bne	bad_first
	qmove.l	(sp)+,d1
	lsl.l	#5,d2
	swap	d1
	or.w	d2,d1
	swap	d1	
	qbsr	put_ppc
	rts_	"Mftb"

**MfMSR and mtmsr
mtmsr:	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mtmsr
	bsr	ops_ignored
ops_ok_mtmsr:
	bsr	get_one		*in d2
	tst.w	first_type(a5)
	bne	bad_first
	bsr	priv_warnmsr
	qmove.l	(sp)+,d1
	lsl.l	#5,d2
	swap	d1
	or.w	d2,d1
	swap	d1	
	qbsr	put_ppc
	rts_	"Mtmsr"

**MTCRF
mtcrf:	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	ble.s	ops_ok_mtcrf
	bsr	ops_ignored
ops_ok_mtcrf:
	bsr	get_two
	tst.w	d1
	beq.s	mtcrf_ok
	addq.l	#4,sp
	rts
mtcrf_ok:
	
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a number
	tst.w	second_type(a5)
	bne	bad_second
**Check number is <=255>0
	tst.w	d2
	bmi	bad_fxm
	cmpi.w	#255,d2
	bgt	bad_fxm
*8get upper 4 bits of d2 in d3
	qmove.w	d2,d4
	lsr.w	#4,d4
	andi.w	#%1111,d2
	andi.w	#%1111,d4
	qmove.l	(sp)+,d1
	swap	d1
	or.w	d4,d1	*upper nybble of fxm
	lsl.w	#5,d3
	or.w	d3,d1
	swap	d1
	lsl.w	#8,d2
	lsl.w	#4,d2
	or.w	d2,d1
	qbsr	put_ppc
	rts_	"mtcrf"

**MTCxr
mcrxr:	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mcrxr
	bsr	ops_ignored
ops_ok_mcrxr:
	bsr	get_one
	tst.w	d1
	beq.s	mcrxr_ok
	addq.l	#4,sp
	rts
mcrxr_ok:
	
**check types is ok
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*must be a number
**Check number is <=7>0
	tst.l	d2
	bmi	bad_cr
	cmpi.l	#7,d2
	bgt	bad_cr
*8get upper 4 bits of d2 in d3
	move.l	(sp)+,d1
	swap	d1
	lsl.l	#7,d2
	or.w	d2,d1
	swap	d1
	qbsr	put_ppc
	rts_	"mcrxr"

**Mfcr
mfcr:	qmove.l	d1,-(sp)	     *save inst
	bsr.l	get_ops_ppc
	cmpi.l	#1,d1
	ble.s	ops_ok_mfcr
	bsr	ops_ignored
ops_ok_mfcr:
	bsr	get_one
	tst.w	d1
	beq.s	mfcr_ok
	addq.l	#4,sp
	rts
mfcr_ok:
	
**check types is ok
	tst.w	first_type(a5)
	bne	bad_first	*must be a gpr
	qmove.l	(sp)+,d1
	swap	d1
	lsl.l	#5,d2
	or.w	d2,d1
	swap	d1
	qbsr	put_ppc
	rts_	"mfcr"
				
*************************
priv_warn:
	save_all
	lea	priv_text(pc),a0
	bsr.l	pass1_warning
	restore_all
	rts_	"priv_warn"
priv_warnf:
	save_all
	lea	privf_text(pc),a0
	bsr.l	pass1_warning
	restore_all
	rts_	"priv_warn"

priv_warnmsr:
	save_all
	lea	privmsr_text(pc),a0
	bsr.l	pass1_warning
	restore_all
	rts_	"priv_warn"

pvr_err:
	addq.l	#4,sp
	lea	pvr_text(pc),a0
	bsr.l	pass1_error
	rts_	"pvr_warn"

spr_64_warn:
	save_all
	lea	spr_64_text(pc),a0
	bsr.l	pass1_warning
	restore_all
	rts_	"priv_warn"

shift_zero_warning:
	save_all
	lea	shift_zero_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	rts_	"shift_zero!"
rotate_zero_warning:
	save_all
	lea	rotate_zero_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	rts_	"rotate_zero!"

bad_clrl_warning:
	save_all
	lea	bad_clr_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	bra	clrl_ok
bad_clrr_warning:
	save_all
	lea	bad_clr_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	bra	clrr_ok
	

bad_rotl_warning:
	save_all
	lea	bad_rot_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	bra	done_rotl

bad_rotr_warning:
	save_all
	lea	bad_rot_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	bra	done_rotr
	
**FOR srwi
bad_shr_warning:
	save_all
	lea	bad_shift_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	bra	done_shrw

**FOR slwi
bad_shl_warning:
	save_all
	lea	bad_shift_text(pc),a0
	bsr.l	pass1_advice
	restore_all
	bra	done_shlw

op4_lt_op3:
	addq.l	#4,sp
	lea	op4_lt_op3_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_field"
bad_fxm:
	addq.l	#4,sp
	lea	fxm_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_field"

not_spr:
	addq.l	#4,sp
	lea	bad_spr_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_spr"

bad_field_width:
	addq.l	#4,sp
	lea	field_width_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_field"

bad_field_width1:
	addq.l	#4,sp
	lea	field_width_text1(pc),a0
	bsr.l	pass1_error
	rts_	"bad_field"
bad_field_start:
	addq.l	#4,sp
	lea	field_start_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_sh"
bad_sh:
	addq.l	#4,sp
	lea	sh_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_sh"

bad_shw:
	addq.l	#4,sp
	lea	shw_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_shw"
bad_mask:
	addq.l	#4,sp
	lea	mask_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_mask"
bad_mask_start:
	addq.l	#4,sp
	lea	mask_start_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_mask"
bad_mask_end:
	addq.l	#4,sp
	lea	mask_end_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_mask"


sh_warning:
	lea	sh_warning_text(pc),a0
	bsr.l	pass1_warning
	rts_	"bad_mask"
bad_to:
	addq.l	#4,sp
	lea	to_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_to"
trunc_warning:
	lea	trunc_text(pc),a0
	bsr.l	pass1_warning
	rts_	"trunc_warning"
trunc_warning1:

	lea	trunc1_text(pc),a0
	bsr.l	pass1_warning
	rts_	"trunc_warning"

*************************
fxm_text:	dc.b	"Bad field mask. 0 to 255 allowed (8 bits).",13,0
pvr_text:	dc.b	"The Processor Version Register cannot be written to.",13,0
spr_64_text:	dc.b	"***WARNING*** This SPR is only available on 64 bit processors.",13,0
priv_text:	dc.b	"***WARNING*** The processor must be in supervisor mode to "
	dc.b	"execute a move to this SPR.",13,"If the processor is not is supervisor ",13
	dc.b	"mode, the system 'privileged instruction error handler' will be invoked.",13,0

privmsr_text:	dc.b	"***WARNING*** The processor must be in supervisor mode to "
	dc.b	"execute a move to or from the Machine State Register.",13,"If the processor is not is supervisor "
	dc.b	"mode, the system 'privileged instruction error handler' will be invoked.",13,0

privf_text:	dc.b	"***WARNING*** The processor must be in supervisor mode to "
	dc.b	"execute a move from this SPR.",13,"If the processor is not is supervisor ",13
	dc.b	"mode, the system 'privileged instruction error handler' will be invoked.",13,0
	
bad_spr_text:	dc.b	"Unknown Special Purpose Register (SPR's are defined in UPPER CASE only).",13,0
rotate_zero_text:	dc.b	"***ADVICE*** You have specified a rotate by zero bits.",13,0
shift_zero_text:	dc.b	"***ADVICE*** You have specified a shift by zero bits.",13,0

bad_clr_text:	dc.b	"***ADVICE*** Third operand (n)"
	dc.b	" is outside the normal range of 1-31. n has been ANDED with 0x1F.",13,0

bad_rot_text:	dc.b	"***ADVICE*** Third operand - the rotate amount (n)"
	dc.b	" is outside the normal range of 1-31. n has been ANDED with 0x1F.",13,0
bad_shift_text:	dc.b	"***ADVICE*** Third operand - the shift amount (n)"
	dc.b	" is outside the normal range of 1-31. n has been ANDED with 0x1F.",13,0
	
trunc_text:	dc.b	"***WARNING***",13,
	dc.b	"The bit field will be truncated.",13
	dc.b	"OPERAND SYNTAX: ra,rs,n,b - select a field of n bits (left or right justified)"
	dc.b	" and insert into destination register at bit b.",13,0

trunc1_text:	dc.b	"***WARNING*** Possible programmer error.",13
	dc.b	"The field is truncated because n (number of bits) > b+1 "
	dc.b	"(b = field start position).",13
	dc.b	"OPERAND SYNTAX: ra,rs,b,n. Select a field of n bits starting at b."
	dc.b	" Right or left justify this field in the target register Ra.",13,0
op4_lt_op3_text:	dc.b	"Operand #4 (width, or number of bits) must be less than or equal to "
	dc.b	"operand #3 (start bit of field).",13,0
	align
			
field_width_text:	dc.b	"The field width (operand #3) is illegal in this instruction. Must be in the range 0-31.",13,0
field_width_text1:	dc.b	"The field width (operand #3) is illegal in this instruction. Must be in the range 1-31.",13,0

field_start_text:	dc.b	"The field start (operand #4) is illegal in this instruction. Must be in the range 0-31.",13,0
sh_warning_text:	dc.b	"***WARNING***WARNING***WARNING***",13
	dc.b	"This is a 64 bit shift/rotate instruction and is illegal on"
	dc.b	" 32 bit processors.",13,0
	
sh_text:	dc.b	"Illegal third operand - the shift operand can be between"
	dc.b	" 0 and 63.",13,0
mask_text:	dc.b	"Illegal fourth operand. The mask operand can be between "
	dc.b	"0 and 63.",13,0
shw_text:	dc.b	"Illegal third operand. The shift operand can be between"
	dc.b	" 0 and 31.",13,0

mask_start_text:	dc.b	"Illegal fourth operand. The mask start bit operand can be between "
	dc.b	"0 and 31.",13,0
mask_end_text:	dc.b	"Illegal fifth operand. The mask end bit operand can be between "
	dc.b	"0 and 31.",13,0

to_text:	dc.b	"Illegal first operand - TO field.",13
	dc.b	"Values are: 1=Less than, 2=Greater than, 4=Equal, 8=Less than Unsigned"
	dc.b	", 16=Greater than Unsigned. These values may be added together.",13,0
	align

sprs:	dc.b	"XER",0,0,0,0,0
	dc.b	"LR",0,0,0,0,0,0
	dc.b	"CTR",0,0,0,0,0
	dc.b	"DSISR",0,0,0
	dc.b	"DAR",0,0,0,0,0	
	dc.b	"DEC",0,0,0,0,0
	dc.b	"SDR1",0,0,0,0
	dc.b	"SRR0",0,0,0,0
	dc.b	"SRR1",0,0,0,0
	dc.b	"VRSAVE",0,0
	dc.b	"SPRG0",0,0,0
	dc.b	"SPRG1",0,0,0
	dc.b	"SPRG2",0,0,0
	dc.b	"SPRG3",0,0,0
	dc.b	"ASR",0,0,0,0,0
	dc.b	"EAR",0,0,0,0,0
	dc.b	"TBL",0,0,0,0,0
	dc.b	"TBU",0,0,0,0,0
	dc.b	"PVR",0,0,0,0,0	*read only
	dc.b	"IBAT0U",0,0
	DC.B	"IBAT0L",0,0
	DC.B	"IBAT1U",0,0
	DC.B	"IBAT1L",0,0
	DC.B	"IBAT2U",0,0
	DC.B	"IBAT2L",0,0
	DC.B	"IBAT3U",0,0
	DC.B	"IBAT3L",0,0
	DC.B	"DBAT0U",0,0
	DC.B	"DBAT0L",0,0
	DC.B	"DBAT1U",0,0
	DC.B	"DBAT1L",0,0
	DC.B	"DBAT2U",0,0
	DC.B	"DBAT2L",0,0
	DC.B	"DBAT3U",0,0
	DC.B	"DBAT3L",0,0
**750 etc
	DC.B	"HID0",0,0,0,0
	DC.B	"HID1",0,0,0,0
	DC.B	"UPMC1",0,0,0	*performance counters (read) 750
	DC.B	"UPMC2",0,0,0
	DC.B	"UPMC3",0,0,0
	DC.B	"UPMC4",0,0,0
	DC.B	"USIA",0,0,0,0
	DC.B	"UMMCR0",0,0
	DC.B	"UMMCR1",0,0	*monitor control (750)
	DC.B	"PMC1",0,0,0,0
	DC.B	"PMC2",0,0,0,0
	DC.B	"PMC3",0,0,0,0
	DC.B	"PMC4",0,0,0,0	*performance counters (write) (750)
	DC.B	"SIA",0,0,0,0,0	*sampled instruction address (750)
	DC.B	"MMCR0",0,0,0	*Monitor control (750)
	DC.B	"MMCR1",0,0,0	*Monitor control (750)
	DC.B	"THRM1",0,0,0	*Thermal assist
	DC.B	"THRM2",0,0,0	*Thermal assist
	DC.B	"THRM3",0,0,0	*Thermal assist
	DC.B	"ICTC",0,0,0,0	*Throttle
	DC.B	"DABR",0,0,0,0	*data address breakpoint register
	DC.B	"L2CR",0,0,0,0	*L2 cache control
	DC.B	"IABR",0,0,0,0	*Instruction address breakpont register
	
	dc.l	-1,-1
	align	4
spr_table:		dc.w	1
	dc.w	8	*lr
	dc.w	9	*ctr
	dc.w	18	*DSISR
	dc.w	19	*DAR
	dc.w	22	*DEC
	dc.w	25	*SDR1
	dc.w	26	*SRR0
	dc.w	27	*SRR1
	dc.w	256	*VRSAVE
	dc.w	272	*SPRG0
	dc.w	273	*SPRG1
	dc.w	274	*SPRG2
	dc.w	275	*SPRG3
	dc.w	280	*ASR (64 bit only)
	dc.w	282	*EAR
	dc.w	284	*TBL	*write only
	dc.w	285	*TBU	*write only
	dc.w	287	*PVR	*read only
	dc.w	528	*IBAT0U
	dc.w	529	*IBAT0L		
	dc.w	530	*IBAT1U
	dc.w	531	*IBAT1L
	dc.w	532	*IBAT2U
	dc.w	533	*IBAT2L
	dc.w	534	*IBAT3U
	dc.w	535	*IBAT3L
	dc.w	536	*Dbatx...
	dc.w	537
	dc.w	538
	dc.w	539
	dc.w	540
	dc.w	541
	dc.w	542
	dc.w	543	
**750 etc
	dc.w	1008	*HID0 - hardware implementation registers
	dc.w	1009	*HID1
	dc.w	937	*UPMC1	- performance counters 9read)
	dc.w	938	*UPMC2
	dc.w	941	*UPMC3
	dc.w	942	*UPMC4
	dc.w	939	*USIA - sampled instruction address
	dc.w	936	*UMMCR0 - monitor control
	dc.w	940	*UMMCR1
	
	dc.w	953
	dc.w	954
	dc.w	957
	dc.w	958	*PMC performance counters (write)
	
	dc.w	955	*SIA (750)
	dc.w	952	*MMCR0
	dc.w	956	*MMCR1
	
	dc.w	1020	*THRM1
	dc.w	1021	*THRM2
	dc.w	1022	*THRM3
	
	dc.w	1019	*ICTC
	dc.w	1013	*DABR
	dc.w	1017	*L2CR
	dc.w	1010	*IABR
	align	4
	global	tdi,td,twei,twe,rldicl,rlwinm,rlwnm,extlwi,extrwi,clrlslwi,inslwi
	global	insrwi,rotlwi,rotrwi,rotlw,slwi,srwi,clrlwi,clrrwi,sradi,srawi
	global	mtspr,mfspr,mtxer,mtlr,mtctr,mtcrf,mcrxr,mfcr,mftb,mtmsr

	extern	sixty_four_warn,bad_first,bad_second,bad_third,bad_cr,get_ops_ppc
	extern	ops_ignored,get_three,put_ppc,datasize_err,pass1_error
	extern	get_two,get_four,pass1_warning,get_five,bad_fourth
	extern	get_one,get_op_code_num,inst_search,pass1_advice
	else
dummy:
	nop
	global	dummy
	endif