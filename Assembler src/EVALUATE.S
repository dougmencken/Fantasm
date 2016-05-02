*********************************************************************
*MODULE:	EVALUATE 					    *
*DATE:		180394						    *
*LAST MODIFIED:	010796						    *
*PROGRAMMER:	S.BALL						    *
*VERSION:	8						    *
*FANT REL VER:	406						    *
*DESCRIPTION:	RETURNS THE VALUE OF THE STRING IN A2 IN D0	    *
*V4 ALLOWS BRACKETS TO DEFINE PRECEDENCE IN IMMEDIATE DATA AND      *
*   EQUATES.                                                        *
*NUMBER OF EXPRESSIONS INCREASED TO 8                               *
*v6 USES *NEW* INTELLIGENT LABEL SEARCH. SEE LAB_SEARCH.S FOR DETAIL*
*2.07 - STRINGS - "A","A " ETC CAN BE USED SO LONG AS THEY ARE THE  *
*ONLY EXPRESSION IN THE EXPRESSION.		    *
*V7 ALLOWS THE USE OF 0x PREFIX FOR HEX NUMBERS FOR PPC		    *
*v8 allows the full use of strings in expressions		    *
*********************************************************************

**************************************************************
*EVALUATE RETURNS THE VALUE OF THE STRING POINTED TO BY A2 IN D0.
*PRESERVES A4,A3,A2,A1,A0
evaluate:
	qmove.l	a0,long_var(a5)	*save text position in case of error reporting
	movem.l	a0/a1/a2/a3/a4,-(sp)
	bsr.s	do_eval	*scan line for operators
	movem.l	(sp)+,a0/a1/a2/a3/a4
	rts

do_eval:
	qbclr #4,flags(a5) 	 *1 if value of label (not equates!) returned
	move.l a2,a3
	move.l a2,long_var(a5) 	*save string
got_equ:
	lea real_numbers(pc),a1	*where the values of the numbers are stored
	qmoveq #8,d6	 	 *counter for number of values in expression
next_numb:
	dec.l	d6
	beq	too_complicated	*we allow up to 8 expressions in one simple line

	movem.l	d6/a1,-(sp)
	bsr get_num		*get the first number in a3. returns d0
	movem.l	(sp)+,d6/a1
	tst.w d1		*d1 will be -ve if a label
	beq.s got_number 
	bgt numb_err_lab	*error in conversion
	bsr found_lab_e	*found a label in the string
got_number:
	move.l d0,(a1)+	*store the value of the number
	movea.l a0,a3		*a0 points to end of number from chk_num_term
	tst.b	(a3)+	*check operator
	bne.s next_numb		*get next number if not terminated

***now we have the numbers in real_numbers we have to find out what
*to do with them from the operators
*we have to calculate expressions using the right precedence which
*goes /*+- in that order

 movea.l long_var(a5),a3	*point to the equ string again
 lea code_val(a5),a4	*coded string
 lea real_numbers(pc),a1	*the numbers

*the coded string uses longs to define numbers and operators
*eg the format is long number,long operator etc 00000000,00000000

get_next_code:
 qmove.l (a1)+,(a4)+	 *move number to code
 bsr chk_num_term
 inc.l	a3		*skip operator
 extb.l d0		*terminator as long in d0
 qmove.l d0,(a4)+
 tst.b d0
 bne.s get_next_code
 
 
***code val now contains number.l, operator.l number.l op.l 00000000
*now we look for the operators in order of precedence.
*if we find the one we want we take the 1st number, the operator
*and the 2nd number. we perform the operation storing the result in
*the first number.
*then the remainder of code val is shifted up to overwrite the operator
*and the 2nd number. eventually we are left with just 1 number in 
*code val which is the result. 
*single numbers with no operators are terminated in 0.l and fall 
*through all the branches to the end of minus.

eval2_entry:		*eval 2 comes here when it has code val
 lea code_val(a5),a4	*reset a4 to start of code_val

***now we look for powers 
pwr_loop:	move.l	0(a4),d1	*get 1st number
	move.l	4(a4),d2	*get operator
	beq.s	end_pwr 	*all the pwrs done (mebbs!)
	qmove.l	8(a4),d3	*get 2nd number
	cmpi.b	#"^",d2	*pwr
	bne.s	not_pwr
	tst.l	d1
	beq.s	power_done	*zero
	tst.l	d3	*check for 2nd zero
	bne	not_zero
	moveq	#1,d1	*5.1a2 - if x^0 return 1
	bra.s	power_done	
not_zero:
**do power processing - power is in d3, number is in d1
	qmove.l	d1,d4
	subq.l	#2,d3
	bmi.s	power_done
do_pwr:	
	muls.l	d4,d1
	dec.l	d3
	bge.s	do_pwr	
power_done:	move.l	d1,0(a4)
	bsr	shift_code	*delete operator and 2nd digit
	bra.s	pwr_loop
not_pwr:	addq.l	#8,a4
	bra.s	pwr_loop	search out more powers
end_pwr:	lea	code_val(a5),a4	*reset a4 to start of code_val

***now we look for divs 
div_loop:
	qmove.l	0(a4),d1	*get 1st number
	move.l	4(a4),d2	*get operator
 beq.s end_div 		*all the divs done (mebbs!)
 move.l 8(a4),d3	*get 2nd number
 cmpi.b #"/",d2		*div
	bne.s	not_div
	tst.l	d3	*check for zero
	bne.s	no_zero	*just return divisor
	save_all
	bsr	div_by_zero
	restore_all
	bra.s	do_zero_err	*just insert
no_zero:
	divs.l	d3,d1		*note new 32 bit div!
do_zero_err:
 qmove.l d1,0(a4)
 bsr.s shift_code		*delete operator and 2nd digit
 bra.s div_loop
not_div:
 addq.l #8,a4
 bra.s div_loop
end_div:

 lea code_val(a5),a4	*reset a4 to start of code_val
***now we look for mutliplies
mult_loop:
 qmove.l 0(a4),d1	 *get 1st number
 move.l 4(a4),d2	*get operator
 beq.s end_mult
 qmove.l 8(a4),d3	 *get 2nd number
 cmpi.b #"*",d2		*mult?
 bne.s not_mult
	muls.l	d1,d3
 qmove.l d3,0(a4)	 *long result
 bsr.s shift_code		*delete operator and 2nd digit
 bra.s mult_loop
not_mult:
 addq.l #8,a4
 bra.s mult_loop
end_mult:

 lea code_val(a5),a4	*reset a4 to start of code_val
***now we look for plus's 
plus_loop:
 move.l 4(a4),d2	*get operator
 beq.s end_plus		*all the additions done (mebbs!)
 qmove.l 8(a4),d3	 *get 2nd number
 cmpi.b #"+",d2		*plus?
 bne.s not_plus
 add.l d3,0(a4)		add second to first
 bsr.s shift_code		*delete operator and 2nd digit
 bra.s plus_loop
not_plus:
 addq.l #8,a4
 bra.s plus_loop
end_plus:


 lea code_val(a5),a4
***now we look for minus's 
minus_loop:
* move.l 0(a4),d1	*get 1st number
 move.l 4(a4),d2	*get operator
 beq.s end_minus		*all the subtractions done (mebbs!)
 qmove.l 8(a4),d3	 *get 2nd number
 cmpi.b #"-",d2		*minus?
 bne.s not_minus
 sub.l d3,0(a4)
 bsr.s shift_code		*delete operator and 2nd digit
 bra.s minus_loop
not_minus:
 addq.l #8,a4
 bra.s minus_loop
end_minus:
***finally the result ends up in 0(a4), so we pass it back in d0
 move.l 0(a4),d0	*return the result of the expression
 rts
numb_err_lab:
 clr.l d0
 rts
 
shift_code:	movem.l	a0/a1,-(sp)
	lea	4(a4),a0	dest
	lea	12(a4),a1	source
sc_loop:
	qmove.l	(a1)+,(a0)+	shift operator
	qmove.l	(a1)+,(a0)+	shift operand
	tst.l	0-8(a0)	check operator
	bne.s	sc_loop	if not zero, then move next
	movem.l	(sp)+,a0/a1
	rts_	"evaluator"
************************************************************************************

***here we've found a label in the expression
found_lab_e:
***here a3 is at the start of the label in the equ string
***we need to return the value of the label in d0	
	movem.l	d6/a1,-(sp)
 qmove.l a3,d6	 	 *save start of label
 bsr chk_num_term	*find end of label and put in a0
 qmove.l d6,a3	*point to start of label
 qmove.l a0,-(sp)	 *save string position
	qmove.b	0(a0),scratch_2(a5)	get terminating character
	clr.b	0(a0)	terminate label correctly
	qmoveq #0,d1
	qmove.l d1,d0
p1_rept:	bsr	get_lab_value	*returns d0=value else d1=-1 for not found
	tst.w	d1
	bmi.s	equ_error	*labe not found
	qmove.l	(sp)+,a0
	qmove.b	scratch_2(a5),0(a0)	restore terminator
	movem.l	(sp)+,d6/a1
	rts_	"found_lab_e"
	align
equ_error:
	qbset	#6,flags2(a5)	*not defined flag for ifd and ifnd
	btst	#5,flags2(a5)	*errors off (for nd and d)?
	bne.s	return_nd	*yep
**if from dc.x we need to report the error on pass1
	btst	#2,flags8(a5)
	bne.s	from_dcx
	btst	#1,flags(a5)
	beq.s	return_nd	*pass 1 so dont eval for speed (unless rept)
from_dcx:
	move.l	scratch_1(a5),a0	label name
	bsr pass_all_error	*print errors on both passes!
	lea equ_err_text(pc),a0
	bsr.l	printit
return_nd:	clr.l d0
	move.l (sp)+,a0
	qmove.b	scratch_2(a5),0(a0)	restore number terminator
	movem.l	(sp)+,d6/a1
	rts_	"equ_error"


div_by_zero:
	lea	zero_div_text(pc),a0
	bsr	pass1_error
	rts
	 
too_complicated:
 lea comp_text(pc),a0	*print error
	bsr	pass1_error
 moveq #0,d0
 rts
**************************************************************************************
**do_long_str:	handles single expresisons in quotes - "abcd", or "abc ", or "a" etc
do_long_str:	addq.l	#1,a2	skip "
	clr.l	d0
	clr.l	d1	counter
dls_loop:	move.b	(a2)+,d2
	beq.s	dls_error	zero
	cmpi.b	#13,d2
	beq.s	dls_error
	cmpi.b	#$22,d2
	beq.s	dls_end
	lsl.l	#8,d0
	qmove.b	d2,d0
	inc.w	d1
	bra.s	dls_loop
dls_end:	cmpi.w	#4,d1
	bgt.s	dls_error_1	more than 4 chars
	rts_	"eval_long_str"
dls_error:	lea	dls_text1(pc),a0
	bsr	pass1_error
	moveq	#1,d1
	rts
dls_error_1:	lea	dls_text2(pc),a0
	bsr	pass1_error
	moveq	#1,d1	*error
	rts
	
***************************************************************************************
***************************************************************************************
****get num gets a number from a3.
****the number can be binary,hex or decimal. dec numbers can be preceded
****with -
****if the number doesnt start with a $,% or a char 0-9 or
****the pc identifier * then it may be a label so d1 is set to -1
****to indicate this.
****the number may also be a char string - like "cath"
****so itll return a longword result for these
****if theres an error in conversion then d1=1 else 0 
get_num:
	tst.b	(a3)
	beq.s	numb_expect	*no number?
**v7
	cmpi.b	#$22,(a3)	*string
	beq.s	get_string	*v4.06	
	cmpi.b	#".",(a3)
	beq.s	local_lab?
	cmpi.w	#"0x",(a3)
	bne.s	not_new_hex
	addq.l	#1,a3	*skip 0 to point to x
	bra.s	get_hex
not_new_hex:
	cmpi.w	#"0X",(a3)
	bne.s	not_new_hex1
	addq.l	#1,a3
	bra.s	get_hex
not_new_hex1:
	cmpi.b #"$",(a3)	*hex number?
	beq.s get_hex
	cmpi.b #"%",(a3)	*binary?
	beq get_bin
	cmpi.b #"9",(a3)	*first char a digit?
	ble get_dec		      *or sign?
*must be an equate or a label
*note a0 must point to end of label on exit!
local_lab?:
 moveq #-1,d1		*return -1 if label
 rts		*dont do them yet.
numb_expect:	lea	numb_b_err(pc),a0
	bsr	pass1_error
	moveq	#1,d1	tell eval to fail
	rts_	"get_number"

****numbers can be terminated in either [space], [tab], [cr], the four
****arithmetic operators, [(],[)],[,]. we use straight code to check
****for these for speed in a routine called chk_num_term
*to convert the number we need to remember the position of a2 (start),
*then move a2 to the terminator-1, then we can convert each character
*using the base mutliplier
get_string:
	inc	a3	*skip "
	clr.l	d0
	clr.l	d1	*los counter
gs_1:	move.b	(a3)+,d2
	beq.s	gs_err
	cmpi.b	#$22,d2
	beq.s	gs_end
	lsl.l	#8,d0
	qmove.b	d2,d0
	addq.l	#1,d1
	bra.s	gs_1
gs_end:
	move.l	a3,a0	
	cmpi.w	#4,d1
	bgt	dls_error_1
	clr.l	d1	*no error
	rts_	"eval_str"
gs_err:
	move.l	a3,a0
	bra	dls_error
	moveq	#1,d1
	rts
		
get_hex:
 qmove.l	a3,d1 start of number
 inc.l	a3		*skip $
 bsr chk_num_term	*find hex string terminator
	exg	d1,a3
	qmove.l	d1,d0	check length of number (8 chars max)
	sub.l	a3,d0
	cmpi.w	#9,d0
	bgt	number_error_hex
	bsr.s	convert_hex	   *make ascii 0-? (0-f really)
 rts_	"eval_hex"

get_bin:
 inc.l	a3		*skip %
 qmove.l a3,d1
 dec.l	d1
 bsr chk_num_term
 qmoveq #2,d2
 bsr conv_num
 tst.w	d1
 bgt.s	conv_num_failed
 clr.l	d1	*no error
 rts_	"eval_bin"

get_dec:
 clr.l d7
 cmpi.b #"-",(a3)	*-ve?
 bne.s not_m
 movea.l a3,a1	*delete -
 movea.l a3,a2
 inc.l	a3
del_min:
 move.b (a3)+,(a1)+
 bne.s del_min
 movea.l a2,a3	*delete -
 qmoveq #1,d7	 	 *set - flag
not_m:
 qmove.l a3,d1	 	 *save start of number in d1
 dec.l	d1		*we'll end when we get here
 bsr chk_num_term
 movea.l a3,a4		save end of this number
 qmoveq #10,d2	 	 *base multiplier
 bsr.s conv_num		*convert the string backwards into d0
 tst.w	d1
 bgt.s	conv_num_failed	
 qmoveq #0,d1
 tst.w d7		-ve flag
 beq.s get_dec_end
 neg.l d0		*make -ve
get_dec_end:	clr.l	d1
conv_num_failed:
 rts_	"eval_dec"

convert_hex:
	clr.l	d0	accumulator
ch_1:	inc.l	a3	next char
	cmp.l	a3,d1
	beq.s	ch_end	all done
	qmove.b	(a3),d2	get char
	cmpi.b	#"A",d2
	blt.s	ch_2	is a digit already
	cmpi.b	#"a",d2
	bge.s	lower_hex
	
	subq.b	#7,d2	make 10
	bra.s	ch_2
lower_hex:
	cmpi.b	#"f",d2
	bgt	number_error_hex1	bigger than "f"
	sub.b	#($61-$3a),d2		make 10
ch_2:	sub.b	#"0",d2	make digital
	bmi	number_error_hex1	-ve?
	cmpi.b	#$0f,d2
	bgt	number_error_hex1	bigger than f!
	lsl.l	#4,d0	shift ready
	or.b	d2,d0	mix in
	bra.s	ch_1
ch_end:	clr.l	d1	no error
	rts_	"convert_hex"
 
conv_num:
 clr.l d0		*clear accumulator (so old fashioned i know!)
 qmoveq #1,d3	 	 *multiplier accumulator
cn_loop:
 dec.l	a3
 cmp.l a3,d1		*reached start of string?
 beq.s cn_loop_end	*all done then.
 clr.l d4
 qmove.b (a3),d4		 *getcharacter

 subi.b #$30,d4		*make a real number
 bmi.s number_error_c	*shouldnt convert to <0
 cmp.b d4,d2
 ble.s number_error_c	*or be more than the base!
	mulu.l	d3,d4	*multiply number by base accumulator
 add.l d4,d0		*add result to accum
	mulu.l	d2,d3	*multiply base accum by base
 bra.s cn_loop
cn_loop_end
	clr.l	d1	*no error
 rts_	"conv_num"		*real numbr in d0
 
**caled only from eval
number_error:
 lea number_err_t(pc),a0
 bsr pass1_error
 qmoveq #0,d0
 qmoveq #1,d1	 	 *error
 move.l (sp)+,d6
 rts_	"number_error"
 
**called only from convert
number_error_c:
 lea number_err_t(pc),a0
 bsr pass1_error
 moveq #0,d0
 moveq #1,d1		*error
 rts

**called only from convert_hex
number_error_hex:
 lea number_err_h(pc),a0
 bsr pass1_error
 qmoveq #1,d0
	moveq	#1,d1
 rts
**called only from convert_hex
number_error_hex1:
 lea number_err_h1(pc),a0
 bsr pass1_error
 qmoveq #1,d0
	moveq	#1,d1
 rts
 
chk_num_term:
**406 - strings in expressions
	cmpi.b	#$22,(a3)
	bne.s	cnt1
	addq.l	#1,a3	*find end of string
feos:	move.b	(a3)+,d0
	beq.s	cnt_end
	cmpi.b	#$22,d0
	bne.s	feos
	
cnt1:
	clr.l	d0
 move.b (a3),d0		*get current character
 beq.s cnt_end		*terminated in zero
 if	PPC
	macs_last
 cmpwi	 cr0,r3,0x2c
 cmpwi	cr1,r3,32
 cmpwi	cr2,r3,9
 cmpwi	cr3,r3,13
 cmpwi	cr4,r3,"("
 cmpwi	cr5,r3,")"
 cmpwi	cr6,r3,"+"
 cmpwi	cr7,r3,"-"
 beq cr0,cnt_end
 beq cr1,cnt_end
 beq cr2,cnt_end
 beq cr3,cnt_end
 beq cr4,cnt_end
 beq cr5,cnt_end
 beq cr6,cnt_end
 beq cr7,cnt_end
 cmpwi	cr0,r3,"/"
 cmpwi	cr1,r3,"*"
 cmpwi	cr2,r3,"^"
 beq cr0,cnt_end
 beq cr1,cnt_end
 beq cr2,cnt_end
	macs_first
 else
 cmpi.l #0x2c,d0	*terminated in comma?
 beq.s cnt_end
 cmpi.b #32,d0
 beq.s cnt_end		*space
 cmpi.b #9,d0
 beq.s cnt_end		*tab
 cmpi.b #13,d0
 beq.s cnt_end
 cmpi.b #"(",d0
 beq.s cnt_end
 cmpi.b #")",d0
 beq.s cnt_end
 cmpi.b #"+",d0
 beq.s cnt_end
 cmpi.b #"-",d0
 beq.s cnt_end
 cmpi.b #"/",d0
 beq.s cnt_end
 cmpi.b #"*",d0
 beq.s cnt_end
 cmpi.b	#"^",d0	v2.00 pwr
 beq.s	cnt_end
 endif
 inc.l	 a3
 bra.s	chk_num_term
cnt_end:
 movea.l	a3,a0	*save the end of the number
 rts_	"chk_num_term"

***get lab value searches bith equ table and label table
***looking for a label. if it finds it, it sticks its value in d0
***and clears d1. if it doesnt then d1=-1
***needs the label to look for in label_search
get_lab_value:	
	qmove.l	a3,scratch_1(a5)	reset pos
		
**if ppc then check for ppc labs like cr,so etc
;	btst	#0,ppc_flags1(a5)
;	beq.s	not_un			*dont check ppc labs

	move.l	a3,a4
	lea	ppc_reserved_table(pc),a1	search equates
	bsr	dir_search 	*search a1 for a4 returns position in d0 or -1
;	tst.w	d0 
 	bmi.s	not_un	*-ve=not found else d0=position
 	lea	reserved_values(pc),a1
**LXT
	qpush1	a1
	add.w	d0,a1
	qmove.b	(a1),d0
	qpop1	a1
;	move.b	(a1,d0.b),d0
	extb.l	d0
	clr.l	d1
	rts_	"eval_ppc_reserved" 	   


not_un:			
**not_narg is the entry point for branch to get a label
**needs the label in a3

**v4 - check for [t] or [t]

	qmove.l	(a3),d0
	lsr.l	#8,d0
	cmpi.l	#"[t]",d0
	beq	search_toc_code_labels
	cmpi.l	#"[T]",d0
	beq	search_toc_code_labels

	bsr.l	test_for_locals	; rp 14/9/97  we need to decode the value of a local
				; set properly...which are stored in the equates table.
 	qmove.l	equates(a5),tree_strings_ptr(a5)
 	move.l	equates_tree(a5),a2
	bsr.l	equ_tree_search
	tst.w	d0
		
;	move.l	equates(a5),a4
;	bsr	search_labp2	*search equs using pass2 algorithm
;	tst.w	d0
	bge	found_in_equ	*got it

**not found in equs, so try labels


	move.l	scratch_1(a5),a3

	bsr.l	test_for_locals		; ****** llbls-rp200797 *********
	extern test_for_locals

 	qmove.l	labels(a5),tree_strings_ptr(a5)
	move.l	labels_tree(a5),a2
	bsr.l	lab_tree_search
	tst.w	d0



;	move.l	labels(a5),a4	*table to be searched
;	bsr	search_labp2	*search for this label 9was lab)
*we have to return the value of the label.
*the label may refer to either a previously defined equ
*or it may refer to the address of a label, so we 
*need to search both labels and equs
*we call search_lab which needs the table to be searched for in a4
*and the string, terminated in 0 in a0.
*it returns d0 as the position in the table or -1 if not found.
;	tst.w	d0	*did we find it?
	bge	found_in_labels	*yes, in labels
**not found in labels, so try toc_names, if ppc is true
	btst	#0,ppc_flags1(a5)
	beq.s	not_found11
	move.l	scratch_1(a5),a3
 	qmove.l	toc_names_table(a5),tree_strings_ptr(a5)
 	move.l	tocnames_tree(a5),a2
	bsr.l	tn_tree_search
	tst.w	d0	

;	move.l	toc_names_table(a5),a4	*imports!
;	bsr	search_labp2	*search for this label (was lab)
;	tst.w	d0
	bge	found_in_toc
not_found11:
**try for internal vars
	move.l	scratch_1(a5),a3
	qmove.l	(a3),d0
	cmpi.l	#"narg",d0	*narg?

	beq	narg_value
	cmpi.l	#"NARG",d0	*narg?
	beq	narg_value
	cmpi.l	#"rssz",d0
	beq	rs_value
	cmpi.l	#"RSSZ",d0
	beq	rs_value
	cmpi.l	#"gbsz",d0
	beq	glob_value
	cmpi.l	#"GBSZ",d0
	beq	glob_value
	cmpi.l	#"pass",d0
	beq	pass_value
	cmpi.l	#"PASS",d0
	beq	pass_value

	cmpi.l	#"m_rx",d0
	beq	mousex_value
	cmpi.l	#"M_RX",d0
	beq	mousex_value

	cmpi.l	#"m_ry",d0
	beq	mousey_value
	cmpi.l	#"M_RY",d0
	beq	mousey_value

	cmpi.l	#"m_bn",d0
	beq	mouseb_value
	cmpi.l	#"M_BN",d0
	beq	mouseb_value
**the above come here if not match
not_narg:
	moveq #-1,d1
	rts		*not found

search_toc_code_labels:
**it is possible that the toc routine has been declared as external.
	addq.l	#3,a3		*skip {t}
	
	cmp.b	#".",(a3)
	beq.s	code_toc_local_error

	qmove.l	toc_code_names(a5),a4
	bsr	search_labp2	*search equs using pass2 algorithm
;	tst.w	d0
	bge.s	found_in_tc	*got it
**try labels for an extern

	move.l	labels(a5),a4	*table to be searched
	bsr	search_labp2	*search for this label (was lab)
;	tst.w	d0
	bge.s	found_in_tc1
	moveq	#-1,d1
	rts
	
code_toc_local_error:
	qmove.l	a0,-(sp)
	lea code_toc_local_text(pc),a0
 	bsr pass1_error
	qmove.l (sp)+,a0
	qmoveq.l #0,d0
	moveq.l #-1,d1
	rts

	
found_in_tc1:
	moveq	#-1,d0	*its an external code offset
found_in_tc:
	lsl.l	#2,d0
**if linking dont add on imports and data items
	btst	#6,flags5(a5)
	bne.s	skip_add_import		*linkable? yes

	qmove.l	total_imports_num(a5),d2
;	ext.l	d2
	add.l	data_item_count(a5),d2
	lsl.l	#2,d2
	add.l	d2,d0		*add total number of imports and data defs
	addq.l	#4,d0		*plus 4 for bss pointer
;	clr.l	d1
**now we have to stick the label and pc in code_ptrs_output_table
**label in a3
**only do this on pass 2 and not a directive and o/p link
skip_add_import:
	btst	#3,ppc_flags1(a5)
	beq	skip_set_import		*pass1
**check if we are doing a directive
	btst	#4,ppc_flags1(a5)	*directive?=1
	bne	skip_set_import		*yes, so we dont add to output table
	btst	#6,flags5(a5)
	beq	skip_set_import		*linkable? no
	
	movem.l	a2/a3/a4,-(sp)
	qmove.l	total_code_ptrs_used(a5),d1
	qmove.l	code_ptrs_output_table(a5),a4
	muls.l	#40,d1
	add.l	d1,a4		*right place for label and offset
	move.l	a4,a2		*save start of label
	moveq	#31,d1
copy_cp_loop:
	move.b	(a3)+,(a4)+
	beq.s	get_out_clause
	qdbra	d1,copy_cp_loop
get_out_clause:

	qmove.l	pc(a5),32(a2)	*save pc of offset
	qmove.l	d0,d1
	lsr.l	#2,d1		*div 4
	btst	#6,flags5(a5)	*linkable?
	bne.s	its_linkable

	qmove.l	total_imports_num(a5),d2
;	ext.l	d2
	sub.l	d2,d1
	sub.l	data_item_count(a5),d1
	subq.l	#1,d1
its_linkable:
	btst	#29,d1
	bne.s	its_external	*bung in fffffffc if external
	move.l	toc_code_offsets(a5),a3	*point to code offsets
**LXT
	lsl.l	#2,d1
	add.l	d1,a3
	qmove.l	(a3),d1
;	move.l	0(a3,d1.l*4),d1	
	qmove.l	d1,36(a2)	*save offset
	addq.l	#1,total_code_ptrs_used(a5)
	clr.l	d1
	movem.l	(sp)+,a2/a3/a4
	rts_	"found_in_toc_code"		
its_external:
	qmove.l	#-1,36(a2)	*save as an external
	addq.l	#1,total_code_ptrs_used(a5)
	clr.l	d1
	movem.l	(sp)+,a2/a3/a4
	rts_	"found_in_toc_code_as_extern"		

****v4
found_in_equ:
	move.l eq_val(a5),a4
**LXT change
	qpush1	a4
	lsl.l	#2,d0
	add.l	d0,a4
	qmove.l	(a4),d0
	qpop1	a4
;	move.l 0(a4,d0.l*4),d0	*get the value
	clr.l d1		*no error
	rts_	"found_in_equs"

**we come here if its a toc label, probably an import (i really hope)
found_in_toc:
	move.l	toc_offsets_table(a5),a4
**LXT change
	qpush1	a4
	lsl.l	#2,d0
	add.l	d0,a4
	qmove.l	(a4),d0
	qpop1	a4
;	move.l	0(a4,d0.l*4),d0	*get offset
**only do this on pass 2
	btst	#3,ppc_flags1(a5)
	beq.s	skip_set_import	*pass1
**check if we are doing a directive
	btst	#4,ppc_flags1(a5)	*directive?=1
	bne.s	skip_set_import		*yes, so we dont add to output table

	btst	#6,flags5(a5)
	beq.s	skip_set_import		*linkable?

	movem.l	a2/a3/a4,-(sp)	
	qmove.l	total_imports_used(a5),d1
	move.l	imports_output_table(a5),a4
	muls.l	#36,d1
	add.l	d1,a4		*right place for label and offset
	move.l	a4,a2		*save start of label
	qmoveq	#31,d1
copy_imp_loop:
	move.b	(a3)+,(a4)+
	beq.s	get_out_clause1
	qdbra	d1,copy_imp_loop
get_out_clause1:
	qmove.l	pc(a5),32(a2)	*save pc of offset
	qmove.l	d0,36(a2)	*save offset in local toc
	addq.l	#1,total_imports_used(a5)
	movem.l	(sp)+,a2/a3/a4
skip_set_import:
	clr.l	d1
	rts_	"found_in_toc_imp"
*****
		
**major change for v3.00
**we need to check if its defined as an external, and add it to the header if so.
**but only on pass 2!	
found_in_labels:
	qbclr	#0,flags8(a5)	
	btst	#6,flags5(a5)	1=linkable
	beq.s	normal_label	no
	btst	#1,flags(a5)
	bne	pass2_lab_chk_ext	pass2, so see if ext
normal_label:
	move.l	lab_val(a5),a4
**LXT change
	qpush1	a4
	lsl.l	#2,d0
	add.l	d0,a4
	qmove.l	(a4),d0
	qpop1	a4

;	move.l	0(a4,d0.l*4),d0
	cmpi.l	#$fffffffe,d0		*extern data?
	bne.s	not_extern_data
	clr.l	d0			*just use plain old zero for extern
	qbset	#31,d0
	qbset	#0,flags8(a5)
not_extern_data:	
**check for bit 31 is set indicating a data offset
	btst	#31,d0
	beq.s	not_data_offset
	qbclr	#31,d0
**only do this on pass 2
	btst	#3,ppc_flags1(a5)
	beq.s	not_data_offset	*pass1
**check if we are doing a directive
	btst	#4,ppc_flags1(a5)	*directive?=1
	bne.s	not_data_offset	*yes, so we dont add to output table
**check if linkable
	btst	#6,flags5(a5)
	beq.s	not_data_offset		*linkable? no
	movem.l	a2/a3/a4,-(sp)	
	qmove.l	total_data_ptrs_used(a5),d1
	qmove.l	data_ptrs_output_table(a5),a4
	muls.l	#40,d1
	add.l	d1,a4		*right place for label and offset
	move.l	a4,a2		*save start of label
	qmoveq	#31,d1
copy_dat_loop:
	move.b	(a3)+,(a4)+
	beq.s	get_out_clause3
	qdbra	d1,copy_dat_loop
get_out_clause3:
	qmove.l	pc(a5),32(a2)	*save pc of offset
	qmove.l	d0,d1
	subq.l	#4,d1		*bss pointer shit
*get data offset
	qmove.l	total_imports_num(a5),d2
;	ext.l	d2
	lsl.l	#2,d2	*times 4 :-)	 
	sub.l	d2,d1	*offset into data offsets
	bmi.s	bad_offset
	move.l	data_item_offsets(a5),a3
**LXT
	qpush1	a3
	add.l	d1,a3
	qmove.l	(a3),d1
	qpop1	a3
;	move.l	0(a3,d1.l),d1
bad_offset:
	btst	#0,flags8(a5)
	beq.s	normal_data_ptr
	qmoveq	#-1,d1		*use -1 for extern_data item
normal_data_ptr:
	qmove.l	d1,36(a2)	*save data offset
	addq.l	#1,total_data_ptrs_used(a5)
	movem.l	(sp)+,a2/a3/a4
	
not_data_offset:
	clr.l	d1
	qbset	#4,flags(a5)	*found a real label
	rts_	"normal_label"
**d0 contains label position
**come here if pass 2 and linkable
pass2_lab_chk_ext:
	move.l	extern_buff(a5),a4	external labels list
	cmpi.b	#-1,0(a4,d0.l)	is it external label?
	bne	normal_label	no
	qmove.l	extern_buff_tab_pos(a5),d0
	move.l	extern_buff_tab(a5),a2
	add.l	d0,a2	point to next slot
	move.l	a2,a1	save

	move.l	scratch_1(a5),a3	point to label name
	qmoveq	#27,d1	counter
copy_ext_name_e:	move.b	(a3)+,(a2)+
	beq.s	cen_done_eval
	qdbra	d1,copy_ext_name_e
**now we need the pc for the displacement
cen_done_eval:	move.l	pc(a5),d1
	addq.l	#2,d1	account for instruction
	qmove.l	d1,28(a1)+	store address of offset after name - 32 bytes
	
	add.l	#32,d0		next position
	qmove.l	d0,extern_buff_tab_pos(a5)
	addq.l	#1,extern_count(a5)
	clr.l	d0	return zero.l
	clr.l	d1	no error
	qbset	#4,flags(a5)	found a real label
	qbset	#0,flags6(a5)	its external too...
	rts_	"found_external_label"
rs_value:
	tst.b	4(a3)
	bne	not_narg	*not a real rssz, but a label starting with rssz!
	qmove.l	rs_counter(a5),d0	*get rs_value
	clr.l	d1
	rts

mousex_value:
	tst.b	4(a3)
	bne	not_narg	*not a real pass, but a label starting with gbsz!
	lea	mouse_pt(pc),a0
	OSGetMouse	a0
	lea	mouse_pt(pc),a1	*this is x
	addq.l	#2,a1
;	clr.l	d0
	qmove.w	(a1),d0
	ext.l	d0
	clr.l	d1
	rts_	"eval_mousex"

mousey_value:
	tst.b	4(a3)
	bne	not_narg	*not a real pass, but a label starting with gbsz!
	lea	mouse_pt(pc),a0
	OSGetMouse	a0
	lea	mouse_pt(pc),a1	*this is x
;	clr.l	d0
	qmove.w	(a1),d0
	ext.l	d0
	clr.l	d1
	rts_	"eval_mousey"
mouseb_value:
	tst.b	4(a3)
	bne	not_narg	*not a real pass, but a label starting with gbsz!
	OSButton	d0
;	clr.b	-(sp)
;	dc.w	_button
;	clr.l	d0
;	move.b	(sp)+,d0

	extb.l	d0
	clr.l	d1
	rts_	"eval_mousey"
	
pass_value:
	tst.b	4(a3)
	bne	not_narg	*not a real pass, but a label starting with gbsz!
**return 1 or 2
	qmove.l	pass_id(a5),d0
	clr.l	d1
	rts

glob_value:
	tst.b	4(a3)
	bne	not_narg	*not a real gbsz, but a label starting with gbsz!
	qmove.l	globoff_counter(a5),d0	*get globoff_value
	clr.l	d1
	rts

narg_value:	tst.b	4(a3)
	bne	not_narg	*not a real narg, but a label starting with narg!
	btst	#1,flags2(a5)
	bne.s	real_narg	*yep in a macro
	clr.l	d0
	clr.l	d1
	rts
real_narg:
;	clr.l	d0
	qmove.l	narg_count(a5),d0	*get narg
	clr.l	d1
	rts
*********************************************************************** 
equ_val:	DS.B 100		*EQUATE STRING
label_search: DS.B 50	     	     *LABELS IN EQUATES GO HERE FOR SEARCH
real_numbers: DS.B 100	     	     *SPACE FOR 10 INTERMEDIATE VALUES FOR EVAL
***********************************************************************
comp_text:	DC.B	"Expression too complicated.",13,0
equ_err_text:	dc.b	"Label is not defined in this file, or any included file "
	dc.b	"and has not been declared "
	dc.b	"as an EXTERN, IMPORT, TOC_ROUTINE or EXTERN_DATA label. ",13,13,0
numb_b_err:	 DC.B	 "General operand syntax.",13,"Number expected, brackets not allowed in offsets or operand problem.",13,0
number_err_h:	DC.B	"Hex number too big.",13,13,0
number_err_h1:	dc.b	"Invalid hex number.",13,13,0
dls_text1:	DC.B	"End quotes expected.",13,13,0
dls_text2:	dc.b	"More than 4 characters in 32 bit string const.",13,13,0
starstar:	dc.b	"***Label = ",0
crcr_text:	dc.b	cr,cr,0
code_toc_local_text:	cstring "Toc Routines cannot be local ",0
		align
zero_div_text:	dc.b	"Divide by zero",13,13,0
	align
mouse_pt:	ds.w	2

	align
	
	public	evaluate,do_eval,eval2_entry
	global	equ_err_text,get_lab_value,search_toc_code_labels
	extern	pass1_error,pass2_error,search_lab
	extern	search_labp2,printit,pass_all_error,dir_search	
	extern_data	ppc_reserved_table,reserved_values
	extern	lab_tree_search,equ_tree_search,tn_tree_search
	
	extern_data	number_err_t
	