*********************************************************************
*MODULE:	PASS 1			*
*DATE:	180594			*
*LAST MODIFIED:	160794			*
*PROGRAMMER:	S.BALL			*
*VERSION:	3			*
*FANT REL VER:	1			*
*DESCRIPTION:	BUILDS LABEL TABLE AND CHECKS SYNTAX	*
*********************************************************************

*PASS1_NOW BUILDS THE LABEL TABLE AND CHECKS THE SYNTAX OF 
*EVERYTHING (I HOPE!)
pass1_now:
	qmove.l	#4550,time_to_idle(a5)	*when we call a_idle
	qmove.l	#0,d0
	qmove.l	d0,last_tree_address_used(a5)
	qmove.l	d0,actual_number_of_labels(a5)
	qmove.l	d0,actual_number_of_tocnames(a5)
	qmove.l	d0,tocnames_last_tree_address_used(a5)	
	qmove.l	d0,equ_last_tree_address_used(a5)
	qmove.l	d0,actual_number_of_equates(a5)
 	qmove.l	d0,entry_point(a5)
 	qmove.l	d0,macro_depth_index(a5)
 	qmove.l	d0,source_pointer_save_index(a5)
 	qmove.l	d0,macro_nest_depth(a5)
	qmove.l	#4,toc_offset_counter(a5)	*starts at 4 because of pointer to BSS at zero!
	qmove.l	#$20,xcoff_bss_size(a5)
	qmove.l	d0,toc_names_pos(a5)	*index into toc_names_table
 	qmove.l	d0,total_imports_num(a5)	*total number of imports
	qmove.b	d0,rs_autoalign(a5)
	qmove.b	d0,macros_first(a5)	*1 if so
	qmove.b	d0,saved_if_depth_array_index(a5)	*for break directive
	qmove.b	d0,break_flag(a5)	*break

 qmove.l d0,lt_pos(a5) 	*lable table index (step 32)
 qmove.w d0,lt_num(a5) 	*total number of labels
 qmove.l d0,eq_pos(a5) 	*equate table position
 qmove.l d0,equ_num(a5)
 qmove.l d0,reloc_tab_pos(a5) 	     *relocation table index
 
 qmove.w	d0,m_label_count(a5)	*macro labels internal counter
 qmove.l	d0,macro_num(a5)	*number of macros
 qmove.w	d0,m_label_count(a5)	*auto label counter
 qmove.b	d0,if_depth(a5)
 qmove.l #1,line_count(a5) 	*line counter
 qbset #0,flags(a5) 	 *set assembly flag
 qbclr #1,flags(a5) 	 *clear pass 2 flag
 qbclr	#7,flags5(a5)	*clear defall flag
 qbclr	#4,flags2(a5)	*clear fatal error flag
 qmove.l	d0,pc(a5) *set pc
 qbclr	#1,flags6(a5)	*tron flag
 qmove.b	d0,abort(a5)
 qmove.l	d0,globisrs_flag(a5)
 qmove.w #2,size2(a5) 	 *510b1 bug fix - link instruction was not setting this

***** llbls-rp200797 *******
 bsr.l	init_local_label_handler
 extern	init_local_label_handler
**** end of llbls-rp200797 *******
 bsr.s do_it
 tst.w	d0
 rts
*************************************************************
do_it:
 movea.l source_buff(a5),a0 	*source is here
 movea.l labels(a5),a1 	*where the label table will be built
 qmoveq #0,d7 	 	 *assembler pc

pass1_loop:
	global	pass1_loop
	tst.b	abort(a5)	
	bne	p1now_end
**if postfix flags [0] is set here, it means an instruction with a dot that wasn't necessary!
	btst	#0,postfix_flags(a5)
	beq.s	dot_ok
	push	a0
	lea	dot_text(pc),a0
	bsr.l	pass1_error
	pop	a0
	qbclr	#0,postfix_flags(a5)
dot_ok:
	qbclr	#1,ppc_flags1(a5)	*error report true field 2
	qmove.l	pc(a5),d0	*check we havent run outta mem
	cmp.l	code_sz(a5),d0
	blt.s	code_sz_ok
	qmove.l	#5050,d0	alert
	bsr.l	do_alert
	OSExitToShell
;	dc.w	exittoshell	emergency exit
	
code_sz_ok:
	subq.l	#1,time_to_idle(a5)
	bne.s	no_idle1

	bsr.l	check_idle	*checks events evry 20 isnts unless no backgrounding
no_idle1:
	andi.b	#%10011111,flags(a5)	*clear bits 5 and 6 of flags

	qmove.l a0,source_save(a5) 	*save source pos in case of error
	addq.l #1,line_count(a5) 	*another line assembled

**********v4.10
	tst.b	start_macro_copy(a5)
	beq.s	not_start_macro
	clr.b	start_macro_copy(a5)
;	bra.s	not_start_macro
not_start_macro:
**************end v4.10

	qbsr get_fields 	*get field 1,2,3 in field_1,field_2 etc
	bsr.l	expand_internal_strings	*for field 3 (fant 5)	*file
nsm1:
**source_save is start of line, a0 is end
	lea	field_1(a5),a2
	lea	field_2(a5),a3
	lea	field_3(a5),a4

	cmpi.b	#$ff,(a2)
	beq	p1now_end 	*eof
 
	cmpi.l	#"endm",(a3)	*v1.02
	beq.s	endm1	
	cmpi.l	#"ENDM",(a3)
	bne.s	not_finish_macro
endm1:
 	btst	#0,flags2(a5)	*in a macro defintition?
	beq	macro_err_3	*nope, possible error if not copying

	bsr.l	finish_macro
**v5.1
	bra	pass1_loop	*copy endm to macro buffer and reset flag
 
not_finish_macro:
**if we have executed a break, the opnly thing we are looking for is an endm
	tst.b	break_flag(a5)
	bne	pass1_loop

**end of test
	btst	#0,flags2(a5)	*v1.02 in a copy macro phase
 	beq.s	not_copy_macro	*v1.02
 	bsr.l	copy_macro	*copy this line to macro buffer
	tst.w	d0
	bmi	p1_f_error	 *Error in copy text
 	bra	pass1_loop
 
not_copy_macro:
 	btst	#1,flags2(a5)	*v1.02 - assembling from macro?
 	beq.s	no_mac
  
 	 bsr.l	replace_params	*v1.02 - replace parameters in fields with real values

no_mac:
	tst.b (a2) 		*1st field blank (no label)?
	beq.s instruction 	*yes

*****here we've found a label
	btst	#0,flags(a5) 	*check assembly flag
	beq.s	instruction 	*assembly is off so dont check labels
nm2:	bsr	copy_label 	*copy label to labels then check out instruction
****look for a directive
 
instruction:
**if macros_first
	tst.b	macros_first(a5)
	beq.s	skip_mac1
	btst	  #0,flags(a5)
	beq	skip_mac1	*assembly off, so next line
	bsr.l	try_macro	*in macro_routines.s - change for 5.1
	beq	pass1_loop
skip_mac1:
	bsr.l	directive 	*returns d0=+1 if not directive,0 if is and -1 if fatal
	qbclr	#4,ppc_flags1(a5)	*not in directive any more!
 	btst	#4,flags2(a5)
	bne	p1_f_error	*fatal error
	tst.w	d0
	bne.s	not_directive
**tron for directives
	btst	#0,flags(a5)
	beq	pass1_loop	ass off
	btst	#1,flags6(a5)	tron
	beq.s	no_tron
	save_all
	bsr	munge_fields
	lea	composite_line(pc),a0
	bsr.l	printit
;	 lea	 field_1(a5),a0	print fields
;	 bsr.l	 printit
;	 bsr.l	 print_space
;	 lea	 field_2(a5),a0
;	 bsr.l	 printit
;	 bsr.l	 print_space
;	 lea	 field_3(a5),a0
;	 bsr.l	 printit
;	 bsr.l	 printcr
	bsr.l	check_escape
	restore_all
no_tron:
	bra	pass1_loop
	
not_directive:	btst	#0,flags(a5)
	beq	pass1_loop 	*assembly off, so next line
**tron for rest
	btst	#1,flags6(a5)
	beq.s	no_tron1
	save_all
	bsr	munge_fields
	lea	composite_line(pc),a0
	bsr.l	printit

;	 lea	 field_1(a5),a0	print fields
;	 bsr.l	 printit
;	 bsr.l	 print_space
;	 lea	 field_2(a5),a0
;	 bsr.l	 printit
;	 bsr.l	 print_space
;	 lea	 field_3(a5),a0
;	 bsr.l	 printit
;	 bsr.l	 printcr
;
	restore_all
no_tron1:
 	bsr	assemble 	*returns d0=-1 if not instruction
	beq	pass1_loop	instruction ok
**macros first, skip this
	tst.b	macros_first(a5)
	bne.s	syntax_error
**we have to restore field 2
	bsr	restore_field_2	
	bsr.l	try_macro	*in macro_routines.s
	bne.s	syntax_error
 	qmove.b	#1,start_macro_copy(a5)
	bra	pass1_loop
	
syntax_error:	qmove.l	a0,-(sp)	save source pos
	lea	tripe_text(pc),a0
	bsr.l	pass1_error
	qmove.l	(sp)+,a0	restore source pos
	bra	pass1_loop
	rts_	"pass1_lo"
	align
	
p1now_end:	clr.w	d0
	rts
p1_f_error:	moveq	#-1,d0
	rts
**macro error 3 picks up on endm when we arent in a macro definiton.
**it checks if we're reading from macro buffer, if not generates an error.
macro_err_3:	btst	#1,flags2(a5)
	beq.s	real_error
	bsr.l	finish_macro
**get if depth at start of macro
	lea	saved_if_depth_array(a5),a1
	clr.l	d0
	move.b	saved_if_depth_array_index(a5),d0
	beq.s	saved_if_depth_array_index_top	*prevent errors and ignore excessive "breaks"
	subq.b	#1,d0
saved_if_depth_array_index_top:
	add.l	d0,a1
	qmove.b	d0,saved_if_depth_array_index(a5)

	tst.b	break_flag(a5)
	beq.s	wasnt_break
	clr.b	break_flag(a5)
**tidy up ifs
	clr.b	if_scan(a5)
	qmove.b	(a1),if_depth(a5)	*if depth back to what it was at at start of breaked macro
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
wasnt_break:

	bra	pass1_loop	*copy endm to macro buffer and reset flag

real_error:	qmove.l	a0,-(sp)
	lea	macro_3_err(pc),a0
	bsr.l	pass1_error
	move.l	(sp)+,a0
	bra.s	p1_f_error
	
******************level 2 subs follow*********************************
munge_fields:	
	lea	composite_line(pc),a1
	lea	field_1(a5),a0
	bsr	copy_cstring
	qmove.l	#"    ",(a1)+
	lea	field_2(a5),a0
	bsr	copy_cstring
	qmove.l	#"    ",(a1)+
	lea	field_3(a5),a0
	bsr	copy_cstring
	qmove.w	#0x0d00,(a1)+
	rts
copy_cstring:
	move.b	(a0)+,(a1)+
	bne.s	copy_cstring
	subq.l	#1,a1
	rts_	"copy_cstring"
;	lea	field_1(a5),a0	print fields
;	 bsr.l	 printit
;	 bsr.l	 print_space
;	 lea	 field_2(a5),a0
;	 bsr.l	 printit
;	 bsr.l	 print_space
;	 lea	 field_3(a5),a0
;	 bsr.l	 printit
;	 bsr.l	 printcr

*restore field 2 is called if:
**ppc and directives and insts have failed so macros get a good run at the macro name :-)
restore_field_2:
	btst	#0,ppc_flags1(a5)
	beq.s	end_rf2			*dont do if 68k
	lea	error_op_field(a5),a2
	lea	field_2(a5),a1
find_endrf2:
	move.b	(a2)+,(a1)+
	bne.s	find_endrf2
end_rf2:
	rts_	"restore_field_2"
		
*assemble attempts(!) to assemble the current instruction at pc
*syntax is also checked here - i.e. if the current instruction isnt
*found then it dont exist!
*a0 must be preserved
assemble:
	qmove.l a0,-(sp)
	lea field_2(a5),a3 	*point to instruction
	tst.b (a3)
	beq.s no_inst 		*blank field
	ifne	powerf
	btst	#0,ppc_flags1(a5)
	bne.s	do_ppc_asm
	endif
**changed for 5.1
	lea inst_table(pc),a2 	*basic instruction table
	bsr.l	inst_search	*in search_labs.s
	beq	got_inst_upper
	lea inst_table_lower(pc),a2 	*basic instruction table
	bsr.l	inst_search	*in search_labs.s
	bmi.s not_inst
got_inst_upper:
	lea code_table(pc),a1 
**LXT
	qpush1	d0
	lsl.l	#1,d0
	add.l	d0,a1
	qmove.w	(a1),d1
	qpop1	d0
;	move.w 0(a1,d0.l*2),d1 	*get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle
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
	lea	ass_table(pc),a1	in pass2
	lsl.l	#3,d0
	add.l	d0,a1
*	move.l	0(a1,d0.l*8),a0	need fant v2.05 to assemble this
	jsr	(a1)	assemble this inst
	endif
no_inst:	move.l 	(sp)+,a0
	clr.l	d0
	rts
not_inst:	move.l	(sp)+,a0
	moveq	#-1,d0	inst not found
	rts_	"assemble"
	align
****fant v4
	ifne	powerf
do_ppc_asm:
	qmove.l	a3,-(sp)
	lea	field_3(a5),a3
	bsr.l	replace_requs
	qmove.l	(sp)+,a3	
	bsr	postfix_logic	*strip  dots,a's,lr's and ctrls from end
	cmpi.w	#"cr",(a3)
	beq.s	do_branches
	cmpi.b	#"s",4(a3)
	bne.s	not_poss_mcrfs
	cmpi.l	#"mcrf",(a3)
	beq.s	try_integer	*its mcrfs	
not_poss_mcrfs:
	cmpi.l	#"mcrf",(a3)
	beq.s	do_branches
	cmpi.w	#"sc",(a3)
	beq.s	do_branches
	cmpi.b	#"b",(a3)	*is it a branch?
	bne.s	try_integer

do_branches:
	lea 	ppc_string_table(pc),a2	*basic instruction table
	bsr.l	inst_search		*in search_labs.s
	bmi.s	not_inst
	lea	ppc_code_table(pc),a1 
**LXT
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
***now we branch to the right routine to handle
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
	rts_	"powerpc_asm_branches"
try_integer:
	cmpi.b	#"f",(a3)
	bne.s	not_float1
	lea 	ppc_fsyntax_table(pc),a2	*basic instruction table
	bsr.l	inst_search		*in search_labs.s
	bmi	not_inst
	lea	ppc_fcode_table(pc),a1 
**LXT
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0
;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
***now we branch to the right routine to handle
	if	PPC
	macs_last
	lwz	r21,[t]ppc_fass_table(rtoc)
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

	lea	ppc_fass_table(pc),a1	in pass2
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0	assembled
	rts_	"powerpc_asm_float"

not_float1:
	cmpi.w	#"lf",(a3)
	bne.s	not_float_load
do_fl:
	lea 	ppc_flsyntax_table(pc),a2	*basic instruction table
	bsr.l	inst_search		*in search_labs.s
	bmi	not_inst
	lea	ppc_flcode_table(pc),a1 
**LXT
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0

;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
***now we branch to the right routine to handle
	if	PPC
	macs_last
	lwz	r21,[t]ppc_flass_table(rtoc)
	slwi	r3,r3,6	*times 64
	add	`temp_reg2,r3,r21
	mtctr	`temp_reg2	*where we go to
	bl	here4
here4:	*address of here in link register
	mflr	`temp_reg1						- 4 bytes
	addi	`temp_reg1,`temp_reg1,16		- 8
	stwu	`temp_reg1,-4(r1)	*put return address on stack	- 12 bytes
	bctr		*16 bytes from "here" to return instruction - 16 bytes
	macs_first
	else

	lea	ppc_flass_table(pc),a1	in pass2
	lsl.l	#3,d0
	add.l	d0,a1
	jsr	(a1)	assemble this inst (basic in d1)
	endif
	move.l	(sp)+,a0
	clr.l	d0	assembled
	rts_	"powerpc_asm_float_load"
not_float_load:		
	cmpi.l	#"stfs",(a3)
	beq.s	do_fl
	cmpi.l	#"stfd",(a3)
	beq.s	do_fl
	
	cmpi.w	#"cm",(a3)
	beq.s	try_compare

	cmpi.w	#"tw",(a3)	*trapword?
	beq	try_trap
	cmpi.w	#"td",(a3)	*trap double
	beq	try_trap
	cmpi.b	#"v",(a3)
	beq	try_vector	
	lea 	ppc_int_string_table(pc),a2	*basic instruction table
	bsr.l	inst_search		*in search_labs.s
	bmi	not_inst
	lea	ppc_int_code_table(pc),a1 
**LXT
	qpush1	d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d1
	qpop1	d0

;	move.l	0(a1,d0.l*4),d1		  *get instruction code (needs 2.05 to assemble)
***now we branch to the right routine to handle it
***now we branch to the right routine to handle
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
	rts_	"powerpc_asm_integer"

try_compare:
	lea 	ppc_cmp_string_table(pc),a2	*basic instruction table
	bsr.l	inst_search		*in search_labs.s
	bmi	not_inst
	lea	ppc_cmp_code_table(pc),a1 
**LXT
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
	rts_	"powerpc_asm_integer_cmp"
try_trap:
	lea 	ppc_trap_string_table(pc),a2	*basic instruction table
	bsr.l	inst_search		 *in search_labs.s
	bmi	not_inst
	lea	ppc_trap_code_table(pc),a1 
**LXT
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
	bl	here7
here7:	*address of here in link register
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
	bsr.l	inst_search12		 *in search_labs.s
	bmi	not_inst
	lea	ppc_vector_code_table(pc),a1 
	
**LXT
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
	bl	here8
here8:	*address of here in link register
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
	rts_	"try_vector"
	extern	ppc_vector_jumptable
	
*************************
*a3->field 2
postfix_logic:	
	clr.b	postfix_flags(a5)
	move.l	a3,a2	*save
**copy op field to error_op_field(a5) and find end so error has english to report!
	lea	error_op_field(a5),a1
find_endpf:
;	move.b	(a3)+,d0
;	move.b	d0,(a1)+
;	tst.b	d0
	move.b	(a3)+,(a1)+
	bne.s	find_endpf
	
	
	subq.l	#2,a3	*->last char
	qbclr	#1,ppc_flags1(a5)	*op stripped if set to 1 - for error report
	cmpi.b	#"+",(a3)
	bne.s	not_plus
	qbset	#5,postfix_flags(a5)
	qbset	#1,ppc_flags1(a5)
	clr.b	(a3)
	subq.l	#1,a3
not_plus:

	cmpi.b	#"-",(a3)
	bne.s	not_minus
	qbset	#1,ppc_flags1(a5)
	clr.b	(a3)
	subq.l	#1,a3
not_minus:

	cmpi.b	#".",(a3)
	bne.s	not_dot
	qbset	#0,postfix_flags(a5)
	qbset	#1,ppc_flags1(a5)
	clr.b	(a3)	*remove dot
	subq.l	#1,a3	*point to prev. char (cant auto)
not_dot:
	cmpi.b	#"b",(a2)
	bne.s	not_a	*only for branches	
	cmpi.b	#"a",(a3)	*there are a few instrs that end in a, but we'll handle them
	
	bne.s	not_a
	qbset	#1,postfix_flags(a5)
	qbset	#1,ppc_flags1(a5)
	clr.b	(a3)	*remove a
	subq.l	#1,a3
not_a:	cmpi.b	#"b",(a2)
	bne.s	not_l
	cmpi.b	#"l",(a3)	*special:rldicl
	bne.s	not_l
	qbset	#2,postfix_flags(a5)
	qbset	#1,ppc_flags1(a5)
	clr.b	(a3)
	subq.l	#1,a3
not_l:
**check for lr as in bltlrl
	cmpi.b	#"b",(a2)
	bne.s	not_rl
	cmpi.b	#"r",(a3)
	bne.s	not_rl
	cmpi.b	#"l",-1(a3)
	bne.s	not_rl
	qbset	#3,postfix_flags(a5)	*to link register
	qbset	#1,ppc_flags1(a5)
	clr.b	(a3)
	subq.l	#1,a3
	clr.b	(a3)
	subq.l	#1,a3
not_rl:
**check for ctr
	cmpi.b	#"b",(a2)
	bne.s	not_ctr
	cmpi.b	#"r",(a3)
	bne.s	not_ctr
	cmpi.b	#"t",-1(a3)
	bne.s	not_ctr
	cmpi.b	#"c",-2(a3)
	bne.s	not_ctr
	qbset	#4,postfix_flags(a5)	*count reg
	qbset	#1,ppc_flags1(a5)
	clr.b	(a3)
	subq.l	#1,a3
	clr.b	(a3)
	subq.l	#1,a3
	clr.b	(a3)
	subq.l	#1,a3
not_ctr:
	move.l	a2,a3
	rts_	"postfix_logic"		
	endif	
*******************************************************************************	
*copy label is the first real routine of this assembler
*firstly it has to see if the label is followed by an equate.
*if it is, then it is skipped in this routine, as we dont have all
*the references yet
*it has to copy the label from the source (a0) to a label buffer (a3)
*then it has to search the label table to see if the label is already
*defined, if it is then it generates an error. if the label isnt defined
*then it copies it to the label table, along with its address
*we actually have 2 label tables:
*labels is split up into 32 byte segments, so each label can be 32 bytes
*long.
*lab_val is split up into 4 byte segments and holds the address of each
*label.

copy_label:
**406 - if ppc then check for reserved labels being defined as code labels
	lea	field_1(a5),a4
	cmpi.l	#"NARG",(a4)
	bne.s	not_narg
	tst.b	4(a4)
	beq	defined_error_reserved	*narg is a reserved label
not_narg:
	cmpi.l	#"narg",(a4)
	bne.s	not_narg1
	tst.b	4(a4)
	beq	defined_error_reserved	*narg is a reserved label
not_narg1:

	cmpi.l	#"RSSZ",(a4)
	bne.s	not_rssz
	tst.b	4(a4)
	beq	defined_error_reserved	*narg is a reserved label
not_rssz:
	cmpi.l	#"rssz",(a4)
	bne.s	not_rssz1
	tst.b	4(a4)
	beq	defined_error_reserved	*narg is a reserved label
not_rssz1:

	cmpi.l	#"GBSZ",(a4)
	bne.s	not_gbsz
	tst.b	4(a4)
	beq	defined_error_reserved	*narg is a reserved label
not_gbsz:
	cmpi.l	#"gbsz",(a4)
	bne.s	not_gbsz1
	tst.b	4(a4)
	beq	defined_error_reserved	*narg is a reserved label
not_gbsz1:

	btst	#0,ppc_flags1(a5)
	beq.s	reserved_no
	lea	field_1(a5),a4
	lea	ppc_reserved_table(pc),a1	search equates
	bsr.l	dir_search 	*search a1 for a4 returns position in d0 or -1
;	tst.w	d0 
 	bge	defined_error_reserved	*-ve=not found

reserved_no:	
 lea field_1(a5),a3
 lea field_2(a5),a2
**v1.02 set directive
	qmove.l	(a2),d0
	cmpi.l	#$73657400,d0	*set?
	beq.s	tis_set
	cmpi.l	#$53455400,d0	*field 2=set?
	bne.s	not_set
tis_set:
	rts		*just return if set, as directives handles it
not_set:
**dont do len either - it's a dirctive which calls set
	cmpi.l	#$6c656e00,d0	*len?
	beq.s	tis_set
	cmpi.l	#$4c454e00,d0	*field 2=len?
	beq.s	tis_set


	cmpi.l	#"ASC$",d0	*len?
	beq.s	tis_set
	cmpi.l	#"asc$",d0	*field 2=asc$?
	beq.s	tis_set
	
	cmpi.l	#"REQU",d0
	beq.s	is_requ
	cmpi.l	#"requ",d0	directives handles em
	beq.s	is_requ

	cmpi.l	#"FNDC",d0
	beq.s	tis_set
	cmpi.l	#"fndc",d0	directives handles em
	beq.s	tis_set
	bra.s	not_requ

is_requ:
	rts
not_requ:
	cmpi.l	#$72656700,d0	reg
	beq.s	is_reg
	cmpi.l	#$52454700,d0	reg
	bne.s	not_equr
is_reg:	rts
	
not_equr:
**v4 mods for case insensitive
	cmpi.l	#$65717500,d0	*equ
	beq	cl_end
	cmpi.l	#$45515500,d0 *field 2=equ?
	beq	cl_end 	*yes, we're not interested in equs yet

	cmpi.w	#"rs",(a2)
	beq	cl_def_end
	cmpi.w	#"RS",(a2)	*check for rs directive, we handle them seperately
	beq	cl_def_end

	cmpi.l	#"obof",2(a2)	gl obof f.s?
	beq	cl_def_end
	cmpi.l	#"OBOF",2(a2)
	beq	cl_def_end
	
	cmpi.l	#"macr",d0
	beq	copy_m_to_buf	*its a macro definition, copy label and buff pos
	cmpi.l	#"MACR",d0
	beq	copy_m_to_buf
**if it's of the form [x$] or [x$]: then skip it!	
	cmpi.b	#"[",(a3)
	bne.s	not_string
	cmpi.b	#"$",2(a3)
	bne.s	not_string
	cmpi.b	#"]",3(a3)
	bne.s	not_string
	move.b	4(a3),d0
	beq	cl_def_end	*[x$]
	cmpi.b	#":",d0
	beq	cl_def_end	*[x$]:
	
not_string:	
*here we've found a real label
*we need to check if its in the label table already
splat:
	bsr.l	test_for_locals		; rp 14/9/97 equate table holds the set labels

 	qmove.l	equates(a5),tree_strings_ptr(a5)
 	move.l	equates_tree(a5),a2
	bsr.l	equ_tree_search
	tst.w	d0
	bge	defined_error	*defined in equates


;	move.l	equates(a5),a4	search equates
;	bsr.l	search_labp2
;	bge	defined_error
	
; movea.l labels(a5),a4 	*labels live here
; bsr.l search_labp2 	  *see if it is defined already returns d0
; bge defined_error

;insert_label:		*external uses this entry 
; movea.l labels(a5),a4
; adda.l lt_pos(a5),a4 	*lt pos is inc'd by 32 for every label
;copy_lab_to_tab: 	 *now copy the label into the table
; move.b (a3)+,(a4)+
; bne.s copy_lab_to_tab
;	debug


; ******* llbls-rp200797 *********
;	bsr.l	test_for_locals		; rp 14/9/97 move to before equates (see above)
; ******* llbls-rp200797 *********

 	qmove.l	labels(a5),tree_strings_ptr(a5)
 	move.l	labels_tree(a5),a2
; 	 lea	 word_buff(a5),a1
;	moveq	#63,d0
;copy_lab12:
;	move.b	(a3)+,(a1)+
; 	 beq.s	 cl12
; 	 dbra	 d0,copy_lab12
;cl12:
**onjkect to search and insert in a3
	bsr.l	lab_tree_insert
	tst.w	d0
	bmi	defined_error
	 
 addq.w #1,lt_num(a5) 	*inc total number of lables
 movea.l lab_val(a5),a4 	*now save its address
 qmove.l lt_pos(a5),d0 	*position/8=right place for long word 
 lsr.l #3,d0
**if ppc and field 2 is dc. or ds. we have to insert the data_offset rather than the pc
	btst	#0,flags7(a5)
	beq	68k_label
;	btst	#0,ppc_flags3(a5)
;	bne.s	ppc_data

	lea	field_2(a5),a3
	qcmove.w	(a3),d1
	cmpi.w	#"df",d1
	beq.s	poss_ppc_data	*v5 - for float
	cmpi.w	#"DF",d1
	beq.s	poss_ppc_data	*v5 - for float.
;	if	PPC
	
;	else
	cmpi.w	#"dc",d1
	beq.s	poss_ppc_data	*v4.11 - for label: dcbz taking data section.
	cmpi.w	#"DC",d1
	beq.s	poss_ppc_data
;	endif
	cmpi.w	#"ds",d1
	beq.s	poss_ppc_data
	cmpi.w	#"DS",d1
	beq.s	poss_ppc_data

	qmove.l	(a3),d1		*5.10a4
	cmpi.l	#"pstr",d1
	beq.s	ppc_data	*pstring directive
	cmpi.l	#"PSTR",d1
	beq.s	ppc_data
	cmpi.l	#"data",d1	*4.10
	beq.s	ppc_data
	cmpi.l	#"DATA",d1
	beq.s	ppc_data
	
	cmpi.l	#"cstr",d1
	beq.s	ppc_data	*cstring directive
	cmpi.l	#"CSTR",d1
	beq.s	ppc_data
	bra.s	68k_label
poss_ppc_data:
**check for sin. at 2(a3)
	cmpi.l	#"sin.",2(a3)	*dfsin.s/d
	beq.s	ppc_data
	cmpi.l	#"SIN.",2(a3)	*dfsin.s/d
	beq.s	ppc_data
	cmpi.b	#".",2(a3)	*dc.?
	bne.s	68k_label	*no
	
ppc_data:
	qmove.l	data_item_count(a5),d1
;	qmove.l	#0,d2				; bug fix rp & sb 20/7/97
	qmove.l	total_imports_num(a5),d2
;;;;;; bug fix rp & sb 20/7/97	ext.l	d2
	add.l	d2,d1
	addq.l	#1,d1	*because first entry in toc is pointer to global
	lsl.l	#2,d1
	qbset	#31,d1		*set flag so when we retrieve it we know it is a data offset
	
	qmove.l	d1,0(a4,d0.l)	*store address of data in data buffer
	addi.l	#32,lt_pos(a5)
**check for null field 2 and inc data_item_count if so!
;	debug
;	lea	field_2(a5),a3
;	move.b	(a3),d1
;	bne.s	will_be_incd	*by releavnt dc or ds etc
;	bsr.l	dcb		*do a dummy
;	move.l	data_buffer_index(a5),d7 	*get current pos
;	move.l	data_item_offsets(a5),a1	*store offset
;	move.l	data_item_count(a5),d0
;	move.l	d7,0(a1,d0.l*4)		*store its offset in data_item_offsets
;	addq.l	#1,data_item_count(a5)		
will_be_incd:
	rts_	"copy_lab_ppc_dcds_def"			
68k_label:
;	btst	#0,ppc_flags3(a5)
;	beq.s	not_data_sect
;	save_all
;	lea	data_sect_warning(pc),a0
;	bsr.l	pass1_warning
;	restore_all
not_data_sect:
	qmove.l pc(a5),0(a4,d0.l) 	 *store address
	addi.l #32,lt_pos(a5) 	*ready for next label
	rts_	"copy_lab"
***her we've found an equate which needs to go in equates
***first we need to see if its defined already
*equates are defined exactly the same as labels with 32bytes
*for the label name
cl_end:


	cmp.b	#".",(a3)		; ***** llbls-rp200797
	beq	equ_local_error		; ***** llbls-rp200797


; 	 move.l	labels(a5),a4
;	bsr.l	search_labp2
;	debug
 	qmove.l	labels(a5),tree_strings_ptr(a5)
 	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search

	tst.w	d0
	bge	defined_error

 	qmove.l	equates(a5),tree_strings_ptr(a5)
 	move.l	equates_tree(a5),a2
	bsr.l	equ_tree_insert
	tst.w	d0
	bmi	defined_error


; movea.l equates(a5),a4 	 *labels live here
; bsr.l search_labp2 	  *see if it is defined already returns d0
* tst.w d0 		*-1=not found else position
; bge defined_error
 
; movea.l equates(a5),a4
; adda.l eq_pos(a5),a4 	*lt pos is inc'd by 32 for every label
;copy_equ_to_tab: 	 *now copy the label into the table
; move.b (a3)+,(a4)+
; bne.s copy_equ_to_tab
 
 addq.l #1,equ_num(a5) 	*inc total number of lables
 movea.l eq_val(a5),a4 	*now save its address
 qmove.l eq_pos(a5),d0
 lsr.l #3,d0
 add.l d0,a4 		*point to right place 32/8=4 (longword)

**now we have to get the value of the equate!
 lea field_3(a5),a2 	*value of equate in field 3
 qmove.w flags(a5),f_save(a5) 	 save state of flags
 qbset #1,flags(a5) 	 *pretend we're on pass 2 even if we're not!
 bsr recurs_eval	*this returns in d0 the value of the string - v2.00
 qmove.w f_save(a5),flags(a5) 	 *restore flags
 qmove.l d0,0(a4) 	 *store value.l
 addi.l #32,eq_pos(a5) 	*ready for next label
cl_def_end:	rts_	"copy_equ"
	align
	
**copy macro
copy_m_to_buf:	

	cmp.b	#".",(a3)		; ***** llbls-rp200797
	beq	macro_local_error	; ***** llbls-rp200797


	move.l	macro_labels(a5),a4
	bsr.l	search_labp2	use pass 2 search algorithm
*	tst.w	d0
	bge.s	defined_error

	move.l	macro_labels(a5),a4	label table for macros
	add.l	macro_pos(a5),a4	index into table
copy_macro_to_tab:
	move.b	(a3)+,(a4)+	copy macro name
	bne.s	copy_macro_to_tab
	movea.l	m_labels_index(a5),a4	point to address of values
	qmove.l	macro_pos(a5),d0	position in macro values
	lsr.l	#3,d0		32/8 is long
	add.l	d0,a4		right place 9each is 32 bytes)
	qmove.l	m_text_pos(a5),(a4)	store position in text
	addi.l	#32,macro_pos(a5)	ready for next label
	rts_	"copy_m_b"
	align
	
defined_error:	qmove.l a0,-(sp) ;	 *save source position
	lea defined_text(pc),a0	*print defined twice
	bsr.l	pass1_error
	movea.l (sp)+,a0
	rts

defined_error_reserved:	qmove.l a0,-(sp) ;	 *save source position
	lea defined_text_reserved(pc),a0	*print defined twice
	bsr.l	pass1_error
	movea.l (sp)+,a0
	rts


; ***** llbls-rp200797 *******
equ_local_error:
	qmove.l	a0,-(sp)
	lea	equ_local_text(pc),a0
	bsr.l	pass1_error
	move.l	(sp)+,a0
	rts_	"equ_local_error"

macro_local_error:
	qmove.l	a0,-(sp)
	lea	macro_local_text(pc),a0
	bsr.l	pass1_error
	move.l	(sp)+,a0
	rts_	"macro_local_error"

; ***** llbls-rp200797 *******
	

***search a macro table (a4) for (a3)
***a3 can be terminated in either . or 0
***return d0=-1 if not found
*else d0=position
*a1 = end of search string (ie size char)
search_mac:
	qmoveq #-1,d0 	 	 *position counter
	qmove.l a0,-(sp) 	 *save source position
	movea.l a3,a0		*save_label
	movea.l a4,a1
	lea 32(a1),a1		*a1 points to next entry
ser_mac_loop:	addq.l #1,d0 		*inc table position counter
	tst.b (a4) 		*end of labels
	beq.s search_mac_end 	*yes
ser_mac_lp1:	move.b (a3)+,d1
	beq.s found_mac		*found match
	cmpi.b	#".",d1
	beq.s	found_mac	*macs can be termed in size (.l,.w etc)
	cmp.b (a4)+,d1  	*compare strings
	beq.s ser_mac_lp1
 
ser_mac_2: 		*no match
	move.l a1,a4		*not found so point to next entry
	lea 32(a1),a1
	move.l a0,a3		*reset label
	bra.s ser_mac_loop
**here the label has terminated, but we need to see if
**the table entry has terminated
found_mac:
	tst.b (a4)
	bne.s ser_mac_2		*no, so we havent found it
	move.l	a3,a1	*a1=size or end
	movea.l a0,a3		*restore label
	movea.l (sp)+,a0
	rts 		*do contains position

search_mac_end:	movea.l a0,a3		*restore label
	movea.l (sp)+,a0 	*restore source position
	moveq #-1,d0
	rts_	"srch_mac"
	align
***get_fields gets the label field, the op code field and the
***operands in field_1,2,3.
***if a field doesnt exist then the 1st byte of the field is set 
***to 0
***it leaves a0 pointing to the next line
***mega hot spot!
***v4 if ppc then field 2 is converted to upper case (the instruction)
**Quick routine
get_fields:
	qmoveq	#$20,d5
	qmoveq	#13,d6
	qmoveq	#"*",d3
	qmove.l	#0,d0
	qmove.b	d0,possible_string_in_field_3(a5)	*set to a 1 if we transfer a [ so we can tell expand_internal_strings whether it's worth running or not!
	qmove.b	d0,possible_string_in_field_2(a5)
	lea	field_3(a5),a2 	*clear the fields
	qmove.b	d0,(a2)
	lea	field_2(a5),a2
	qmove.l	d0,(a2)+ 		   *clear out old instruction
	qmove.l	d0,(a2)+
	lea	field_1(a5),a2
	qmove.b	d0,(a2)
	
	
	move.b	(a0),d0 	*first see if its a comment line
	beq	got_file_end 	*eof
	cmp.l	d3,d0
	beq	find_end 		*yes
	cmpi.l	#$3b,d0	;
	beq	find_end
	cmp.l	d6,d0 	*blank line?
	beq	find_end
	cmpi.l	#"$",d0 	*devst generated filename?
	beq	find_end
	cmp.l	d5,d0	*space?
	bne.s	get_f_1 		*field 1 is blank
	addq.l	#1,a0 		*skip field 1
	bra.s	get_f_2
 

get_f_1:
	qmove.l	#0,d0
	move.b	(a0)+,d0 	*now copy a0 to a2 until space
	beq	got_file_end
	cmpi.l	#":",d0
	beq.s	get_f_1 		*labels can be terminated in :
	cmp.l	d5,d0
	beq.s	got_f_1
	cmp.l	d6,d0
	beq	got_line_end 	*field 1 can be terminated in cr
	qmove.b	d0,(a2)+
	bra.s	get_f_1
got_f_1:
	clr.b	(a2) 		*terminate correctly
get_f_2:
	lea	field_2(a5),a2
	cmp.b	(a0),d3	*?
	beq	find_end 		*comment
	cmpi.b	#$3b,(a0)
	beq	find_end
gf2:
	qmove.l	#0,d0
	move.b	(a0)+,d0
	beq	got_file_end
	cmp.l	#"[",d0
	bne.s	not_a_string2

	st	possible_string_in_field_2(a5)	*tells expand_internal_strings to run
not_a_string2:

	cmp.l	d5,d0 		*space
	beq.s	got_f_2
	cmp.l	d6,d0 		8cr
	beq.s	got_line_end
	qmove.b	d0,(a2)+
	bra.s	gf2
got_f_2:
	clr.b	(a2)
skip_space_run:
	cmp.b	(a0),d5 	*in case there is more than 1 space between 2+3!
	bne.s	get_f_3
	addq.l	#1,a0
	bra.s	skip_space_run

get_f_3:
	qmoveq	#$22,d7		"
	lea	field_3(a5),a2
	cmp.b	(a0),d3	"*"?
	beq.s	got_line_end	*comment
	cmpi.b	#$3b,(a0)
	beq.s	got_line_end
	cmp.b	(a0),d7 	*strings may have spaces in them
	beq.s	gf3_string 	*field 3 is a string


gf3:	clr.l	d0
	move.b	(a0)+,d0
	beq.s	got_file_end
	cmp.l	#"[",d0
	bne.s	not_a_string

	st	possible_string_in_field_3(a5)	*tells expand_internal_strings to run
not_a_string:
	cmp.l	d5,d0 		*space
	beq.s	got_f_3
	cmp.l	d6,d0 		*cr
	beq.s	got_line_end
	cmp.l	d7,d0 		*quotes
	beq.s	gf3_mid_string 	*string in middle of field
	qmove.b	d0,(a2)+
	bra.s	gf3
	
got_f_3
	clr.b	(a2)
	subq.l	#1,a0
	bra.s	find_end
 
gf3_mid_string:
	qmove.b	d0,(a2)+ 	save 1st quote
	bra.s	gf3_loop
 
gf3_string:
	qmove.b	(a0)+,(a2)+ 	*save first quote
gf3_loop:
	move.b	(a0)+,d0
	beq.s	got_file_end
	cmp.b	#"[",d0
	bne.s	not_a_var	*variables in strings is ok
	st	possible_string_in_field_3(a5)	*tells expand_internal_strings to run
not_a_var:

	cmp.b	d7,d0 		*end quotes?
	beq.s	got_f_3s
	cmp.b	d6,d0
	beq.s	got_line_end
	qmove.b	d0,(a2)+
	bra.s	gf3_loop
got_f_3s:
	qmove.b	d0,(a2)+ 	*save end quotes
	bra	gf3 		*carry on with line
 
got_line_end:	clr.b	(a2)
	bra.s	gf_end

find_end:
	qmoveq	#13,d5
fe_1:
	qmove.l	#0,d0
 move.b (a0)+,d0
 beq.s got_end
 cmp.l d5,d0
	bne.s fe_1

got_end:	bra.s	gf_end

got_file_end:
	lea field_1(a5),a2 	*i know this is slow!
	qmove.b #$ff,(a2)
gf_end:
**if ppc then convert field2 to upper case
	bra.s	cu_end
;	btst	#0,flags7(a5)
;	beq.s	cu_end

;	 lea	 field_2(a5),a2
;	 qmoveq	#$7b,d3	*above this is also upper case
;	 qmoveq	#$60,d4 *upper case limit
;	 qmoveq	#32,d7
;
;conv_up:
;	 move.b	(a2),d0
;	 beq.s	 cu_end
;	 cmp.b	 d3,d0
;	 bge.s	 upper_ok	 *if ge 7b the upper case
;	 cmp.b	 d4,d0 		   *if less than _ then it is upper case
;	 ble.s	 upper_ok
;	 sub.b	 d7,d0 		   *make upper case
;	 qmove.b	d0,(a2)
;upper_ok:
;	 addq.l	#1,a2
;	 bra.s	 conv_up
		
cu_end:	qrts
	align 
************FIXED DAT FOLLOWS*********************************
data_sect_warning:	dc.b	"**warning** Code label in data section!",13,13,0
	align	 

defined_text:	DC.B	"Label defined twice in this file.",13,0
defined_text_reserved:	dc.b	"Label is a reserved label - you cannot use it.",13,0
number_err_t:	dc.b	"Error in number.",13,0
tripe_text:	dc.b	"Invalid instruction.",13,0
macro_3_err:	DC.B	"**FATAL** Not in a macro definition.",13,13,0
dot_text:	dc.b	"Error: Dot can not be used on this instruction.",13,0

	align

; ***** LLBLS-RP200797 *******
equ_local_text:	cstring	"Equate labels cannot be local",0
	align
macro_local_text: cstring "Macro labels cannot be local",0
	align
composite_line:	ds.b	1200
	align
; ***** LLBLS-RP200797 *******

	ifne	powerf
	public	postfix_logic
	endif
	public	get_fields,search_mac,copy_label
	global	pass1_now,number_err_t,defined_error
	global	restore_field_2
	extern	do_alert,check_keyboard,finish_macro,replace_params,directive
	extern	try_macro,pass1_error,inst_search
	extern	search_labp2,search_lab,recurs_eval,copy_macro
	extern	printit,printcr,print_space,pass1_warning
	
	extern	ass_table,ppc_ass_table,ppc_trap_jumptable,ppc_cmp_jumptable
	extern	ppc_fass_table,ppc_int_jumptable,ppc_flass_table,inst_search12
	extern_data	inst_table_lower,inst_table,code_table
**v4
	extern_data	ppc_string_table,ppc_code_table
	extern_data	ppc_int_code_table,ppc_int_string_table
	extern_data	ppc_cmp_code_table,ppc_cmp_string_table
	extern_data	ppc_trap_code_table,ppc_trap_string_table
	extern_data	ppc_fcode_table,ppc_fsyntax_table
	extern_data	ppc_flsyntax_table,ppc_flcode_table
	extern_data	ppc_reserved_table,ppc_vector_string_table,ppc_vector_code_table

	
	extern	replace_requs
	extern	pass1_advice,dir_search
	extern	replace_params2
	
	extern	lab_tree_insert,lab_tree_search
	extern	equ_tree_search,equ_tree_insert
	extern	check_idle,test_for_locals,expand_internal_strings
	extern	check_escape