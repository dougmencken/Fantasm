********************************************************************************
*PASS1.S - FANTASM FORMAT			               *
*060694	SB			               *
*INTERNAL VERSION NUMBER:	1		               *
*REV CHANGES:				               *
*V1	ORIGINAL			               *
*V2 260794	DONT CLEAR FILE BUFFERS ANY MORE	               *
********************************************************************************

**THIS IS THE START OF PASS 1
pass1:	  
;	movea.l	f_name_addr(a5),a0 	*file to load - _proj_fname from c frame
**get src from the_file into file_buff1
	move.l	the_file(a5),a0
	qmove.l	a0,file_buff1(a5)
;	move.l 	file_buff1(a5),long_var(a5) 	*pass buffer address

;	bsr	readmain  	*read main source into file_buff1
;	tst.l	d0
;	bmi	dead	*couldnt find file
;	bsr	do_build_receive	*add in anything from build
	bsr 	find_includs	*copy lines to source_buff(a5) +insert files
  
****now we have all the source lines in source_buff
****things get difficult now!
	tst.w d0
	bmi dead 		*summat wrong
	btst	#0,build_options(a5)
	bne.s	skip_disp_lines
	move.l line_count(a5),d0
	subq.l #1,d0 		*slight correction!
	bsr printnum
	lea	lines_read(pc),a0
	bsr	printit 		*print number of lines read

**print 'source size: xxxxk out of xxxx"
 lea source_bytes(pc),a0 	*source size:
 bsr printit
 qmove.l char_count(a5),d0
 bsr printnum
 lea bytes_text(pc),a0
 bsr printit 		*bytes out of
 qmove.l max_s_size(a5),d0
 bsr printnum
 lea bytes1_text(pc),a0 	*bytes.cr
 bsr printit
**check we didnt over run
skip_disp_lines:
	qmove.l	char_count(a5),d0
	qmove.l	max_s_size(a5),d1
	cmp.l	d1,d0
	blt.s	source_ok
	lea	outtamem(pc),a0
	bsr	printit
	bra.s	dead
source_ok:
	bsr convert 		*convert to how we want it!
	btst	#0,build_options(a5)
	bne.s	skip_p_labs
	lea lab_text(pc),a0 	*compiling labels....
	bsr printit
skip_p_labs:
*************do pass 1******************************
	bsr.l	pass1_now 	*here we go then!!!!!!!!
	tst.w	d0
	bmi.s	dead	*fatal err on pass 1
****pass 1 completed 0851 200294 - hurray!!!!!!!****
****v3.20 pass 1 completed 0319 210895 -yipee!!*****
not_cond_err:	btst	#0,build_options(a5)
	bne.s	not_show_labs	quiet?
**show how many labels
	btst	#7,flags5(a5)	defall?
	beq.s	no_defall
	bsr.s	set_all_global	yes
no_defall:	bsr.s	show_labs
not_show_labs:
	btst #3,option_flags(a5)
	beq.s no_w_src
	bsr write_src 	*option s+ - write out complete source
no_w_src:
	bsr write_labels 	*option l+ - write out label table in address order
	rts_	"pass1"		*bye
dead:
;	bset #7,flags(a5) 	*error detected flag
	st	global_err(a5)
	lea f_errors(pc),a0 	*tell user assembly failed
	bsr printit
	moveq #-1,d0 		*fatal failure.
	rts
******************level 1 subs follow*********************
**sets all labels to global at end of pass 1 if defall encountered
**not implemented
set_all_global:	qmove.w	lt_num(a5),d7
	ext.l	d7
	move.l	d7,global_count(a5)	how many globals
	beq.s	no_sag	no labels
	subq.w	#1,d7
	qmoveq	#1,d0
	move.l	global_buff(a5),a1	global table
sag_loop:	qmove.b	d0,(a1)+
	dbra	d7,sag_loop
no_sag:	rts

show_labs:	move.l lt_pos(a5),d0 	*show how many labels
	beq.s	show_no_labs
	lsr.l #5,d0
	cmpi.w	#1,d0
	beq.s	show_one_lab
	bsr printnum
	lea labels_text(pc),a0
	bsr printit
	bra.s	shown_labs
show_no_labs:	lea	no_labs_text(pc),a0
	bsr	printit
	bra.s	shown_labs
show_one_lab:	lea	one_lab_text(pc),a0
	bsr	printit
shown_labs:
**show how many equs
	move.l eq_pos(a5),d0 	*show how many labels
	beq.s	show_no_equs
	lsr.l #5,d0
	cmpi.w	#1,d0
	beq.s	show_one_equ
	bsr.l	printnum
	lea	equs_text(pc),a0
	bsr	printit
	bra.s	shown_equs
show_no_equs:	lea	no_equs_text(pc),a0
	bsr	printit
	bra.s	shown_equs
show_one_equ:	lea	one_equ_text(pc),a0
	bsr	printit

shown_equs:
	move.l	macro_num(a5),d0
	beq.s	show_no_macs
	cmpi.w	#1,d0
	beq.s	show_one_mac
	bsr.l	printnum
	lea	mac1_text(pc),a0
	bsr	printit
	bra.s	shown_macs
show_one_mac:	lea	mac2_text(pc),a0
	bsr	printit
	bra.s	shown_macs
show_no_macs:	lea	mac3_text(pc),a0
	bsr	printit
shown_macs:
	btst	#0,ppc_flags1(a5)
	beq.s	shown_imports		*not ppc mode!
;	clr.l	d0
	move.l	total_imports_num(a5),d0
	beq.s	show_no_imports
	cmpi.w	#1,d0
	beq.s	show_one_import
	bsr.l	printnum
	lea	imp1_text(pc),a0
	bsr	printit
	rts
show_one_import:	lea	imp2_text(pc),a0
	bsr	printit
	rts
show_no_imports:	lea	imp3_text(pc),a0
	bsr	printit
	rts
shown_imports:
	lea	imp4_text(pc),a0
	bsr	printit
	rts
  
*convert modifies the complete source to the format we want:
*1. makes everything upper case except strings in quotes - "
*2. replaces all tabs with spaces.

convert:	movea.l source_buff(a5),a0 	*our source
	qmove.l char_count(a5),d0 	 *size of source
	qmoveq #0,d1 	 	 *source index
	qmoveq	#$7b,d3	*above this is also upper case
	qmoveq #$60,d4 	*upper case limit
	qmoveq #9,d5
	clr.l	d6	string flag
	qmoveq #32,d7
conv_loop:
**LXT change
	qpush1	a0
	add.l	d1,a0
	qmove.b	(a0),d2
	qpop1	a0
;	move.b 0(a0,d1.l),d2 	*get byte
	tst.b	d6
	bne.s	in_string	we dont convert in strings

	cmpi.b	#$22,d2	*quotes?
	beq.s	toggle_string	*toggle string flag
	cmp.b d5,d2 		*tab char?
	beq.s conv_tab
**v4 - if ppc then dont convert to upper case!
	btst	#0,flags7(a5)
	bne.s	upper_ok
	
	cmp.b	d3,d2
	bge.s	upper_ok	*if ge 7b the upper case
	cmp.b d4,d2 		*if less than _ then it is upper case
	ble.s upper_ok
**commented out to make case sensitive
**LXT change
	qpush1	a0
	add.l	d1,a0
	sub.b	d7,(a0)
	qpop1	a0
;	sub.b d7,0(a0,d1.l) 		*make upper case

upper_ok:	addq.l #1,d1
	cmp.l d0,d1
	ble.s conv_loop
	rts
conv_tab:
**LXT change
	qpush1	a0
	add.l	d1,a0
	qmove.b	d7,(a0)
	qpop1	a0
;	move.b d7,0(a0,d1.l) 	*insert a space
	addq.l #1,d1
	cmp.l d0,d1
	ble.s conv_loop
	rts

in_string:	cmpi.b	#$22,d2	*end of string?
	beq.s	toggle_string	*yes
	cmpi.b	#13,d2	*cr?
	beq.s	toggle_string	*eol before eos!
do_next:	addq.l	#1,d1	*no
	cmp.l	d0,d1
	ble.s	conv_loop
	rts
	
toggle_string:
	eori.l	#1,d6	*toggle flag
	bra.s	do_next

	
******************************
*write_labels saves the labels as labels.lst
write_labels:
 btst #2,option_flags(a5) 	option l+
 bne.s w_labs
 rts
w_labs:
 	lea 	write_lab_text(pc),a0 	*writing label table to disk....
 	bsr 	printit
 	move.l 	file_buff1(a5),d1 	*use file buffer #1 to build listing in.

 	movea.l 	labels(a5),a0 	*where the labels are
 	movea.l 	lab_val(a5),a2 	*label values
 	movea.l 	d1,a3 	*op buffer
 	clr.l 	d5 		*label counter
 	clr.l 	d7 		*byte counter
pl_loop:
 	movea.l 	a0,a1
 	tst.b 	(a1)
 	beq.s 	end_print
	moveq	#31,d4	tabs=32
pl:	move.b	(a1)+,d0
	beq.s	end_pl
	qmove.b	d0,(a3)+ 	*copy label
	addq.l	#1,d7
	subq.l	#1,d4	tab counter
	bne.s	pl
end_pl:	add.l	d4,d7	inc file size counter
	addq.l	#1,d7
	cmp.l	max_f_size(a5),d7
	bgt	labs_full	out of memory for labels buffer
fill_tab:	move.b	#" ",(a3)+
	dbra	d4,fill_tab	fill rest of tab with spaces
**LXT change
	qpush1	a2
	add.l	d5,a2
	qmove.l	(a2),d0
	qpop1	a2
; 	 move.l 	0(a2,d5.l),d0
 	bsr	print_mem 	*prints the number in d0 to a3
 	qmove.b 	#13,(a3)+
 	addq.l 	#1,d7
 	add.l 	#32,a0
 	addq.l 	#4,d5
 	bra.s 	pl_loop
end_print: 
 	lea 	source_name(a5),a1
 	lea 	labels_name(pc),a0 	*build filename
	addq.l	#1,a0
	lea assembler_source_fsspec(a5),a1
	addq.l	#6,a1	*->name past count
	clr.l	d2
	qmove.b	(a1)+,d2
	moveq	#-1,d1	*count byte

build_lab_name:
	addq.l	#1,d1
 	move.b 	(a1)+,d0
 	beq.s 	got_lab_name
 	cmpi.b 	#".",d0
 	beq.s 	got_lab_name
 	qmove.b 	d0,(a0)+ 	 *copy char
 	dbra	d2,build_lab_name
got_lab_name:
 	qmove.b 	#".",(a0)+
 	qmove.b 	#"L",(a0)+
 qmove.b #"A",(a0)+
 qmove.b #"B",(a0)+
	clr.b	(a0)+
	addq.l	   #4,d1	*count byte
	lea labels_name(pc),a0 	a0->source total filename xxxxxxxx.s_tot
	qmove.b	d1,(a0)	*pascal byte count
	addq.l	#1,a0	*printit is c routine
	qmove.l	d7,-(sp)
	bsr	printit
	bsr	printcr
	qmove.l	(sp)+,d7
	lea	assembler_output_fsspec(a5),a0
 	lea 	labels_name(pc),a1 	a0->labels filename xxxxxxxx.lab
	bsr	make_temp_fsspec
	lea	temp_fsspec(a5),a0
 	movea.l 	file_buff1(a5),a1

 	qmove.l 	d7,d1
	qmove.l	#"TElb",scratch_1(a5)
 	bsr 	write_file 		*write a0 to disk
	tst.l	d0
	bge.s	wl_ok
	bsr.l	report_disk_error
	rts	
wl_ok:	  
* movea.l file_buff1(a5),a0
* dc.w dispose_ptr
	rts
labs_full:	lea	labs_full_text(pc),a0
	bsr	printit
	rts
	 
************printnum_mem prints d0 as a 16 bit number to a3
print_mem:
 qmoveq #0,d6
 qmove.w d0,d6
 divs #10000,d6
 beq.s skip_zero
 qbsr convertm
 bra.s do_thous
skip_zero: 		*skip the leading zero
	clr.w	d6
	swap	d6
; swap d6
; andi.l #$ffff,d6
do_thous:
 divs #1000,d6
 qbsr.s convertm
 divs #100,d6
 qbsr.s convertm
 divs #10,d6
 qbsr.s convertm
 qbsr.s convertm
 rts
convertm:
 	addi.b #48,d6
 	qmove.b d6,(a3)+
 	addq.l #1,d7
	clr.w	d6
 	swap d6
; andi.l #$0000ffff,d6
 qrts
 
 
******************************
*write_src writes the contents of source_buff(a5) to disk
*as source.tot
write_src:
 lea write_src_text(pc),a0 	*writing label table to disk....
 bsr printit
 lea source_name(pc),a0 	*name of file to write
	addq.l	#1,a0	*space for count byte
 lea assembler_source_fsspec(a5),a1
 addq.l	#6,a1	*->name past count
	clr.l	d2
	move.b	(a1)+,d2
	moveq	#-1,d1	*count byte
build_src_name:
	addq.l	#1,d1
 move.b (a1)+,d0
 beq.s got_src_name
 cmpi.b #".",d0
 beq.s got_src_name
 move.b d0,(a0)+ 	*copy char
 dbra 	d2,build_src_name
 
got_src_name:
 qmove.b #".",(a0)+
 qmove.b #"s",(a0)+
 qmove.b #"_",(a0)+
 qmove.b #"t",(a0)+
 qmove.b #"o",(a0)+
 qmove.b #"t",(a0)+
	clr.b	(a0)
 addq.l	#6,d1	*count byte
 lea source_name(pc),a0 	a0->source total filename xxxxxxxx.s_tot
	qmove.b	d1,(a0)	*pascal byte count
	addq.l	#1,a0	*printit is c routine
 bsr printit 		print filename
 bsr printcr
 	
	lea	assembler_output_fsspec(a5),a0	*folder name and fsspec
	lea source_name(pc),a1
	bsr	make_temp_fsspec
	lea	temp_fsspec(a5),a0
	movea.l source_buff(a5),a1 	*buffer address
	move.l char_count(a5),d1 	*length of buffer
 	qmove.l	#"TEsr",scratch_1(a5)
	bsr write_file 		  *write buffer to hd
	tst.l	d0
	bge.s	wf_ok
	bsr.l	report_disk_error	
wf_ok:
	 rts_	"wr_src"
	align
******************************
*readit neads a filename in a0.
*it reads the file into long_var
*called from find_incs
readit: 	bsr.s open_src 		*open fantmain.s and read it into a1
	tst.l d0
	bmi.s fatal1		*fatal error on opening fantmain.s!
	rts_	"readit" 	 	 *fantmain read in ok

fatal1:
; 	  bset #7,flags(a5) 	*error detected flag
	st	global_err(a5)
	lea inc_f_name(pc),a0
;	clr.l	d0
	qcmove.b	(a0)+,d0
;	subq.b	#1,d0
	clr.b	0(a0,d0.w)	*make c string 
	bsr printit
	lea p1error(pc),a0
	bsr printit
	moveq #-1,d0
	rts_	"fatal1"
 
;readmain:	 bsr.s open_src 		 *open src file and read into long_var
;	 tst.l d0
;	 bmi.s fatal2	 	 *fatal error on opening fantmain.s!
;	 rts 	 	 *fantmain read in ok

fatal2:
;	bset #7,flags(a5) 	*error detected flag
	st	global_err(a5)
	lea pmerror(pc),a0
	bsr.l printit
	moveq #-1,d0
	rts_	"fatal2"

open_src:
	bsr	read_file
	rts_	"open_src"
 
*********************FIXED DATA FOLLOWS*******************
source_name: ds.b	50 	filename+.s_tot
labels_name: ds.b	50 	filename+.lab goes here
inc_f_name:	ds.b	50
p1error:	dc.b	"  -  Cant find this file!",13,0
pmerror:	dc.b	"Cant find this source file - please select stand alone source file"
	dc.b	" from the file menu, or check the Build Control File.",13,13,0
open_text:	dc.b	"Open error",13,0
create_text:	dc.b	"Create error.",13,0
create2_text:	dc.b	"Cant open file after creating it! - Errr?",13,0
lf_error_t:	dc.b	"No LFs allowed!",13,0
f_errors:	dc.b	"***Pass 1 halted***",13,0
lines_read:	dc.b	" lines.",13,0
source_bytes:	dc.b	"Total source size: ",0
bytes_text:	dc.b	" bytes used out of ",0
bytes1_text:	dc.b	" bytes.",13,13,0
lab_text:	dc.b	"Building label dictionary.",13,13,0
labels_text:	dc.b	" labels, ",0
write_lab_text:	dc.b	"Writing labels to output folder as ",0
write_src_text:	dc.b	"Writing complete source to output folder as ",0
file_size_text:	dc.b	"File too big - allocate more memory to Fantasm.",13,13,0
no_labs_text:	DC.B	"No labels, ",0
one_lab_text:	dc.b	"One label, ",0
equs_text:	DC.B	" equates, ",0
no_equs_text:	dc.b	"no equates, ",0
one_equ_text:	dc.b	"one equate, ",0
mac1_text:	dc.b	" macros and ",0
mac2_text:	dc.b	"one macro and ",0
mac3_text:	dc.b	"no macros and ",0
imp1_text:	dc.b	" imports.",13,13,0
imp2_text:	dc.b	"one import.",13,13,0
imp3_text:	dc.b	"no imports.",13,13,0
imp4_text:	dc.b	"no PowerPC imports.",13,13,0
outtamem:	DC.B	"***NOT ENOUGH MEMORY***",13,13,0
labs_full_text:	DC.B	"***NOT ENOUGH MEMORY TO WRITE LABELS TO DISK***",13,13,0
cond_err:	DC.B	"**FATAL** In a conditional at end of pass 1.",13,13,0
	align
***********************************************************
	public	pass1,convert,write_labels,print_mem,write_src
	public	fatal1,fatal2
	
	global	source_name,labels_name,inc_f_name
	global	readit

	extern	printit,write_file,read_file,printcr,seventrec
	extern	printnum,find_includs,pass1_now,do_build_receive
	extern	make_temp_fsspec,open_folder,report_disk_error
	