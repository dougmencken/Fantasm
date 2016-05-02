*************************************************************************
*PASS2				        *
*STARTED 200294	Stuart Ball			        *
*COMPLETED 110394			        *
*CODE IS BUILT IN CODE_BUFFER - ADDRESSES WILL BE ABSOLUTE AS DEFINED   *
*BY PC ON PASS 1			        *
*************************************************************************

pass2:
	qmove.l	#0,d0
	qmove.l	d0,globisrs_flag(a5)
	qmove.l	d0,macro_depth_index(a5)
 	qmove.l	d0,source_pointer_save_index(a5)
 	qmove.l	d0,macro_nest_depth(a5)
 	qmove.w	d0,title_length(a5)	v3.6 header
 	qmove.w	d0,input_length(a5)	info
 	qmove.w	d0,output_length(a5)	
	qbset	#3,ppc_flags1(a5)	we are on pass 2 now!
	qmove.b	d0,rs_autoalign(a5)
	qmove.b	d0,macros_first(a5)	*default is search macros last
 qbset #0,flags(a5) 	 *set assembly flag
 qbset #1,flags(a5) 	 *set pass 2 flag
 qbclr #2,flags(a5) 	 *clear -ve flag for get_op_num
 qbclr	#4,flags2(a5)
 
 qmove.l	d0,pc(a5) *set pc
 qmove.l d0,reloc_tab_pos(a5) 	     *reloc table index
	qmove.b	d0,saved_if_depth_array_index(a5)	*for break directive
	qmove.b	d0,break_flag(a5)	*break
***** llbls-rp200797
	bsr.l	pass2_init_local_labels
	extern	pass2_init_local_labels
***** llbls-rp200797
 
 movea.l source_buff(a5),a0 	*source is here
 clr.w	m_label_count(a5)	*auto label generator
	clr.b	start_macro_copy(a5)
pass2_loop:
	tst.b	abort(a5)	
	bne	p2_end
	qbclr	#1,ppc_flags1(a5)	*error reprot true field 2 unless set
	subq.l	#1,time_to_idle(a5)
	bne.s	no_idle2
	bsr.l	check_idle	*checks events evry 20 isnts unless no backgrounding
no_idle2:
;	bsr	check_keyboard	*for manual stop
	btst	#4,flags2(a5)	*fatal error
	bne	p2_f_error
	qmove.l	a0,source_save(a5)
	qbclr	#5,flags(a5)
	qbclr	#6,flags(a5) 	*extension1 and 2 long flags for insert_inst

**********v4.10
;	tst.b	start_macro_copy(a5)
;	beq.s	not_start_macro
;	clr.b	start_macro_copy(a5)
**here we have to be devious.
**if field 1 currently has a label we have to copy it, if not, goto not_start_macro.
**next get the new fields.
**check field 1 - if a label goto nsm1
**copy old field 1 back to field 1 then goto "instruction" because the label is already defined
;
;	lea	field_1(a5),a2
;	tst.b	(a2)
;	beq.s	not_start_macro	*old field 1 is not a label
;	lea	macro_copy_field1(a5),a3
;copy_mlab:
;	move.b	(a2)+,d0
;	move.b	d0,(a3)+
;	tst.b	d0
;	bne	copy_mlab
;	bsr	get_fields
;	lea	field_1(a5),a2	*check new field 1
;	tst.b	(a2)
;	bne.s	nsm1	*old field 1 is not a label
;	lea	macro_copy_field1(a5),a3
;copy_old_mlab:
;	move.b	(a3)+,d0
;	move.b	d0,(a2)+
;	tst.b	d0
;	bne	copy_old_mlab
;	bsr.l	replace_params2	*v1.02 - replace parameters in fields with real values
;
;	bra.s	no_mac
;
;*********end v4.10
not_start_macro:
	qbsr	get_fields 	*get field 1,2,3 in field_1,field_2 etc
	bsr.l	expand_internal_strings	*for field 3 (fant 5)	*file

nsm1:
**tron for p2
	btst	#0,flags(a5)
	beq	skip_tron	ass off

	btst	#1,flags6(a5)	tron
	beq.s	skip_tron
	tst.b	break_flag(a5)
	bne	skip_tron	*break	- 5.1

	save_all
	lea	field_1(a5),a0	print fields
	bsr.l	printit
	bsr.l	print_space
	lea	field_2(a5),a0
	bsr.l	printit
	bsr.l	print_space
	lea	field_3(a5),a0
	bsr.l	printit
	bsr.l	printcr


	restore_all
skip_tron:
	lea	field_1(a5),a2
	cmpi.b	#$ff,(a2)
	beq	p2_end 	*eof
	
****look for a directive
 
instruction_p2:	
	lea	field_2(a5),a3
	lea	field_3(a5),a4
	btst	#1,flags2(a5)	*v1.02 - assembling from macro?
 	beq.s	no_mac
 	bsr.l	replace_params	*v1.02 - replace parameters in fields with real values
no_mac:
**v5.1 - if we have executed a break, then only thing we are looking for is an endm
	tst.b	break_flag(a5)
	beq	not_looking_for_endm
	lea	field_2(a5),a3
	cmpi.l	#"endm",(a3)
	beq.s	endm1	
	cmpi.l	#"ENDM",(a3)
	bne	pass2_loop	*wasnt and endm
endm1:
	clr.b	break_flag(a5)
	qbclr	#3,flags2(a5)	*clear in repeat flag
**tidy up ifs
	clr.b	if_scan(a5)	*not scanning for endifs etc
	lea	saved_if_depth_array(a5),a1	*restore if depth to as it was going into the broken macro
	clr.l	d0
	move.b	saved_if_depth_array_index(a5),d0
	beq.s	saved_if_depth_array_index_top	*prevent errors and ignore excessive breaks
	subq.b	#1,d0
saved_if_depth_array_index_top:
	add.l	d0,a1
	qmove.b	(a1),if_depth(a5)	*if depth back to what it was at at start of breaked macro
	qmove.b	d0,saved_if_depth_array_index(a5)
**check if we wwere in a repeat
	lea	saved_repeat_depth_array(a5),a1
	add.l	d0,a1
	move.b	(a1),d0
	beq.s	clear_repeat
	qbset	#3,flags2(a5)	*set in repeat
	bra.s	done_repeat
clear_repeat:
	qbclr	#3,flags2(a5)	*clear in repeat flag
done_repeat:

	qbset	#0,flags(a5) 	*set assembly flag
	bra.s	not_endm2	*done it already - 0310 181197
;	bsr	endm		*taken care of by directives...
not_looking_for_endm:
**if it is an endm, we must dec if_depth_array_index
	cmpi.l	#"endm",(a3)
	beq.s	endm2	
	cmpi.l	#"ENDM",(a3)
	bne.s	not_endm2	*wasnt and endm
endm2:
	move.b	saved_if_depth_array_index(a5),d0
	beq.s	saved_if_depth_array_index_top1	*prevent errors and ignore excessive breaks
	subq.b	#1,d0
	qmove.b	d0,saved_if_depth_array_index(a5)
saved_if_depth_array_index_top1:
not_endm2:
**if macros first, do this next bit
	tst.b	macros_first(a5)
	beq.s	skip_macros_first
	btst	  #0,flags(a5)	*5.1
	beq	 skip_mac1	*assembly off, so next line 5.1
	btst	 #2,flags2(a5)	 ignoring mac def? 5.1
	bne.s	not_mac	*yes - 5.1
	
	bsr.l	try_macro	*search macros, copy params and set flag2[1] 5.1
	tst.w	d0		*5.1
	blt	not_mac	*5.1
	bra	pass2_loop	*5.1
not_mac:	clr.l	d0	*5.1
skip_macros_first:
skip_mac1:	
	bsr	directive 	*returns d0=-1 if not directive
	qbclr	#4,ppc_flags1(a5)	*not in directive any more!
	tst.w	d0
*v4.04
	beq	pass2_loop	was directive
directives_off:			*5.1
;	bne.s	not_directive
;**tron for directives
;	 btst	 #0,flags(a5)
;	 beq	 pass2_loop	 ass off
;	 btst	 #1,flags6(a5)	 tron
;	 beq.s	 no_tron
;	 save_all
;	 lea	 field_1(a5),a0	print fields
;	 bsr.l	 printit
;	 bsr.l	 print_space
;	 lea	 field_2(a5),a0
;	 bsr.l	 printit
;	 bsr.l	 print_space
;	 lea	 field_3(a5),a0
;	 bsr.l	 printit
;	 bsr.l	 printcr
;	 bsr	 do_kbd
;
;	 restore_all
;no_tron:	 bra	 pass2_loop
************

not_directive:	btst	#0,flags(a5)	assembly off?
	beq	pass2_loop 	assembly off, so next line

	btst	#2,flags2(a5)	*we're in a macro def, so skip till endm
	bne	pass2_loop
not_ass_f_mac:
	
	bsr.s	assemble_2 	assemble this line
	bra	pass2_loop

p2_end:
	qbclr	#0,flags5(a5)	enable printing
	qmove.l	pc(a5),code_end(a5)

	btst	#0,build_options(a5)
	bne.s	build_quiet_5
	lea	code_text(pc),a0
	bsr.l	printit
	qmove.l	pc(a5),d0
	bsr.l	printnum
	lea	bytes_text_2(pc),a0
	bsr.l	printit 		*'bytes'
build_quiet_5:	clr.l	d0
	rts_	"pass_2"
p2_f_error:	moveq	#-1,d0
	
	align
**************************************************************************************
*assemble attempts(!) to assemble the current instruction at pc
*syntax is also checked here - i.e. if the current instruction isnt
*found then it dont exist!
*a0 must be preserved
assemble_2:
	qmove.l	a0,-(sp)
	lea	field_2(a5),a3 	point to instruction
	tst.b	(a3)
	beq.s	no_inst_2 	blank field
	ifne	powerf
	btst	#0,ppc_flags1(a5)
	bne.s	do_ppc_asm
	endif
	
	lea	inst_table(pc),a2	*basic instruction table
	bsr	inst_search	search instructions for current, returns d0
	bmi	try_macro_exp	bad instruction, so try macros	

	lea	code_table(pc),a1
**LXT change
	qpush1	a1
	qpush2	d0
	lsl.l	#1,d0
	add.l	d0,a1
	qmove.w	(a1),d1
	qpop2	d0
	qpop1	a1
;	move.w	0(a1,d0.l*2),d1 	get instruction code
***now we branch to the right routine to handle it
	if	PPC
	macs_last
	lwz	r21,[t]ass_table(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here1
here1:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else
	lea	ass_table(pc),a0
	lsl.l	#3,d0
	add.l	d0,a0
*	move.l	0(a1,d0.l*8),a0	get code address
	jsr	(a0)	assemble this instruction
	endif
no_inst_2:	move.l	(sp)+,a0
	rts_	"ass_2"
****fant v4
	ifne	powerf
do_ppc_asm:
	qmove.l	a3,-(sp)
	lea	field_3(a5),a3
	bsr.l	replace_requs
	qmove.l	(sp)+,a3

	bsr	postfix_logic	*set postfix flags and remove chars
	cmpi.w	#"cr",(a3)
	beq.s	do_branches
	cmpi.b	#"s",4(a3)
	bne.s	not_poss_mcrfs
	cmpi.l	#"mcrf",(a3)
	beq.s	try_integer2	*its mcrfs	
not_poss_mcrfs:

	cmpi.l	#"mcrf",(a3)
	beq.s	do_branches
	cmpi.w	#"sc",(a3)
	beq.s	do_branches
	cmpi.b	#"b",(a3)
	bne.s	try_integer2
do_branches:	
	lea 	ppc_string_table(pc),a2	*basic instruction table
	bsr	inst_search		*in search_labs.s
	bmi	try_macro_exp		*not found inst
	lea	ppc_code_table(pc),a1 
**LXT change
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
	if	PPC
	macs_last
	lwz	r21,[t]ppc_ass_table(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here2
here2:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first	
	else
	lea	ppc_ass_table(pc),a1	in pass2
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0	assembled
	rts_	"powerpc_asmp2"

try_integer2:
	cmpi.b	#"f",(a3)
	beq	do_float
	cmpi.w	#"lf",(a3)
	bne.s	not_floatl

do_fl:	lea 	ppc_flsyntax_table(pc),a2	*basic instruction table
	bsr	inst_search		*in search_labs.s
	bmi	try_macro_exp
	lea	ppc_flcode_table(pc),a1 
**LXT change
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
	if	PPC
	macs_last
	lwz	r21,[t]ppc_flass_table(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here3
here3:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else
	lea	ppc_flass_table(pc),a1
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0	assembled
	rts_	"powerpc_asm_float"

not_floatl:
	cmpi.l	#"stfs",(a3)
	beq.s	do_fl
	cmpi.l	#"stfd",(a3)
	beq.s	do_fl
	cmpi.w	#"cm",(a3)
	beq.s	try_cmp
	cmpi.w	#"tw",(a3)	*trapword?
	beq	try_trap
	cmpi.w	#"td",(a3)	*trap double
	beq	try_trap	
	cmpi.b	#"v",(a3)
	beq	try_vector	
	lea 	ppc_int_string_table(pc),a2	*basic instruction table
	bsr	inst_search		*in search_labs.s
	bmi	try_macro_exp
	lea	ppc_int_code_table(pc),a1 
**LXT change
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
	if	PPC
	macs_last
	lwz	r21,[t]ppc_int_jumptable(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here5
here5:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else
	lea	ppc_int_jumptable(pc),a1
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0	assembled
	rts_	"powerpc_asm_integer2"

try_cmp:

	lea 	ppc_cmp_string_table(pc),a2	*basic instruction table
	bsr	inst_search		*in search_labs.s
	bmi	try_macro_exp
	lea	ppc_cmp_code_table(pc),a1 
**LXT change
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
	if	PPC
	macs_last
	lwz	r21,[t]ppc_cmp_jumptable(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here6
here6:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else
	lea	ppc_cmp_jumptable(pc),a1
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0	assembled
	rts_	"powerpc_asm_integer2_cmp"
do_float:

	lea 	ppc_fsyntax_table(pc),a2	*basic instruction table
	bsr	inst_search		*in search_labs.s
	bmi	try_macro_exp
	lea	ppc_fcode_table(pc),a1 
**LXT change
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
	if	PPC
	macs_last
	lwz	r21,[t]ppc_fass_table(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here7
here7:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else
	lea	ppc_fass_table(pc),a1
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0	assembled
	rts_	"powerpc_asm_float"

try_trap:
	lea 	ppc_trap_string_table(pc),a2	*basic instruction table
	bsr	inst_search		 *in search_labs.s
	bmi.s	try_macro_exp
	lea	ppc_trap_code_table(pc),a1 
**LXT change
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
	if	PPC
	macs_last
	lwz	r21,[t]ppc_trap_jumptable(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here8
here8:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else
	lea	ppc_trap_jumptable(pc),a1
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0
	rts_	"try_traps"
	
try_vector:
	lea 	ppc_vector_string_table(pc),a2	*basic instruction table

	bsr	inst_search12		 *in search_labs.s
	bmi.s	try_macro_exp
	lea	ppc_vector_code_table(pc),a1 
	
**LXT change
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
	if	PPC
	macs_last
	lwz	r21,[t]ppc_vector_jumptable(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here8a
here8a:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else
	lea	ppc_vector_jumptable(pc),a1
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0
	rts_	"try_vector2"
	
	endif			*not powerf

try_macro_exp:
	bsr	restore_field_2
**if not macros_first do this
	tst.b	macros_first(a5)
	bne.s	skip_mac2
	bsr.l	try_macro	search macros, copy params and set flag2[1]
	tst.w	d0
	bge.s	macro_ok
skip_mac2:
	bsr.s	bad_macro
macro_ok:	move.l	a0,a1	save new text pos
	move.l	(sp)+,a0
	move.l	a1,a0	get new text pos in macro buffer
	rts
		
bad_macro:	qmove.l	a0,-(sp)
	lea	bad_macro_text(pc),a0
	bsr.l	pass2_error
	move.l	(sp)+,a0
	rts
	
not_implemented:	qmove.l	a0,-(sp)	
	lea	ni_text(pc),a0
	bsr.l	pass2_error
	move.l	(sp)+,a0
	rts
 
************************************************************************* 
lines_text:	DC.B	" Lines assembled into ",0
bytes_text_2:	dc.b	" bytes",13,13,0
ni_text:	dc.b	"Sorry, but a few instructions are not implemented"
	dc.b	" in this unregistered version. Please register.",13,13,0
bad_macro_text:	DC.B	"This Macro has not been defined.",13,13,0
code_text:	dc.b	"Code is ",0
	align
	public	pass2,not_implemented
	extern	check_keyboard,get_fields
	extern	replace_params
	extern	printit,printnum,directive
	extern	inst_search,ass_table
	extern	try_macro,pass2_error,print_space,printcr
	extern	postfix_logic
	extern	restore_field_2,replace_requs,do_kbd,replace_params2
	extern	check_idle
	extern	expand_internal_strings
	extern	ppc_ass_table,ppc_flass_table,ppc_int_jumptable
	extern	ppc_fass_table,ppc_trap_jumptable,ppc_cmp_jumptable,inst_search12
	extern	ppc_vector_jumptable,
	
	extern_data	inst_table_lower,inst_table,code_table
**v4
	extern_data	ppc_string_table,ppc_code_table
	extern_data	ppc_int_code_table,ppc_int_string_table
	extern_data	ppc_cmp_code_table,ppc_cmp_string_table
	extern_data	ppc_trap_code_table,ppc_trap_string_table
	extern_data	ppc_fcode_table,ppc_fsyntax_table
	extern_data	ppc_flsyntax_table,ppc_flcode_table
	extern_data	ppc_reserved_table
	extern_data	ppc_vector_string_table,ppc_vector_code_table
