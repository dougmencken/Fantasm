**************Directives_3.s
swg_high:	equ	4
swg_med:	equ	3
swg_low:	equ	2
swg_off:	equ	1

swg_high_directive:
	qmoveq.l	#swg_high,d0
	bra.s	set_swg
swg_med_directive:
	qmoveq.l	#swg_med,d0
	bra.s	set_swg
swg_low_directive:
	qmoveq.l	#swg_low,d0
	bra.s	set_swg
swg_off_directive:
	qmoveq.l	#swg_off,d0
set_swg:
	qmove.l	d0,r2d2_prefs(a5)
**Check if PowerMac
	tst.b	frag_loaded(a5)
	bne	got_frag
	lea	swg_68k(pc),a0
	bsr.l	send_to_log
got_frag:
**Call a warning if using these (only warn on pass 1)
	qmove.l	pass_id(a5),d0
	btst	#1,d0
	bne.s	swg_ppc_ok		; skip on pass 2

	btst	#0,ppc_flags1(a5)
	bne.s	swg_ppc_ok		; skip if ppc
	
	lea	swg_ppc_only_advice(pc),a0
	bsr.l	send_to_log
	extern	send_to_log
	
swg_ppc_ok
	rts_	"swg_blah_directives"
*******************************************
set_ppc:
;	lea ppc_text(pc),a0
;	bsr.l	printit_pass1
	qbset	#0,ppc_flags1(a5)
	rts_	"Set_ppc"
set_68k:
;	lea	text_68k(pc),a0
;	bsr	printit_pass1
	qbclr	#0,ppc_flags1(a5)
	rts_	"set_68k"

*handles alignment of data

align_it:
	qbclr	#2,ppc_flags1(a5)	*alignment back on
	lea field_3(a5),a1
	cmpi.b	#$22,(a1)
	bne	al1
	bsr.l	define_string_warning	*haha crash no more!
	rts
al1:	tst.b	(a1)			*no filed 3?
	beq	default_align		*2 for 68k and 4 for ppc
	cmpi.w	#"of",(a1)		*align off?
	beq	align_off
	cmpi.w	#"on",(a1)
	beq	align_on
	cmpi.w	#"OF",(a1)
	beq	align_off
	cmpi.w	#"ON",(a1)
	beq	align_on
	
	qmove.w flags(a5),f_save(a5) 	 save state of flags
	qbset #1,flags(a5) 	*pretend we"re on pass 2 even if we"re not!
	qmove.l #0,d1
	bsr.l   get_numb 		     *returns number pointed to in a1 in d0 or d1=-1
	qmove.w f_save(a5),flags(a5)
	tst.l	d0
	beq	align_error

	cmpi.l	#2,d0
	beq	even_ok
	cmpi.l	#8,d0
	beq	align_8
	cmpi.l	#4,d0
	beq.s	align_4
	cmpi.l	#16,d0
	beq.s	align_16
	bra	align_error
**align 4
align_4:
	qbclr	#2,ppc_flags1(a5)	*alignment back on
	btst	#0,ppc_flags1(a5)	*ppc?
	bne	align4_ppc
		
	qmove.l pc(a5),d0
align_4a:
	qmove.l	d0,d1
	andi.l	#$3,d1
	beq.s is_4
	addq.l #1,d0		*for a change i'll do it this way
	addq.l #1,code_buffer(a5)
	bra.s	align_4a
is_4:	qmove.l	d0,pc(a5)	
	rts_	"align_4"

**align 4
align_16:
	qbclr	#2,ppc_flags1(a5)	*alignment back on
	btst	#0,ppc_flags1(a5)	*ppc?
	bne	align16_ppc
		
	qmove.l pc(a5),d0
align_16a:
	qmove.l	d0,d1
	andi.w	#$f,d1
	beq.s is_16
	addq.l #1,d0		*for a change i'll do it this way
	addq.l #1,code_buffer(a5)
	bra.s	align_16a
is_16:	qmove.l	d0,pc(a5)	
	rts_	"align_16"


align_8:
	qbclr	#2,ppc_flags1(a5)	*alignment back on
	btst	#0,ppc_flags1(a5)	*ppc?
	bne.s	align8_ppc

	qmove.l pc(a5),d0
align_8a:
	qmove.l	d0,d1
	andi.l	#$7,d1
	beq.s is_8
	addq.l #1,d0		*for a change i'll do it this way
	addq.l #1,code_buffer(a5)
	bra.s	align_8a
is_8:	qmove.l	d0,pc(a5)	
	rts_	"align_8"

	qmove.l pc(a5),d0

align4_ppc:
	qmove.l	data_buffer_index(a5),d0	
align_4p:
	qmove.l	d0,d1
	andi.l	#$3,d1
	beq.s is_4p
	addq.l #1,d0		*for a change i'll do it this way
	addq.l #1,data_buffer(a5)
	bra.s	align_4p
is_4p:	qmove.l	d0,data_buffer_index(a5)	
	rts_	"align_4p"

align16_ppc:
	qmove.l	data_buffer_index(a5),d0	
align_16p:
	qmove.l	d0,d1
	andi.l	#$f,d1
	beq.s is_16p
	addq.l #1,d0		*for a change i'll do it this way
	addq.l #1,data_buffer(a5)
	bra.s	align_16p
is_16p:	qmove.l	d0,data_buffer_index(a5)	
	rts_	"align_16p"

align8_ppc:
	qmove.l data_buffer_index(a5),d0
align_8p:
	qmove.l	d0,d1
	andi.l	#$7,d1
	beq.s is_8p
	addq.l #1,d0		*for a change i'll do it this way
	addq.l #1,data_buffer(a5)
	bra.s	align_8p
is_8p:	qmove.l	d0,data_buffer_index(a5)	
	rts_	"align_8p"

**come here if no field_3
default_align:
	btst	#2,ppc_flags1(a5)
	bne.s	no_align		*auto off
	btst	#0,ppc_flags1(a5)	*ppc or 68k?
	beq	even_ok			*even for 68k
	bra	align_4
no_align:
	rts_	"default_align"
align_error:
	lea	align_error_text(pc),a0
	bsr.l	pass2_error
	rts_	"align_error"

align_on:
	lea	al_on_text(pc),a0
	bsr.l	pass1_advice
	qbclr	#2,ppc_flags1(a5)
	rts
align_off:
	lea	al_off_text(pc),a0
	bsr.l	pass1_warning
	qbset	#2,ppc_flags1(a5)
	rts_	"align_on_off"
************
do_toc_routine:
	btst	#0,ppc_flags1(a5)
	bne.s	ppctr_ok
	lea	ppc_only_text(pc),a0
	bsr.l	pass1_error
	rts_	"Do_toc_routinel"
ppctr_ok:
**if pass 2 then we need to do a dummy call so it gets exported in link
	btst	#1,flags(a5)
	bne	do_dummy		*If p2 then do dummy call
	move.l	toc_code_names(a5),a4	*the table to search
	lea	field_1(a5),a3
	tst.b	(a3)
	beq.s	need_toc_label
	bsr.l	search_labp2	*returns d0=pos or -1 if not found
;	tst.w	d0
	bmi.s	code_def_not_found

	lea	code_def_error(pc),a0
	bsr	pass1_error
	rts_	"Toc_code_def_dupe"
need_toc_label:
	lea	toc_label_text(pc),a0
	bsr	pass1_error
	rts
	
code_def_not_found:
	qcmove.w	ppc_number_of_code_defs(a5),d0
;	ext.l	d0
	cmp.l	toc_code_count(a5),d0		*if number is le than actual
	ble.s	tocs_maxxed			*too many toc defs
	
	movea.l toc_code_names(a5),a4
	add.l	toc_code_names_pos(a5),a4 	*lt pos is inc'd by 32 for every label
	move.l	a4,a2	*save so we can bung in the type
copy_lab_to_ctab: 	 *now copy the label into the table
	move.b	(a3)+,(a4)+
	bne.s	copy_lab_to_ctab
	clr.b	31(a2)	*terminate
	add.l	#32,toc_code_names_pos(a5)	
**Now store the PC at toc_code_offsets(a5)+toc_code_count*4	
	move.l	toc_code_offsets(a5),a3
	qmove.l	toc_code_count(a5),d0
**LXT change
	qpush1	d0
	lsl.l	#2,d0
	qmove.l	pc(a5),0(a3,d0.l)	*save pc, was d0.l*4
	qpop1	d0
	addq.l	#1,toc_code_count(a5)
	rts_	"Do_Toc_Routine_P1"
tocs_maxxed:
	lea	max_tocs(pc),a0
	bsr	printit
	qbset	#4,flags2(a5)		*STOP!		
	rts_	"Imports_maxxed"

**Now we have to do a dummy usage, so it is made global in link
do_dummy:
	btst	#6,flags5(a5)
	beq	no_code_dummy		*linkable? no

	lea	field_1(a5),a3
	move.l	toc_code_names(a5),a4
	bsr.l	search_labp2	*search equs using pass2 algorithm
;	tst.w	d0
	bge.s	found_in_tc	*got it
**try labels for an extern
	move.l	labels(a5),a4	*table to be searched
	bsr.l	search_labp2	*search for this label (was lab)
;	tst.w	d0
	bge.s	found_in_tc1
	moveq	#-1,d1
	rts
found_in_tc1:

	qmoveq	#-1,d0	*its an external code offset
found_in_tc:

	movem.l	a2/a3/a4,-(sp)
	qmove.l	total_code_ptrs_used(a5),d1
	move.l	code_ptrs_output_table(a5),a4
	muls	#40,d1
	add.l	d1,a4		*right place for label and offset
	move.l	a4,a2		*save start of label
	qmoveq	#31,d1
copy_cp_loop:
	move.b	(a3)+,(a4)+
	beq.s	get_out_clause
	qdbra	d1,copy_cp_loop
get_out_clause:

	qmove.l	#-3,32(a2)	*save pc of offset (-3=just a definition in case it isnt used!)
	qmove.l	d0,d1
	lsr.l	#2,d1		*div 4
	btst	#29,d1
	bne.s	its_external	*bung in fffffffc if external

	move.l	toc_code_offsets(a5),a3	*point to code offsets
**LXT
	push	d0
	push	a3
	lsl.l	#2,d0
	add.l	d0,a3
	qmove.l	(a3),d1
	pop	a3
	pop	d0
;	move.l	0(a3,d0.l*4),d1	*was d1	
	qmove.l	d1,36(a2)	*save offset
	addq.l	#1,total_code_ptrs_used(a5)
	clr.l	d1
	movem.l	(sp)+,a2/a3/a4
							
on_pass_1:
	rts_	"Do_toc_routine_P2"
its_external:
	qmove.l	#-1,36(a2)	*save as an external
	addq.l	#1,total_code_ptrs_used(a5)
	clr.l	d1
	movem.l	(sp)+,a2/a3/a4
no_code_dummy:
	rts_	"Do_TOc_routine_p2_ext"		

*****************
set_entry:
	qmove.l	pc(a5),d0
	qbset	#31,d0		*how we flag a real entry
	qmove.l	d0,entry_point(a5)
	rts_	"Set_entry"
	
*****************
import_lab:
	btst	#0,ppc_flags1(a5)
	bne.s	ppc_ok
	lea	ppc_only_text(pc),a0
	bsr	pass1_error
	rts_	"Import_label"
ppc_ok:
	btst	#1,flags(a5)
	bne.s	on_pass_2	*dont do if on p2
**now we have to get the label (third field) and insert it into toc_names_table and its
**value into toc_offsets_table
;	move.l	toc_names_table(a5),a4	*the table to search
;	debug
	lea	field_3(a5),a3
 	qmove.l	toc_names_table(a5),tree_strings_ptr(a5)
 	move.l	tocnames_tree(a5),a2
	bsr.l	tn_tree_search
	tst.l	d0	
;	bsr.l	SEARCH_LABP2	*returns d0=pos or -1 if not found
;	tst.w	d0
	bmi.s	import_not_found
**if it is found we need do nothing
	lea	import_error(pc),a0
	bsr	pass1_error
on_pass_2:
	rts_	"import_defined_twice!"
import_not_found:
**Check number of imports
	qmove.l	ppc_number_of_imports(a5),d0
	cmp.l	total_imports_num(a5),d0
	ble.s	imports_maxxed
 	qmove.l	toc_names_table(a5),tree_strings_ptr(a5)
 	move.l	tocnames_tree(a5),a2
	bsr.l	tn_tree_insert


	movea.l toc_names_table(a5),a2
	add.l	toc_names_pos(a5),a2 	*lt pos is inc'd by 32 for every label
;	move.l	a4,a2	*save so we can bung in the type
;copy_lab_to_tab: 	 *now copy the label into the table
;	move.b	(a3)+,(a4)+
;	bne.s	copy_lab_to_tab
	clr.b	31(a2)		*zero is code import
	 
	addq.l	#1,total_imports_num(a5) 	*inc total number of lables
	movea.l	toc_offsets_table(a5),a4 	 *now save its value
	qmove.l	toc_names_pos(a5),d0 	*position/8=right place for long word 
 	lsr.l	#3,d0
	qmove.l	toc_offset_counter(a5),0(a4,d0.l) 	*store address
	addi.l	#32,toc_names_pos(a5) 	*ready for next label
	addq.l	#4,toc_offset_counter(a5)	*next offset			
	rts_	"import_not_found"
imports_maxxed:
	lea	max_imports(pc),a0
	bsr	printit
	qbset	#4,flags2(a5)		*stop!		
	rts_	"Imports_maxxed"
	
align_error_text:	dc.b	"Alignment is not valid; 2,4, 8 or 16 allowed.",13,0
;ppc_text:	dc.b	"Using Fantasm PowerPCª assembler.",13,0
;	align
import_error:	dc.b	"This label has already been imported.",13,0
max_imports:	dc.b	"***FATAL*** Exceeded maximum number of imports.",13,0
	dc.b	"Increase Anvil's memory allocation.",13,0

max_tocs:	dc.b	"***FATAL*** Exceeded maximum number of TOC code pointers.",13
	dc.b	"Increase Anvil's memory allocation.",13,0
;text_68k:	dc.b	"Using Fantasm 680x0 assembler.",13,0
;	align
ppc_only_text:	dc.b	"You can only use this directive when assembling for PowerPCª.",13,0
code_def_error:	dc.b	"This label has already been defined as a TOC code pointer.",13,0
toc_label_text:	dc.b	"The 'TOC_ROUTINE' directive needs a label at the start of the line.",13,0
	align

swg_ppc_only_advice:	dc.b	"***ADVICE*** SWG level directives only effective in PowerPCª.",13,0
	align

al_off_text:	dc.b	"***WARNING*** Auto alignment of data switched off.",13,0
al_on_text:	dc.b	"***ADVICE*** Auto alignment of data switched on.",13,0
	align
swg_68k:	dc.b	"***ADVICE*** Stall Warning Generator only operative when running on a PowerMac.",13,0
	align		
	
***************
	global	set_ppc,set_68k,align_it,import_lab,do_toc_routine
	global	swg_high_directive,swg_med_directive,swg_low_directive,swg_off_directive
	global	set_entry,default_align
	extern	printit_pass1,define_string_warning,get_numb,pass1_error
	extern	even,pass2_error,search_labp2,pass1_warning
	extern	even_ok,search_toc_code_labels,search_lab,printit,pass1_advice
	extern	tn_tree_search,tn_tree_insert