***************************************************************
*FIND_ERROR GOES THROUGH EVERY FILE THAT IS INCLUDE D IN THE
*SOURCE, AND COUNTS THE LINES TILL IT GETS TO THE ERROR LINE
*THEN PRINTD THE FILE NAME
*
*IF WE ARE ASSEMBLING FROM MACRO BUFFER, THE SOURCE POINTERS ARE SWAPPED
*8TO POINT TO THE ORIGINAL TEXT FIRST!
*****FOLLOWING
*****THE INCLUDES FROM EACH FILE.
*****NOTE THAT WE ALLOW UPTO 3 LEVELS OF INCLUDES

find_error:
	btst	#1,flags2(a5)	*assembling from macro
	beq.s	normal_error	*no
	qmove.l	a0,-(sp)	*save current text pointers
	lea	macro_name(a5),a0
	bsr.l	printit	print current macro name
	lea	macro_error1(pc),a0
	bsr.l	printit	*macro error 
**goto top text level
;	clr.l	d1
;	move.w	macro_nest_depth(a5),d1
	lea	source_pointer_save(a5),a1
;	clr.l	d1
;	move.w	source_pointer_save_index(a5),d1	debug purps
;;	ext.l	d1
;	subq.l	#4,d1	up a level
;	add.l	d1,a1
	move.l	(a1),a0	*original source file
	move.l	a0,d0	test it
	beq.s	crap_error	not initialised
	bsr.s	normal_error
	lea	mx_text(pc),a0
	bsr.l	printit
crap_error:	move.l	(sp)+,a0	*back into macro buffer
	rts
	
normal_error:

	moveq.l	#-1,d0 	*line counter
	movea.l	a0,a1	*source position
***now we search back in the file for a $ at the start of the line
***to find the filename. from a0-a1 we get the difference in lines
***so we can calc the line number
***first find cr$ in -a1
	
	moveq.l	#13,d1
find_crd:
	move.b	-(a1),d4	*LXT change
	cmp.b	d4,d1
	bne.s	find_crd
**now we've got a cr, we need to see if the next char is a $
	addq.l	#1,d0 		*linecount-1
	cmpi.b	#"$",1(a1)
	bne.s	find_crd		*nope
***here  we are pointing at the filename in a1 (i hope)
 qmove.l d0,-(sp) 	 *save start of file line #
 lea inc_f_name(pc),a0 	*we'll use this buffer again to print filename
 addq.l #2,a1
get_fname_l:
 move.b (a1)+,d0
 cmpi.b #13,d0
 beq.s gfname_end
 move.b d0,(a0)+
 bra.s get_fname_l
gfname_end:
 clr.b	(a0)
 lea inc_f_name(pc),a0
**3.50 - see if name is main, and make a real name if so.
	cmpi.l	#"MAIN",(a0)
	bne.s	got_fname1
**replace main with source file name
	
	move.l	f_name_addr(a5),a1	*tis an fsspec
;	addq.l	#6,a1
	clr.l	d0
	move.b	(a1)+,d0	*count

	subq.w	#1,d0
new_name:
	move.b	(a1)+,(a0)+
	dbra	d0,new_name
	clr.b	(a0)+	*c string remember stu.
	lea	inc_f_name(pc),a0
got_fname1:
; addq.l	 #1,a0	 *320 - skip pascal byte count
	bsr.l printit
	lea line_n_text(pc),a0
	bsr.l printit
	clr.l	d0
	move.w	incs_counter(a5),d0
;	ext.l	d0
	add.l	d0,(sp)

	move.l (sp),d0 	*print line number
	tst.w	building?(a5)
	beq.s	skip_frig2
	subq.l	#1,d0	*dont do this if building
skip_frig2:
	bsr.l printnum
**
	lea crtext(pc),a0
	bsr.l printit
	move.l	(sp)+,d7
;	tst.w	integrated(a5)	*lide?
;	beq.s	not_lide
	lea	inc_f_name(pc),a0
	bsr.s	printit_to_error
not_lide:
 rts_	"find_err"
	align
**line number in d7
printit_to_error:
	move.l	a0,a1	*save text	
	lea	comms_buffer(a5),a0
**now copy string
csl:
	move.b	(a1)+,(a0)+
	bne.s	csl
	subq.l	#1,a0	*dont pass 0
	move.l	#" Lin",(a0)+
	move.l	#"e = ",(a0)+
	move.l	d7,d6
;	move.l	a0,a3	*save current
	bsr.s	printnum_mem
	move.w	#". ",(a0)+
	move.l	error_string_save(a5),a1	->erorr string
**copy error string
ces:
	move.b	(a1)+,d1
	beq.s	done_str
	cmpi.b	#13,d1
	beq.s	done_str
	cmpi.b	#".",d1
	beq.s	done_str
	move.b	d1,(a0)+
	bra.s	ces
done_str:
	move.b	#13,(a0)+
	clr.b	(a0)
	lea	comms_buffer(a5),a0
	bsr.l	send_to_error
	rts_	"printit_it_to_error"
	align
	
**************
printnum_mem:	
	cmpi.l	#10000,d6
	bge.s	do_ttm
	cmpi.l	#1000,d6
	bge.s	dt_m
	cmpi.l	#100,d6
	bge.s	dh_m
	cmpi.l	#10,d6
	bge.s	dte_m
	bra.s	du_m
do_ttm	divu	#10000,d6	get tens of thoudsands
	bsr.s	convert_m	print number of tens of thousands
dt_m	divu	#1000,d6	get thousands
	bsr.s	convert_m	etc
	move.b	#0x2c,(a0)+	*Comma
dh_m	divu	#100,d6
	bsr.s	convert_m
dte_m	divu	#10,d6
	bsr.s	convert_m
du_m:	bsr.s	convert_m
;	clr.b	(a0)
	rts
convert_m:	addi.b	#48,d6	make character	(ascii)
	move.b	d6,(a0)+
	swap	d6
	andi.l	#$ffff,d6
	addq.l	#1,d1	*inc counter for no_commas
	rts_	"printnmm"
		
line_n_text:	DC.B	"  at line ",0
crtext:	DC.B	13,0 
macro_error1:	DC.B	" - Macro error - macro called in ",0
mx_text:	DC.B	"Expands to:",13,0
	align
***************************************************************************
store_name: 	DS.W 40
	align
	global	find_error,printnum_mem
	extern_data	inc_f_name
	extern	printit,printnum
	extern	send_and_wait,send_to_error
	