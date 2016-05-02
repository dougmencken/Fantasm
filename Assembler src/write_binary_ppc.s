**write_binary_68K dumps the file as pure code
**no header, no nothing
write_binary_ppc:
	btst	#0,build_options(a5)
	bne.s	link_quiet_please
	lea	writing_linkbp(pc),a0
	bsr.l	printit	
link_quiet_please:
	move.l	source_buff(a5),a0	use a big buffer!
	clr.l	d7	*file size counter

**now o/p code
	move.l	code_start(a5),a1	yer actual code
	move.l	code_end(a5),d1		length of yer actual code
	beq.s	no_code_520b3
	add.l	d1,the_code_size(a5)
	add.l	d1,d7		*update total length
op_code:	qmove.b	(a1)+,(a0)+
	dec.l	d1
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
	qmove.b	(a1)+,(a0)+
	dec.l	d1
	bgt.s	op_data
	addq.l	#1,d7
no_output_data:
	move.l	d7,output_file_size(a5)
	rts_	"write_binary_ppc"
************************
writing_linkbp:	DC.B	"Creating PPC binary dump file.",13,13,0
	align

	extern	printit
	global	write_binary_ppc