*MODULE:	ASSEMBLE
*DATE:      180594
*LAST MODIFIED:       Jan2000
*PROGRAMMER:    S.BALL
*VERSION:       4.00
*FANT REL VER:  4.00
*DESCRIPTION:   CALLS ALL RELEVANT ROUTINES
*VERSION INFO:
*3: 16/07/94	FANTASM RELEASE 1
*4: 22/07/94	RELEASE 1 WITH CRIPPLES IF UNREGISTERED=1
*5: 240794	RS DIRECTIVE + 8 BIT WELCOME ALERT
*	FASTER FILE LOADING AND MORE EFFICIENT MEM ALLOC
*6: 250794	JUMP TABLE FOR DIRECTIVES + MEMUSEAGE SHOWS RELOC
*FANT REL VER   1.01
*1 090894	FIXED .BIN EXTENSIONS
*FANT REL VER	2.00
*	MACROS
*modified 190195 for gloabl a5 offsets
*Modified 100895 for FSspecs
*
*modified 190696 for rs accumlator for bss section

**NEEDS A6 POINTING TO OUR VARIABLES


	align

	clr.b	flags5(a5)
	bsr	tx_opts	send menu selections to assembler
	tst.w	d0	error?
	bmi	fatal	yes

fant_entry:			*run fant from here as standalone
fant_entry_b:			*build enters here
	qbclr	#1,option_flags(a5)	*5.21 - opt d

	clr.w	fatal_flag(a5)
	clr.b	fant_return_code(a5)	return code to build
	clr.l	m_text_pos(a5)
**get memory for macro_counters
	qmove.l	#macro_ctr_size,d0
	OSNewHandleClear	d0,a0
;	dc.w	newhandleclear
	move.l	a0,d0
	beq	fatal_mem	no can do
	qmove.l	a0,macro_counters_h(a5)	so we can delete it
	OSHLock	a0
	

	move.l	macro_counters_h(a5),a0	so we can delete it
	move.l	(a0),a0
	qmove.l	a0,macro_counters(a5)

	qmove.l	#parameter_size*number_of_parameters*macro_depth_limit,d0
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_mem
	qmove.l	a0,macro_param_h(a5)
	OSHLock	a0
	move.l	macro_param_h(a5),a0
	move.l	(a0),a0
	qmove.l	a0,macro_param(a5)
	ifne	powerf	
**get memory for toc_names_table (imports)
	qmove.l	ppc_number_of_imports(a5),d0
;	ext.l	d0
	lsl.l	#5,d0		*times 32
	OSNewHandleClear	d0,a0
;	dc.w	newhandlesysclear
	move.l	a0,d0
	beq	fatal_sys	no can do
	move.l	a0,toc_names_table_h(a5)	so we can delete it
	OSHLock	a0
	
	move.l	toc_names_table_h(a5),a0
	move.l	(a0),a0
	move.l	a0,toc_names_table(a5)

**get memory for toc_offsets_table (imports)
	qmove.l	ppc_number_of_imports(a5),d0
;	ext.l	d0
	lsl.l	#2,d0		*times 4
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_sys	no can do
	move.l	a0,toc_offsets_table_h(a5)	so we can delete it
	OSHLock	a0
	
	move.l	toc_offsets_table_h(a5),a0
	move.l	(a0),a0
	move.l	a0,toc_offsets_table(a5)

**get memory for toc_code_names_table - 1000 allowed

	qcmove.w	ppc_number_of_code_defs(a5),d0
;	ext.l	d0
	lsl.l	#5,d0
	OSNewHandleClear	d0,a0 
	move.l	a0,d0
	beq	fatal_sys	no can do
	qmove.l	a0,toc_code_names_h(a5)	so we can delete it
	OSHLock	a0
	
	move.l	toc_code_names_h(a5),a0
	move.l	(a0),a0
	move.l	a0,toc_code_names(a5)

;	qmove.l	#0,d0
	qcmove.w	ppc_number_of_code_defs(a5),d0

	lsl.l	#2,d0		*times 4
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_sys	no can do
	qmove.l	a0,toc_code_offsets_h(a5)	so we can delete it
	OSHLock	a0
	
	move.l	toc_code_offsets_h(a5),a0	so we can delete it
	move.l	(a0),a0
	move.l	a0,toc_code_offsets(a5)


**get memory for long labels
;	qmove.l	#0,d0
	qcmove.w	ppc_number_of_data_defs(a5),d0
	lsl.l	#5,d0
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_sys	no can do
	qmove.l	a0,long_labels_h(a5)	so we can delete it
	OSHLock	a0
	move.l	long_labels_h(a5),a0
	move.l	(a0),a0
	move.l	a0,long_labels(a5)

**get memory for data_buffer
	move.l	ppc_data_buffer_size(a5),d0
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_sys	no can do
	qmove.l	a0,data_buffer_h(a5)	so we can delete it
	OSHLock	a0
	move.l	data_buffer_h(a5),a0
	move.l	(a0),a0
	qmove.l	a0,data_buffer(a5)
	clr.l	data_buffer_index(a5)	

**get memory for data_offsets_table
;	qmove.l	#0,d0
	qcmove.w	ppc_number_of_data_defs(a5),d0
	lsl.l	#4,d0
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_sys	no can do
	qmove.l	a0,data_item_offsets_h(a5)	so we can delete it
	OSHLock	a0
	move.l	data_item_offsets_h(a5),a0
	move.l	(a0),a0
	move.l	a0,data_item_offsets(a5)
	clr.l	data_item_count(a5)		*number of data items in data buffer

;	qmove.l	#0,d0
	qmove.l	ppc_number_of_imports(a5),d0
	muls.l	#36,d0		*times 36
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_sys	no can do
	qmove.l	a0,imports_output_table_h(a5)	so we can delete it
	OSHLock	a0
	
	move.l	imports_output_table_h(a5),a0
	move.l	(a0),a0
	qmove.l	a0,imports_output_table(a5)
	
;	qmove.l	#0,d0
	qcmove.w	ppc_number_of_code_defs(a5),d0
	muls.l	#40,d0		*times 40
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_sys	no can do
	qmove.l	a0,code_ptrs_output_table_h(a5)	so we can delete it
	OSHLock	a0
	
	move.l	code_ptrs_output_table_h(a5),a0	so we can delete it
	move.l	(a0),a0
	move.l	a0,code_ptrs_output_table(a5)
	
**Line numbers
;	 qcmove.w	 ppc_number_of_code_defs(a5),d0
;	 move.l	d0,max_linenumbers(a5)
;	 clr.l	 line_number_index(a5)
;	 muls.l	#8,d0	 	 *times 40
;	 OSNewHandleClear	 d0,a0
;	 move.l	a0,d0
;	 beq	 fatal_sys	 no can do
;	 qmove.l	a0,line_numbers_table_h(a5)	so we can delete it
;	 OSHLock	a0
;	 
;	 move.l	line_numbers_table_h(a5),a0	so we can delete it
;	 move.l	(a0),a0
;	 move.l	a0,line_numbers_table(a5)

**
;	qmove.l	#0,d0
	qcmove.w	ppc_number_of_data_defs(a5),d0
	muls.l	#40,d0		*times 40
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	fatal_sys	no can do
	qmove.l	a0,data_ptrs_output_table_h(a5)	so we can delete it
	OSHLock	a0
	
	move.l	data_ptrs_output_table_h(a5),a0
	move.l	(a0),a0
	qmove.l	a0,data_ptrs_output_table(a5)
not_linkable:	
**END of linkable stuff
	endif	;of powerfant
	
frame_setup:	qbset	#1,flags5(a5)	*count errors in printit
start:

**DO PASS 1
	OSTickCount	d0
	qmove.l	d0,start_count(a5)
	qmove.l	code_start(a5),code_buffer(a5)
	qmove.l	#0,d0
	qmove.l	d0,entry_point(a5)	*code entry point
	qmove.l	d0,rs_counter(a5)	clear rs counter
	qmove.l	d0,globoff_counter(a5)	a5 offsets
	qmove.l	d0,macro_pos(a5)
	qmove.l	d0,m_text_size(a5)
	qmove.l	d0,macro_num(a5)
	qmove.b	d0,flags(a5)
	qmove.b	d0,flags2(a5)
	qmove.w	d0,warning_count(a5)
	qmove.w	d0,log_length(a5)
	qmove.w	d0,optimisation_count(a5)
	qmove.w	d0,optimisation_saving(a5)
	qmove.l	d0,extern_buff_tab_pos(a5)
	qmove.l	d0,extern_count(a5)
	qmove.l	d0,global_count(a5)
	qmove.w	d0,requ_names_count(a5)
	
	qmove.l	d0,toc_code_count(a5)
	qmove.l	d0,toc_code_names_pos(a5)
	qmove.b	d0,if_counter(a5)		*counts on/offs in if_depth_array
	qmove.w	#20,events_count(a5)	short delay between events
	btst	#0,flags7(a5)
	beq.s	clear_ppc
	qbset	#0,ppc_flags1(a5)	*set processor flag from prefs
	bra.s	done_ppc
clear_ppc:
	qbclr	#0,ppc_flags1(a5)
done_ppc:
	qmove.l	d0,total_imports_used(a5)	
	qmove.l	d0,total_data_ptrs_used(a5)
	qmove.l	d0,total_code_ptrs_used(a5)
	qbclr	#3,ppc_flags1(a5)	we are on pass 1 now!
	qmove.w	d0,incs_counter(a5)
	qbclr	#0,ppc_flags3(a5)	data_sect
	qmove.b	d0,if_depth(a5)
	qbclr	#1,flags8(a5)	*clear ppc immediate data flag
	qbclr	#2,flags8(a5)	*tell eval to report undefined labs on pass 1		
	qbset	#5,flags4(a5)	*anvil is always on
	qmove.l	#1,pass_id(a5)
	qmove.b	d0,if_scan(a5)	* added by rp 14/9/97 - problem with subsequent assembly of if's
				* after "in part of else" condition at end of previous assembly.

	qmove.b	d0,half_size(a5)	*lxt mod
	bsr.l	pass1	do pass1 with o.p in code buffer
	bmi	fatal	if minus flag then fatal error

	tst.b	abort(a5)
	bne	user_error

	qmove.l	pc(a5),save_pc_pass1(a5)	*save for error checking

**accumulate largest rs block
	bsr	accumulate_rs
**better do an a_idle
	bsr.l	do_idle	
**check at end of pass 1 we're not in a block or macro
	btst	#1,flags2(a5)	assemble from macro?
	bne	in_macro_err	fatal
	tst.b	if_depth(a5)	in a conditional block?
	bne	in_cond_err	fatal
	tst.b	if_scan(a5)
	bne	in_cond_err1
	btst	#2,flags2(a5)	*we're in a macro def at end of pass 1
	bne	in_macro_err
**do pass 2
	clr.l	d0
	qmove.b	d0,if_depth(a5)
	qbclr	#0,ppc_flags3(a5)	*data sect
	qmove.w	d0,optimisation_count(a5)
	qmove.w	d0,optimisation_saving(a5)
	qmove.w	d0,extern_buff_tab_pos(a5)	link file externals header data
**clear out macro_counters
	move.l	macro_counters(a5),a6
	qmove.l	#3998,d0	15992 bytes
	qmove.l	#0,d1
cmc:	qmove.l	d1,(a6)+
	qdbra	d0,cmc
	
	qbclr	#0,flags5(a5)
skip_p2text:	qmove.l	code_start(a5),code_buffer(a5)
	clr.l	rs_counter(a5)
	clr.l	globoff_counter(a5)
	clr.b	flags2(a5)
	qbset	#0,flags5(a5)
	bsr.l	reset_sets	in general.s (reset all sets)
;	clr.l	data_buffer_index(a5)	*haha!
;	move.l	data_buffer_h(a5),a0
;	move.l	(a0),data_buffer(a5)	*reset data buffer
	btst	#0,flags7(a5)	*set processor flag from prefs
	beq.s	clear_ppc1
	qbset	#0,ppc_flags1(a5)
	bra.s	done_ppc1
clear_ppc1:
	qbclr	#0,ppc_flags1(a5)
done_ppc1:
;	clr.l	toc_code_count(a5)
	qmove.l	#0,d0
	qmove.l	d0,toc_code_names_pos(a5)
	qmove.l	d0,total_imports_used(a5)	*for export of imports to link file
	qmove.l	d0,total_data_ptrs_used(a5)
	qmove.l	d0,total_code_ptrs_used(a5)
	qmove.b	d0,if_counter(a5)		*see pass 1
	qbclr	#1,flags8(a5)	*clear ppc immediate data flag
	qbclr	#2,flags8(a5)	*tell eval to report undefined labs on pass 1
	qmove.l	#2,pass_id(a5)	*this is pass 2
	qmove.b	d0,half_size(a5)	*lxt mod

	bsr.l	pass2	do pass 2

	bmi	fatal_p2	user stopped pass 2
	bsr	accumulate_rs
	bsr	accumulate_globoff
	qmove.l	rs_accumulator(a5),rs_counter(a5)	*v405	
	btst	#2,flags2(a5)	*we're in a macro def, so skip till endm
	bne	in_macro_def_err

	qbclr	#0,flags5(a5)	enable printing
;	move.w	#$2000,sr
	move.l	code_start(a5),a3
;	tst.w	error_count(a5)
;	btst	#7,flags(a5)	error?
	tst.b	abort(a5)
	bne	user_error
	tst.b	global_err(a5)
	bne	errors	yes
	qmove.l	save_pc_pass1(a5),d0
	cmp.l	pc(a5),d0
	bne	major_fu	*pass 1 size doesnt match with pass 2 size!

**set up output directory
	btst	#6,flags5(a5)	linkable file o/p?
	beq.s	not_link		no
**ppc or 68k?
	btst	#0,flags7(a5)
	bne.s	wl_ppc
	bsr.l	write_link	v3.xx
	bra.s	write_done
wl_ppc:
	bsr.l	write_link_ppc
	bra.s	write_done

not_link:
write_done:
	btst	#0,flags7(a5)
	beq.s	not_ppc10
	btst	#4,option_flags(a5)	run in mac ram?
	bne	ppc_in_ram		*no
not_ppc10:

	btst	#5,flags3(a5)
	beq.s	timer_ok
	lea	timer_not_on(pc),a0
	bsr	printit
	bra.s	show_longs
	
timer_ok:	btst	#0,build_options(a5)
	bne.s	show_longs
	lea	time_text(pc),a0
	bsr	printit
	OSTickCount	d0	*finish time
	sub.l	start_count(a5),d0	get total time
	divs	#60,d0
	qmove.l	d0,-(sp)	save remainder
	andi.l	#$ffff,d0
	bsr	printnum	print secs
	lea	point_text(pc),a0
	bsr	printit
	qmove.l	(sp)+,d0
	swap	d0	get 100ths
	andi.l	#$ffff,d0
	bsr	printnum
	lea	secs_text(pc),a0
	bsr	printit
**show how many longs to reloc
show_longs:	move.l	reloc_tab_pos(a5),d0
	lsr.l	#2,d0
	bne.s	show_reloc
**pos inde code
	btst	#0,build_options(a5)	quiet mode?
	bne.s	reloc_mess_done
	lea	no_reloc_text(pc),a0
	bsr	printit
	lea	pos_inde_text(pc),a0
	bsr	printit
	bra.s	reloc_mess_done	
show_reloc:	cmpi.w	#1,d0
	bne.s	show_lots_reloc
	lea	one_long_text(pc),a0
	bsr	printit
	bra.s	reloc_mess_done
show_lots_reloc:
	bsr	printnum
	lea	relocate_text(pc),a0
	bsr	printit	show number of relocations
reloc_mess_done:

	tst.w	test_flag(a5)
	bne	test_ok
	lea	no_error_text(pc),a0
	btst	#0,build_options(a5)
	bne.s	build_quiet_3	quiet mode
	bsr	printit	no errors
	bsr	print_warnings	show how many warnings there were
	bsr	print_optimisations
build_quiet_3:
on_disk:

ppc_in_ram:
wait_f_key:

	tst.b	global_err(a5)
	bne.s	bad_assembly
	lea	good_assm_t(pc),a0
	bsr	printit
	bra.s	all_done
bad_assembly:	lea	bad_assm_t(pc),a0
	bsr	printit
	qmove.b	#-1,fant_return_code(a5)
all_done:	
f_end:
**hand mem back for macro_counters
	move.l	macro_counters_h(a5),a0
	move.l	a0,d0
	beq.s	skip_1
	OSDisposeHandle	d0

**Dispose of toc stuff		
skip_1:
	ifne	powerf
	move.l	toc_code_names_h(a5),a0	*toc code entries
	move.l	a0,d0
	beq.s	skip_2
	OSDisposeHandle	d0	bye...
skip_2:	move.l	toc_code_offsets_h(a5),a0	*toc code entries
	move.l	a0,d0
	beq.s	skip_3
	OSDisposeHandle	d0	bye...
skip_3:
	move.l	toc_names_table_h(a5),a0
	move.l	a0,d0
	beq.s	skip_4
	OSDisposeHandle	d0	bye...
skip_4
	move.l	long_labels_h(a5),a0
	move.l	a0,d0
	beq.s	skip_5
	OSDisposeHandle	d0	bye...
skip_5:
	move.l	toc_offsets_table_h(a5),a0
	move.l	a0,d0
	beq.s	skip_6
	OSDisposeHandle	d0	bye...
skip_6:
	move.l	data_buffer_h(a5),a0	*data buffer
	move.l	a0,d0
	beq.s	skip_7
	OSDisposeHandle	d0
skip_7:
	move.l	data_item_offsets_h(a5),a0	*data items offsets
	move.l	a0,d0
	beq.s	skip_8
	OSDisposeHandle	d0
skip_8:

	move.l	imports_output_table_h(a5),a0	*data items offsets
	move.l	a0,d0
	beq.s	skip_9
	OSDisposeHandle	d0
skip_9:
	move.l	data_ptrs_output_table_h(a5),a0	*data items offsets
	move.l	a0,d0
	beq.s	skip_10
	OSDisposeHandle	d0
skip_10:
	move.l	code_ptrs_output_table_h(a5),a0	*data items offsets
	move.l	a0,d0
	beq.s	skip_11
	OSDisposeHandle	d0
skip_11:
	endif	;of powerf

	move.l	macro_param_h(a5),a0	*data items offsets
	move.l	a0,d0
	beq.s	skip_12
	OSDisposeHandle	d0
skip_12:
	rts_	"assemble"

	
test_ok:	bsr	print_warnings
	lea	test_passed(pc),a0
	bsr	printit
	bra	on_disk
major_fu:	qmove.b	#-1,fant_return_code(a5)	tell build fant failed
	lea	p1p2_text(pc),a0
	bsr	printit
	addq.w	#1,error_count(a5)
	bra	bad_assembly
user_error:
	qmove.b	#-1,fant_return_code(a5)
	qmove.b	#-1,global_err(a5)
	lea	user_abort(pc),a0
	bsr	printit
	bra	wait_f_key

errors:	move.b	#-1,fant_return_code(a5)
	cmpi.w	#1,error_count(a5)
	beq.s	single_error
	qmove.w	error_count(a5),d0	how many errors
	clr.w	error_count(a5)		clear it so print will work
	bsr	printnum		print number of ewrrors
	lea	numb_errors_t(pc),a0
	
e_report:	bsr	printit
	bsr	print_warnings

	bsr	write_log
	bra	wait_f_key	byeeee

single_error:	lea	one_error_t(pc),a0
	bra.s	e_report

in_macro_err:	lea	in_macro_text(pc),a0
	bsr	printit

	bsr	write_log
	bra	bad_assembly

in_macro_def_err:	lea	in_macro_def_text(pc),a0
	bsr	printit

	bsr	write_log
	bra	bad_assembly

in_cond_err:
	lea	in_cond_text(pc),a0
	bsr	printit
	tst.b	if_depth(a5)		*too many ifs or ends?
	bmi.s	too_many_ends
	lea	ifs_text(pc),a0
	bsr	printit
	bra.s	done_ifs
too_many_ends:
	lea	ends_text(pc),a0
	bsr	printit
done_ifs:

	bsr	write_log
	bra	bad_assembly
in_cond_err1:
	lea	in_else_text(pc),a0
	bsr	printit

	bsr	write_log
	bra	bad_assembly

fatal_mem:	qbclr	#0,flags5(a5)
;	MOVE.W	#$2000,SR
	lea	mem_err_text(pc),a0
	bsr.l	printit
fatal:	move.w	#1,fatal_flag(a5)
	move.w	#1,d0
	OSSysBeep	d0
	move.w	#1,d0
	OSSysBeep	d0
	move.w	#1,d0
	OSSysBeep	d0
	bra	f_end
fatal_sys:
	qmove.w	#1,fatal_flag(a5)
	qbclr	#0,flags5(a5)
;	MOVE.W	#$2000,SR

	lea	mem_err_sys_text(pc),a0
	bsr.l	printit

	qcmove.w	#1,d0
	OSSysBeep	d0
	qcmove.w	#1,d0
	OSSysBeep	d0
	qcmove.w	#1,d0
	OSSysBeep	d0
	bra	f_end
	
fatal_p2:	lea	pass2_stop(pc),a0
	bsr	printit
	bra.s	fatal
	

************************************************************************************
print_warnings:
	move.w	warning_count(a5),d0
	beq.s	no_w
	cmpi.w	#1,d0
	beq.s	one_w
	bsr	printnum
	lea	many_warnings(pc),a0
	bsr	printit
	bra.s	end_warnings
one_w:	lea	one_warning(pc),a0
	bsr	printit
	bra.s	end_warnings
no_w:	lea	nil_warnings(pc),a0
	bsr	printit
end_warnings:	rts

print_optimisations:
	move.w	optimisation_count(a5),d0
	beq.s	no_optim
	cmpi.w	#1,d0
	beq.s	one_optim
	bsr	printnum
	lea	many_optims_text(pc),a0
	bsr	printit
	bra.s	show_saving
one_optim:	lea	one_optim_text(pc),a0
	bsr	printit
	bra.s	show_saving
no_optim:	lea	nil_optims_text(pc),a0
	bsr	printit
	bra.s	end_po
show_saving:	move.w	optimisation_saving(a5),d0
	bsr	printnum
	lea	n_bytes_text(pc),a0
	bsr	printit
end_po:	rts


print_log_mess:	tst.w	error_count(a5)
	bne.s	show_log_text
	tst.w	warning_count(a5)
	bne.s	show_log_text
	rts
show_log_text:	btst	#0,flags3(a5)	dump log to disk?
	beq.s	no_log_text
	lea	log_text(pc),a0
	bsr	printit
no_log_text:	rts
		
**PROJ FILENAME IS ACTUALLY THE MAIN SOURCE CODE FILE NAME
init: 
	clr.l	rs_accumulator(a5)
	clr.l	globoff_accumulator(a5)
	
	clr.w	error_count(a5)	clear error counter
	qmove.w	#10,curs_x(a5)	cursor position
	qmove.w	#10,curs_y(a5)
	clr.l	org_address(a5)	pc starts at 0
;	bclr	#7,flags(a5)	clear error	flag
 	clr.b	global_err(a5)
	clr.l	rs_counter(a5)	clear the internal rs counter for rs.s directive
	rts_	"init"
**write log writes out the error buffer to	filename.log
write_log:
wlog_end:	rts
;erase_log:
;	lea	assembler_output_fsspec(a5),a0
;	lea	log_name(pc),a1
;	bsr	make_temp_fsspec
;	lea	temp_fsspec(a5),a0
;	bsr	erase_f
;	rts_	"write_lo"	
	
***************************************************************************************	
**PRINTIT PRINTS A STRING IN A0 USING THE TEXTEDITOR TO THE ASSEMBLER WINDOW	
**String in a0
printit_to_line:
	lea	the_line(a5),a1
	add.l	pline_index(a5),a1
	tst.b	(a0)
	beq.s	insert_a_space
ptl_loop:
	move.b	(a0)+,d0
	beq.s	insert_a_space
	addq.l	#1,pline_index(a5)
	move.b	d0,(a1)+
	bne.s	ptl_loop
	rts_	"Printit_to_line"
insert_a_space:
	qmove.b	#32,(a1)
	addq.l	#1,pline_index(a5)
	rts
	
print_space_to_line:
	lea	the_line(a5),a1
	add.l	pline_index(a5),a1
	inc.l	pline_index(a5)
	qmove.b	#32,(a1)
	rts_	"print_space_to_line"
print_cr_to_line:
	lea	the_line(a5),a1
	add.l	pline_index(a5),a1
	inc.l	pline_index(a5)
	qmove.b	#13,(a1)
	rts_	"print_space_to_line"
print_term_to_line:
	lea	the_line(a5),a1
	add.l	pline_index(a5),a1
	inc.l	pline_index(a5)
	qmove.b	#0,(a1)
	rts_	"print_term_to_line"
		
send_line:
	movem.l	d6/a0/a1/a2/a3/a4,-(sp)
	lea	the_line(a5),a0
	bsr.l	send_to_log
	movem.l	(sp)+,d6/a0/a1/a2/a3/a4
	clr.l	pline_index(a5)
	rts_	"Send_line_to_anv"
		

printit_pass1:
	btst	#1,flags(a5)
	beq.s	printit
	rts_	"Printit_pass1"		*if pass 2

**Modified for Anvil
printit:
	movem.l	d6/a0/a1/a2/a3/a4,-(sp)
	tst.b	(a0)
	beq.s	pi_end
	bsr.l	send_to_log
pi_end:	movem.l	(sp)+,d6/a0/a1/a2/a3/a4
	rts_	"printit"

**PRINTCR DOES A CR
printcr:	qmove.l	a0,-(sp)
	lea	a_cr_text(pc),a0
	bsr	printit
	qmove.l	(sp)+,a0
	rts_	"printcr "
**prints to d0
printnum_mem_signed:
	tst.l	d0
	bge.s	pnmw_plm
	qmove.b	#"-",(a0)+
	neg.l	d0	make plus
pnmw_plm:
	qmove.l	d0,d6
	bsr.l	printnum_mem
	rts_	"f_printnum_mem_signed"

**printnum_word prints do as a signed word
printnum_signed:
	lea	char_buff(pc),a0
	tst.l	d0
	bge.s	pnmw_pl
	qmove.l	d0,-(sp)
	qmove.b	#"-",0(a0)
	bsr	printit
	qmove.l	(sp)+,d0
	neg.l	d0	make plus
pnmw_pl:	bra.s	printnum	just in case i ever insert any code here!
	
**printnum prints a 32 bit number held in d0
**limited to 1e7
**uses commas for seperators.
printnum:
**find size of number to quash leading zeros

	lea	new_char_buff(pc),a0	where chars are	stored for printing
	clr.l	(a0)
	clr.l	4(a0)
	clr.l	8(a0)
	clr.l	12(a0)	*clear old string
	tst.l	d0
	bge.s	plus
	qmove.b	#"-",(a0)+
	neg.l	d0
plus:
	cmpi.l	#$ffff,d0
	bgt.s	print_long	long word print
	qmoveq	#0,d6
	qmove.w	d0,d6
	cmpi.l	#10,d6
	blt.s	do_units
	cmpi.l	#100,d6
	blt.s	do_tens
	cmpi.l	#1000,d6
	blt.s	do_huns
	cmpi.l	#10000,d6
	blt.s	do_thou
**now divide by relevant	units
long_ent:	divs	#10000,d6	get tens of thoudsands
	bsr.s	convert_n	print number of tens of thousands
do_thou:	divs	#1000,d6	get thousands
	bsr.s	convert_n	etc
	qmove.b	#0x2c,(a0)+
do_huns:	divs	#100,d6
	bsr.s	convert_n
do_tens:	divs	#10,d6
	bsr.s	convert_n
do_units:	bsr.s	convert_n
	clr.b	(a0)
	lea	new_char_buff(pc),a0
	bsr	printit
	rts
convert_n:	addi.b	#48,d6	make character	(ascii)
	qmove.b	d6,(a0)+
	clr.w	d6
	swap	d6
;	swap	d6
;	andi.l	#$ffff,d6
	rts_	"printnum"
**print long print do.l
**limited to 1e7 (10meg)
print_long:	cmpi.l	#9999999,d0
	bgt.s	numb_error
	qmove.l	d0,d1
	cmpi.l	#99999,d0
	blt.s	do_ten_thou
	cmpi.l	#999999,d0
	blt.s	do_hund_thou
	move.l	#1000000,d0	get millions
	bsr.l	long_div	divide d1.l by d0.l with remainder in d0
	addi.b	#"0",d1
	qmove.b	d1,(a0)+
	qmove.l	d0,d6
	qmove.b	#0x2c,(a0)+
	bsr	printit
	qmove.l	d6,d1
do_hund_thou:	qmove.l	#100000,d0	get 100 thousands
	bsr.l	long_div
	addi.b	#"0",d1
	qmove.b	d1,(a0)+
	qmove.l	d0,d6
	cmpi.l	#$ffff,d6	<65536?
	blt	long_ent	yes, print word routine
	qmove.l	d6,d1	no,get 10thousands
do_ten_thou:	qmove.l	#10000,d0
	bsr.l	long_div
	addi.b	#"0",d1
	qmove.b	d1,(a0)+
	qmove.l	d0,d6
	andi.l	#$ffff,d6
	bra	do_thou
numb_error:
	lea	numb_too_big(pc),a0
	bsr	printit
	rts_	"print_nl"
	align
**print line prints a line of source code by printing file name and field 1-3	
print_line:
not_lide:
	clr.l	pline_index(a5)
	bsr	print_name	print file name

	lea	field_1(a5),a0	print fields
	bsr	printit_to_line
	bsr	print_space_to_line
	btst	#1,ppc_flags1(a5)
	bne.s	use_error_op
	lea	field_2(a5),a0
	bra.s	got_field
use_error_op:
	lea	error_op_field(a5),a0	*because field has been stripped during parse...
got_field:

	bsr	printit_to_line
	bsr	print_space_to_line
	lea	field_3(a5),a0
	bsr	printit_to_line
	lea	asterix(pc),a0
	bsr	printit_to_line		*so errors stand out
	bsr	print_cr_to_line
	bsr	print_term_to_line

	bsr	send_line
	rts_	"print_line"
	align
**print line prints a line of source code by printing file name and field 1-3	
print_warning2:
	clr.l	pline_index(a5)
	bsr	print_name	print file name to log and error! needs string in error_string_save(a5)
	clr.l	pline_index(a5)
	lea	field_1(a5),a0	print fields
	bsr	printit_to_line
	bsr	print_space_to_line
	btst	#1,ppc_flags1(a5)
	bne.s	use_error_op1
	lea	field_2(a5),a0
	bra.s	got_f2
use_error_op1:
	lea	error_op_field(a5),a0	*because field has been stripped during parse...
got_f2:	
	bsr	printit_to_line
	bsr	print_space_to_line
	lea	field_3(a5),a0
	bsr	printit_to_line
	bsr	print_cr_to_line
	bsr	print_term_to_line
	bsr	send_line
	rts_	"print_warning2"
	align
		
**print optimisation prints a line of source code by printing file name and field 1-3	
**then does cr and prints the string in a0
print_optimisation:
	btst	#7,flags3(a5)	show optimisations?
	beq.s	skip_po	no	
	btst	#1,flags(a5)	pass 1?
	bne.s	skip_po	only on pass 1
	inc.w	warning_count(a5)	inc advisements
	qmove.l	a0,-(sp)	save string
	bsr	print_warning2	see above
	lea	dash(pc),a0
	bsr	printit
	qmove.l	(sp)+,a0
	bsr	printit	print opt string
	bsr	printcr
	bsr	printcr
skip_po:	rts_	"print_op"
	align

print_space:	qmove.l	a0,-(sp)
	lea	space_text(pc),a0
	bsr	printit
	qmove.l	(sp)+,a0
	rts_	"print_sp"
**[rint name saves regs and calls find_error to	find the file name of the offending line
**held	in	source	save
print_name:	movem.l	a0/a1/a2/a3/a4,-(sp)
	move.l	source_save(a5),a0
	bsr.l	find_error
	movem.l	(sp)+,a0/a1/a2/a3/a4
	rts_		"print_na"
****
*INIT MEM V3.00
*gets free mem from system, then calculates actual sizes from percentages
*defined in equates below
source_size2:	equ	15	*these equates define percentage	18	
reloc_size2:	equ	1	*of total free mem allocated to each	19
file_size2:	equ	6	*(18)	*buffer*3		37
labels_size2:	equ	7					43
lab_vals_size2:	equ	2					45
lab_tree_size:	equ	4		49
equ_tree_size:	equ	4	53
tn_tree_size:	equ	4	57
equ_size2:	equ	9					67
eq_val_size2:	equ	8					75
code_size2:	equ	9					84
error_buff2:	equ	2					86
macro_text:	equ	4	8% for macros			89
mlabels_size2:	equ	2	1 % for macro names		91
m_vals2:	equ	2	1% for macro offsets in macro_text	93
st_reloc2:	equ	1					94
global_size2:	equ	2	global labels 2 		96
extern_size2:	equ	2	external labels size 2		98
extern_buff2:	equ	3	total 93% 3			101
app_mem:	equ	52	application and link memory 20

init_mem1:

	qmove.l	freemem(a5),d6	from shell
**NMM
**Calc space required for stuff that was on system heap, basically, a third
	qmove.l	d6,d4
;	divu.l	#3,d4	*size of stuff that would go on sys heap	
**calc 20% of free mem
	qmove.l	d6,d5
	qmove.l	#100,d0
	qmove.l	d5,d1
	bsr.l	long_div
	muls.l	#app_mem,d1	calc memory required
	cmpi.l	#320000,d1
	bgt.s	free_ok
	qmove.l	#320000,d1
free_ok:
	
	sub.l	d1,d6	*memory for heap
;	sub.l	d4,d6	*minus memory for stuff on system heap
;	sub.l	#280991,d6	*some spare space for host
	qmove.l	d6,d0
	sub.l	#parameter_size*number_of_parameters*macro_depth_limit+20,d0
	OSNewPtr	d0,a0
;	dc.w	new_ptr	get all free mem - heap
	qmove.l	a0,d1
	move.l	d1,newptr_result(a5)
	rts
	
**we have a big block of memory in newptr_result
init_mem:
	move.l	newptr_result(a5),d1	see if we have the mem
;	tst.l	d1
	beq	mem_error		no we dont
	qmove.l	freemem(a5),d6	from shell
	qmove.l	d6,d5
	divs.l	#100,d5
	muls.l	#app_mem,d5	calc memory required
	sub.l	d5,d6		d6=size of free mem
	sub.l	#parameter_size*number_of_parameters*macro_depth_limit+20,d6
make_start_quad:
	qmove.l	d1,d4
	andi.w	#%11,d4
	beq.s	is_quad1
	addq.l	#1,d1
	bra.s	make_start_quad
is_quad1:

	qmove.l	d1,base_buff(a5)	start of free mem
	qmove.l	d1,pointer_pos(a5)	pointer to start of free mem
	add.l	d1,d6			d6=end of free mem
	qmove.l	d6,end_buff(a5)		end of free mem
	qmove.l	#source_size2,d1
	bsr	calc_mem		returns d0=actual size in bytes

	qmove.l	d0,d5		save size for clearing purposes
	qmove.l	d0,max_s_size(a5)	save size for later printing
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,source_buff(a5)
;	clr.l	d0
	qmove.l	d1,a0
	lsr.l	#2,d5		divide by 4 for	long clear
	if	68K
	qmoveq	#$00,d0
clear_source:
	qmove.l	d0,(a0)+
	dec.l	d5
	bne.s	clear_source
	else
	macs_last
	li	r3,0
	mtctr	r15
clear_source:
	stw	r3,(r20)
	addi	r20,r20,4
	bdnz	clear_source
	macs_first
	endif
**now do reloc table
	qmove.l	#reloc_size2,d1
	bsr	calc_mem
	qmove.l	d0,max_reloc_size(a5)	save max reloc size
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,reloc_tab(a5)
**now do 3 file	buffers
	qmove.l	#file_size2,d1
	bsr	calc_mem	
	qmove.l	d0,d5	save for other 2 file buffs
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d5,max_f_size(a5)	save max size for later
	qmove.l	d1,file_buff1(a5)
	qmove.l	d5,d0
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,file_buff2(a5)
	qmove.l	d5,d0
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,file_buff3(a5)
**get mem for lable names
	qmove.l	#labels_size2,d1
	bsr	calc_mem
	qmove.l	d0,labels_sz(a5)	max size of labs
	qmove.l	d0,d5
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	add.l	#32,d1	allow for overshoot area at start
	qmove.l	d1,labels(a5)
	sub.l	#32,d1	clear overshoot area and table
	move.l	d1,a0
	subq.l	#4,d5	correct table size
	qmove.l	d5,d1
;	if 68K

	lsr.l	#2,d1	divide by 4
	qmoveq	#$00,d0
clear_labs:	qmove.l	d0,(a0)+
	dec.l	d1
	bne.s	clear_labs
;	else
;	import	BlockZero	
;	macs_last
;	mr	r3,r20
;	Xcall	BlockZero
;	endif
;	mtctr	r4
;clear_labs:
;	stw	r3,(r20)
;	addi	r20,r20,4
;	bdnz	clear_labs
;	macs_first
;	endif
**now do labels	values buffer
	qmove.l	#lab_vals_size2,d1
	bsr	calc_mem
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,lab_val(a5)
**4.6
**labels_tree - each notde is 12 bytes
	qmove.l	#lab_tree_size,d1
	bsr	calc_mem
	qmove.l	d0,d4
	divu.l	#12,d4
	qmove.l	d4,max_number_of_labels(a5)
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,labels_tree(a5)
	qmove.l	d1,a0	clear macro labels
	qmove.l	d5,d1

	lsr.l	#2,d1	divide by 4
	qmoveq	#-1,d0
	if	68K
clear_labtree:	qmove.l	d0,(a0)+
	dec.l	d1
	bne.s	clear_labtree
	else
	macs_last
	mtctr	r4
clear_labtree:
	stw	r3,(r20)
	addi	r20,r20,4
	bdnz	clear_labtree
	macs_first
	endif

**equates_tree - each notde is 12 bytes
	qmove.l	#equ_tree_size,d1
	bsr	calc_mem
	qmove.l	d0,d4
	divu.l	#12,d4
	qmove.l	d4,max_number_of_equates(a5)
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,equates_tree(a5)
	qmove.l	d1,a0	clear macro labels
	qmove.l	d5,d1
	lsr.l	#2,d1	divide by 4
	qmoveq	#-1,d0

	if	68K
clear_equtree:	qmove.l	d0,(a0)+
	dec.l	d1
	bne.s	clear_equtree
	else
	macs_last
	mtctr	r4
clear_equtree:
	stw	r3,(r20)
	addi	r20,r20,4
	bdnz	clear_equtree
	macs_first
	endif
	
**toc_names_tree - each notde is 12 bytes
	qmove.l	#tn_tree_size,d1
	bsr	calc_mem
	qmove.l	d0,d4
	divu.l	#12,d4
	qmove.l	d4,max_number_of_tocnames(a5)
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,tocnames_tree(a5)
	qmove.l	d1,a0	clear macro labels
	qmove.l	d5,d1
	lsr.l	#2,d1	divide by 4
	qmoveq	#-1,d0
clear_tntree:	qmove.l	d0,(a0)+
	dec.l	d1
	bne.s	clear_tntree

**equates names
	qmove.l	#equ_size2,d1
	bsr	calc_mem
	qmove.l	d0,d5
	qmove.l	d0,equ_sz(a5)
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
**ok
	qmove.l	d1,equates(a5)
	qmove.l	d1,a0
	qmove.l	d5,d1
;	if	68K
	lsr.l	#2,d1
	qmoveq	#$00,d0
clear_equs:	qmove.l	d0,(a0)+
	dec.l	d1
	bne.s	clear_equs
;	else
;	macs_last
;	mr	r3,r20
;	Xcall	BlockZero
;	endif
**equate values
	qmove.l	#eq_val_size2,d1
	bsr	calc_mem
	qmove.l	d0,max_eq_val_size(a5)
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,eq_val(a5)
**code
	qmove.l	#code_size2,d1
	bsr	calc_mem
	qmove.l	d0,code_sz(a5)	save size of code buffer
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,code_buffer(a5)
	add.l	#$0000001c,d1
	move.l	d1,code_start(a5)
	qmove.w	#$0000,file_pos1(a5)
	qmove.w	#$0000,file_pos2(a5)
	qmove.w	#$0000,file_pos3(a5)
**error buffer
	qmove.l	#error_buff2,d1
	bsr	calc_mem
	cmpi.l	#32000,d0	biggest we allow
	blt.s	errsize_ok
**ok
	qmove.l	#32000,d0
errsize_ok:	move.w	d0,error_size(a5)	size of buffer
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,error_buffer(a5)
	clr.w	text_count(a5)
**clear error buffer
;	clr.l	d1
	qcmove.w	error_size(a5),d1
	lsr.l	#2,d1
	qmove.l	error_buffer(a5),a0
ceb:	clr.l	(a0)+
	dec.l	d1
	bne.s	ceb
	
**macro text (v1.02->)
	qmove.l	#macro_text,d1
	bsr	calc_mem
	qmove.l	d0,mac_buff_size(a5)
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,macro_address(a5)	*address of text buffer

**macro labels
	qmove.l	#mlabels_size2,d1
	bsr	calc_mem
	qmove.l	d0,m_labels_size(a5)
	qmove.l	d0,d5

	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,macro_labels(a5)
	qmove.l	d1,a0	clear macro labels
	qmove.l	d5,d1
;	if	68K
	lsr.l	#2,d1	divide by 4
	qmoveq	#$00,d0
clear_mlabs:	qmove.l	d0,(a0)+
	dec.l	d1
	bne.s	clear_mlabs
;	else
;	macs_last
;	mr	r3,r20
;	Xcall	BlockZero
;	endif

**ok
**macro offsets from text base
	qmove.l	#m_vals2,d1
	bsr	calc_mem
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,m_labels_index(a5)
	clr.l	macro_pos(a5)
	clr.l	m_text_size(a5)
	clr.l	macro_num(a5)
	clr.b	flags2(a5)
**
	move.l	#st_reloc2,d1	get reloc table	memory
	bsr	calc_mem
	qmove.l	d0,d5
	bsr	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,st_reloc(a5)	address of where reloc table will be built
	qmove.l	d5,d0
	lsr.l	#2,d0
	qmove.l	d1,a0
;	if	68K
	qmoveq	#$00,d1

clear_macs:	qmove.l	d1,(a0)+
	dec.l	d0
	bne.s	clear_macs
;	else
;	qmove.l	d0,d1
;	macs_last
;	mr	r3,r20
;	Xcall	BlockZero
;	endif

**globals	
	qmove.l	#global_size2,d1
	bsr	calc_mem		returns d0=actual size in bytes
	qmove.l	d0,d5		save size for clearing purposes
	qmove.l	d0,max_global_size(a5)	save size for later printing
	bsr.s	my_alloc
	tst.l	d1
	beq	mem_error
	qmove.l	d1,global_buff(a5)
;	clr.l	d0
	qmove.l	d1,a0
	lsr.l	#2,d5		divide by 4 for	long clear
;	if	68K
	qmoveq	#$00,d0
clear_globals:	
	qmove.l	d0,(a0)+
	dec.l	d5
	bne.s	clear_globals
;	else
;	qmove.l	d5,d1
;	macs_last
;	mr	r3,r20
;	Xcall	BlockZero
;	endif

**externals
**ok
	qmove.l	#extern_size2,d1
	bsr	calc_mem		returns d0=actual size in bytes
	qmove.l	d0,d5		save size for clearing purposes
	qmove.l	d0,max_extern_size(a5)	save size for later printing
	bsr.s	my_alloc
	tst.l	d1
	beq.s	mem_error
	qmove.l	d1,extern_buff(a5)
;	clr.l	d0
	qmove.l	d1,a0
	lsr.l	#2,d5		divide by 4 for	long clear
	qmoveq	#$00,d0
clear_externs:	
	qmove.l	d0,(a0)+
	dec.l	d5
	bne.s	clear_externs

**external buff
	qmove.l	#extern_buff2,d1
	bsr.s	calc_mem		returns d0=actual size in bytes
	qmove.l	d0,d5		save size for clearing purposes
	qmove.l	d0,max_extern_buff_size(a5)	save size for later printing
	bsr.s	my_alloc
	tst.l	d1
	beq.s	mem_error
	qmove.l	d1,extern_buff_tab(a5)

;	clr.l	d0
	qmove.l	d1,a0
;	if	68K
	lsr.l	#2,d5		divide by 4 for	long clear
	qmoveq	#$00,d0
clear_externb:	
	qmove.l	d0,(a0)+
	dec.l	d5
	bne.s	clear_externb
;	else
;	qmove.l	d5,d1
;
;	macs_last
;	mr	r3,r20
;	Xcall	BlockZero
;	endif

***v3.2 - set up memory for macro params
**proj buff
;	move.l	#proj_buff2,d1
;;	bsr.s	calc_mem		returns d0=actual size in bytes
;	move.l	d0,d5		save size for clearing purposes
;	move.l	d0,max_proj_buff_size(a5)	save size for later printing
;	bsr.s	my_alloc
;	tst.l	d1
;	beq.s	mem_error
;	move.l	d1,proj_buff(a5)
;	clr.l	d0
;	movea.l	d1,a0
;	lsr.l	#2,d5		divide by 4 for	long clear
;clear_proj:	moveq	#$00,d0
;	move.l	d0,(a0)+
;	dec.l	d5
;	bne.s	clear_proj

	moveq	#$00,d0
	rts_	"init_mem"
	
**all returns are quad aligned	
my_alloc:	
	qmove.l	pointer_pos(a5),d1	get address of start of block
make_quad:
	qmove.l	d1,d4
	andi.l	#%11,d4
	beq.s	is_quad
	addq.l	#1,d1
	bra.s	make_quad
is_quad:

	qmove.l	d1,d2
	add.l	d0,d2		points to end of block
	qmove.l	end_buff(a5),d0		check memory in range
	cmp.l	d2,d0		cmp new pointer	to end ofbuffer
	blt.s	alloc_error		if eob < new pointer then error
	qmove.l	d2,pointer_pos(a5)
	rts
alloc_error:	moveq	#0,d1
	rts_	"my_alloc"
	align	 	 
**mem error print not enough memory
mem_error:
	qbset	#$07,$0046(a5)
	lea	mem_err_text(pc),a0
	bsr	printit
	moveq	#$ff,d0
	rts_	"mem_erro"
	
**calc mem calculates as memory	size from a percentage in d1.
calc_mem:	move.l	end_buff(a5),d0	get max mem
	sub.l	base_buff(a5),d0	d0=size of free	memory
**divide by 100
	divs.l	#100,d0
	muls.l	d1,d0	calc memory required
	andi.l	#$fffffffe,d0	make even!(silly bugger)
	rts_	"calc_mem"
**clear mem hands back memory we've use to mac
clear_mem:	move.l	base_buff(a5),a0
	OSDisposePtr	a0
;	dc.w	dispose_ptr
	tst.w	d0
	bmi.s	mem_mismatch
	rts_	"clear_me"
int_err_1:	
mem_mismatch:	lea	mem_mis_text(pc),a0
	bsr	printit
	rts_		"mem_mism"	    
**now transfer menu options to assembler flags
tx_opts:	move.w	ext_options(a5),d0	get menu selections
	qmove.w	#0,d1	   	will be option-flags
	btst	#4,d0	linkable?
	beq.s	not_tx_link	no
	qbset	#6,flags5(a5)	yes
	
not_tx_link:	btst	#0,d0	st?
	beq.s	not_tx_st	no
	qbset	#5,d1	st format

not_tx_st:	btst	#1,d0
	beq.s	not_tx_bin
	qbset	#1,d1	binary file only

not_tx_bin:	btst	#2,d0
	beq.s	not_tx_ml	not mac loader
	qbset	#6,d1	mac loader format

not_tx_ml:	btst	#3,d0
	beq.s	not_tx_mr	not mac ram
	qbset	#4,d1	run in mac

not_tx_mr:	btst	#8,d0	o/p labels
	beq.s	not_tx_labs
	qbset	#2,d1	dump labels to file
	
not_tx_labs:	btst	#9,d0
	beq.s	not_tx_src	dump source?
	qbset	#3,d1

not_tx_src:	btst	#10,d0
	beq.s	not_tx_liop	labs in op
	qbset	#0,d1	dump labs in op

not_tx_liop:	move.b	d1,option_flags(a5)
	rts_	"tx_opts "
***************************************************************************************	
char_buff:	dc.b	0,0
new_char_buff:	ds.b	20	space for numbers
a_cr_text:	dc.b	13,0
point_text:	dc.b	".",0
space_text:	dc.b	32,32,32,32,0
	align
log_name:	ds.b	66	*log name is source name.log
	align
mem_err_text:	DC.B	13,"**FATAL** Need more memory (1). Increase Anvil's partition.",13,0
mem_err_sys_text:	DC.B	13,"**FATAL** Need more memory (2). Increase Anvil's partition.",13,0

mem_mis_text:	dc.b	"Address not recognised by dispose_ptr - errr...",13,0
	align

pass1t:	dc.b	"Pass 1",13,0
reading_text:	dc.b	"Reading file(s).",13,0
pass2_t:	DC.B	"Pass 2",13,0
finished_text:	DC.B	"Finished  - ",0
numb_errors_t:	DC.B	" assembler errors and ",0
no_error_text:	DC.B	"No assembler errors and ",0
one_error_t:	DC.B	"One assembler error and ",0
n_bytes_text:	DC.B	" bytes.",13,0
numb_too_big:	DC.B	"xxxxxxxxxx",0
time_text:	DC.B	"Took ",0
secs_text:	dc.b	" seconds.",13,13,0
test_passed:	DC.B	"File assembled and tested ok.",13,0
relocate_text:	DC.B	" absolute long references.",13,13,0
no_reloc_text:	DC.B	"There are no absolute long references.",13,0
pos_inde_text:	dc.b	"Code is position independent.",13,13,0
one_long_text:	dc.b	"One absolute long reference.",13,13,0
pass2_stop:	DC.B	"**Stopped on pass 2**",13,13,0
timer_not_on:	DC.B	"Interupts were disabled - time unknown.",13,13,0
nil_warnings:	DC.B	"No advisements.",13,0
one_warning:	dc.b	"One advisement.",13,0
many_warnings:	dc.b	" advisements.",13,0
log_text:	dc.b	"All errors and warnings placed in Fantasm.log",13,0
bad_assm_t:	DC.B	"********ASSEMBLY FAILED*******",13,13,0
good_assm_t:	DC.B	"Good assembly.",13,13,0
log_full_text:	dc.b	"***Log overflowed***",13,13,0
one_optim_text:	DC.B	"One optimisation saving ",0
nil_optims_text:	dc.b	"No optimisations.",13,0
many_optims_text:	dc.b	" optimisations saving ",0
dash:	DC.B	"  -  ",0
p1p2_text:	dc.b	"***FATAL*** Code size on Pass 2 is different from",13,"code size on "
	dc.b	"Pass 1 - possible forward reference",13,"problem.",13,13,0
asterix:	dc.b	"  ****ERROR****",0
in_macro_def_text:	DC.B	"**FATAL** In a macro definition at end of pass 2.",13,0
in_macro_text:	DC.B	"**FATAL** Assembling from a macro at end of pass 1.",13,0

in_cond_text:	dc.b	"**FATAL** Conditional block error at end of pass 1. ",0
in_else_text:	dc.b	"**FATAL** In part of an else statement at end of pass 1.",13,0
back_in_fantasm:	dc.b	"**Finished**",13,0
ifs_text:	cstring	"Found too many IF's",13
	align
ends_text:	cstring	"Found too many ENDC's/ENDIF's",13
	align
user_abort:	cstring	"еее FANTASM USER ABORT еее",13
	align
stutemp:	dc.l	0	*debug for stumemman
*************************************END**************************************************
	public	fant_entry,fant_entry_b,init,printit,printcr
	public	printnum_signed,printnum,print_long,print_line,init_mem1,init_mem
	public	tx_opts,print_optimisation,numb_error
	public	print_warning2,clear_mem
	public	mem_error,calc_mem,my_alloc
	global	point_text,secs_text,print_space,printit_pass1
	global	printnum_mem_signed
	
	extern	reset_window,aadjusttext,avscroll,do_kbd,pass1,pass2,set_directory
	extern	write_link,write_st,write_mac,play_sound,proj_filename
	extern	ateh,write_file,erase_f,scroll_assm,long_div
	extern	find_error,awindptr,reset_sets,do_alert,make_temp_fsspec,make_fsspec
	extern	get_time,open_error_window
 	extern	send_cmd,write_link_ppc,send_and_wait
 	extern	accumulate_rs,send_to_log,accumulate_globoff,printnum_mem
 	extern	do_idle