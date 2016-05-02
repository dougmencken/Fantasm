**write_binary_68K dumps the file as pure code
**no header, no nothing
write_binary_68K:
	btst	#0,build_options(a5)
	bne.s	link_quiet_please
	lea	writing_linkb6(pc),a0
	bsr.l	printit	
link_quiet_please:
	move.l	source_buff(a5),a0	use a big buffer!
	clr.l	d7	*file size counter

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
	rts_	"write_binary_68K"
************************
writing_linkb6:	DC.B	"Creating 68K binary dump file.",13,13,0
	align

	extern	printit
	global	write_binary_68K