*********************************************************************************
*FILE:	GET_MODE.S				*
*MOTHER FILE:	FANTASM2XX.S				*
*DATE:	300994				*
*PROGRAMMER:	STUART BALL				*
*VERSION:	2.00				*
*DESCRIPTION:	GETS ADDRESSING MODES INCLUDING 020 - totally new for V2.00	*
*INPUT:	A3 POINTS TO OPERANDS			*
*OUTPUT:	SEE BELOW				*
*VERSION CHANGES:				*
*2.00	SCALE ENCODED INTO EXTENSION (COMPAT WITH 68000)	*
*********************************************************************************
**INCLUDED INTO GENERAL.S
**************************************************************************
***GET_MODE EXAMINES THE OPERAND POINTED TO BY A3 AND TERMINATED
***IN 0. IT RETURNS THE ADDRESSING MODE IN D0 AS 0-7 
***AND THE REGISTER FIELD IN D2
***and any extension field in d3
***THE BASIC SIZE OF A SOURCE OP IN D4
**scale is in extension[9-10] - d3
**
**V3.2X - REQUS - FIRST CALLS REPLACE_REQUS

***FOR DESTINATION OPS 2 HAS TO BE SUBTRACTED
***DESTROYS A1
***
***modes:
*0=Dn. rf will = n
*1=An. rf will = n
*2=(An). rf will = n
*3=(An)+ rf will = n
*4=-(An) rf will = n
*5=x(An) where x is 16 bits. rf will = n

*6=x(An,Dn.size*scale) where x is 8 bits, rf is address reg.	*new - 300994
*6 with rf=reg no  = bd(An,Dn.size*SCALE). Rf=address register	*new
*6 with rf = reg. = ([bd,An],Xn,size*scale,od) - pre indexed	*new
*6 with rf = reg. = ([bd,An,Xn.size*scale],od) - post indexd	*new

*7=x where x is 16 bit short address
*7 with rf=1 = abs long address
*7 with rf=2 = x(pc) with displacement i.e. $100(pc) where x=16bits

*7 with rf=3 = x(pc,Dn.size) where x = 8bits	*new
*7 with rf=3 = bd(pc,Xn.size*scale)	*new
*7 with rf=3 = ([bd,pc],Xn.size*scale,od) - pre indexed	*new
*7 with rf=3 = ([bd,pc,Xn.size*scale],od) - post indexed	*new

*7 with rf=4 = #x where x depends on size of instruction
*8 with rf=4 when used as destination = sr or ccr where ccr is low byte of sr

* W A R N I N G !!!!
* ==================
* Get_mode under certain random whims (i.e. errors, occasionally), will
* whip off your caller ret address, in an attempt to get at you dangly
* bits (i.e. branch table driver thingy). You have been warned!
get_mode:
***check for immediate (7 with reg=4 only for source)
***#
	bsr	replace_requs	in general.s
	
 qbclr #4,flags(a5) 	 *reloc long flag for insert inst
 qbclr	#0,flags6(a5)	*set to 1 if 7,2 or 7.3 and external def..
 movea.l a3,a4 	*convert sp to a7
 qmove.l a3,d5
 qmoveq #"S",d7
find_sp:
 move.b (a3)+,d0
 beq.s end_sp 		*finished
 cmp.b d7,d0 		*s?
 bne.s find_sp
 cmpi.b #"P",(a3) 	*p?
 bne.s find_sp
***here we've found sp but the real sp can only be terminated
***in either ),0 and must be preceded by either space or (
 qmove.b 0-2(a3),d6 	 *check char in front
 cmpi.b #" ",d6
 beq.s possible_sp
 cmpi.b #"(",d6
 beq.s possible_sp
 addq.l #1,d5
 cmpa.l d5,a3 		*there is nothing in front of sp!
 beq.s possible_sp
 bra.s find_sp
possible_sp:
 move.b 1(a3),d6 	*now check sp terminator
 beq.s got_sp
 cmpi.b #")",d6
 beq.s got_sp
 bra.s find_sp
got_sp:
****here we've really found an sp so replace with a7
 qmove.b #"A",0-1(a3)
 qmove.b #"7",(a3)
end_sp:
	move.l	a4,a3	reset
**first check for new modes
	cmpi.w	#$285b,(a3)	*([
	beq	twenty_modes
**now check for bitfield def
	cmpi.b	#"{",(a3)
	beq	bitfield	
	movea.l a4,a3
***check immediate addressing
	qmoveq	#0,d2 		*clear rf
	cmpi.b	#"U",(a3) 	*usp?
	bne.s	not_usp
	cmpi.b	#"S",1(a3)
	bne.s	not_usp
	cmpi.b	#"P",2(a3)
	bne.s	not_usp
	qmoveq	#4,d4 		*size is word
	moveq	#-2,d0 		*set mode=-2
	rts_	"end_sp"
	align
not_usp:	cmpi.b	#"#",(a3)
	bne.s	not_m74s

	addq.l	#1,a3 		*skip #
	movea.l	a3,a1 	*copy op code
	bsr	get_op_code_num_i 	*returns d0=expression with a1 past expression
	tst.b	(a1)	*must be a comma after immediate data
	bne	comma_error_g
	qmove.l	d0,d3 		*immediate data
	qmoveq	#7,d0 		*set mode 7
	qmoveq	#4,d2 		*set reg field=4
***now check size of instruction
	cmpi.w	#2,d1 		*d1 is the size
	bne.s	do_word
	moveq	#6,d4 		*.l #xxxxxxxx,
	rts_	"not_usp "
	align
do_word:	moveq	#4,d4 		*.w or .b #xxxx,
	rts_	"do_word "
	align
check_usp:	cmpi.w	#"SP",1(a3)
	bne	reg_error
	qmoveq	#4,d4 		*size is word
	moveq	#-2,d0 		*set mode=-2
	rts_	"chk_usp "
 	align
not_m74s:
***dn
	cmpi.b	#"D",(a3)
	bne.s	not_m0
	qmoveq	#0,d2
	qmove.b	1(a3),d2
	sub.b	#48,d2 		*make real number
	bmi.s	not_m0
	cmpi.b	#7,d2
	bgt.s	not_m0
	cmpi.b	#"-",2(a3) 	*d0-d3?
	beq.s	movem_g
 	cmpi.b	#"/",2(a3)
 	beq.s	is_m0

	tst.b	2(a3)
	bne.s	not_m0		*416 - prevent d17(a5) appearing as d1!

is_m0:	moveq	#0,d0 		*set mode 0
	moveq	#2,d4
	rts_	"not_m74s"
	align
movem_g:	moveq #0,d0
	moveq #4,d4 		*movem is 4 bytes
	rts_	"move_g  "
	align
***an
not_m0:
 cmpi.b #"A",(a3)
 bne.s not_m1

 qmoveq #0,d2
 qmove.b 1(a3),d2
 sub.b #48,d2
 bmi.s not_m1
 cmpi.b #7,d2
 bgt.s not_m1
 	cmpi.b	#"-",2(a3)
 	beq.s	is_m1
 	cmpi.b	#"/",2(a3)
 	beq.s	is_m1
	tst.b	2(a3)
	bne.s	not_m1		*416 - prevent a17(a5) appearing as d1!
is_m1:
 qmoveq #1,d0 	 	 *set mode 1
 moveq #2,d4
 rts_	"not_m0  "
 	align
***sr or ccr
not_m1:
 cmpi.w #"SR",(a3)
 bne.s not_sr
 tst.b	2(a3)
 bne.s not_sr
 qmoveq #-1,d0 		 *mode 7 with error checking
 qmoveq #4,d2
 moveq #2,d4
 rts_	"not_m1  "
 	align
not_sr:
 cmpi.l #$43435200,(a3) 	*"ccr"
 bne.s not_m74d 		*nope
 qmoveq #-1,d0 		 *mode 7
 qmoveq #4,d2 	 	 *rf=4
 moveq #2,d4
 rts_	"not_sr"
 	align
not_m74d:	cmpi.b #"(",(a3) 	*mode2=(ax)
	bne.s not_m2or3
	cmpi.b #"A",1(a3)
	bne.s not_m2or3
	
 qmove.b 2(a3),d2
 sub.b #48,d2
 bmi reg_error
 cmpi.b #7,d2
 bgt reg_error
 cmpi.b #")",3(a3) 	*check for close blackets
 bne.s not_m2or3 	*cant be modes 2 or 3, try 4
 cmpi.b #"+",4(a3) 	*make sure its not mode 3
 beq.s m3 		*it is!
 qmoveq #2,d0
 moveq #2,d4
 rts_	"not_m74d"
 	align
m3:
 qmoveq #3,d0
 moveq #2,d4
 rts_	"m3"
	align
***-(an)
not_m2or3:	
	cmpi.b #"-",(a3)
	bne.s not_m4
	cmpi.b #"(",1(a3)
	bne.s not_m4
 qmove.b 3(a3),d2
 sub.b #48,d2
 bmi reg_error
 cmpi.b #7,d2
 bgt reg_error
 cmpi.b #")",4(a3)
 bne close_brack_err
 qmoveq #4,d0
 moveq #2,d4
 rts_	"not_m23"
	align
**heavy mods for v3 (linkable) from here on...
not_m4:
***15(ax) or 15(pc)
 movea.l a3,a1 	*copy op code
 bsr get_op_code_num 	*returns d0=expression with a1 past expression.d6=1 if label

**flags 6[0] will be 1 if external
 
 cmpi.b #"(",(a1) 	*so we can check the rest of the op code
 bne not_m_4or5 	*could be absolute address
	
 cmpi.b #"P",1(a1) 	*pc addressing?
 beq.s do_72or73 	*yes
 qmove.b 2(a1),d2 	 *get reg number
 sub.b #48,d2
 bmi reg_error
 cmpi.b #7,d2
 bgt reg_error
 cmpi.b #")",3(a1)
 bne not_m5 		*see if index reg
**now check for 16 bit displacement
 cmpi.l #32766,d0
 bgt only_16_disp
 cmpi.l #-32765,d0
 blt only_16_disp
 qmove.w d0,d3 		 *return displacement in d3
 qmoveq #5,d0
 moveq #4,d4
 rts_	"not_m4"

do_72or73:
 cmpi.b #"C",2(a1) 	*check for pc
 bne reg_error 	*bad syntax
 cmpi.b #")",3(a1) 	*mode 7 2?
	bne	try_73 		*no, with index
 btst #1,flags(a5)
 bne.s do_it_g 		*pass 2 so eval
 moveq #2,d0
 bra.s done_p1
do_it_g:
 	btst	#4,flags(a5)	was it a real label?
 	beq.s	nr_1	no
 	btst	#0,flags6(a5)	was it an external?
 	beq.s	not_ext_pc_ref	no
**yes it was, so we modify the offset in ext_buff_tab to read upper 8
**bits = ff, lower 24 bits is address

	save_all
	qmove.l	extern_buff_tab_pos(a5),d0
	qmove.l	extern_buff_tab(a5),a2
	sub.l	#32,d0	point to last entry
	add.l	d0,a2	taadaah
	lea	28(a2),a2	point to abs data
	qmove.b	#-1,(a2)	set upper 8 bits...
	restore_all
	clr.l	d0	insert 0 as offset
	bra.s	nr_1 
not_ext_pc_ref:	move.l pc(a5),d7
	addq.l #2,d7
	sub.l d7,d0 		*get offset
**now check for 16 bit displacement
nr_1:	cmpi.l #32768,d0
	bgt.s maybe_addr 	*we dont know if its an offset or an address yet
	cmpi.l #-32766,d0
	blt.s maybe_addr
done_p1: 		*pass 1 dont calculate offset
 qmove.w d0,d3 		 *return displacement in d3
 qmoveq #7,d0 	 	 *mode=7
 qmoveq #2,d2 	 	 *rf=2
 moveq #4,d4
 rts_	"do_72_73"
 	align
maybe_addr:
 qmove.l pc(a5),d7 	 *try calculating offset from pc
 addq.l #2,d7
 sub.l d7,d0
 cmpi.l #32768,d0
 bgt only_16_disp
 cmpi.l #-32766,d0
 blt only_16_disp
 bra.s done_p1 		*thats ok.


try_73:		*pc with index
 cmpi.b #0x2c,3(a1)
 bne comma_error_g 	*should be a comma here 15(pc,d0.w)
**now check for 8 bit displacement
 btst #1,flags(a5)
 bne.s do_it8 		*pass 2 so eval
 moveq #2,d0
 bra.s done_p18
do_it8:
	btst	#4,flags(a5)	was it a real label?
	beq.s	nr_2	no
	qmove.l	pc(a5),d7	yes
	addq.l	#2,d7
	sub.l	d7,d0
nr_2:	cmpi.l	#128,d0
	bgt	only_8_disp
	cmpi.l	#-127,d0
 blt only_8_disp
done_p18:
 clr.l	d3
 qmove.b d0,d3 		 *return displacement in d3
 cmpi.b #"D",4(a1) 	*data register?
 bne.s check_a73		*no
 bra.s chk_reg73
check_a73:
 cmpi.b #"A",4(a1) 	*address register?
 bne reg_error
 qbset #15,d3 	 	 *set address in extension
chk_reg73:
 qmove.b 5(a1),d2 	 *get reg number
 sub.b #48,d2
 bmi reg_error
 cmpi.b #7,d2
 bgt reg_error
**now we need to get reg in bits 12-14 to or to extension
 lsl.w #8,d2
 lsl.w #4,d2
 or.w d2,d3 		*reg now in extension
 cmpi.b #"L",7(a1) 	*now check size of index reg
 bne.s index_w73
 qbset #11,d3 	 	 *set long in extension
index_w73:
 bsr	try_scale	*mix in scale	v2.05
 qmoveq #7,d0 	 	 *mode 7
 qmoveq #3,d2 	 	 *rf=3
 moveq #4,d4
 rts_	"chk_a73"
	align
*** 57,d6 - absolute address or label
not_m_4or5:
 tst.b (a1)
 bne address_error 	*theres characters after the address
 qmove.l d0,d3 		 *address
 qmoveq #7,d0 	 	 *mode 7
 qmoveq #1,d2 	 	 *rf=1
 moveq #6,d4 		*flags(4) will be 1 if returned from labels or 0 for equs

 rts_	"not_4or5"
 	align
not_m5:
***15(ax,dn.s)
 movea.l a3,a1 	*copy op code
 bsr get_op_code_num 	*returns d0=expression with a1 past expression
 cmpi.b #"(",(a1) 	*so we can check the rest of the op code
 bne open_brack_error
 qmove.b 2(a1),d2 	 *get reg number
 sub.b #48,d2
 bmi reg_error
 cmpi.b #7,d2
 bgt reg_error
 qmove.w d2,d4 		 *save reg
 cmpi.b #0x2c,3(a1)
	bne	comma_error
**now check for 8 bit displacement
 cmpi.l #128,d0
 bgt only_8_disp
 cmpi.l #-127,d0
 blt only_8_disp
 clr.l	d3
 qmove.b d0,d3 		 *return displacement in d3
 cmpi.b #"D",4(a1) 	*data register?
 bne.s check_a 		*no
 bra.s chk_reg
check_a:
 cmpi.b #"A",4(a1) 	*address register?
 bne reg_error
 qbset #15,d3 	 	 *set address in extension
chk_reg:
 qmove.b 5(a1),d2 	 *get reg number
 sub.b #48,d2
 bmi reg_error
 cmpi.b #7,d2
 bgt reg_error
**now we need to get reg in bits 12-14 to or to extension
 lsl.w #8,d2
 lsl.w #4,d2
 or.w d2,d3 		*reg now in extension
 cmpi.b #"L",7(a1) 	*now check size of index reg
 bne.s index_w
 qbset #11,d3 	 	 *set long in extension
index_w:
	bsr	try_scale	*if scale, then 8(a1) will be *
 qmoveq #6,d0
 qmove.w d4,d2 		 *return reg
 moveq #4,d4
 rts_	"not_m5"
	align

twenty_modes:	lea	twenty_mode_text(pc),a0
	bsr	do_gen_error
	rts

**a3 points to {
**first get offset, either dn or 0-31	
bitfield:	clr.l	d3	clear extension
	lea	1(a3),a4
	cmpi.b	#"D",(a4)
	beq.s	offset_dn	data reg
	lea	offset_temp(pc),a2
copy_offset:	move.b	(a4)+,d0
	cmpi.b	#":",d0
	beq.s	co_done
	qmove.b	d0,(a2)+
	bra.s	copy_offset
co_done:	clr.b	(a2)
	lea	offset_temp(pc),a2
	qmove.l	d3,-(sp)
	bsr	evaluate	get offset in d0
	qmove.l	(sp)+,d3
	tst.w	d0
	bmi	offset_error	<0
	cmpi.w	#31,d0
	bgt	offset_error	>31
	
	lsl.w	#6,d0	offset in 6-10 of extension
	or.w	d0,d3	mix in offset
	bra.s	done_offset
offset_dn:	qbset	#11,d3	set do field
	qmove.b	1(a4),d0	get d number
	addq.l	#3,a4	point past :
	subi.b	#"0",d0	make real number
	cmpi.b	#7,d0
	bgt	offset_error	d>7
	lsl.w	#6,d0
	or.w	d0,d3
	
done_offset:	cmpi.b	#"D",(a4)
	beq.s	width_dn
	lea	offset_temp(pc),a2
copy_width:	move.b	(a4)+,d0
	cmpi.b	#"}",d0
	beq.s	cw_done
	qmove.b	d0,(a2)+
	bra.s	copy_width
cw_done:	clr.b	(a2)
	lea	offset_temp(pc),a2
	qmove.l	d3,-(sp)
	bsr	evaluate
	qmove.l	(sp)+,d3
	tst.w	d0
	bmi	width_error
	cmpi.w	#32,d0
	bgt	width_error
	bne.s	width_ok
	clr.l	d0	0 is 32 for width
width_ok:	or.w	d0,d3
	bra.s	done_width
width_dn:	qbset	#5,d3	set dw field
	qmove.b	1(a4),d0
	addq.l	#3,a4
	subi.b	#"0",d0
	cmpi.b	#7,d0
	bgt	width_error
	or.w	d0,d3
done_width:	move.w	#4,d4	size
	rts		*note no rf

**************************************************************************************	
****
**try_scale examines 8(a1) for a *, if not then no change.
**if * present, then scale in 9(a1)
**modifies extension[9-10] - d3
try_scale:
	cmpi.b	#"*",8(a1)
	beq.s	do_scale
**maybe its (an,d0*scale)
	cmpi.b	#"*",6(a1)
	beq.s	do_scale1
	rts
do_scale:	clr.l	d7
	qmove.b	9(a1),d5	think this is spare????
	subi.b	#"0",d5
	ext.w	d5
	cmpi.b	#8,d5
	bgt	scale_error_2	scale too big
	cmpi.w	#1,d5
	bne.s	not_sc_1
	bra.s	no_scale	00=1
not_sc_1:	cmpi.w	#2,d5
	bne.s	not_sc_2
	qbset	#9,d3	01=2
	bra.s	no_scale
not_sc_2:	cmpi.w	#4,d5
	bne.s	not_sc_4
	qbset	#10,d3	10=4
	bra.s	no_scale
not_sc_4:	cmpi.w	#8,d5
	bne	scale_error_1	unrecognised scale
	qbset	#10,d3
	qbset	#9,d3	11=8	
no_scale:	rts_	"try_scal"
	align
**handles (xn,sn*scale)
do_scale1:	clr.l	d7
	qmove.b	7(a1),d5	think this is spare????
	subi.b	#"0",d5
	cmpi.b	#8,d5
	bgt	scale_error_2	scale too big
	cmpi.w	#1,d5
	bne.s	not_sc_11
	bra.s	no_scale	00=1
not_sc_11:	cmpi.w	#2,d5
	bne.s	not_sc_21
	qbset	#9,d3	01=2
	bra.s	no_scale
not_sc_21:	cmpi.w	#4,d5
	bne.s	not_sc_41
	qbset	#10,d3	10=4
	bra.s	no_scale
not_sc_41:	cmpi.w	#8,d5
	bne	scale_error_1	unrecognised scale
	qbset	#10,d3
	qbset	#9,d3	11=8	
	rts_	"do_scal1"
	align
*****************************
get_op_code_num_immediate:

get_op_code_num:
**flags 8(1) is used to tell us whether we are expacting immediate data, if we are
*8then we call get_op_code_num_i!
**the below is for 4.10
**we can have things like:
*(a0)
*22(a0)
*22
*(22+3-5)(a0)
**0+(fred*nancy)-2(a0)
**
**we need a way of spotting the end of the number! the old way of just looking for
**an open brackets is no good.
**we need a new routine with more intelligence!
**so, first thing we do is look at the end of the line. if it ends in close bracks
**then scan back to find open bracks - if not found, error.

**then pass the whole (new) string to check_special label.
**this tells us whether the contents of the brackets are a reserved label	

**if the open bracks are the start of the string and the contents are a register,
**we return zero.

**if the contents of the brackets are not a special label, we check the character in front 
**of the open brackets, and if its an 
**operator or a bracket, we pass the whole string to recurs_eval.

**if they are not the start of the string, then we use the open brackets as the end of 
**the current number and call recurs_eval.

**if the string does not end in close brackets, pass the whole string to recurs_eval.

***if pass 1 then this routine returns 0
***if pass 2 then
***this routine calls evaluate to see if a1 is pointing to an expression
***if it is then d0=number else d1=-1
***evaluate needs the string in a2
	btst	#1,flags8(a5)
	bne	get_op_code_num_i_ppc	*immediate data	
	qmove.l	a2,-(sp) 	*op code string goes here for evaluate
	lea	op_buff(pc),a2
	cmpi.b	#$22,(a1)	"
	beq.s	gocn_str 		*necessary cause strings can be commas
**405 - if we find an open bracket as the first character and the next character is 0-9
;	cmpi.b	#"(",(a1)	*check for (a1,d5.l) without a 0 if 68k!
;	beq.s	return_zero
	cmpi.b	#"(",(a1)
	bne.s	not_start_open
	cmpi.b	#"0",1(a1)
	blt.s	return_zero
	cmpi.b	#"9",1(a1)
	bgt.s	return_zero
**pass the whole string to eval
copy_to_op:
	move.b	(a1)+,(a2)+
	bne.s	copy_to_op
	bra.s	got_expression_bracks
	
not_start_open:
	qmoveq	#"(",d5
	qmoveq	#")",d6
	qmoveq	#0x2c,d7
gocn_lp:
;	clr.l	d2
	qcmove.b	(a1)+,d2
	tst.b	d2
	beq.s	got_expression
	cmp.l	d5,d2 		* ( because we can have lines like 500(a5)
	beq.s	got_expression
	cmp.l	d6,d2 		* )
	beq.s	got_expression
	cmp.l	d7,d2 		* ,
	beq.s	got_expression
	qmove.b	d2,(a2)+
	bra.s	gocn_lp

***next bit transfers strings
gocn_str:	qmove.b	(a1)+,(a2)+ 	*move first quote
	qmoveq	#$22,d7
gs_lp:	move.b	(a1)+,d2
	beq	string_error_g 	*no closing quotes
	qmove.b	d2,(a2)+
	cmp.b	d7,d2 		* "
	beq.s	got_expressions_str
	bra.s	gs_lp
got_expressions_str:
	tst.b	(a2)
	bne	string_error_quotes
	 
got_expressions:	addq.l	#1,a1
got_expression:	clr.b	(a2) 		*terminate correctly

ppc_get_op:	*needs op in op_buff(pc)
	lea	op_buff(pc),a2
	cmpi.b	#"-",(a2) 	*dont pass -ve labels!
	bne.s	pos_ve
	addq.l	#1,a2
	qbset	#2,flags(a5) 	8set -ve flag
pos_ve:	qmove.l	d1,-(sp) 	*save code
	bsr	evaluate
	qmove.l	(sp)+,d1
	qmove.l	(sp)+,a2
	btst	#2,flags(a5) 	*negative number?
	beq.s	plus_ve 		*nah
	neg.l	d0 		*yup, negate result
	qbclr	#2,flags(a5)
plus_ve:	subq.l	#1,a1 		*make a1 correct
	rts
do_nowt_g:		*dont think this is refd anymore?
	subq.l #1,a1 		*make a1 correct

return_zero:	movea.l (sp)+,a2
	moveq #0,d0
	rts_	"gocn"
	align
	
	
got_expression_bracks:	clr.b	(a2) 		*terminate correctly
	lea	op_buff(pc),a2
	cmpi.b	#"-",(a2) 	*dont pass -ve labels!
	bne.s	pos_veb
	addq.l	#1,a2
	qbset	#2,flags(a5) 	8set -ve flag
pos_veb:	qmove.l	d1,-(sp) 	*save code
	bsr	recurs_eval
	qmove.l	(sp)+,d1
	movea.l	(sp)+,a2
	btst	#2,flags(a5) 	*negative number?
	beq.s	plus_veb 	 	 *nah
	neg.l	d0 		*yup, negate result
	qbclr	#2,flags(a5)
plus_veb:	subq.l	#1,a1 		*make a1 correct
	rts

***************************************
get_num20:
**gets numbers for new 020 modes. here numbers can be termed in .,)
***this routine calls evaluate to see if a1 is pointing to an expression
***if it is then d0=number else -1
***numbers can have sizes appended - .w or .l
***d1=0 if number is sign extended word (default)
***  =1 if long 
***evaluate needs the string in a2
	qmove.l	a2,-(sp) 	*op code string goes here for evaluate
	lea	op_buff(pc),a2
	cmpi.b	#$22,(a1)	"
	beq.s	gocn_str20 	*necessary cause strings can be commas
	qmoveq	#".",d5
	qmoveq	#")",d6
	qmoveq	#0x2c,d7
gocn_lp20:	move.b	(a1)+,d2
	beq.s	got_expression20
	cmp.b	d5,d2 	*.
	beq.s	got_expression20
	cmp.b	d6,d2 		* )
	beq.s	got_expression20
	cmp.b	d7,d2 		* ,
	beq.s	got_expression20
	qmove.b	d2,(a2)+
	bra.s	gocn_lp20

***next bit transfers strings
gocn_str20:	qmove.b	(a1)+,(a2)+ 	*move first quote
	qmoveq	#$22,d7
gs_lp20:	move.b	(a1)+,d2
	beq	string_error_g 	*no closing quotes
	qmove.b	d2,(a2)+
	cmp.b	d7,d2 		* "
	beq.s	got_expressions20
	bra.s	gs_lp20
 
got_expressions20:	addq.l	#1,a1
got_expression20:	clr.b	(a2) 		*terminate correctly
	lea	op_buff(pc),a2
	cmpi.b	#"-",(a2) 	*dont pass -ve labels!
	bne.s	pos_ve20
	addq.l	#1,a2
	qbset	#2,flags(a5) 	8set -ve flag
pos_ve20:	qmove.l	d1,-(sp) 	*save code
	bsr	evaluate
	qmove.l	(sp)+,d1
	movea.l	(sp)+,a2
	btst	#2,flags(a5) 	*negative number?
	beq.s	plus_ve20 		*nah
	neg.l	d0 		*yup, negate result
	qbclr	#2,flags(a5)
plus_ve20:	subq.l	#1,a1 		*make a1 correct
**check size
	cmpi.w	#$2e57,(a1)	.w
	bne.s	try_long2	*no size
default_word:	clr.l	d1
	rts
try_long2:	cmpi.w	#$2e4c,(a1)	.l
	bne.s	default_word
	moveq	#1,d1
	rts
	
get_op_code_num_i:
	bra	get_op_code_num_i_ppc
***if pass 1 then th
***if
***this routine calls evaluate to see if a1 is pointing to an expression
***if it is then d0=number else -1
***evaluate needs the string in a2
**only called for immediate data!
	qbclr	#1,flags8(a5)	*clear ppc immediate data flag
 qmove.l	a2,-(sp) 	*op code string goes here for evaluate
 lea	op_buff(pc),a2
 cmpi.b	#$22,(a1)	"
 beq.s	gocn_str_i		*necessary cause strings can be commas
 qmoveq	#0x2c,d7
**crash check for #number(
	cmpi.b	#"(",(a1)	#(xxxx?
	beq.s	gocn_lp_i1	yes
	
	move.l	a1,a2	save

cc_1:	qmove.b	(a1)+,d0
	cmpi.b	#"0",d0
	blt.s	end_cc1
	cmpi.b	#"9",d0
	ble.s	cc_1
end_cc1:	cmpi.b	#"(",d0
	beq	avert_crash_1	yes it was #xxx(
	move.l	a2,a1	restore pointer
	lea	op_buff(pc),a2
	bra.s	gocn_lp_i

gocn_lp_i1:		*come here if #(xxx to transfer bracks
	move.b	(a1)+,d2		*402
	beq.s	got_expression_i
	qmove.b	d2,(a2)+
	bra.s	gocn_lp_i1

gocn_lp_i:
 move.b	(a1)+,d2
 beq.s	got_expression_i
	cmpi.b	#"(",d2			*4.02
	beq	avert_crash_2		*yes it was #xxxx(

 qmove.b	d2,(a2)+
 bra.s	gocn_lp_i


***next bit transfers strings
gocn_str_i:
 qmove.b	(a1)+,(a2)+ 	*move first quote
 qmoveq	#$22,d7
gs_lp_i:
 move.b	(a1)+,d2
 beq	string_error_g 	*no closing quotes
 qmove.b	d2,(a2)+
 cmp.b	d7,d2 		* "
 beq.s	got_expressions_i
 bra.s	gs_lp_i
 
got_expressions_i:
 addq.l	#1,a1
got_expression_i:
 clr.b	(a2) 		*terminate correctly
 lea	op_buff(pc),a2
 cmpi.b	#"-",(a2) 	*dont pass -ve labels!
 bne.s	pos_ve_i
 addq.l	#1,a2
 qbset	#2,flags(a5) 	*set -ve flag
pos_ve_i:
 qmove.l	d1,-(sp) 	*save code

	bsr	recurs_eval	*do brackets
*	bsr	evaluate
 qmove.l	(sp)+,d1
 movea.l	(sp)+,a2
 btst	#2,flags(a5) 	*negative number?
 beq.s	plus_ve_i 		*nah
 neg.l	d0 		*yup, negate result
 qbclr	#2,flags(a5)
plus_ve_i:
 subq.l	#1,a1 		*make a1 correct
 rts

get_op_code_num_i_ppc:

***if pass 1 then th
***if
***this routine calls evaluate to see if a1 is pointing to an expression
***if it is then d0=number else -1
***evaluate needs the string in a2
**only called for immediate data!
	qbclr	#1,flags8(a5)	*clear ppc immediate data flag
	qmove.l	a2,-(sp) 	*op code string goes here for evaluate
	lea	op_buff(pc),a2
copy_i_p:
	move.b	(a1)+,(a2)+
	bne.s	copy_i_p

	clr.b	(a2) 		*terminate correctly

**406b8 - in immediate data check for open brackets preceded by a non operator.

	lea	op_buff(pc),a2
	qmove.b	(a2)+,d0
	cmpi.b	#$22,d0		*first char a quote (we normally dont check 1st char)
	beq.s	feos		*find end of string
find_ob:	
	tst.b	(a2)
	beq.s	find_ob_end
	cmpi.b	#$22,(a2)	*string?
	bne.s	not_find_eos
feos:	move.b	(a2)+,d0
	beq	string_error
	cmpi.b	#$22,d0
	bne.s	feos
	bra.s	find_ob
	
not_find_eos:
	cmpi.b	#"(",(a2)
	bne.s	not_ob
	qcmove.b	-1(a2),d0
	cmpi.l	#"^",d0
	beq.s	not_ob
	cmpi.l	#"*",d0
	beq.s	not_ob
	cmpi.l	#"/",d0
	beq.s	not_ob
	cmpi.l	#"+",d0
	beq.s	not_ob
	cmpi.l	#"-",d0
	beq.s	not_ob
**here we have something like fred(r6) which is an immediate data error!
	save_all
	lea	bad_second_op(pc),a0
	bsr	pass1_error
	restore_all
	bra.s	r_error
not_ob:	addq.l	#1,a2
	bra.s	find_ob
	
**no error
find_ob_end:
	lea	op_buff(pc),a2
	cmpi.b	#"-",(a2) 	*dont pass -ve labels!
	bne.s	pos_ve_ip
	addq.l	#1,a2
	qbset	#2,flags(a5) 	*set -ve flag
pos_ve_ip:
	qmove.l	d1,-(sp) 	*save code
	bsr	recurs_eval	*do brackets
*	bsr	evaluate
	qmove.l	(sp)+,d1
	movea.l	(sp)+,a2
	btst	#2,flags(a5) 	*negative number?
	beq.s	plus_ve_ip 	 	 *nah
	neg.l	d0 		*yup, negate result
	qbclr	#2,flags(a5)
plus_ve_ip:
	subq.l	#1,a1 		*make a1 correct
	rts
r_error:
	movea.l	(sp)+,a2
	clr.l	d0
	rts

avert_crash_1:	move.l	(sp)+,a2	*restore a2
	clr.l	d0
	rts	*get mode will pick up on the erro

avert_crash_2:			*402
	move.l	(sp)+,a2
	lea	bad_first_op(pc),a0
	bsr	pass1_error
	clr.l	d0
	rts_	"gocni_ac2"
string_error_quotes:
	lea	strings_only(pc),a0
	bra.s	do_gen_error
	
string_error_g:	lea close_string(pc),a0
do_gen_error:	bsr pass2_error
	qmove.l #0,d2
	qmove.l #0,d0
	clr.l d4
	movea.l (sp)+,a2     *  whip off callers address.
	rts

do_gen_error1:	bsr pass2_error
	qmove.l #0,d2
	qmove.l #0,d0
	clr.l d4
	rts
string_error:
	lea	bad_str(pc),a0
	bra.s	do_gen_error
reg_error:
	lea bad_reg_text(pc),a0
 	bra.s	do_gen_error

open_brack_error:
	lea open_brack_text(pc),a0
	bra.s	do_gen_error


close_brack_err:
	lea close_brack_text(pc),a0
	bra.s	do_gen_error

only_16_disp:	lea disp_16_text(pc),a0
	bra	do_gen_error


only_8_disp:	qmove.l	d0,-(sp)	*save offset
 	lea disp_8_text(pc),a0
 	bra.s	do_gen_error


comma_error_g:	lea comma_text_g(pc),a0
	bra.s	do_gen_error

address_error:	lea address_text(pc),a0
	bra.s	do_gen_error

scale_error_1:	lea	scale1_text(pc),a0
	bra	do_gen_error
	
scale_error_2:	lea	scale2_text(pc),a0
	bra	do_gen_error
offset_error:	lea	offset1_text(pc),a0
	bra	do_gen_error1
width_error:	lea	width1_text(pc),a0
	bra	do_gen_error1
	
************************************************************************************
offset_temp:	ds.b	6
scale1_text:	DC.B	"Unrecognised scale value - can be 1,2,4 or 8.",13,13,0
scale2_text:	dc.b	"Scale can be 1,2,4 or 8 - the scale here is too big.",13,13,0
twenty_mode_text:	DC.B	"Addressing mode not supported.",13,13,0
offset1_text:	DC.B	"Offset field syntax error.",13,13,0
width1_text:	dc.b	"Width field syntax error.",13,13,0
bad_first_op:	dc.b	"Illegal source operand addressing mode.",13,13,0
strings_only:	dc.b	"Can't use strings with operators.",13,13,0
bad_second_op:	dc.b	"Error in operand -  immediate data expected.",13,13,0
bad_str:	dc.b	"Bad String - close quotes expected.",13,130

	align
	global	get_mode,bitfield,twenty_modes,get_op_code_num
	global	get_op_code_num_i
	extern	comma_error,recurs_eval,print_warning2
	extern	replace_requs,evaluate
	extern	pass2_error
	extern	pass1_error	
	extern_data	op_buff,close_string,close_brack_text,bad_reg_text
	extern_data	disp_8_text,open_brack_text,disp_16_text
	extern_data	comma_text_g,address_text