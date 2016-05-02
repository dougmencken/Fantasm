
**********************************************************************
*MODULE:	DIRECTIVE V2.20	(SEE ALSO DIRECTIVES_2.S)      	*
*DATE:	190194			     *
*PROGRAMMER:	S. BALL			     *
*FANT REL VER:  4.00 		     *
*LIGHTSOFT V:	2.4			     *
*VERSION DESCRIPTIONS			     *
*2.0 240794	CONDITIONAL ASSEMBLY DIRECTIVES		     *
*	IFGT,IFGE,IFLT,IFLE ADDED		     *
*2.1 240794     RS DIRECTIVES.			     *
*2.2 240794	MOD TO RS SO WORDS AND LONGS ARE WORD ALIGNED!	     *
*2.3 250794	JUMP TABLE FOR DIRECTIVES		     *
*2.4 150395	oops, missed a few - however 2.4 is double extern    *
*RELEASE VERSION 1.01			     *
*1	INCBIN DIRECTIVE INCLUDED.		     *
*DESCRIPTION:	DIRECTIVE SEARCHES THE LINE HELD IN A2 FOR A DIRECTIV*
*	IF FOUND IT ACTS ACCORDINGLY AND SETS D0=0 ELSE      *
*	D0=-1			     *
**********************************************************************

***DIRECTIVE ACTS ON DIRECTIVES OR IF NOT FOUND RETURNS D0=-1
***TO TELL US IT WASNT FOUND
***ALSO RETURNS A4 POINTING AT THE INSTRUCTION

***BIG NOTE - NEVER EVER DEFINE ANOTHER DIRECTIVE STARTING WITH "EQ"!!!!!!!!!*******

directive:
	qbset	#4,ppc_flags1(a5)	*we are doing a directive
	qmove.l	a0,-(sp) 	*save the source position
	qmove.l	a1,-(sp) 	*save it because i want to?
	lea	field_2(a5),a4
	lea	field_3(a5),a2
;	move.w	0(a4),d1
	move.l	0(a4),d1	*v4
	beq	directive_skip	*no field 2!
	cmpi.l	#"EQU$",d1
	beq.s	skip_equ_check
	cmpi.l	#"equ$",d1
	beq.s	skip_equ_check

	andi.l	#$FFFFFF00,d1	*V4

;	CMPI.W	#"EQ",D1
	cmpi.l	#$45515500,d1	*V4	"EQU"
	beq	directive_skip	*it was an equate - weve done them
	cmpi.l	#$65717500,d1	*v4 "equ"
	beq	directive_skip
skip_equ_check:
	swap	d1		*v4
	lsr.l	#8,d1 		*get the first char
	cmpi.b	#"*",d1 	*tabbed comment line?
	beq	directive_skip
**because off the change to directives searching in 5.1 the Debug macro is no longer being taken!
**hence we need to specifically check for this macro name and skip directives if so
	cmpi.l	#"Debu",(a4)
	bne.s	not_debug_frig
	cmpi.b	#"g",4(a4)
	bne.s	not_debug_frig
	cmpi.b	#0,5(a4)
	beq	directive_no	*Is Debug - note the case - and hence is not a directive
not_debug_frig:
	lea	directives_byte(pc),a1
	lea	directives_full(pc),a6
	bsr	dir_search_quick
**Block commented out for 5.1a4
;	tst.w	d0
;	bge.s	got_dir1	*found in upper case table	
;	lea	field_2(a5),a4
;	lea	directives_lower(pc),a1 	*point to list of directives
;	bsr	dir_search 	*search a1 for a4 returns position in d0 or -1
	tst.w	d0 
 	bmi	directive_no 	*-ve=not found

got_dir1:
	ext.l	d0	no need for error checking
***now we branch to the right routine to handle it
	if PPC
	macs_last

	lwz	r21,[t]directive_table(rtoc)
	slwi	r4,r3,6	*times 64
	add	r21,r4,r21
	macs_first
	else
	lea	directive_table(pc),a1
	move.l	d0,d1
	lsl.l	#3,d1	get address of routine
	add.l	d1,a1
	endif
**IF ASSEMBLY IS OFF, WE ONLY CHECK FOR ENDC AND ELSE 
**V4.04 and ifs
**IF directives is off, we only check for
;	 tst.b	 directives_on(A5)	 *1 if so
;	 bne.s	 not_directive	 *directives are on
;**Directives are off, so we're only interested in directives_on
;	 cmpi.w	#107,d0		 *if not directives_on
;	 beq	 not_directive	 *then SKIP IT CAUSE ASS IS OFF
;	 cmpi.w	#46,d0		 *tron
;	 beq	 not_directive
;	 cmpi.w	#47,d0		 *troff
;	 beq	 not_directive
;
;	 bra	 directive_skip
;not_directive:
	btst	#0,flags(a5)
	bne.s	ass_on	*assemble on
**here assembly is off, so we're only interested in endc and else - v3.20
	cmpi.w	#16,d0	endc?	was 16
	beq.s	ass_on	yes do it
	cmpi.w	#17,d0	endif?
	beq.s	ass_on
	
	cmpi.w	#45,d0	else?	was 44
	beq.s	ass_on	do else
	cmpi.w	#14,d0	*ifeq
	beq.s	ass_on

	cmpi.w	#15,d0	*ifne
	beq.s	ass_on
	cmpi.w	#18,d0	*etc
	beq.s	ass_on
	cmpi.w	#19,d0
	beq.s	ass_on
	cmpi.w	#20,d0
	beq.s	ass_on
	cmpi.w	#21,d0
	beq.s	ass_on
	cmpi.w	#32,d0
	beq.s	ass_on
	cmpi.w	#33,d0
	beq.s	ass_on
	cmpi.w	#35,d0
	beq.s	ass_on
	cmpi.w	#36,d0
	beq.s	ass_on
	cmpi.w	#64,d0	*if?
	beq.s	ass_on
	bra.s	directive_skip	else skip it cause ass is off
	
ass_on:	btst	#2,flags2(a5)	ignoring mac def?
	beq.s	mac_ok	no, do directive
	cmpi.w	#12,d0	endm?
	bne.s	directive_skip
mac_ok:
	if PPC
	macs_last

	mtctr	r21	*where we go to
	bl	here1
here1:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else
	jsr	(a1)	assemble this directive
	endif
directive_skip:	
	qmove.l (sp)+,a1
	qmove.l (sp)+,a0
	clr.l	d0	ok, we handled it
	rts
directive_no:
 qmove.l (sp)+,a1
 qmove.l (sp)+,a0
 moveq	#-1,d0	not a directive
 rts_	"directive"
	align
**************************************************************************
**********************FAIL DIRECTIVE**************************************
fail:
	lea	fail_text(pc),a0	fail string
	bsr	pass1_error
	lea	field_3(a5),a0
	tst.b	(a0)
	beq.s	no_message
	cmpi.b	#$22,(a0)
	bne.s	fail_quotes
no_message:
	qbset	#4,flags2(a5)	*fatal error
	rts
fail_quotes:
	lea	quotes_expected(pc),a0
	bsr	printit
	qbset	#4,flags2(a5)
	rts
		
*******************repeat directive***************************************
repeat:	btst	#3,flags2(a5)	*in a repeat already?
	bne.s	repeat_err	*yes
	move.l	a0,repeat_addr(a5)	*save source pos
	qbset	#3,flags2(a5)	*set flag
	rts
repeat_err:	lea	rep_err_1(pc),a0
	bsr	pass1_error
	qbset	#4,flags2(a5)	*fatal error flag!
	rts_	"repeat  "
	align
*******************UNTIL_GT DIRECTIVE*************************************
**FIELD 3 IN A2
until_gt:	btst	#3,flags2(a5)	*in repeat loop?
	beq.s	until_err	*no!
	bsr	recurs_eval	*eval a2
	tst.l	d0
	bgt.s	gt_failed	*evald to le
	move.l	repeat_addr(a5),12(sp)	*text addr on stack
	rts
gt_failed:	qbclr	#3,flags2(a5)	*clear repeat flag	
	rts		*carry on with source code
until_err:	lea	until_err_1(pc),a0
	bsr	pass1_error
	qbset	#4,flags2(a5)	*fatal error*
	rts_	"until_gt"
	align
*******************until_ge directive*************************************
**field 3 in a2
until_ge:	btst	#3,flags2(a5)	*in repeat loop?
	beq	until_err	*no!
	bsr	recurs_eval	*eval a2
	tst.l	d0
	bge.s	ge_failed	*evald to le
	qmove.l	repeat_addr(a5),12(sp)	*text addr on stack
	rts
ge_failed:	qbclr	#3,flags2(a5)	*clear repeat flag	
	rts_	"until_ge"
	align

*******************until_eq directive*************************************
**field 3 in a2
until_eq:	btst	#3,flags2(a5)	*in repeat loop?
	beq	until_err	*no!
	bsr	recurs_eval	*eval a2
	tst.l	d0
	beq.s	eq_failed	*evald to le
	qmove.l	repeat_addr(a5),12(sp)	*text addr on stack
	rts
eq_failed:	qbclr	#3,flags2(a5)	*clear repeat flag	
	rts_	"until_eq"
	align

*******************until_ne directive*************************************
**field 3 in a2
until_ne:	btst	#3,flags2(a5)	*in repeat loop?
	beq	until_err	*no!
	bsr	recurs_eval	*eval a2
	tst.l	d0
	bne.s	ne_failed	*evald to le
	qmove.l	repeat_addr(a5),12(sp)	*text addr on stack
	rts
ne_failed:	qbclr	#3,flags2(a5)	*clear repeat flag	
	rts_	"until_ne"
	align
	
*******************UNTIL_LT DIRECTIVE*************************************
**field 3 in a2
until_lt:	btst	#3,flags2(a5)	*in repeat loop?
	beq	until_err	*no!
	bsr	recurs_eval	*eval a2
	tst.l	d0
	blt.s	lt_failed	*evald to le
	qmove.l	repeat_addr(a5),12(sp)	*text addr on stack
	rts
lt_failed:	qbclr	#3,flags2(a5)	*clear repeat flag	
	rts_	"until_lt"
	align

*******************until_le directive*************************************
**field 3 in a2
until_le:	btst	#3,flags2(a5)	*in repeat loop?
	beq	until_err	*no!
	bsr	recurs_eval	*eval a2
	tst.l	d0
	ble.s	le_failed	*evald to le
	qmove.l	repeat_addr(a5),12(sp)	*text addr on stack
	rts
le_failed:	qbclr	#3,flags2(a5)	*clear repeat flag	
	rts_	"until_le"


******************set directive*******************************************
**called from pass 1 in labels and pass 2 as a directive
set:
	lea	field_1(a5),a3
	tst.b	(a3)
	beq	set_lab_err

	bsr.l	test_for_locals	; llbls-rp060997 - rob just do 'em
	;cmp.b	#".",(a3)	; llbls-rp200797
	;beq	set_local_err	; llbls-rp200797

	
	lea	field_2(a5),a2
*8first make sure label isnt defined already
 	qmove.l	labels(a5),tree_strings_ptr(a5)
 	qmove.l	labels_tree(a5),a2
	bsr.l	lab_tree_search

	tst.w	d0

;	move.l	labels(a5),a4 	*labels live here
;	bsr	search_labp2 	  *see if it is defined already returns d0 (was lab)
;	tst.w	d0 	*-1=not found else position
	bge	set_err_1	*found!

find_label:
 	qmove.l	equates(a5),tree_strings_ptr(a5)
 	move.l	equates_tree(a5),a2
	bsr.l	equ_tree_search
	tst.w	d0
	bge.s	got_in_equates	*defined in equates

;	move.l	equates(a5),a4	search equates
;	bsr	search_labp2
;	tst.w	d0
;	bge.s	got_in_equates

 	qmove.l	equates(a5),tree_strings_ptr(a5)
 	move.l	equates_tree(a5),a2
	bsr.l	equ_tree_insert

	move.l equates(a5),a2
	add.l eq_pos(a5),a2 	*eq_pos is inc"d by 32 for every label
;	move.l	a4,a2	*save pos	v3.20
;copy_set_to_tab: 	 	 *now copy the label into the table
;	move.b (a3)+,(a4)+
;	bne.s copy_set_to_tab
 	qmove.b	#-1,31(a2)	*its a set!
 	
	addq.l #1,equ_num(a5) 	*inc total number of lables
	qmove.l eq_val(a5),a4 	 *base address of labels values
	qmove.l eq_pos(a5),d0 	 *position/8=right place for long word 
	lsr.l #2,d0		*5.1 - was 3
	clr.l	0(a4,d0.l) 	*set to zero
	addi.l #32,eq_pos(a5) 	*ready for next label
	lea	field_1(a5),a3	*reset field_1
	bsr.l	test_for_locals	; llbls  rp 14/9/97  make sure we actually looking at local
				; pre-pended label text

	bra.s	find_label	*now do search again

got_in_equates:	qmove.l	d0,-(sp)	*save position of label
	lea	field_3(a5),a2	recurs_eval field 3
	bsr	recurs_eval
	qmove.l	d0,d1
	qmove.l	(sp)+,d0
	qmove.l	eq_val(a5),a4	label values table
*	lsl.l	#2,d0	times 4 for long word acces to value table	
**LXT CHANGE
	qpush1	d0
	lsl.l	#2,d0
	qmove.l	d1,(a4,d0.l)
	qpop1	d0
**
;	move.l	d1,0(a4,d0.l*4)	store new value for label
**check for tron
	btst	#0,flags(a5)
	beq	no_tron	ass off
	btst	#1,flags6(a5)	tron
	beq.s	no_tron
	save_all
	qmove.l	d1,-(sp)
**print " = value"
	lea	set_text(pc),a0
	bsr.l	printit
	move.l	(sp)+,d0
	bsr.l	printnum
	lea	d_crtext(pc),a0
	bsr.l	printit
	restore_all
no_tron:
**end check for tron
	rts_	"set"
set_err_1:	lea	set_error(pc),a0
	bsr	pass1_error
	rts_	"set_err_1"
	
set_lab_err:
	lea	set_error1(pc),a0
	bsr	pass1_error
	rts_	"set_lab_err"
;; ******** llbls-rp200797
;; old code from when set could not be locals,,,,,,,,,,
;set_local_err:
;	lea	set_error2(pc),a0
;	bsr	pass1_error
;	rts_	"set_lab_err"
;set_error2:
;	cstring	"local label cannot be set!",13
;	align
;; ******** llbls-rp200797	 

******************incbin directive****************************************
incbin:	movem.l	a0/a1/a2/a3/a4,-(sp)
;	 lea	 field_3(a5),a0	point to file name
;	 lea	 inc_f_name(pc),a1	 copy name to inc-fname
;	 addq.l	#1,a1	 *make space for byte count ;-)
;	 moveq	 #-1,d1	*counter
;copy_name_fe:
;	 addq.l	#1,d1	  
;	 move.b	(a0)+,(a1)+	in case of error
;	 bne.s	 copy_name_fe
;
;	 lea	 field_3(a5),a0	reset name pointer
;	 movea.l	code_buffer(a5),long_var(a5)
;	 lea	 inc_f_name(pc),a1	  
;	 move.b	d1,(a1)	*store pascal byte count
;	 lea	 incbins_fsspec(a5),a0	 *read from incbins folder
;	 bsr	 make_temp_fsspec
;	 lea	 temp_fsspec(a5),a0
;	 bsr	 readit	*read binary into code buffer
;	 tst.l	 d0	error on reading bin file?
;	 bmi.s	 didnt_read	yep
;	 add.l	 d0,pc(a5)	 add size to pc
;	 add.l	 d0,code_buffer(a5)	inc buffer index
;	bra.s	incbin_end
didnt_read:	lea	incbin_error_t(pc),a0
	bsr	pass1_error	report on pass 2
	qbset	#4,flags2(a5)	*set fatal error flag
incbin_end:
	movem.l	(sp)+,a0/a1/a2/a3/a4
	rts
	
******************rs directives*******************************************
rs_auto_align:
	lea	field_3(a5),a1
	cmpi.w	#"ON",(a1)
	beq.s	aa_on
	cmpi.w	#"on",(a1)
	beq.s	aa_on
	cmpi.w	#"of",(a1)
	beq.s	aa_off
	cmpi.w	#"OF",(a1)
	beq.s	aa_off
	lea	auto_align_error(pc),a0
	bsr	pass1_error
	qbset	#4,flags2(a5)
	rts
aa_on:	move.b	#1,rs_autoalign(a5)	
	rts
aa_off:	clr.b	rs_autoalign(a5)
	rts_	"RS_Auto_align"
do_rs_align:
	lea	field_3(a5),a1
	tst.b	(a1)
	beq	dra8		*default is 8
	cmpi.b	#"2",(a1)
	beq	dra2
	cmpi.b	#"4",(a1)
	beq	dra4
	cmpi.b	#"8",(a1)
	beq	dra8
	cmpi.w	#"32",(a1)
	beq	dra32
	cmpi.w	#"64",(a1)
	beq	dra64
	cmpi.w	#"25",(a1)
	bne.s	dra_error
	cmpi.b	#"6",2(a1)
	beq	dra256
dra_error:
	lea	rs_align_error(pc),a0
	bsr	pass1_error
	qbset	#4,flags2(a5)
	rts
dra2:	move.l	rs_counter(a5),d0

do_align2:
	move.l	d0,d1
	andi.l	#%1,d1
	beq.s	done_aligned
	addq.l	#1,d0
	bra.s	do_align2

dra4:	move.l	rs_counter(a5),d0

do_align4:
	move.l	d0,d1
	andi.l	#%11,d1
	beq.s	done_aligned
	addq.l	#1,d0
	bra	do_align4

dra8:	move.l	rs_counter(a5),d0
do_align8:
	move.l	d0,d1
	andi.l	#%111,d1
	beq.s	done_aligned
	addq.l	#1,d0
	bra	do_align8

dra32:	move.l	rs_counter(a5),d0
do_align32:
	move.l	d0,d1
	andi.l	#%11111,d1
	beq.s	done_aligned
	addq.l	#1,d0
	bra	do_align32

dra64:	move.l	rs_counter(a5),d0
do_align64:
	move.l	d0,d1
	andi.l	#%111111,d1
	beq.s	done_aligned
	addq.l	#1,d0
	bra	do_align64

dra256:	move.l	rs_counter(a5),d0
do_align256:
	move.l	d0,d1
	andi.l	#%11111111,d1
	beq.s	done_aligned
	addq.l	#1,d0
	bra	do_align256
done_aligned:
	move.l	d0,rs_counter(a5)
	rts

********	
rs_reset:
	global	rs_reset
	bsr.s	accumulate_rs	*For ppc bss
**In fant 520 we can pass an optional expression in field 3 (a2) to reset the counter to
	tst.b	(a2)
	beq.s	clear_rs
	bsr	test_for_hash
	tst.l	d0
	bmi.s	clear_rs	*cant hash rs_reset
	bsr	recurs_eval	*eval a2 into d0
	move.l	d0,rs_counter(a5)
	bra.s	done_rs_reset
clear_rs:
	clr.l	rs_counter(a5)
done_rs_reset:
	clr.l	d0
	rts

accumulate_rs:
	move.l	rs_counter(a5),d0
	cmp.l	rs_accumulator(a5),d0
	bgt.s	up_rs_accum
	rts_	"Accum_rs"
up_rs_accum:
	move.l	d0,rs_accumulator(a5)
	rts
	
test_for_hash:
	clr.l	d0
	cmpi.b	#"#",(a2)
	bne.s	not_hash
	lea	hash_err(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d0
not_hash:
	rts_	"test_for_hash"
	
		
rs_byte:
	tst.b	(a2)			*Field 3 empty?
	bne.s	rsb_ok1
	bsr	rs_empty
	qmove.b	#"1",(a2)		*if yes, then substitute an ascii 1
rsb_ok1:
	bsr	test_for_hash
	tst.w	d0
	bmi	rsa_off1

	qmove.w	flags(a5),f_save(a5) 	save state of flags
	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	bsr	recurs_eval 	*get value of label in a2
	move.w	f_save(a5),flags(a5)
**now insert rs_counter, with this label in equates table

	qmove.l	d0,-(sp)	size of this rs
	bsr	insert_equ
	qmove.l	(sp)+,d0
	ext.l	d0	
	add.l	d0,rs_counter(a5)	update rs counter
**v4.11 - rs_auto_align
	tst.b	rs_autoalign(a5)
	beq.s	rsa_off1
	bsr	dra8
rsa_off1:
	rts_	"rs_byte "
	align
	
rs_word:
	tst.b	(a2)			*field 3 empty?
	bne.s	rsw_ok1
	bsr	rs_empty
	qmove.b	#"1",(a2)		*if yes, then substitute an ascii 1
rsw_ok1:
	bsr	test_for_hash
	tst.w	d0
	bmi	rsa_off1

;	btst	#0,flags7(a5)
	btst	#0,ppc_flags1(a5)
	bne.s	ppc_rs_word	*actually a long!
ppc_rs_half:
	qmove.w	flags(a5),f_save(a5) 	save state of flags
	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
ppc_rs_half_ent:
	bsr	recurs_eval 	*get value of label in a2
	qmove.w	f_save(a5),flags(a5)

	qmove.l	rs_counter(a5),d1	v2.2
;	btst	#2,ppc_flags1(a5)
;	bne.s	size_ppc_half_ok	align off v4
;	btst	#0,d1	check for even
;	beq.s	size_ppc_half_ok
;	addq.l	#1,rs_counter(a5)	make rs even
size_ppc_half_ok:	

	qmove.l	d0,-(sp)	size of this rs
	bsr	insert_equ
	qmove.l	(sp)+,d0
	ext.l	d0	
	lsl.l	#1,d0	times 2 for words
	add.l	d0,rs_counter(a5)	update rs counter
**v4.11 - rs_auto_align
	tst.b	rs_autoalign(a5)
	beq.s	rsa_off2
	bsr	dra8
rsa_off2:

	rts_	"rs_word "
	align
	
rs_long:
	tst.b	(a2)			*field 3 empty?
	bne	rsl_ok1
	bsr	rs_empty
	qmove.b	#"1",(a2)		*if yes, then substitute an ascii 1
rsl_ok1:
	bsr	test_for_hash
	tst.w	d0
	bmi	rsa_off1

;	btst	#0,flags7(a5)
	btst	#0,ppc_flags1(a5)
	bne.s	ppc_rs_long	*actually a 64 bitter!

ppc_rs_word:
	qmove.w	flags(a5),f_save(a5) 	save state of flags
	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	tst.b	half_size(a5)
	bne	ppc_rs_half_ent

ppc_rs_word_ent:
	bsr	recurs_eval 	*get value of label in a2
	qmove.w	f_save(a5),flags(a5)
**now insert rs_counter, with this label in equates table
	qmove.l	rs_counter(a5),d1
;	btst	#2,ppc_flags1(a5)
;	bne.s	size_long_ok
;	btst	#0,d1	check for even v2.2
;	beq.s	size_long_ok
;	addq.l	#1,rs_counter(a5)	make rs even
;size_long_ok:	
	qmove.l	d0,-(sp)	size of this rs
	bsr	insert_equ
	qmove.l	(sp)+,d0
	ext.l	d0	
	lsl.l	#2,d0	times 4 for longs
	add.l	d0,rs_counter(a5)	update rs counter
**v4.11 - rs_auto_align
	tst.b	rs_autoalign(a5)
	beq.s	rsa_off3
	bsr	dra8
rsa_off3:

	rts_	"rs_long "
	align
	
ppc_rs_long:

	qmove.w	flags(a5),f_save(a5) 	save state of flags
	qbset	#1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	tst.b	half_size(a5)
	bne	ppc_rs_word_ent
	bsr	recurs_eval 	*get value of label in a2
	qmove.w	f_save(a5),flags(a5)
**now insert rs_counter, with this label in equates table
	qmove.l	rs_counter(a5),d1
ppc_size_long_ok:
		
	qmove.l	d0,-(sp)	size of this rs
	bsr.s	insert_equ
	qmove.l	(sp)+,d0
	ext.l	d0	
	lsl.l	#3,d0	times 8 for ppc longs
	add.l	d0,rs_counter(a5)	update rs counter
**v4.11 - rs_auto_align
	tst.b	rs_autoalign(a5)
	beq.s	rsa_off4
	bsr	dra8
rsa_off4:

	rts_	"ppc_rs_long"

rs_empty:
	save_all
	lea	one_substituted(pc),a0
	bsr	pass1_warning
	restore_all
	rts_	"rs_empty"
		
****insert equ inserts a simulated equ for rs directives into equ table
insert_equ:	lea 	field_1(a5),a3
	tst.b	(a3)
	beq.s	no_equ_tit_head
	cmp.b	#".",(a3)	 	  ; llbls-rp200797
	beq.s	rs_local_error	          ; llbls-rp200797
	
**search labels
 	qmove.l	labels(a5),tree_strings_ptr(a5)
 	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search
	tst.w	d0
;
; 	  move.l	labels(a5),a4	labels list
;	bsr	search_labp2	(was lab)
;	tst.w	d0
	bmi	not_def1
	bsr.l	defined_error
	rts
not_def1:
	lea 	field_1(a5),a3	      
 	qmove.l	equates(a5),tree_strings_ptr(a5)
 	move.l	equates_tree(a5),a2
	bsr.l	equ_tree_insert
	tst.w	d0
	bge	not_def2
	bsr.l	defined_error
	rts
not_def2:
;	movea.l	equates(a5),a4 	*equates list
;	bsr	search_labp2 	*see if it is defined already returns d0
;	tst.w	d0 	*-1=not found else position
;	bge	defined_error
 
;	movea.l equates(a5),a4
;	adda.l eq_pos(a5),a4 	*lt pos is inc"d by 32 for every label
;copy_equ_to_tab_rs: 	 *now copy the label into the table
;	move.b (a3)+,(a4)+
;	bne.s copy_equ_to_tab_rs
 
	addq.l #1,equ_num(a5) 	*inc total number of lables
	qmove.l eq_val(a5),a4 	*now save its address
	qmove.l eq_pos(a5),d0
	lsr.l #3,d0
	add.l d0,a4 		*point to right place 32/8=4 (longword)

	qmove.l rs_counter(a5),0(a4) 	 *store value of rs_counter
	addi.l #32,eq_pos(a5) 	*ready for next label
no_equ_tit_head:
	rts_	"ins_equ "
	align


; ******** llbls-rp200797
rs_local_error:
	lea	rs_error2(pc),a0
	bsr	pass1_error
	rts_	"rs_local_err"
; ******** llbls-rp200797	

*********************************options**********************************
options:
 move.b (a2),d0
; move.b 1(a2),d1
; cmpi.b #"d",d0 	 *d=debug info in o/p file
; bne.s not_o_lab
; bset #0,option_flags(a5) 	*dump labels
; rts_	 "options "
; align
not_o_lab:
 cmpi.b #"b",d0
 bne.s not_o_bin
 qbset #1,option_flags(a5) 	*binary dump only
 rts_	"not_o_la"
	align
	
not_o_bin:
; cmpi.b #"l",d0 	 *list labels to disk file
; bne.s not_o_lf
; bset #2,option_flags(a5)
; rts_	 "not_o_bi"
	align
	
;not_o_lf:
; cmpi.b #"s",d0
; bne.s not_o_s
; bset #3,option_flags(a5) 	*dump complete source to disk file
; rts
 
not_o_s:
 bsr opt_err
 rts_	"not_o_s "
************************************************************************
*debug processing - insert a9ff into code for mac.                     *
************************************************************************
do_debug:
	btst	#0,ppc_flags1(a5)	*ppc?
	bne.s	ppc_directive_error		*can't use in ppc mode!

 movea.l code_buffer(a5),a3
 addq.l #2,pc(a5)
 move.w #debugger,(a3)+
 move.l a3,code_buffer(a5)
 rts_	"do_debug"
ppc_directive_error:
	lea	directive_error_text(pc),a0	fail string
	bsr	pass1_error
	rts
************************************************************************
***dc.b processing			*
************************************************************************
dcb:
	btst	#0,ppc_flags1(a5)	*ppc?
	bne	dcb_ppc		*yes, use data buffer
 qmove.l pc(a5),d7 	*get current pc
 movea.l code_buffer(a5),a3
 btst #0,flags(a5)
 beq.s dcb_end 		*assembly off!
 lea field_3(a5),a1
next_byte:
 cmpi.b #$22,(a1) 	*string delimiters?
 bne.s not_string
 bsr.s string
 tst.b	(a1)
 beq.s dcb_end 		*eol
 cmpi.b #0x2c,(a1)+
 bne comma_error 	8we must have a comma if not eol
 bra.s next_byte
not_string:

 bsr.s get_numb_byte 	*get a number
 tst.w d1
 bmi.s dcb_end
 bra.s next_byte
dcb_end:
 qmove.l d7,pc(a5) 	*save our pc
 move.l a3,code_buffer(a5)
; bsr	 default_align
 rts
 
get_numb_byte:
****here a1 points to a string like 27, 
get_next_byte:
 bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
 tst.l d1
 bmi.s got_b_error 	*eol
 cmpi.l #255,d0
 bgt too_big_byte
 cmpi.l #-127,d0
 blt too_big_byte
 qmove.b d0,(a3)+ 	 *save byte in buffer
 addq.l #1,d7 		*inc pc
got_b_error:
 rts
 
string:
 addq.l #1,a1 		*skip "
move_string:
 move.b (a1)+,d6 	*get yer actual character
 beq.s string_error 	*we should see delimeter before we get to 0
 cmpi.b #$22,d6 	*delimeter?
 beq.s ms_done
 qmove.b d6,(a3)+ 	 *store byte in code buffer at pc
 addq.l #1,d7 		*inc pc
 bra.s move_string
ms_done:
 rts_	"dcb"

string_error:
 lea string_text(pc),a0 	*quotes expected!
	bsr	pass1_error
 clr.b	(a1) 	*stop processing field 3
 rts_	"string_error"


dcb_ppc:
	btst	#1,flags(a5)
	bne.s	dcb_dummy		*branch on pass 2, fall through only on pass 1
;	bsr	default_align

	qmove.l	data_buffer_index(a5),d7 	*get current pos
	move.l	data_item_offsets(a5),a1	*store offset
	qmove.l	data_item_count(a5),d0
**LXT CHANGE
	qpush1	d0
	lsl.l	#2,d0
	qmove.l	d7,(a1,d0.l)
	qpop1	a0
**
;	move.l	d7,0(a1,d0.l*4)		*store its offset in data_item_offsets
	addq.l	#1,data_item_count(a5)		
	
	qmove.l data_buffer(a5),a3
	btst #0,flags(a5)
	beq.s dcb_endp 		*assembly off!
	lea field_3(a5),a1
next_bytep:
	cmpi.b #$22,(a1) 	*string delimiters?
	bne.s not_stringp
	bsr.s string
	tst.b	(a1)
	beq.s dcb_endp 		*eol
	cmpi.b #0x2c,(a1)+
	bne comma_error 	8we must have a comma if not eol
	bra.s next_bytep
not_stringp:
	qbset	#2,flags8(a5)	*tell eval to report undefined labs on pass 1
	bsr get_numb_byte 	*get a number
	qbclr	#2,flags8(a5)
	tst.w d1
	bmi.s dcb_endp
	bra.s next_bytep
dcb_endp:
	qmove.l d7,data_buffer_index(a5) 	 *save our pc
	qmove.l a3,data_buffer(a5)
;	bsr	default_align		*do a ppc align
dcb_skipp:
;	btst	#1,flags(a5)
;	bne	dcb_dummy		*only on pass 2 export the dummy

	rts_	"dcb_ppc"
dcb_dummy:
	btst	#6,flags5(a5)
	beq	no_data_dummy		*linkable? no
	lea	field_1(a5),a3
	tst.b	(a3)
	beq.s	no_lab_dcbdummy
;	debug


	bsr.l	test_for_locals		; ******* llbls-rp200797 *********
	extern	test_for_locals

 	qmove.l	labels(a5),tree_strings_ptr(a5)
	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search

;	move.l	labels(a5),a4	*table to be searched
;	bsr	search_labp2	*search for this label (was lab)

	tst.w	d0	*did we find it?
	bge.s	found_in_labels	*yes, in labels
no_lab_dcbdummy:
	rts
found_in_labels:
	move.l	lab_val(a5),a4
**LXT CHange
	qpush1	a4
	lsl.l	#2,d0
	add.l	d0,a4
	qmove.l	(a4),d0
	qpop1	a4
**
;	move.l	0(a4,d0.l*4),d0
	btst	#31,d0
	beq.s	no_data_dummy	*its been defined already
	qbclr	#31,d0
	movem.l	a2/a3/a4,-(sp)	
	qmove.l	total_data_ptrs_used(a5),d1
	qmove.l	data_ptrs_output_table(a5),a4
	muls	#40,d1
	add.l	d1,a4		*right place for label and offset
	move.l	a4,a2		*save start of label
	qmoveq	#31,d1
copy_dat_loop:
	move.b	(a3)+,(a4)+
	beq.s	get_out_clause3
	qdbra	d1,copy_dat_loop
get_out_clause3:
	qmove.l	#-4,32(a2)	*save pc of offset as a dummy
	qmove.l	d0,d1
	subq.l	#4,d1		*bss pointer shit
*get data offset
	qmove.l	total_imports_num(a5),d2
;	ext.l	d2
	lsl.l	#2,d2	*times 4 :-)	 
	sub.l	d2,d1	*offset into data offsets
	bmi.s	bad_offset
	move.l	data_item_offsets(a5),a3
**LXT
	qpush1	a3
	add.l	d1,a3
	qmove.l	(a3),d1
	qpop1	a3
**
;	move.l	0(a3,d1.l),d1
bad_offset:
	qmove.l	d1,36(a2)	*save data offset
	addq.l	#1,total_data_ptrs_used(a5)
	movem.l	(sp)+,a2/a3/a4
no_data_dummy:
	clr.l	d0
	rts_	"do_data_dummy"

**************************************************************************
****END OF DCB PROCESSING			*
**************************************************************************

**************************************************************************
****DC.W PROCESSING			*
************************************************************************** 
dcw:
 btst #0,flags(a5)
 beq.s dcw_end 		*assembly off!
	btst	#0,ppc_flags1(a5)	*ppc?
	bne	dcw_ppc		*yes, use data buffer for 32 bits!

;	debug
; bsr default_align 	  	  *make pc even for words!
;	bsr	even
 qmove.l pc(a5),d7 	*get current pc
 movea.l code_buffer(a5),a3
 lea field_3(a5),a1
 cmpi.b	#$22,(a1)
 beq	define_space_warning	*dc.w	"fred"
get_numb_word:
****here a1 points to list of words 
get_next_word:
 bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1

 tst.l d1
 bmi.s got_w_end 	*eol
 cmpi.l #-32767,d0
 blt too_big_word
 cmpi.l #65536,d0
 bgt too_big_word
word_ok:
 qmove.w d0,(a3)+ 	 *save byte in code buffer
 addq.l #2,d7 		*inc pc
 bra.s get_next_word
got_w_end:
 qmove.l d7,pc(a5)
 qmove.l a3,code_buffer(a5)
dcw_end:
;	bsr	default_align
	rts_	"dcw"
	align

ppc_dch:
	btst	#1,flags(a5)
	bne	dcb_dummy		*only on pass 1
;	bsr	default_align
	qmove.l data_buffer_index(a5),d7 	 *get current pc
	qmove.l	data_item_offsets(a5),a1	*store offset
	qmove.l	data_item_count(a5),d0
**LXT change
	push	d0
	lsl.l	#2,d0
	qmove.l	d7,(a1,d0.l)
	pop	d0
;	move.l	d7,0(a1,d0.l*4)		*store its offset in data_item_offsets
	addq.l	#1,data_item_count(a5)		
	movea.l data_buffer(a5),a3
	lea field_3(a5),a1
	cmpi.b	#$22,(a1)
	beq	define_space_warning	*dc.w	"fred"
get_numb_wordp:
****here a1 points to list of words 
get_next_wordp:
	qbset	#2,flags8(a5)	*tell eval to report undefined labs on pass 1
	bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
;	bset	#2,flags8(a5)	*tell eval to report undefined labs on pass 1
	qbclr	#2,flags8(a5)	*tell eval to report undefined labs on pass 1

	tst.l d1
	bmi.s got_w_endp 	*eol
	cmpi.l #-32767,d0
	blt too_big_word
	cmpi.l #65536,d0
	bgt too_big_word
word_okp:
	move.w d0,(a3)+ 	*save byte in code buffer
	addq.l #2,d7 		*inc pc
	bra.s get_next_wordp
got_w_endp:
	qmove.l d7,data_buffer_index(a5)
	qmove.l a3,data_buffer(a5)
dcw_endp:
;	btst	#1,flags(a5)
;	bne	dcb_dummy		*only on pass 2 export the dummy
;	bsr	default_align
	clr.l	d0
	rts_	"dcw_ppc"

****************************************************************************
****end of word processing			*
****************************************************************************

****************************************************************************
****dc.l processing			*
****************************************************************************
dcl:
 btst #0,flags(a5)
 beq.s dcl_end 		*assembly off!
;	bsr	default_align 	    	    *make even address
	btst	#0,ppc_flags1(a5)	*ppc?
	bne.s	dcl_ppc		*yes, use data buffer

 qmove.l pc(a5),d7 	*get current pc
 movea.l code_buffer(a5),a3
 lea field_3(a5),a1
get_numb_long:
****here a1 points to list of longs 
get_next_long:
 qmove.w #0,d1
 bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
 tst.w d1
 bmi.s got_l_end 	*eol
 btst #4,flags(a5) 	*was it a label?
 beq.s dcl_equ 		*nah!
***here we have to put the long in the reloc table
 qmove.l reloc_tab_pos(a5),d5 	 *get position
 movea.l reloc_tab(a5),a4 	*get table
 qmove.l d7,0(a4,d5.l) 	*save pc in table
 addq.l #4,reloc_tab_pos(a5)
**if flags4(5) is set, then output line to log, showing abs ref
	btst	#5,flags4(a5)
	beq.s	dcl_equ
	save_all
	lea	d_abs_ref_text(pc),a0
	bsr	pass2_error
	restore_all

dcl_equ:
 qmove.l d0,(a3)+ 	 *and save long in code buffer
 addq.l #4,d7 		*inc pc
 bra get_next_long
got_l_end:
 qmove.l d7,pc(a5)
 qmove.l a3,code_buffer(a5)
;	bsr	default_align
 rts
****we cant get longs yet, cause they may not be defined
dcl_skip:
 qmove.w #0,d1
 bsr skip_numb
 tst.w d1
 bmi.s got_l_end 	eol
 addq.l #4,d7 		inc pc
 bra.s dcl_skip
 
dcl_end:		*if assembly is off, we come here
 	clr.l	d0
 	rts_	"dcl     "
	align
	
dcl_ppc:
	tst.b	half_size(a5)
	bne.s	dcw_ppc_ent
	lea	no_dcl_ppc(pc),a0
	bsr	pass1_error
	rts
	
dcw_ppc:
	tst.b	half_size(a5)
	bne	ppc_dch
dcw_ppc_ent:	btst	#1,flags(a5)
	bne	dcb_dummy		*only on pass 1
;	bsr	default_align
	qmove.l data_buffer_index(a5),d7 	 *get current pc
	qmove.l	data_item_offsets(a5),a1	*store offset
	qmove.l	data_item_count(a5),d0
**LXT
	push	d0
	lsl.l	#2,d0
	qmove.l	d7,(a1,d0.l)
	pop	d0
;	move.l	d7,0(a1,d0.l*4)		*store its offset in data_item_offsets
	addq.l	#1,data_item_count(a5)		
	movea.l data_buffer(a5),a3
	lea field_3(a5),a1
get_numb_longp:
****here a1 points to list of longs 
get_next_longp:
	qmove.l #0,d1
	qbset	#2,flags8(a5)	*tell eval to report undefined labs on pass 1
	bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
	qbclr	#2,flags8(a5)	*tell eval to report undefined labs on pass 1
	tst.w d1
	bmi.s got_l_endp 	*eol
	btst #4,flags(a5) 	*was it a label?
	beq.s dcl_equp 		*nah!
***here we have to put the long in the reloc table
	qmove.l reloc_tab_pos(a5),d5 	 *get position
	movea.l reloc_tab(a5),a4 	*get table
	qmove.l d7,0(a4,d5.l) 	 *save pc in table
	addq.l #4,reloc_tab_pos(a5)
**if flags4(5) is set, then output line to log, showing abs ref
	btst	#5,flags4(a5)
	beq.s	dcl_equp
	save_all
	lea	d_abs_ref_text(pc),a0
	bsr	pass2_warning
	restore_all

dcl_equp:
	move.l d0,(a3)+ 	*and save long in code buffer
	addq.l #4,d7 		*inc pc
	bra get_next_longp
got_l_endp:
	qmove.l d7,data_buffer_index(a5)
	move.l a3,data_buffer(a5)
;	btst	#1,flags(a5)
;	bne	dcb_dummy		*only on pass 2 export the dummy
;	bsr	default_align
	clr.l	d0
	rts_	"dcl_ppc"
*****************************************************************************
****end of dc.l processing			*
*****************************************************************************
****************************************************************************
****dcoff processing			*
****************************************************************************
**dcoff is a special directive that allows defining offsets as longs without
**tripping the relocation flags. used for setting jump tables etc
dcoff:
 btst #0,flags(a5)
 beq dcl_end 		      *assembly off!
 bsr even 		*make even address
 move.l pc(a5),d7 	*get current pc
 movea.l code_buffer(a5),a3
 lea field_3(a5),a1
get_numb_long_off:
****here a1 points to list of longs 
get_next_long_off:
 qmove.w #0,d1
 bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
 tst.w d1
 bmi got_l_end 	*eol
 btst #4,flags(a5) 	*was it a label?
 beq.s dcl_equ_off 		*nah!
***here we have to put the long in the reloc table
; move.l reloc_tab_pos(a5),d5 	*get position
; movea.l reloc_tab(a5),a4 	*get table
; move.l d7,0(a4,d5.l) 	*save pc in table
; addq.l #4,reloc_tab_pos(a5)
**if flags4(5) is set, then output line to log, showing abs ref
;	btst	#5,flags4(a5)
;	beq.s	dcl_equ
;	save_all
;	lea	abs_ref_text(pc),a0
;	bsr	pass2_warning
;	restore_all

dcl_equ_off:
 move.l d0,(a3)+ 	*and save long in code buffer
 addq.l #4,d7 		*inc pc
 bra get_next_long
got_l_end_off:
 move.l d7,pc(a5)
 move.l a3,code_buffer(a5)
 rts
****we cant get longs yet, cause they may not be defined
dcl_skip_off:
 qmove.w #0,d1
 bsr skip_numb
 tst.w d1
 bmi.s got_l_end_off 	eol
 addq.l #4,d7 		inc pc
 bra.s dcl_skip_off
 
dcl_end_off:		*if assembly is off, we come here
 	clr.l	d0
 	rts_	"dcoff   "
	align
*****************************************************************************
****end of dcoff processing			*
*****************************************************************************

*****************************************************************************
****ds.b processing			*
*****************************************************************************
dsb:
 btst #0,flags(a5)
 beq.s dsb_end 		*assembly off!
	btst	#0,flags7(a5)	*ppc?
	bne.s	dsb_ppc		*yes, use data buffer

;	bsr	default_align
 qmove.l pc(a5),d7 	*get current pc
 movea.l code_buffer(a5),a3
 lea field_3(a5),a1
 cmpi.b	#$22,(a1)
 beq	define_string_warning	*haha crash no more!
 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we"re on pass 2 even if we"re not!

 qmove.l #0,d1
 bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
 qmove.w f_save(a5),flags(a5)
 tst.l	d0
 beq	define_space_warning	zero returned, so give warning
**check for -ve?
	tst.l	d0
	bmi	minus_space_error

 tst.w d1
 bmi.s byte_error 	*eol!
 add.l d0,d7
 movea.l a3,a4
 add.l d0,a4 		*inc pc by n bytes
fill_bytes:
 clr.b (a3)+ 		*we clear the bytes
 cmpa.l a3,a4
 bne.s fill_bytes
 qmove.l d7,pc(a5) 	*skip d0 bytes
 qmove.l a3,code_buffer(a5)
dsb_end:

;	bsr	default_align	do an even on pc
	rts

byte_error:
 lea bytes_expected(pc),a0
 bsr pass1_error
 clr.l	d0
 rts_	"dsb     "
	align
dsb_ppc:
	btst	#1,flags(a5)
	bne	dcb_dummy		*only on pass 1
;	bsr	default_align
	qmove.l data_buffer_index(a5),d7 	 *get current pc
	move.l	data_item_offsets(a5),a1	*store offset
	qmove.l	data_item_count(a5),d0
**LXT
	push	d0
	lsl.l	#2,d0
	qmove.l	d7,(a1,d0.l)
	pop	d0
;	move.l	d7,0(a1,d0.l*4)		*store its offset in data_item_offsets
	addq.l	#1,data_item_count(a5)		
	movea.l data_buffer(a5),a3
	lea field_3(a5),a1
	cmpi.b	#$22,(a1)
	beq	define_string_warning	*haha crash no more!
	qmove.w flags(a5),f_save(a5) 	 save state of flags
	qbset #1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	qmove.l #0,d1
	bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
	move.w f_save(a5),flags(a5)
	tst.l	d0
	beq	define_space_warning	zero returned, so give warning
**check for -ve?
	tst.l	d0
	bmi	minus_space_error
**check space available
	qmove.l	d7,d6		*current index
	add.l	d0,d6
	qmove.l	ppc_data_buffer_size(a5),d5
	cmp.l	d5,d6
	bgt.s	fatal_data_buffer_error
	tst.w d1
	bmi byte_error 	*eol!
	add.l d0,d7
	movea.l a3,a4
 	add.l d0,a4 		*inc pc by n bytes
fill_bytesp:
	clr.b (a3)+ 		*we clear the bytes
	cmpa.l a3,a4
	bne.s fill_bytesp
	qmove.l d7,data_buffer_index(a5) 	 *skip d0 bytes
	qmove.l a3,data_buffer(a5)
dsb_endp:
;	bsr	default_align	do an even on pc	
;	btst	#1,flags(a5)
;	bne	dcb_dummy		*only on pass 2 export the dummy

	rts_	"dsb_ppc"

fatal_data_buffer_error:
	lea	fatal_data(pc),a0
	bsr	printit
	qbset	#4,flags2(a5)	*fatal errerrrr
	rts_	"fatal_databuff_catcher"
******************************************************************************
****end of ds.b processing.			*
******************************************************************************
ppc_ds_h:
	btst	#0,flags7(a5)
	beq	error_68k1
	btst	#1,flags(a5)
	bne	dcb_dummy		*only on pass 1
;	bsr	default_align
	qmove.l data_buffer_index(a5),d7 	 *get current pc
	move.l	data_item_offsets(a5),a1	*store offset
	qmove.l	data_item_count(a5),d0
**LXT
	push	d0
	lsl.l	#2,d0
	qmove.l	d7,(a1,d0.l)
	pop	d0
;	move.l	d7,0(a1,d0.l*4)		*store its offset in data_item_offsets
	addq.l	#1,data_item_count(a5)		
	movea.l data_buffer(a5),a3
	lea field_3(a5),a1


	cmpi.b	#$22,(a1)
	beq	define_string_warning	*haha crash no more!

	qmove.w flags(a5),f_save(a5) 	 save state of flags
	qbset #1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	qmove.w #0,d1
	bsr get_numb 	     	     *returns number pointed to in a1 in d0 or d1=-1
	qmove.w f_save(a5),flags(a5)
	tst.l	d0
	beq	define_space_warning
**check for -ve?
	tst.l	d0
	bmi	minus_space_error
	tst.w d1
	bmi long_error 	*eol!
	lsl.l #1,d0 		*16 bits
	add.l d0,d7
	movea.l a3,a4
	add.l d0,a4
clear_halfs:
	clr.w (a3)+
	cmpa.l a3,a4
	bne.s clear_halfs
 
	qmove.l d7,data_buffer_index(a5) 	 *skip d0 words
	qmove.l a3,data_buffer(a5)
;	bsr	default_align
	rts_	"dsh_ppc"
	
error_68k1:
	lea	dsh_ppc_only(pc),a0
	bsr	pass1_error
	rts
*****************************************************************************
****ds.w processing			*
*****************************************************************************

dsw:
 btst #0,flags(a5)
 beq.s dsw_end 		*assembly off!
 
; bsr even 		 *make pc even
	btst	#0,ppc_flags1(a5)	*ppc?
	bne.s	dsw_ppc		*yes, use data buffer

 qmove.l pc(a5),d7 	*get current pc
 movea.l code_buffer(a5),a3
 lea field_3(a5),a1
 cmpi.b	#$22,(a1)
 beq	define_string_warning	*haha crash no more!

 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we"re on pass 2 even if we"re not!
 qmove.w #0,d1
 bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
 qmove.w f_save(a5),flags(a5)
 tst.l	d0
 beq	define_space_warning
**check for -ve?
	tst.l	d0
	bmi	minus_space_error
 tst.w d1
 bmi.s word_error 	*eol!
 lsl.l #1,d0 		*words
 add.l d0,d7
 movea.l a3,a4
 add.l d0,a4
clear_words:
 clr.w (a3)+ 		*clear words
 cmpa.l a3,a4
 bne.s clear_words
 qmove.l d7,pc(a5) 	*skip d0 words
 qmove.l a3,code_buffer(a5)
dsw_end:
;	bsr	default_align
 rts

word_error:
 lea words_expected(pc),a0
 bsr pass1_error
 rts_	"dsw     "
	align
minus_space_error:
	lea	space_error_text(pc),a0
	bsr	pass1_error
	rts
*dsw_ppc:
dsw_ppc:
	tst.b	half_size(a5)
	bne	ppc_ds_h	*68k ppc mode
dsw_ppc_ent:
	btst	#1,flags(a5)
	bne	dcb_dummy		*only on pass 1
;	bsr	default_align
	qmove.l data_buffer_index(a5),d7 	 *get current pc
	move.l	data_item_offsets(a5),a1	*store offset
	qmove.l	data_item_count(a5),d0
**LXT
	push	d0
	lsl.l	#2,d0
	qmove.l	d7,(a1,d0.l)
	pop	d0
;	move.l	d7,0(a1,d0.l*4)		*store its offset in data_item_offsets
	addq.l	#1,data_item_count(a5)		
	movea.l data_buffer(a5),a3
	lea field_3(a5),a1

	cmpi.b	#$22,(a1)
	beq	define_string_warning	*haha crash no more!

	qmove.w flags(a5),f_save(a5) 	 save state of flags
	qbset #1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	qmove.w #0,d1
	bsr get_numb 		*returns number pointed to in a1 in d0 or d1=-1
	qmove.w f_save(a5),flags(a5)
	tst.l	d0
	beq	define_space_warning
**check for -ve?
	tst.l	d0
	bmi	minus_space_error
	tst.w d1
	bmi word_error 	*eol!
	lsl.l #2,d0 		*words
	add.l d0,d7
	movea.l a3,a4
	add.l d0,a4
clear_wordsp:
	clr.b (a3)+ 		*clear words
	cmpa.l a3,a4
	bne.s clear_wordsp
	qmove.l d7,data_buffer_index(a5) 	 *skip d0 words
	qmove.l a3,data_buffer(a5)
dsw_endp:
;	bsr	default_align
	rts_	"dsw_ppc"
	
******************************************************************************
****end of ds.w processing.			*
******************************************************************************

*****************************************************************************
****ds.l processing			*
*****************************************************************************

dsl:
	tst.b	half_size(a5)
	bne	dsw_ppc_ent	*68k ppc mode

 btst #0,flags(a5)
 beq.s dsl_end 		*assembly off!
; bsr even 		       *make pc even
	btst	#0,ppc_flags1(a5)	*ppc?
	bne.s	dsl_ppc		*yes, use data buffer

 qmove.l pc(a5),d7 	*get current pc
 movea.l code_buffer(a5),a3
 lea field_3(a5),a1
 cmpi.b	#$22,(a1)
 beq	define_string_warning	*haha crash no more!

 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we"re on pass 2 even if we"re not!
 qmove.w #0,d1
 bsr get_numb 	      	      *returns number pointed to in a1 in d0 or d1=-1
 qmove.w f_save(a5),flags(a5)
 tst.l	d0
 beq	define_space_warning
**check for -ve?
	tst.l	d0
	bmi	minus_space_error

 tst.w d1
 bmi.s long_error 	*eol!
 lsl.l #2,d0 		*longs
 add.l d0,d7
 movea.l a3,a4
 add.l d0,a4
clear_longs:
 clr.l (a3)+
 cmpa.l a3,a4
 bne.s clear_longs
 
 move.l d7,pc(a5) 	*skip d0 words
 move.l a3,code_buffer(a5)
dsl_end:
;	bsr default_align
	rts

long_error:
 lea longs_expected(pc),a0
 bsr pass1_error
 rts_	"dsl     "
	align
dsl_ppc:	
	btst	#1,flags(a5)
	bne	dcb_dummy		*only on pass 1
;	bsr	default_align
	qmove.l data_buffer_index(a5),d7 	 *get current pc
	move.l	data_item_offsets(a5),a1	*store offset
	qmove.l	data_item_count(a5),d0
**LXT
	qpush1	d0
	lsl.l	#2,d0
	qmove.l	d7,(a1,d0.l)
	qpop1	d0
;	move.l	d7,0(a1,d0.l*4)		*store its offset in data_item_offsets
	addq.l	#1,data_item_count(a5)		
	movea.l data_buffer(a5),a3
	lea field_3(a5),a1


	cmpi.b	#$22,(a1)
	beq	define_string_warning	*haha crash no more!

	qmove.w flags(a5),f_save(a5) 	 save state of flags
	qbset #1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	qmove.w #0,d1
	bsr get_numb 		                              *returns number pointed to in a1 in d0 or d1=-1
	qmove.w f_save(a5),flags(a5)
	tst.l	d0
	beq	define_space_warning
**check for -ve?
	tst.l	d0
	bmi	minus_space_error
	tst.w d1
	bmi long_error 	*eol!
	lsl.l #3,d0 		*longs
	add.l d0,d7
	movea.l a3,a4
	add.l d0,a4
clear_longsp:
	clr.l (a3)+
	cmpa.l a3,a4
	bne.s clear_longsp
 
	qmove.l d7,data_buffer_index(a5) 	 *skip d0 words
	qmove.l a3,data_buffer(a5)
;	bsr	default_align
	rts_	"dsl_ppc"
******************************************************************************
****end of ds.l processing.			*
******************************************************************************

even:
	btst	#2,ppc_flags1(a5)
	beq.s	even_ok
	rts_	"align_off"		*v4 align off/on
even_ok:
	qbclr	#2,ppc_flags1(a5)	*clear align off
	btst	#0,ppc_flags1(a5)
	bne.s	even_ppc
 qmove.l pc(a5),d0
 btst #0,d0
 beq.s is_even
 addq.l #1,d0
 addq.l #1,code_buffer(a5)
 qmove.l d0,pc(a5)
is_even:	rts_	"even    "
	align
even_ppc:
;	move.l data_buffer_index(a5),d0
;	btst #0,d0
;	beq.s is_evenp
;	addq.l #1,d0
;	addq.l #1,data_buffer(a5)
;	move.l d0,data_buffer_index(a5)
	bsr	default_align	*do ppc align
is_evenp:	rts_	"evenp"


too_big_byte:
 lea size_text(pc),a0
 bsr pass2_error
 rts
 
too_big_word:
 lea size_text_w(pc),a0
 bsr pass2_error
 rts
	
***get_numb gets a number from a1, sends it to recurs_eval
***and returns the value of the number in d0
***the numbers in a1 are seperated by commas dc.w 25,16,32 etc
***if a1=0 then it sends back -1 in d1
get_numb:
 qmove.l d7,-(sp)
 tst.b	(a1)
 beq.s gn_term 		*nothing to convert
 lea numb_buff(pc),a2 	*recurs_eval needs a3 pointing to string
gn_loop:
 move.b (a1)+,d0
 beq.s last_numb 	*last number in this string
 cmpi.b #0x2c,d0
 beq.s got_numb
 qmove.b d0,(a2)+
 bra.s gn_loop
got_numb:
 clr.b	(a2)
 lea numb_buff(pc),a2
 bsr recurs_eval 	*get number in d0 (v2.00 calls recurs_eval to allow brackets)
 qmoveq #0,d1 	 	 *flags(4) will be set if it was a label
 move.l (sp)+,d7
 rts
last_numb:
 clr.b (a2)
 subq.l #1,a1 		*point back to terminator
 lea numb_buff(pc),a2
 bsr recurs_eval
 qmoveq #0,d1
 move.l (sp)+,d7
 rts
gn_term:
 qmoveq #-1,d1 		 *all done
 move.l (sp)+,d7
 rts

******************************************macros*****************************
macro:	btst	#1,flags(a5)	*1 if pass 2
	bne.s	macro_p2
	qbset	#0,flags2(a5)
	addq.l	#1,macro_num(a5)	inc number of macros
	rts
	
**we ignore macros definitions on pass 2 by setting bit 2 in flags2
macro_p2:	qbset	#2,flags2(a5)
	rts_	"macro"
	align
**endm	
endm:	btst	#1,flags(a5)	*1 if pass 2
	bne.s	endm_p2
**(we never come here cause its handled in do_pass_1, but just in case.....)
	rts
	
	
**if pass 2, then switch ignore macro def flag
endm_p2:	btst	#2,flags2(a5)	*are we in macro def?
	beq.s	switch_source	no
	qbclr	#2,flags2(a5)	*clear ignore mac flag
	rts
		
switch_source:	qmove.l	(sp)+,a1	*scrap call from jump table
	qmove.l	(sp)+,a1	*scrap call to jt from directives
	qmove.l	(sp)+,a1	*pop saved regs
	qmove.l	(sp)+,a0
**v3.2x
**v3.2x mods in accordance with fm_171194_01
	subq.l	#4,source_pointer_save_index(a5)
	lea	source_pointer_save(a5),a2
	qmove.l	source_pointer_save_index(a5),d1
;	ext.l	d1
	add.l	d1,a2
	move.l	(a2),a0	*source from next level up
	tst.l	source_pointer_save_index(a5)
	bne.s	not_top_level	not in source text yet
	qbclr	#1,flags2(a5)	yes, no macro paramter processing please
not_top_level:	sub.l	#parameter_size*number_of_parameters,macro_depth_index(a5)
*v3.75
**get the counter from counter_save(macro_nest-depth)
**and puts it into m_label_count
	lea	counter_save(a5),a6
	subq.l	#1,macro_nest_depth(a5)	*oops, forgot this
*v3.75
**get the counter from counter_save(macro_nest-depth)
**and puts it into m_label_count
	lea	counter_save(a5),a6
	qmove.l	#0,d0
	qmove.l	macro_nest_depth(a5),d0
**LXT
	qpush1	a6
	qpush2	d0
;	andi.l	#0xffff,d0
	lsl.l	#1,d0
	add.l	d0,a6
	qmove.w	(a6),m_label_count(a5)
	qpop2	d0
	qpop1	a6
;	move.w	0(a6,d0.w*2),m_label_count(a5)	*previous counter!
	move.l	macro_param(a5),a3
	qmove.l	macro_depth_index(a5),d1
**mdi is inc to next macro, so dec it**
	sub.l	#parameter_size*number_of_parameters,d1
	add.l	d1,a3	point to right param block
	clr.l	narg_count(a5)
count_narg:
	tst.b	(a3)
	beq.s	end_narg_count
	addq.l	#1,narg_count(a5)
	add.l	#parameter_size,a3
	bra.s	count_narg
end_narg_count:

***very important next line!
*	addq.w	#1,m_label_count(a5)	*make new label ready
	clr.l	d0
	rts		*return directily to pass 2 loop :-)



***skip_numb gets a number from a1
***the numbers in a1 are seperated by commas dc.w 25,16,32 etc
***if a1=0 then it sends back -1 in d1
skip_numb:
 qmove.l d7,-(sp)
 tst.b (a1)
 beq.s sn_term 		*nothing to convert
sn_loop:
 move.b (a1)+,d0
 beq.s last_numbs 	*last number in this string
 cmpi.b #0x2c,d0
 beq.s got_numbs
 bra.s sn_loop
got_numbs:
 qmoveq #0,d1
 move.l (sp)+,d7
 rts
last_numbs:
 subq.l #1,a1 		*point back to terminator
 qmoveq #0,d1
 move.l (sp)+,d7
 rts
sn_term:
 qmoveq #-1,d1 		 *all done
 move.l (sp)+,d7
 rts

*******************************global************************************
*defines a label(s) as being a global label
**we have summat like:
*	global	fred,jack,harry
*the global buffer is 32 bytes/label
*write link gets the address
*we only do on pass 2!
*
*the global buffer is 32 bytes for label and 4 bytes for address rel to zero.
	section
global:	btst	#6,flags5(a5)	1=linkable o/p
	beq	link_only	error

	btst	#1,flags(a5)	1 if pass 2
	beq.s	g_end	nope
	lea	field_3(a5),a2
g_def_loop:	lea	get_ge_space(pc),a1	buffer for name
	clr.l	d7	*counter - 27 chars max	
get_g:	move.b	(a2),d0	get label name from field 3
	beq.s	got_glob	termed in zero
	cmpi.b	#13,d0	cr
	beq.s	got_glob	or
	cmpi.b	#0x2c,d0	comma
	beq.s	got_glob
	addq.l	#1,d7
	cmpi.l	#29,d7
	beq	glob_too_long_error	*5.1
	qmove.b	d0,(a1)+	store char
	addq.l	#1,a2	inc source
	bra.s	get_g	next char
got_glob:	clr.b	(a1)	terminate dest
	qmove.l	a2,-(sp)	save position in field 3


	lea	get_ge_space(pc),a3
	cmp.b	#".",(a3)		; ***** llbls-rp200797
	bne.s	.skip_warning		; ***** llbls-rp200797
	bsr.s	global_local_warning
.skip_warning:
	bsr.l	test_for_locals

 	qmove.l	labels(a5),tree_strings_ptr(a5)
	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search
	tst.l	d0
;	movea.l	labels(a5),a4 	*labels live here
;	bsr	search_labp2 	  *see if it is defined already returns d0 (was lab)
	bmi.s	g_not_defined_error
*we have position in d0
	qmove.l	global_buff(a5),a1
	move.l	(sp)+,a2	restore field position 3.94
	tst.b	0(a1,d0.l)	check if defd as glob already
	bne.s	glob_twice_error	yes.
	qmove.b	#1,0(a1,d0.l)	*set byte to 1 to indicate global
	addq.l	#1,global_count(a5)
	tst.b	(a2)+	*zero if end of field 3
	bne.s	g_def_loop	more defs
g_end:	rts


global_local_warning:	; ***** llbls-rp060997
	save_all
	lea	glob3_text(pc),a0
	bsr.l	send_to_log
	extern	send_to_log
	restore_all
	rts_	"global_local_warning"

glob_too_long_error:
	lea	glob2long_text(pc),a0
	bra.s	ext_def_err	do error

glob_twice_error:
	lea	glob2_text(pc),a0
	bra.s	ext_def_err	do error
	
g_not_defined_error:
	move.l	(sp)+,a2
	lea	gnt_text(pc),a0
ext_def_err:	bsr	pass2_error
	lea	get_ge_space(pc),a0
	bsr	printit	print label name
	lea	exc_text(pc),a0
	bsr	printit	print "error",13
	rts_	"global  "
	align	 

*******************************defall*************************************
**defall defines all labels generated in this file as global, or public
**sets flags5[7]
**not implemented!
defall:	qbset	#7,flags5(a5)
	rts_	"defall  "
	align
	
**************************************************************************
* llbls-rp200797
local_section:

; no, don't skip out if pass 2....
; skip out if not pass 1
;	btst	#1,flags(a5)		; pass1?
;	bne	exit_local_section

; pass field 3 to routine
	lea	field_3(a5),a0
	bsr.l	local_sectioning_directive
	extern	local_sectioning_directive
exit_local_section:
	rts_	"local_section"
* end of  llbls-rp200797 *******	
*******************************extern*************************************
*defines a label(s) as being external to this file
	section
extern:	btst	#6,flags5(a5)	1=linkable o/p
	beq	link_only	error
	btst	#1,flags(a5)	pass 1?
	bne	e_end	no

	lea	field_3(a5),a2
e_def_loop:	lea	get_ge_space(pc),a1	buffer for name
	
get_e:	move.b	(a2),d0	get label name from field 3
	beq.s	got_ext	termed in zero
	cmpi.b	#13,d0	cr
	beq.s	got_ext	or
	cmpi.b	#0x2c,d0	comma
	beq.s	got_ext	
	qmove.b	d0,(a1)+	store char
	addq.l	#1,a2	inc source
	bra.s	get_e	next char
got_ext:	clr.b	(a1)	terminate dest
	move.l	a2,-(sp)	save position in field 3

	lea	get_ge_space(pc),a3
	cmp.b	#".",(a3)		; ***** llbls-rp200797
	bne.s	.skip_warning		; ***** llbls-rp200797
	bsr.s	extern_local_warning
.skip_warning:
	bsr.l	test_for_locals
;	debug


 	qmove.l	labels(a5),tree_strings_ptr(a5)
	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search
	tst.l	d0

;	movea.l	labels(a5),a4 	*labels live here
;	bsr	search_labp2 	  *see if it is defined already returns d0 (was lab)
;	tst.w	d0
	bge	ext_defined_error
	lea	get_ge_space(pc),a3
	bsr.l	test_for_locals

 	qmove.l	labels(a5),tree_strings_ptr(a5)
 	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_insert	*cant fail cause we just searched


;	movea.l	labels(a5),a4
;	adda.l	lt_pos(a5),a4 	*lt pos is inc'd by 32 for every label
;copy_lab_to_tab_e: 	 *now copy the label into the table
;	move.b	(a3)+,(a4)+
;	bne.s	copy_lab_to_tab_e
 
	addq.w	#1,lt_num(a5) 	*inc total number of lables
	movea.l	lab_val(a5),a4 	*now save its address
	qmove.l	lt_pos(a5),d0 	*position/8=right place for long word 
	lsr.l	#3,d0
	qmove.l	#$ffffffff,0(a4,d0.l) *store address as -1!
	addi.l	#32,lt_pos(a5) 	*ready for next label

	qmove.w	lt_num(a5),d0	get label position
	subq.w	#1,d0	its incd by insert_label
	qmove.l	extern_buff(a5),a3
	qmove.b	#-1,0(a3,d0.w)	set corresponding byte to -1
* 	addq.l	#1,extern_count(a5)
	
	qmove.l	(sp)+,a2
	tst.b	(a2)+	zero if end of field
	bne	e_def_loop
e_end:	rts_	"extern  "
	align
	
extern_local_warning:	; ***** llbls-rp060997
	save_all
	lea	ext_local_text(pc),a0
	bsr.l	send_to_log
	restore_all
	rts_	"extern_local_warning"
		
	
ext_defined_error:
	qmove.l	(sp)+,a2
	lea	ext_def_text(pc),a0	external defined local
carry_on_with_ext_error:
	bsr	pass1_error
	lea	get_ge_space(pc),a0
	bsr	printit	print label name
	lea	exc_text(pc),a0
	bsr	printit	print "error",13
	rts_	"exte_err"
	align
link_only:	lea	link_only_text(pc),a0
	bsr	pass2_warning
	rts

***********
	section
extern_data:
**if 68k, goto extern
	btst	#0,flags7(a5)
	beq	extern
**else

	btst	#6,flags5(a5)	1=linkable o/p
	beq	link_only	error
	btst	#1,flags(a5)	pass 1?
	bne	e_end	no
	lea	field_3(a5),a2
ed_def_loop:	lea	get_ge_space(pc),a1	buffer for name
	
get_ed:	move.b	(a2),d0	get label name from field 3
	beq.s	got_extd	termed in zero
	cmpi.b	#13,d0	cr
	beq.s	got_extd	or
	cmpi.b	#0x2c,d0	comma
	beq.s	got_extd	
	move.b	d0,(a1)+	store char
	addq.l	#1,a2	inc source
	bra.s	get_ed	next char
got_extd:	clr.b	(a1)	terminate dest
	qmove.l	a2,-(sp)	save position in field 3

	lea	get_ge_space(pc),a3
	cmp.b	#".",(a3)		; ***** llbls-rp200797
	bne.s	.skip_warning
	bsr.l	extern_local_warning	; ***** llbls-rp200797
.skip_warning:
	bsr.l	test_for_locals
	
 	qmove.l	labels(a5),tree_strings_ptr(a5)
	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search
	tst.l	d0

;	movea.l	labels(a5),a4 	*labels live here
;	bsr	search_labp2 	  *see if it is defined already returns d0 (was lab)
;	tst.w	d0
	bge	ext_defined_error
	lea	get_ge_space(pc),a3
	bsr.l	test_for_locals

 	qmove.l	labels(a5),tree_strings_ptr(a5)
 	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_insert	*cant fail cause we just searched

;	movea.l	labels(a5),a4
;	adda.l	lt_pos(a5),a4 	*lt pos is inc'd by 32 for every label
;copy_lab_to_tab_ed: 	  *now copy the label into the table
;	move.b	(a3)+,(a4)+
;	bne.s	copy_lab_to_tab_ed
 
	addq.w	#1,lt_num(a5) 	*inc total number of lables
	movea.l	lab_val(a5),a4 	*now save its address
	qmove.l	lt_pos(a5),d0 	*position/8=right place for long word 
	lsr.l	#3,d0
	qmove.l	#$fffffffe,0(a4,d0.l) *store address as -2 for data!
	addi.l	#32,lt_pos(a5) 	*ready for next label

	qmove.w	lt_num(a5),d0	get label position
	subq.w	#1,d0	its incd by insert_label
;	move.l	extern_buff(a5),a3
;	move.b	#-1,0(a3,d0.w)	set corresponding byte to -1	
	qmove.l	(sp)+,a2
	tst.b	(a2)+	zero if end of field
	bne	ed_def_loop
e_endd:	rts_	"extern_data"
	
code_section:	
	lea	section_not_supported(pc),a0
	bsr	pass1_error
;bclr	#0,ppc_flags3(a5
	rts_	"set_code_sect"
data_section:	
	lea	section_not_supported(pc),a0
	bsr	pass1_error

;bset	#0,ppc_flags3(a5)
	rts_	"set_data_sect"
**pstring defines a pascal string as count.b, string
p_string:
	lea	field_3(a5),a1		*the string
	cmpi.b	#$22,(a1)
	bne	string_error		*no open quotes
	bsr.s	get_string_length	*in d0
	extb.l	d0
	qmove.l	d0,d6
	
	lea temp_string4(a5),a3		*now copy field 3 to temp string4
	lea	field_3(a5),a1
	qmove.b	(a1)+,(a3)+ 		      	*copy first "
move_string1:
	move.b (a1)+,d0 	*get yer actual character
	beq string_error 	*we should see delimeter before we get to 0
	cmpi.b #$22,d0 	*delimeter?
	beq.s ms1_done
	qmove.b d0,(a3)+ 	 *store byte in code buffer at pc
	bra.s move_string1
ms1_done:
	move.b	d0,(a3)+	*copy last "
**now d6 is length of string so we dc.b that first using printnum_mem
	lea	field_3(a5),a0
	bsr.l	printnum_mem	*into field 3, now a comma
	qmove.b	#0x2c,(a0)+	*now copy temp_string4(a5) to a0 (field3)

	lea temp_string4(a5),a1		*now copy temp string4 to field 3
	move.l	a0,a3			*field 3
	qmove.b	(a1)+,(a3)+ 		      	*copy first "
move_string2:
	move.b (a1)+,d0 	*get yer actual character
	beq string_error 	*we should see delimeter before we get to 0
	cmpi.b #$22,d0 	*delimeter?
	beq.s ms2_done
	qmove.b d0,(a3)+ 	 *store byte in field_3
	bra.s move_string2
ms2_done:
	qmove.b	d0,(a3)+	*copy last "
	clr.b	(a3)		*terminate
	lea	field_3(a5),a1	*debug purps
;	debug
	bsr	dcb
;	bsr	even		*removed for 415
	rts

	rts_	"p_string_directive"
**get length of quotes delimited string in a1 in d0
get_string_length:
	qmove.l	#0,d0
	addq.l #1,a1 		*skip "
count_string:
	move.b	(a1)+,d6 	*get yer actual character
	bne.s	string_ok
	bra	string_error 	 *we should see delimeter before we get to 0
string_ok:
	cmpi.b	#$22,d6 	*delimeter?
	beq.s	cs_done
	addq.l	#1,d0 		*inc pc
	bra.s	count_string
cs_done:
	rts_	"get_p_string_length"
	
**cstring defines a c string as string,0
c_string:
	lea	field_3(a5),a1		*the string
	cmpi.b	#$22,(a1)
	bne	string_error		*no open quotes
**find end of line
feol20:	tst.b	(a1)+
	bne.s	feol20
	subq.l	#1,a1
;	move.w	#",0",(a1)+
	qmove.w	#0x2c30,(a1)+	*,0
	clr.b	(a1)
	lea	field_3(a5),a1	*debug purps
	bsr	dcb
;	bsr	even	*do an even - removed for 415
	rts

	rts_	"c_string"
	
*************************************************************************
***directives errors			*
comma_error:
 lea comma_text(pc),a0
 bsr pass1_error
 rts
;macro_err_1:
; lea macro1_text(pc),a0
; bsr pass1_error
; rts
opt_err:
 lea opt_text(pc),a0
 bsr pass1_error
 rts

define_space_warning:	
	tst.b	dsw_warn_flag_off(a5)
	bne.s	skip_ds_warn
	lea	space_warning(pc),a0
	bsr	pass1_warning
skip_ds_warn:
	rts

define_string_warning:
	lea	string_warning(pc),a0
	bsr	pass1_error
	rts
	
**********************4.10
*do data synthesises as ds.b	0 instruction so we get a toc entry
*for a data label rather than a code label.
do_data:		btst	#0,ppc_flags1(a5)	*ppc?
	beq.s	data_error		*no, can only use in ppc mode
	lea	field_2(a5),a1
	qmove.l	#"ds.w",(a1)+
	clr.b	(a1)
	lea	field_3(a5),a1
	qmove.b	#"0",(a1)+
	clr.b	(a1)
	move.b	#1,dsw_warn_flag_off(a5)
	bsr	dsw
	clr.b	dsw_warn_flag_off(a5)
	rts
data_error:
	lea	data_err1(pc),a0
	bsr	pass1_error
	rts

*set flag that makes globoff call rs	
do_globisrs:
	move.l	#1,globisrs_flag(a5)
	rts
		
*************************************************************************
	
**jump table for directives v3.16
	if PPC
directive_table:	toc_routine
	else
directive_table:
	endif
	global	directive_table
	bsr.l	dcb	*0
	rts44
	
	bsr.l	dcw	*1
	rts44
	
	bsr.l	dcl	*2
	rts44
	
	bsr.l	dsb	*3
	rts44
	
	bsr.l	dsw	*4
	rts44

	bsr.l	dsl	*5
	rts44

	bsr.l	rs_byte	*6
	rts44
	
	bsr.l	rs_word	*7
	rts44
	
	bsr.l	rs_long	*8
	rts44
	
	bsr.l	even_ok		*v4, switch back on auto align
	rts44
	
	bsr.l	options	*10
	rts44
	
	bsr.l	macro	macro	*11
	rts44
	
	bsr.l	endm	endm	*12
	rts44
	
	bsr.l	do_debug	*13
	rts44
	
	bsr.l	ifne	ext	*14
	rts44
	
	bsr.l	ifeq	ext	*15
	rts44
	
	bsr.l	endc	ext	*16
	rts44
	
	bsr.l	endc	ext v3.83	endif	*17
	rts44
	
	bsr.l	ifle	ext	*18
	rts44
	
	bsr.l	ifgt	ext	*19
	rts44
	
	bsr.l	ifge	ext	*20
	rts44
	
	bsr.l	iflt	ext	*21
	rts44
	
	bsr.l	rs_reset	*22
	rts44
	
	bsr.l	incbin		*23
	rts44
	
	bsr.l	set	v1.02	*24
	rts44

	bsr.l	repeat	v1.02	*25
	rts44
	
	bsr.l	until_gt	*26
	rts44
	
	bsr.l	until_ge
	rts44
	
	bsr.l	until_eq
	rts44
	
	bsr.l	until_ne
	rts44
	
	bsr.l	until_lt
	rts44
	
	bsr.l	until_le	
	rts44
	
	bsr.l	ifd	ext	*32
	rts44
	
	bsr.l	ifnd	ext	*33
	rts44
	
	bsr.l	fail		*34
	rts44
	
	bsr.l	ifc	*if compare string	*35
	rts44
	
	bsr.l	ifnc	*if not compare string	*36
	rts44
	
**v3.xx onwards
	bsr.l	global	def	mpw	*37
	rts44
	
	bsr.l	global	xdef	devpac	*38
	rts44
	
	bsr.l	global	global	me!	*39
	rts44
	
	bsr.l	global	public	rob	*40
	rts44
	
	bsr.l	extern	ref	*41
	rts44
	
	bsr.l	extern	xref	*42
	rts44
	
	bsr.l	extern	extern	*43
	rts44
	
	bsr.l	defall		*44
	rts44
	
	bsr.l	else	ext	*45
	rts44
	
	bsr.l	tron	trace on ext	*46
	rts44
	
	bsr.l	troff	trace off ext	*47
	rts44
	
	bsr.l	requ	requ	*48
	rts44
	
	bsr.l	requ	equr
	rts44
	
**v3.6 onwards
	bsr.l	do_title	title "string"
	rts44
	
	bsr.l	do_input	input "string"	*51
	rts44
	
	bsr.l	do_output	output "string"
	rts44
	
	bsr.l	go_byte	global offset (globoff)
	rts44
	
	bsr.l	go_word
	rts44
	
	bsr.l	go_long	*55
	rts44
	
	bsr.l	go_reset
	rts44
	
	bsr.l	dcoff
	rts44
	
**v4 onwards	
	bsr.l	set_ppc	*proc_ppc - in directives 3
	rts44
	
	bsr.l	set_68k	*proc_68k - in directives 3
	rts44
		*8 bytes/ entry
	bsr.l	align_it	*in directives 3
	rts44
	
	bsr.l	import_lab	*61
	rts44
	
	bsr.l	ppc_rs_half	*rs.h
	rts44
	
	bsr.l	ppc_rs_half	*globoff.h
	rts44
	
	bsr.l	ifne	ext - if!	*64
	rts44
	
	bsr.l	do_toc_routine	*65
	rts44
	
	bsr.l	set_entry	*entry directive
	rts44
		
	bsr.l	extern_data
	rts44
	
	bsr.l	ppc_ds_h	*68
	rts44
	
	bsr.l	ppc_dch		*dc.h (16 bit)
	rts44
		
	bsr.l	rs_long	*70
	rts44
			     	     *rs.d
	bsr.l	dsl		*ds.d
	rts44
	
	bsr.l	dcl		*dc.d
	rts44
	
	bsr.l	code_section
	rts44
	
	bsr.l	data_section
	rts44
		
	bsr.l	p_string	*75
	rts44
	

	bsr.l	c_string
	rts44
	
	bsr.l	do_data
	rts44
	
	bsr.l	do_rs_align
	rts44
	
	bsr.l	rs_auto_align
	rts44
	
**v5 onwards
***** llbls-rp200797 ******
	bsr.l	local_section		*80
	rts44
	
***** end of  llbls-rp200797 ********

***** df.d - sb010897 ******
	bsr.l	define_float_double		
	rts44
***** df.s - sb010897 ******
	bsr.l	define_float_single	*ppc_float_defs	
	rts44
**f5pl
**file process_internal_strings
	bsr.l	handle_equ$
	rts44
	extern	handle_equ$
	
	bsr.l	handle_left$	*84
	rts44
	extern	handle_left$
	
	bsr.l	handle_mid$	*85
	rts44
	extern	handle_mid$
	
	bsr.l	handle_right$
	rts44
	extern	handle_right$
	
	
	bsr.l	handle_asc$
	rts44
	extern	handle_asc$
	
	bsr.l	handle_len
	rts44
	extern	handle_len
	
	bsr.l	handle_str$
	rts44
	extern	handle_str$

	bsr.l	handle_chr$	*90
	rts44
	extern	handle_chr$
	bsr.l	handle_concat$
	rts44
	extern	handle_concat$	
	bsr.l	handle_bin$
	rts44
	extern	handle_bin$
	bsr.l	define_sin_single
	rts44
	extern	define_sin_single
	bsr.l	define_sin_double
	rts44
	extern	define_sin_double
	bsr.l	clearlog	*95
	rts44
	extern	clearlog	*file f5pl
	bsr.l	goto_xy
	rts44
	extern	goto_xy
	bsr.l	send_print
	rts44
	extern	send_print
	bsr.l	pause
	rts44
	extern	pause
	bsr.l	beep
	rts44
	extern	beep
	bsr.l	print_to_log	*to_log - 100
	rts44
	extern	print_to_log

	bsr.l	swg_high_directive
	rts44
	extern	swg_high_directive
	bsr.l	swg_med_directive
	rts44
	extern	swg_med_directive
	bsr.l	swg_low_directive
	rts44
	extern	swg_low_directive
	bsr.l	swg_off_directive
	rts44
	extern	swg_off_directive
	bsr.l	set_finder_size	*105
	rts44
	extern	set_finder_size
	bsr.l	do_macros_first
	rts44
	bsr.l	do_macros_last
	rts44
	bsr.l	do_size_68k
	rts44
	bsr.l	do_size_ppc
	rts44
	bsr.l	do_break
	rts44
	extern	do_break
	bsr.l	handle_fndc
	rts44
	extern	handle_fndc
	bsr.l	do_globisrs
	rts44	  
;	nop
**Directives can have alpha chars, no numbers
**a dot is char e and a $ is char 4
xcb	macro

	ifeq dir_conv-1		; second table is full strings, padded to 16 bytes with zeros.
	
	
mylen:	len	\1
mylen:	set	mylen-2
mylen:	set	16-mylen
	dc.b	\1
	
	dc.b	0
mylen	set		mylen-1
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif


		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif


		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif


		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif
		ifne		mylen
		dc.b	0
mylen		set		mylen-1
		endif


	else			; first table is just the first bytes of every string

	
; Improved Key: RP 170198 [a$]:	left$	\1,2
; Improved Key: RP 170198 [b$]:	left$	\1,1
; Improved Key: RP 170198 [c$]:	concat$	[a$],[b$]
; Improved Key: RP 170198	dc.b	[c$]

; Improved Key: RP 170198  ---BLOCK START---

[a$]:	mid$	\1,1,1
mykey:	asc$ 	[a$]


mylen:	len	\1
mylen:	set	mylen-3		; get rid of length off quotes plus first character
	
		ifne		mylen
[a$]:	 	mid$	\1,2,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,3,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,4,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif


		ifne		mylen
[a$]:	 	mid$	\1,5,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,6,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,7,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,8,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif


		ifne		mylen
[a$]:	 	mid$	\1,9,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,10,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,11,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,12,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif


		ifne		mylen
[a$]:	 	mid$	\1,13,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,14,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,15,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif
		ifne		mylen
[a$]:	 	mid$	\1,16,1
myvar:		asc$ 	[a$]
mykey:		set	myvar+mykey
mylen		set		mylen-1
		endif


myvar:	set	mykey/256
myvar:	set	myvar*256
mykey:	set	mykey-myvar		; I only want lower 8 bits

	dc.b	mykey
; Improved Key: RP 170198  ---BLOCK END---



	endif
	
	endm

	
dir_conv:	set	2
		repeat
		align 4
		
		if PPC
			ifeq dir_conv-2		; do first one as byte table
directives_byte:	data
			else
directives_full:	data
			endif
		else
			ifeq dir_conv-2	; do second one as byte table
directives_byte:
			else
directives_full:
			endif
		endif
		xcb	"DC.B"
		xcb	"DC.W"
		xcb	"DC.L"
		xcb	"DS.B"
		xcb	"DS.W"
		xcb	"DS.L"
		xcb	"RS.B"
		xcb	"RS.W"
		xcb	"RS.L"
		xcb	"EVEN"
		xcb	"OPT"
		xcb	"MACRO"
		xcb	"ENDM"
		xcb	"DEBUG"
		xcb	"IFNE"
		xcb	"IFEQ"
		xcb	"ENDC"
		xcb	"ENDIF"
		xcb	"IFLE"		;	V2.0
		xcb	"IFGT"
		xcb	"IFGE"
		xcb	"IFLT"
		xcb	"RSRESET"
		xcb	"INCBIN"
		xcb	"SET"
		xcb	"REPEAT"
		xcb	"UNTIL_GT"
		xcb	"UNTIL_GE"
		xcb	"UNTIL_EQ"
		xcb	"UNTIL_NE"
		xcb	"UNTIL_LT"
		xcb	"UNTIL_LE"
		xcb	"IFD"
		xcb	"IFND"
		xcb	"FAIL"
		xcb	"IFC"
		xcb	"IFNC"
		xcb	"DEF"
		xcb	"XDEF"
		xcb	"GLOBAL"
		xcb	"PUBLIC"		*COMPATIBLE WITH DEVPAC, MPW AND ME AND ROB
		xcb	"REF"
		xcb	"XREF"
		xcb	"EXTERN"
		xcb	"DEFALL"
		xcb	"ELSE"
		xcb	"TRON"
		xcb	"TROFF"
		xcb	"REQU"
		xcb	"REG"
		xcb	"TITLE"
		xcb	"INPUT"
		xcb	"OUTPUT"
		xcb	"GLOBOFF.B"
		xcb	"GLOBOFF.W"
		xcb	"GLOBOFF.L"
		xcb	"GLOBRESET"
		xcb	"DCOFF"
**V4
	xcb	"PROC_PPC"
	xcb	"PROC_68K"	*V4
	xcb	"ALIGN"
	xcb	"IMPORT"
	xcb	"RS.H"
	xcb	"GLOBOFF.H"
	xcb	"IF"
	xcb	"TOC_ROUTINE"
	xcb	"ENTRY"
	xcb	"EXTERN_DATA"
	xcb	"DS.H"
	xcb	"DC.H"
	xcb	"RS.D"
	xcb	"DS.D"
	xcb	"DC.D"
	xcb	"CODE_SECT"
	xcb	"DATA_SECT"
	xcb	"PSTRING"
	xcb	"CSTRING"
	xcb	"DATA"
	xcb	"RS_ALIGN"
	xcb	"RS_AUTO_ALIGN"
**F5
	xcb	"SECTION"	****** LLBLS-RP200797 ******
	xcb	"DF.D"
	xcb	"DF.S"	*Define Float double and single ****** F5 - SB010897*******
	
**f5pl - process internal strings
	xcb	"EQU$"
	xcb	"LEFT$"
	xcb	"MID$"
	xcb	"RIGHT$"
	xcb	"ASC$"
	xcb	"LEN"
	xcb	"STR$"
	xcb	"CHR$"
	xcb	"CONCAT$"
	xcb	"BIN$"
**F5 trig
	xcb	"DFSIN.S"
	xcb	"DFSIN.D"
	xcb	"CLRLOG"
	xcb	"GOTOXY"
	xcb	"PRINT"
	xcb	"PAUSE"
	xcb	"BEEP"
	xcb	"PRINTLOG"
	xcb	"SWG_HIGH"
	xcb	"SWG_MED"
	xcb	"SWG_LOW"
	xcb	"SWG_OFF"
	xcb	"FNDRSIZE"
	xcb	"MACS_FIRST"
	xcb	"MACS_LAST"
	xcb	"SIZE_68K"
	xcb	"SIZE_PPC"
	xcb	"BREAK"
	xcb	"FNDC"
	xcb	"GLOB_IS_RS"
	DC.L	0,0
	
dir_conv:	set	dir_conv-1
	until_eq	dir_conv
	
**Not used in 5.1
;directives_lower:	dc.b	"dc.b",0,"dc.w",0,"dc.l",0,"ds.b",0,"ds.w",0
;	 dc.b	 "ds.l",0,"rs.b",0,"rs.w",0,"rs.l",0,"even",0
;	 dc.b	 "opt",0,"macro",0,"endm",0,"debug",0
;	 dc.b	 "ifne",0,"ifeq",0,"endc",0,"endif",0,"ifle",0	 v2.0
;	 dc.b	 "ifgt",0,"ifge",0,"iflt",0,"rsreset",0
;	 dc.b	 "incbin",0,"set",0,"repeat",0,"until_gt",0
;	 dc.b	 "until_ge",0,"until_eq",0,"until_ne",0
;	 dc.b	 "until_lt",0,"until_le",0,"ifd",0,"ifnd",0,"fail",0
;	 dc.b	 "ifc",0,"ifnc",0
;	 dc.b	 "def",0,"xdef",0,"global",0,"public",0	*compatible with devpac, mpw and me and rob
;	 dc.b	 "ref",0,"xref",0,"extern",0
;	 dc.b	 "defall",0,"else",0,"tron",0,"troff",0
;	 dc.b	 "requ",0,"reg",0
;	 dc.b	 "title",0,"input",0,"output",0
;	 dc.b	 "globoff.b",0,"globoff.w",0,"globoff.l",0
;	 dc.b	 "globreset",0,"dcoff",0
;**V4
;	 dc.b	 "proc_ppc",0,"proc_68k",0	 *v4
;	 dc.b	 "align",0,"import",0,"rs.h",0,"globoff.h",0,"if",0,"toc_routine",0
;	 dc.b	 "entry",0,"extern_data",0,"ds.h",0,"dc.h",0,"rs.d",0,"ds.d",0,"dc.d",0
;	 dc.b	 "code_sect",0,"data_sect",0,"pstring",0,"cstring",0,"data",0
;	 dc.b	 "rs_align",0,"rs_auto_align",0
;	 dc.b	 "section",0     ******* LLBLS-RP200797 *******
;	 dc.b	 "df.d",0,"df.s",0	 *Define Float double and single ****** F5 - SB010897*******
;**f5pl - process_internal_strings
;	 dc.b	 "equ$",0,"left$",0,"mid$",0,"right$",0
;	 dc.b	 "asc$",0,"len",0,"str$",0,"chr$",0,"concat$",0
;	 dc.b	 "bin$",0
;**F5 trig
;	 dc.b	 "dfsin.s",0,"dfsin.d",0
;	 dc.b	 "clrlog",0,"gotoxy",0,"print",0,"pause",0,"beep",0,"printlog",0
;	 dc.b	 "swg_high",0,"swg_med",0,"swg_low",0,"swg_off",0,"fndrsize",0
;	 dc.b	 "macs_first",0,"macs_last",0,"size_68k",0,"size_ppc",0,"break",0
;	 dc.b	 "fndc",0,"glob_is_rs"
;	 dc.b	 0,0,0,0,0
	align
string_warning:	dc.b	"Can not use a string as a numeric constant with this "
	dc.b	"directive.",13,0
string_text:	DC.B	"Invalid string - end quotes expected.",13,13,0
size_text:	dc.b	"Number too big to fit in a byte.",13,13,0
size_text_w:	dc.b	"Number too big to fit in a word.",13,13,0
comma_text:	dc.b	"Comma expected in operand field.",13,13,0
bytes_expected:	dc.b	"Number of bytes expected.",13,13,0
words_expected:	dc.b	"Number of words expected.",13,13,0
space_error_text:	dc.b	"Can't define a negative quantity.",13,13,0
	align	4
longs_expected:	dc.b	"Number of longs expected.",13,13,0
;macro1_text:	dc.b	"Macros not implemented yet.",13,13,0
opt_text:	dc.b	"Unrecognised option.",13,13,0
incbin_error_t:	DC.B	"Could not find this binary file - Not included.",13,13,0
**v2 errors
set_error:	DC.B	"Can only SET EQUated and SET labels",13,"This is a code or data label.",13,13,0
rep_err_1:	DC.B	"**FATAL** Repeats can't be nested.",13,13,0
until_err_1:	DC.B	"**FATAL** Not in a repeat loop.",13,13,0
fail_text:	DC.B	"**FATAL** User fail.",13,0
**V3.XX ERRORS
space_warning:	DC.B	"**POSSIBLE FATAL WARNING** - Zero space defined!",13,13,0
gnt_text:	DC.B	"Global label has not been defined - ",0
exc_text:	DC.B	".",13,13,0
ext_def_text:	DC.B	"External label already defined or declared in this file - ",0
link_only_text:	DC.B	"WARNING - This directive can only be used when "
	dc.b	" outputting linkable files.",13,13,0
	align
glob2long_text:	dc.b	"Global label too long (28 chars max) ",0
	align
glob2_text:	DC.B	"Global label defined twice - ",0
	align
quotes_expected:	cstring "Double quotes expected in field 3",13
	align
	
; ****** LLBLS-RP200797 ******
glob3_text:	cstring	"**WARNING** You are giving global scope to local label!",13
	align
ext_local_text:	cstring	"**WARNING** You are referencing an external local label!",13
	align
; ****** LLBLS-RP200797 ******
fatal_data:	dc.b	"***FATAL*** Out of memory for data buffer - please quit.",13,0
	align	 
set_error1:	cstring	"Nil label being set!",13
	align
set_text:	dc.b	"Value being set = ",0
	align
d_crtext:	dc.b	13,0
	align
rs_align_error:	dc.b	"Unrecognised RS alignment boundary - 2,4,8,32,64 and 256 allowed.",13,13,0
	align	

directive_error_text:	cstring	"Can't use this directive in PPC mode.",13,13
	align
no_dcl_ppc:	dc.b	"Fantasm cannot (yet) define 64 bit values.",13,0
	align
dsh_ppc_only:	dc.b	"The ds.h directive can only be used in PPC mode.",13,0
	align
data_err1:	dc.b	"Can't use this directive in 68k mode.",13,13,0
	align
auto_align_error:	cstring	"Invalid parameter to rs_auto_align directive - on or off allowed."
	align		
one_substituted:	cstring	"Defaulting to 1 for operand.",13
	align
rs_error2:	cstring	"RS on Local label!",13
	align

**************************************************************************
numb_buff:	DS.B 40 	*NUMBERS FROM DC'S ETC GO TO EVAL HERE
	align
d_abs_ref_text:	dc.b	"**ERROR** Absolute reference - code is not position independent,",13
	dc.b	"it needs to be (pc) addressing mode - for example: ",13
	dc.b	"  lea	fred(pc),a0",13,13,0
	align
section_not_supported:	dc.b	"The code_sect and data_sect directives are no longer supported.",13
	dc.b	"Please see the 'data' directive in your manual.",13,0
	align
hash_err:	dc.b	"Illegal hash character - hash is not used with RS.",0
	align
get_ge_space:	ds.b	64	*space for label copy
	align
*************************************************************************
	public	directive,comma_error,define_string_warning,get_numb
	global	string_text,even_ok,rs_byte,ppc_rs_word,ppc_rs_long
	global	extern_data,ppc_rs_half,get_string_length
	global	dcb,accumulate_rs,dcw_ppc,set
	global	dcw_ppc_ent
	
	extern	dir_search,pass1_error,search_lab
	extern	search_labp2,set_directory,inc_f_name,readit,pass2_error,defined_error
	extern	get_two_strings,field_3_new,compare_strings,field_2_new
	extern	recurs_eval,printit,pass2_warning,printnum_mem
**externs in directive_2
	extern	ifd,ifnd,ifc,ifnc,ifne,ifeq,ifgt,ifge,iflt,ifle,endc
	extern	else,tron,troff,requ
	extern	do_title,do_input,do_output,make_temp_fsspec
	extern	go_reset,go_byte,go_word,go_long,open_folder,pass1_warning
**externs in directives_3.s
	extern	set_ppc,set_68k,align_it,import_lab,do_toc_routine,set_entry,default_align
	extern	pass2_advice
**f5
	extern	lab_tree_search,lab_tree_insert,equ_tree_search,equ_tree_insert
	extern	define_float_single,define_float_double
**f5.1
	extern	do_macros_first,do_macros_last,do_size_68k,do_size_ppc
	extern	printnum,dir_search_quick