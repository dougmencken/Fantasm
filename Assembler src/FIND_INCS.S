***************************************************************
*FIND_INCLUDES GOES THROUGH EVERY FILE THAT IS INCLUDE D IN THE
*SOURCE, AND BUILDS THE COMPLETE SOURCE IN SOURCE_BUFF(A5).
*THE LIMITS ARE UPTO 3 LEVELS OF INCLUDES
*
*VERSION 1 RELEASED 290794 SB
*VERSION 1.01 FIXES LF BUG - IGNORES THEM!

*****FIND_INCLUDES BUILDS THE WHOLE SOURCE BY FOLLOWING
*****THE INCLUDES FROM EACH FILE.
*****NOTE THAT WE ALLOW UPTO 3 LEVELS OF INCLUDES
find_includs:
 clr.l line_count(a5) 	*source code line counter
 clr.l char_count(a5) 	*length of source code
 clr.l file_counter(a5)
 movea.l file_buff1(a5),a0 	*a0->fantmain.s
 movea.l source_buff(a5),a2  	*the whole source is built here
***insert cr$main at start of text
 qmove.b #13,(a2)+
 qmove.b #"$",(a2)+
**insert file name
 qmove.l #"MAIN",(a2)+
 qmove.b #13,(a2)+
 addq.l #7,char_count(a5)
 	addq.l	#1,line_count(a5)
scan_next_inc:
	qmove.l	char_count(a5),d0
	cmp.l	max_s_size(a5),d0
	blt.s	source_s_ok
	qmove.l	#5050,d0
	bsr.l	do_alert	*out of memory for source
	OSExitToShell
source_s_ok:
 lea includ_t(pc),a1 	*what we're looking for
 bsr scan_includs 	*process this line
 tst.w d0
**scan includes can return:
**0=no includes
**1=inlcude found
**-1=eof
 beq copy_line
 bmi includs_done

**here we've found an include
*skip spaces and tabs to get to file name
*we dont include includes in the source.
*we put a $filename instead, in the source (a0),so we can back track to
*find errors

 qmove.b #13,(a2)+ 	 *cr
 qmove.b #"$",(a2)+ 	 *$ in source
 addq.l	#1,line_count(a5)
 addq.l #2,char_count(a5)
 subq.l #1,a0

find_name:
 addq.l #1,a0
 cmpi.b #32,(a0)
 beq.s find_name
 cmpi.b #9,(a0)  	*tab?
 beq.s find_name
*now a0 points to start of file name
 movea.l a0,a4  	*save position in this file
 lea inc_f_name(pc),a0 	*now copy the file name
	addq.l	#1,a0
copy_inc_f_name:
 move.b (a4)+,d0
 beq.s copy_f_end	*eof
 cmpi.b #13,d0 	*cr?
 beq.s copy_f_end
 cmpi.b #32,d0 	*space?
 beq.s copy_f_end
 cmpi.b #9,d0 		*tab?
 beq.s copy_f_end
 qmove.b d0,(a0)+
 qmove.b d0,(a2)+ 	 *write filename to source
 addq.l #1,char_count(a5)
 bra copy_inc_f_name
copy_f_end:
 clr.b	(a0) 	*terminate filename
**insert count byte to start of filename
**find length
	lea	inc_f_name(pc),a0
	addq.l	#1,a0
	qmoveq	#-1,d1
fle:	addq.l	#1,d1
	tst.b	(a0)+
	bne.s	fle
	lea	inc_f_name(pc),a0
	qmove.b	d1,(a0)			****320
		
 qmove.b #13,(a2)+ 	 *cr after filename in source
 addq.l #1,char_count(a5)
 addq.l	#1,line_count(a5)
*now find eol
 subq.l #1,a4 	*correct file position
find_eol:
 cmpi.b #13,(a4)+
 bne.s find_eol
 qmove.l a4,file_pos1(a5) 	 *save our position in this file
 lea inc_f_name(pc),a0
 bsr.s read2 	  	    *process first includ filename
 bmi.s includ_err
**now copy original filename into text

 move.l f_name_addr(a5),a3 	*fsspec of master filename
; addq.l	#6,a3
 
 qmove.b #13,(a2)+
 qmove.b #"$",(a2)+ 	 *preceed with $
 addq.l #2,char_count(a5)
;	clr.l	d0
	qcmove.b	(a3)+,d0
	subq.w	#1,d0
cop1:
 qmove.b (a3)+,d1
 qmove.b d1,(a2)+
 addq.l #1,char_count(a5)
 qdbra.s d0,cop1

cop1end:
 qmove.b #13,(a2)+ 	 *and cr in text
 addq.l #1,char_count(a5)
 	addq.l	#2,line_count(a5)
 movea.l file_pos1(a5),a0 	*get our file position
 bra scan_next_inc 	*and carry on with the top level file.
 
 
copy_line:	clr.l	d6	in string flag
cl1:	bsr	skip_space_runs
	qmove.b d0,(a2)+
 addq.l #1,char_count(a5) 	*inc length of source
 cmpi.b #13,0-1(a2) 	*have we copied the cr?
 beq scan_next_inc 	*yup
 tst.b	0-1(a2) 	*is it an eof?
 beq scan_next_inc
 bra.s cl1

**here weve found eof so copy the last line 
includs_done:
 qmove.b (a0)+,(a2)+
 addq.l #1,char_count(a5)
 tst.b	0-1(a2)
 bne.s includs_done
 movea.l source_buff(a5),a2
 clr.l d0
 rts 		*now we have the complete file
includ_err:
 moveq #-1,d0
 rts_	"find_inc"
	align
*****************************************************************************
  

******************level 2 subs follow*********************
***read2 reads in the first level include files
read2:
;	tst.w	building?(a5)
;	bne.s	skip_frig

	addq.w	#1,incs_counter(a5)
;skip_frig:
 	move.l file_buff2(a5),long_var(a5)	*read in file here
 	qmove.l	a2,-(sp) 	*save source buffer position
	btst	#5,flags6(a5)	*search global incs?
	beq.s	norm_read_1	*no

**call ccp to find globinc file
	subq.w	#1,incs_counter(a5)	*cause it'll be added, but we dont see globincs
	qmove.l	#100,d0			*a_find this file
	qmoveq	#1,d1			*user header
	lea	inc_f_name(pc),a1
	move.l	a1,d2			*the name
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	qmove.l	(a0),a0			*0=error, 4=*fsspec
	qmove.l	(a0),d0
**copy to output so we can dispose our pb safely
	move.l	4(a0),a0		*the fsspec
	qmove.l	a0,-(sp)
	qmove.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0
	move.l	(sp)+,a0
	bra.s	doneg1	
norm_read_1:
	btst	#7,flags6(a5)
	beq.s	norm_read1a
**includeh
	qmove.l	#100,d0			*a_find this file
	qmoveq	#2,d1			*low level defs
	lea	inc_f_name(pc),a1
	qmove.l	a1,d2			*the name
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	move.l	(a0),a0			*0=error, 4=*fsspec
	qmove.l	(a0),d0
**copy to output so we can dispose our pb safely
	move.l	4(a0),a0		*the fsspec
	qmove.l	a0,-(sp)
	move.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0
	move.l	(sp)+,a0
	bra.s	doneg1
norm_read1a:
**call ccp to find globinc file
	qmove.l	#100,d0			*a_find this file
	qmoveq	#1,d1			*sinc then all
	lea	inc_f_name(pc),a1
	qmove.l	a1,d2			*the name
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	move.l	(a0),a0			*0=error, 4=*fsspec
	qmove.l	(a0),d0
**copy to output so we can dispose our pb safely
	move.l	4(a0),a0		*the fsspec
	qmove.l	a0,-(sp)
	move.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0
	move.l	(sp)+,a0
	bra.s	doneg1	
doneg1:
**fsspec in a0
	save_all
	addq.l	#6,a0
	move.l	incldes_h(a5),a1
	move.l	(a1),a1
	add.l	#68,a1	*number of incs and primary filename goes here
	qmove.l	tot_number_of_includes(a5),d0
	mulu.l	#64,d0
	add.l	d0,a1
	qmoveq	#64,d2
	OSBlockMoveData	a0,a1,d2
	inc.l	tot_number_of_includes(a5)
	restore_all
	bsr	readit 	*read in the includ file to buffer 2
 	movea.l	(sp)+,a2
 	tst.l	d0
	bge.s	find_includs2
	moveq	#-1,d0
	rts

find_includs2:
 movea.l file_buff2(a5),a0 	*a0->includ file
scan_next_inc2:
 lea includ_t(pc),a1 	*what we're looking for
 bsr scan_includs 	*process this line
 tst.w d0
**scan includes can return:
**0=no includes
**1=inlcude found
**-1=eof

 beq copy_line_2
 bmi includs_done2

**here we've found an include
*skip spaces and tabs to get to file name
 lea fname_store(pc),a3
 qmove.l a2,-(sp) 	 *now copy this file name
 lea inc_f_name(pc),a2
cincfn:
 move.b (a2)+,d0
 beq.s cincfnend
 move.b d0,(a3)+
 bra.s cincfn
cincfnend:
 qmove.b #13,(a3)+ 	 *cr
 clr.b (a3) 	*terminate

 movea.l (sp)+,a2 	8restore src pointer
 qmove.b #13,(a2)+
 qmove.b #"$",(a2)+
 addq.l #2,char_count(a5)
 subq.l #1,a0

find_name2:
 addq.l #1,a0
 cmpi.b #32,(a0) 	*space?
 beq.s find_name2
 cmpi.b #9,(a0)  	*tab?
 beq.s find_name2
*now a0 points to start of file name
 movea.l a0,a4  	*save position in this file
 lea inc_f_name(pc),a0 	*now copy the file name
	addq.l	#1,a0

copy_inc_f_name2:
 move.b (a4)+,d0
 beq.s copy_f_end2	*eof
 cmpi.b #13,d0 	*cr?
 beq.s copy_f_end2
 cmpi.b #32,d0 	*space?
 beq.s copy_f_end2
 cmpi.b #9,d0 		*tab?
 beq.s copy_f_end2
 move.b d0,(a0)+ 	*inc f name
 move.b d0,(a2)+ 	*$text
 addq.l #1,char_count(a5)
 bra.s copy_inc_f_name2
copy_f_end2:
 clr.b	(a0) 	*terminate filename
**insert count byte to start of filename
**find length
	lea	inc_f_name(pc),a0
	addq.l	#1,a0
	qmoveq	#-1,d1
fle2:	 addq.l	#1,d1
	tst.b	(a0)+
	bne.s	fle2
	lea	inc_f_name(pc),a0
	qmove.b	d1,(a0)			****320

 qmove.b #13,(a2)+
 addq.l #1,char_count(a5)
 	addq.l	#1,line_count(a5)
*now find eol
find_eol2:
 subq.l #1,a4 		*in case theres no comment! 
 cmpi.b #13,(a4)+
 beq.s got_eol2
 tst.b	(a4)+
 bne.s	find_eol2
got_eol2:
 qmove.l a4,file_pos2(a5) 	 *save our position in this file
 lea inc_f_name(pc),a0
 bsr.s read3 	  	    *process 2nd includ filename
 bge.s	read3_ok
 moveq	#-1,d0
 rts
read3_ok:
 qmove.b #13,(a2)+
 qmove.b #"$",(a2)+
 addq.l #2,char_count(a5)

 lea fname_store(pc),a3
; addq.l	 #6,a3
;	clr.l	d0 
	qcmove.b	(a3)+,d0
	subq.w	#1,d0
cop2:
 qmove.b (a3)+,d1
 qmove.b d1,(a2)+
 addq.l #1,char_count(a5)
 qdbra.s d0,cop2
 move.b #13,(a2)+ 	*and cr in text
 addq.l #1,char_count(a5)
 	addq.l	#2,line_count(a5)

 movea.l file_pos2(a5),a0 	*get our file position
 bra scan_next_inc2 	*and carry on with the top level file.
 
copy_line_2:	clr.w	d6	clear string toggle flag
cl2:	bsr	skip_space_runs	*skip over space/tabs in a run
 qmove.b d0,(a2)+
 addq.l #1,char_count(a5) 	*inc length of source
 cmpi.b #13,0-1(a2) 	*have we copied the cr?
 beq scan_next_inc2 	*yup
 tst.b	0-1(a2) 	*is it an eof?
 beq scan_next_inc2
 bra.s cl2
 
**here weve found eof so copy the last line 
includs_done2:
 qmove.b (a0)+,(a2)+
 addq.l #1,char_count(a5) 	*inc size of file
 tst.b	0-1(a2)
 bne includs_done2
 qmove.b #13,0-1(a2) 	 *replace char 0 with cr
 clr.l d0
 rts_	"fnd_inc2"
	align
**************************************************************************
***read3 reads in the second level include files
read3:
;	tst.w	building?(a5)
;	bne.s	skip_frig2
;	addq.w	#1,incs_counter(a5)
;skip_frig2:
 move.l file_buff3(a5),long_var(a5)
 qmove.l a2,-(sp) 	 *save source buffer position
	btst	#5,flags6(a5)	*includeg?
	beq.s	norm_read_2	*no
**inc_fname(pc) has name
**make temp_fsspec from gi fsspec, check and if not found use headers

	lea	inc_f_name(pc),a1	 
	lea	global_incs_fsspec(a5),a0
	bsr.l	  make_temp_fsspec
	lea	temp_fsspec(a5),a0	  
	cmpi.w	#$ffd5,d0
	bne.s	doneg2
	
	lea	inc_f_name(pc),a1	 
	lea	headers_fsspec(a5),a0
	bsr.l	  make_temp_fsspec
	lea	temp_fsspec(a5),a0
	bra.s	doneg2

norm_read_2:
	btst	#7,flags6(a5)
	beq.s	norm_read2a
	lea	inc_f_name(pc),a1	 
	lea	headers_fsspec(a5),a0
	bsr.l	make_temp_fsspec
	lea	temp_fsspec(a5),a0	  
	bra.s	doneg2

**inc_fname(pc) has name
**make temp_fsspec from source fsspec
norm_read2a:

	lea	inc_f_name(pc),a1	 
	lea	assembler_source_fsspec(a5),a0
	bsr.l	make_temp_fsspec
	lea	temp_fsspec(a5),a0	  
doneg2:
	bsr	readit 	*read in the includ file to buffer 2
 movea.l (sp)+,a2
 	tst.l	d0
 bge.s	find_includs3
 moveq	#-1,d0
 rts
find_includs3:
 movea.l file_buff3(a5),a0 	*a0->includ fiel
scan_next_inc3:
 lea includ_t(pc),a1 	*what we're looking for
 bsr scan_includs 	*process this line - 0 not found
 tst.w d0
**scan includes can return:
**0=no includes
**1=inlcude found - error in this case
**-1=eof
 beq.s copy_line_3
 bmi.s includs_done3

**here we've found an include
*we only allow 3 levels of inclde, so a 4th is an error
; bset #7,flags(a5) 	 *error detected flag
	st	global_err(a5)
 lea includ_error_t(pc),a0
 bsr.l printit
 moveq #-1,d0
 rts
 
copy_line_3:	clr.l	d6
cl3:	bsr.s	skip_space_runs
 qmove.b d0,(a2)+
 addq.l #1,char_count(a5) 	*inc length of source
 cmpi.b #13,0-1(a2) 	*have we copied the cr?
 beq scan_next_inc3 	*yup
 tst.b	0-1(a2) 	*is it an eof?
 beq scan_next_inc3
 bra.s cl3

 
**here weve found eof so copy the last line 
includs_done3:
 
 qmove.b (a0)+,(a2)+
 addq.l #1,char_count(a5) 	*inc total size of file
 tst.b	0-1(a2)
 bne.s includs_done3
 qmove.b #13,0-1(a2) 	 *replace char 0 with cr
 clr.l d0
 rts_	"fnd_inc3"
	align
************************************************************************
skip_space_runs:
	qmove.b	(a0)+,d0	get char
	cmpi.b	#$0a,d0	lf?	*v1.01
	beq.s	skip_space_runs
	cmpi.b	#$22,d0
	beq.s	tog	toggle in string flag
	tst.w	d6
	beq.s	ssr_ok
	rts_	"skip_spc"
	align
ssr_ok:	cmpi.b	#32,d0
	beq.s	got_spc
	cmpi.b	#9,d0
	beq.s	got_spc
	rts
got_spc:	qmoveq	#32,d0	if we came here from tab, make space
	cmpi.b	#32,(a0)	space
	beq.s	skip_space_runs
	cmpi.b	#9,(a0)	tab
	beq.s	skip_space_runs
	rts
tog:	eori.w	#1,d6
	rts_	"skip_spc"
	align	 
***scan_includes needs:
***a0>file_bufferx
***a1>'include'

scan_includs:
	addq.l	#1,line_count(a5) 	*add 1 to line counter
	clr.l	d0	*found_flag
	move.l	a0,a4
**find start of text on this line
	tst.b	(a0)
	beq	eof_inc	*found eof
	cmpi.b	#13,(a0)
	beq	blank_line
	cmpi.b	#"*",(a0)
	beq	comment_line
	cmpi.b	#$3b,(a0)	unconverted text here!
	beq	comment_line
find_sot:	qcmove.b	(a0)+,d1
	cmpi.l	#10,d1
	beq	find_sot	ignore lfs! (thanks timothy)
	cmpi.l	#" ",d1
	beq.s	find_sot
	cmpi.l	#9,d1
	beq.s	find_sot
	subq.l	#1,a0	
	cmpi.b	#"I",0(a0)
	bne	end_line
	cmpi.b	#"N",1(a0)
	bne	end_line
	cmpi.b	#"C",2(a0)
	bne	end_line
	cmpi.b	#"L",3(a0)
	bne	end_line
	cmpi.b	#"U",4(a0)
	bne	end_line
	cmpi.b	#"D",5(a0)
	bne	end_line	
	cmpi.b	#"E",6(a0)
	bne	end_line
	cmpi.b	#":",7(a0)	in case we have a label called include!
	beq	end_line
	qbclr	#7,flags6(a5)	set if headers inc
	qbclr	#5,flags6(a5)	set if a global inc
	cmpi.b	#"G",7(a0)
	bne.s	not_global1	*check for h (header)
	qbset	#5,flags6(a5)
	bra.s	not_global
not_global1:

	cmpi.b	#"H",7(a0)
	bne.s	not_global
	qbset	#7,flags6(a5)
		
not_global:
	move.l	a4,a0
si1:	movea.l a0,a4 	*save buffer pos
	movea.l a1,a3 	*save pattern
	qcmove.b 0(a0),d1 	  *check for comment line!
	cmpi.l #$3b,d1		semi colon?
	beq comment_line
	cmpi.l #10,d1 	*lf?
 	bne.s si_loop
	addq.l #1,a0 		*just skip lfs!
	bra.s si1

si_loop:
	movea.l a3,a1 	*reset pattern
next_lett:
	clr.l	d1
	move.b (a0)+,d1 	*get source
	beq eof_inc 		     *found eof
**now convert character to upper case
	cmpi.l #$60,d1 	*if less than _ then it is upper case
	ble.s is_upper 
	subi.l #$20,d1 	*make upper case
	move.b d1,0-1(a0) 	*save it back in file, so all is upper case
is_upper:
	move.b (a1)+,d2 	*get letter of pattern
	beq.s end_si 	*end of pattern
	cmp.b d1,d2
	beq.s next_lett 	*keep looking
	cmpi.l #13,d1 	*end of line?
	beq.s end_line
	bra.s si_loop

end_si:
	moveq #1,d0 		*found
	rts_	"scan_inc"
	align 
end_line: 
	cmpi.b	#"i",0(a0)	*v4 - check for lower case include (g)
	bne.s	end_line1
	cmpi.b	#"n",1(a0)
	bne.s	end_line1
	cmpi.b	#"c",2(a0)
	bne.s	end_line1
	cmpi.b	#"l",3(a0)
	bne.s	end_line1
	cmpi.b	#"u",4(a0)
	bne.s	end_line1
	cmpi.b	#"d",5(a0)
	bne.s	end_line1	
	cmpi.b	#"e",6(a0)
	bne.s	end_line1
	cmpi.b	#":",7(a0)	in case we have a label called include!
	beq.s	end_line1
	qbclr	#7,flags6(a5)
	qbclr	#5,flags6(a5)	set if a global inc
	cmpi.b	#"g",7(a0)
	bne.s	not_global10
	qbset	#5,flags6(a5)
	bra	not_global
not_global10:
	cmpi.b	#"h",7(a0)
	bne	not_global
	qbset	#7,flags6(a5)
	bra	not_global
end_line1:
	movea.l a4,a0 	*reset to start of line
	rts

eof_inc:
 tst.b (a0) 		*found a 0
 bne.s end_line 		*not really eof!
 movea.l a4,a0 	*reset to start of line
 moveq #-1,d0 		*tell caller eof!
 rts
 
blank_line:
**blank lines wont be included
 movea.l a4,a0
 rts
 
comment_line:
**comments wont be included
 movea.l a4,a0
 rts
 
fname_store: ds.b 40 	*callers name stored here
***************************************************************************
includ_t:	dc.l	$494e434c
	dc.b	$55,$44,$45,0	"include"
includ_error_t:	dc.b	"Includs nesting limited to 3.",13,0
	align
	global	find_includs
	extern	do_alert,readit,printit,gi_directory,p_directory
	extern	set_directory,make_temp_fsspec,send_2
	extern_data	inc_f_name