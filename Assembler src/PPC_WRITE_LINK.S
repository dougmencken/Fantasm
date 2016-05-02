*********************************************************************************
*FILE:	WRITE_LINK.S								*
*MOTHER FILE:	FANTASM4XX.S							*
*DATE:	251194									*
*LAST MOD:									*
*PROGRAMMER:	STUART BALL							*
*DESCRIPTION:	WRITES THE O/P AS A PPC LINKABLE FILE.	    	    	    	*
*INPUT:	CODE START, PC (LENGTH)							*
*OUTPUT:									*
*********************************************************************************
 
;USE DEF, XDEF OR GLOBAL TO DEFINE SYMBOLS IN A FILE AS GLOBAL.
;USE REF, XREF OR EXTERN TO REFERENCE EXTERNAL SYMBOLS TO A FILE.
;
;Linkable file header (PPC)
;0: Title/comment.
;400: Inputs
;724: Outputs
;1024:	 .L	 Length of global labels/addresses (32 bytes=1 label)
;1028:	 .L	 Length of Extern labels (32 bytes=1 label)
;1032:	 .L	 Length of Imports list (32 bytes=label, 4 bytes pc offset of toc offset).
;1036:	 .L	 Length of code pointers (32 bytes label, 4 bytes pc offset of toc offset, 4 bytes def code offset)
;1040:	 .L	 Length of data pointers (32 bytes label, 4 bytes pc offset of toc offset, 4 bytes def data offset).
;1044:	 .L	 "FLPo" - Identifier for checking.
;1048:	 .L	 Reserved for Length of  code exports.
;1052:	 .L	 Reserved for Length of exported data
;1056:	 .L	 Reserved for optional CRC check sum
;1060:	 .L	 Entry point, or -1 if not in this file
;
;1064:	 .L	 Length of code
;1068:	 .L	 Length of data
;1072:	 .L	 Reserved 1
;1076:	 .L	 reserved 2
;1080:	 .L	 reserved 3
;
;1084:	 Start of globals (28 label/4 offset)
;....:	 Start of externs (28/4)
;....:	 Start of Imports (32/4)
;....:	 Start of code pointers (32/4/4)
;....:	 Start of data pointers (32/4/4)
;....:	 Code
;....:	 Data
;EOF

;
;
;FORMAT OF LABELS/ADDRESSES TABLES
;ÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ
;28 BYTES - LABEL
;4 BYTES  - ADDRESS RELATIVE TO 0


write_link_ppc:
	clr.l	the_code_size(a5)
	tst.w	test_flag(a5)
	beq.s	wlp_ok
	rts		test mode!
wlp_ok:
**v5.21 - check for opt d
	btst	#1,option_flags(a5)
	bne.l	write_binary_ppc
	
	btst	#0,build_options(a5)
	bne.s	link_quiet_please
	lea	ppc_writing_link(pc),a0
	bsr.l	printit	
link_quiet_please:
	move.l	source_buff(a5),a0	use a big buffer!
**first get comment/title/etc
	qmove.l	#1023,d1	counter
	lea	link_title(pc),a1
copy_comm:	addq.l	#1,d7
	qmove.b	(a1)+,(a0)+
	qdbra	d1,copy_comm
	qmove.l	#1024,d7	file size counter
	move.l	source_buff(a5),a0
	lea	1024(a0),a0
**write length of globals

	qmove.l	global_count(a5),d0
	lsl.w	#5,d0
	add.l	d0,d7	add global table size to file length
	qmove.l	d0,(a0)+
**write length of external

	qmove.l	extern_count(a5),d0
	lsl.l	#5,d0
	add.l	d0,d7	add external table size to file length
	qmove.l	d0,(a0)+
**write size of imports list
	qmove.l	total_imports_used(a5),d0	*total number of imports used
	muls	#36,d0		*each entry is 32 bytes
	add.l	d0,d7
	qmove.l	d0,(a0)+

**write size of code ptrs list
	qmove.l	total_code_ptrs_used(a5),d0	*total number of cpde ptrs
	muls	#40,d0		*each entry is 32 bytes
	add.l	d0,d7
	qmove.l	d0,(a0)+
**write size of data ptrslist
	qmove.l	total_data_ptrs_used(a5),d0	*total number of data ptrs
	muls	#40,d0		*each entry is 32 bytes
	add.l	d0,d7
	qmove.l	d0,(a0)+

**write identifier
	tst.l	reloc_tab_pos(a5)
	bne	abs_ref_error	no no no no no !
	qmove.l	entry_point(a5),d0
	qmove.l	d0,(a0)+	*entry or zero

	add.l	#24,d7	account for these six longs
**now clear 3 reserved longs
	qmove.l	#"LOFP",(a0)+	*id - lightsoft object file powerpc
	clr.l	(a0)+
	clr.l	(a0)+
**output entry point
	clr.l	(a0)+
**output length of code and data
	qmove.l	pc(a5),(a0)+			*size of code
	qmove.l	data_buffer_index(a5),(a0)+	*size of data buffer
	add.l	#24,d7
**output 3 reserved longs
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	add.l	#12,d7

**now o/p external labels table

	qmove.l	extern_count(a5),d0
	lsl.l	#5,d0	each extern is 32 bytes
	tst.l	d0
	beq.s	no_externals	none to o/p
	
	move.l	extern_buff_tab(a5),a1
copy_extern:	move.b	(a1),(a0)
	subq.l	#1,d0	cant use dbra cause long
	addq.l	#1,a0
	addq.l	#1,a1
	bne.s	copy_extern	well that was easy!
	
**now o/p global labels (slightly harder)
no_externals:	move.l	labels(a5),a1	label names
	move.l	lab_val(a5),a2	label values
	move.l	global_buff(a5),a3	byte values 1=global
	qmove.l	#-1,d0	table position counter
	move.l	global_count(a5),d6	how many globals
	beq.s	no_globals	none
find_glob:	addq.l	#1,d0	inc table pos
	cmpi.b	#1,(a3)+	is it global?
	bne.s	find_glob	no
	qbsr	op_glob	yes, o/p it to a0
	subq.l	#1,d6	dec number of globs
	bne.s	find_glob	if not zero find next glob
no_globals:	
***now o/p imports

	qmove.l	total_imports_used(a5),d0
	muls	#36,d0	each import is 36 bytes
;	tst.l	d0
	beq.s	no_imports	none to o/p
	
	move.l	imports_output_table(a5),a1
copy_imp:	qmove.b	(a1),(a0)
	subq.l	#1,d0	cant use dbra cause long
	addq.l	#1,a1
	addq.l	#1,a0
	bne.s	copy_imp	well that was easy!

no_imports:
***now code ptrs
	qmove.l	total_code_ptrs_used(a5),d0
	muls	#40,d0	each ptr is 40 bytes
;	tst.l	d0
	beq.s	no_cps	none to o/p
	
	move.l	code_ptrs_output_table(a5),a1
copy_cps:	qmove.b	(a1),(a0)
	subq.l	#1,d0	cant use dbra cause long
	addq.l	#1,a1
	addq.l	#1,a0
	bne.s	copy_cps	well that was easy!
no_cps:
***now data ptrs
	qmove.l	total_data_ptrs_used(a5),d0
	muls	#40,d0	each ptr is 40 bytes 32+4(pc)+4(offset)
;	tst.l	d0
	beq.s	no_dps	none to o/p
	move.l	data_ptrs_output_table(a5),a1
copy_dps:	qmove.b	(a1),(a0)
	subq.l	#1,d0	cant use dbra cause long
	addq.l	#1,a1
	addq.l	#1,a0
	bne.s	copy_dps	well that was easy!
no_dps:

**now o/p code
	move.l	code_start(a5),a1	yer actual code
	move.l	code_end(a5),d1		length of yer actual code
	beq.s	no_code_520b3
	add.l	d1,the_code_size(a5)
	add.l	d1,d7		*update total length
op_code:	qmove.b	(a1),(a0)
	dec.l	d1
	addq.l	#1,a1
	addq.l	#1,a0
	bgt.s	op_code	32 bit now
	addq.l	#1,d7
no_code_520b3:
**now output the data
	move.l	data_buffer(a5),a1
	move.l	data_buffer_index(a5),d1
	beq.s	no_output_data
	sub.l	d1,a1	*a1 was pointing to end of data!
	add.l	d1,d7
	add.l	d1,the_code_size(a5)
op_data:
	qmove.b	(a1),(a0)
	dec.l	d1
	addq.l	#1,a1
	addq.l	#1,a0
	bgt.s	op_data
	addq.l	#1,d7
no_output_data:
	move.l	d7,output_file_size(a5)
	
;**now o/p the file as "text"
;**create temp fsspec to describe the file
;	 move.l	d7,-(sp)
;	 lea	 op_name(a5),a1
;	 lea	 assembler_output_fsspec(a5),a0
;	 bsr.l	 make_temp_fsspec
;	 move.l	(sp)+,d7	 
;	 move.l	source_buff(a5),a1
;	 lea	 temp_fsspec(a5),a0	 *file spec
;	 move.l	d7,d1	 *length (ish)
;	 move.l	#"f4lp",scratch_1(a5)	 *file type
;	 bsr.l	 write_file
;	 save_all
;	 tst.l	 d0
;	 bge.s	 all_ok
;	 bsr.	 report_disk_error
;	 move.b	#-1,fant_return_code(a5)
;all_ok:	restore_all	 
;	 
;	 move.l	#"pf40",d0
;	 move.l	#"f4lp",d1
;	 lea	 temp_fsspec(a5),a0
;	 bsr.l	 fsp_setinfo	 set creator to f312
;
	rts_	"write_link_file_ppc"
	align

**d0 is label position
**This is a leaf routine!
op_glob:	move.l	labels(a5),a1
	move.l	lab_val(a5),a2
	qmove.l	d0,d1	copy position
	lsl.l	#5,d1	times 32 for access
	add.l	d1,a1	point to right label
	qmoveq	#6,d2	counter
	move.l	a0,a4	save pos
op_glob_name:	qmove.l	(a1)+,(a0)+
	qdbra	d2,op_glob_name
ogn_end:	move.l	a4,a0	replace with lea 28(a4),a0
	lea	28(a0),a0	point to value
**LXT change
	qpush1	a2
	qpush2	d0
	lsl.l	#2,d0
	add.l	d0,a2
	qmove.l	(a2),(a0)+
	qpop2	d0
	qpop1	a2
;	move.l	0(a2,d0.l*4),(a0)+
	qrts	"op_glob_ppc"
	align
abs_ref_error:	lea	ppc_cant_write_link(pc),a0
	bsr.l	printit
	rts
	
******************************************************************************
ppc_writing_link:	DC.B	"Writing PowerPCª linkable file to disk.",13,13,0
	align
ppc_cant_write_link:	DC.B	"***FATAL*** Unable to save as a linkable file because the code "
	DC.B	"is not position independent. Use SHOW ABSOLUTE REFS "
	DC.B	"to find where.",13,13,0
	align
	extern	printit,write_file,set_creator,do_alert
	extern	make_temp_fsspec,fsp_setinfo,report_disk_error
	extern	write_binary_ppc
	extern_data	link_title,input,output
	public	write_link_ppc