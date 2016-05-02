**Version 5.1
**Needs instruction in d1.l
put_ppc:	

	movea.l code_buffer(a5),a3
	qmove.l d1,(a3)+ 	 *insert instruction in buffer
	addq.l #4,pc(a5) 	*inc pc
	qmove.l	a3,code_buffer(a5)
**no r2d2 in 510a5
;	bra.s	its_pass2	*uncomment to take swg out
;	tst.b	frag_loaded(a5)
;	beq.s	its_pass2	*what swg?

**call r2d2 if pass 1
	if	68K
	rts
	else
	move.l	pass_id(a5),d0
	btst	#1,d0
	bne.s	its_pass2
	
; check if its actually running
	move.l	r2d2_prefs(a5),d0
	cmp.l	#1,d0
	ble.s	its_pass2
;	lea	pass1_warning_offset(pc),a2	*the code we run to report a warning
	macs_last
	lwz	r22,[t]pass1_warning_offset(rtoc)
	macs_first
	move.l	d1,d0	*the current instruction
	move.l	a2,d1	*ptr to report error
	lea	r2d2_prefs(a5),a3	*pointer to prefs flags
	move.l	a3,d2	*prefs
	lea	field_1(a5),a1		*point to field 3 comes in r6
**call r2d2
	macs_last
	mr	r6,r21	*field 1 ptr
	stwu	sp,-112(sp)	; parameter area and linkage area for subroutine
	bl	r2d2
	addi	sp,sp,112

;	lea	bp_proc_pointer(pc),a0
;	macs_last
;	illegal
;	stw	R2,20(sp)	*save my RTOC
;	lwz	r0,0(r20) 	*get callee address
;	mtctr	r0		*prepare branch
;	lwz	R2,4(r20)	*set callee RTOC
;	bctrl			*bsr to callee
;	lwz	r2,20(sp)	*get my toc back
*;*Tear down stack frame
;
;	addi	sp,sp,112
;
;	macs_first

;	else
;	lea	bp_proc_pointer(pc),a0
;	move.l	r2d2_fd(a5),(a0)	*this is a pointer to fant_to_double's fd
;	
;	bsr	bp_univ_pointer	*returns a pointer in d0, or -1 if failed
its_pass2:
	rts_	"put_ppc"
**little bit of patch code so native can get at the warning code
**on the stack we will have the reutnr addr and the ptr to the string
pass1_warning_offset:	toc_routine
; remember this is c calling conventions, so parameters are _pushed_ right to left
; so they can be referenced (_popped_) left to right, as would be needed for variable
; arguments...
;	move.l	(sp)+,a1		; return address
;	move.l	(sp)+,a0		; the error
;	move.l	(sp)+,a2		; the warning

;	move.l	a1,-(sp)	*now just return addr on stack
**gets warning in r5, additional in r6
	macs_last
	mr	r20,r5
	mr	r22,r6
	mflr	r3
	stwu	r3,-4(sp)	*save return
	macs_first
	move.l	a2,-(sp)	; restack warning (for now)
	bsr.l	pass1_warning_always	*cant switch these off
	move.l	(sp)+,d0	; unstack warning
	beq.s	no_log_message	; zero is no log message

	move.l	d0,a0
	bsr.l	send_to_log
no_log_message:

	rts_	"pass1_warning_offset"
	endif	*of if PPC
******************************************************************
branch_l:
	btst	#3,postfix_flags(a5)
	bne.s	blr			*really blr
	btst	#4,postfix_flags(a5)
	bne	bctr
	btst	#1,postfix_flags(a5)
	beq.s	not_absoi
	bset	#1,d1		*set aa flag
not_absoi:
	btst	#2,postfix_flags(a5)	*lk
	beq.s	not_uplinki
	bset	#0,d1		*set lk
not_uplinki:
**now get the offset
	qmove.l	pc(a5),d0	*we use pc
	btst	#1,flags(a5)
	beq.s	b_p1	*pass 1 just use zero
	qmove.l	d1,-(sp)
	lea	field_3(a5),a3
	bsr.l	get_lab_value
	move.l	d1,d2
	qmove.l	(sp)+,d1
	tst.w	d2
	bmi	bra_error3
b_p1:
	qmove.l	d0,d3	     
;	tst.l	d3
;	bne.s	got_good_bra2
;	move.l	pc(a5),d3
;got_good_bra2:

;	move.l	labels(a5),a4	*table to be searched
;	 bsr	 search_lab	 *search for this label
;	 move.l	(sp)+,d1	 get inst back
;	 tst.w	 d0	 	 *did we find it?
;	 bge.s	 do_normal_branchbi	 *yes
;	 btst	 #1,flags(a5)	 pass 2?
;	 bne	 bra_error3	 yes, must be undefined label
;	 move.l	pc(a5),d3	 simulate fwd branch for pass 1
;	 addq.l	#4,d3	 so we get pc+6-pc+2=fwd branch!
;	 bra.s	 got_branch1bi	 
;do_normal_branchbi:
;**calc offset
;	 move.l	lab_val(a5),a4
;	 move.l	0(a4,d0.l*4),d3
got_branch1bi:
	qmove.l	pc(a5),d7 	*get pc
	sub.l	d7,d3 		*pc-label gives offset
	cmpi.l	#33554430,d3	*bx is 24 bit
	bgt	bi_error	*eeek
	if PPC
	macs_last
	movei	`temp_reg1,-33000000
	cmpw	r13,`temp_reg1
	macs_first
	else
	cmpi.l	#-33000000,d3
	endif
	blt	bi_error
	andi.l	#$03fffffc,d3		*make quad
	or.l	d3,d1		*final inst
	bsr	put_ppc
	rts_	"branch_i"
		
***ppc assemblers 1
blr:	bsr.l	get_ops_ppc
	tst.l	d1
	beq.s	lr_op_ok
	bsr	ops_ignored
lr_op_ok:
	qmove.l	#$4e800020,d1
	btst	#1,postfix_flags(a5)
	bne	not_abs_in_link
	btst	#5,postfix_flags(a5)
	beq.s	not_predict1
	bset	#21,d1
not_predict1:
	btst	#2,postfix_flags(a5)	*lk
	beq.s	not_uplink3
	bset	#0,d1		*set lk
not_uplink3:

	bsr	put_ppc		      *this routine is a time waste!
	rts_	"blr"

bctr:
	bsr.l	get_ops_ppc
	tst.l	d1
	beq.s	op_ok_ctr
	bsr	ops_ignored		     *this isntruction does not require any operands!
op_ok_ctr:
	qmove.l	#$4e800000,d1
	qmove.l	#528*2,d2
	or.l	d2,d1			*make to ctr
	btst	#1,postfix_flags(a5)
	bne	not_abs_in_link
	btst	#5,postfix_flags(a5)
	beq.s	not_predict2
	bset	#21,d1
not_predict2:
	btst	#2,postfix_flags(a5)	*lk
	beq.s	not_uplink2
	bset	#0,d1		*set lk
not_uplink2:
	bsr	put_ppc		      *this routine is a time waste!

	rts_	"bctr"
	

**********logical conditional branch - bt,bf
b_logical:
	btst	#1,postfix_flags(a5)
	beq.s	not_absol
	bset	#1,d1		*set aa flag
not_absol:
	btst	#2,postfix_flags(a5)	*lk
	beq.s	not_uplinkl
	bset	#0,d1		*set lk
not_uplinkl:
	btst	#3,postfix_flags(a5)	*to lr?
	bne.s	b_log_to_link
	btst	#4,postfix_flags(a5)	*to ctr?
	bne	b_log_to_ctr	
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	bsr	get_two
	tst.w	d1
	beq.s	b_lo_ok
	addq.l	#4,sp
	rts
b_lo_ok:
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*cant be a reg!
	tst.l	d2
	bmi	bad_first
	cmpi.l	#31,d2
	bgt	bad_first
	qmove.l	(sp)+,d1
	swap	d2
	or.l	d2,d1		*set bi

**address in d3
	cmpi.w	#3,second_type(a5)
	bne	bad_second	
	bra	got_branch1	*calc offset and insert etc...
	rts_	"b_logical"

b_log_to_link	
	btst	#1,d1		*abs?
	bne	not_abs_in_link	*yes
	qmove.l	d1,-(sp)
	bsr.l	get_ops_ppc
	bsr	get_one
	tst.w	d1
	beq.s	b_lo_oklr
	addq.l	#4,sp
	rts
b_lo_oklr:
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*cant be a reg!
	tst.l	d2
	bmi	bad_first
	cmpi.l	#31,d2
	bgt	bad_first
	qmove.l	(sp)+,d1
	swap	d2
	or.l	d2,d1		*set bi
	andi.l	#$4fff0001,d1
	or.l	#$0c000020,d1	*make blr insts
	bsr	put_ppc
	rts_	"b_log_to_link"

b_log_to_ctr	
	btst	#1,d1		*abs?
	bne	not_abs_in_link	*yes
	move.l	d1,-(sp)
	bsr.l	get_ops_ppc
	bsr	get_one
	tst.w	d1
	beq.s	b_lo_okctr
	addq.l	#4,sp
	rts
b_lo_okctr:
	cmpi.w	#3,first_type(a5)
	bne	bad_first	*cant be a reg!
	tst.l	d2
	bmi	bad_first
	cmpi.l	#31,d2
	bgt	bad_first
	qmove.l	(sp)+,d1
	swap	d2
	or.l	d2,d1		*set bi
	andi.l	#$4fff0001,d1
	or.l	#$0c000420,d1	*make bctr insts
	bsr	put_ppc
	rts_	"b_log_to_ctr"
		
********conditional branch - 15 bits tops
bc:
**a4->end of opcode text
*it is possible to get:
*bne	target
*bne	crx,target
*bc	4,10,target	
*they all are the same thing
*so we can say that if th number of op_codes is one, its just a target. if 2, theres a crx
*and if three, its the normal instruction

****basic code in d1
**posssible to get bc	bo,bi,target
**so first examine source_op - we use 

**if "a" flag is set, set bit 1 (31) aa
	btst	#1,postfix_flags(a5)
	beq.s	not_abso
	bset	#1,d1		*set aa flag
not_abso:
	btst	#2,postfix_flags(a5)	*lk
	beq.s	not_uplink
	bset	#0,d1		*set lk
not_uplink:
**check for c as second char of branch inst.
	qmove.l	d1,-(sp)	save inst
	btst	#3,postfix_flags(a5)
	bne	to_link_register
	btst	#4,postfix_flags(a5)
	bne	to_count_register

	bsr.l	get_ops_ppc	*get upto 5 operands! returns number of ops in d1
	tst.l	d1
	beq	op_needed
	cmpi.w	#1,d1
	beq.s	straight_label	*just one operand
	cmpi.w	#2,d1
	beq.s	just_crx

	bsr	get_bo_bi
	lea	op_3(a5),a3
	bra.s	do_label

just_crx:

	lea	source_op(a5),a3
	cmpi.w	#"CR",(a3)
	beq.s	got_cr
	cmpi.w	#"cr",(a3)
	bne	cr_error	*no cr text
got_cr:
**just number
	qmove.b	2(a3),d0
	tst.b	3(a3)		*406
	bne	bad_cr	*single digit please!
**calc cr value	
	subi.b	#"0",d0
	bmi	bad_cr	*less than zero!
	cmpi.b	#7,d0
	bgt	bad_cr	*>7
**now multiply the basic bi by 4*d0
	lsl.w	#2,d0
	qmove.l	(sp),d1			*get inst back
**bi is 11-15 (ppc numbering
	swap	d1		*bi is now lower 5 bits
	andi.l	#%11111,d1
	andi.l	#%11111,d0
	add.w	d1,d0		*new bi
	swap	d0
	qmove.l	(sp)+,d1
	or.l	d0,d1		*new bi in inst
	qmove.l	d1,-(sp)	*back on stack
	lea	dest_op(a5),a3
	bra.s	do_label
				
straight_label:
	lea	source_op(a5),a3	
do_label:
	clr.l	d3
	btst	#1,flags(a5)
	beq.s	bc_p1		*pass1
	bsr.l	get_lab_value
	move.l	d0,d3
;	tst.l	d3
	bne.s	got_good_bra
**must be external
;	move.l	pc(a5),d3
got_good_bra:
	move.w	d1,d2	
;	tst.w	d2
	bne	bra_error2
	bra.s	bc_p2
bc_p1:
;	move.l	pc(a5),d3	*return pc on pass1	
bc_p2:
;	move.l	labels(a5),a4	*table to be searched
;	bsr	search_lab	*search for this label
	qmove.l	(sp)+,d1	get inst back
;	tst.w	d0		*did we find it?
;	bge.s	do_normal_branch	*yes
;	btst	#1,flags(a5)	pass 2?
;	bne	bra_error2	yes, must be undefined label
;	move.l	pc(a5),d3	simulate fwd branch for pass 1
;	addq.l	#4,d3	so we get pc+6-pc+2=fwd branch!
;	bra.s	got_branch1	
;do_normal_branch:
;**calc offset
;	move.l	lab_val(a5),a4
;	move.l	0(a4,d0.l*4),d3

got_branch1:
	
	qmove.l	pc(a5),d7 	*get pc
	sub.l	d7,d3 		*pc-label gives offset
	cmpi.l	#32760,d3
	bgt	bc_error
	cmpi.l	#-32700,d3
	blt	bc_error
	andi.l	#$0000fffc,d3		*make quad
	bra	got_target
to_link_register:
**change from
	lea	field_2(a5),a1
	cmpi.b	#"C",1(a1)		*check for bclr which means we have two operands
	beq.s	got_bcxx
	cmpi.b	#"c",1(a1)
	bne.s	not_bcxx
**now we have to get bo,bi and mix into inst
got_bcxx:
	bsr.l	get_ops_ppc
	bsr	get_bo_bi
	bra.s	no_op_lr
not_bcxx:
	bsr.l	get_ops_ppc
	tst.l	d1
	beq.s	no_op_lr
	cmpi.l	#1,d1
	beq.s	lr_ops_ok
	bsr	ops_ignored
lr_ops_ok:
	lea	source_op(a5),a3
	cmpi.w	#"cr",(a3)
	beq.s	do_cr_lr
	cmpi.w	#"CR",(a3)
	beq.s	do_cr_lr
	bsr	bad_op_lr	
	bra.s	no_op_lr
do_cr_lr:
**get cr
	qmove.b	2(a3),d0
	tst.b	3(a3)
	bne	bad_cr	*single digit please!
**calc cr value	
	subi.b	#"0",d0
	bmi	bad_cr	*less than zero!
	cmpi.b	#7,d0
	bgt	bad_cr	*>7
**now multiply the basic bi by 4*d0
	lsl.w	#2,d0
	qmove.l	(sp),d1			*get inst back
**bi is 11-15 (ppc numbering
	swap	d1		*bi is now lower 5 bits
	andi.l	#%11111,d1
	andi.l	#%11111,d0
	add.w	d1,d0		*new bi
	swap	d0
	qmove.l	(sp)+,d1
	or.l	d0,d1		*new bi in inst
	qmove.l	d1,-(sp)	*back on stack

no_op_lr:
	qmove.l	(sp)+,d1	*basic instruction
	btst	#1,d1
	bne	not_abs_in_link
	qmove.l	#$4c000000,d2	*bclr/bcctr
	andi.l	#$03ffffff,d1
	or.l	d2,d1		*is now bclr
	qmove.l	#$20,d3		*secondary=16dec<<1
	bra	got_target		
to_count_register:
**change from 
	lea	field_2(a5),a1
	cmpi.b	#"c",1(a1)		*check for bclr which means we have two operands
	beq.s	got_bccxx
	cmpi.b	#"C",1(a1)	
	bne.s	not_bccxx
**now we have to get bo,bi and mix into inst
got_bccxx:
	bsr.l	get_ops_ppc
	bsr	get_bo_bi
	bra.s	no_op_ctr
not_bccxx:

	bsr.l	get_ops_ppc
	tst.l	d1
	beq.s	no_op_ctr
	cmpi.w	#1,d1
	beq.s	ctr_ops_ok
	bsr	ops_ignored
ctr_ops_ok:

	lea	source_op(a5),a3
	cmpi.w	#"cr",(a3)
	beq.s	do_cr_ctr
	cmpi.w	#"CR",(a3)
	beq.s	do_cr_ctr
	bsr	ops_ignored	
	bra.s	no_op_ctr
do_cr_ctr:
**get cr
	qmove.b	2(a3),d0
	tst.b	3(a3)	*406
	bne	bad_cr	*single digit please!
**calc cr value	
	subi.b	#"0",d0
	bmi	bad_cr	*less than zero!
	cmpi.b	#7,d0
	bgt	bad_cr	*>7
**now multiply the basic bi by 4*d0
	lsl.w	#2,d0
	qmove.l	(sp),d1			*get inst back
**bi is 11-15 (ppc numbering
	swap	d1		*bi is now lower 5 bits
	andi.l	#%11111,d1
	andi.l	#%11111,d0
	add.w	d1,d0		*new bi
	swap	d0
	qmove.l	(sp)+,d1
	or.l	d0,d1		*new bi in inst
	qmove.l	d1,-(sp)	*back on stack

no_op_ctr:
	qmove.l	(sp)+,d1	*basic instruction
	btst	#1,d1
	bne	not_abs_in_link	*cant have bcctr(l)a
	qmove.l	#$4c000000,d2	*bclr/bcctr
	andi.l	#$03ffffff,d1
	or.l	d2,d1		*is now bclr
	qmove.l	#528*2,d3		*secondary=16dec<<1

got_target:
	or.l	d3,d1		*final inst
	btst	#5,postfix_flags(a5)
	beq.s	not_predict3
	bset	#21,d1
not_predict3:	bsr	put_ppc
	rts_	"bc"
	
bc_error:
;	bset	#7,flags(a5) 	*error detected flag
	btst	#1,flags(a5)
	beq.s	sim_no_branch 	      *only report on pass 2. 5.1 fix - on pass 1 we'll get this
				*if a single source file assembles to > 32k
 	qmove.l	d3,d0	offset in d0
	qmove.l	d0,-(sp)
	lea	bp_branch_text(pc),a0
	st	global_err(a5)
	addq.w	#1,error_count(a5)
;	bset	#7,flags(a5) 	   *error detected flag
	st	global_err(a5)
	qmove.l	a0,d0
	qmove.l	d0,error_string_save(a5)

	qmove.l a0,-(sp) 	 *save string
	bsr.l print_line		*print line
	qmove.l (sp)+,a0
	bsr.l printit		*and error
only_p2:
	qmove.l	(sp)+,d0	*print offset was....
	bsr.l	printnum_signed	*print signed long in d0
	lea	offset_bytes(pc),a0
	bsr.l	printit

sim_no_branch:
	qmove.l	#$40820000,d1
	bsr	put_ppc
	rts


***needs inst on stack!
get_bo_bi:
	move.l	(sp)+,a4	*return addr
**this is bo,bi
	lea	source_op(a5),a1
	bsr.l	get_op_code_num	*d1=-1 if failed
	tst.w	d1
	bmi.s	bad_bo		*bo number is bad
	tst.w	d0
	bmi.s	bad_bo		*bo<0
	cmpi.w	#31,d0
	bgt.s	bad_bo		*bo>31	
**now mix bo into insturction
	qmove.l	(sp)+,d1	*instruction
	swap	d1		*bo now starts at bit 5
	andi.l	#%11111,d0
	lsl.w	#5,d0		*shift bo to match
	or.l	d1,d0		*new bo
	swap	d0
	qmove.l	d0,-(sp)
**now do bi
	lea	dest_op(a5),a1
	bsr.l	get_op_code_num	*d1=-1 if failed
	tst.w	d1
	bmi.s	bad_bi		*bo number is bad
	tst.w	d0
	bmi.s	bad_bi		*bo<0
	cmpi.w	#31,d0
	bgt.s	bad_bi		*bo>31	
**now mix bi into insturction
	qmove.l	(sp)+,d1	*instruction
	swap	d1		*bi now starts at bit 0
	andi.l	#%11111,d0
	or.l	d1,d0		*new bo
	swap	d0
	qmove.l	d0,-(sp)	*inst back on stack
get_bo_bi_end:
	jmp	(a4)
	rts_	"get_bo_bi"

bad_bi:	addq.l	#4,sp		*inst is on stack
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	bad_bi_text(pc),a0
	bsr.l	pass2_error
	bra	get_bo_bi_end
	rts_	"bad_bi"
bad_bo:	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	bad_bo_text(pc),a0
	bsr.l	pass2_error
	bra	get_bo_bi_end
	rts_	"bad_bo"
	
sc:	move.l	d1,-(sp)
	bsr.l	get_ops_ppc
	tst.l	d1
	beq.s	sc_ok
	lea	no_ops_needed(pc),a0
	bsr.l	pass1_advice
sc_ok:	move.l	(sp)+,d1	
	bsr	put_ppc
	rts_	"ppc_system_call"
	
******

cr_logical:
	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#3,d1
	bne	not_3_for_crl
	lea	source_op(a5),a1
;	cmpi.w	#"cr",(a1)
;	beq	illegal_cr
;	cmpi.w	#"cr",(a1)
;	beq	illegal_cr
	bsr.l	get_op_code_num	*d1=-1 if failed
	tst.w	d1
	bmi	bad_first		* number is bad
	tst.w	d0
	bmi	bad_first		*<0
	cmpi.w	#31,d0
	bgt	bad_first		*>31	

**now mix bt into insturction
	qmove.l	(sp)+,d1	*instruction
	swap	d1		*bo now starts at bit 5
	andi.l	#%11111,d0
	lsl.w	#5,d0		*shift bo to match
	or.l	d1,d0		*new bt
	swap	d0
	qmove.l	d0,-(sp)

	lea	dest_op(a5),a1
;	cmpi.w	#"cr",(a1)
;	beq	illegal_cr
;	cmpi.w	#"cr",(a1)
;	beq	illegal_cr
	bsr.l	get_op_code_num	*d1=-1 if failed
	tst.w	d1
	bmi	bad_second		* number is bad
	tst.w	d0
	bmi	bad_second		*<0
	cmpi.w	#31,d0
	bgt	bad_second		*>31	

**now mix ba into insturction
	qmove.l	(sp)+,d1	*instruction
	swap	d1		*bo now starts at bit 5
	andi.l	#%11111,d0
;	lsl.w	#5,d0		*shift bo to match
	or.l	d1,d0		*new bt
	swap	d0
	qmove.l	d0,-(sp)

	lea	op_3(a5),a1
;	cmpi.w	#"cr",(a1)
;	beq	illegal_cr
;	cmpi.w	#"cr",(a1)
;	beq	illegal_cr
	bsr.l	get_op_code_num	*d1=-1 if failed
	tst.w	d1
	bmi	bad_third		* number is bad
	tst.w	d0
	bmi	bad_third		*<0
	cmpi.w	#31,d0
	bgt	bad_third		*>31	

**now mix bb into insturction
	qmove.l	(sp)+,d1	*instruction
;	swap	d1		*bo now starts at bit 5
	andi.l	#%11111,d0
	lsl.w	#8,d0		*shift bo to match
	lsl.w	#3,d0
	or.l	d1,d0		*new bt
;	swap	d0
;	move.l	d0,-(sp)
	qmove.l	d0,d1	
	bsr	put_ppc
	rts_	"cr_logical"

**mcrf
mcrf:
	qmove.l	d1,-(sp)	*save inst
	bsr.l	get_ops_ppc
	cmpi.l	#2,d1
	bne	mcrf_error
	lea	source_op(a5),a1
	bsr.l	get_op_code_num	*d1=-1 if failed
	tst.w	d1
	bmi	mcrf_error		* number is bad
	tst.w	d0
	bmi	bad_first		*<0
	cmpi.w	#7,d0
	bgt	bad_first		*>7	
	qmove.l	(sp)+,d1
	swap	d1
	lsl.w	#7,d0		*make bf
	or.w	d0,d1
	swap	d1
	qmove.l	d1,-(sp)

	lea	dest_op(a5),a1
	bsr.l	get_op_code_num	*d1=-1 if failed
	tst.w	d1
	bmi	mcrf_error		* number is bad
	tst.w	d0
	bmi	bad_second		*<0
	cmpi.w	#7,d0
	bgt	bad_second		*>7	
	qmove.l	(sp)+,d1
	swap	d1
	lsl.w	#2,d0		*make bfa
	or.w	d0,d1
	swap	d1
	bsr	put_ppc
	rts_	"mcrf"
			
**cr extended
crmove:
	qmove.l	d1,-(sp)	*save inst.
	bsr.l	get_ops_ppc
	bsr	get_two		*get bx,by, returns d1=0 if ok, else -1, returns d2,d3
	tst.w	d1
	beq.s	crmove_ok
	addq.l	#4,sp
	rts
crmove_ok:
**check types - 0=gpr,1=fpr,2=cr,3=number/label
	cmpi.w	#number,second_type(a5)
	bne	bad_second
	cmpi.w	#number,first_type(a5)
	bne	bad_first	
**check d2 and d3 for size
	tst.l	d2
	bmi	bad_first
	cmpi.l	#31,d2
	bgt	bad_first
	tst.l	d3
	bmi	bad_second
	cmpi.l	#31,d3
	bgt	bad_second
	qmove.l	(sp)+,d1	*cror
	swap	d1
	lsl.l	#5,d2
	or.l	d2,d1		*bx
	or.l	d3,d1		*by1
	swap	d1
	lsl.l	#8,d3
	lsl.l	#3,d3
	or.l	d3,d1		*by2
	bsr	put_ppc
	rts_	"crmove"

***

crclr:
	qmove.l	d1,-(sp)	*save inst.
	bsr.l	get_ops_ppc
	bsr	get_one		*get bx returns d1=0 if ok, else -1, returns d2
	tst.w	d1
	beq.s	crclr_ok
	addq.l	#4,sp
	rts
crclr_ok:
**check types - 0=gpr,1=fpr,3=number/label
	cmpi.w	#number,first_type(a5)
	bne	bad_first
**check d2 and d3 for size
	tst.l	d2
	bmi	bad_first
	cmpi.l	#31,d2
	bgt	bad_first
	qmove.l	(sp)+,d1	*cror
	swap	d1
	qmove.l	d2,d3		*copy bx
	lsl.w	#5,d2
	or.l	d2,d1		*bx
	or.l	d3,d1		*bx
	swap	d1
	lsl.l	#8,d3
	lsl.l	#3,d3
	or.l	d3,d1		*bx
	bsr	put_ppc
	rts_	"crclr"

***
	
***********************************get operands******************
**can handle either:
**'crx'
**x
**rx
**fprx
**returns in d2 upwards, so get_2 returns in d2,d3. get_5 returns in d2,d3,d4,d5,d6
get_five:
	btst	#4,ppc_immediate_data_operand(a5)	*is it immediate
	beq.s	not_imm5	*no, clear immediate flag
	bset	#1,flags8(a5)	*yes set immediate flag
	bra.s	done_imm5
not_imm5:
	bclr	#1,flags8(a5)
done_imm5:

	lea	op_5(a5),a1
	bsr	get_ppc_operand
	tst.w	d1
	bge.s	get_five_ok
	bsr	bad_fifth
	bra	return_bad
	rts_	"get_five"

get_five_ok:
	qmove.w	d1,fifth_type(a5)
	qmove.l	d0,fifth_operand(a5)
**check type and size
	cmpi.w	#2,d1
	bgt.s	get_four
**0 or 1 must be 0->31
	tst.w	d0
	bge.s	greater_than5
	bsr	bad_fifth
	bra	return_bad

greater_than5:
	cmpi.w	#31,d0
	ble.s	get_four
	bsr	bad_fifth
	bra	return_bad

get_four:
	btst	#3,ppc_immediate_data_operand(a5)	*is it immediate
	beq.s	not_imm4	*no, clear immediate flag
	bset	#1,flags8(a5)	*yes set immediate flag
	bra.s	done_imm4
not_imm4:
	bclr	#1,flags8(a5)
done_imm4:

	lea	op_4(a5),a1
	bsr	get_ppc_operand
	tst.w	d1
	bge.s	get_four_ok
	bsr	bad_fourth
	bra	return_bad
	rts_	"get_four"

get_four_ok:
	qmove.w	d1,fourth_type(a5)
	qmove.l	d0,fourth_operand(a5)
**check type and size
	cmpi.w	#2,d1
	bgt.s	get_three
**0 or 1 must be 0->31
	tst.w	d0
	bge.s	greater_than4
	bsr	bad_fourth
	bra	return_bad

greater_than4:
	cmpi.w	#31,d0
	ble.s	get_three
	bsr	bad_fourth
	bra	return_bad

get_three:
	btst	#2,ppc_immediate_data_operand(a5)	*is it immediate
	beq.s	not_imm3	*no, clear immediate flag
	bset	#1,flags8(a5)	*yes set immediate flag
	bra.s	done_imm3
not_imm3:
	bclr	#1,flags8(a5)
done_imm3:

	lea	op_3(a5),a1
	bsr	get_ppc_operand
	tst.w	d1
	bge.s	get_three_ok
	bsr	bad_third
	bra	return_bad
	rts_	"get_three"

get_three_ok:
	qmove.w	d1,third_type(a5)
	qmove.l	d0,third_operand(a5)
**check type and size
	cmpi.w	#2,d1
	bgt.s	get_two
**0 or 1 must be 0->31
	tst.w	d0
	bge.s	greater_than3
	bsr	bad_third
	bra	return_bad

greater_than3:
	cmpi.w	#31,d0
	ble.s	get_two
	bsr	bad_third
	bra	return_bad

get_two:
	btst	#1,ppc_immediate_data_operand(a5)	*is it immediate
	beq.s	not_imm2	*no, clear immediate flag
	bset	#1,flags8(a5)	*yes set immediate flag
	bra.s	done_imm2
not_imm2:
	bclr	#1,flags8(a5)
done_imm2:
	lea	dest_op(a5),a1
	bsr	get_ppc_operand
	tst.w	d1
	bge.s	get_two_ok
	bsr	bad_second
	bra	return_bad
	rts_	"get_two"
get_two_ok:
	qmove.w	d1,second_type(a5)	*store type
	qmove.l	d0,second_operand(a5)
**check type and size
	cmpi.w	#2,d1
	bgt.s	get_one
**0 or 1 must be 0->31
	tst.w	d0
	bge.s	greater_than2
	bsr	bad_second
	bra	return_bad
greater_than2:
	cmpi.w	#31,d0
	ble.s	get_one
	bsr	bad_second
	bra	return_bad
	
get_one:
	btst	#0,ppc_immediate_data_operand(a5)	*is it immediate
	beq.s	not_imm1	*no, clear immediate flag
	bset	#1,flags8(a5)	*yes set immediate flag
	bra.s	done_imm1
not_imm1:
	bclr	#1,flags8(a5)
done_imm1:
	lea	source_op(a5),a1
	bsr.s	get_ppc_operand
	tst.w	d1
	bge.s	get_one_ok
	bsr	bad_first
	bra.s	return_bad
	rts_	"get_one"

get_one_ok:
	qmove.w	d1,first_type(a5)
	qmove.l	d0,d2
**check type and size
	cmpi.w	#2,d1
	bgt.s	got_all
**0 or 1 must be 0->31
	tst.w	d0
	bge.s	greater_than1
	bsr	bad_first
	bra.s	return_bad
greater_than1:
	cmpi.w	#31,d0
	ble.s	got_all
	bsr	bad_first
	bra.s	return_bad

got_all:
	qmove.l	second_operand(a5),d3
	qmove.l	third_operand(a5),d4
	qmove.l	fourth_operand(a5),d5
	qmove.l	fifth_operand(a5),d6
	bclr	#1,flags8(a5)
	clr.b	ppc_immediate_data_operand(a5)
	clr.l	d1		*no error
	rts_	"get_one_five"

return_bad:
	bclr	#1,flags8(a5)
	clr.b	ppc_immediate_data_operand(a5)
	moveq	#-1,d1
	rts_	"get_x"
			
**get_ppc_operand - can handle:
**rxx
**fxx
**crx
**x:l
**needs a1->operand text
**returns d0=number
**d1=-1 if bad, else 0=gpr, 1=fpr, 2=vr, 3=number/label
get_ppc_operand:
**find type
**check for sp or sp
	cmpi.w	#"SP",(a1)
	bne.s	not_spu
	tst.b	2(a1)
	bne.s	not_spu
	qmoveq	#0,d1
	qmoveq	#1,d0
	rts
not_spu:
	cmpi.w	#"sp",(a1)
	bne.s	not_spl
	tst.b	2(a1)
	bne.s	not_spl
	qmoveq	#0,d1
	qmoveq	#1,d0
	rts
not_spl:
	cmpi.b	#$52,(a1)	*r
	bne.s	not_gprh

**gpr
	cmpi.l	#"RTOC",(a1)
	bne.s	not_rtoc1
	tst.b	4(a1)
	bne.s	not_rtoc1
	qmoveq	#0,d1
	qmoveq	#2,d0
	rts
not_rtoc1:	
	cmpi.b	#"0",1(a1)
	blt	not_gpr
	cmpi.b	#"9",1(a1)
	bgt.s	not_gpr
**fant 5
**if 2(a1) is a-z or a-z then it's not a reg

	qpush1	a1
	qcmove.b	2(a1),d0
	qbsr.l	toupper
	qpop1	a1
	cmpi.l	#"A",d0
	blt.s	is_reg
	cmpi.l	#"Z",d0
	bgt.s	is_reg
	bra.s	not_gpr

is_reg:	addq.l	#1,a1		*skip r
	qmoveq	#0,d1		*return gpr
	bra	do_number
not_gprh:
	cmpi.b	#$72,(a1)	*r
	bne.s	not_gpr
	cmpi.l	#"rtoc",(a1)
	bne.s	not_rtoc2
	tst.b	4(a1)
	bne.s	not_rtoc2
	qmoveq	#0,d1
	qmoveq	#2,d0
	rts
not_rtoc2:	

	cmpi.b	#"0",1(a1)
	blt.s	not_gpr
	cmpi.b	#"9",1(a1)
	bgt.s	not_gpr
	qpush1	a1
	qcmove.b	2(a1),d0
	qbsr.l	toupper
	qpop1	a1
	cmpi.l	#"A",d0
	blt.s	is_reg1
	cmpi.l	#"Z",d0
	bgt.s	is_reg1
	bra.s	not_gpr
is_reg1:
	addq.l	#1,a1		*skip r
	qmoveq	#0,d1		*return gpr
	bra	do_number

not_gpr:
	cmpi.b	#$46,(a1)	*f?
	bne.s	not_fprh
	cmpi.b	#"0",1(a1)
	blt.s	not_fpr
	cmpi.b	#"9",1(a1)
	bgt.s	not_fpr
**fant 5
**if 2(a1) is a-z or a-z then it's not a reg
	qpush1	a1
	qcmove.b	2(a1),d0
	qbsr.l	toupper
	qpop1	a1
	cmpi.l	#"A",d0
	blt.s	is_freg
	cmpi.l	#"Z",d0
	bgt.s	is_freg
	bra.s	not_fpr
is_freg:
	addq.l	#1,a1
	qmoveq	#1,d1		*return fpr
	bra.s	do_number
not_fprh:
	cmpi.b	#$66,(a1)	*f?
	bne.s	not_fpr
	cmpi.b	#"0",1(a1)
	blt.s	not_fpr
	cmpi.b	#"9",1(a1)
	bgt.s	not_fpr
**if 2(a1) is a-z or a-z then it's not a reg
	qpush1	a1
	qcmove.b	2(a1),d0
	qbsr.l	toupper
	qpop1	a1
	cmpi.l	#"A",d0
	blt.s	is_fregl
	cmpi.l	#"Z",d0
	bgt.s	is_fregl
	bra.s	not_fpr
is_fregl:
	addq.l	#1,a1
	qmoveq	#1,d1		*return fpr
	bra.s	do_number


not_fpr:
**fant 5.30 - check for vector register
	cmpi.b	#"v",(a1)	*f?
	bne.s	not_vr
	cmpi.b	#"0",1(a1)
	blt.s	not_vr
	cmpi.b	#"9",1(a1)
	bgt.s	not_vr
**if 2(a1) is a-z or a-z then it's not a reg
	qpush1	a1
	qcmove.b	2(a1),d0
	qbsr.l	toupper
	qpop1	a1
	cmpi.l	#"A",d0
	blt.s	is_vr
	cmpi.l	#"Z",d0
	bgt.s	is_vr
	bra.s	not_vr
is_vr:
	addq.l	#1,a1
	qmoveq	#2,d1		*return vr
	bra.s	do_number

;	swap	d0
;	cmpi.w	#"cr",d0
;	bne.s	not_cr
;	addq.l	#2,a1
;	moveq	#2,d1		*return cr
;	bra.s	do_number
not_vr:
not_cr:
	qmoveq	#3,d1		*number or label
**must either be a number or a label
do_number:
**copy toop_buff(pc),and terminate
	qmove.l	d1,-(sp)	*save type
	bsr.l	get_op_code_num	*d1=-1 if failed
	tst.l	d1
	beq.s	converted_ok
	bclr	#1,flags8(a5)	*clear ppc immediate flag

	addq.l	#4,sp
	rts_	"get_ppc_operand"
converted_ok:
	bclr	#1,flags8(a5)	*clear ppc immediate flag

	move.l	(sp)+,d1	*get type
	rts_	"get_ppc_operand_ok"	
********************************errors***************************
mcrf_error:
	addq.l	#4,sp
;	bset	#7,flags(a5)
;	st	global_err(a5)
	lea	merr_text(pc),a0
	bsr.l	pass1_error
	rts_	"mcrf_error"
	
illegal_cr:
	addq.l	#4,sp
;	bset	#7,flags(a5)
;	st	global_err(a5)
	lea	illegal_cr_text(pc),a0
	bsr.l	pass2_error
	rts_	"illegal_cr_in_crlog"
not_3_for_crl:
	addq.l	#4,sp
;	bset	#7,flags(a5)
;	st	global_err(a5)
	lea	three_needed(pc),a0
	bsr.l	pass2_error
	rts_	"not_3_for_crl"
	
bad_first:
	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	first_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_first"

bad_second:
	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	second_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_2nd"
bad_third:	
	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	third_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_3rd"
bad_fourth:	
	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	fourth_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_4th"
bad_fifth:	
	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	fifth_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_5th"

bra_error2:
	addq.l	#4,sp		*d1 is on stack!
;	bset	#7,flags(a5) 	*error detected flag
;	st	global_err(a5)
	lea	bsrlab_err_text(pc),a0
	bsr.l	pass2_error
	bra	sim_no_branch
	rts_	"short_bra_offset_err"

bra_error3:
;	bset	#7,flags(a5) 	*error detected flag
;	st	global_err(a5)
	lea	bralab_err_text(pc),a0
	bsr.l	pass2_error
	bra	sim_no_branch
	rts_	"long_bra_offset_err"

op_needed:
	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	need_target(pc),a0
	bsr.l	pass1_error
	rts_	"branch_target_needed"
	

bad_cr:	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag
;	st	global_err(a5)
	lea	bad_cr_text(pc),a0
	bsr.l	pass1_error
	rts_	"bad_cr"		
cr_error:
	addq.l	#4,sp
;	bset	#7,flags(a5) 	*error detected flag
;	st	global_err(a5)
	lea	cr_expected(pc),a0
	bsr.l	pass1_error
	rts_	"cr_error"
not_abs_in_link:
;	bset	#7,flags(a5) 	*error detected flag	    
;	st	global_err(a5)
	lea	no_abs_text(pc),a0
	bsr.l	pass1_error
	rts_	"no_abs_in_bclr"
bi_error:
;	bset	#7,flags(a5) 	*error detected flag
;	st	global_err(a5)
	lea	long_offset_text(pc),a0
	bsr.l	pass2_error
	rts_	"long_offset_error"
			
ops_ignored:
	lea	bp_ops_ignored_text(pc),a0
	bsr.l	pass1_warning
	rts_	"ops_ignored_warning"
bad_op_lr:
	lea	only_cr_text(pc),a0
	bsr.l	pass1_warning
	rts_	"ops_ignored_warning"

*****
merr_text:	dc.b	"Illegal operand - syntax: mcrf bf,bfa.",13,0

three_needed:	dc.b	"This instruction requires 3 operands - normally",13
		dc.b	"'Total,Source A,Source B'",13,0
		
first_text:	dc.b	"Illegal first operand for this instruction.",13,0
second_text:	dc.b	"Illegal second operand for this instruction.",13,0
third_text:	dc.b	"Illegal third operand for this instruction.",13,0
fourth_text:	dc.b	"Fourth operand is illegal for this instruction.",13,0
fifth_text:	dc.b	"The last operand is illegal.",13,0

only_cr_text:	dc.b	"**WARNING** The only valid operand for extended branches to LR or CTR is 'CRn'"
		dc.b	" where 'n' is a condition register field between 0 and 7.",13
		dc.b	"The operand has been ignored.",13,0
		align

bp_ops_ignored_text:	dc.b	"**WARNING** Unused operand(s)."
		dc.b	13,0
need_target:	dc.b	"This branch needs a target label to branch to.",13,0
long_offset_text:	dc.b	"The offset is too big. You are limited to 26 bits"
	dc.b	"offset for unconditional branches, which is +/- 32Mbytes.",13,0
	
no_abs_text:	dc.b	"Can't use absolute flag ('A') in branches to Link"
		dc.b	" register (LR) or Counter register (CTR) instructions. The contents of the"
		dc.b	" register IS an absolute address.",13
		dc.b	"Remove the 'A' from the end of the instruction.",13,0

cr_expected:	dc.b	"CRx expected as first operand of instruction - EG 'CR0'"
		dc.b	" is the normal integer flags, and CR1 is the FPU flags.",13,0
illegal_cr_text:	dc.b	"You cannot use the label 'CR' in this instruction as 'CRn' refers to"
	dc.b	" a complete condition code field. This instruction is refering to"
	dc.b	" individual bits in the register.",13,0

bad_cr_text:	dc.b	"CR fields must lie between 0 and 7 - E.G. 'CR1' is the FPU flags.",13,0

bad_bo_text:	dc.b	"BO field is illegal (0-31 allowed) - first operand.",13,0

bad_bi_text:	dc.b	"Illegal BI field (0-31 allowed) - second operand.",13,0

bsrlab_err_text:	dc.b	"The target label of this conditional branch is not"
	dc.b	" defined.",13,0

bralab_err_text:	dc.b	"The target label of this branch is not"
	dc.b	" defined.",13,0

bp_branch_text:	dc.b	"The offset to the label is too great for a conditional branch.",13,	
		dc.b	"Only 16 bit size allowed for conditional branches (+/- 32700 ish).",13,0
no_ops_needed:	dc.b	"***ADVICE*** This instruction requires no operands.",13,0
	align	 
***MODE SWITCH CODE TO PPC
bp_univ_pointer:	DC.W	$AAFE		*MIXEDMODEMAGIC TRAP
	DC.B	7		*VERSION OF MIXED MODE
	DC.B	0		*
	DC.L	0		*RES1
	DC.B	0		*RES2
	DC.B	0		*SELECTOR INFO
	DC.W	0		*NUMBER OF ROUTINES (ARRAY INDEX!)
**PROCINFOREC

**We need to pass a5 and a3
**               a1   a3   a2   d0   returns in d0
**		 r6   r5   r4   r3 
	dc.l	%1011111111110110001100000110010	*register based call - procinfo
	DC.B	0		*RESVD
	DC.B	1		*PPC (68K=0)
	DC.W	4		*ROUTINE FLAGS 4=NATIVE + 2=NEEDS INIT + 1=OFFSET

;bp_proc_pointer:	DS.L	1		*PROC POINTER (TO TRANSITION VECTOR ACTUALLY!)
;	DC.L	0		*RESVD
;	DC.L	0		*RESVD		

	align
	global	blr,bc,branch_l,sc,cr_logical,mcrf,crmove,crclr
	global	get_two,get_one,b_logical,put_ppc,get_three,get_four
	global	bad_first,bad_second,bad_third,bad_fourth,bad_cr,get_five,no_ops_needed
	extern	search_lab,get_ops,get_ops_ppc,get_op_code_num
	extern	pass2_error,printit,printnum_signed,print_line
	extern	pass1_warning,pass1_error,get_lab_value,pass1_advice,pass1_warning_always
	extern	send_to_log,toupper,r2d2
	
	extern_data	offset_bytes