
beta:	equ	0	*set to 0 for release
beta_exp_time:	equ	0xb53271df	*date to expire/25 June  99

	include call_ccp_macro

**tool version
	reset_locals
	local.l	my_pb_h,1

fantasm_v5:
	entry
**lxt tool entry code
	if PPC
**save regs
	macs_last	*note tools do not use lxt_init
	mflr	r5	*get rts
	stwu	r5,-4(sp)	*put on stack so we can use 68k to return
;	stmw	r10,-88(sp)	**save r10-31
;	subi	sp,sp,88	* reset the stack pointer
	
;	stwu	sp,-88(sp)	* skip over the stack space where the caller
	lwz r25,(rtoc)		*load global data (bss) pointer (first entry in toc)
				*into a5
	mr	r21,r4	*da param
	macs_first
	else
	move.l	8(sp),a1	*parameter block argv
	endif

	sub_entry	a4
	qmove.l	a1,command_save(a5)
	qmove.l	(a1),callback(a5)
	qmove.l	4(a1),callback_toc(a5)

	qmove.l	16(a1),d0	*command
	cmpi.l	#1,d0
	beq.s	fant_init
	cmpi.l	#100,d0
	beq	translate
	cmpi.l	#6,d0
	beq	fant_read_prefs

	bsr	fant_clear_up

	sub_exit	a4
	rts_	"fant_5"

fant_init:
	tst.w	fant_has_been_initted(a5)
	bne	dont_init

	if	beta
**beta, so check time
	lea	beta_time(pc),a0
	OSReadDateTime	a0,d0
	lea	beta_time(pc),a0
	qmove.l	(a0),d0
	cmpi.l	#beta_exp_time,d0	*10th may plus 20 days in secs
	nop
	ble.s	load_resources
	qmove.l	#128,d0	alert
	bsr.l	do_alert
	OSExitToShell

beta_ok:
	endif
load_resources:
**load table resources
	qmove.l	#tables_fourchar,d0

	clr.l	ppc_flsyntax_table_Handle(a5)
	qcmove.w	#flsyntax_resID,d1
	OSGet1Resource	d0,d1,d0
	move.l	d0,ppc_flsyntax_table_Handle(a5)
	move.l	ppc_flsyntax_table_Handle(a5),a0
	OSHLock	a0

	clr.l	ppc_fsyntax_table_Handle(a5)
	qmove.l	#tables_fourchar,d0
	qcmove.w	#fsyntax_resID,d1
	OSGet1Resource	d0,d1,d0
	move.l	d0,ppc_fsyntax_table_Handle(a5)
	move.l	ppc_fsyntax_table_Handle(a5),a0
	OSHLock	a0

	clr.l	ppc_flcode_table_Handle(a5)
	qmove.l	#tables_fourchar,d0
	qcmove.w	#flcode_resID,d1
	OSGet1Resource	d0,d1,d0
	move.l	d0,ppc_flcode_table_Handle(a5)
	move.l	ppc_flcode_table_Handle(a5),a0
	OSHLock	a0

	clr.l	ppc_fcode_table_Handle(a5)
	qmove.l	#tables_fourchar,d0
	qcmove.w	#fcode_resID,d1
	OSGet1Resource	d0,d1,d0
	move.l	d0,ppc_fcode_table_Handle(a5)
	move.l	ppc_fcode_table_Handle(a5),a0
	OSHLock	a0

	clr.l	ppc_cmp_code_table_Handle(a5)
	qmove.l	#tables_fourchar,d0
	qcmove.w	cmp_code_resID,d1
	OSGet1Resource	d0,d1,d0
	move.l	d0,ppc_cmp_code_table_Handle(a5)
	move.l	ppc_cmp_code_table_Handle(a5),a0
	OSHLock	a0

**get beep sound
	qmove.l	#"snd ",d0
	qcmove.w	#128,d1
	OSGet1Resource	d0,d1,d0
	qmove.l	d0,beep_handle(a5)
;	clr.l	-(sp)
;	move.l	#"snd ",-(sp)
;	move.w	#128,-(sp)
;	dc.w	_get1resource
;	move.l	(sp)+,beep_handle(a5)
	qmove.l	beep_handle(a5),a0
	OSHLock	a0

	bsr	set_cpu_type			
	tst.w	is_ppc(a5)
	beq.s	no_load_frag
	bsr	load_frag
	
no_load_frag:
	lea	fant_loaded_text(pc),a0
	bsr	printit
	qmove.w	#1,fant_has_been_initted(a5)
dont_init:	
	bra.s	fant_read_prefs
**we aint going to get here because we quit in fant_read_prefs
	move.l	command_save(a5),a0
	clr.l	d0
	qmove.l	d0,(a0)
	unlk	a4
	rts_	"fant_init"

fant_clear_up:
**release table resources
	move.l	ppc_flsyntax_table_Handle(a5),a0
	beq.s	release_fsyntax_table
	OSReleaseResource  a0
release_fsyntax_table:
	move.l	ppc_fsyntax_table_Handle(a5),a0
	beq.s	release_flcode_table
	OSReleaseResource  a0
release_flcode_table:
	move.l	ppc_flcode_table_Handle(a5),a0
	beq.s	release_fcode_table
	OSReleaseResource  a0
release_fcode_table:
	move.l	ppc_fcode_table_Handle(a5),a0
	beq.s	release_cmp_code_table
	OSReleaseResource  a0
release_cmp_code_table:
	move.l	ppc_cmp_code_table_Handle(a5),a0
	beq.s	clear_save_command
	OSReleaseResource  a0

clear_save_command:
	clr.l	d0
	move.l	command_save(a5),a0
	qmove.l	d0,(a0)

	rts_	"fant_clear_up"

fant_read_prefs:
	qmove.l	#"myPF",d0
	qmove.l	#128,d1
	OSGet1Resource	d0,d1,a1
;	clr.l	-(sp)
;	move.l	#"mypf",-(sp)
;	move.w	#128,-(sp)
;	dc.w	_getresource	*warn of fwd branches, do bwds, and and sub, move.l
;	move.l	(sp)+,a1
	move.l	a1,d0
	beq.s	fault1	*no resource
	move.l	(a1),a2
	move.l	(a2)+,d1
	beq.s	not_wof
	qbset	#0,flags4(a5)
	bra.s	done_wof
not_wof:
	qbclr	#0,flags4(a5)	*warn of fwd bra
done_wof:
	move.l	(a2)+,d1
	beq.s	not_db
	qbset	#1,flags4(a5)	*do backwards
	bra.s	done_db
not_db:
	qbclr	#1,flags4(a5)	*no do bwds
done_db:

	move.l	(a2)+,d1	*the long word = 1 = alternative chroma
	beq.s	not_asq
	qbset	#3,flags4(a5)
	bra.s	done_asq
not_asq:
	qbclr	#3,flags4(a5)	*warn of fwd bra
done_asq:
	move.l	(a2)+,d1	*the long word = 1 = alternative chroma
	beq.s	not_mq
	qbset	#4,flags4(a5)
	bra.s	done_mq
not_mq:
	qbclr	#4,flags4(a5)	*warn of fwd bra
done_mq:
	OSReleaseResource a1
;	move.l	a1,-(sp)
;	dc.w	_releaseresource	*bye to prefs 128

fault1:
**warnings - 129
	qmove.l	#"myPF",d0
	qmove.l	#129,d1
	OSGet1Resource	d0,d1,a1

;	clr.l	-(sp)
;	move.l	#"mypf",-(sp)
;	move.w	#129,-(sp)
;	dc.w	_getresource	*warn of fwd branches, do bwds, and and sub, move.l
;	move.l	(sp)+,a1
	move.l	a1,d0
	beq.s	fault2	*no resource
	move.l	(a1),a2
	move.l	(a2)+,d1	*the long word = warnings
	bne.s	not_warn
	qbset	#1,flags7(a5)
	bra.s	done_warn
not_warn:
	qbclr	#1,flags7(a5)	*no warnings
done_warn:

	move.l	(a2)+,d1	*advice
	bne.s	not_adv
	qbset	#4,flags7(a5)	*no advice
	bra.s	done_adv
not_adv:
	qbclr	#4,flags7(a5)	*d oadvice
done_adv:

	move.l	(a2)+,d1	*64 bit warn
	bne.s	not_64b
	qbset	#3,flags7(a5)	*no show 64 bit warns
	bra.s	done_64b
not_64b:
	qbclr	#3,flags7(a5)	*64 bit warn
done_64b:

	move.l	(a2)+,d1	*the long word = 1 = alternative chroma
	beq.s	not_short
	qbset	#2,flags7(a5)
	bra.s	done_short
not_short:
	qbclr	#2,flags7(a5)	*warn of fwd bra
done_short:
;	move.l	a1,-(sp)
;	dc.w	_releaseresource	*bye to prefs 128
	OSReleaseResource	a1
fault2:
**show optimisations - 130
	qmove.l	#"myPF",d0
	qmove.l	#130,d1
	OSGet1Resource	d0,d1,a1

;	clr.l	-(sp)
;	move.l	#"mypf",-(sp)
;	move.w	#130,-(sp)
;	dc.w	_getresource	*optimisations and quiet
;	move.l	(sp)+,a1
	move.l	a1,d0
	beq.s	fault3	*no resource
	move.l	(a1),a2
	move.l	(a2)+,d1	*the long word = 1 = alternative chroma
	beq.s	not_warn1
	qbset	#7,flags3(a5)	*show optimistaions
	bra.s	done_warn1
not_warn1:
	qbclr	#7,flags3(a5)	*no show optimisations
done_warn1:
	move.l	(a2)+,d1	*the long word = 1 = alternative chroma
	beq.s	not_quiet1
	qbset	#0,build_options(a5)	*show optimistaions
	bra.s	done_quiet1
not_quiet1:
	qbclr	#0,build_options(a5)	*no show optimisations
done_quiet1:

	OSReleaseResource	a1
;	move.l	a1,-(sp)
;	dc.w	_releaseresource	*bye to prefs 128
fault3:

*stall warnings - 132
	qmove.l	#"myPF",d0
	qmove.l	#128,d1
	OSGet1Resource	d0,d1,a1

;	clr.l	-(sp)
;	move.l	#"mypf",-(sp)
;	move.w	#132,-(sp)
;	dc.w	_getresource	*optimisations and quiet
;	move.l	(sp)+,a1
	move.l	a1,d0
	beq.s	fault4	*no resource
	move.l	(a1),a2
	qmove.l	(a2)+,d1	*the long word = 1 = alternative chroma
	qmove.l	d1,r2d2_prefs(a5)
	OSReleaseResource	a1
;	move.l	a1,-(sp)
;	dc.w	_releaseresource	*bye to prefs 128
fault4:

	unlk	a4
	rts_	"fant_read_prefs"

translate:
	global	translate
**check personality at 8(a1) - a686 or appp
	cmpi.b	#"P",12(a1)
	bne.s	set_68k
	qbset	#0,flags7(a5)	*default ppc
	bra.s	done_personality
set_68k:
	qbclr	#0,flags7(a5)
done_personality:
	qmove.l	20(a1),the_file(a5)	*save the file
	qmove.l	24(a1),f_name_addr(a5)	*save file name
	qmove.l	32(a1),f_debug_flag(a5)
	clr.l	fant_end_error(a5)
**get memory for list of includes
	qmove.l	#128*68,d0
	OSNewHandle	d0,a0
;	dc.w	_newhandle
	qmove.l	a0,incldes_h(a5)
	clr.l	tot_number_of_includes(a5)
**get memory for internal strings (26*255) - a to z
	qmove.l	#26*256,d0
	OSNewHandleClear	d0,a0
;	dc.w	_newhandleclear
	qmove.l	a0,d0	debug purps
	tst.l	d0
	beq	no_mem1
	qmove.l	a0,internal_strings_h(a5)
	OSMoveHHi	a0
;	dc.w	_movehhi	*5.1 change
	qmove.l	internal_strings_h(a5),d0
	OSHLock	d0
;	dc.w	_hlock		*5.1 change		
**copy primary filename to 4(includes_h)

	move.l	incldes_h(a5),a0
	move.l	(a0),a0
	lea	4(a0),a1
	move.l	f_name_addr(a5),a0
	qmoveq	#64,d2
	OSBlockMoveData	a0,a1,d2
;	dc.w	_blockmove	
	lea	crap(pc),a1
	OSMaxMem	a1,d0
;	dc.w	maxmem	get all free memory
 	qmove.l 	d0,freemem(a5)	get size of free memory

	qmove.l	freemem(a5),d0
**calc size of data buffer
	qmove.l	d0,d1
	divs.l	#10,d0
	qmove.l	d0,ppc_data_buffer_size(a5)
	qmove.l	d1,d0
	divu.l	#450,d0		*crucial number!
	qmove.l	d0,ppc_number_of_imports(a5)
	lsr.l	#1,d0
	qmove.w	d0,ppc_number_of_code_defs(a5)
	qmove.w	d0,ppc_number_of_data_defs(a5)	
**get mem for requs from system

	qmove.l	#reg_names,d0
	OSNewHandleClear 	d0,a0
;	dc.w	newhandleclear
	qmove.l	a0,d0	debug purps
	tst.l	d0
	beq	no_mem1
	qmove.l	d0,requ_names_h(a5)	

	qmove.l	a4,-(sp)
	if	PPC
	tst.b	frag_loaded(a5)
	beq.s	done_r2d2_init	     *what swg?

**init r2d2

;	lea	proc_pointer(pc),a0
;	move.l	r2d2_init_fd(a5),(a0)	*this is a pointer to fant_to_double's fd
;
;	bsr	univ_pointer1	*returns a pointer in d0, or -1 if failed
	macs_last
	stwu	sp,-112(sp)	; parameter area and linkage area for subroutine
	bl	r2d2_init
	addi	sp,sp,112
	macs_first
;	bra.s	done_r2d2_init


done_r2d2_init:
	endif
;	debug
	bsr	init_mem1	get memory for our buffers
	OSGetMemErr	d0
	bne	no_mem1
	bsr	init_mem	set up buffers
	bsr	init	initialise all
*set up
	qbset	#6,flags5(a5)	linkable file o/p
	bsr	ass_remote_entry	*the_file(a5)
	move.l	(sp)+,a4
**v4 frig
**init r2d2
	section
	if	PPC
	tst.b	frag_loaded(a5)
	beq.s	done_r2d2_term	     *what swg?
	macs_last
	stwu	sp,-112(sp)	; parameter area and linkage area for subroutine
	bl	r2d2_term
	addi	sp,sp,112
	macs_first

;	lea	proc_pointer1(pc),a0
;	move.l	r2d2_term_fd(a5),(a0)	*this is a pointer to fant_to_double's fd
;	bsr	univ_pointer2	*returns a pointer in d0, or -1 if failed
;	bra.s	done_r2d2_term
done_r2d2_term:
	endif
	
**send globals size to build
	btst	#0,flags7(a5)
	beq.s	mode_68
	qmove.l	rs_accumulator(a5),d0	+ve from fant
**Fant530 - altivec aligment space
	add.l	#16,d0	*for sliding bss pointer start
	bra.s	check_size
mode_68:
	qmove.l	globoff_accumulator(a5),d0	-ve from fantasm
;	neg.l	d0		+ve
check_size:
	qmove.l	d0,d7		*save size
	qmove.l	#256,d0		*pb
	OSNewHandleClear	d0,a0
;	dc.w	_newhandleclear
	move.l	a0,d0
	beq	no_mem1
	qmove.l	d0,my_pb_h(a4)
	OSHLock	d0
;	dc.w	_hlock
	move.l	my_pb_h(a4),a0
	move.l	(a0),a0
	qmove.l	#610,(a0)	*a_send_command
**class in 4(a0)
	qmove.l	#"BUIL",4(a0)
	qmove.w	#"Dx",8(a0)			*class we want to send to
	clr.l	12(a0)				*serial
**command in 16
	qmove.l	#20000,16(a0)			*build knows this as set globals size
**file in 16
	qmove.l	d7,20(a0)			*file is here
;	move.l	a0,-(sp)		*request parameter block to anvil
;	move.l	callback(a5),a0
;	jsr	(a0)
;	addq.l	#4,sp			*tidy up stack (ah)
	call_ccp
	qmove.l	my_pb_h(a4),d0
	OSDisposeHandle	d0
;	dc.w	_disposehandle
**return from a_send_command is error, serial, data

**return handle to output file
**linkable file in source_buff(a5)
**size in output_file_size(a5)
	move.l	source_buff(a5),a0
	qmove.l	output_file_size(a5),d2
	lea	code_buff_hand(a5),a1
	OSPtrToHand	a0,a1,d2
;	dc.w	_ptrtohand
	qmove.l	code_buff_hand(a5),d7	*the handle
	OSGetMemErr	d0		*memerr
	tst.w	d0
	beq.s	no_mem_err
	qmove.l	#-1,fant_end_error(a5)	*memory error
no_mem_err:
	qmove.l	newptr_result(a5),d0
	OSDisposePtr	d0	*goodbye to our memory
	qmove.l	requ_names_h(a5),d0
	OSDisposeHandle	d0

**check for errors
**check assm
;	 debug
;	 move.l	fant_end_error(a5),d0
	
	btst	#6,flags6(a5)	fantasm error?
	beq.s	ass_oka
	qmove.l	#-1,fant_end_error(a5)
ass_oka:
	tst.w	fatal_flag(a5)
	beq.s	ass_oka2
	qmove.l	#-1,fant_end_error(a5)

ass_oka2:
	btst	#4,flags2(a5)	fantasm pass 1error?
	beq.s	ass_oka1
	qmove.l	#-1,fant_end_error(a5)
ass_oka1:
	tst.w	ws_err(a5)
	beq.s	ws_oka
	qmove.l	#-1,fant_end_error(a5)
ws_oka:
	tst.b	global_err(a5)
	beq.s	p2_ok
	qmove.l	#-1,fant_end_error(a5)
p2_ok:
	tst.b	fant_return_code(a5)
	beq.s	frc_ok
	qmove.l	#-1,fant_end_error(a5)
frc_ok:
**now, if good assembly, send list of includes to ddbacc
	tst.l	fant_end_error(a5)
	bne.s	do_not_send_incs
	move.l	incldes_h(a5),d0
	OSHLock	d0	*we send a ptr
	qmove.l	#256,d0		*pb
	OSNewHandleClear	d0,a0
	move.l	a0,d0
	beq	no_mem1
	move.l	d0,my_pb_h(a4)
	OSHLock	d0
	move.l	my_pb_h(a4),a0
	move.l	(a0),a0
	qmove.l	#610,(a0)	*a_send_command
**class in 4(a0)
	qmove.l	#"DDBA",4(a0)
	qmove.w	#"CC",8(a0)			*class we want to send to
	clr.l	12(a0)				*serial
**command in 16
	qmove.l	#100,16(a0)			*build knows this as set globals size
**file list in 20
	move.l	incldes_h(a5),a1
	move.l	(a1),a1
	qmove.l	tot_number_of_includes(a5),(a1)
	qmove.l	a1,20(a0)		*ptr to filelist
;	move.l	a0,-(sp)		*request parameter block to anvil
;	move.l	callback(a5),a0
;	jsr	(a0)
;	addq.l	#4,sp			*tidy up stack (ah)
	call_ccp
	qmove.l	my_pb_h(a4),d0
	OSDisposeHandle	d0
	qmove.l	incldes_h(a5),d0
	OSHUnlock	d0
do_not_send_incs:
	qmove.l	incldes_h(a5),d0
	OSDisposeHandle	d0
	qmove.l	internal_strings_h(a5),d0
	OSDisposeHandle	d0
	
	qmove.l	fant_end_error(a5),d0
	move.l	command_save(a5),a0
	qmove.l	d0,(a0)
	qmove.l	d7,4(a0)	*handle to object file
	qmove.l	the_code_size(a5),8(a0)	*size of code and data

	unlk	a4
	rts_	"fant_translate"

no_mem1:
	lea	no_mem_text(pc),a0
	bsr	printit

	qmove.l	#-1,d0
	move.l	command_save(a5),a0
	qmove.l	d0,(a0)
	qmove.l	d7,4(a0)	*handle to object file
	qmove.l	the_code_size(a5),8(a0)	*size of code and data

	moveq	#-1,d0
	unlk	a4
fbye:	rts_	"fant_fatal_errors"
set_cpu_type:
	qmove.l	#"cput",d0		*try for ppc
	lea	gresponse(pc),a1	*result goes here
	OSGestalt	d0,a1,d0
;	dc.w 	$a1ad
;	dc.w 	$2288	*bless you
	lea	gresponse(pc),a0
	qmove.l	(a0),d1
	tst.w	d0
	bmi.s	cput_not_supported	*not ppc
	qmove.w	d1,d0	
	cmpi.w	#$200,d0
	bgt.s	cput_not_supported
	cmpi.w	#$100,d0
	bgt.s	do_ppc_proc
	clr.w	is_ppc(a5)
	rts
do_ppc_proc:
	qmove.w	#1,is_ppc(a5)	*we're ok
	rts_	"fant_set_cpu"
cput_not_supported:
	clr.w	is_ppc(a5)
	rts

load_frag:
	if PPC
	st	frag_loaded(a5)
	else
	clr.b	frag_loaded(a5)
	endif
	rts	*NO! Included in source for native project
;	 tst.b	 frag_loaded(a5)
;	 bne	 dont_load_again	*cause it's embarassing
;	 lea	 frag_loading_text(pc),a0
;	 bsr	 printit
;
;	 clr.b	 frag_loaded(a5)
;
;;	 clr.l	 -(sp)
;	 move.l	#"FppC",d0
;	 move.w	#128,d1
;	 OSGet1Resource	d0,d1,a0
;	 move.l	a0,fantasm_ppc_handle(a5)
;	 move.l	fantasm_ppc_handle(a5),a0
;	 move.l	a0,d0
;	 beq	 report_frag_error
;	 move.l	fantasm_ppc_handle(a5),a0
;	 OSMoveHHi	 a0
;;	 dc.w	 _movehhi
;	 move.l	fantasm_ppc_handle(a5),a0
;	 OSHLock	a0
;;	 dc.w	 _hlock
;	 move.l	fantasm_ppc_handle(a5),a0
;	 OSGetHandleSize	a0,d0
;;	 dc.w	 _gethandlesize	*in d0
;;	 bra	 report_frag_error	 *i'll do this one later!
;;**prepare frag in memory
;	 qmove.l	d0,d1	 *size of code
;	 move.l	fantasm_ppc_handle(a5),a0
;	 qmove.l	(a0),d0	*ptr to where to go
;	 lea	 testname(pc),a1
;	 qmove.l	a1,d2	 *name for debug
;	 move.l	#5,d3	 *load flags
;	 lea	 frag_conn_id(a5),a1
;	 move.l	a1,d4
;	 lea	 frag_main_addr(a5),a1
;	 lea	 err_name(a5),a2
;	 OSGetMemFrag	 d0,d1,d2,d3,d4,a1,a2,d0 
;;	 clr.w	 -(sp)
;;	 move.l	fantasm_ppc_handle(a5),a0
;;	 move.l	(a0),-(sp)	 *code
;;	 move.l	d0,-(sp)	 *size of code
;;	 pea	 testname(pc)	 *name for debug
;;	 move.l	#5,-(sp)	 *load flags
;;	 pea	 frag_conn_id(a5)
;;	 pea	 frag_main_addr(a5)
;;	 pea	 err_name(a5)
;;	 move.w	#3,-(sp)	 *get mem frag
;;	 dc.w	 $aa5a
;;	 move.w	(sp)+,d0
;	 bne	 report_frag_error
;	 
;;**load shared lib
;;	  tst.b	frag_loaded(a5)
;;	  bne	  dont_load_again	 *cause it's embarassing
;;	  clr.w	-(sp)
;;	  pea	  lib_name(pc)
;;	  move.l	#"pwpc",-(sp)	  *arch
;;	  move.l	#5,-(sp)	  *load flags
;;	  pea	  frag_conn_id(a5)
;;	  pea	  frag_main_addr(a5)
;;	  pea	  err_name(a5)
;;	  move.w	#1,-(sp)	  *get shared lib
;;	  dc.w	  $aa5a
;;	  move.w	(sp)+,d0
;;	  bne.s	report_frag_error
;
;	 
;**now find our symbols (exported)
;	 move.l	frag_conn_id(a5),d0
;	 lea	 to_single(pc),a0
;	 lea	 to_single_fd(a5),a1
;	 lea	 symclass(a5),a2
;	 OSFindSymbol	 d0,a0,a1,a2,d0
;;	 clr.w	 -(sp)
;;	  move.l	frag_conn_id(a5),-(sp)
;;	  pea	  to_single(pc)
;;	  pea	  to_single_fd(a5)
;;	  pea	  symclass(a5)
;;	  move.w	#5,-(sp)
;;	  dc.w	  $aa5a	*find symbol
;;	  move.w	(sp)+,d0
;	 bne	 report_frag_error
;
;	 move.l	frag_conn_id(a5),d0
;	 lea	 to_double(pc),a0
;	 lea	 to_double_fd(a5),a1
;	 lea	 symclass(a5),a2
;	 OSFindSymbol	 d0,a0,a1,a2,d0
;;	  clr.w	-(sp)
;;	  move.l	frag_conn_id(a5),-(sp)
;;	  pea	  to_double(pc)
;;	  pea	  to_double_fd(a5)
;;	  pea	  symclass(a5)
;;	  move.w	#5,-(sp)
;;	  dc.w	  $aa5a	*find symbol
;;	  move.w	(sp)+,d0
;	 bne	 report_frag_error
;	 move.l	frag_conn_id(a5),d0
;	 lea	 to_single_sin(pc),a0
;	 lea	 to_single_sin_fd(a5),a1
;	 lea	 symclass(a5),a2
;	 OSFindSymbol	 d0,a0,a1,a2,d0
;
;;	  clr.w	-(sp)
;;	  move.l	frag_conn_id(a5),-(sp)
;;	  pea	  to_single_sin(pc)
;;	  pea	  to_single_sin_fd(a5)
;;	  pea	  symclass(a5)
;;	  move.w	#5,-(sp)
;;	  dc.w	  $aa5a	*find symbol
;;	  move.w	(sp)+,d0
;	 bne	 report_frag_error
;	 move.l	frag_conn_id(a5),d0
;	 lea	 to_double_sin(pc),a0
;	 lea	 to_double_sin_fd(a5),a1
;	 lea	 symclass(a5),a2
;	 OSFindSymbol	 d0,a0,a1,a2,d0
;
;;	  clr.w	-(sp)
;;	  move.l	frag_conn_id(a5),-(sp)
;;	  pea	  to_double_sin(pc)
;;	  pea	  to_double_sin_fd(a5)
;;	  pea	  symclass(a5)
;;	  move.w	#5,-(sp)
;;	  dc.w	  $aa5a	*find symbol
;;	  move.w	(sp)+,d0
;	 bne.s	 report_frag_error
;
;	 move.l	frag_conn_id(a5),d0
;	 lea	 r2d2_name(pc),a0
;	 lea	 r2d2_fd(a5),a1
;	 lea	 symclass(a5),a2
;	 OSFindSymbol	 d0,a0,a1,a2,d0
;
;;	  clr.w	-(sp)
;;	  move.l	frag_conn_id(a5),-(sp)
;;	  pea	  r2d2_name(pc)
;;	  pea	  r2d2_fd(a5)
;;	  pea	  symclass(a5)
;;	  move.w	#5,-(sp)
;;	  dc.w	  $aa5a	*find symbol
;;	  move.w	(sp)+,d0
;	 bne.s	 report_frag_error
;
;	 move.l	frag_conn_id(a5),d0
;	 lea	 r2d2_init_name(pc),a0
;	 lea	 r2d2_init_fd(a5),a1
;	 lea	 symclass(a5),a2
;	 OSFindSymbol	 d0,a0,a1,a2,d0
;;	  clr.w	-(sp)
;;	  move.l	frag_conn_id(a5),-(sp)
;;	  pea	  r2d2_init_name(pc)
;;	  pea	  r2d2_init_fd(a5)
;;	  pea	  symclass(a5)
;;	  move.w	#5,-(sp)
;;	  dc.w	  $aa5a	*find symbol
;;	  move.w	(sp)+,d0
;	 bne.s	 report_frag_error
;
;;	  clr.w	-(sp)
;;	  move.l	frag_conn_id(a5),-(sp)
;;	  pea	  r2d2_term_name(pc)
;;	  pea	  r2d2_term_fd(a5)
;;	  pea	  symclass(a5)
;;	  move.w	#5,-(sp)
;;	  dc.w	  $aa5a	*find symbol
;;	  move.w	(sp)+,d0
;	 move.l	frag_conn_id(a5),d0
;	 lea	 r2d2_term_name(pc),a0
;	 lea	 r2d2_term_fd(a5),a1
;	 lea	 symclass(a5),a2
;	 OSFindSymbol	 d0,a0,a1,a2,d0
;
;	 bne.s	 report_frag_error
;
;	 st	frag_loaded(a5)
;dont_load_again:
;no_ppc:	rts_	 "get_accel"
;report_frag_error:
;	 lea	 no_frag_text(pc),a0
;	 bsr	 printit
;	 clr.b	 frag_loaded(a5)
;	 rts_	 "fant_load_frag"
**end f5
*************************************************************************


do_alert:
	clr.l	d1	*filter proc
	OSAlert	d0,d1,d0
;	clr.w	-(sp)
;	move.w	d0,-(sp)	res id of alert
;	clr.l	-(sp)
;	dc.w	alert
;	move.w	(sp)+,d0
	rts_	"do_alert"
**************************utility routines*****************************************
**needs c string in a0
**and p buffer in a1
c_to_p_str:	clr.l	d0
do_p_loop:	move.b	(a0)+,d1
	beq.s	ctopend
	addq.l	#1,d0	counter		
	qmove.b	d1,0(a1,d0.l)	save byte in p string
	bra.s	do_p_loop
ctopend:	qmove.b	d0,(a1)
	rts

**stack based c to p and p to c convert
ctopstr:	link	a6,#$0000
	clr.l	d0
	movea.l	$000c(a6),a0
	movea.l	$0008(a6),a1
ctploop:	move.b	(a0)+,d1 
	beq.s	ctp_done
	addq.l	#$1,d0
	qmove.b 	d1,$00(a1,d0.l)
	bra.s	ctploop       
ctp_done:	qmove.b	d0,(a1)
	unlk	a6
	rts_	"ctopstr "

ptocstr:	link 	a6,#$0000
	clr.l	d0
	movea.l	$000c(a6),a0
	movea.l	$0008(a6),a1
	move.b	(a0)+,d0 
	bra.s 	ptcdo
ptcloop:	qmove.b	(a0)+,(a1)+ 
ptcdo:	dbra	d0,ptcloop
	clr.b	(a1)
	unlk	a6
	rts_	"ptocstr "

	
*******************variables follow************************************************
**program globals

;volume_name:	ds.b	60	volume name
;sboundrect:	dc.w	0,40,640,479	*screen bounds
;pblock:	ds.b	100	*param block for i/o
;filename:	ds.b	64
;pfilename:	ds.b	64
;proj_filename:	ds.b	100	main filename	
;proj_folder:	ds.b	40
;incbin_folder:	ds.b	40
;output_folder:	ds.b	40
;gi_folder:	ds.b	40	global incs folder
;	even
;gresponse:	ds.l	1	*gestalt return
;fred:	dc.w	$a5a5
;seventrec:	ds.b 	16	*screen event record - moved to a5

**********************data follows*************************************************
;apple_title:	dc.b	1,20	pascal format - char 20=an apple!
;no_w_title:	dc.b	"fantasm editor - no file.",0
;	even
;null_string:	dc.b	0	pascal null string
;	ifne	registered
;ser_no:	dc.b	"serial number: ",0
;	even;
;	else
;what_ser_no:	dc.b	"serial number: unregistered demo",13,0
;	align
;	endif
;disk_label:	cstring	"see disk label",13
;	align	
no_mem_for_regs:	dc.b	"Can not allocate memory for requs...terminating...",13,0

	align
anvil_info:	dc.l	0xf2		*4 data regs in, 1 long out, c
	dc.b	0		*resvd
	dc.b	0		*ppc (68k=0)
	dc.w	0		*routine flags 4=native + 2=needs init + 1=offset

***mode switch code to ppc
univ_pointer1:	dc.w	$aafe		*mixedmodemagic trap
	dc.b	7		*version of mixed mode
	dc.b	0		*
	dc.l	0		*res1
	dc.b	0		*res2
	dc.b	0		*selector info
	dc.w	0		*number of routines (array index!)
**procinforec

**we need to pass a5 and a3
**               a1   a3   a2   d0   returns in d0
**		 r6   r5   r4   r3 
	dc.l	%1011111111110110001100000110010	*register based call - procinfo
	dc.b	0		*resvd
	dc.b	1		*ppc (68k=0)
	dc.w	4		*routine flags 4=native + 2=needs init + 1=offset

proc_pointer:	ds.l	1		*proc pointer (to transition vector actually!)
	dc.l	0		*resvd
	dc.l	0		*resvd

***mode switch code to ppc
univ_pointer2:	dc.w	$aafe		*mixedmodemagic trap
	dc.b	7		*version of mixed mode
	dc.b	0		*
	dc.l	0		*res1
	dc.b	0		*res2
	dc.b	0		*selector info
	dc.w	0		*number of routines (array index!)
**procinforec

**we need to pass a5 and a3
**               a1   a3   a2   d0   returns in d0
**		 r6   r5   r4   r3 
	dc.l	%1011111111110110001100000110010	*register based call - procinfo
	dc.b	0		*resvd
	dc.b	1		*ppc (68k=0)
	dc.w	4		*routine flags 4=native + 2=needs init + 1=offset

proc_pointer1:	ds.l	1		*proc pointer (to transition vector actually!)
	dc.l	0		*resvd
	dc.l	0		*resvd		
	rts_	"r2d2_term_from_68k"


no_mem_text:	cstring	"Fantasm> ¥¥¥No memory! Can't initialise.¥¥¥",13
	align
testname:	pstring	"Fantasm 5 float convert"
	align
no_frag_text:	cstring	"Fantasm> ¥¥¥Couldn't load native code.¥¥¥",13,"PPC floating point directives will",13,"be disabled.",13,13
	align
r2d2_name:	pstring	"r2d2"
	align
r2d2_init_name:	pstring	"r2d2_init"
	align
r2d2_term_name:	pstring	"r2d2_term"
	align
to_single:	pstring	"fant_to_single"
	align
to_double:	pstring	"fant_to_double"
	align	
to_single_sin:	pstring	"fant_to_single_sin"
	align
to_double_sin:	pstring	"fant_to_double_sin"
	align
lib_name:	pstring	"lightsoft_ppc"	*our shared lib name
	align
gresponse:	ds.l	1	*gestalt return
crap:	ds.l	1
	align
	ifeq	registered
	if	PPC
fant_loaded_text:	dc.b	"Fantasm v6.1.0 DEMO (ISA=PPC). AltiVec 1.01",13,"Build #[build$] on [day$]/[month$]/2000",13,0
	else
fant_loaded_text:	dc.b	"Fantasm v6.1.0 DEMO (ISA=68K). AltiVec 1.01",13,"Build #[build$] on [day$]/[month$]/2000",13,0
	endif
	
	else
	if	PPC
fant_loaded_text:	dc.b	"Fantasm v6.1.0 (ISA=PPC). AltiVec 1.01",13,"Build #[build$] on [day$]/[month$]/2000",13,0
	else
fant_loaded_text:	dc.b	"Fantasm v6.1.0 (ISA=68K). AltiVec 1.01",13,"Build #[build$] on [day$]/[month$]/2000",13,0
	endif
	endif	;registered
	align
beta_time:	ds.l	2
	align
;	if PPC
;frag_loading_text:	 cstring	"Fantasm v5.1.0. (ISA=PPC) ©Lightsoft 1998 loading...",13,"Loading Fantasm extensions...",13
;	 else
;frag_loading_text:	 cstring	"Fantasm v5.1.0. (ISA=68K) ©Lightsoft 1998 loading...",13,"Loading Fantasm extensions...",13
;	 endif
	align
;	public	events,update,activate,
	global	do_alert
	public	c_to_p_str,ctopstr,ptocstr
;	public	wdpb,volume_name,pblock,filename
;	public	pfilename,proj_filename,proj_folder,incbin_folder
;	public	output_folder,null_string
;	public	gi_folder
	extern	init,init_mem1,clear_pb,read_prefs,do_checks
	extern	fant_entry,clear_mem,do_mouse,do_menu,aupdate
	extern	awindptr,setupawindow,read_global_prefs,set_up_prefname
	extern	load_voices,play_voice,get_time
	extern	printit,init_eddie,do_build,send_and_wait
	extern	ass_remote_entry,init_mem
	extern	r2d2_init,r2d2_term
	extern	getmem,init_graph_lib

