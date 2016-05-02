
**mods to ifxx for 3.20
**basically if we are defining an if, we add 1 to if_depth, and if we're 
**ending a conditional, we add 1 to if_depth
ifd:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq	ifeq_off
	
	qmove.w	flags(a5),f_save(a5) 	save state of flags
 	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
 	qbset	#5,flags2(a5)	*dont report errors
	qbclr	#6,flags2(a5)	*not defined flag from eval
	bsr	recurs_eval 	*get value of label in a2

 	btst	#6,flags2(a5)	*set z flag to bit (i get confused!)
	bne.s	tis_not	*ie z flag is 0
	
tis:	move.w	f_save(a5),flags(a5)
	qbclr	#5,flags2(a5)
	qbclr	#6,flags2(a5)
	qbset	#0,flags(a5) 	*set assembly bit
	addq.b	#1,if_depth(a5)
ifdef_off:
	rts_	"tis"
	align
tis_not:	move.w	f_save(a5),flags(a5)
	qbclr	#5,flags2(a5)
	qbclr	#6,flags2(a5)
	qbclr	#0,flags(a5)	*clear assembly bit
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)
	addq.b	#1,if_depth(a5)

	bsr	tron_print	*show line as assm is off!
	rts_	"tis_not "
	align
	

**if not defined
ifnd:	
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq	ifeq_off

	qmove.w	flags(a5),f_save(a5) 	save state of flags
 	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
 	qbset	#5,flags2(a5)	*dont report errors
	qbclr	#6,flags2(a5)
	bsr recurs_eval 		*get value of label in a2
 	btst	#6,flags2(a5)	*1=not defined
	bne	tis
	bra.s	tis_not
		
************************************ifc****************************************************
ifc:

	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq	ifeq_off

	lea	field_3(a5),a1
	lea	field_2_new(a5),a2
	lea	field_3_new(a5),a3
	bsr	get_two_strings	*get strings in a2,a3 without quotes
	movem.l	a0/a1,-(sp)
	lea	field_2_new(a5),a0
	lea	field_3_new(a5),a1
	bsr	compare_strings	*compare a2,a3, returns d0=0 for match, -1 else
	movem.l	(sp)+,a0/a1
	tst.w	d0
	bne.s	no_match
	addq.b	#1,if_depth(a5)
	qbset	#0,flags(a5)
	rts		*do nowt, strings match
no_match:
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)
	addq.b	#1,if_depth(a5)

	qbclr	#0,flags(a5)	*no match, assembly off
	bsr	tron_print
	rts_	"ifc"
	align	 
********************************ifnc*********************************************
ifnc:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq	ifeq_off


	lea	field_3(a5),a1
	lea	field_2_new(a5),a2
	lea	field_3_new(a5),a3
	bsr	get_two_strings	*get strings in a2,a3 without quotes
	movem.l	a0/a1,-(sp)
	lea	field_2_new(a5),a0
	lea	field_3_new(a5),a1
	bsr	compare_strings	*compare a2,a3, returns d0=0 for match, -1 else
	movem.l	(sp)+,a0/a1
	tst.w	d0
	beq.s	match
	addq.b	#1,if_depth(a5)

	rts		*do nowt, strings dont match
match:
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)
	addq.b	#1,if_depth(a5)

	qbclr	#0,flags(a5)	*match, assembly off
	bsr	tron_print
	rts_	"ifnc"
	align	 
	

******************************************************************************************
ifne:	
**field 2 is a2
**see if its if 68k or if ppc
	cmpi.w	#"68",(a2)
	beq	if_68k
	qmove.l	(a2),d0
	andi.l	#$ffffff00,d0
	cmpi.l	#$50504300,d0	*"ppc"
	beq	if_ppc

	tst.b	if_scan(a5)	*looking for endif/else?
	bne.s	is_on		*yes
	btst	#0,flags(a5)
	beq.s	ifassm_off
	qmove.w flags(a5),f_save(a5) 	 save state of flags
	qbset #1,flags(a5) 	 *pretend we"re on pass 2 even if we"re not!
	
	bsr recurs_eval 	*get value of label in a2
	qmove.w f_save(a5),flags(a5)
	tst.l d0
	beq.s ifne_eq_z 	*ifne=0
ass_on:
**4.04
	
 qbset #0,flags(a5) 	 *ifne=1 tis true, so set assembly bit
	addq.b	#1,if_depth(a5)

 rts
ifne_eq_z:
**4.04
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)
	bsr	tron_print	
 	qbclr	#0,flags(a5)
is_on:
ifassm_off:
	addq.b	#1,if_depth(a5)
 
	rts_	"ifne"
	
 
endc:
**pf404 change for nested ifs!
**4.04
	tst.b	if_scan(a5)		*coming from an else or if?
	bmi.s	endc_from_else
**subtract before the compare	
	subq.b	#1,if_depth(a5)
	tst.b	if_scan(a5)
	beq.s	no_scan			*not lloking for an endif
	qmove.b	saved_depth(a5),d0
	cmp.b	if_depth(a5),d0
	bne.s	not_endc_scan		*if eq then switch assm on.
	clr.b	if_scan(a5)
no_scan:
	qbset	#0,flags(a5) 	*set assembly flag
not_endc_scan:
;	subq.b	#1,if_depth(a5)

	rts_	"endif"
	
**here we subtract after the compare
endc_from_else:
	tst.b	if_scan(a5)
	beq.s	no_scan1			*not lloking for an endif
	qmove.b	saved_depth(a5),d0
	cmp.b	if_depth(a5),d0
	bne.s	not_endc_scan1		*if eq then switch assm on.
	clr.b	if_scan(a5)
no_scan1:
	qbset	#0,flags(a5) 	*set assembly flag
not_endc_scan1:
	subq.b	#1,if_depth(a5)
	rts_	"endif_from_else"

else:
**v4.04 - we need to change the assembly state for this if depth
	cmpi.b	#-1,if_scan(a5)
	beq.s	skip_else
	cmpi.b	#1,if_scan(a5)
	beq.s	is_set
	bchg	#0,flags(a5)	*reverse assembly
	btst	#0,flags(a5)
	bne.s	skip_else	*assm not turned off
	qmove.b	if_depth(a5),saved_depth(a5)	*assm is turned off
	qmove.b	#-1,if_scan(a5)
skip_else:
	rts		*note - no change to dep
is_set:
	subq.b	#1,if_depth(a5)
	qmove.b	if_depth(a5),d0
	cmp.b	saved_depth(a5),d0
	bne.s	carry_on1	
	qbset	#0,flags(a5)	*assm on
	clr.b	if_scan(a5)
carry_on1:
	addq.b	#1,if_depth(a5)
	rts_	"else"
	align

*************************************
if_68k:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes
	btst	#0,flags(a5)
	beq	ifassm_off

	btst	#0,ppc_flags1(a5)	*will be zero if 68k
	beq	ass_on		*yes, 68k
	bra	ifne_eq_z	*no, not 68k
	rts_	"if_68k"
if_ppc:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes
	btst	#0,flags(a5)
	beq	ifassm_off

	btst	#0,ppc_flags1(a5)
	bne	ass_on		*yes, ppc
	bra	ifne_eq_z	*no, not ppc
	rts_	"if_ppc"
			
ifeq:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq.s	ifeq_off

 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we"re on pass 2 even if we"re not!
 bsr recurs_eval 		*get value of label in a4
 qmove.w f_save(a5),flags(a5)
 tst.l d0
 beq.s if_eq_z 		*if x=0
 qbclr #0,flags(a5) 	 *tis not true, so set assembly bit
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)
	addq.b	#1,if_depth(a5)
 	bsr	tron_print
	rts
if_eq_z:
 qbset #0,flags(a5) 	 *set assembly bit
	addq.b	#1,if_depth(a5)
	rts_	"if_eq"
	align
	
ifgt:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq.s	ifeq_off

 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we"re on pass 2 even if we"re not!
 bsr recurs_eval 		*get value of label in a4
 qmove.w f_save(a5),flags(a5)
 tst.l d0
 ble.s if_eq_le 	*if x<=0
 qbset #0,flags(a5) 	 *greater, so set assembly bit
ifeq_off:
	addq.b	#1,if_depth(a5)

 rts
	
if_eq_le:
 qbclr #0,flags(a5) 	 *clear assembly bit
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)
	addq.b	#1,if_depth(a5)

 bsr	tron_print
 rts_	"if_gt"
	align
	
ifge:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq	ifeq_off


 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we're on pass 2 even if we"re not!
 bsr recurs_eval 		*get value of label in a4
 qmove.w f_save(a5),flags(a5)
 tst.l d0
 blt.s if_eq_l 		*if x<0
 qbset #0,flags(a5) 	 *tis true, so set assembly bit
	addq.b	#1,if_depth(a5)

 clr.l	d0
 rts
if_eq_l:
 qbclr #0,flags(a5) 	 *clear assembly bit
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)
	addq.b	#1,if_depth(a5)

 	bsr	tron_print
ifge_off:
 rts_	"if_ge"
	align
iflt:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq	ifeq_off

 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we"re on pass 2 even if we"re not!
 bsr recurs_eval 		*get value of label in a4
 qmove.w f_save(a5),flags(a5)
 tst.l d0
 bge.s if_eq_ge 		*if x>=0
	addq.b	#1,if_depth(a5)

 qbset #0,flags(a5) 	 *tis true, so set assembly bit
 rts
if_eq_ge:
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)
	addq.b	#1,if_depth(a5)

 qbclr #0,flags(a5) 	 *clear assembly bit
 	bsr	tron_print
iflt_off:
 clr.l	d0
 rts_	"if_lt"
	align
	
ifle:
	tst.b	if_scan(a5)	*looking for endif/else?
	bne	is_on		*yes

	btst	#0,flags(a5)
	beq	ifeq_off

 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we"re on pass 2 even if we"re not!
 bsr recurs_eval 	*get value of label in a4
 qmove.w f_save(a5),flags(a5)
 tst.l d0
 bgt.s if_eq_gt		*if x>0
	addq.b	#1,if_depth(a5)

 qbset #0,flags(a5) 	 *tis true, so set assembly bit
 rts
if_eq_gt:
	qmove.b	if_depth(a5),saved_depth(a5)
	qmove.b	#1,if_scan(a5)	; rp 14/9/97  was -1, obviously (!?) a bug in the
				; implementation of the algorithm in this if statement
	addq.b	#1,if_depth(a5)

 qbclr #0,flags(a5) 	 *clear assembly bit
 bsr.s	tron_print
ifle_off:
 rts_	"if_le"
	align
	
	
tron:	qbset	#1,flags6(a5)
	qmove.w	#6,d0
;	bsr.l	play_voice
	rts
troff:	qbclr	#1,flags6(a5)
	qmove.w	#5,d0
;	bsr.l	play_voice
	rts

**tron print is used to print the directive after assm is switched off
*8tron in the pass loop wont do it
tron_print:	btst	#1,flags(a5)
	bne.s	no_tron	pass 2
	btst	#1,flags6(a5)
	beq.s	no_tron	troff
diag_fields:	save_all
	lea	field_1(a5),a0	print fields
	bsr.l	printit
	bsr.l	print_space
	lea	field_2(a5),a0
	bsr.l	printit
	bsr.l	print_space
	lea	field_3(a5),a0
	bsr.l	printit
	lea	ass_off(pc),a0
	bsr.l	printit	condition failed
	bsr.l	printcr
	restore_all
no_tron:	rts

requ:
**modified for v4 (naturally enough)
**requ entries are:
**28 bytes name, bytes 28 and 29 upper byte=address reg, lower byte=data
**30 and 31 are wasted :-(	
**syntax:
**name:	requ	rn
**check size
	qbclr	#2,flags6(a5)	defd already flag
	qmove.w	requ_names_count(a5),d0
	cmpi.w	#reg_names/32,d0	in fant-equs
	bge	reg_names_full
	lea	field_1(a5),a2

	cmp.b	#".",(a2)	 	 ; ***** llbls-rp200797
	beq	requ_local_error	 ; ***** llbls-rp200797
	
	
	bsr	search_requ	needs a1->table returns d0=pos or -1
**if it was found, then we modify the entry
**if it wasnt found, we make a new entry
	bge.s	requ_defd
	
requ_not_defd:	lea	requ_buff(pc),a2	the name padded
	move.l	requ_names_h(a5),a1
	move.l	(a1),a1
	qcmove.w	requ_names_count(a5),d0
;	ext.l	d0
	lsl.l	#5,d0	times 32
	add.l	d0,a1	point to right place
	bra.s	do_requ_insert	

requ_defd:	qbset	#2,flags6(a5)	set flag
	lea	requ_buff(pc),a2	the name padded
	move.l	requ_names_h(a5),a1
	move.l	(a1),a1
	lsl.l	#5,d0	times 32
	add.l	d0,a1	point to right place

do_requ_insert:
	lea	field_3(a5),a3	see if d or a
	cmpi.b	#"D",(a3)
	beq.s	do_data
	cmpi.b	#"A",(a3)
	beq.s	do_addr
	cmpi.b	#"r",(a3)
	beq.s	do_ppc_reg
	cmpi.b	#"R",(a3)
	beq.s	do_ppc_reg
	cmpi.b	#"F",(a3)
	beq	do_ppc_freg
	cmpi.b	#"f",(a3)
	beq.s	do_ppc_freg
requ_err:
	lea	requ_text(pc),a0
	bsr	pass1_error
	bra	no_requ
do_data:	move.b	1(a3),d0
	subi.b	#"0",d0
	bmi.s	requ_err
	cmpi.b	#7,d0
	bgt.s	requ_err
	addq.b	#1,d0	so regs run 1 to 8
	qmove.b	d0,29(a2)	set data byte
	bra	insert_requ
do_addr:	move.b	1(a3),d0
	subi.b	#"0",d0
	bmi.s	requ_err
	cmpi.b	#7,d0
	bgt.s	requ_err
	addq.b	#1,d0	so regs run 1 to 8
	qmove.b	d0,28(a2)	set addr byte
	bra.s	insert_requ
**new for v4
do_ppc_reg:
	qmove.b	1(a3),d0
	cmpi.b	#"0",d0
	blt	requ_err
	cmpi.b	#"9",d0
	bgt	requ_err
	sub.b	#"0",d0	*make real number
**now see if next char is a digit
	qmove.b	2(a3),d1
	cmpi.b	#"0",d1
	blt.s	end_ppc_reg
	cmpi.b	#"9",d1
	bgt.s	end_ppc_reg
	sub.b	#"0",d1	*make real number
	extb.l	d0
	muls	#10,d0
	add.b	d1,d0	*the full number
end_ppc_reg:
	add.b	#16,d0	*so reg runs 16->48
	qmove.b	d0,28(a2)	set addr byte for gprs
	bra.s	insert_requ
do_ppc_freg:
	qmove.l	#0,d0
	qmove.b	1(a3),d0
	cmpi.b	#"0",d0
	blt	requ_err
	cmpi.b	#"9",d0
	bgt	requ_err
	sub.b	#"0",d0	*make real number
**now see if next char is a digit
	qmove.b	2(a3),d1
	cmpi.b	#"0",d1
	blt.s	end_ppc_freg
	cmpi.b	#"9",d1
	bgt.s	end_ppc_freg
	sub.b	#"0",d1	*make real number
	muls	#10,d0
	add.b	d1,d0	*the full number
end_ppc_freg:
	add.b	#16,d0	*so freg runs 16->48
	qmove.b	d0,29(a2)	set data byte for fprs

insert_requ:	qmoveq	#7,d0
ir_loop:	qmove.l	(a2)+,(a1)+
	dbra	d0,ir_loop
	btst	#2,flags6(a5)
	bne.s	no_requ	dont inc count - it was defd alredy
	inc.w	requ_names_count(a5)
no_requ:	rts

reg_names_full:
	push	a0
	lea	rn_full_text(pc),a0
	bsr	pass1_error
	qbset	#4,flags2(a5)	set fatal flag
	pop	a0
	rts

; ***** llbls-rp200797
requ_local_error:
	push	a0
	lea	requ_local_text(pc),a0
	bsr	pass1_error
;;;;not fatal??	bset	#4,flags2(a5)	set fatal flag
	pop	a0
	rts
; ***** llbls-rp200797	      
		
		
**search requ retruns d0=pos or -1 if not found
**needs a2 pointing to name to search for
**first expand name to 28 bytes in a buffer
search_requ:
	qmove.l	#0,d0
	lea	requ_buff(pc),a3
	qmove.l	d0,0(a3)	make sure buffer is empty
	qmove.l	d0,4(a3)
	qmove.l	d0,8(a3)
	qmove.l	d0,12(a3)
	qmove.l	d0,16(a3)
	qmove.l	d0,20(a3)
	qmove.l	d0,24(a3)
	qmove.l	d0,28(a3)
;	lea	requ_buff(pc),a3
	qmoveq	#27,d0	count
copy_requ:	subq	#1,d0
	beq.s	cr_end
	move.b	(a2)+,(a3)+	copy name to empty buffer
	bne.s	copy_requ
cr_end:	lea	requ_buff(pc),a2	done
	
	move.l	requ_names_h(a5),a1	handle
	move.l	(a1),a1		points to list of names
	
	move.w	requ_names_count(a5),d1	how many counter
	beq.s	requ_not_found		noone, so not found.
	qmoveq.l	#0,d0	position counter

find_requ:	lea	requ_buff(pc),a2	reset
	qmoveq.l	#0,d7	flag
	cmpm.l	(a2)+,(a1)+	well this is different....
	beq.s	fr1
	qmoveq	#-1,d7
fr1:	cmpm.l	(a2)+,(a1)+
	beq.s	fr2
	qmoveq	#-1,d7
fr2:	cmpm.l	(a2)+,(a1)+
	beq.s	fr3
	qmoveq	#-1,d7
fr3:	cmpm.l	(a2)+,(a1)+
	beq.s	fr4
	qmoveq	#-1,d7
fr4:	cmpm.l	(a2)+,(a1)+
	beq.s	fr5
	qmoveq	#-1,d7
fr5:	cmpm.l	(a2)+,(a1)+
	beq.s	fr6
	qmoveq	#-1,d7
fr6:	cmpm.l	(a2)+,(a1)+
	beq.s	fr7
	qmoveq	#-1,d7
fr7:	tst.w	d7
	beq.s	got_requ
		
	addq.l	#4,a1	skip data
	addq.l	#1,d0	inc pos counter
	subq.w	#1,d1	how many counter
	bne.s	find_requ	keep going
	
requ_not_found:	moveq	#-1,d0
got_requ:	rts_	"register_equate"

**v3.6 onwards
**these folowing expect:
**	title	"string"	note string in quotes!
do_title:	btst	#1,flags(a5)	pass 2 if set
	beq.s	skip_title	only do on pass 2
	move.w	title_length(a5),d0
	cmpi.w	#398,d0
	bgt.s	skip_title	max length
	lea	field_3(a5),a1	get string
	lea	link_title(pc),a2	where
	add.w	d0,a2
copy_title:	move.b	(a1)+,(a2)+
	beq.s	end_ct
	inc.w	d0
	cmpi.w	#398,d0
	bne.s	copy_title
end_ct:	move.b	#13,-1(a2)	cr
	clr.b	(a2)
	inc.w	d0
	move.w	d0,title_length(a5)	update size
skip_title:	rts_	"title   "
	align
	
do_input:	btst	#1,flags(a5)
	beq.s	skip_title
	move.w	input_length(a5),d0
	cmpi.w	#322,d0
	bgt.s	skip_title	max length
	lea	field_3(a5),a1	get string
	lea	input(pc),a2	where
	add.w	d0,a2
copy_input:	move.b	(a1)+,(a2)+
	beq.s	end_ci
	inc.w	d0
	cmpi.w	#322,d0
	bne.s	copy_input
end_ci:	move.b	#13,-1(a2)	cr
	clr.b	(a2)
	inc.w	d0
	move.w	d0,input_length(a5)	update size
	rts_	"input   "
	align
	
do_output:	btst	#1,flags(a5)
	beq.s	skip_title	pass 1
	move.w	output_length(a5),d0
	cmpi.w	#298,d0
	bgt.s	skip_title	max length
	lea	field_3(a5),a1	get string
	lea	output(pc),a2	where
	add.w	d0,a2
copy_output:	move.b	(a1)+,(a2)+
	beq.s	end_co
	inc.w	d0
	cmpi.w	#298,d0
	bne.s	copy_output
end_co:	move.b	#13,-1(a2)	cr
	clr.b	(a2)
	inc.w	d0
	move.w	d0,output_length(a5)	update size
	rts_	"output"
	align

accumulate_globoff:
	qmove.l	globoff_counter(a5),d0
	neg.l	d0
	cmp.l	globoff_accumulator(a5),d0
	bgt.s	up_gaccum
	rts
up_gaccum:
	move.l	d0,globoff_accumulator(a5)
	rts_	"accum_globoff"

**a5 global offsets 
*8copied from rs directives modded for globoff_counter and -ve offsets
**note that go directives predecrement the offset counter!
go_reset:
	tst.l	globisrs_flag(a5)	*ppc?
	bne.l	rs_reset		*in ppc, globoff is rs!
	bsr	accumulate_globoff
	clr.l	globoff_counter(a5)
	clr.l	d0
	rts_	"go_reset"	that was easy!
	align
	
go_byte:
	tst.l	globisrs_flag(a5)	*ppc?
	bne.l	rs_byte		*in ppc, globoff is rs!
	bsr	test_for_hash
	tst.w	d0
	bmi	go_end
	
	qmove.w	flags(a5),f_save(a5) 	save state of flags
	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	bsr	recurs_eval 	*get value of label in a2
	qmove.w	f_save(a5),flags(a5)
**now insert rs_counter, with this label in equates table
	ext.l	d0	
	sub.l	d0,globoff_counter(a5)	update go counter
	bsr	insert_equ
go_end:
	rts_	"go_byte "
	align
test_for_hash:
	clr.l	d0
	cmpi.b	#"#",(a2)
	bne.s	not_hash
	lea	hash_err1(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
not_hash:
	rts_	"test_for_hash"
go_word:
	tst.l	globisrs_flag(a5)	*ppc?
;	btst	#0,ppc_flags1(a5)	*ppc?
	bne.l	ppc_rs_word		*in ppc globoff is rs!
	bsr	test_for_hash
	tst.w	d0
	bmi	go_end
	
	qmove.w	flags(a5),f_save(a5) 	save state of flags
	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	bsr	recurs_eval 	*get value of label in a2
	qmove.w	f_save(a5),flags(a5)
	ext.l	d0	
	lsl.l	#1,d0	times 2 for words
	qmove.l	globoff_counter(a5),d1	v2.2
	btst	#0,d1	check for even
	beq.s	size_word_ok
	subq.l	#1,d1	make even
size_word_ok:	sub.l	d0,d1	update rs counter
	move.l	d1,globoff_counter(a5)
	bsr.s	insert_equ
	rts_	"go_word"
	align
	
go_long:
	tst.l	globisrs_flag(a5)	*ppc?
;	btst	#0,ppc_flags1(a5)
	bne.l	ppc_rs_long	*in ppc globoff is same as rs!
	bsr	test_for_hash
	tst.w	d0
	bmi	go_end
		
	qmove.w	flags(a5),f_save(a5) 	save state of flags
	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	bsr	recurs_eval 	*get value of label in a2
	qmove.w	f_save(a5),flags(a5)
**now insert globoff_counter, with this label in equates table
	ext.l	d0	
	lsl.l	#2,d0	times 4 for longs

	qmove.l	globoff_counter(a5),d1
**change in 5.1m - make longs quad aligned!
	qmove.l	d1,d6
	andi.l	#%11,d6
	beq.s	size_long_ok
	sub.l	d6,d1	*make quad aligned
;	btst	#0,d1	check for even v2.2
;	beq.s	size_long_ok
;	subq.l	#1,d1	make rs even
size_long_ok:	sub.l	d0,d1	update rs counter
	qmove.l	d1,globoff_counter(a5)
	bsr.s	insert_equ
	rts_	"go_long"
	align

****insert equ inserts a simulated equ for go directives into equ table
**copy of insert_equ in directives.s modded for globoof_counter
insert_equ:
	lea 	field_1(a5),a3
;	move.l	labels(a5),a4	labels list
;	bsr	search_labp2	*was lab
;	debug

	cmp.b	#".",(a3)		; ***** llbls-rp200797
	beq.s	globoff_local_error	; ***** llbls-rp200797

	
 	qmove.l	labels(a5),tree_strings_ptr(a5)
 	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search

	tst.w	d0
	bmi	not_defined
	bsr.l	defined_error
	rts
not_defined:
	lea 	field_1(a5),a3	      
 	qmove.l	equates(a5),tree_strings_ptr(a5)
 	move.l	equates_tree(a5),a2
	bsr.l	equ_tree_insert
	tst.w	d0
	bge	not_defined1
	bsr.l	defined_error
	rts
not_defined1:
	
;	movea.l	equates(a5),a4 	*equates list
;	bsr	search_labp2 	*see if it is defined already returns d0
;	tst.w	d0 	*-1=not found else position
;	bge	defined_error	external
 
;	movea.l equates(a5),a4
;	adda.l eq_pos(a5),a4 	*lt pos is inc"d by 32 for every label
;copy_equ_to_tab_rs: 	 *now copy the label into the table
;	move.b (a3)+,(a4)+
;	bne.s copy_equ_to_tab_rs
 
	addq.l #1,equ_num(a5) 	*inc total number of lables
	movea.l eq_val(a5),a4 	*now save its address
	qmove.l eq_pos(a5),d0
	lsr.l #3,d0
	add.l d0,a4 		*point to right place 32/8=4 (longword)

	qmove.l globoff_counter(a5),0(a4) 	 *store value of rs_counter
	addi.l #32,eq_pos(a5) 	*ready for next label
	rts_	"ins_equg"
	align
	
; ***** llbls-rp200797	      
globoff_local_error:
	qmove.l a0,-(sp) ;	   *save source position
	lea globoff_local_text(pc),a0	*print defined twice
	bsr	pass1_error
	qmove.l (sp)+,a0
	rts

*************************************************************************************
requ_buff:	DS.B	36	BUFFER FOR SEARCH
requ_text:	DC.B	"Unrecognised register.",13,0
rn_full_text:	DC.B	"**FATAL** Out of space for REQUs - allocate more memory to "
	DC.B	"Anvil - but congratulations all the same...",13,0
ass_off:	dc.b	"  <- Condition not met.",0
	align


; ***** LLBLS-RP200797
globoff_local_text:	 cstring "Cannot globoff local label"
			align	
			
requ_local_text: cstring "Cannot requ local label"
		align
; ***** LLBLS-RP200797

hash_err1:	cstring	"Illegal hash character. Hash is not used with globoff."
	align
	global	accumulate_globoff
	public	ifd,ifnd,ifc,ifnc,ifne,ifeq,ifgt,ifge,iflt,ifle,endc
	public	else,tron,troff,requ,search_requ
	public	do_title,do_input,do_output,diag_fields
	public	go_reset,go_byte,go_word,go_long
	
	extern	recurs_eval	*the evaluator
	extern	compare_strings	*for ifc and ifnc
	extern	get_two_strings
	extern	printit,print_space,printcr,pass1_error
	extern_data	link_title,input,output	*the strings
	extern	defined_error,search_lab,search_labp2,play_voice
	extern	rs_byte,ppc_rs_word,ppc_rs_long,ppc_rs_half
	extern	lab_tree_search,equ_tree_insert
	extern	rs_reset