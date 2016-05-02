
**BRA V2source_op(a5) - LONG BRANCHES
bra:
****basic code in d1
	move.w	d1,-(sp)	save inst
	move.b	(a4),size2(a5) 	*save size character
	bsr.l	get_ops
	lea	source_op(a5),a3

	bsr.l	test_for_locals		; ****** llbls-rp200797 *********
	extern	test_for_locals
	
 	move.l	labels(a5),tree_strings_ptr(a5)
 	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search

;	move.l	labels(a5),a4	*table to be searched
;	bsr	search_labp2	*search for this label (was lab)
	move.w	(sp)+,d1	get inst back
	tst.w	d0	*did we find it?
	bge.s	do_normal_branch	*yes
	btst	#1,flags(a5)	pass 2?
	bne	bra_error2	yes, must be undefined label
	move.l	pc(a5),d3	simulate fwd branch for pass 1
	addq.l	#6,d3	so we get pc+6-pc+2=fwd branch!
	bra.s	got_branch1	
do_normal_branch:
	btst	#6,flags5(a5)	1=linkable
	beq.s	normal_label_b	no
	btst	#1,flags(a5)
	bne.s	pass2_lab_chk_ext_b	pass2, so see if ext
normal_label_b:
	move.l	lab_val(a5),a4
**LXT change
	push	d0
	push	a4
	lsl.l	#2,d0
	add.l	d0,a4
	move.l	(a4),d3
	pop	a4
	pop	d0
;	move.l	0(a4,d0.l*4),d3
got_branch1:	move.l	pc(a5),d7 	*get pc
	addq.l	#2,d7 		*account for branch instruction
	sub.l	d7,d3 		*pc-label gives offset
	bra.s	label_done
**d0 contains label position
**come here if pass 2 and linkable
pass2_lab_chk_ext_b:
	move.l	extern_buff(a5),a4	external labels list
	cmpi.b	#-1,0(a4,d0.l)	is it external label?
	bne.s	normal_label_b	no
	
	cmpi.b	#"S",size2(a5)		
	bne.s	ext_bra_size_ok	
	save_all			
	lea	size_ext_bra(pc),a0
	bsr.l	pass2_error
	restore_all
	rts
	
ext_bra_size_ok:
	move.l	extern_buff_tab_pos(a5),d0
	move.l	extern_buff_tab(a5),a2
	add.l	d0,a2	point to next slot
	move.l	a2,a1	save

	lea	source_op(a5),a3	point to label name
	moveq	#27,d2	counter
copy_ext_name:	move.b	(a3)+,(a2)+
	beq.s	cen_done
	dbra	d2,copy_ext_name
**now we need the pc for the displacement
cen_done:	move.l	pc(a5),d2
	addq.l	#2,d2	account for instruction
	move.l	d2,28(a1)+	store address of offset after name - 32 bytes
	
	add.l	#32,d0		next position
	move.l	d0,extern_buff_tab_pos(a5)
	addq.l	#1,extern_count(a5)
	move.l	#$fff,d3	*big enough to stop a short optimisation!
	cmpi.b	#"L",size2(a5)
	beq	do_long_bra	do long bra
	bra	try_word_m	do word bra
label_done:
do_it_m:	move.b	size2(a5),d6	get size character back
	cmpi.b	#"L",d6
	beq	do_long_bra

	cmpi.l	#32766,d3
	bgt	bra_error 	*offset too great
	cmpi.l	#-32768,d3
	blt	bra_error 	*-ve offset too great
	move.b	size2(a5),d6	*get size character back
	cmpi.b	#"S",d6
	beq.s	do_byte	*short cct optimisations if short

***check for warn short fwd
	btst	#0,flags4(a5)
	beq.s	no_wf	warnings off
	btst	#1,flags(a5)	check for pass 2
	beq.s	no_wf	nah, pass 1
	tst.l	d3
	bmi.s	no_wf	minus branch, so ignore
	cmpi.l	#127,d3	check for possible short
	bgt.s	no_wf	too big
	save_all
	
	lea	short_fwd_warn(pc),a0
	bsr.l	pass2_advice	display warning
	restore_all
	

no_wf:
**here we try a short backwards	
	btst	#1,flags4(a5)	do backwards short?
	beq.s	no_db	nope
	tst.l	d3	+ve offset?
	bge.s	no_db	yep
	cmpi.l	#-127,d3
	bge.s	byte_ok1	too small for short

	
no_db:	cmpi.b	#"S",d6
	bne.s	try_word_m
do_byte:	tst.w	d3	check for zero offset!
	beq.s	do_nop	make a nop
	cmpi.w	#127,d3
	bgt.s	bra_error
check_mb:	cmpi.w	#-128,d3
	blt.s	bra_error

**optimised branches
byte_ok1:	cmpi.b	#"S",d6
	beq.s	byte_ok	not an optimisation!
	addq.w	#2,optimisation_saving(a5)
	addq.w	#1,optimisation_count(a5)
	save_all
	lea	conv_short_text(pc),a0
	move.l	a0,error_string_save(a5)

	bsr.l	print_optimisation	debug purposes
	restore_all	

***here we've picked up a branch that will fit in a byte
byte_ok:	or.b	d3,d1 		*mix in offset
nop_entry:	move.w	#2,size(a5)
	move.w	#2,size2(a5)
	bsr	insert_inst
	rts
**do_nop handles short branches of zero - which just cant be because 0 means 16 bit disp.
do_nop:	move.w	#$4e71,d1
	bra.s	nop_entry
try_word_m:	move.l	d3,extension(a5)
	move.w	#4,size(a5)
	move.w	#2,size2(a5)
	bsr	insert_inst
	rts
do_long_bra:	ori.b	#$ff,d1	*long branch s'il vous plait
	move.l	d3,extension(a5)
	move.w	#6,size(a5)	long extension
	move.w	#2,size2(a5)
	bsr	insert_inst
	rts
		
bra_error:
;	bset	#7,flags(a5) 	*error detected flag
	st	global_err(a5)
 	move.l	d3,d0	offset in d0

	btst #1,flags(a5)
	beq.s	only_p2 		*only report on pass 2
**print offset to bt1

	lea	bt1(pc),a0
	bsr.l	printnum_mem_signed	*print signed long in d0
	move.l	#" byt",(a0)+
	move.l	#"es. ",(a0)+
	clr.b	(a0)
	move.l	a0,-(sp)	*save end of string so we can tag on a 13
	lea	im_branch_text(pc),a0

	addq.w #1,error_count(a5)
;	bset #7,flags(a5) 	*error detected flag
	st	global_err(a5)
	move.l	a0,error_string_save(a5)

	bsr.l print_line		*print line and error!
	move.l	(sp)+,a0
	move.w	#0x0d00,(a0)+
	lea	im_branch_text(pc),a0
	bsr.l	printit
	
only_p2:
sim_no_branch:
 move.b #2,d1 		*null branch because error
 move.w #2,size(a5)
 move.w #2,size2(a5)
 bsr insert_inst
 rts
bra_error2:

	lea	im_bsrlab_err_text(pc),a0	*in evaluate - undefined label
	bsr.l	pass2_error
	bra.s	sim_no_branch	
	rts_	"bra"
	align



dbra:
****basic code in d1
**f5 mod
 bsr.l get_ops
	lea	dest_op(a5),a3
	bsr.l	test_for_locals		; ****** llbls-rp200797 ********* sbqueryrp
	move.l	a3,save_possible_local(a5)
 lea source_op(a5),a3

 bsr.l get_mode		  *must be data reg
 tst.w d0
 bne s_illegal_err
 or.w d2,d1 		*mix in data reg
	move.l	save_possible_local(a5),a3	*dest op after conversion from possible local
; lea dest_op(a5),a3	*removed for locals sb
 bsr.l get_mode
 cmpi.w #7,d0
 bne d_illegal_err 	*better check mode i suppose!
 cmpi.w #1,d2
 bne d_illegal_err
 move.l pc(a5),d7 	*get pc
 addq #2,d7 		*account for branch instruction
 sub.l d7,d3 		*pc-label gives offset
 btst #1,flags(a5)
 bne.s do_it_dbra 		*pass 2 so eval
 moveq #2,d3 		*pass 1 so dummy branch
do_it_dbra:
 cmpi.l #32766,d3
 bgt bra_error 	*offset too great
 cmpi.l #-32768,d3
 blt bra_error 	*-ve offset too great

 move.w #4,size(a5)
 move.l d3,extension(a5)
 move.w #2,size2(a5)
 bsr insert_inst
 rts_	"dbra"
 	align
*****************************s c c*****************************************
***good for scc,scs,seq,sge,sgt,shi,sf,st, etc
***basic code in d1
scc:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s scc_equish
 qbset #5,flags(a5)
scc_equish:
 cmpi.w #1,d0
 beq s_illegal_err
 cmpi.w #7,d0
 bne.s scc_ok
 cmpi.w #2,d2
 bge s_illegal_err
scc_ok:
 or.w d2,d1
**LXT
	andi.w	#%111,d0
	lsl.w	#3,d0
	or.w	d0,d1
;	bfins	d0,d1{26:3}
 move.w d4,size(a5)
 move.l d3,extension(a5)
 move.w #2,size2(a5)
 bsr insert_inst
 rts_	"scc"
 	align
***************************************************************************
im_branch_text:	DC.B	"Offset too great at "
bt1:	ds.b	60
	align
offset_bytes:	DC.B	" bytes.",13,13,0
short_fwd_warn:	DC.B	"***ADVICE*** - Branch could be short.",13,13,0
short_back_warn:	dc.b	"Branch could be short.",13,13,0
conv_short_text:	DC.B	"Branch converted to short format.",0
size_ext_bra:	DC.B	"Absolutely refuse to allow short branches",13,"to externals.",13,13,0
im_bsrlab_err_text:	dc.b	"Code label not defined in this file, and",13,"has not been defined "
	dc.b	"as an EXTERN reference.",13,0,13
	align
*************************************************************************
	global	bra,dbra,scc,im_branch_text,offset_bytes

	extern	get_size12,get_mode,get_ops,source_op,dest_op,insert_inst
	extern	search_labp2,printit,printnum_signed,pass2_error
	extern	print_optimisation,print_line,s_illegal_err
	extern	d_illegal_err,pass2_warning,pass2_advice
	extern	printnum_mem_signed
	extern	lab_tree_search