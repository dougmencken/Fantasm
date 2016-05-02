***************************************
*Expand_internal_strings 
*expands tim$, dat$ and ivx$
*where x is 0 to 9
	reset_locals
	local.b	my_field,1024	*space to expand into
expand_internal_strings:
**scan, looking for ['s, expand valid ['s and return in field_3
	sub_entry	a4
	tst.b	possible_string_in_field_3(a5)
	beq.s	no_strings

	push	a0
	lea	field_3(a5),a0
	lea	my_field(a4),a1
	push	a4	*Grrr
	bsr.s	expand
	pop	a4
	lea	my_field(a4),a0
	lea	field_3(a5),a1
	qmove.l	#511,d2	*clipped back to 511 bytes
	OSBlockMoveData	a0,a1,d2	*return field3

	pop	a0
no_strings:
	tst.b	possible_string_in_field_2(a5)
	beq.s	no_strings1

	push	a0
	lea	field_2(a5),a0
	lea	my_field(a4),a1
	push	a4	*Grrr
	bsr.s	expand
	pop	a4
	lea	my_field(a4),a0
	lea	field_2(a5),a1
	qmove.l	#511,d2	*clipped back to 511 bytes
	OSBlockMove	a0,a1,d2	*return field3

	pop	a0
no_strings1:

	sub_exit	a4
	rts_	"Expand_internal_strings"

	reset_locals
	local.b	temp_string22,512
expand:
	sub_entry	a4	*bit tricky cause we destroy this...
	qmove.l	#511,d7	*max field width
expand1:
	move.b	(a0)+,d0
	beq.s	end
	cmpi.b	#"[",d0
	bne.s	copy
**Check for A-Z$

	bsr	check_for_internal_string	*can return 0 to 25 for a to z or 64,65,66 for 1-3$
	tst.l	d0
	bmi.s	not_internal
	
	addq.l	#3,a0	*Skip past [x$]

	push	a0
;	 cmpi.w	#64,d0
;	 blt.s	 internal_string1
;	 debug
;**a field - 64 is field 1, 65 is field 2, 66 is field 3
;	 cmpi.w	#64,d0
;	 bne.s	 not_f1
;	 lea	field_1(a5),a0
;	 bra.s	 copy_internal
;not_f1:
;	 cmpi.w	#65,d0
;	 bne.s	 not_f2
;	 lea	field_2(a5),a0
;	 bra.s	 copy_internal
;
;not_f2:
;	 cmpi.w	#66,d0
;	 bne.s	 not_f3
;	 lea	field_3(a5),a0
;	 bra.s	 copy_internal
;
;not_f3:	clr.l	 d0	*default to a$
;internal_string1:
**copy to a1 and bugger ooff..
	lsl.l	#8,d0	*each is is 256 bytes
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
copy_internal:
	move.b	(a0)+,(a1)+
	bne.s	copy_internal
	pop	a0
	subq.l	#1,a1
	bra.s	do_next	*carry on
	
not_internal:
**now send string to search which will return -1 if not found else a code as
**follow:
**0 = ukdate
**1 = usdate
**2 = time
**find end square bracks and copy to temp_string22(a4)
**its possible we wont find a close brackets
	lea	temp_string22(a4),a2
	move.l	a0,a3	*so we can restore to start if not found
find_end_square:
	move.b	(a0)+,d0
	beq.s	no_end
	qmove.b	d0,(a2)+
	cmpi.b	#"]",d0
	bne.s	find_end_square
	clr.b	(a2)	*terminate for search
	movem.l	a0/a1/a4/a3,-(sp)
;	push	a3	*Save our reset
;	push	a4	*save our frame pointer cause dir_search destroys it
;	push	a1	*save our output pointer
	lea	temp_string22(a4),a4
;	push	a0	*save current source pos
	lea	iv_strings_table(pc),a1	SEARCH EQUATES
	bsr.l	dir_search 	*search a1 for a4 returns position in d0 or -1
	movem.l	(sp)+,a0/a1/a4/a3
;	pop	a0	*resotre current source pos
;	pop	a1	*restore output pointer
;	pop	a4	*restore our frame pointer
;	pop	a3	*restore our reset for if not found
	tst.w	d0 
 	bmi.s	no_end	*-ve=not found else d0=position
	if	PPC
	push	a3
	push	d0
	macs_last
	lwz	r23,[t]iv_branch_table(rtoc)
	slwi	r3,r3,6	*times 64
	add	r23,r3,r23
	
	mtctr	r23	*where we go to
	bl	here1
here1:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	pop	d0
	pop	a3
	else
	push	a3
 	lea	iv_branch_table(pc),a3
	jsr	0(a3,d0.w*8)
	pop	a3
	endif
done_replace:
**a0 is pointing at char next to end of variable
	bra.s	do_next	*don't copy the bollox in d0 stu...

**Come here if we did not find a close brackets
no_end:
	move.l	a3,a0
	qmove.b	#"[",d0
copy:
	qmove.b	d0,(a1)+
do_next:
	qdbra	d7,expand1
end:	clr.b	(a1)
	clr.b	1(a1)	*call me a cynic...
	sub_exit	a4
	rts_	"Expand"

**check a0-1 for [x$] or [1$] (meaning field 1)
check_for_internal_string:
	qmove.l	#0,d0	*default error
	qmove.l	-1(a0),d1

	andi.l	#0xff00ffff,d1

	cmpi.l	#$5b00245d,d1	*[x$]
	beq.s	field_1ok
	moveq	#-1,d0
	bra.s	cf1_end
field1_bad:
	lea	eis_string_error(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
	bra.s	cf1_end
field_1ok:
**get string ID, do is clear already
	qcmove.w	-1(a0),d0
	andi.w	#0xff,d0
;	 cmpi.w	#"1",d0
;	 beq.s	 got_field1
;	 cmpi.w	#"2",d0
;	 beq.s	 got_field2
;	 cmpi.w	#"3",d0
;	 beq.s	 got_field3
	cmpi.l	#"Z",d0
	ble.s	seems_ok1
	sub.l	#0x20,d0	*try to make upper case
seems_ok1:
	sub.l	#"A",d0
	bmi	field1_bad
	cmpi.l	#25,d0
	bgt.s	field1_bad
cf1_end:
	rts_	"Check_for_internal_string"
;got_field1:
;	 qmoveq	#64,d0
;	 bra.s	 cf1_end
;got_field2:
;	 qmoveq	#65,d0
;	 bra.s	 cf1_end
;got_field3:
;	 qmoveq	#66,d0
;	 bra.s	 cf1_end
	
**************
**each entry 8 bytes
	if 	PPC
iv_branch_table:	toc_routine
	else
iv_branch_table:
	endif
	bsr.l	expand_uk_date
	rts44
	bsr.l	expand_us_date
	rts44
	bsr.l	expand_time_with_secs
	rts44
	bsr.l	expand_time_no_secs
	rts44
	bsr.l	expand_hours
	rts44
	bsr.l	expand_minutes
	rts44
	bsr.l	expand_seconds
	rts44
	bsr.l	expand_day	*days
	rts44
	bsr.l	expand_month
	rts44
	bsr.l	expand_year
	rts44
	bsr.l	expand_long_year
	rts44
	bsr.l	expand_pi
	rts44
	bsr.l	expand_vers
	rts44
	bsr.l	expand_build_number
	rts44
	extern	expand_seconds,expand_minutes,expand_hours,expand_time_no_secs,expand_time_with_secs
	extern	expand_us_date,expand_uk_date
	extern	expand_day,expand_month,expand_year,expand_long_year,expand_pi
	extern	expand_vers,expand_build_number
***tables
iv_strings_table:	dc.b	"ukdate$]",0	*0
	dc.b	"usdate$]",0	*1
	dc.b	"time_with_secs$]",0	*2
	dc.b	"time$]",0	*3
	dc.b	"hours$]",0	*4
	dc.b	"minutes$]",0	*5
	dc.b	"seconds$]",0	*6
	dc.b	"day$]",0	*7 - same as hours!
	dc.b	"month$]",0	*8
	dc.b	"year$]",0	*9	97
	dc.b	"longyear$]",0	*10 - 1997
	dc.b	"pi$]",0	*11 - 3.1428571429
	dc.b	"vers$]",0	*12
	dc.b	"build$]",0	*13	- the build number as a string
	dc.b	0,0,0,0,0,0,0,0,0,0
	align	4	
eis_string_error:	cstring	"Bad string identifier in field 3",13
	align	4
	global	expand_internal_strings
	extern	dir_search
	extern	pass1_error