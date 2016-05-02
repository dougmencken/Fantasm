*********************************************************************
*MODULE:	EVALUATE2.S			    *
*DATE:	280894			    *
*LAST MODIFIED:	030994			    *
*PROGRAMMER:	S.BALL			    *
*VERSION:	1	 		    *
*FANT REL VER:	2.00			    *
*DESCRIPTION:	RETURNS THE VALUE OF THE STRING IN A2 IN D0	    *
*ALLOWS BRACKETS TO DEFINE PRECEDENCE IN IMMEDIATE DATA AND         *
*   EQUATES.                                                        *
*I'D JUST LIKE TO POINT OUT THAT THIS WAS (IS) A REAL BITCH         *
*********************************************************************

**************************************************************
*EVALUATE RETURNS THE VALUE OF THE STRING POINTED TO BY A2 IN D0.
*PRESERVES A4,A3,A2,A1,A0
********************************************************************************
**recurs_eval is new for v2.00
**is called from immediate mode and equates
**also dc, ds directives
**string is in a2
recurs_eval:
**pf404 - see if its a string, and if so, is it greater than 4 chars long?
;	cmpi.b	#$22,(a2)
;	bne	not_string_check
;	save_all
;	move.l	a2,a1
;	bsr.l	get_string_length	*in d0
;	cmpi.l	#4,d0
;	ble.s	string_ok
;	lea	string_len_warning(pc),a0
;	bsr.l	pass2_warning
;string_ok:
;	restore_all
		
not_string_check:
	btst	#6,flags3(a5)	*no brackets if set
	beq.s	allow_bracks
	bsr	evaluate
	rts_	"recurs_eval"
	
allow_bracks:	qmove.l	a0,long_var(a5)
	movem.l	a0/a1/a2/a3/a4,-(sp)

recurse_entry:

	move.l	a2,a3	*save string pos
**find deepest open bracket
	bsr	find_bracks	*returns d0=pos of deepest open
	tst.w	d2	*length of open bracks array
	bne.s	got_some_bracks
	move.l	a3,a2
	bsr	do_eval	*no brackets
	movem.l	(sp)+,a0/a1/a2/a3/a4
	rts_	"recurs_entry"
		
got_some_bracks:
	qmove.w	d1,los(a5)	*save length of string

**d1=length of string
**d2=length of open array
**d3=length of close array
**a1=open array
**a4=close array

**now find deepest open
	qmove.l	d2,d4	save length of open array
	subq.l	#2,d2	for dbra
	clr.l	d5	depeest
find_deep:
**LXT
	qpush1	a1
	add.w	d2,a1
	qmove.b	1(a1),d0
	qpop1	a1
;	move.b	1(a1,d2.w),d0
	cmp.b	d0,d5
	bge.s	not_bigger	if d5 is bigger than d0
	qmove.b	d0,d5
not_bigger:	subq.w	#2,d2
	bge.s	find_deep
	tst.b	d5
	bne	deep_bracks
**here the brackets are not nested, so we do them sequentially
**we want to get an array like:
**number.l, operator.l, number.l, operator.l etc,0,0
**first eval first bracks
**string is in a3
**d4 contains length of open array
	clr.l	d1	counter
	lea	bracks_express(a5),a0	where exprssion is built
	clr.l	eval2_item_count(a5)
	qmove.l	#0,d2
	qmove.l	#0,d3
**LXT change
	movem.l	a1/a4,-(sp)
	add.w	d1,a1
	add.w	d1,a4
	qmove.b	(a1),d2
	qmove.b	(a4),d3
	movem.l	(sp)+,a1/a4
;	move.b	0(a1,d1.w),d2	start pos	(
;	move.b	0(a4,d1.w),d3	end pos	)
	lea	temp_string(a5),a2	*copy area for string

	tst.w	d2
	beq.s	nowt_before	*a bracket starts the line
	qmoveq	#0,d1	*counter, 1 so we dont include the operator
	dec	d2
	beq.s	no_expression_before_operator
copy_before:
**LXT change
	qpush1	a3
	add.w	d1,a3
	qmove.b	(a3),(a2)+
	qpop1	a3
;	move.b	0(a3,d1.w),(a2)+
	inc.l	d1
	cmp.w	d1,d2
	bne.s	copy_before
	clr.b	(a2)+
	lea	temp_string(a5),a2
	movem.l	d1/d2/d3/d4/a0/a1/a2/a3/a4,-(sp)
	bsr	do_eval	eval expression
	movem.l	(sp)+,d1/d2/d3/d4/a0/a1/a2/a3/a4
	bra.s	skip_no_exp

no_expression_before_operator:
	clr.l	d0
skip_no_exp:
	
	qmove.l	d0,(a0)+	*store operand
	addq.l	#1,eval2_item_count(a5)
	clr.l	d0
**LXT change
	qpush1	a3
	add.w	d1,a3
	qmove.b	(a3),d0
	qpop1	a3
;	move.b	0(a3,d1.w),d0	*get operator
	qmove.l	d0,(a0)+
	addq.l	#1,eval2_item_count(a5)

	qmoveq	#0,d1	*do not touch d1 from now on!
	
**now progress through brackets
do_bracks_loop:
	qmove.l	#0,d2
	qmove.l	#0,d3
**LXT change
	movem.l	a1/a4,-(sp)
	add.w	d1,a1
	add.w	d1,a4
	qmove.b	(a1),d2
	qmove.b	(a4),d3
	movem.l	(sp)+,a1/a4
;	move.b	0(a1,d1.w),d2	start pos	(
;	move.b	0(a4,d1.w),d3	end pos	)
	lea	temp_string(a5),a2	*copy area for string
	
nowt_before:	inc	d2	*skip (
	dec	d3	*stop before )
copy_temp_str:
**LXT change
	qpush1	a3
	add.w	d2,a3
	qmove.b	(a3),(a2)+
	qpop1	a3
;	move.b	0(a3,d2.w),(a2)+
	inc	d2	*copy inside text from bracks
	cmp.w	d2,d3
	bge.s	copy_temp_str	next byte if d3>d2
	clr.b	(a2)	terminate
	lea	temp_string(a5),a2
	movem.l	d1/d2/d3/d4/a0/a1/a2/a3/a4,-(sp)
	bsr	do_eval	eval this expression returns d0
	movem.l	(sp)+,d1/d2/d3/d4/a0/a1/a2/a3/a4
	qmove.l	d0,(a0)+	save number
	addq.l	#1,eval2_item_count(a5)

	addq.w	#2,d3	*skip bracks to point to operator
	clr.l	d0
**LXT change
	qpush1	a3
	add.w	d3,a3
	qmove.b	(a3),d0
	qpop1	a3
;	move.b	0(a3,d3.w),d0
	qmove.l	d0,(a0)+	store operator
	addq.l	#1,eval2_item_count(a5)

**now we need see if d3 (current pos) is remotely like the next open bracket

	addq.l	#2,d1	*index into open bracks array
;	qmove.l	#0,d7
**LXT change
	qpush1	a1
	add.w	d1,a1
	qcmove.b	(a1),d7
	qpop1	a1
;	move.b	0(a1,d1.w),d7	*next open bracks pos
	inc.w	d3	*point to next char after operator
	cmp.w	d3,d7
	beq.s	bracks_yep	*yep, were ready for next open
	cmp.w	los(a5),d3
	bge.s	def_eos	*end of string
**here we copy upto the next bracks and eval
	dec	d7	rewind past next operator
	lea	temp_string(a5),a2
copy_inline:
**LXT change
	qpush1	a3
	add.w	d3,a3
	move.b	(a3),(a2)+
	qpop1	a3

;	move.b	0(a3,d3.w),(a2)+
	beq.s	eos_1	found end of string
	inc.w	d3
	cmp.w	d3,d7
	bne.s	copy_inline
	clr.b	(a2)+
eos_1:	lea	temp_string(a5),a2
	movem.l	d1/d2/d3/d4/a0/a1/a2/a3/a4,-(sp)
	bsr	do_eval	eval expression
	movem.l	(sp)+,d1/d2/d3/d4/a0/a1/a2/a3/a4
	qmove.l	d0,(a0)+	*store operand
	addq.l	#1,eval2_item_count(a5)
;	clr.l	d0
**LXT change
	qpush1	a3
	add.w	d3,a3
	qcmove.b	(a3),d0
	qpop1	a3
;	move.b	0(a3,d3.w),d0	*get operator

	qmove.l	d0,(a0)+
	addq.l	#1,eval2_item_count(a5)

**phew

bracks_yep:	cmp.w	d1,d4
	bgt	do_bracks_loop	do next set of bracks
def_eos:
	clr.l	(a0)+
	clr.l	(a0)+	just in case
	addq.l	#2,eval2_item_count(a5)

	lea	bracks_express(a5),a0	*code val for eval
	lea	code_val(a5),a4		*copy to here
	qmove.l	eval2_item_count(a5),d0	*how many to copy
	subq.l	#1,d0			*item counter

copy_cv:	qmove.l	(a0)+,(a4)+
	qdbra	d0,copy_cv
	
	bsr	eval2_entry	get final evaluation in d0
	movem.l	(sp)+,a0/a1/a2/a3/a4
	rts_	"eval2"
	
deep_bracks:
**search arrays for depth in d5
**open array a1, close a4, length d4
	qmove.l	d4,d2	get length
	dec.l	d2
find_open_brack:
**LXT change
	qpush1	a1
	add.w	d2,a1
	qmove.b	(a1),d0
	qpop1	a1
;	move.b	0(a1,d2.w),d0
	cmp.b	d0,d5
	beq.s	got_open_arr
	subq.w	#2,d2
	bge.s	find_open_brack
	bra	eval_fail	*fatal evaluator failure
got_open_arr:	move.l	d2,d6	*save open pos
	qmove.l	d4,d2	get length
	dec.l	d2
find_close_brack:
**LXT change
	qpush1	a4
	add.w	d2,a4
	qmove.b	(a4),d0
	qpop1	a4
;	move.b	0(a4,d2.w),d0
	cmp.b	d0,d5
	beq.s	got_close_arr
	subq.w	#2,d2
	bge.s	find_close_brack
	bra.s	eval_fail	*fatal evaluator failure
got_close_arr:	move.l	d2,d7	*close brack position
;	dec.l	d6		*warning!
;	dec.l	d7		
;	clr.l	d6
;	clr.l	d7
**LXT change
	qpush1	a1
	add.w	d6,a1
	qmove.b	-1(a1),d6
	qpop1	a1
;	move.b	-1(a1,d6.w),d6	*get start of bracks
**LXT change
	qpush1	a4
	add.w	d7,a4
	qmove.b	-1(a4),d7
	qpop1	a4
;	move.b	-1(a4,d7.w),d7	*get end of bracks
	ext.w	d6
	ext.w	d7
	qmove.w	d6,d1	*save start
	qmove.w	d7,d2	*save end
	inc	d6	*start of text
	dec	d7	*end of text
	lea	temp_string(a5),a2
copy_temp_str1:
**LXT change
	qpush1	a3
	add.w	d6,a3
	qmove.b	(a3),(a2)+
	qpop1	a3
;	move.b	0(a3,d6.w),(a2)+
	inc	d6
	cmp.w	d6,d7
	bge.s	copy_temp_str1	next byte if d3>d2
	clr.b	(a2)	terminate
	lea	temp_string(a5),a2
	movem.l	d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4,-(sp)
	bsr	do_eval	eval this expression returns d0
	movem.l	(sp)+,d1/d2/d3/d4/d5/d6/d7/a0/a1/a2/a3/a4
**now we have to reconstruct the string, and insert the result instead of 
*the expression in brackets - result in d0
	lea	temp_string2(a5),a2
	clr.l	d2
copy_str_3:	cmp.w	d2,d1
	beq.s	got_open_start
	move.b	(a3)+,(a2)+	copy string
	beq.s	copy_done	all done
	inc	d2
	bra.s	copy_str_3
got_open_start:	bsr	printnum_long_mem	*print d0.l to a2
	addq.w	#2,d7	*1 for dec above, and 1 to skip close brack
**now skip string until d7
skip_str:	inc.l	a3
	inc	d2
	cmp.w	d2,d7
	bne.s	skip_str

**copy rest of string
rest_of_str:	move.b	(a3)+,(a2)+
	bne.s	rest_of_str
copy_done:	lea	temp_string2(a5),a2	*we have now expanded the 
				*deepest brackets!
**copy to input string
	lea	input_string(a5),a3
cis:	move.b	(a2)+,(a3)+
	bne.s	cis

	lea	input_string(a5),a2
	bra	recurse_entry	*do it all again!
	
eval_fail:	lea	eval_gen_text(pc),a0
	bsr	pass2_error
	moveq	#-1,d1
	movem.l	(sp)+,a0/a1/a2/a3/a4
	rts_	"deep_bracks"
	
********************************************************************************
**find bracks scans a2 for brackets
*8the position of open brackets goes in bracks open
**as follows:
**1st byte is position
**2nd byte is depth
**depth starts at 0 and is incremented for every open bracket and decremented for
**every close bracket
find_bracks:	move.l	a2,a3
	qmove.l	#0,d0	*depth counter
	qmove.l	#0,d1	   *position counter
	qmove.l	#0,d2	   *open array index
	qmove.l	#0,d3	   *close array index
	lea	bracks_open(pc),a1
	lea	bracks_close(pc),a4
	
fb1:	move.b	(a2)+,d7
	beq.s	fb_end	eos
	cmpi.b	#$22,d7	start of string, so find end
	beq.s	find_close_string
	cmpi.b	#"(",d7
	beq.s	got_open_brack
	cmpi.b	#")",d7
	beq.s	got_close_brack
	inc	d1	inc index
	bra.s	fb1
	
find_close_string:
	inc	d1		*for start quote - 406
find_close_string1:
	inc	d1		*for next byte
	move.b	(a2)+,d7
	beq.s	string_err21	*eofield?
	cmpi.b	#$22,d7
	beq.s	fb1	*got eos
	cmpi.b	#13,d7
	beq.s	string_err21
	bra.s	find_close_string1
	
got_open_brack:	qmove.b	d1,0(a1,d2.w)	*store position
	qmove.b	d0,1(a1,d2.w)	*store depth
	addq.w	#2,d2	*index plus 2
	inc	d1	*inc string index
	inc.l	d0	*inc depth after insertion
 	bra.s	fb1	*next char
got_close_brack:
	dec.l	d0	*dec depth before insertion!
	qmove.b	d1,0(a4,d3.w)
	qmove.b	d0,1(a4,d3.w)
	addq.w	#2,d3
	inc	d1	*inc string index
	bra.s	fb1
fb_end:	tst.w	d0
	bne.s	bracks_mismatch	*error
	move.l	a3,a2	*restore a2
	rts_	"find_brackets"
	
*******************************errors**********************************************
bracks_mismatch:
	qmove.l	a0,-(sp)
	lea	mismatch_err(pc),a0
	bsr	pass2_error
	qmoveq	#0,d0
	moveq	#-1,d1
	move.l	(sp)+,a0
	rts
string_err21:
	qmove.l	a0,-(sp)
	lea	string_err21t(pc),a0
	bsr	pass2_error
	qmoveq	#0,d0
	moveq	#-1,d1
	move.l	(sp)+,a0
	rts
****************************************************************************************************
	
bracks_open:	DS.B	20	*OPEN BRACKETS ARRAY (SPACE FOR 10)
bracks_close:	DS.B	20	*CLOSE BRACKETS ARRAY - SEE FIND BRACKS	
mismatch_err:	DC.B	"Brackets dont match up in expression.",13,0
string_err21t:	DC.B	"Double quotes expected.",13,0
eval_gen_text:	DC.B	"EVALUATOR INTERNAL FAILURE - PRE PARSE BRACKETS.",13,0
string_len_warning:	cstring	"**WARNING*** String will be truncated to 4 characters.",13
	align
	public	recurs_eval
	extern	evaluate,do_eval,eval2_entry,printnum_long_mem
	extern	pass2_error,get_string_length,pass1_warning,pass2_warning
	extern	pass1_error
	