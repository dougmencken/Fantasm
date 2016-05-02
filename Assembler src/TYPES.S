****SHIFTS - TYPE 14
****THREE FORMATS POSSIBLE
****SHIFT #COUNT,DX
****SHIFT DX,DY
****SHIFT <EA> (BY ONE BIT ONLY)
type14:
 bsr.l get_size12
 lsl.w #6,d0
 or.w d0,d1
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 tst.w d0
 beq.s shift_reg 	*dx,dy form
 cmpi.w #1,d0 		*illegal
 beq.l s_illegal_err
 cmpi.w #7,d0
 bne shift_mem 	*<ea> form
 cmpi.w #1,d2 		*if not immediate form then check memory.l
 beq shift_mem 
 cmpi.w #4,d2
 bne.l s_illegal_err
***immediate shift on data reg
 tst.w d3
 bmi.l s_illegal_err 	  *-ve shift count!
 cmpi.w #$8,d3
 bgt.l s_illegal_err 	  *count too great
 bne.s count_ok
 moveq #0,d3 		*8 is represented by 0
count_ok:
**LXT
	lsl.w	#8,d3
	lsl.w	#1,d3
	or.w	d3,d1
;	bfins	d3,d1{20:3}
 lea dest_op(a5),a3
 bsr.l get_mode
 tst.w d0
 bne.l d_illegal_err
 or.w d2,d1 		*mix in dest data reg
 qmove.w d4,size(a5) 	 *d4=2
 qmove.w d4,size2(a5)
 bsr insert_inst
 rts
shift_reg:
***devpac allows us to say asr.w d3, which is very nice,but totally illegal syntax
***we pick that up here.
 lea dest_op(a5),a3 	*check for nil dest op
 tst.b (a3)
 beq.s frig_shift
 qbset #5,d1 	 	 *immediate field is data reg
**LXT
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}
 lea dest_op(a5),a3
 bsr.l get_mode
 tst.w d0
 bne.l d_illegal_err
 or.w d2,d1
 qmove.w d4,size(a5)
 qmove.w d4,size2(a5)
 bsr insert_inst
 rts
***we simulate shift #1,dx
frig_shift:
 qbset #9,d1 	 	 * #1
 or.w d2,d1 		*reg in 0-2
 qmove.w #2,size(a5)
 qmove.w #2,size2(a5)
 bsr insert_inst
 rts
 
shift_mem:
***memory operands are limited to word size
***check size=1
 qmove.w d1,d6
 andi.w #$00c0,d6
 cmpi.w #$0040,d6
 bne size_err_2 	*not word size
 move.b #$c0,d1 	*make mem form
 or.w d2,d1 		*mix in reg
 lsl.w #3,d0
 or.w d0,d1 		*mix in mode
***heath robinson eat you're heart out over the next bit!***
 or.w scratch_6(a5),d1 	*mix in immediate field from caller
 qmove.w d4,size(a5)
 qmove.w #2,size2(a5) 	 *no 2nd op
 qmove.l d3,extension(a5)
 btst #4,flags(a5)
 beq.s equ1 		*was an equ, not a long 
 qbset #5,flags(a5) 	 *abs long for ext 1 (reloc)
equ1:
 bsr insert_inst
 rts_	"type_14"
	align 
****bit functions - type 13
****bchg,bclr,bset,btst
type13:
***needs basic instruction in d1
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 tst.w d0 		*mode 0
 beq bit_data 		*dreg mode btst d0,xxxx
 cmpi.w #7,d0
 bne.l s_illegal_err 	  *mode 7.4?
 cmpi.w #4,d2
 bne.l s_illegal_err

***this is immediate mode
 qmove.w d3,scratch_6(a5) 	 *save source data for now
 qmove.w d4,size(a5)
 lea dest_op(a5),a3
 bsr.l get_mode 		*get destination mode
 btst #4,flags(a5)
 beq.s imm_not_addr
 qbset #5,flags(a5)
imm_not_addr: 		*#fred,xxxx where fred is long needing reloc
 tst.w d0
 beq.s imm_dreg 		*data reg mode (0-31 allowed)
 cmpi.w #1,d0
 beq.l d_illegal_err	*an
 cmpi.w #7,d0
 bne.s imm_mem 		*immediate to mem (0-7 allowed)
**if bits 7&6 are clear then we can use 3, rather than 2 because it's a btst

 cmpi.w #2,d2
 bge.l d_illegal_err
 
***btst #5,fred
imm_mem:
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1 		*mix in addressing mode
 qbset #11,d1
 qbclr #8,d1 	 	 *make static form
 move.w scratch_6(a5),d5 	*get immediate data back
 bmi.l s_illegal_err 	  *-ve bit number!
 cmpi.w #7,d5
 bgt.l s_illegal_err 	  *too big
 andi.l #$7,d5
 qmove.l d5,extension(a5)
 qmove.w #4,size(a5)
 qmove.l d3,extension2(a5)
 qmove.w d4,size2(a5)
 btst #4,flags(a5)
 beq.s equ_actually
 qbset #6,flags(a5) 	 *extension 2 to reloc table
equ_actually:
 bsr insert_inst
 rts_	"type_13"
	align
***btst #3,dx 
imm_dreg:
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1 		*mix in addressing mode
 qbset #11,d1
 qbclr #8,d1 	 	 *make static form
 qmove.w scratch_6(a5),d5 	 *get immediate data back
 cmpi.w #31,d5 	*allow long operations for data regs
 bgt.l s_illegal_err 	  *too big
 andi.l #$1f,d5
 qmove.l d5,extension(a5)
 qmove.l d3,extension2(a5)
 qmove.w d4,size2(a5)
 bsr insert_inst
 rts_	"imm_dreg"
 	align
****this is data reg mode*** btst d0,d5
bit_data:
 move.w d2,scratch_6(a5) 	*save source data for now
 lea dest_op(a5),a3
 bsr.l get_mode 		*get destination mode
 btst #4,flags(a5) 	*mode 7.1?
 beq.s not_shft_mem
 qbset #6,flags(a5) 	 *reloc ext 2
not_shft_mem:
 tst.w d0
 beq.s d_dreg 		*data reg mode (0-31 allowed)
 cmpi.w #1,d0
 beq.l d_illegal_err
 cmpi.w #7,d0
 bne.s d_dreg 		*immediate to mem (0-7 allowed)
 cmpi.w #2,d2
 bge.l d_illegal_err
d_dreg:
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1 		*mix in addressing mode
 move.w scratch_6(a5),d2
 **LXT
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}
 qmove.l d3,extension(a5)
 qmove.w d4,size(a5)
 qmove.w #2,size2(a5)
 bsr insert_inst
 rts_	"bit_data"
	align
****immediate type 4
****basic code in d6
immediate:
 move.l a4,-(sp)
 bsr.l get_ops
 movea.l (sp)+,a4
 move.w d6,size2(a5)
 bsr.l get_size12
 move.w d0,d1 		*move size to d1
imm_entry: 	*type 1 enters here if immediate detected
***enter here needs size in lsb's of d1 and basic inst in size2(a5) 
 lea source_op(a5),a3
 bsr.l get_mode
 cmpi.w #7,d0
 bne.l illegal_err
 cmpi.w #4,d2
 bne.l	illegal_err
 qmove.w d4,size(a5)
 qmove.l d3,extension(a5)
 btst #4,flags(a5) 	*was it a label?
 beq.s not_immaddr 	*no
 qbset #5,flags(a5) 	 *yes, it was so address into reloc table please
not_immaddr:
 lea dest_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5) 	*an absolute label?
 beq.s not_imm_long
 qbset #6,flags(a5) 	 *reloc long
not_imm_long:
***check 0,2-6,7.0,7.1, and if eori/andi/ori 7.5,7.6
 lsl.w #6,d1
 qmove.w size2(a5),d6
 tst.w d0
 bmi.s srccr
; cmpi.w #0,d0
 beq.s imm_d_ok
 cmpi.w #2,d0
 beq.s imm_d_ok
 cmpi.w #3,d0
 beq.s imm_d_ok
 cmpi.w #4,d0
 beq.s imm_d_ok
 cmpi.w #5,d0
 beq.s imm_d_ok
 cmpi.w #6,d0
 beq.s imm_d_ok
 cmpi.w #1,d0
 beq.l illegal_err 	  *no #x,a0's please
 tst.w	d2
 beq.s imm_d_ok
 cmpi.w #1,d2
 beq.s imm_d_ok
 bra.l illegal_err
srccr:
**404 - find ccr or sr

	lea	dest_op(a5),a3
	cmpi.w	#"SR",(a3)
	beq.s	sr_ok
**change size to byte
	clr.l	d1		*byte size now!
sr_ok:
 qmoveq #7,d0 	 restore mode
 cmpi.w #$0a00,d6
 beq.s imm_d_ok 		*eori/andi/ori can use sr/ccr as well
not_eori:
 cmpi.w #$0200,d6 	*check andi
 beq.s imm_d_ok
not_andi:
 cmpi.w #$0000,d6 	*check ori
 beq.s imm_d_ok
 bra.l illegal_err
imm_d_ok:
 or.w d6,d1		*d1 is size
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1
 qmove.w d4,size2(a5)
 qmove.l d3,extension2(a5)
 bsr insert_inst
 rts_	"immediat"
 	align
***********************quick***********************************************
quick:
*type5 - addq/subq
*-----------------
***needs basic code in d6!
; move.w d6,-(sp)            *save op code
	move.w	d6,scratch_7(a5)	save op code
 move.l a4,-(sp)	*save size string pointer
 bsr.l get_ops
 movea.l (sp)+,a4
 bsr.l get_size12               *get size 0-2 ind1
 qmove.w d0,d1
 lea source_op(a5),a3
 bsr.l get_mode               *get addressing mode of source op
; move.w (sp)+,d6            *restore op code
	move.w	scratch_7(a5),d6
 cmpi.w #7,d0               *check immediate add mode
 bne.l illegal_err
 cmpi.w #4,d2
 bne.l illegal_err
 tst.w	d3
 bmi.s	too_big_quick
 cmpi.l #9,d3               *check data size
 bge.s too_big_quick
 
 cmpi.w #8,d3
 bne.s not_8                  *make 8=0
 moveq #0,d3
not_8:
 move.w d1,size2(a5)        *save instruction
 lsl.w #6,d1
**LXT
	lsl.w	#8,d3
	lsl.w	#1,d3
	or.w	d3,d1
;	bfins	d3,d1{20:3}
 or.w d6,d1                 *or in op code
 qmove.w #2,size(a5)         *2 byte inst.
 qmove.w d1,-(sp)            *save inst
 qmove.w size2(a5),d1        *get size in d1
 lea dest_op(a5),a3             *get dest reg
 bsr.l get_mode               *get dest addr mode
 btst #4,flags(a5)
 beq.s not_addq_long
 qbset #6,flags(a5)
not_addq_long:
 move.w (sp)+,d1            *restore inst
 tst.w d0
 bmi.l illegal_err 	  *not sr!
 cmpi.w #7,d0
 bne.s dest_q_ok
 tst.w	d2
 beq.s dest_q_ok
 cmpi.w #1,d2
 beq.s dest_q_ok
 bra.l illegal_err
dest_q_ok:
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1
 qmove.l d3,extension2(a5)
 qmove.w d4,size2(a5)
 bsr insert_inst
 rts
too_big_quick:
 lea quick_text(pc),a0
 bsr.l pass2_error
 rts

****************type 11****************************************************
****good for clr,neg,negx,not,tst
****needs basic code in d1
type_11:
 qmove.w d1,size2(a5)
 bsr.l get_ops
 bsr.l get_size12
 qmove.w d0,d1 		 *size in d1 for get_mode
 lea source_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s equ2
 qbset #5,flags(a5)
equ2:
 tst.w d0
 bmi.l illegal_err
; cmpi.w #0,d0
 beq.s m11_ok
 cmpi.w #1,d0
 beq.l illegal_err
 cmpi.w #7,d0
 blt.s m11_ok
 tst.w	d2
 beq.s m11_ok
 cmpi.w #1,d2
 beq.s m11_ok
 bra.l illegal_err
m11_ok:
 lsl.w #6,d1                *shift size
 or.w size2(a5),d1          *mix in op code
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1
 qmove.w d4,size(a5)
 qmove.l d3,extension(a5)
 qmove.w #2,size2(a5)
 bsr insert_inst
 rts


simple:
 qmove.w #2,size(a5)
 qmove.w #2,size2(a5)
 bsr insert_inst
 rts

***type 2 needs basic code in d1
***handles instructions of form:
***xxxx reg xxx mode reg
***divs,divu,muls,mulu 
**moded 031094 for long - syntax muls.l <ea>,dh-dl
**	              or muls.l <ea>,dn
type2:	cmpi.b	#"L",(a4)	long form?
	beq	type2_long	yes
 qmove.w d1,size2(a5) 	 *save op code
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s not_2_long
 qbset #5,flags(a5) 	 *ext1=long addr
not_2_long:
 cmpi.w #1,d0
 beq.l s_illegal_err
 cmpi.w #7,d0
 bne.s type2_ok
 cmpi.w #5,d2
 beq.l s_illegal_err
 cmpi.w #6,d2
 beq.l s_illegal_err
type2_ok:
 qmove.w size2(a5),d1 	 *get basic op
 lsl.w #3,d0 		*mix in source mode
 or.w d0,d1
 or.w d2,d1 		*and rf
 qmove.w d4,size(a5) 	 *save size
 qmove.l d3,extension(a5) 	 *and any extension
 lea dest_op(a5),a3
 bsr.l get_mode
 tst.b	2(a3)
 bne	div_illegal_err	*poss d0-d1 etc
 tst.w	d0
 bne.l d_illegal_err 	  *must be data reg!
**LXT
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}
 qmove.w d4,size2(a5)
 bsr insert_inst
 rts

**long has dest operand as first extension, cause its 32 bit instruction (2*16)
type2_long:	qmove.w	d1,size2(a5)	save instruction
	
	bsr.l	get_ops
	lea	dest_op(a5),a3	*dest op is either dh
			*or dh-dl - we sort it here
	cmpi.b	#"D",(a3)
	bne.l	d_illegal_err	must be data reg
	qmove.l	#$0800,d3	the extension
	qmove.w	#4,size(a5)
	qmove.b	1(a3),d0	*reg number
	subi.b	#"0",d0
	bmi	bad_dest_reg
	cmpi.b	#7,d0	v3.9c
	bgt	bad_dest_reg	make sure reg is valid
	
**this is muls32 bit
**lxt
	lsl.w	#8,d0
	lsl.w	#4,d0
	or.w	d0,d3
;	bfins	d0,d3{17:3}	insert dl at 12-14 of word
	tst.b	2(a3)	check for -
	bne.s	muls_64	32 bit only
	bra.s	done_mext
muls_64:	cmpi.b	#"D",3(a3)
	bne.l	d_illegal_err
	qmove.b	4(a3),d0
	subi.b	#"0",d0
	bmi	bad_dest_reg
	cmpi.b	#7,d0
	bgt	bad_dest_reg
	or.b	d0,d3	dh in bits 0-2
	qbset	#10,d3	set 64 bit mode	
done_mext:	move.l	d3,extension(a5)
	
	qmove.l	#2,d1	tell get mode the size is long v3.9b
	lea	source_op(a5),a3
	bsr.l	get_mode
	btst	#4,flags(a5)
	beq.s	not_ml_long
	qbset	#5,flags(a5) 	*ext1=long addr	
not_ml_long:	cmpi.w	#1,d0
	beq.l	s_illegal_err
	cmpi.w	#7,d0
	bne.s	type2l_ok
	cmpi.w	#5,d2
	beq.l	s_illegal_err
	cmpi.w	#6,d2
	beq.l	s_illegal_err
type2l_ok:	move.w	size2(a5),d5	get instruction back
	move.l	extension(a5),d6	get extension back
**find instruction
	cmpi.w	#$c1c0,d5	muls?
	bne.s	not_muls
	qmove.w	#$4c00,d1 	*make muls.s
	qbset	#11,d6
	bra.s	done_mull
not_muls:	cmpi.w	#$c0c0,d5	mulu
	bne.s	not_mulu
	qmove.w	#$4c00,d1
	qbclr	#11,d6
	bra.s	done_mull
not_mulu:	cmpi.w	#$81c0,d5	divs
	bne.s	not_divs
	qmove.w	#$4c40,d1
	qbset	#11,d6
**check dr, if zero copy dq into it!
	btst	#10,d6
	bne.s	done_mull
	qmove.b	d6,d7
	andi.b	#7,d7
	bne.s	done_mull	no need
**LXT
	qmove.w	d6,d7
	lsr.w	#8,d7
	lsr.w	#4,d7
	andi.b	#%111,d7
	or.b	d7,d6
;	bfextu	d6{17:3},d7	get dq
;	or.b	d7,d6	copy dq
	bra.s	done_mull
not_divs:	move.w	#$4c40,d1	divu
	qbclr	#11,d6
**check dr, if zero copy dq into it!
	btst	#10,d6
	bne.s	done_mull
	move.b	d6,d7
	andi.b	#7,d7
	bne.s	done_mull	no need
**LXT
	qmove.w	d6,d7
	lsr.w	#8,d7
	lsr.w	#4,d7
	andi.b	#%111,d7
	or.b	d7,d6
;	bfextu	d6{17:3},d7	get dq
;	or.b	d7,d6	copy dq

done_mull:
	qmove.l	d6,extension(a5)
	lsl.w	#3,d0 	*mix in source mode
	or.w	d0,d1
	or.w	d2,d1 	*and rf
	qmove.w	d4,size2(a5) 	*save size
	qmove.l	d3,extension2(a5) 	*and any extension
	bsr	insert_inst
	rts_	"type_2"
	align
**************************************************************************************
***make_inst1 handles instructions with the form
*** / / / ! / / / ! / / / ! / / / !
***x x x x r e g d siz mode  r e g
***it needs the basic code and size in d1
***i.e d080 = add.l
make_inst1:
 bsr get_d_regs 	*returns d6= 0,1,2 or 3 depending on posiotns of data reg(s)
* 		*also returns -1 if immediate data so we can use add.l #1,fred
*		*with out having to use the immediate form of the instruction.
 tst.w d6
 beq addaddr 		*no data regs, maybe adda/suba
 bmi.s type_1_immediate 	*just like devac.
 cmpi.w #1,d6 		*only source op?
 beq only_src_op
 cmpi.w #2,d6
 beq only_dest_op
***here both ops are data regs, so we put dest in reg field and clear bit 8
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}
* lsl.w #8,d2 		*shift reg to 9-11
* lsl.w #1,d2
* or.w d2,d1 		*insert dat reg as destination in instruction
 qmove.w #2,size2(a5)
 lea source_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s miok
 qbset #5,flags(a5)
miok:
 lsl.w #3,d0 		*shift mode to 3-5
 or.w d0,d1
 or.w d2,d1 		*mix in rf
 qmove.w d4,size(a5)
 qmove.l d3,extension(a5)
 bsr insert_inst 	*insert instruction into code buffer
 rts
 
*******type 1 to immediate conversion****************************************************

type_1_immediate:
 qmove.w d1,d2 		 *save inst and size
 andi.w #$00f0,d1 	*mask off size
 lsr.w #6,d1 		*get size in lsbs
***now we hav to replace the basic instruction with the immediate type by
***comparison
 andi.w #$f000,d2 	*mask off basic instruction
 cmpi.w #$d000,d2 	*add?
 bne.s not_add
 qmove.w #$0600,d2 	 *make addi
 qmove.w d2,size2(a5) 	 *save in right place for imm_entry
 bsr imm_entry
 rts
not_add:
 cmpi.w #$c000,d2
 bne.s not_and
 qmove.w #$0200,d2
 qmove.w d2,size2(a5)
 bsr imm_entry
 rts
not_and:
 cmpi.w #$9000,d2
 bne.s not_sub
 qmove.w #$0400,d2
 qmove.w d2,size2(a5)
 bsr imm_entry
 rts
not_sub:
 cmpi.w #$8000,d2 	*check or
 bne imm_err
 qmoveq #0,d2
 qmove.w d2,size2(a5)
 bsr imm_entry
 rts
*****************************************************************************************
 
****here only the source op is a data reg
only_src_op:
***first save destination mode,reg size and extension
***addressing modes not allowed for dest op:
***1,7.2,7.3,7.4,7.5,7.6
***1 means adda, all the rest are illegal
 tst.w d0
 bmi.l illegal_err 	  *sr as dest not allowed
 cmpi.w #1,d0
 beq addaddr 		*we need adda op code!
 cmpi.w #7,d0
 bne.s ok10
 cmpi.w #2,d2
 beq.l illegal_err
 cmpi.w #3,d2
 beq.l illegal_err
 cmpi.w #4,d2
 beq.l illegal_err
 btst #4,flags(a5)
 beq.s ok10
 qbset #6,flags(a5)
ok10:
 lsl.w #3,d0 		*shift mode to 3-5
 or.w d0,d1
 or.w d2,d1 		*mix in rf
 qmove.w d4,size2(a5)
 qmove.l d3,extension2(a5)
 lea source_op(a5),a3
 bsr.l get_mode
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}
 qbset #8,d1 	 	 *eff addr is dest
 qmove.w #2,size(a5)
 bsr insert_inst
 rts

****here only dest op is data reg
only_dest_op:
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}
 qmove.w #2,size2(a5)
 lea source_op(a5),a3
 qmove.w d1,-(sp) 	 *save inst
 move.w size(a5),d1 	*size in d1 in case of immediate data
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s odo_ok
 qbset #5,flags(a5)
odo_ok:
 move.w (sp)+,d1
 tst.w d0 
 bmi.l illegal_err 	  *sr/ccr not allowed for add/sub
 lsl.w #3,d0 		*shift mode to 3-5
 or.w d0,d1
 or.w d2,d1 		*mix in rf
 qmove.w d4,size(a5)
 qmove.l d3,extension(a5)
 bsr insert_inst
 rts

***here we've found summat like add.l d0,a3, which is a totally different op code!
***we hav dest mode etc in regs allready.
addaddr:
 qmove.w d1,d6
***check for add instruction
 andi.w #$f000,d6
 cmpi.w #$d000,d6
 bne.s not_adda 		*only add has specific adda instruction
 lsl.w #1,d1 		*make size 0=word,1=long in bit 8
 andi.w #$0100,d1 	*clear all but size
 or.w #$d0c0,d1 	*adda op code
 bra.s dest_addr
not_adda:
 cmpi.w #$9000,d6
 bne.l illegal_err 	  *as for adda
 lsl.w #1,d1
 andi.w #$0100,d1
 or.w #$90c0,d1 	*suba op code
***we come here if we have adda, or suba
dest_addr:
 lea dest_op(a5),a3
 bsr.l get_mode
 tst.w d0 		*check source add mode
 bmi.l illegal_err 	  *no sr or ccr pppplease.
 cmpi.w #1,d0 		*must be mode 1 -ax
 bne.l illegal_err
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}
 qmove.w #2,size2(a5) 	 *2 bytes for instruction and 2nd operand
 lea source_op(a5),a3
 qmove.w d1,scratch_6(a5) 	 *save inst
 qmove.w size(a5),d1
 bsr.l get_mode 		*get source add mode
 btst #4,flags(a5)
 beq.s da_ok
 qbset #5,flags(a5)
da_ok:
 qmove.w scratch_6(a5),d1
 tst.w d0
 bmi.l illegal_err
 lsl.w #3,d0 		*shift mode to 3-5
 or.w d0,d1
 or.w d2,d1 		*mix in rf
 qmove.l d3,extension(a5)
 qmove.w d4,size(a5)
 bsr.s insert_inst
 rts
  
*********h o t  s p o t **********
***insert_inst moves d1 (the instruction) into the code buffer
***and then moves any extension words as well ,depending on size and size2
insert_inst:
 movea.l code_buffer(a5),a3
 qmove.l pc(a5),d7
 qmove.w d1,(a3)+ 	 *save instruction in buffer
 addq.l #2,d7 	*inc pc
 cmpi.w #2,size(a5)
 beq.s no_m_one
 bsr.s move_extension 	*move extension to pc (word or long) and inc pc
no_m_one:
 cmpi.w #2,size2(a5)
 beq.s no_m_two
 bsr move_ext_two
no_m_two:
 qmove.l d7,pc(a5)
 qmove.l a3,code_buffer(a5)
 rts_	"insert_inst"
 
move_extension:
	subq.w	#4,size(a5)	4=word, 6=long
	beq.s	me_word
***here it is long
	qmove.l	extension(a5),(a3)+
***if st=1 and pass 2then we have to save the pc in reloc_table
***if bit 5 of flags is set for ext 1 and bit 6 for ext 2
 
 btst #1,flags(a5)	
 beq.s pass1_stu
 btst #5,flags(a5)
 beq.s pass1_stu 	*dont reloc long
 qmove.l reloc_tab_pos(a5),d5 	 *get position
 movea.l reloc_tab(a5),a4 	*get table
 move.l d7,0(a4,d5.l) 	*save pc in table
 addq.l #4,reloc_tab_pos(a5)
**if flags4(5) is set, then output line to log, showing abs ref
	btst	#5,flags4(a5)
	bne.s	show_abs
pass1_stu:	addq.l	#4,d7
	rts_	"move_extension"
me_word:	move.w	extension+2(a5),(a3)+
	addq.l	#2,d7
	rts_	"me_word"
 
show_abs:	save_all
	lea	abs_ref_text(pc),a0
	bsr.l	pass2_error
	restore_all
	bra.s	pass1_stu


move_ext_two:	subq.w	#4,size2(a5)
	beq.s	me_word2	its word sized
	move.l	extension2(a5),(a3)+ 	*save extension
***if st=1 and pass 2then we have to save the pc in reloc_table
 
	btst	#1,flags(a5)
	beq.s	pass1_stu2
	btst	#6,flags(a5) 		*reloc this long?
	beq.s	pass1_stu2
	qmove.l	reloc_tab_pos(a5),d5 	*get position
	movea.l	reloc_tab(a5),a4 	*get table
	qmove.l	d7,0(a4,d5.l) 	*save pc in table
	addq.l	#4,reloc_tab_pos(a5)
**if flags4(5) is set, then output line to log, showing abs ref
	btst	#5,flags4(a5)
	bne.s	show_abs

pass1_stu2:	addq.l #4,d7
	rts_	"move_ext_two"

me_word2:	move.w	extension2+2(a5),(a3)+
	addq.l	#2,d7
	rts_	"me_word2"



****get_d_regs returns d6=0=no data regs, 1=source data reg,2=dest data reg,3=both data reg 
****or -1 if source is immediate like and.w #1,fred (which should be andi.w)
get_d_regs:
 lea source_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s gr1ok
 qbset #5,flags(a5)
gr1ok:
 qmoveq #0,d6
**now see if its 7.4 (immediate)
 cmpi.w #7,d0
 bne.s not_imm
 cmpi.w #4,d2
 bne.s not_imm
 moveq #-1,d6
***now see if the destination is an address reg
 qmove.l d6,scratch_6(a5)
 lea dest_op(a5),a3
 bsr.l get_mode
 btst #4,flags(a5)
 beq.s gr2_ok
 qbset #6,flags(a5)
gr2_ok:
 qmove.l scratch_6(a5),d6
 cmpi.w #1,d0
 bne.s end_imm 		*not 1,so straight immediate
 moveq #0,d6 		*no data regs, not imm, so try adda
end_imm:
 rts
 
not_imm:
 tst.w d0
 bne.s not_s_data
 addq.w #1,d6 		*source=data reg
not_s_data:
 lea dest_op(a5),a3
 qmove.l d6,scratch_6(a5)
 bsr.l get_mode
 qmove.l scratch_6(a5),d6
 btst #4,flags(a5)
 beq.s gr3_ok
 qbset #6,flags(a5)
gr3_ok:
 tst.w d0
 bne.s not_d_data
 addq.w #2,d6
not_d_data:
***result in d6 with dest op data in d0,2,3 and 4
 rts
 
imm_err:
 lea imm_text(pc),a0
 bsr.l pass1_error
 rts

size_err_2:
 lea size_text_typ(pc),a0
 bsr.l pass1_error
 rts

bad_dest_reg:	lea	bad_d_reg(pc),a0
	bsr.l	pass1_error
	rts

div_illegal_err:
	lea	short_div(pc),a0
	bsr.l	pass1_error
	rts
	
***************************************************************************
quick_text:	dc.b	"Only 1-8 allowed for immediate data for addq or subq.",13,0
imm_text:	dc.b	"Error with immediate conversion.",13,13,0
size_text_typ:	DC.B	"Must be word size.",13,13,0
bad_d_reg:	DC.B	"Invalid destination data register.",13,13,0
abs_ref_text:	DC.B	"**ERROR** Absolute reference - code is not position independent",13
	dc.b	" - needs to be (pc) addressing mode - for example: ",13
	dc.b	"  lea	fred(pc),a0",13,13,0
	align
short_div:	dc.b	"The destination addressing mode is "
	dc.b	"either:",13
	dc.b	"a). Not legal for this instruction",13
	dc.b	"b). Mistyped.",13
	dc.b	"c). Or I'm going loopy in my old age?",13,13,0 
	align
	public	type14,type13,immediate,imm_entry,quick,type_11,simple
	public	type2,make_inst1,type_1_immediate,only_src_op
	public	only_dest_op,insert_inst,get_d_regs,size_err_2,bad_dest_reg
	global	abs_ref_text
	
	extern	get_size12,get_ops,source_op,dest_op,s_illegal_err
	extern	get_mode,d_illegal_err,pass1_error,pass2_warning,illegal_err
	extern	pass2_error,pass2_advice