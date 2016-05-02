
******************************M O V E*****************************************************
move:
***here a4 points to size if any
 bsr.l get_size 		  *get size in d0 1=byte,2=long,3=word
 qmove.w d0,d1
 bsr.l get_ops 		  *gets source and dest_ops from a2
 lea source_op(a5),a3 	*point to source op
**beefed up in 406
	cmpi.b	#$22,1(a3)	string?
 	beq.s	not_movem2
	cmpi.w	#"-D",2(a3)	*check for movem
	beq	possibly_movem
	cmpi.w	#"/D",2(a3)	i.e.	move.l	d0/a0,-(sp)
	beq	possibly_movem	I do it all the time!
	cmpi.w	#"-A",2(a3)	*check for movem
	beq	possibly_movem
	cmpi.w	#"/A",2(a3)	i.e.	move.l	d0/a0,-(sp)
	beq	possibly_movem	I do it all the time!

not_movem2:
 bsr get_mode 		*returns add mode in d0,rf in d2,ext in d3 
 		*and size in d4
 btst #4,flags(a5) 	*check for reloc on ext 1
 beq.s moveok1
 qbset #5,flags(a5)
moveok1:
 lsl.w #8,d1		shift size to right place
 lsl.w #4,d1
***if d0 is -1 then its move from sr
 cmpi.w #-2,d0
 beq move_from_usp
 tst.w d0
 bmi move_f_sr
	btst	#4,flags4(a5)	*move to moveq?
	beq.s	not_op_move	*no
**we can only optimise longs, so check size
	cmpi.w	#%0010000000000000,d1
	bne.s	not_op_move	wrong size
	cmpi.w	#7,d0	*check for immediate
	bne.s	not_op_move
	cmpi.w	#4,d2
	bne.s	not_op_move
	cmpi.l	#127,d3	see if it'll fit
	bgt.s	not_op_move	nope
	cmpi.l	#-128,d3
	blt.s	not_op_move	nope
**check dest is a data reg
	qmove.b	dest_op(a5),d7
	cmpi.b	#"D",d7	check for a d
	bne.s	not_op_move	no good - doesnt start with a d
	qmove.l	dest_op(a5),d7
	lsr.l	#8,d7
	tst.b	d7
	bne.s	not_op_move	*byte 2 isnt zero
	qmove.w	dest_op(a5),d7
	cmpi.b	#"0",d7
	blt.s	not_op_move	*less than d0
	cmpi.b	#"7",d7	
	bgt.s	not_op_move	*greater than d7
**here the immediate data will fit in a moveq instruction
	addq.w	#4,optimisation_saving(a5)
	addq.w	#1,optimisation_count(a5)
	clr.l	d1	
	bsr	move_entry	make a quicky
	movem.l	a0/a1/a2/a3/a4,-(sp)
	lea	conv_quick_text(pc),a0
	move.l	a0,error_string_save(a5)
	bsr.l	  print_optimisation	debug purposes
	movem.l	(sp)+,a0/a1/a2/a3/a4	
	rts_	"moveq"
	align	 
not_op_move:
 qmove.l d3,extension(a5) 	 *save 1st extension if any
 qmove.w d4,size(a5) 	 *so we know the size of the extension
***mode in bits 3 to 5
***reg in 0-2
	lsl.w	#3,d0
	or.w	d0,d1

 or.w d2,d1 		*assemble source reg
 qmove.l d4,d5 		 *save size of instruction so far
fsr_ent: 		*movesr enters here
***now get dest op
 lea dest_op(a5),a3
**beefed up in 406
 cmpi.b	#$22,1(a3)	*string?
 beq.s	not_movem
	cmpi.w	#"-D",2(a3)	*check for movem - v3.9b
	beq	possibly_movem
	cmpi.w	#"-A",2(a3)
	beq	possibly_movem
	cmpi.w	#"/A",2(a3)	i.e.	move.l	d0/a0,-(sp)
	beq	possibly_movem	I do it all the time!
	cmpi.w	#"/D",2(a3)	i.e.	move.l	d0/a0,-(sp)
	beq	possibly_movem	I do it all the time!

not_movem:
 clr.l d3 		*clear old extension - <<<may not need this>>>
 bsr get_mode
***if d0=-1 then its move to sr
 cmpi.w #-2,d0
 beq move_to_usp
 tst.w d0
 bmi move_t_sr
 btst #4,flags(a5)
 beq.s moveok2
 qbset #6,flags(a5)
moveok2:
***check legality of mode
**if movea, then dont check ax as dest

; cmpi.w #1,d0 		 *ax?
;bne not_movea

;not_movea:
 cmpi.w #7,d0
 bne.s move_dest_ok

 cmpi.w #2,d2 		*x(pc)?
 beq d_illegal_err
 cmpi.w #3,d2 		*x(pc,xr.s)?
 beq d_illegal_err
 cmpi.w #4,d2
 beq d_illegal_err 	*#?
move_dest_ok:
 qmove.l d3,extension2(a5) 	 *save second extension if any
 qmove.w d4,size2(a5)
***normal dest_op
***mode in bits 6 to 8
***rf in bits 9 to 11
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}	*9-11 of d1
	lsl.w	#6,d0
	or.w	d0,d1
;	bfins	d0,d1{23:3}	*6-8 of d1
misc_move_ent:
 bsr.l insert_inst
 rts_	"move"
	align 
move_from_usp:
 qmove.w #$4e68,d1 	 *move usp,ax
 qmove.w #2,size(a5)
 clr.l	extension(a5)
 lea dest_op(a5),a3
 clr.l d3
 bsr get_mode
 cmpi.w #1,d0 		*address reg?
 bne d_illegal_err
 or.b d2,d1
 qmove.w #2,size2(a5)
 bsr.l insert_inst
 rts
move_to_usp:
 qmove.w #$4e60,d1 	 *move ax,usp
 lea source_op(a5),a3
 clr.l d3
 bsr get_mode
 cmpi.w #1,d0
 bne s_illegal_err
 or.b d2,d1
 qmove.w #2,size(a5)
 clr.l	extension(a5)
 qmove.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"move_f_s"
 	align
 
**************************************************************************************

***move sr,xxxx
***ignore size!
move_f_sr:
 cmpi.l #$43435200,(a3) 	*'ccr?'
 bne.s move_from_sr 	  *no move from ccr instruction!
 qmove.w	#$42c0,d1	*move from ccr
 bra.s	done_movesr
move_from_sr:
 qmove.w #$40c0,d1 	 *move from sr
done_movesr:
 clr.l	extension(a5) 	     *no source ext
 qmove.w #2,size(a5) 	 *size=2
 lea dest_op(a5),a3
 clr.l d3 		*clear old extension - <<<may not need this>>>
 bsr get_mode
 btst #4,flags(a5)
 beq.s moveok3
 qbset #6,flags(a5)
moveok3:
 tst.w d0
 bmi d_illegal_err 	*cnat have move sr,sr!
 cmpi.w #1,d0
 beq d_illegal_err 	*move.w sr,a0
 cmpi.w #7,d0
 bne.s move_fsr_ok
 cmpi.w #2,d2 		*sr,x(pc)?
 beq d_illegal_err
 cmpi.w #3,d2 		*sr,x(pc,xr.s)?
 beq d_illegal_err
 cmpi.w #4,d2
 beq d_illegal_err 	*sr,#xxxx?
move_fsr_ok:
 qmove.l d3,extension2(a5) 	 *save second extension if any
 qmove.w d4,size2(a5)
**dest_op
***mode in bits 3 to 5
***rf in bits 0 to 2
 or.w d2,d1 		*reg in 0-2
 lsl.w #3,d0
 or.w d0,d1 		*mode in 3 to 5
 bra misc_move_ent

*************************************************************************************
***move xxxx,sr 
***d2=rf, d0=mode, source mode in d1 3-5
move_t_sr:
 andi.w #$0ff,d1 	source mode is in d1 3-5
 move.w d1,d0 		get mode
 lsr.w #3,d0 		test it for 1
 cmpi.w #1,d0
 beq s_illegal_err 	*not allowed
 cmpi.l #$43435200,(a3) 	*'ccr'
 beq.s move_to_ccr 	*move xxxx,ccr
 or.w #$46c0,d1 	*move xxxx,sr
 qmove.w #2,size2(a5)
 bra misc_move_ent
move_to_ccr:
 or.w #$44c0,d1 	*move to ccr
 move.w #2,size2(a5)
 bra misc_move_ent
**************************************************************************************

 
******************************* a d d ************************************************
add:
***here a4 points to size if any
 bsr.l get_size12 	  *get size in d0 0=byte,1=long,2=word
 qmove.w d0,size(a5) 	 *for use later in add #xxxx,xxx
 qmove.w d0,d1 		 *get size in d1
 lsl.w #6,d1
 or.w #$d000,d1 	*basic instruction
	qmove.l	a4,scratch_3(a5)	save size char
	bsr.l get_ops

	qmove.w	d1,scratch_5(a5)	save inst so far	
	btst	#3,flags4(a5)	*optimise add to addq?
	beq.s	normal_add	no
	qmove.b	source_op(a5),d7	*see if immediate
	cmpi.b	#"#",d7
	bne.s	normal_add	*not immediate
	lea	source_op(a5),a3
	qmove.w	size(a5),d1	set up for get mode
	bsr	get_mode	returns immediate data in d3
	tst.l	d3
	bmi.s	normal_add	negative 
	cmpi.l	#8,d3
	bgt.s	normal_add	too big
	tst.b	d3
	beq.s	normal_add	*dont optimise zeros!!! v4
	move.l	scratch_3(a5),a4	point to size char
	move.w	size(a5),d6
;	tst.w	d6
	bne.s	shift_size
	moveq	#1,d6
shift_size:	lsl.w	#1,d6	if 1 then save = 2 else 4 bytes
	add.w	d6,optimisation_saving(a5)
	addq.w	#1,optimisation_count(a5)

	bsr.s	addq	hand control over to addq as
	movem.l	a0/a1/a2/a3/a4,-(sp)
	lea	conv_quick_text_add(pc),a0
	move.l	a0,error_string_save(a5)
	bsr.l	  print_optimisation	debug purposes
	movem.l	(sp)+,a0/a1/a2/a3/a4	
	rts		add and addq have same dest addr modes
	
normal_add:	move.w	scratch_5(a5),d1	get inst back
	bsr.l make_inst1 	*form xxxxregdszmodreg
	rts_	"add"
 	align
addi:		*checked!
 qmove.w #$0600,d6 	 *immediate needs data in d6
 bsr.l immediate
 rts
addq:		*checked!
 qmove.w #$5000,d6
 bsr.l quick
 rts_	"addi"
 	align
*******************************s u b****************************************************
sub:
***here a4 points to size if any
 bsr.l get_size12 	  *get size in d0 0=byte,1=long,2=word
 qmove.w d0,size(a5) 	 *for use later in add #xxxx,xxx
 qmove.w d0,d1 		 *get size in d1
 lsl.w #6,d1
 or.w #$9000,d1 	*basic sub instruction

	qmove.l	a4,scratch_3(a5)	save size char
	bsr.l get_ops

	qmove.w	d1,scratch_5(a5)	save inst so far	
	btst	#3,flags4(a5)	*optimise sub to subq?
	beq.s	normal_sub	no
	qmove.b	source_op(a5),d6	*see if immediate
	cmpi.b	#"#",d6
	bne.s	normal_sub	*not immediate
	lea	source_op(a5),a3
	qmove.w	size(a5),d1	set up for get mode
	bsr	get_mode	returns immediate data in d3
	tst.l	d3
	bmi.s	normal_sub	negative 
	cmpi.l	#8,d3
	bgt.s	normal_sub	too big
	qmove.l	scratch_3(a5),a4	point to size char
	move.w	size(a5),d6	size is 0-2
;	tst.w	d6
	bne.s	shift_sizes
	moveq	#1,d6	if 0 make 1
shift_sizes:	lsl.w	#1,d6	else size * 2
	add.w	d6,optimisation_saving(a5)
	addq.w	#1,optimisation_count(a5)

	bsr.s	subq	hand control over to addq as
	movem.l	a0/a1/a2/a3/a4,-(sp)
	lea	conv_quick_text_sub(pc),a0
	move.l	a0,error_string_save(a5)
	bsr.l	  print_optimisation	debug purposes
	movem.l	(sp)+,a0/a1/a2/a3/a4	
	
	rts_	"sub_rout"
	align	 
normal_sub:	move.w	scratch_5(a5),d1	get inst back
	bsr.l	make_inst1 	*form xxxxregdszmodreg
	rts_	"sub"
	align
subi:		*checked!
 qmove.w #$0400,d6
 bsr.l immediate 
 rts_	"subi"
	align
subq:		*checked!
 qmove.w #$5100,d6
 bsr.l quick
 rts_	"subq"
 	align
*****************************c m p******************************************************
cmp:
***i've coded cmp on its own for speed, rather than lump it in with type 2 etc
***syntax: cmp ea,dn *or* cmp ea,an, *or* cmp #x,ea
***cmp handles cmp,cmpa,cmpi and is clever enough to spot and correct
***mistakes - ie cmp.l d0,a0 should be cmpa.l d0,a0
 bsr.l get_size12 	  *0=byte,1=word,2=long
 qmove.w d0,d1 		 *size in d1
 qmove.w d1,-(sp) 	 *save size for get_mode
 lsl.w #6,d1 		*size in right place 6-7
 or.w #$b000,d1 	*cmp op code
 bsr.l get_ops
 lea source_op(a5),a3
 qmove.w d1,size2(a5) 	 *save basic inst
 qmove.w (sp)+,d1 	 *get mode needs size in d1 as 0,1 or 2 (bwl)
 bsr get_mode
 qmove.w size2(a5),d1 	 *getbasic inst back
 tst.w d0
 bmi s_illegal_err 	*sr/ccr not allowed - all else is
***now we check for immediate source so we're easy to use.
 cmpi.w #7,d0
 bne.s not_cmpi
 cmpi.w #4,d2
 beq really_cmpi
not_cmpi:
*	bfins	d0,d1{26:3}
	lsl.w	#3,d0
	or.w	d0,d1

 or.w d2,d1 		*mix in rf
 qmove.l d3,extension(a5)
 qmove.w d4,size(a5)
 btst #4,flags(a5)
 beq.s cmp0ok
 qbset #5,flags(a5)
cmp0ok:
 lea dest_op(a5),a3
 bsr get_mode 		*dest mode must either be 0(d) or 1 (a)
 cmpi.w #1,d0
 beq.s cmp_addr 	*if 1 then make cmpa
 cmpi.w	#3,d0	*dest=(a0)+?
 beq	need_cmpm	*tell user to use cmpm
 tst.w d0
 bne data_err 		*destination must be data reg

	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}	*9-11 of d1
 qmove.w #2,size2(a5)
 bsr.l insert_inst 	  *plonk the instruction into buffer
 rts_	"cmp"
 	align
***this next bit does cmpa which is totally different!
cmp_addr:
 qmove.w d1,d5 		 *save source addressing mode
 andi.w #$00c0,d1 	*mask size - v3.98
 lsl.w #1,d1 		*move size=0=word/1=long to bit 8 for cmpa
 or.w #$b0c0,d1 	*make cmpa
 andi.w #$3f,d5 	*mask source addressing mode
 or.w d5,d1 		*mix it in
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1	
;	bfins	d2,d1{20:3}	*9-11 of d1
 qmove.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"cmpa"
 	align
***here the user has summut like cmp #2,fred, which is illegal as it should be cmpi,
***but because i'm nice, i'll do it for them.
really_cmpi:
***we wont call immediate because we use a lot of cmpi's, we'll code it.
***we have basic instruction plus size in d1

 andi.w #$00f0,d1 	*mask off size
 or.w #$0c00,d1 	*make cmpi
 qmove.l d3,extension(a5) 	 *save source extension
 qmove.w d4,size(a5) 	 *and size
 btst #4,flags(a5)
 beq.s cmp_imm_a_ok
 qbset #5,flags(a5) 	 *cmpi.l #fred,d0 where fred is address!
cmp_imm_a_ok:
 lea dest_op(a5),a3
 bsr get_mode 		*dest mode cant be 1, or 7.2 upwards
 cmpi.w #1,d0
 beq.s cmp_imm_addr 	*oh dear, cmp #xx,ax
 cmpi.w #7,d0
 bne.s rcmpi_dok
 cmpi.w #2,d2
 bge d_illegal_err 
rcmpi_dok:
 *	bfins	d0,d1{26:3}
 	lsl.w	#3,d0
	or.w	d0,d1

 or.w d2,d1
 qmove.l d3,extension2(a5)
 qmove.w d4,size2(a5)
 btst #4,flags(a5)
 beq.s cmp_equ
 qbset #6,flags(a5)
cmp_equ:
 bsr.l insert_inst
 rts_	"cmpi"
 	align
***here we handle cmp.l #x,ax
cmp_imm_addr:
 andi.w #$00f0,d1 	*mask off size
 ori.w #$3c,d1 	*make mode immediate
 bra cmp_addr
cmpa:
 bra cmp 		*if ever the cmpa instruction is used, we bra to cmp!
 
cmpi:		*checked!
 qmove.w #$0c00,d6
 bsr.l immediate
 rts_	"act_cmpi"
 	align
need_cmpm:	lea	cmpm1_text(pc),a0
	bsr.l	pass2_error
	rts_	"need_cpm"
	align
********************************e x t***************************************************
ext:
*size needs to be 10 for word and 11 for long
 tst.b (a4)
 bne.s try_w
 qmove.w #$4880,d1 	 *if no size we assume w
 bra.s done_size
try_w:
 cmpi.b #"W",(a4)
 bne.s try_l
 qmove.w #$4880,d1 	 *basic inst+size in 6-7
 bra.s done_size
try_l:
 cmpi.b #"L",(a4)
 bne size_err 		*cant ext.b
 qmove.w #$48c0,d1
 cmpi.b	#"B",-2(a4)	*v2 extb.l
 bne.s	done_size
 	move.w	#$49c0,d1	v2
	
done_size:
 bsr.l get_ops
 lea source_op(a5),a3
 bsr get_mode
 tst.w d0
 bne s_illegal_err 	*must be mode 0 (data reg)
 or.w d2,d1 		*must in reg
 qmove.w d4,size(a5)
 qmove.w d4,size2(a5)
 bsr.l insert_inst
 rts_	"ext"
 	align
********************************l e a***************************************************
lea:		*checked!

 bsr.l get_ops
 lea source_op(a5),a3
 qmoveq #2,d1 	 	 *long size for get_mode
 bsr get_mode
	cmpi.w	#7,d0
	bne.s	not_extended
	cmpi.w #4,d2
	bge	s_illegal_err
	bra.s	lea_ok
	
not_extended:
	cmpi.w #2,d0
	beq.s lea_ok
	cmpi.w #5,d0
	beq.s lea_ok
	cmpi.w #6,d0
	beq.s	lea_ok	
	bra s_illegal_err
lea_ok:
 btst #4,flags(a5)
 beq.s lea1
 qbset #5,flags(a5)
lea1:
 qmove.w #$41c0,d1
 lsl.w #3,d0
 or.w d0,d1
 or.w d2,d1
 qmove.w d4,size(a5)
 qmove.l d3,extension(a5)
 lea dest_op(a5),a3
 bsr get_mode
 cmpi.w #1,d0
 bne illegal_err1 	*youll have to try hard to get this string up!
 	lsl.w	#8,d2
 	lsl.w	#1,d2
 	or.w	d2,d1
 ;	 bfins	 d2,d1{20:3}
 
 qmove.w d4,size2(a5)
 bsr.l insert_inst
 rts_		"lea"
 	align
 
****************************m o v e m v1.1********************************************* 
movem:
***we cant use get_ops because of the syntax involved
 tst.b (a4) 		*check size
 bne.s try_word
 qmove.w #$4880,d1 	 *no size assume word
 bra.s got_m_size
try_word:
 cmpi.b #"W",(a4)
 bne.s try_long
 qmove.w #$4880,d1
 bra.s got_m_size
try_long:
 cmpi.b #"L",(a4)
 bne size_err
 qmove.w #$48c0,d1
got_m_size:
***now we see which way round the instruction is by calling get_mode with
***the source op. if its d0-d5,-(sp) or summat, we'll get mode 0
***if its a0-a??,-(sp), we'll get mode 1
***else we'll get another mode - 2 etc
 clr.l d3 		*extension word
 bsr.l get_ops
 lea source_op(a5),a3
 bsr get_mode
**addressing modes allowed for mem to reg
 
 tst.w	d0		*d0....
 beq.s	reg_to_mem
 cmpi.w	#1,d0		*a0....
 beq.s	reg_to_mem
 bra	mem_to_reg

reg_to_mem:
 clr.l d3 		
***here we're faced with a register list in a3
***we have to convert to:
*d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 a3 a4 a5 a6 a7 in extension(a5)
*this list is in d3
***we allow xn-xn and xn/xn/xn syntax
get_next:
 tst.b (a3)
 beq.s end_get 		*end of list
 bsr get_reg 		*get reg in d0 in form of xxxdxnnn where d=1 if data reg
 bmi movem_err_2 	*bad reg in list
 qmove.b d0,d6
 bsr save_reg 		*put reg in right place in d3
 cmpi.b #"-",(a3)
 beq.s get_run 		*d0/d5
 tst.b (a3)
 beq.s end_get
 addq.l #1,a3
 bra.s get_next
get_run:
**this bit does dx-dx
 addq.l #1,a3 		*skip -
 bsr get_reg 		*get ending reg in d0
 bmi movem_err_2 	*bad reg in list
 qmove.b d0,d7 		 *d6=start reg,d7=end reg
 qmove.b d6,d0
 andi.b #7,d0 		*who was it who said 'assembly language isnt fun'?
 qmove.b d7,d4
 andi.b #7,d4
 cmp.b d0,d4
 ble movem_err_3 	*start reg is <= end reg.
 btst #4,d6 		*data regs?
 beq.s do_loop
 qbset #4,d7 	 	 *yes set bit 4
**now count upto end reg
do_loop:
 qmove.b d6,d0 		 *save this reg in d3
 bsr save_reg
 addq.b #1,d6 		*inc low reg
 cmp.b d6,d7
 bge.s do_loop 		*gone past high reg - no carry on.
 tst.b (a3) 		*end of string?
 beq.s end_get
 cmpi.b #"/",(a3)
 bne slash_err 	*/ expected
 addq.l #1,a3 		*skip /
 bra.s get_next
end_get:
***here we've got the register list for move to -(ax) in d3
***and we've the basic instruction and size in d1
	qmove.l	d3,extension(a5)	save list
	lea	dest_op(a5),a3
	bsr	get_mode
	cmpi.w	#2,d0		*check dest modes for reg ->mem
	beq.s	rev_list	*reverse bit list if not -(an)
	cmpi.w	#4,d0	*-(an)
	beq.s	mmrm_mode_ok
	cmpi.w	#5,d0
	beq.s	rev_list	*x(an)
	cmpi.w	#6,d0
	beq.s	rev_list	*x(an,dx.s)
	cmpi.w	#7,d0
	bne	d_illegal_err
	cmpi.w	#1,d2	check rf < 2
	bgt	d_illegal_err
rev_list:	bsr.s	reverse_list
mmrm_mode_ok:	lsl.w	#3,d0
	or.w	d0,d1

*	bfins	d0,d1{26:3}
	or.w	d2,d1

	btst #4,flags(a5)
	beq.s mmrm_not_long
	qbset #6,flags(a5)	 relocate extention 1
mmrm_not_long:	move.w	#4,size(a5)
	qmove.l	d3,extension2(a5)
	qmove.w	d4,size2(a5) 	*no extension 2
	bsr.l	insert_inst
	rts_	"movem"
	align
**reverse list changes list from d0-d7,a0-a7
**to 		 a7-a0,d7-d0 
**for modes that arent -(an)
**must preserve d0-d4
reverse_list:	movem.l	d0/d1,-(sp)	save these
	qmove.l	extension(a5),d5	get list
	clr.l	d6	op reg
	qmove.w	d5,d7	save list
**first do data bits in 8-15
	lsr.w	#8,d5	get data in 0-7
	qmoveq	#7,d0	bit counter
tst_data:
**LXT change
	btst	#0,d5
	beq.s	do_d_lp
;	ror.b	d5	get bits in carry
;	bcs.s	setbit
;	bra.s	do_d_lp
setbit:	qbset	d0,d6
do_d_lp:
	lsr.w	#1,d5
	dbra	d0,tst_data
**now do address bits in 0-7
	clr.l	d1	address bits built here
	moveq	#7,d0
tst_addr:
	btst	#0,d7
	beq	do_a_lp
;	ror.b	d7
;	bcs.s	setbita
;	bra.s	do_a_lp
;	bcc.s	do_a_lp
setbita:	qbset	d0,d1
do_a_lp:
	lsr.w	#1,d7
	dbra	d0,tst_addr
	lsl.w	#8,d1	make addr bits in 8-15
	or.w	d1,d6	or in with data in 0-7
	ext.l	d6	
	qmove.l	d6,extension(a5)
	movem.l	(sp)+,d0/d1
	rts_	"rev_list"
	align
***********************mem to regs***************************************************** 
mem_to_reg:
***here we're faced with a register list in a3
***we have to convert to:
*a7 a6 a5 a4 a3 a2 a1 d7 d6 d5 d4 d3 d2 d1 d0 in extension(a5)
*this list is in d3
***we allow xn-xn and xn/xn/xn syntax

	btst	#4,flags(a5)	*source needs reloc?
	beq.s	smtr_ok
	qbset	#6,flags(a5)
smtr_ok:	
**now for a frig, if mode=x(pc) or x(pc,dx.s) we have to sub 2 from d3!
	cmpi.w	#7,d0
	bne.s	no_movem_frig
	tst.w	d2
	beq.s	no_movem_frig
	cmpi.w	#1,d2
	beq.s	no_movem_frig
	subq.l	#2,d3	the frig
no_movem_frig:	move.l	d3,extension2(a5)
	qmove.w	d4,size2(a5)	*as first extension is reg list!	
	save_all
	lea dest_op(a5),a3	v3.75 - replace regs

	bsr.s patch
	restore_all	* get mode wants quick exit to branch table....
	rts
patch:
	bsr get_mode		* double blind for get mode....
	addq.l #4,sp	* get rid of spare return address
	
	
	restore_all
 	lea dest_op(a5),a3 	*register list
 
 	clr.l	d3
get_nextmr:
 tst.b (a3)
 beq.s end_getmr 		*end of list
 bsr get_reg 		*get reg in d0 in form of xxxdxnnn where d=1 if data reg
 bmi movem_err_2 	*bad reg in list
 move.b d0,d6
 bsr save_regmr 		*put reg in right place in d3
 cmpi.b #"-",(a3)
 beq.s get_runmr 		*d0/d5
 tst.b (a3)
 beq.s end_getmr
 addq.l #1,a3
 bra.s get_nextmr
get_runmr:
**this bit does dx-dx
 addq.l #1,a3 		*skip -
 bsr get_reg 		*get ending reg in d0
 bmi movem_err_2 	*bad reg in list
 qmove.b d0,d7 		 *d6=start reg,d7=end reg
 qmove.b d6,d0
 andi.b #7,d0 		*who was it who said 'assembly language isnt fun'?
 qmove.b d7,d4
 andi.b #7,d4
 cmp.b d0,d4
 ble movem_err_3 	*start reg is <= end reg.
 btst #4,d6 		*data regs?
 beq.s do_loopmr
 qbset #4,d7 	 	 *yes set bit 4
**now count upto end reg
do_loopmr:
 qmove.b d6,d0 		 *save this reg in d3
 bsr save_regmr
 addq.b #1,d6 		*inc low reg
 cmp.b d6,d7
 bge.s do_loopmr 	*gone past high reg - no carry on.
 tst.b (a3) 		*end of string?
 beq.s end_getmr
 cmpi.b #"/",(a3)
 bne slash_err 	*/ expected
 addq.l #1,a3 		*skip /
 bra.s get_nextmr
end_getmr:
 qmove.w	#4,size(a5)
 qmove.l	d3,extension(a5)	*save bit list
***here we've got the register list for move from (ax)+ in d3
***and we've the basic instruction and size in d1 - we hav to change the instruction
	qbset	#10,d1	*make movem.l mem,.......
	lea	source_op(a5),a3
	bsr	get_mode
	cmpi.w	#2,d0
	beq.s	mmmr_mode_ok	(an)
	cmpi.w	#3,d0	
	beq.s	mmmr_mode_ok	(an)+
	cmpi.w	#5,d0
	beq.s	mmmr_mode_ok	(x(an)
	cmpi.w	#6,d0
	beq.s	mmmr_mode_ok	*x(an,dx.s)
	cmpi.w	#7,d0
	bne	s_illegal_err
	cmpi.w	#3,d2
	bgt	s_illegal_err
mmmr_mode_ok:	
	lsl.w	#3,d0
	or.w	d0,d1

*	bfins	d0,d1{26:3}
	or.w	d2,d1
	bsr.l	insert_inst
	rts_	"mem_to_r"
	align
  
save_reg:
 btst #4,d0 		*data reg?
 bne.s do_data 		*yes
**this is an address reg, which goes 7-0
 qmoveq #7,d2
 andi.b #$7,d0
 sub.b d0,d2 		*make right bit
 qbset d2,d3 	 	 *set addr reg bit
 rts_	"save_reg"
 	align
do_data:
 qmoveq #15,d2
 andi.b #$7,d0
 sub.b d0,d2
 qbset d2,d3 	 	 *set data reg bit
 rts_	"do_data "
 	align

save_regmr:
 btst #4,d0 		*data reg?
 bne.s do_datamr 		*yes
**this is an address reg, which goes 7-0
 qmoveq #7,d2
 andi.b #$7,d0
 addi.b #8,d0
 qbset d0,d3 	 	 *set addr reg bit
 rts
 
do_datamr:
 andi.b #$7,d0
 qbset d0,d3 	 	 *set data reg bit
 rts
  
  
get_reg:
 clr.w d0 		*reg is built in d0
 cmpi.b #"D",(a3)+
 bne.s got_reg
 qbset #4,d0 	 	 *set d bit
got_reg:
 qmove.b (a3)+,d2 	 *get reg number
 sub.b #$30,d2 	*make real number
 bmi.s reg_error_i1 	*error
 cmpi.b #7,d2
 bgt.s reg_error_i1
 or.b d2,d0		*warning!
 rts
 
reg_error_i1:
 moveq #-1,d0
 rts
****************************m o v e q*********************************************
moveq:		*checked!
 bsr.l get_ops
 lea source_op(a5),a3
 bsr get_mode
 cmpi.w #7,d0
 bne s_illegal_err
 cmpi.w #4,d2
 bne s_illegal_err
 cmpi.w #255,d3
	bgt	mq_too_big
 cmpi.w #-128,d3
 blt mq_too_small
move_entry:		*optimised moves enter here
 qmove.b d3,d1
 or.w #$7000,d1             	*moveq
 move.w #2,size(a5)
 lea dest_op(a5),a3
 bsr get_mode
 tst.w d0 		*must be a data reg
 bne data_err 		*
	lsl.w	#8,d2
	lsl.w	#1,d2
	or.w	d2,d1
;	bfins	d2,d1{20:3}	*9-11 of d1

 qmove.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"moveq"
 	align
****************************t r a p**********************************************
trap:		*checked!
 bsr.l get_ops
 lea source_op(a5),a3
 bsr get_mode
 cmpi.w #7,d0
 bne s_illegal_err
 cmpi.w #4,d2
 bne s_illegal_err
 cmpi.w #15,d3
 bgt trap_err
 qmove.w #$4e40,d1
 or.w d3,d1                 	*insert trap into ls nibble
 qmove.w #2,size(a5) 	 *no extensions
 qmove.w #2,size2(a5)
 bsr.l insert_inst
 rts_	"trap"
 	align
******************************a n d********************************************** 

and:		*checked!
***here a4 points to size if any
***and uses the same format as add, with a0 not allowed as a source mode
***so we have to check for that here
 bsr.l get_size12 	  *get size in d0 0=byte,1=long,2=word
 qmove.w d0,size(a5) 	 *for use later in add #xxxx,xxx
 qmove.w d0,d1 		 *get size in d1
 lsl.w #6,d1
 or.w #$c000,d1 	*basic instruction
 bsr.l get_ops
 lea source_op(a5),a3
 bsr get_mode
 btst #4,flags(a5)
 beq.s and1
 qbset #5,flags(a5)
and1:
 cmpi.w #1,d0 		*mode 1 source?
 beq and_err 		                      *all the other modes are the same as add.
 bsr.l make_inst1 	  *form xxxxregdszmodreg
 rts_	"and"
	align
andi:		*checked!
 qmove.w #$0200,d6
 bsr.l immediate
 rts_	"andi"
 	align
********************e r r o r s ************************************************	 
illegal_err:
 lea illegal_text(pc),a0
 bsr.l pass1_error
 rts
 
s_illegal_err:		*source error
 lea s_ill_text(pc),a0
 bsr.l pass1_error
 rts
 
d_illegal_err:		*source error
 lea d_ill_text(pc),a0
 bsr.l pass1_error
 rts

illegal_err1:
 lea smoke_text(pc),a0
 bsr.l pass1_error
 rts
 
trap_err:
 lea trap_text(pc),a0
 bsr.l pass1_error
 rts

possibly_movem:
	lea	you_need_movem(pc),a0
	bsr.l	pass1_error
	rts
	
mq_too_big:	lea big_text(pc),a0
	bsr.l pass1_error
	rts
mq_too_small:
 lea small_text(pc),a0
 bsr.l pass1_error
 rts
data_err:
 lea dr_text(pc),a0
 bsr.l pass1_error
 rts
and_err:
 lea and_text(pc),a0
 bsr.l pass1_error
 rts
size_err:
 lea size_text_i1(pc),a0
 bsr.l pass1_error
 rts
movem_err:
 lea movem_text(pc),a0
 bsr.l pass1_error
 rts
movem_err_2:
 lea movem_text_2(pc),a0
 bsr.l pass1_error
 rts
movem_err_3:
 lea movem_text_3(pc),a0
 bsr.l pass1_error
 rts
slash_err:
 lea slash_text(pc),a0
 bsr.l pass1_error			; rp 14/6/97 added .l  = fantasm gets bigger
 rts_	"inst1ers"

***************************************************************************
source_text:	DC.B	"Source addressing mode illegal.",13,13,0
illegal_text:	dc.b	"Addressing mode illegal.",13,13,0
s_ill_text:	dc.b	"Source operand addressing mode illegal.",13,13,0
d_ill_text:	dc.b	"Destination addressing mode illegal.",13,13,0
smoke_text:	dc.b	"Smoke me a kipper.....Destination operand must be an address register.",13,13,0
trap_text:	dc.b	"Only TRAP 0-15 allowed. Notice the non-smarmy error"
	dc.b	" messages?",13,13,0
big_text:	dc.b	"Data too big.",13,13,0
small_text:	dc.b	"Data too small.",13,13,0
dr_text:	dc.b	"Destination must be a data register.",13,13,0
and_text:	dc.b	"Cant use an address register as source op for AND"
	dc.b	" instruction.",13,13,0
size_text_i1:	dc.b	"Cant EXT.B - must be .w or .l",13,13,0
movem_text:	dc.b	"Addressing mode not allowed in this version.",13,13,0
movem_text_2:	dc.b	"Bad register in list.",13,13,0
movem_text_3:	dc.b	"Register list backwards. Dont see that one very"
	dc.b	" often!!!",13,13,0
slash_text:	dc.b	"Ò/Ó expected in register list - e.g. MOVEM.L D0-D1/A0-A1"
	DC.B	",-(SP)",13,13,0
cmpm1_text:	dc.b	"Use the CMPM instruction.",13,13,0
conv_quick_text:	DC.B	"Used quick format for MOVE.L.",0
conv_quick_text_add:	DC.B	"Used quick format for ADD.",0
conv_quick_text_sub:	DC.B	"Used quick format for SUB.",0
you_need_movem:	dc.b	"You need MOVEM for this operand syntax.",13,13,0
	align
***************************************************************************
	global	move,add,addi,addq,sub,subi,subq,cmp,cmpa,cmpi,ext,lea,movem
	global	moveq,move_entry,trap,and,andi,illegal_err,s_illegal_err,d_illegal_err
	global	illegal_err1,data_err,size_err
	
	extern	get_size,get_ops,source_op,get_mode,dest_op,print_optimisation
	extern	insert_inst,get_size12,make_inst1,immediate,quick,pass2_error
	extern	pass1_error