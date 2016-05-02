
swap:
 bsr.l get_ops
 lea source_op(a5)(pc),a3
 bsr.l get_mode
 tst.w d0
 bne s_illegal_err
 move.w d2,d1
 or.w #$4840,d1
 move.w d4,size(a5)
 move.w #2,size2(a5) 	2=no extension
 bsr.l insert_inst
 rts_	"swap"
	align
tas:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 tst.w d0
 beq.s tas_ok
 cmpi.w #2,d0
 beq.s tas_ok
 cmpi.w #3,d0
 beq.s tas_ok
 cmpi.w #4,d0
 beq.s tas_ok
 cmpi.w #5,d0
 beq.s tas_ok
 cmpi.w #6,d0
 beq.s tas_ok
 tst.w	d2
 beq.s tas_ok
 cmpi.w #1,d2
 beq.s tas_ok
 bra illegal_err
tas_ok:
 btst #4,flags(a5)
 beq.s tas1
 qbset #5,flags(a5)
tas1:
 lsl.w #3,d0
 move.w #$4ac0,d1
 or.w d0,d1
 or.w d2,d1
 move.w d4,size(a5)
 move.l d3,extension(a5)
 move.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"tas"
 	align
unlk:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 cmpi.w #1,d0
 bne illegal_err
 move.w #$4e58,d1
 or.w d2,d1
 move.w d4,size(a5)
 move.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"unlk"
 	align
link:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 cmpi.w #1,d0
 bne s_illegal_err 	*must be adress reg
 or.w d2,d1 		*mix it in
 lea dest_op(a5),a3
 bsr.l get_mode
 cmpi.w #7,d0
 bne d_illegal_err 	*must be immediate
 cmpi.w #4,d2
 bne d_illegal_err
 cmpi.l #$32766,d3
 bgt link_err
 cmpi.l #-32768,d3
 blt link_err
 move.l d3,extension(a5)
 move.w d4,size(a5)
 move.w #2,size2(a5) 	2=no extension
 bsr.l insert_inst
 rts_	"link"
	align 
eor:
***unfortunately, like most 68k instructions, eor dont fit with owt
***else, so its coded seperately
***syntax: eor dx,<ea>
 bsr.l get_size12
 lsl.w #6,d0
 or.w d0,d1
 bsr.l  get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 cmpi.w #7,d0
 bne.s try_eor 		*we'll be clever and allow immediate mode
 cmpi.w #4,d2
 beq.s do_eor_imm 	*make it immediate
try_eor:
 tst.w d0
 bne s_illegal_err 	*must be data reg
 lsl.w #1,d2
 lsl.w #8,d2
 or.w d2,d1 		*mix in reg to 9-11
 lea dest_op(a5),a3
 bsr.l get_mode
 cmpi.w #1,d0
 beq d_illegal_err 	*not mode 1 for dest
 cmpi.w #7,d0
 bne.s eor_d_ok
 cmpi.w #2,d2
 bge d_illegal_err
eor_d_ok:
 btst #4,flags(a5)
 beq.s eor1
 qbset #6,flags(a5)
eor1:
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1
 move.l d3,extension(a5)
 move.w d4,size(a5) 
 bsr.l insert_inst
 rts
do_eor_imm:
 move.w #$0a00,size2(a5)
 lsr.w #6,d1
 andi.w #$0003,d1
 bsr.l imm_entry
 rts_	"eor"
 	align
eori:
 move.w d1,d6
 bsr.l immediate
 rts_	"eori"
 	align
movep:
***syntax movep.x d0,x(an)
***       movep.x x(an),d0
 move.b (a4),d0 	*get size
 bne.s got_char
 move.w #$0108,d1 	*basic inst with word size
 bra.s got_size_mp
got_char:
 cmpi.b #"W",d0
 bne.s try_l_mp
 move.w #$0108,d1
 bra.s got_size_mp
try_l_mp:
 cmpi.b #"L",d0
 bne mp_size_err 	*.b not allowed
 move.w #$0148,d1 	*movep.l
got_size_mp:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 tst.w d0
 beq.s reg_to_mem_3
 cmpi.w #5,d0 		*x(an)
 beq.s mem_to_reg_3
 bra s_illegal_err 	*source illegal mode
mem_to_reg_3:
 move.l d3,extension(a5) 	*offset
 move.w d4,size(a5)
 or.w d2,d1 		*mix in addr reg
 lea dest_op(a5),a3
 bsr.l get_mode
 tst.w d0
 bne d_illegal_err 	*dest must be data rg
 lsl.w #8,d2
 lsl.w #1,d2
 or.w d2,d1 		*mix in data reg
 move.w d4,size2(a5) 	*will be 2
 bsr.l insert_inst
 rts
 
reg_to_mem_3:
 qbset #7,d1 	 	 *reg to mem form
 lsl.w #8,d2
 lsl.w #1,d2
 or.w d2,d1 		*mix in data reg
 lea dest_op(a5),a3
 bsr.l get_mode
 cmpi.w #5,d0
 bne d_illegal_err
 or.w d2,d1 		*mix in addr reg
 move.l d3,extension(a5)
 move.w d4,size(a5)
 move.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"movep"
 	align
 	
abcd:	move.w	#$c100,d1 	*abcd op code
bcd_entry:	bsr.l	get_ops	*sbcd comes here
	lea	source_op(a5),a3
	bsr.l	get_mode
	tst.w	d0
	beq.s	abcd_data
	cmpi.w	#4,d0
	beq.s	abcd_addr
bcd_err:	lea	bcd_text(pc),a0
	bsr.l	pass1_error
	rts
**this is data reg form
abcd_data:	or.w	d2,d1	or in sreg
	lea	dest_op(a5),a3
	bsr.l	get_mode
	tst.w	d0
	bne.s	bcd_err	must be a data reg
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1	or in dest reg
	qbclr	#3,d1	data formof inst
	move.w	#2,size(a5)
	move.w	#2,size2(a5)
	bsr.l	insert_inst
	rts
abcd_addr:	or.w	d2,d1	or in sreg
	lea	dest_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#4,d0
	bne.s	bcd_err	must be a data reg
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1	or in dx
	qbset	#3,d1	data form of inst
	move.w	#2,size(a5)
	move.w	#2,size2(a5)
	bsr.l	insert_inst
	rts_	"abcd"
	align
	
addx:	bsr.l	get_size12 	*0=byte,1=word,2=long
	move.w	d0,d1	*size in d1
	lsl.w	#6,d1 	*size in right place 6-7
	or.w	#$d100,d1 	*addx op code
x_entry:	bsr.l	get_ops	*subx comes here
	lea	source_op(a5),a3
	bsr.l	get_mode
	tst.w	d0
	beq.s	addx_data
	cmpi.w	#4,d0
	beq.s	addx_addr
x_err:	lea	addx_text(pc),a0
	bsr.l	pass1_error
	rts
**this is data reg form
addx_data:	or.w	d2,d1	or in dy
	lea	dest_op(a5),a3
	bsr.l	get_mode
	tst.w	d0
	bne.s	x_err	must be a data reg
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1	or in dx
	qbclr	#3,d1	data form of inst
	move.w	#2,size(a5)
	move.w	#2,size2(a5)
	bsr.l	insert_inst
	rts
addx_addr:	or.w	d2,d1	or in dy
	lea	dest_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#4,d0
	bne.s	x_err	must be a data reg
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1	or in dx
	qbset	#3,d1	data form of inst
	move.w	#2,size(a5)
	move.w	#2,size2(a5)
	bsr.l	insert_inst
	rts_	"addx"
	align
chk:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 cmpi.w #1,d0
 beq s_illegal_err
 cmpi.w #7,d0
 bne.s chk_ok
 cmpi.w #5,d2
 beq s_illegal_err
 cmpi.w #6,d2
 beq s_illegal_err
chk_ok:
 btst #4,flags(a5)
 beq.s chk1
 qbset #5,flags(a5)
chk1:
 move.w #$4180,d1
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1
 move.w d4,size(a5)
 move.l d3,extension(a5)
 lea dest_op(a5),a3
 bsr.l get_mode
 tst.w d0
 bne d_illegal_err
 lsl.w #8,d2
 lsl.w #1,d2
 or.w d2,d1
 move.w d4,size2(a5)
 bsr.l insert_inst
 rts_	"chk"
	align
cmpm:	bsr.l	get_size12 	*0=byte,1=word,2=long
	move.w	d0,d1	*size in d1
	lsl.w	#6,d1 	*size in right place 6-7
	or.w	#$b108,d1 	*cmpm op code
	bsr.l	get_ops	*subx comes here
	lea	source_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#3,d0
	beq.s	cmpm_ok
cpm_err:	lea	cmpm_text(pc),a0
	bsr.l	pass1_error
	rts
**this is data reg form
cmpm_ok:	or.w	d2,d1	or in dy
	lea	dest_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#3,d0
	bne.s	cpm_err	must be a data reg
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1	or in dx
	move.w	#2,size(a5)
	move.w	#2,size2(a5)
	bsr.l	insert_inst
	rts

nbcd:	bsr.l	get_ops
	lea	source_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#1,d0
	beq	s_illegal_err
	cmpi.w	#7,d0
	bne.s	nbcd_mode_ok
	cmpi.w	#2,d2
	bge	s_illegal_err
nbcd_mode_ok:	btst	#4,flags(a5)
	beq.s	nbcd1
	qbset	#5,flags(a5)
nbcd1:	move.w	#$4800,d1
	or.w	d2,d1	or rf
	lsl.w	#3,d0	get am
	or.w	d0,d1	or am
	move.w	d4,size(a5)
	move.l	d3,extension(a5)
	move.w	#2,size2(a5)
	bsr.l	insert_inst
	rts_	"cmpm"
	align	 
	
negx:
 bsr.l type_11
 rts_	"negx"
 	align
roxl:
 move.w #$0400,scratch_2(a5)
 bsr type14
 rts
roxr:
 move.w #$0400,scratch_2(a5)
 bsr type14
 rts
 
sbcd:	move.w	#$8100,d1 	*abcd op code
	bra	bcd_entry

stop:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr.l get_mode
 cmpi.w #7,d0
 bne illegal_err
 cmpi.w #4,d2
 bne illegal_err
 move.w #$4e72,d1
 move.l d3,extension(a5)
 move.w #4,size(a5) 	*word size
 move.w #2,size2(a5) 	*no second extension
 bsr.l insert_inst
 rts_	"stop"
 	align
subx:	bsr.l	get_size12 	*0=byte,1=word,2=long
	move.w	d0,d1	*size in d1
	lsl.w	#6,d1 	*size in right place 6-7
	or.w	#$9100,d1 	*subx op code
	bra	x_entry
trapv:	bra.l	simple
	
link_err: 
; bset #7,flags(a5) 	 *error detected flag
;	st	global_err(a5)
 lea link_text(pc),a0
 bsr.l pass1_error
 rts_	"link_err"
 	align
mp_size_err:
; bset #7,flags(a5) 	 *error detected flag
;	st	global_err(a5)
 lea size_text_3(pc),a0
 bsr.l pass1_error
 rts_	"mp_sz_er"

******************************************************************************
link_text:	DC.B	"Displacement limited to 16 bits.",13,13,0
size_text_3:	dc.b	"Byte size not allowed with movep.",13,13,0
addx_text:	DC.B	"Only Dn,Dn and -(An),-(An) syntax allowed for"
	dc.b	" ADDX and SUBX instructions.",13,13,0
bcd_text:	DC.B	"Only Dn,Dn and -(An),-(An) syntax allowed for"
	dc.b	" ABCD and SBCD instructions.",13,13,0
cmpm_text:	DC.B	"Only (Ax)+ addressing mode allowed for CMPM "
	dc.b	"instruction.",13,13,0
	align
*****************************************************************************
 	global	swap,tas,unlk,link,eor,eori,movep,abcd,addx,chk,cmpm,nbcd,negx
	global	roxl,roxr,sbcd,stop,subx,trapv
	
	extern	get_mode
	extern	source_op,s_illegal_err,insert_inst,get_ops,illegal_err
	extern	dest_op,d_illegal_err,get_size12,imm_entry,immediate
	extern	pass1_error,type_11,type14,simple 