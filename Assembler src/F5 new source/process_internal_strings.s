	include	client_commands.def
**Process_internal_strings
**a list of routines accessed from expand_internal_strings
expand_uk_date:
**insert ukdate as a string into a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*year, month, date in a0
	
	qcmove.w	(a0)+,d2	*year
	sub.w	#1900,d2
	qcmove.w	(a0)+,d1	*month
	qcmove.w	(a0)+,d0	*day
	pop	a1
	move.l	a1,a0
	qmove.l	#0,d6
	qmove.w	d0,d6
	push	d1
	bsr	printnum_mem
	pop	d1
	clr.l	d6
	qmove.w	d1,d6
	bsr	printnum_mem
	clr.l	d6
	qmove.w	d2,d6
	bsr	printnum_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"Expand_uk_date"
expand_us_date:
**insert usdate as a string into a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*year, month, date in a0
	qcmove.w	(a0)+,d2	*year
	sub.w	#1900,d2
	qcmove.w	(a0)+,d0	*month
	qcmove.w	(a0)+,d1	*day
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d0,d6
	push	d1
	bsr	printnum_mem
	pop	d1
	clr.l	d6
	qmove.w	d1,d6
	bsr	printnum_mem
	clr.l	d6
	qmove.w	d2,d6
	bsr	printnum_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_us_date"
expand_day:
**insert usdate as a string into a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*year, month, date in a0
	qcmove.w	(a0)+,d2	*year
	sub.w	#1900,d2
	qcmove.w	(a0)+,d0	*month
	qcmove.w	(a0)+,d1	*day
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d1,d6
	bsr		printnum_no_lead_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_day"
expand_month:
**insert usdate as a string into a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*year, month, date in a0
	qcmove.w	(a0)+,d2	*year
	sub.w	#1900,d2
	qcmove.w	(a0)+,d0	*month
	qcmove.w	(a0)+,d1	*day
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d0,d6
	bsr	printnum_no_lead_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_month"

expand_year:
**insert usdate as a string into a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*year, month, date in a0
	qcmove.w	(a0)+,d2	*year
	sub.w	#1900,d2
	qcmove.w	(a0)+,d0	*month
	qcmove.w	(a0)+,d1	*day
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d2,d6
	bsr	printnum_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_year"

expand_long_year:
**insert usdate as a string into a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*year, month, date in a0
	move.w	(a0)+,d2	*year
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d2,d6
	bsr	printnum_no_lead_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_longyear"

expand_time_with_secs:
**insert time with seconds as a string into a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*d0=hours, d1=mns, d2=secs
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d0,d6
	push	d1
	bsr	printnum_mem
	pop	d1
	clr.l	d6
	qmove.w	d1,d6
	bsr	printnum_mem
	clr.l	d6
	qmove.w	d2,d6
	bsr	printnum_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_time_with_secs"
expand_time_no_secs:
**insert time with seconds as a string into a1
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*d0=hours, d1=mns, d2=secs
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d0,d6	*hours
	push	d1
	bsr	printnum_mem
	pop	d1
	clr.l	d6
	qmove.w	d1,d6
	bsr	printnum_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_time_no_secs"
expand_hours:
**insert hours string and suppress leading zero
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*d0=hours, d1=mns, d2=secs
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d0,d6
	bsr	printnum_no_lead_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_hours"
expand_minutes:
**insert hours string and suppress leading zero
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*d0=hours, d1=mns, d2=secs
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d1,d6
	bsr	printnum_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_minutes"
expand_seconds:
**insert hours string and suppress leading zero
	movem.l	d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4,-(sp)
	push	a1
	bsr	get_time	*d0=hours, d1=mns, d2=secs
	pop	a1
	move.l	a1,a0
	clr.l	d6
	qmove.w	d2,d6
	bsr	printnum_mem
	move.l	a0,a1	*this is our output pointer!
	movem.l	(sp)+,d0/d1/d2/d3/d4/d5/d6/d7/a0/a2/a3/a4
	rts_	"expand_seconds"
expand_pi:
**insert hours string and suppress leading zero
	qmove.l	#"3.14",(a1)+	*3.1428571429
	qmove.l	#"1592",(a1)+
	qmove.l	#"6535",(a1)+
	qmove.l	#"8979",(a1)+
	rts_	"expand_pi"
expand_vers:
	qmove.l	#"6.0.",(a1)+
	qmove.w	#"0 ",(a1)+
	rts_	"expand_vers"
*******************************
expand_build_number:
	section	ebn
*8get build number
	movem.l	d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6,-(sp)
**use send_2
	qmove.l	#A_get_build_number,d0
	qmove.l	#0,d1
	qmove.l	#0,d2
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	move.l	(a0),a0
	qmove.l	4(a0),d0	*The build number
	qpush1	d0
	move.l	my_pb_handle(a5),d0
	OSDisposeHandle	d0
	qpop1	d0
	movem.l	(sp)+,d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4/a5/a6
	cmpi.l	#9999999,d0
	ble.s	.number_ok
	sub.l	#9999999,d0
	
.number_ok:
	move.l	a1,a2
	bsr.l	print_long_m	
	move.l	a2,a1
	rts_	"expand_build_number"
	global	expand_seconds,expand_minutes,expand_hours,expand_time_no_secs,expand_time_with_secs
	global	expand_us_date,expand_uk_date,expand_day,expand_month,expand_year,expand_long_year
	global	expand_pi,expand_vers,expand_build_number

*********************************************************************************
**String handling directives

**********String asignment - EQU$
[x$]:	equ$	string constant or string variable
handle_equ$:
**Check field for valid string ID
	push	a0
	bsr	check_field1	*returns string ID (0-25)
	tst.w	d0
	bmi.s	he_end	*field 1 is bad
	lsl.l	#8,d0	*each string is 256 bytes max
	qpush1	d0
	move.l	internal_strings_h(a5),d0
	OSHLock	d0
	qpop1	d0
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
	qmove.l	a0,dest_string_addr(a5)
**Now copy field 3 to dest_string_addr
**field 3 may or may not be in double quotes
	section
	lea	field_3(a5),a1
.copy_3:
	move.b	(a1)+,(a0)+
	bne.s	.copy_3
	move.l	dest_string_addr(a5),a0
he_end:
	pop	a0
	rts_	"handle_equ"
*********SEARCH$
**pos:		search$	str,character identifier	acts as a set
handle_fndc:	*fndc=find char
**Find the god damned comma - we'll have something like expansion,count
**Find end, then work backwards!
	push	a0
	section

	lea	field_3(a5),a1
.find_end:
	move.b	(a1)+,d0
	bne.s	.find_end

**now scan back looking for a comma - we have a guard byte (0) at the start of field 3
	subq.l	#2,a1
.find_comma1:
	qcmove.b	(a1),d0
	tst.l	d0
	beq.s	.wot_comma!
	cmpi.l	#0x2c,d0
	beq.s	.got_comma1
	subq.l	#1,a1
	bra.s	.find_comma1
.got_comma1:
	qmove.l	a1,arguments_start(a5)	*so we don't process our args
	addq.l	#1,a1
**now evaluate what follows
	tst.b	(a1)
	beq.s	.wot_comma!
	move.l	a1,a2
	bsr.l	evaluate	*in d0
	tst.l	d0
	bge.s	.got_value
	bsr	neg_arg_error
	bra	hs_end
.wot_comma!:
	lea	field3_left_error(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
	bra	ss_end
.got_value:
**now search what's before the comma looking for d0
	section
**char in d0
	lea	field_3(a5),a1
	qmove.l	arguments_start(a5),d3
	qmove.l	#-1,d1
.search:
	addq.l	#1,d1	*pos counter
	cmp.l	a1,d3
	beq.s	.not_found	*We've hit the start of our arguments!
	cmp.b	(a1)+,d0
	bne.s	.search
.found:	*comment label only
	bra.s	do_set
.not_found:
	moveq	#-1,d1
do_set:
**Save field 3
	qpush1	d1
	lea	field_3(a5),a0
	lea	temp_string4(a5),a1
	qmove.l	#514,d2
	OSBlockMoveData	a0,a1,d2
	qpop1	d1
	
	lea	field_3(a5),a0
	move.l	d1,d6
	bge.s	do_printnum
	qmove.w	#"-1",(a0)+
	qmove.w	#0,(a0)+
	bra.s	done_printmem
do_printnum:
	bsr	printnum_no_lead_mem
	clr.b	(a0)	*terminate
done_printmem:
	lea	field_3(a5),a0
	bsr.l	set
**restore field 3
	lea	field_3(a5),a1
	lea	temp_string4(a5),a0
	qmove.l	#514,d2
	OSBlockMoveData	a0,a1,d2

;	move.l	dest_string_addr(a5),a0
ss_end:
	pop	a0
	rts_	"handle_fndc"
	global	handle_fndc
*********LEFT$
**[x$] left$	[x$],x	
handle_left$:
	push	a0
	bsr	check_field1	*returns string ID (0-25)
	tst.w	d0
	bmi	hl_end	*field 1 is bad
	lsl.l	#8,d0	*each string is 256 bytes max
;	push	d0		*5.1 deletes these 4 lines
;	move.l	internal_strings_h(a5),a0
;	dc.w	_HLock
;	pop	d0
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
;	move.l	a0,dest_string_addr(a5)
**Now copy field 3 to dest_string_addr
**field 3 may or may not be in double quotes
**Find the god damned comma - we'll have something like expansion,count
**Find end, then work backwards!
	section

	lea	field_3(a5),a1
.find_end:
	move.b	(a1)+,d0
	bne.s	.find_end

**now scan back looking for a comma - we have a guard byte (0) at the start of field 3
	subq.l	#2,a1
.find_comma1:
	qmove.l	#0,d0
	qcmove.b	(a1),d0
	tst.l	d0
	beq.s	.wot_comma!
	cmpi.l	#0x2c,d0
	beq.s	.got_comma1
	subq.l	#1,a1
	bra.s	.find_comma1
.got_comma1:
	qmove.l	a1,arguments_start(a5)	*so we don't process our args
	addq.l	#1,a1
**now evaluate what follows
	tst.b	(a1)
	beq.s	.wot_comma!
	move.l	a1,a2
	bsr.l	evaluate	*in d0
	tst.l	d0
	beq.s	hl_end
;	tst.l	d0
	bgt.s	.got_value
	bsr	neg_arg_error
	bra	hr_end
.wot_comma!:
	lea	field3_left_error(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
	bra.s	hl_end
.got_value:
;	move.l	dest_string_addr(a5),a0
	section
**count in d0
	dec.l	d0
	lea	field_3(a5),a1
	qmove.l	arguments_start(a5),d3
.copy_3:
	cmp.l	a1,d3
	beq.s	hl_err2	*We've hit the start of our arguments!
	move.b	(a1)+,(a0)+
	beq.s	hl_err2	*fuck, run out of text!
	qdbra	d0,.copy_3
	clr.b	(a0)
;	move.l	dest_string_addr(a5),a0
hl_end:
	pop	a0
	rts_	"handle_left"
hl_err2:
	lea	field3_data_error(pc),a0
	bsr.l	pass1_error
	bra.s	hl_end
*****************MID$
handle_mid$:
	push	a0
	bsr	check_field1	*returns string ID (0-25)
	tst.w	d0
	bmi	hm_end	*field 1 is bad
	lsl.l	#8,d0	*each string is 256 bytes max
;	push	d0		*5.1 deletes these lines - locked in Fantasm.s
;	move.l	internal_strings_h(a5),a0
;	dc.w	_HLock
;	pop	d0
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
;	move.l	a0,dest_string_addr(a5)
**Now copy field 3 to dest_string_addr
**field 3 may or may not be in double quotes
**Find the god damned comma - we'll have something like expansion,start,length
**Find end, then work backwards!
	section

	lea	field_3(a5),a1
.find_end:
	move.b	(a1)+,d0
	bne.s	.find_end

**now scan back looking for a comma - we have a guard byte (0) at the start of field 3
	subq.l	#2,a1
.find_comma1:
	qmove.l	#0,d0
	qcmove.b	(a1),d0
	tst.l	d0
	beq.s	.wot_comma!
	cmpi.l	#0x2c,d0
	beq.s	.got_comma1
	subq.l	#1,a1
	bra.s	.find_comma1
.got_comma1:
	
	qmove.l	a1,arguments_start(a5)	*so we don't process our args
	addq.l	#1,a1
**now evaluate what follows
	move.l	a1,a2
	tst.b	(a1)
	beq.s	.wot_comma!
	push	a1
	bsr.l	evaluate	*in d0
	pop	a1
	tst.l	d0
	beq	hr_end	*zero as argument
	tst.l	d0
	bge.s	.argok1
	bsr	neg_arg_error
	bra	hm_end
.argok1:

	qmove.l	d0,mid_arg_2(a5)

**find previous comma
	subq.l	#1,a1	*back past comma
	qmove.l	a1,restore_comma(a5)	*pole a comma back in here after eval
	clr.b	(a1)	*For evaluator
	subq.l	#1,a1
.find_comma2:
	move.b	(a1),d0
	beq.s	.wot_comma!
	cmpi.b	#0x2c,d0
	beq.s	.got_comma2
	subq.l	#1,a1
	bra.s	.find_comma2
.got_comma2:
	
	move.l	a1,arguments_start(a5)	*so we don't process our args
	addq.l	#1,a1
**now evaluate what follows
	move.l	a1,a2
	tst.b	(a1)
	beq.s	.wot_comma!
	push	a1
	bsr.l	evaluate	*in d0
	move.l	restore_comma(a5),a1
	qmove.b	#0x2c,(a1)	*so we report ok
	pop	a1
	tst.l	d0
	bge.s	.argok
	bsr.s	neg_arg_error
	bra.s	hm_end
.argok:
	qmove.l	d0,mid_arg_1(a5)
	bra.s	.got_value
.wot_comma!:
	lea	field3_left_error(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
	bra	hr_end
.got_value:
	section
**count in d0
**end of field 3 is in arguments_start
;	move.l	arguments_start(a5),a1
;	sub.l	d0,a1	*where we start copying from
**check addr of a1 isn't less than field_3
;	move.l	dest_string_addr(a5),a0
	lea	field_3(a5),a2
	move.l	a2,a1
	add.l	mid_arg_1(a5),a2
	qmove.l	a2,d1
	cmp.l	a1,d1
	bge.s	.not_off_start
	lea	field3_negative_param(pc),a0	*copying before the start of data
	bsr.l	pass1_error
	moveq	#-1,d0
	bra.s	hm_end
.not_off_start:
	qmove.l	mid_arg_2(a5),d0	*count
	sub.l	#1,d0
	qmove.l	arguments_start(a5),d3
.copy_3:
	cmp.l	a2,d3
	beq.s	hm_err2	*We've hit the start of our arguments, so stop!
	move.b	(a2)+,(a0)+
	beq.s	hm_err2	*fuck, run out of text!
	qdbra	d0,.copy_3
.stop:	
	clr.b	(a0)
;	move.l	dest_string_addr(a5),a0
hm_end:
	pop	a0


	rts_	"handle_mid"

neg_arg_error:
	lea	field3_negative_param(pc),a0	*copying before the start of data
	bsr.l	pass1_error
	moveq	#-1,d0
	rts_	"neg_arg_error"
	
hm_err2:
	lea	field3_data_error(pc),a0
	bsr.l	pass1_error
	bra.s	hm_end
	
*****************RIGHT$
handle_right$:
	push	a0
	bsr	check_field1	*returns string ID (0-25)
	tst.w	d0
	bmi	hr_end	*field 1 is bad
	lsl.l	#8,d0	*each string is 256 bytes max
;	push	d0		*5.1 deletes these 4 lines - locked in Fantasm.s
;	move.l	internal_strings_h(a5),a0
;	dc.w	_HLock
;	pop	d0
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
;	move.l	a0,dest_string_addr(a5)
**Now copy field 3 to dest_string_addr
**field 3 may or may not be in double quotes
**Find the god damned comma - we'll have something like expansion,count
**Find end, then work backwards!
	section

	lea	field_3(a5),a1
.find_end:
	move.b	(a1)+,d0
	bne.s	.find_end

**now scan back looking for a comma - we have a guard byte (0) at the start of field 3
	subq.l	#2,a1
.find_comma1:
	move.b	(a1),d0
	beq.s	.wot_comma!
	cmpi.b	#0x2c,d0
	beq.s	.got_comma1
	subq.l	#1,a1
	bra.s	.find_comma1
.got_comma1:
	qmove.l	a1,arguments_start(a5)	*so we don't process our args
	addq.l	#1,a1
**now evaluate what follows
	move.l	a1,a2
	tst.b	(a1)
	beq.s	.wot_comma!
	bsr.l	evaluate	*in d0
	tst.l	d0
	beq.s	hr_end	*zero as argument
;	tst.l	d0
	bgt.s	.got_value
	bsr	neg_arg_error
	bra.s	hr_end
;.argok:

;	bra.s	.got_value
.wot_comma!:
	lea	field3_left_error(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
	bra.s	hr_end
.got_value:
	section
**count in d0
**end of field 3 is in arguments_start
	move.l	arguments_start(a5),a1
	sub.l	d0,a1	*where we start copying from
**check addr of a1 isn't less than field_3
;	move.l	dest_string_addr(a5),a0
	lea	field_3(a5),a2
	qmove.l	a2,d1
	cmp.l	a1,d1
	ble.s	.not_off_start
	lea	field3_right_error(pc),a0	*copying before the start of data
	bsr.l	pass1_error
	moveq	#-1,d0
	bra.s	hr_end
	subq.l	#1,d0
.not_off_start:
	qmove.l	arguments_start(a5),d3
.copy_3:
	cmp.l	a1,d3
	beq.s	.stop	*We've hit the start of our arguments, so stop!
	move.b	(a1)+,(a0)+
	beq.s	hr_err2	*fuck, run out of text!
	dbra	d0,.copy_3
.stop:
	clr.b	(a0)
;	move.l	dest_string_addr(a5),a0
hr_end:
	pop	a0

	rts_	"Handle_right"
hr_err2:
	lea	field3_data_error(pc),a0
	bsr.l	pass1_error
	bra.s	hr_end

**********CONCAT
handle_concat$:
	clr.l	output_counter(a5)	*So we can check if we run out of space
	push	a0
	bsr	check_field1	*returns string ID (0-25)
	tst.w	d0
	bmi	hc_end	*field 1 is bad
	lsl.l	#8,d0	*each string is 256 bytes max
	qpush1	d0
	qmove.l	internal_strings_h(a5),d0
	OSHLock	d0
	qpop1	d0
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
	qmove.l	a0,dest_string_addr(a5)
**Now copy field 3 to dest_string_addr
**field 3 may or may not be in double quotes
**Find the god damned comma - we'll have something like str1,str2
**Find end, then work backwards!
	section

	lea	field_3(a5),a1
.find_end:
	move.b	(a1)+,d0
	bne.s	.find_end

**now scan back looking for a comma - we have a guard byte (0) at the start of field 3
	subq.l	#2,a1
	qmove.l	#0,d5	*quotes flag
	qmove.l	#0,d6
.find_comma1:
	move.b	(a1),d0
	beq	.wot_comma!	*off start of f3
	cmpi.b	#0x22,d0
	bne.s	.not_quotes
	bchg	#0,d5
.not_quotes:
	cmpi.b	#0x2c,d0
	beq.s	.got_comma1
.in_string1:
	inc.l	d6
	subq.l	#1,a1
	bra.s	.find_comma1
.got_comma1:
**maybe
	cmpi.l	#1,d6	*one character?
	bne.s	maybe_quote	*no
**This is a real weird situation for:
**	a,"abc,"
**We have to scan back still, looking for a " preceeded by a comma
**if found, we have not found the seperator.

	move.l	a1,a3
findqc:
	move.b	-(a3),d0
	beq.s	found_sep	*Start of field
	cmpi.b	#0x22,d0
	bne.s	findqc
	cmpi.b	#0x2c,-1(a3)
	beq.s	maybe_quote	*we may be in quotes - check the flag
	
found_sep:
	clr.b	d5	*was one char which was quote so not in a string!
maybe_quote:
	tst.b	d5	*in a string?
	bne.s	.in_string1	*yes

	qmove.l	a1,arguments_start(a5)	*start of string 2, string 1 starts at field_3
**Copy from field_3 to arguments_start-1
	lea	field_3(a5),a1
	move.l	arguments_start(a5),a2
	qmove.l	#0,d5
	cmp.l	a1,a2
	beq.s	.no_str1
.copy1:
	qmove.b	(a1)+,(a0)+
	inc.l	output_counter(a5)
	cmpi.l	#255,output_counter(a5)
	bne.s	.size_ok
	lea	string_error(pc),a0
	bsr.l	pass1_error
	bra.s	hc_end
.size_ok:
	cmp.l	a1,a2
	bne.s	.copy1
	qmove.b	-1(a1),d5	*Save last char for quotes check
**Copy param2
.no_str1
	move.l	arguments_start(a5),a1
	inc.l	a1	*skip comma
	cmpi.b	#0x22,(a1)
	bne.s	.notaquote
*8was last char of previous string a quote?
	cmpi.b	#0x22,d5
	bne.s	.notaquote
**last string ended with and this one starts with a quote so remove them
	subq.l	#1,a0	*bye to previous
	addq.l	#1,a1	*bye to this
.notaquote:
.copy2:
	inc.l	output_counter(a5)
	cmpi.l	#255,output_counter(a5)
	bne.s	.size_ok1
	lea	string_error(pc),a0
	bsr.l	pass1_error
	bra.s	hc_end
.size_ok1:
	move.b	(a1)+,(a0)+
	bne.s	.copy2
hc_end:
	pop	a0
	rts_	"handle_concat"
.wot_comma!:
	lea	field3_left_error(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
	bra	hc_end


handle_asc$:
	section
**replace field 3 with length of string in field 3
**Save field 3
	lea	field_3(a5),a0
	lea	temp_string4(a5),a1
	qmove.l	#514,d2
	OSBlockMoveData	a0,a1,d2
	lea	field_3(a5),a2
**count length
	qmove.l	#0,d0
	qmove.b	(a2),d0

	lea	field_3(a5),a0
	qmove.l	d0,d6
	bsr	printnum_no_lead_mem
	clr.b	(a0)	*terminate
	lea	field_3(a5),a0
	bsr.l	set
**restore field 3
	lea	field_3(a5),a1
	lea	temp_string4(a5),a0
	qmove.l	#514,d2
	OSBlockMoveData	a0,a1,d2	
	rts_	"handle_asc"
handle_len:
	section
**replace field 3 with length of string in field 3
**Save field 3
	lea	field_3(a5),a0
	lea	temp_string4(a5),a1
	qmove.l	#514,d2
	OSBlockMoveData	a0,a1,d2
	lea	field_3(a5),a2
**count length
	qmoveq	#-1,d0
.count_len:
	inc.l	d0
	tst.b	(a2)+
	bne.s	.count_len

	lea	field_3(a5),a0
	qmove.l	d0,d6
	bsr	printnum_no_lead_mem
	clr.b	(a0)	*terminate
	lea	field_3(a5),a0
	bsr.l	set
**restore field 3
	lea	field_3(a5),a1
	lea	temp_string4(a5),a0
	qmove.l	#514,d2
	OSBlockMoveData	a0,a1,d2

	rts_	"handle_len"

handle_str$:
	push	a0
	bsr	check_field1	*returns string ID (0-25)
	tst.w	d0
	bmi.s	hs_end	*field 1 is bad
	lsl.l	#8,d0	*each string is 256 bytes max
	qpush1	d0
	move.l	internal_strings_h(a5),d0
	OSHLock	d0
	qpop1	d0
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
	qmove.l	a0,dest_string_addr(a5)
**now eval field3
	lea	field_3(a5),a2
	bsr.l	recurs_eval	*in d0
	cmpi.l	#9999999,d0
	ble.s	number_ok
	lea	number_warning(pc),a0
	bsr.l	pass1_error
	bra.s	hs_end
number_ok:
	move.l	a0,a2
	bsr.l	print_long_m	
hs_end:
	pop	a0
	rts_	"handle_str"
handle_bin$:
	push	a0
	bsr	check_field1	*returns string ID (0-25)
	tst.w	d0
	bmi.s	hbs_end	*field 1 is bad
	lsl.l	#8,d0	*each string is 256 bytes max
	qpush1	d0
	move.l	internal_strings_h(a5),d0
	OSHLock	d0
	qpop1	d0
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
	qmove.l	a0,dest_string_addr(a5)
**now eval field3
	lea	field_3(a5),a2
	bsr.l	recurs_eval	*in d0

	qmove.b	#"%",(a0)+
	qmoveq	#31,d1	*bit counter
pb32_loop:
	btst	d1,d0
	beq.s	do_zero
	qmove.b	#"1",(a0)+
	bra.s	done_digit
do_zero:
	qmove.b	#"0",(a0)+
done_digit:
	qdbra	d1,pb32_loop	
hbs_end:
	pop	a0
	rts_	"handle_binstr"
handle_chr$:
	push	a0
	bsr	check_field1	*returns string ID (0-25)
	tst.w	d0
	bmi.s	hcs_end	*field 1 is bad
	lsl.l	#8,d0	*each string is 256 bytes max
	qpush1	d0
	move.l	internal_strings_h(a5),d0
	OSHLock	d0
	qpop1	d0
	move.l	internal_strings_h(a5),a0
	move.l	(a0),a0
	add.l	d0,a0	*Dest string
	qmove.l	a0,dest_string_addr(a5)
**now eval field3
	lea	field_3(a5),a2
	bsr.l	evaluate	*in d0
	
	qmove.b	d0,(a0)	*the character
	cmpi.l	#255,d0
	ble.s	hcs_end
	lea	char_warning(pc),a0
	bsr.l	pass1_warning
hcs_end:
	pop	a0

	rts_	"handle_chr"	
******misc routines
	
check_field1:	
	qmove.l	#0,d0	*default error
	lea	field_1(a5),a0
	qmove.l	(a0),d1
	if PPC
	macs_last
	movei	`temp_reg1,0xff00ffff
	and	r4,r4,`temp_reg1
	macs_first
	else
	andi.l	#0xff00ffff,d1
	endif
	cmpi.l	#$5b00245d,d1	*[x$]
	beq.s	field_1ok
field1_bad:
	lea	field1_error(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
	bra.s	cf1_end
field_1ok:
**get string ID, do is clear already
	qcmove.w	(a0),d0
	andi.l	#0xff,d0
	cmpi.l	#"Z",d0
	ble.s	seems_ok1
	sub.l	#0x20,d0	*try to make upper case
seems_ok1:
	sub.l	#"A",d0
	bmi	field1_bad
	cmpi.l	#25,d0
	bgt.s	field1_bad
cf1_end:
	rts_	"Strings_Check_field_1"
**

	section
printnum_no_lead_mem:	
	cmpi.l	#10000,d6
	bge.s	do_ttm
	cmpi.l	#1000,d6
	bge.s	dt_m
	cmpi.l	#100,d6
	bge.s	dh_m
	cmpi.l	#10,d6
	bge.s	dte_m
	bra.s	du_m
do_ttm	divu	#10000,d6	get tens of thoudsands
	qbsr.s	convert_m	print number of tens of thousands
dt_m	divu	#1000,d6	get thousands
	qbsr.s	convert_m	etc
dh_m	divu	#100,d6
	qbsr.s	convert_m
dte_m	divu	#10,d6
	qbsr.s	convert_m
du_m:	qbsr.s	convert_m
;	clr.b	(a0)
	rts

printnum_mem:	
;	 cmpi.l	#10000,d6
;	 bge.s	 do_ttm
;	 cmpi.l	#1000,d6
;	 bge.s	 dt_m
;	 cmpi.l	#100,d6
;	 bge.s	 dh_m
;	 cmpi.l	#10,d6
;	 bge.s	 dte_m
;	 bra.s	 du_m
;do_ttm	DIVu	 #10000,D6	 GET TENS OF THOUDSANDS
;	 BSR.S	 CONVERT_m	 PRINT NUMBER OF TENS OF THOUSANDS
;dt_m	 DIVu	 #1000,D6	 GET THOUSANDS
;	 BSR.S	 CONVERT_m	 ETC
;	 MOVE.B	#",",(A0)+
;dh_m	 DIVu	 #100,D6
;	 BSR.S	 CONVERT_m
	divu	#10,d6
	qbsr.s	convert_m
	qbsr.s	convert_m
;	clr.b	(a0)
	rts
convert_m:	addi.b	#48,d6	make character	(ascii)
	qmove.b	d6,(a0)+
	clr.w	d6
	swap	d6	*saves an and.l
;	swap	d6
;	andi.l	#$ffff,d6
	addq.l	#1,d1	*inc counter for no_commas
	qrts

**RETURNS THE HOUR IN D0,mins in d1 and secs in d2
get_time:	lea		date_time_rec(pc),a0
			OSReadDateTime	a0,d0		get date/time
			lea		date_time_rec(pc),a0
			qmove.l	(a0),d0		get secs
			qmove.l	d0,d7		raw time
			lea	date_time_rec(pc),a0
			OSGetTime	a0
			lea		date_time_rec(pc),a0
			qcmove.w	6(a0),d0	get hour
			qcmove.w	8(a0),d1
			qcmove.w	10(a0),d2
			rts_	"getdatetime"
date_time_rec:			dc.w	1			year
			dc.w	1			month
			dc.w	1			day
			dc.w	1			hour
			dc.w	1			minute
			dc.w	1			second
			dc.w	1			day of week
			ds.w	2			just in case!

	align
field3_data_error:	cstring	"Oops, you've run out of data to copy",13,"Parameter too big or length of data to short?",13
	align
field3_left_error:	cstring	"Invalid parameter.",13
	align
field3_negative_param:	cstring	"Negative parameter not allowed in string directives."
	align
field3_right_error:	cstring	"Parameter too big for amount of data.",13
	align
string_error:	cstring	"String overflow!"
	align
number_warning:	cstring	"Number too big for str$ directive."
	align
char_warning:	cstring	"WARNING - Character evaluated to greater than 255",13,"Used MOD(255)."
	align
field1_error:	cstring	"Bad string identifier in field 1.",13
	align

	global	handle_equ$,handle_left$,handle_mid$,handle_right$,handle_concat$
	global	handle_asc$,handle_len,handle_str$,handle_chr$,handle_bin$
	global	printnum_no_lead_mem

	extern	pass1_error,evaluate,pass1_warning,set,print_long_m,send_2
	extern	recurs_eval