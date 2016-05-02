*********************************************************************************
*FILE:	WRITE_LINK.S				*
*MOTHER FILE:	FANTASM3XX.S				*
*DATE:	251094				*
*LAST MOD:	200895				*
*PROGRAMMER:	STUART BALL				*
*DESCRIPTION:	WRITES THE O/P AS A LINKABLE FILE.		*			*
*INPUT:	CODE START, PC (LENGTH)			*
*OUTPUT:					*
*********************************************************************************
;IT IS ADVISABLE TO USE LONG BRANCHES TO EXTERNAL SUBROUTINES - THE LINKER WILL
;GENERATE A WARNING IF A BRANCH CAN BE SHORTER.
;
;USE DEF, XDEF OR GLOBAL TO DEFINE SYMBOLS IN A FILE AS GLOBAL.
;USE REF, XREF OR EXTERN TO REFERENCE EXTERNAL SYMBOLS TO A FILE.
;
;LINKABLE FILE HEADER v2.xx
;0:		TITLE, COMMENTS,DESCRIPTION ETC
;400:		INPUTS
;724:		OUTPUTS, USEAGE
;1024:		.L		LENGTH OF GLOBAL LABELS/ADDRESSES (32 BYTES=1 LABEL)
;1028:		.L		LENGTH OF EXTERN LABELS/ADDRESSES (32 BYTES=1 LABEL)
;1032:		.L		cAtH=ID
;1036:				START OF EXTERN LABELS/ADDRESSES
;1036+(1028.L):			START OF GLOBAL LABS/ADDRESSES
;1036+(1028.L)+(1024.L)		START OF CODE

;
;
;FORMAT OF LABELS/ADDRESSES TABLES
;ттттттттттттттттттттттттттттттттт
;28 BYTES - LABEL
;4 BYTES  - ADDRESS RELATIVE TO 0


write_link:
	clr.l	the_code_size(a5)	*for report back tocaller
	tst.w	test_flag(a5)
	beq.s	wl_ok
	rts		test mode!
wl_ok:
**v5.21 - check for opt d
	btst	#1,option_flags(a5)
	bne.l	write_binary_68K
	btst	#0,build_options(a5)
	bne.s	link_quiet_please
	lea	writing_link(pc),a0
	bsr.l	printit	
link_quiet_please:
	move.l	source_buff(a5),a0	use a big buffer!
**first get comment/title/etc
	move.w	#1023,d1	counter
	lea	link_title(pc),a1
copy_comm:	addq.l	#1,d7
	move.b	(a1)+,(a0)+
	dbra	d1,copy_comm
	move.l	#1024,d7	file size counter
	move.l	source_buff(a5),a0
	lea	1024(a0),a0
**write length of globals

	move.l	global_count(a5),d0
	lsl.w	#5,d0
	add.l	d0,d7	add global table size to file length
	add.l	#12,d7	account for these three longs
	move.l	d0,(a0)+
**write length of external

	move.l	extern_count(a5),d0
	lsl.l	#5,d0
	add.l	d0,d7	add external table size to file length
	move.l	d0,(a0)+
**write identifier
	tst.l	reloc_tab_pos(a5)
	bne	abs_ref_error	no no no no no !
	move.l	entry_point(a5),d0
	move.l	d0,(a0)+	*entry or zero
**now o/p external labels table
	move.l	extern_count(a5),d0
	lsl.l	#5,d0	each extern is 32 bytes
	tst.l	d0
	beq.s	no_externals	none to o/p	
	move.l	extern_buff_tab(a5),a1
copy_extern:	move.b	(a1)+,(a0)+
	subq.l	#1,d0	cant use dbra cause long
	bne.s	copy_extern	well that was easy!
	
**now o/p global labels (slightly harder)
no_externals:	move.l	labels(a5),a1	label names
	move.l	lab_val(a5),a2	label values
	move.l	global_buff(a5),a3	byte values 1=global
	move.l	#-1,d0	table position counter
	move.l	global_count(a5),d6	how many globals
	beq.s	no_globals	none
find_glob:	addq.l	#1,d0	inc table pos
	cmpi.b	#1,(a3)+	is it global?
	bne.s	find_glob	no
	bsr.s	op_glob	yes, o/p it to a0
	subq.l	#1,d6	dec number of globs
	bne.s	find_glob	if not zero find next glob
no_globals:	
**now o/p rloc tab
	move.l	reloc_tab_pos(a5),d0	total size of reloc table
	lsr.l	#2,d0	make real count
	beq.s	no_reloc_op
	move.l	reloc_tab(a5),a1
copy_reloc_l:	move.l	(a1)+,(a0)+
	subq.l	#1,d0
	bne.s	copy_reloc_l
no_reloc_op:

**now o/p code
	move.l	code_start(a5),a1	yer actual code
	move.l	code_end(a5),d1		length of yer actual code
	add.l	d1,d7		total length
	add.l	d1,the_code_size(a5)
op_code:	move.b	(a1)+,(a0)+
	dec.l	d1
	bge.s	op_code	32 bit now
	addq.l	#1,d7

**now o/p the file as "text"
**create temp fsspec to describe the file
	move.l	d7,output_file_size(a5)
;	move.l	d7,-(sp)
;	lea	op_name(a5),a1
;	lea	assembler_output_fsspec(a5),a0
;	bsr.l	make_temp_fsspec
;	move.l	(sp)+,d7	
;	move.l	source_buff(a5),a1
;	lea	temp_fsspec(a5),a0	*file spec
;	move.l	d7,d1	*length (ish)
;	move.l	#"f3lk",scratch_1(a5)	*file type
;	bsr.l	write_file
;	save_all
;	tst.l	d0
;	bge.s	all_ok
;	bsr.	report_disk_error
;	move.b	#-1,fant_return_code(a5)
;all_ok:	restore_all	
;	move.l	   #"pf40",d0
;	move.l	#"f3lk",d1
;	lea	temp_fsspec(a5),a0
;	bsr.l	fsp_setinfo	set creator to f312

	rts_	"write_lk"
	align

**D0 IS LABEL POSITION
op_glob:	move.l	labels(a5),a1
	move.l	lab_val(a5),a2
	move.l	d0,d1	copy position
	lsl.l	#5,d1	times 32 for access
	add.l	d1,a1	point to right label
	move.w	#6,d2	counter
	move.l	a0,a4	save pos
op_glob_name:	move.l	(a1)+,(a0)+
	dbra	d2,op_glob_name
ogn_end:	move.l	a4,a0	replace with lea 28(a4),a0
	lea	28(a0),a0	point to value
**LXT
	push	a2
	push	d0
	lsl.l	#2,d0
	add.l	d0,a2
	move.l	(a2),(a0)+
	pop	d0
	pop	a2
;	move.l	0(a2,d0*4),(a0)+
	rts_	"op_glob"
	align
abs_ref_error:
	move.b	#-1,fant_return_code(a5)
	lea	cant_write_link(pc),a0
	bsr.l	printit
	rts
	
******************************************************************************
writing_link:	DC.B	"Creating 68K linkable file.",13,13,0
	align
cant_write_link:	DC.B	"***FATAL*** Unable to save as a linkable",13,"file because the code "
	DC.B	"is not position",13,"independent. Use SHOW ABSOLUTE REFS "
	DC.B	13,"to find where.",13,13,0
	align
	extern	printit,write_file,set_creator,do_alert
	extern	make_temp_fsspec,fsp_setinfo,report_disk_error,write_binary_68K
	extern_data	link_title,input,output
	public	write_link