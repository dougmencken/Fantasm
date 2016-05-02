*********************************************************************
*MODULE:	GP ROUTINES			*
*DATE:	060294/070694			*
*PROGRAMMER:	S. BALL			*
*VERSION:	2			*
*DESCRIPTION:	ALL THE GENERAL ROUTINES THAT WOULDNT FIT ANYWHERE   *
*********************************************************************
reg_stand_out:	equ	"`"

****get size examines the contents of a4 and sets d0 accordingly
****where a4 points to l/w/b
****returns d0=1=byte,2=long,3=word
get_size:
 tst.b	-1(a4) 	*cause a4 is incd to skip .
 bne.s not_no_size
 moveq #3,d0 		*no size given so make word
 rts
not_no_size:
 cmpi.b #"B",(a4)
 bne.s not_byte
 moveq #1,d0
 rts
not_byte:
 cmpi.b #"W",(a4)
 bne.s not_word
 moveq #3,d0
 rts
not_word:
 cmpi.b #"L",(a4)
 bne.s check_short 	*bsr.s?
 moveq #2,d0
 rts
check_short:
 cmpi.b #"S",(a4)
 bne.s size_error_g
 moveq #1,d0
 rts_	"get_size"
 	align
****get size examines the contents of a4 and sets d0 accordingly
****where a4 points to l/w/b
****returns d0=0=byte,1=word,2=long
get_size12:
 tst.b	-1(a4) 	*cause a4 is incd to skip .
 bne.s not_no_size12
 moveq #1,d0 		*no size given so make word
 rts
not_no_size12:
 cmpi.b #"B",(a4)
 bne.s not_byte12
 moveq #0,d0
 rts
not_byte12:
 cmpi.b #"W",(a4)
 bne.s not_word12
 moveq #1,d0
 rts
not_word12:
 cmpi.b #"L",(a4)
 bne.s check_short12 	*bsr.s?
 moveq #2,d0
 rts
check_short12:
 cmpi.b #"S",(a4)
 bne.s size_error_g
 moveq #0,d0
 rts_	"get_sz12"
	align 
size_error_g:	lea	invalid_s_text(pc),a0
	bsr	pass2_error
	move.l	#$3,d0 	*make word anyway
	rts
 

	
	
**printnum_long_mem prints a signed 32 bit number to memory in a2
**printnum_word prints do as a signed long
printnum_long_mem:
	tst.l	d0
	bge.s	pnm
	qmove.b	#"-",(a2)+
	neg.l	d0	make plus
	
**printnum prints a 32 bit number held in d0
**limited to 1e7
**uses commas for seperators.
pnm:
**find size of number to quash leading zeros
	cmpi.l	#$ffff,d0
	bgt.s	print_long_m	long word print
	qmoveq	#0,d6
	qmove.w	d0,d6
	cmpi.l	#10,d6
	blt.s	do_units_m
	cmpi.l	#100,d6
	blt.s	do_tens_m
	cmpi.l	#1000,d6
	blt.s	do_huns_m
	cmpi.l	#10000,d6
	blt.s	do_thou_m
**now divide by relevant	units
long_ent_m:	divs	#10000,d6	get tens of thoudsands
	bsr.s	convert_m	print number of tens of thousands
do_thou_m:	divs	#1000,d6	get thousands
	bsr.s	convert_m	etc
do_huns_m:	divs	#100,d6
	bsr.s	convert_m
do_tens_m:	divs	#10,d6
	bsr.s	convert_m
do_units_m:	bsr.s	convert_m
	rts
convert_m:	addi.b	#48,d6	make character	(ascii)
	qmove.b	d6,(a2)+
	clr.w	d6
	swap	d6
;	swap	d6
;	andi.l	#$ffff,d6
	rts

**print long print do.l
**limited to 1e7 (10meg)
print_long_m:	cmpi.l	#9999999,d0
	bgt	numb_error1
	qmove.l	d0,d1
	qmove.l	d0,d6
	cmpi.l	#9,d0
	ble	do_units_m
	cmpi.l	#99,d0
	ble	do_tens_m
	cmpi.l	#999,d0
	ble	do_huns_m
	cmpi.l	#9999,d0
	ble	do_thou_m
	cmpi.l	#99999,d0
	ble.s	do_ten_thou_m
	cmpi.l	#999999,d0
	ble.s	do_hund_thou_m

	qmove.l	#1000000,d0	get millions
	bsr	long_div	divide d1.l by d0.l with remainder in d0
	addi.b	#"0",d1
	qmove.b	d1,(a2)+
	qmove.l	d0,d6
	qmove.l	d6,d1
do_hund_thou_m:	qmove.l	#100000,d0	 get 100 thousands
	bsr	long_div
	addi.b	#"0",d1
	qmove.b	d1,(a2)+
	qmove.l	d0,d6
	cmpi.l	#$ffff,d6	<65536?
	blt	long_ent_m	yes, print word routine
	qmove.l	d6,d1	no,get 10thousands
do_ten_thou_m:	qmove.l	#10000,d0
	bsr	long_div
	addi.b	#"0",d1
	qmove.b	d1,(a2)+
	qmove.l	d0,d6
	andi.l	#$ffff,d6
	bra	do_thou_m
		    
numb_error1:
	qmove.l	#"Too ",(a2)+
	qmove.l	#"big!",(a2)+
	rts
	
**compare_strings compares a2 with a3.
**returns d0=0 if match, else -1 if no match
*8strings must be termd in 0	
compare_strings:	
	bsr.l	strcmp		*c lib func
	rts_	"cmp_strs"
	align	 
**this gets two strings from a1. the strings should be seperated by a comma
**puts first string in a2, second in a3
get_two_strings:
	tst.b	(a1)
	beq.s	gtt_err_1	*no string 1
	cmpi.b	#$22,(a1)	*check "
	bne.s	gtt_err_2
	addq.l	#1,a1	*skip quotes
copy_1st_str:	move.b	(a1)+,d0
	beq.s	gtt_err_4	*end of field!
	cmpi.b	#0x2c,d0
	beq.s	gtt_err_2	*comma found before end quotes
	cmpi.b	#$22,d0
	beq.s	got_str_1
	qmove.b	d0,(a2)+
	bra.s	copy_1st_str
got_str_1:	clr.b	(a2)
	cmpi.b	#0x2c,(a1)+	must be "str1","str2"
	bne.s	gtt_err_3
	
	tst.b	(a1)
	beq.s	gtt_err_1	*no string 1
	cmpi.b	#$22,(a1)	*check "
	bne.s	gtt_err_2
	addq.l	#1,a1	*skip quotes
copy_2nd_str:	move.b	(a1)+,d0
	beq.s	gtt_err_4	*end of field!
	cmpi.b	#0x2c,d0
	beq.s	gtt_err_2	*comma found before end quotes
	cmpi.b	#$22,d0
	beq.s	got_str_2
	qmove.b	d0,(a3)+
	bra.s	copy_2nd_str
got_str_2:	clr.b	(a3)
	rts_	"get2strs"
	align
	
gtt_err_1:	qmove.l	a0,-(sp)
	lea	gtt_err1_text(pc),a0
	bsr	pass1_error
	qmove.l	(sp)+,a0
	rts
gtt_err_2:	qmove.l	a0,-(sp)
	lea	string_text(pc),a0
	bsr	pass1_error
	qmove.l	(sp)+,a0
	rts
gtt_err_3:	qmove.l	a0,-(sp)
	lea	gtt_err2_text(pc),a0
	bsr	pass1_error
	move.l	(sp)+,a0
	rts
gtt_err_4:	qmove.l	a0,-(sp)
	lea	gtt_err3_text(pc),a0	*end of field!
	bsr	pass1_error
	move.l	(sp)+,a0
	rts_	"gt2s_err"
	align

***gp_search searches a1 for a4.
***a1 is a list of strings, seperated by 0 and terminated in 0
***the strings may be any length and terminated in either . or 0
***returns in d0 if found else -1
gp_search:
 move.l a4,a3 	*save string
 qmoveq #-1,d0
 qmoveq #".",d7 	*strings terminated with either 0 or "."
next:
 tst.b (a1)
 beq.s not_found
 addq.l #1,d0 		*counter
compare:
 move.b (a4)+,d1
 beq.s end_string
 cmp.b d7,d1 		*string can also be terminated in .
 beq.s end_string
 cmp.b (a1),d1
 bne.s skip_it 		*no match
 addq.l #1,a1
 bra.s compare
end_string:
 tst.b (a1)+
 beq.s found_it
skip_it:
 movea.l a3,a4 	*reset search string
sig_loop:
 tst.b (a1)+ 	*find end of word in list
 bne.s sig_loop
 bra.s next
not_found:
 moveq #-1,d0
found_it:	rts_	"gp_searc"
	align
***dir_search searches a1 for a4.
***a1 is a list of strings, seperated by 0 and terminated in 0
***the strings may be any length
***returns in d0 if found else -1
;dir_search_quick:
;**Make a1 upper case in directive_upper
;ds_to_upper:
;	 lea	 directive_upper(pc),a3
;dstu1:	clr.l	 d0	 *Do this unsigned
;	 move.b	(a4)+,d0
;	 beq.s	 end_toupper
;	 cmpi.b	#"a",d0
;	 blt.s	 skip_upper	 *If upper or symbol ignore
;	 subi.b	#32,d0		 *MAke upper
;skip_upper:	 move.b	d0,(a3)+
;	 bra.s	 dstu1
;end_toupper:
;	 clr.b	 (a3)
;	 lea	 directive_upper(pc),a4

dir_search:	move.l a4,a3 	*save string
	moveq #-1,d0
nextd:	tst.b	(a1)
	beq.s	not_foundd
	addq.l	#1,d0 		*counter
compared:	move.b	(a4)+,d1
	beq.s	end_stringd
	cmp.b	(a1)+,d1
	bne.s	skip_itd 		*no match
	bra.s	compared

end_stringd:	tst.b (a1)+
	beq.s found_itd
skip_itd:	movea.l a3,a4 	*reset search string
si_loopd:	tst.b	-1(a1)
	beq.s	nextd
	tst.b (a1)+ 		*find next word in list
	bne.s si_loopd
	bra.s nextd
not_foundd:	moveq #-1,d0
found_itd:
	tst.l	d0
	rts_	"dir_serc"
	align


***dir_search searches a1/a6 for a4.
***
***a1 is a bytes list terminated in 0, a6 is a 16 byte padded string list. 
***returns in d0 if found else -1
dir_search_quick:
	lea	directive_upper(pc),a3
	qmoveq	#0,d0
	qmove.l	d0,(a3)
	qmove.l	d0,4(a3)
	qmove.l	d0,8(a3)
	qmove.l	d0,12(a3)
	qmove.l	d0,d6			; Improved Key: RP 170198
**Make a1 upper case in directive_upper
;ds_to_upper
;	 lea	 directive_upper(pc),a3
;dstu1:	clr.l	d0	*Do this unsigned
dstu1:	move.b	(a4)+,d0
	beq.s	end_toupper
	cmpi.b	#"a",d0
	blt.s	skip_upper	*If upper or symbol ignore
	subi.b	#32,d0		*MAke upper
skip_upper:	qmove.b	d0,(a3)+
	add.l	d0,d6			; Improved Key: RP 170198
	bra.s	dstu1
end_toupper:
;	clr.b	(a3)
	lea	directive_upper(pc),a4
	lea	-16(a6),a6

	qmove.l	a1,d7
next_directive:
; Improved Key: RP 170198	 qmove.b	(a4),d1		 	 ; source byte
next_first_char:
	lea	16(a6),a6		; next one in full string list as well
	move.b	(a1)+,d0		; byte from byte list
	beq.s	end_of_list_and_not_found
; Improved Key: RP 170198	 cmp.b	 d0,d1
	cmp.b	d0,d6		; Improved Key: RP 170198
	bne	next_first_char

; let check rest of string
	qmove.l	(a4),d1
	cmp.l	(a6),d1
	bne	next_directive
	qmove.l	4(a4),d1
	cmp.l	4(a6),d1
	bne	next_directive
	qmove.l	8(a4),d1
	cmp.l	8(a6),d1
	bne	next_directive
	qmove.l	12(a4),d1
	cmp.l	12(a6),d1
	bne	next_directive

	qmove.l	a1,d0
	sub.l	d7,d0
	subq.l	#1,d0
	bra.s	found_it_dir
	
end_of_list_and_not_found:
	moveq.l	#-1,d0
found_it_dir:
	rts_	"dir_search_quick"
	align

**find size used to live here

**pass1_error prints the file and linenumber, follwed by the line, followed
**by an error string.
**needs error string in a0
pass1_error:
 btst #1,flags(a5)
 bne.s not_now1 		*only report on pass 1
pass_all_error:
**we only print upto 6 errors on screen
	save_all
 	addq.w #1,error_count(a5) 	*inc total number of errrors
**510a17 - if error_count>16 then stop
	cmpi.w	#16,error_count(a5)
	blt.s	no_stop
;	bset	#4,flags2(a5)	*clear fatal error flag
	qmove.b	#1,abort(a5)	

no_stop:
 	qmove.l a0,-(sp) 	 *save string
; bset #7,flags(a5) 	 *error detected flag
	st	global_err(a5)
	qmove.l	a0,d0
	qmove.l	d0,error_string_save(a5)
	bsr print_line
	movea.l (sp)+,a0
	btst	#2,flags7(a5)	*short warning?
	beq.s	not_short2
	bsr	do_short
not_short2:	

 bsr printit
 bsr printcr
	restore_all
not_now1:
 rts_	"pass1_er"
	align 
**pass2_error prints the file and linenumber, follwed by the line, followed
**by an error string.
**needs error string in a0
pass2_error:

 btst #1,flags(a5)
 beq.s not_now 		*only report on pass 2
	save_all
	addq.w #1,error_count(a5)
;	bset #7,flags(a5) 	*error detected flag
	st	global_err(a5)
	qmove.l	a0,d0
	qmove.l	d0,error_string_save(a5)

	qmove.l a0,-(sp) 	 *save string
 	bsr print_line
	movea.l (sp)+,a0
	btst	#2,flags7(a5)	*short warning?
	beq.s	not_short1
	bsr	do_short
not_short1:	

 bsr printit
 bsr printcr
 	restore_all
not_now:	rts_	"pass2_er"
	align

pass1_advice:

	btst	#4,flags7(a5)
	beq.s	pass1_warning
	rts
**pass1_warning prints the file and linenumber, follwed by the line, followed
**by an error string.
**needs error string in a0
pass1_warning:
	btst #1,flags(a5)
	bne.s notw_noww 		*only report on pass 1
	btst	#1,flags7(a5)
	bne.s	notw_noww	*no warnings
 	save_all
	addq.w	#1,warning_count(a5)
 	qmove.l	a0,d0
	qmove.l	d0,error_string_save(a5)

	qmove.l a0,-(sp) 	 *save string
	bsr print_warning2	*print line without ***error***
	move.l (sp)+,a0

	btst	#2,flags7(a5)	*short warning?
	beq.s	not_short
	bsr.s	do_short
not_short:	
	bsr printit
	bsr printcr
 	restore_all
notw_noww:
	rts_	"pass1_warning"
	section
pass1_warning_always:
	btst #1,flags(a5)
	bne.s .notw_noww 	 	 *only report on pass 1
 	save_all
	addq.w	#1,warning_count(a5)
 	qmove.l	a0,d0
	qmove.l	d0,error_string_save(a5)

	qmove.l a0,-(sp) 	 *save string
	bsr print_warning2	*print line without ***error***
	movea.l (sp)+,a0

	btst	#2,flags7(a5)	*short warning?
	beq.s	.not_short
	bsr.s	do_short
.not_short:	
	bsr printit
	bsr printcr
 	restore_all
.notw_noww:
	rts_	"pass1_warning_always"

**truncates the string in a0 to the first . or !
do_short:
	lea	temp_string_warn(a5),a1
cs1:	move.b	(a0)+,(a1)+
	bne.s	cs1
	lea	temp_string_warn(a5),a0
**short warning, so find first full stop and insert a zero after
	move.l	a0,a1	*save start of string
find_stop:
	move.b	(a0)+,d0
	beq.s	stop_not_found
	cmpi.b	#".",d0
	beq.s	got_stop
	cmpi.b	#"!",d0
	beq.s	got_stop
	bra.s	find_stop
got_stop:
	clr.b	(a0)	*terminate string
stop_not_found:
	move.l	a1,a0
	rts_	"do_short"

pass2_advice:
	btst	#4,flags7(a5)
	beq.s	pass2_warning
	rts
		
**pass2_warning prints the file and linenumber, follwed by the line, followed
**by an error string.
**needs error string in a0
pass2_warning:
 btst #1,flags(a5)
 beq.s notw_now 		*only report on pass 2
 	btst	#1,flags7(a5)
 	bne.s	notw_now	*no warnings
 	save_all
 addq.w	#1,warning_count(a5)
 	move.l	a0,d0
	move.l	d0,error_string_save(a5)

 qmove.l a0,-(sp) 	 *save string
 bsr print_warning2	*print line without ***error***
 movea.l (sp)+,a0

	btst	#2,flags7(a5)	*short warning?
	beq.s	not_short3
	bsr	do_short
not_short3:	

 bsr printit
 bsr printcr
 	restore_all
notw_now:
	rts_	"pass2_warning"
 
*********************************************************************************
*name:	get_ops.s				*
*mother file:	fantasm2xx.s				*
*date:	011094				*
*programmer:	stuart ball				*
*description:	gets the op codes in source_op and dest_op - called from all 	*
*	instructions.				*
*input:	none - needs data in field3 terminated in zero		*
*output:	source_op and dest_op			*
*destroyed:	d4,d5,d7/a2,3,4				*
*********************************************************************************

get_ops:	qmove.l	d6,-(sp)	save d6
	lea	dest_op(a5),a2
	clr.w	(a2)	clear old field
	lea	source_op(a5),a2
	clr.w	(a2)	clear old field
	lea	field_3(a5),a3	input field
	qbsr	get_op	input in a3, o/p in a2, leaves a3 at end
	cmpi.b	#"{",-1(a3)
	beq.s	get_bf	check for bit field
	cmpi.b	#0x2c,-1(a3)
	bne.s	get_ops_end	no field 2
	lea	dest_op(a5),a2
bf_entry:	qbsr	get_op
	
get_ops_end:	qmove.l	(sp)+,d6
	rts_	"get_ops "
	align
get_bf:	lea	dest_op(a5),a2
	qmove.b	#"{",(a2)+
	bra.s	bf_entry

**gets upto 5 operands	
get_ops_ppc:
	qmoveq	#0,d1		*number of ops counter
	qmove.l	d6,-(sp)	save d6
	lea	dest_op(a5),a2
	qmove.l	d1,(a2)	clear old field
	lea	source_op(a5),a2
	qmove.l	d1,(a2)	clear old field
	lea	op_3(a5),a2
	qmove.l	d1,(a2)
	lea	op_4(a5),a2
	qmove.l	d1,(a2)
	lea	op_5(a5),a2
	qmove.l	d1,(a2)	
	lea	source_op(a5),a2	*do source op
	lea	field_3(a5),a3	input field
	tst.b	(a3)
	beq	get_ops_end

	qbsr.s	get_op	input in a3, o/p in a2, leaves a3 at end
	addq.l	#1,d1
	cmpi.b	#0x2c,-1(a3)
	bne.s	get_ops_end	no field 2

	lea	dest_op(a5),a2
	qbsr.s	get_op	
	addq.l	#1,d1
	cmpi.b	#0x2c,-1(a3)
	bne.s	get_ops_end	

	lea	op_3(a5),a2
	qbsr.s	get_op
	addq.l	#1,d1
	cmpi.b	#0x2c,-1(a3)
	bne.s	get_ops_end

	lea	op_4(a5),a2
	qbsr.s	get_op
	addq.l	#1,d1
	cmpi.b	#0x2c,-1(a3)
	bne	get_ops_end

	lea	op_5(a5),a2
	qbsr.s	get_op
	addq.l	#1,d1
	bra	get_ops_end
	rts_	"get_ops_ppc"
	align

**get_op needs i/p in a3, outputs to a2
**op can be terminated in 0,{
**QUICK bsr to this
get_op:
	qmove.l	#")",d6
	if 68k
	qmove.l	#$22,d7	quotes
	qmove.l	#0x28,d5
	qmove.l	#0x2c,d4	field terminator, or zero, or {
	endif
go_loop:
	qmoveq	#0,d0
	move.b	(a3)+,d0	get byte
	beq.s	go_end	end
	if	PPC
	macs_last
	cmpwi	cr0,r3,0x28
	cmpwi	cr1,r3,0x22
	cmpwi	cr2,r3,0x2c
	cmpwi	cr3,r3,"{"
	beq	cr0,brackets_loop
	beq	cr1,string_loop
	beq	cr2,go_end
	beq	cr3,go_end
	macs_first
	else
	cmp.l	d5,d0	(
	beq.s	brackets_loop	find end bracks
	cmp.l	d7,d0	"
	beq.s	string_loop	find eos
	cmp.l	d4,d0	comma
	beq.s	go_end
	cmpi.l	#"{",d0	{
	beq.s	go_end
	endif
	qmove.b	d0,(a2)+
	bra.s	go_loop
	
brackets_loop:	qmove.b	d0,(a2)+
brackets_lp1:	qcmove.b	(a3)+,d0
	move.b	d0,(a2)+
	beq.s	go_end	zero byte!
	cmp.l	d6,d0
	bne.s	brackets_lp1
	bra.s	go_loop
	
string_loop:	qmove.b	d0,(a2)+
string_lp1:	qcmove.b	(a3)+,d0
	cmpi.l	#0,d0
	beq.s	go_end
	qmove.b	d0,(a2)+
	cmp.l	#0x22,d0
	bne.s	string_lp1
	bra.s	go_loop
	
go_end:	clr.b	(a2)	terminate
	qrts
	align
**long div divides d1.l by d0.l
long_div:
	if	PPC
	divwu	r11,r4,r3	*int in r11
	mr	r12,r11	*Save int
**get remainder in r3
	mullw	r11,r11,r3
	subf	r3,r11,r4
	mr	r4,r12
	else
 tst.l  d0
 bne.s div
 divu.w     d0,d1
 rts
div:
 bpl.s do_div
 neg.l d0
 bsr.s do_div
 neg.l d1
 rts
do_div:
 tst.l d1
 bpl.s div_p
 neg.l d1
 bsr.s div_p
 neg.l d1
 neg.l d0
 rts
div_p:
 clr.l d3
 clr.l d2
div2:
 cmp.l d0,d1
 bls.s div1
 addq.l #1,d3
 lsl.l #1,d0
 bmi.s div3
 bra.s div2
div5:
 lsl.l #1,d2
 lsr.l #1,d0
div3:
 cmp.l d0,d1
div1:
 bcs.s div4
 sub.l d0,d1
 addq.l #1,d2
div4:
 dbf d3,div5
 move.l d1,d0
 move.l d2,d1
 endif
 rts_	"long_div"
 	align

**sets are identified by byte 31 of the name being set to -1
**reset_sets is called interpass the search out all such labels
**in equates and change the first char of the name to e5 so as not
*8to be defined.
reset_sets:
	move.l	equates(a5),a4	label names
	lea	31(a4),a2	sets have ff here
	move.l	equ_num(a5),d0	how many
	beq.s	reset_sets_end	noone....
;	ext.l	d0	better safe than sorry.
	subq.l	#1,d0	for dbra
reset_set_loop:	tst.b	(a2)
	bge.s	not_a_set
	qmove.b	#$e5,31(a4)	make label undefined, we can check in tree search
not_a_set:	lea	32(a2),a2
	lea	32(a4),a4
	qdbra	d0,reset_set_loop
reset_sets_end:	rts_	"reset_sets"

**called from get_mode (and ppc_asm) to replace register equates with actual registers
**expects operand in a3 terminated in 0
**has to copy the new operand back to a3 unfortunately
replace_requs:	qmove.l	d1,-(sp)	save instruction!
	lea	field_2_new(a5),a4
	qmove.l	a3,-(sp)	save address of field
rr_loop:	move.b	(a3)+,d0
	beq.s	rr_end	register names must not contain
	cmpi.b	#reg_stand_out,d0	the old cedilla ploy....
	bne.s	not_rr

	bsr.s	replace_register
	bra.s	rr_loop
	
not_rr:	qmove.b	d0,(a4)+
	bra.s	rr_loop
	
rr_end:	clr.b	(a4)	terminate
	lea	field_2_new(a5),a4	reset
	move.l	(sp)+,a3	restore original operand address
	move.l	a3,a2
rr_copy_back:	move.b	(a4)+,(a3)+	copy new string back
	bne.s	rr_copy_back
	move.l	a2,a3	a3 back to where it was, but register replaced
	qmove.l	(sp)+,d1
	rts_	"rep_requ"
	align
replace_register:
	lea	field_3_new(a5),a2	copy name to here
	qmoveq	#7,d0
	qmove.l	#0,d1
cf3n:	qmove.l	d1,(a2)+
	qdbra	d0,cf3n
	lea	field_3_new(a5),a2
	
do_rr:
	qmove.l	#0,d0
	move.b	(a3)+,d0	register names must not contain
	beq.s	not_rr1
	cmpi.l	#".",d0	a full stop
	beq.s	not_rr1
	cmpi.l	#" ",d0	a space
	beq.s	not_rr1
	cmpi.l	#0x2c,d0	a comma
	beq.s	not_rr1
	cmpi.l	#"*",d0	a multiply
	beq.s	not_rr1
	cmpi.l	#"/",d0
	beq.s	not_rr1	movem....
	cmpi.l	#0x28,d0	a open bracket (i know thats an)
	beq.s	not_rr1
	cmpi.l	#")",d0
	beq.s	not_rr1
	cmpi.l	#"}",d0	bfins
	beq.s	not_rr1
	cmpi.l	#":",d0	cas2
	beq.s	not_rr1
	cmpi.l	#"-",d0	movem....
	beq.s	not_rr1
	cmpi.l	#"[",d0
	beq.s	not_rr1	toc
	cmpi.l	#"]",d0
	beq.s	not_rr1	toc
	qmove.b	d0,(a2)+
	bra.s	do_rr
not_rr1:	subq.l	#1,a3	rewind
	lea	field_3_new(a5),a2
	qmove.l	a3,-(sp)
	bsr	search_requ	see if we can find it
	qmove.l	(sp)+,a3
	tst.w	d0
	bge.s	rr_ok
	lea	requ_text_1(pc),a0
	bsr	pass1_error
	rts_	"rep_reg "
	align
rr_ok:	move.l	requ_names_h(a5),a1
	move.l	(a1),a1
	ext.l	d0
	lsl.l	#5,d0
	add.l	d0,a1
**if its an address reg byte 28
**if its data reg byte 29 - both regs are +1
	tst.b	28(a1)
	beq.s	rr_not_addr

	cmpi.b	#16,28(a1)
	bge.s	ppc_gpr
	qmove.b	#"A",(a4)+
	qcmove.b	28(a1),d0
	subq.l	#1,d0
	add.l	#"0",d0
	qmove.b	d0,(a4)+
	rts_	"rr_ok   "
	align
ppc_gpr:
	qmove.b	#"R",(a4)+
;	clr.l	d0
	qcmove.b	28(a1),d0
	sub.l	#16,d0
	cmpi.l	#9,d0
	ble.s	just_unit
	divs	#10,d0
	add.b	#"0",d0
	qmove.b	d0,(a4)+
	swap	d0
just_unit:
	add.l	#"0",d0
	qmove.b	d0,(a4)+
	rts
	
rr_not_addr:	tst.b	29(a1)
	beq.s	rr_err_bad_reg
	cmpi.b	#16,29(a1)
	bge.s	ppc_fpr
	
	qmove.b	#"D",(a4)+
	qcmove.b	29(a1),d0
	subq.l	#1,d0
	add.l	#"0",d0
	qmove.b	d0,(a4)+
	rts_	"rr_nt_ad"
	align
ppc_fpr:
	qmove.b	#"F",(a4)+
	qcmove.b	29(a1),d0
	sub.b	#16,d0
	cmpi.b	#9,d0
	ble.s	just_funit
	divs	#10,d0
	add.b	#"0",d0
	qmove.b	d0,(a4)+
	swap	d0
just_funit:
	add.l	#"0",d0
	qmove.b	d0,(a4)+
	rts

rr_err_bad_reg:	lea	requ_text_2(pc),a0
	bsr	pass1_error
	rts
		
	
********************************************************************
 
************************************************************************
	align
op_buff:	ds.b	40 *where expressions get txd to evaluate
	align
requ_text_1:	dc.b	"Undefined register name.",13,0
requ_text_2:	dc.b	"Cant replace register due to bad register.",13,0
invalid_s_text:	dc.b	"Invalid size.",13,13,0

address_text:	dc.b	"Invalid address.",13,13,0
bad_reg_text:	dc.b	"Bad register number.",13,13,0
open_brack_text:	dc.b	"( expected.",13,13,0
close_brack_text:	dc.b	") expected.",13,13,0
comma_text_g:	dc.b	"Comma expected.",13,13,0
disp_16_text:	dc.b	"Displacement greater than 16 bits.",13,13,0
disp_8_text:	dc.b	"Displacement greater than 8 bits.",13,13,0
close_string:	dc.b	"Quotes expected.",13,13,0
gtt_err1_text:	dc.b	"Strings expected for operand.",13,13,0
gtt_err2_text:	dc.b	"Comma expected between strings.",13,13,0
gtt_err3_text:	dc.b	"End of field before operands defined.",13,13,0
	align
directive_upper:	ds.b	256
	align
	global	get_size,get_size12,size_error_g
	global	printnum_long_mem,print_long_m,compare_strings,get_two_strings
	global	gp_search,dir_search,pass1_error
	global	pass2_error,pass2_warning,get_op,long_div
	global	op_buff,invalid_s_text
	global	address_text,bad_reg_text,open_brack_text,disp_16_text
	global	disp_8_text,close_string,reset_sets
	global	replace_requs,close_brack_text,comma_text_g,get_ops
	global	pass1_warning,get_ops_ppc
	global	pass1_advice,pass2_advice,pass_all_error,pass1_warning_always
	global	dir_search_quick	*5.1a4
	
	extern	seventrec,aupdate,numb_error
	extern	print_line,printcr,printit,evaluate
	extern	search_requ,print_warning2
	extern	strcmp		*lib func
	extern_data	string_text