*********************************************************************************
*FILE:	INSTS_V2.S				*
*MOTHER FILE:	FANTASM2XX.S				*
*DATE:	021094				*
*PROGRAMMER:	STUART BALL				*
*DESCRIPTION:	THE NEW INSTRUCTIONS FOR 20,30 AND 40 PROCS		*
*INPUT:	BASIC INST IN D1			*
*OUTPUT:	NONE				*
*********************************************************************************
**HANDLES BIT FIELD INSTRUCTIONS OF THE FORM <EA>{OFFSET:WIDTH}
**BFCHG,BFCLR,BFSET,BFTEST,BFEXTS,BFEXTU,BFFFO,BFINS

****REMEMBER - BIT FIELDS GO FROM LEFT TO RIGHT!!!!!****

bf1:
	cmpi.w	#$efc0,d1	bfins?
	beq	bf_3	yes
	bsr.l	get_ops	get ea in source_op and bf in dest_op
	move.l	a3,scratch_6(a5)	save position
bf_3_entry:	lea	source_op(a5),a3
	bsr.l	get_mode
	tst.w	d0
	beq.s	bf_mode_ok
	cmpi.w	#2,d0
	beq.s	bf_mode_ok
	cmpi.w	#5,d0
	beq.s	bf_mode_ok
	cmpi.w	#6,d0
	beq.s	bf_mode_ok
	cmpi.w	#7,d0
	bne	bf_mode_error
	tst.w	d2
	beq.s	bf_mode_ok
	cmpi.w	#1,d2
	bne	bf_mode_error
bf_mode_ok:	btst	#4,flags(a5)	abs label?
	beq.s	bf_l1	no	
	qbset	#6,flags(a5)	yes, reloc ext 2
bf_l1:	or.w	d2,d1	mix in reg
	lsl.w	#3,d0	shift mode - replace with bfins d0,d1{3:3}
	or.w	d0,d1	mix in mode
	move.w	d1,size(a5)	save inst
	move.w	d4,size2(a5)	size - note reverse layout!
	move.l	d3,extension2(a5)
	lea	dest_op(a5),a3
	bsr.l	get_mode
	move.w	size(a5),d1
	move.w	d4,size(a5)
	move.l	d3,extension(a5) bf goes in extension 1!
	btst	#8,d1	*bf_2 if bit 8 set
	bne.s	bf_2
	bsr.l	insert_inst
	rts_	"bf1"
	align	 
**bf_2 handles <ea>{offset:width},dn
**bfexts,bfextu,bfff0
bf_2:	move.l	scratch_6(a5),a3	get text back
	cmpi.b	#"D",(a3)
	bne.s	bf_data_reg
	move.b	1(a3),d0
	subi.b	#"0",d0
	bmi.s	bf_data_reg
	cmpi.b	#7,d0
	bgt.s	bf_data_reg
**now mix data reg into extension 1 at 12-14
	lsl.w	#8,d0
	lsl.w	#4,d0	replace with bfins
	or.w	d0,d3	neat!
	move.l	d3,extension(a5)
	bsr.l	insert_inst
	rts_	"bf2"
	align
**bf_3 handles bfins - dn,<ea>{offset:width}
bf_3:	lea	field_3(a5),a3
	lea	bfins_dsave(pc),a2
	move.w	(a3),(a2)	copy dn
	clr.b	2(a2)	just in case
	lea	bfins_dsave(pc),a2
	move.l	a2,scratch_6(a5)	save for bf_2
**now overwrite dn, with rest of field_3
	lea	field_3(a5),a3
	move.l	a3,a2
	addq.l	#3,a2
	moveq	#(76/4)-1,d0	move longs :-)
ow_dr:	move.l	(a2)+,(a3)+
	dbra	d0,ow_dr
	lea	field_3(a5),a3
	bsr.l	get_ops
	bra	bf_3_entry	will end up in bf-2 because bit 8 is set!
	
				
bf_dr_src:	lea	bf_data_src(pc),a0
	bsr.l	pass1_error
	rts_	"bf3"
	align
bf_data_reg:	lea	bf_dest_d_reg(pc),a0
	bsr.l	pass1_error
	rts

bf_mode_error:	lea	bf_ill_mode(pc),a0
	bsr.l	pass1_error
	rts
***************************cas and cas2********************************************
cas:	bsr.l	get_ops
	lea	source_op(a5),a3
	cmpi.b	#":",2(a3)	cas2 is dc1:dc2
	beq	cas2	its cas2

**cas syntax:	cas dc,du,<ea>
	bsr	check_cas_syntax	look for 2 commas and return
			*2nd comma in d1 (so we can get op)
	tst.w	d6	error?
	bge.s	cas_syn_ok
	rts
cas_syn_ok:	move.l	a2,scratch_6(a5)	save for later
	bsr.l	get_size12	get size in d0, from a4 (end of field2)
	inc.w	d0	size=1 byte, 2=word, 3=long
**LXT
	andi.w	#%11,d0
	lsl.w	#8,d0
	lsl.w	#1,d0
	or.w	d0,d1
;	bfins	d0,d1{21:2}	insert size into instruction
	lea	field_3(a5),a3	now get dc and du	
	cmpi.b	#"D",(a3)
	bne	cas_error_1
	move.b	1(a3),d0
	subi.b	#"0",d0
	bmi	cas_data_reg
	cmpi.b	#7,d0
	bgt	cas_data_reg
	clr.l	d3	extension
	or.b	d0,d3	mix in dc
	cmpi.b	#"D",3(a3)	2nd data reg - du
	bne	cas_error_1
	move.b	4(a3),d0
	subi.b	#"0",d0
	bmi	cas_data_reg
	cmpi.b	#7,d0
	bgt	cas_data_reg
	lsl.w	#6,d0
	or.w	d0,d3
	move.l	d3,extension(a5)
	move.w	#4,size(a5)
**now get ea
	move.l	scratch_6(a5),a3
	bsr.l	get_mode
	cmpi.w	#2,d0
	blt	cas_mode_error
	cmpi.w	#7,d0
	bne.s	cas_mode_ok
	cmpi.w	#1,d2
	bne	cas_mode_error
cas_mode_ok:	lsl.w	#3,d0	shift mode
	or.w	d0,d1	mix in mode
	or.w	d2,d1	mix in rf
	move.w	d4,size2(a5)
	move.l	d3,extension2(a5)
	bsr.l	insert_inst
	rts_	"cas"
	align
******************
**cas2 syntax:	cas2 dc1:dc2,du1:du2,(rn1):(rn2) - a bastard indeed
**somebody at motorola must have been on coke to come up with this!

cas2:	bsr	check_cas_syntax	look for 2 commas and return
			*2nd comma in d1 (so we can get op)
	tst.w	d6	may as well leave the checking in!
	bge.s	cas_syn_ok2
	rts
**this is such a git, we'll just hard wire it!
cas_syn_ok2:	move.l	a2,scratch_6(a5)	save for later
	bsr.l	get_size12	get size in d0, from a4 (end of field2)
	inc.w	d0	size=1 byte, 2=word, 3=long
	cmpi.w	#1,d0
	beq	cas_size_error	byte s not allowed
**LXT
	andi.w	#%11,d0
	lsl.w	#8,d0
	lsl.w	#1,d0
	or.w	d0,d1

;	bfins	d0,d1{21:2}	insert size into instruction
	clr.l	d3	extension 1
	clr.l	d4	extension 2
**now wade through picking out the bits and building the extensions

	lea	field_3(a5),a3	now get dc and du	
	cmpi.b	#"D",(a3)
	bne	cas_error_3
	move.b	1(a3),d0
	subi.b	#"0",d0
	bmi	cas_error_3
	cmpi.b	#7,d0
	bgt	cas_error_3
	or.b	d0,d3	mix in dc1
	
	cmpi.b	#"D",3(a3)	
	bne	cas_error_3
	move.b	4(a3),d0
	subi.b	#"0",d0
	bmi	cas_error_3
	cmpi.b	#7,d0
	bgt	cas_error_3
	or.w	d0,d4	mix in dc2
**now do dus
	cmpi.b	#"D",6(a3)	
	bne	cas_error_3
	move.b	7(a3),d0
	subi.b	#"0",d0
	bmi	cas_error_3
	cmpi.b	#7,d0
	bgt	cas_error_3
	lsl.w	#6,d0
	or.w	d0,d3	mix in du1
	
	cmpi.b	#"D",9(a3)	
	bne	cas_error_3
	move.b	10(a3),d0
	subi.b	#"0",d0
	bmi	cas_error_3
	cmpi.b	#7,d0
	bgt	cas_error_3
	lsl.w	#6,d0
	or.w	d0,d4	mix in du2
**now do rns - either (ax) or (dx)
**we are at 12(a3)- we can either have (ax) or (dn) for each

	cmpi.b	#"(",12(a3)	
	bne	cas_error_2
	cmpi.b	#"A",13(a3)
	bne.s	try_d1
**rn1 is a
	move.b	14(a3),d0
	subi.b	#"0",d0
	bmi	cas_error_3
	cmpi.b	#7,d0
	bgt	cas_error_3	report syntax
	lsl.w	#8,d0
	lsl.w	#4,d0
	or.w	d0,d3	mix in rn1
	qbset	#15,d3	address reg
	bra.s	done_rn1
try_d1:	cmpi.b	#"D",13(a3)
	bne	cas_error_3
**rn1 is d
	move.b	14(a3),d0
	subi.b	#"0",d0
	bmi	cas_error_3
	cmpi.b	#7,d0
	bgt	cas_error_3	report syntax
	lsl.w	#8,d0
	lsl.w	#4,d0
	or.w	d0,d3	mix in rn1

done_rn1:
	cmpi.b	#"(",17(a3)	do rn2	
	bne	cas_error_2
	cmpi.b	#"A",18(a3)
	bne.s	try_d2
**rn1 is a
	move.b	19(a3),d0
	subi.b	#"0",d0
	bmi	cas_error_3
	cmpi.b	#7,d0
	bgt	cas_error_3	report syntax
	lsl.w	#8,d0
	lsl.w	#4,d0
	or.w	d0,d4	mix in rn1
	qbset	#15,d4	address reg
	bra.s	done_rn2
try_d2:	cmpi.b	#"D",18(a3)
	bne	cas_error_3
**rn2 is d
	move.b	19(a3),d0
	subi.b	#"0",d0
	bmi	cas_error_3
	cmpi.b	#7,d0
	bgt.s	cas_error_3	report syntax
	lsl.w	#8,d0
	lsl.w	#4,d0
	or.w	d0,d4	mix in rn1

done_rn2:	move.w	#4,size(a5)
	move.w	#4,size2(a5)
	move.l	d3,extension(a5)
	move.l	d4,extension2(a5)
	bsr.l	insert_inst
	rts_	"cas2"
	align
	
	
**returns d1 at address of second comma, else error
check_cas_syntax:
	clr.l	d6	error return
	lea	field_3(a5),a2
find_first_c:	move.b	(a2)+,d0
	beq.s	cas_error_1	*cas syntax error
	cmpi.b	#13,d0
	beq.s	cas_error_1
	cmpi.b	#32,d0
	beq.s	cas_error_1
	cmpi.b	#0x2c,d0
	beq.s	got_1st_c
	bra.s	find_first_c
got_1st_c:	move.b	(a2)+,d0
	beq.s	cas_error_1
	cmpi.b	#13,d0
	beq.s	cas_error_1
	cmpi.b	#32,d0
	beq.s	cas_error_1
	cmpi.b	#0x2c,d0
	beq.s	got_2nd_c
	bra.s	got_1st_c
got_2nd_c:	rts		*a2->dest op

cas_error_1:	lea	cas_syntax_error(pc),a0
	bsr.l	pass1_error
	moveq	#-1,d6
	rts
	align
cas_error_2:	lea	cas_syntax_error1(pc),a0
	bsr.l	pass1_error
	rts


cas_error_3:	lea	cas_syntax_error2(pc),a0
	bsr.l	pass1_error
	rts

	align
cas_data_reg:	lea	cas_d_reg(pc),a0
	bsr.l	pass1_error
	rts

	align
cas_mode_error:	lea	cas_me_text(pc),a0
	bsr.l	pass1_error
	rts

	align
cas_size_error:	lea	cas_size_text(pc),a0
	bsr.l	pass1_error
	rts

	align
**************************chk2*****************************************************
chk2:	bsr.l	get_size12
**LXT
	andi.w	#%11,d0
	lsl.w	#8,d0
	lsl.w	#1,d0
	or.w	d0,d1

;	bfins	d0,d1{21:2}	insert size
	bsr.l	get_ops
	lea	source_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#2,d0	2,5,6,71
	blt.s	chk2_am_error
	beq.s	chk2_am_ok
	cmpi.w	#5,d0
	beq.s	chk2_am_ok
	cmpi.w	#6,d0
	beq.s	chk2_am_ok
	cmpi.w	#7,d0
	bne.s	chk2_am_error
	cmpi.w	#3,d2
	ble.s	chk2_am_ok	xxxx, or d8(pc etc, or d16(pc etc
	bra.s	chk2_am_error
chk2_am_ok:	btst	#4,flags(a5)	abs label?
	beq.s	chk2_l1	no	
	qbset	#6,flags(a5)	yes, reloc ext 2
chk2_l1:
	lsl.w	#3,d0
	or.w	d2,d1	mix in rf
	or.w	d0,d1	mix in mode
	move.w	d4,size2(a5)
	move.l	d3,extension2(a5)
	clr.l	d3
	lea	dest_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#2,d0	*only dn and an allowed for dest
	bgt.s	chk2_am_error
**LXT
	lsl.w	#8,d2
	lsl.w	#4,d2
	or.w	d2,d3
;	bfins	d2,d3{17:3}	mix in reg at 12-14
	tst.w	d0
	beq.s	chk2_data
	qbset	#15,d3	set address reg bit
chk2_data:	qbset	#11,d3	make chk2 - cmp2 dont have this
	move.l	d3,extension(a5)
	move.w	#4,size(a5)
	bsr.l	insert_inst
	rts
chk2_am_error:	lea	chk2_error_text(pc),a0
	bsr.l	pass1_error
	rts_	"chk2"
	align
**************************cmp2*****************************************************
cmp2:	bsr.l	get_size12
**LXT
	andi.w	#%11,d0
	lsl.w	#8,d0
	lsl.w	#1,d0
	or.w	d0,d1

;	bfins	d0,d1{21:2}	insert size
	bsr.l	get_ops
	lea	source_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#2,d0	2,5,6,71
	blt.s	cmp2_am_error
	beq.s	cmp2_am_ok
	cmpi.w	#5,d0
	beq.s	cmp2_am_ok
	cmpi.w	#6,d0
	beq.s	cmp2_am_ok
	cmpi.w	#7,d0
	bne.s	cmp2_am_error
	cmpi.w	#3,d2
	ble.s	cmp2_am_ok
	bra.s	cmp2_am_error
cmp2_am_ok:	btst	#4,flags(a5)	abs label?
	beq.s	cmp2_l1	no	
	qbset	#6,flags(a5)	yes, reloc ext 2
cmp2_l1:
	lsl.w	#3,d0
	or.w	d2,d1	mix in rf
	or.w	d0,d1	mix in mode
	move.w	d4,size2(a5)
	move.l	d3,extension2(a5)
	clr.l	d3
	lea	dest_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#2,d0	*only dn and an allowed for dest
	bgt.s	cmp2_am_error
	lsl.w	#8,d2
	lsl.w	#4,d2
	or.w	d2,d3
;	bfins	d2,d3{17:3}	mix in reg at 12-14
	tst.w	d0
	beq.s	cmp2_data
	qbset	#15,d3	set address reg bit
cmp2_data:	move.l	d3,extension(a5)
	move.w	#4,size(a5)
	bsr.l	insert_inst
	rts
cmp2_am_error:	lea	cmp2_error_text(pc),a0
	bsr.l	pass1_error
	rts_	"cmp2"
	align
*******************move16*********************************
**move16 (ax)+,(ay)+
**move16 xxxx,(an)
**move16 xxxx,)an)+
**move16 (an),xxxx
**move16 (an)+,xxxx

move16:	bsr.l	get_ops	get source and dest ops
	lea	field_3(a5),a2
	cmpi.b	#"(",(a2)
	beq.s	m16_ar1	address reg as first op
**here we have xxxx,something
**xxxx goes in extension, size = 6, a reg goes in instruction (d1)
	lea	source_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#7,d0
	bne	m16_err1	must be abs long
	cmpi.w	#1,d2
	bne	m16_err1
	btst	#4,flags(a5)	abs label?
	beq.s	m16_l1	no	
	qbset	#5,flags(a5)	yes, reloc ext 1
m16_l1:	move.w	d4,size(a5)
	move.l	d3,extension(a5)
	lea	dest_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#2,d0
	beq.s	m16_l2
	cmpi.w	#3,d0
	bne	m16_err1
	qbset	#3,d1	make xxxx,(an)+
	bra.s	m16_l3
m16_l2:	qbset	#3,d1
	qbset	#4,d1	make xxxx,(an)
m16_l3:	or.b	d2,d1	mix in reg
	bsr.l	insert_inst		
	rts
	
m16_ar1:	lea	dest_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#3,d0
	beq.s	m16_aa	(an)+,(an)+
**this is something,xxxx
	cmpi.w	#7,d0
	bne.s	m16_err1	must be abs long
	cmpi.w	#1,d2
	bne.s	m16_err1
	btst	#4,flags(a5)	abs label?
	beq.s	m16_l12	no	
	qbset	#5,flags(a5)	yes, reloc ext 1
m16_l12:	move.w	d4,size(a5)
	move.l	d3,extension(a5)
	lea	source_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#2,d0
	beq.s	m16_l22
	cmpi.w	#3,d0
	bne.s	m16_err1
*this is (an)+,xxxx
	bra.s	m16_l32
m16_l22:	qbset	#4,d1	make (an),xxxx
m16_l32:	or.b	d2,d1	mix in reg
	bsr.l	insert_inst		
	rts
**this is (an)+,(an)+
m16_aa:	clr.l	d3
	lsl.w	#8,d2
	lsl.w	#4,d2
	or.w	d2,d3
;	bfins	d2,d3{17:3}	insert ay into extension
	move.w	#4,size(a5)
	qbset	#15,d3
	move.l	d3,extension(a5)
	lea	source_op(a5),a3
	bsr.l	get_mode
	cmpi.w	#3,d0
	bne.s	m16_err1
	or.b	d2,d1
	qbset	#5,d1	make (an)+,(an)+
	bsr.l	insert_inst
	rts

m16_err1:	lea	m16_text(pc),a0
	bsr.l	pass1_error
	rts

************************************trapcc*************************	
trapcc:	bsr.l	get_ops
	bsr.l	get_size12	returns 0,1,2
	tst.b	d0
	beq.s	trapcc_error2	bytes not allowed
	addq.w	#1,d0	size=2=word, 3=long
	lea	source_op(a5),a3
	tst.b	(a3)
	bne.s	tcc_got_op
	move.w	#4,scratch_6(a5)	save size
	bra.s	tcc_done_ops
tcc_got_op:	move.w	d0,scratch_6(a5)	save size
	bsr.l	get_mode	get source mode
	cmpi.w	#7,d0	only #xxxx allowed
	bne.s	trapcc_error1
	cmpi.w	#4,d2
	bne.s	trapcc_error1
	move.l	d3,extension(a5)
	move.w	d4,size(a5)
tcc_done_ops:	move.w	scratch_6(a5),d0
	or.b	d0,d1	mix in opmode
	bsr.l	insert_inst	
	rts
trapcc_error1:	lea	trapcc_text1(pc),a0
	bsr.l	pass1_error
	rts
trapcc_error2:	lea	trapcc_text2(pc),a0
	bsr.l	pass1_error
	rts
			
************************************************************************************	
bfins_dsave:	DS.L	1	
bf_ill_mode:	DC.B	"Addressing mode not allowed for bit field instructions.",13
	DC.B	"Valid addressing modes are: Dn, (An), d16(An), d8(An,Xn.s*scale), "
	DC.B	"absolute address.",13,13,0
bf_dest_d_reg:	DC.B	"Destination operand must be a valid data "
	dc.b	"register - i.e. <ea>{offset:width},Dn.",13,13,0
bf_data_src:	DC.B	"Source operand must be a valid data register - Syntax: BFINS D0,<ea>"
	dc.b	"{offset:width}",13,13,0
cas_syntax_error:	DC.B	"Comma expected in CAS instruction.",13,13,0
cas_syntax_error1:	DC.B	"Syntax: CAS2 Dc1:Dc2,Du1:Du2,(Rn1):(Rn2).",13
	DC.B	"Where Dc is compare, Du is update and (Rn) is dest operand "
	DC.B	"either data or address register.",13,13,0
cas_syntax_error2:	dc.b	"Bad data register.",13,13,0
cas_d_reg:	DC.B	"Data reg expected - Syntax: CAS Dc,Du,<EA>.",13,13,0
cas_me_text:	DC.B	"Destination addressing mode not allowed for CAS.",13
	dc.b	"Valid addressing modes: (An), (An)+, -(An), d16(An), "
	dc.b	"d8(An,Xn.s*scale), absolute address.",13,13,0
cas_size_text:	DC.B	"Byte size not allowed for CAS2.",13,13,0
chk2_error_text:	DC.B	"Addressing mode not allowed for CHK2 instruction.",13
	dc.b	"Source modes are: (An), d16(An), d8(an,Xn.s*scale), "
	dc.b	"absolute address, d16(PC), d8(PC,Xn.s*scale).",13
	dc.b	"Destination must be a valid data or address register.",13,13,0
cmp2_error_text:	DC.B	"Addressing mode not allowed for CMP2 instruction.",13
	dc.b	"Source modes are: (An), d16(An), d8(an,Xn.s*scale), "
	dc.b	"absolute address, d16(PC), d8(PC,Xn.s*scale).",13
	dc.b	"Destination must be a valid data or address register.",13,13,0
m16_text:	DC.B	"Error in move16 instruction - syntax:",13
	dc.b	"MOVE16 (Ax)+,(Ax)+  MOVE16 xxxx,(An)  MOVE16 xxxx,(An)+",13
	dc.b	"MOVE16 (An),xxxx  MOVE16 (An)+,xxxx  where xxxx is memory location.",13,13,0
trapcc_text1:	DC.B	"Only immediate data allowed for TRAPCC instruction.",13
	dc.b	"Syntax: TRAPCC.W #data or TRAPCC.L #data.",13,13,0	
trapcc_text2:	DC.B	"Only word and long sizes allowed for TRAPCC instruction.",13
	dc.b	"Syntax: TRAPCC.W #data or TRAPCC.L #data.",13,13,0	
	align
	global	bf1,bf_3_entry,bf_2,bf_3,cas,cas2,chk2,cmp2,move16,trapcc
	extern	get_size12,get_mode,get_ops,source_op,dest_op,pass1_error
	extern	insert_inst