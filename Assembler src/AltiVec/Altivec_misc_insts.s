**These routines assemble all the altivec instructions that start with v 
**and are called fromAltivec_tables.s

**altiVec
do_dst:
;	lea	unsupported(pc),a0
;	bsr.l	pass1_warning
;	qmove.l	#$60000000,d1	*nop
	push	d1

	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
;	cmpi.l	#4,d1	*4 if transient bit
;	beq.s	dst_with_t
	qmove.l	d1,d7	*save number of operands
	bset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	cmpi.l	#4,d7
	bne.s	dst_three
	push	d7
	bsr.l	get_four
	pop	d7
	bra.s	got_dst_ops
dst_three:
	push	d7
	bsr.l	get_three	*get three operands - ra,rb,tag - d2-d4
	pop	d7
got_dst_ops:
	pop	d1
**Ops in d2-d4/5
	cmpi.w	#0,first_type(a5)
	beq.s	dst_op1_ok
	lea	op1_gpr(pc),a0
	bsr.l	pass1_error
	bra	dst_end
dst_op1_ok:
	cmpi.w	#0,second_type(a5)
	beq.s	dst_op2_ok
	lea	op2_gpr(pc),a0
	bsr.l	pass1_error
	bra	dst_end
dst_op2_ok:
	cmpi.w	#3,third_type(a5)
	beq.s	dst_op3_ok1
	lea	op3_imm(pc),a0
	bsr.l	pass1_error
	bra	dst_end
dst_op3_ok1:
**Stream in range 0-3?
	cmpi.l	#0,d4
	blt.s	dst_str_err
	cmpi.l	#3,d4
	ble.s	dst_op3_ok2
dst_str_err:
	lea	stream_err(pc),a0
	bsr.l	pass1_error
	bra	dst_end
dst_op3_ok2:
	cmpi.l	#4,d7
	bne.s	not_dst_touch
	cmpi.w	#3,third_type(a5)
	beq.s	dst_op4_ok1
	lea	op4_imm(pc),a0
	bsr.l	pass1_error
	bra	dst_end
dst_op4_ok1:
**We allow 0 or 1 for touch bit
	cmpi.l	#0,d5
	blt.s	dst_t_err
	cmpi.l	#1,d5
	ble.s	dst_op4_ok2
dst_t_err:
	lea	touch_bit_err(pc),a0
	bsr.l	pass1_error
	bra	dst_end
dst_op4_ok2:
not_dst_touch:

**munge the bits in
**rb in bit 16-20
	lsl.l	#8,d3
	lsl.l	#3,d3
	or.w	d3,d1
**ra in bits 11-15
	swap	d2
	or.l	d2,d1
**Stream in 9-10
	swap	d4
	lsl.l	#5,d4
	or.l	d4,d1
**Touch bit in 6
	cmpi.l	#4,d7
	bne.s	not_dst_touch1
	swap	d5
	lsl.l	#8,d5
	lsl.l	#1,d5
	or.l	d5,d1
not_dst_touch1:
	bsr.l	put_ppc
dst_end:
	rts_	"do_dst"
	global	do_dst

do_dss:
*get stream
	push	d1
	bsr	get_1_imm		*in d2
	pop	d1
	tst.l	d0
	bne	dss_end
	swap	d1
	tst.l	d2
	blt.s	stream_err1
	cmpi.l	#3,d2
	ble.s	stream_ok1
stream_err1:
	lea	stream_err(pc),a0
	bsr.l	pass1_error
	bra	dlv_end
stream_ok1:
	lsl.l	#5,d2
	or.w	d2,d1
	swap	d1
	bsr.l	put_ppc
dss_end:
	rts_	"do_dss"
	global	do_dss
	
**lvebx vn,ra,rb
do_load_vreg:
	push	d1	*save basic instruction
	bsr	get_1_vec_2_gpr	
	pop	d1
	tst.l	d0
	bne	dlv_end
	cmpi.w	#2,first_type(a5)
	beq.s	dlv_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	dlv_end
dlv_op1_ok:
**mix in vd
	swap	d1
	lsl.l	#5,d2
	or.w	d2,d1
**mix in ra
	cmpi.w	#0,second_type(a5)
	beq.s	dlv_op2_ok
	lea	op2_gpr(pc),a0
	bsr.l	pass1_error
	bra	dlv_end
dlv_op2_ok:
**mix in ra
	move.l	second_operand(a5),d0
	or.w	d0,d1
**mix in rb
	swap	d1
	cmpi.w	#0,third_type(a5)
	beq.s	dlv_op3_ok
	lea	op3_gpr(pc),a0
	bsr.l	pass1_error
	bra	dlv_end
dlv_op3_ok:
**mix in ra
	move.l	third_operand(a5),d0
	lsl.l	#8,d0
	lsl.l	#3,d0
	or.l	d0,d1
	bsr.l	put_ppc
dlv_end:
	rts_	"do_load_vreg"
	global	do_load_vreg
****************

do_mfvscr:
**get one vector reg
	push	d1
	bsr	get_1_vec
	pop	d1
	tst.l	d0
	bne	dmf_end

	cmpi.w	#2,first_type(a5)
	beq.s	dmf_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	dmf_end
dmf_op1_ok:
**mix in reg
	swap	d1
	lsl.l	#5,d2
	or.w	d2,d1
	swap	d1	
	bsr.l	put_ppc
dmf_end:
	rts_	"do_mfvscr"
	global	do_mfvscr
	
do_mtvscr:
**get one vector reg
	push	d1
	bsr	get_1_vec
	pop	d1
	tst.l	d0
	bne	dmt_end

	cmpi.w	#2,first_type(a5)
	beq.s	dmt_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	dmt_end
dmt_op1_ok:
**mix in reg
	lsl.l	#8,d2
	lsl.l	#3,d2
	or.w	d2,d1
	bsr.l	put_ppc
dmt_end:
	rts_	"do_mtvscr"
	global	do_mtvscr

do_vaddcuw:
	push	d1
	bsr	get_3_vec	*d2,d3,d4
	pop	d1
	tst.l	d0
	bmi	vadd_end
	cmpi.w	#2,first_type(a5)
	beq.s	d_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	vadd_end
d_op1_ok:
	cmpi.w	#2,second_type(a5)
	beq.s	d_op2_ok
	lea	op2_vect(pc),a0
	bsr.l	pass1_error
	bra	vadd_end
d_op2_ok:
	cmpi.w	#2,third_type(a5)
	beq.s	d_op3_ok
	lea	op3_vect(pc),a0
	bsr.l	pass1_error
	bra	vadd_end
d_op3_ok:
**mix in regs to instruction in d1
	swap	d1
	lsl.l	#5,d2	*op1
	or.w	d2,d1
	or.w	d3,d1	*op2
	swap	d1
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1
	bsr.l	put_ppc
	global	do_vaddcuw
vadd_end:
	rts_	"do_vaddcuw"
	
do_vbasic_dot:
	push	d1
	bsr	get_3_vec	*d2,d3,d4
	pop	d1
	tst.l	d0
	bmi	vbd_end
	cmpi.w	#2,first_type(a5)
	beq.s	dbd_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	vbd_end
dbd_op1_ok:
	cmpi.w	#2,second_type(a5)
	beq.s	dbd_op2_ok
	lea	op2_vect(pc),a0
	bsr.l	pass1_error
	bra	vbd_end
dbd_op2_ok:
	cmpi.w	#2,third_type(a5)
	beq.s	dbd_op3_ok
	lea	op3_vect(pc),a0
	bsr.l	pass1_error
	bra	vbd_end
dbd_op3_ok:
**mix in regs to instruction in d1
	swap	d1
	lsl.l	#5,d2	*op1
	or.w	d2,d1
	or.w	d3,d1	*op2
	swap	d1
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_dbd
	bset	#10,d1	*set dot bit
	bclr	#0,postfix_flags(a5)	*so we dont get a dot warning!

no_dot_dbd:
	bsr.l	put_ppc
	global	do_vbasic_dot
vbd_end:
	rts_	"do_vbasic_dot"

do_vbasic_dot4:	*handles vcmp which may have a cr6 at the start of the operands

	push	d1
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#3,d1
	beq.s	not_cr6
**here we have to deal with cr6,vx,vy,vz
	bsr.l	get_four	*get four operands
**move upper three operands and types
	move.w	second_type(a5),first_type(a5)
	move.l	d3,d2
	move.w	third_type(a5),second_type(a5)
	move.l	d4,d3
	move.w	fourth_type(a5),third_type(a5)
	move.l	d5,d4
	clr.l	d0
	bra.s	got_three_vbd
not_cr6:
	bsr	get_3_vec	*d2,d3,d4
got_three_vbd:
	pop	d1
	tst.l	d0
	bmi	vbd_end
	cmpi.w	#2,first_type(a5)
	beq.s	dbd_op1_ok4
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	vbd_end4
dbd_op1_ok4:
	cmpi.w	#2,second_type(a5)
	beq.s	dbd_op2_ok4
	lea	op2_vect(pc),a0
	bsr.l	pass1_error
	bra	vbd_end4
dbd_op2_ok4:
	cmpi.w	#2,third_type(a5)
	beq.s	dbd_op3_ok4
	lea	op3_vect(pc),a0
	bsr.l	pass1_error
	bra	vbd_end4
dbd_op3_ok4:
**mix in regs to instruction in d1
	swap	d1
	lsl.l	#5,d2	*op1
	or.w	d2,d1
	or.w	d3,d1	*op2
	swap	d1
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1
	btst	#0,postfix_flags(a5)
	beq.s	no_dot_dbd4
	bset	#10,d1	*set dot bit
	bclr	#0,postfix_flags(a5)	*so we dont get a dot warning!

no_dot_dbd4:
	bsr.l	put_ppc
	global	do_vbasic_dot4
vbd_end4:
	rts_	"do_vbasic_dot4"
	
do_vbasic_im:
	push	d1
	bsr	get_2_vec_1_imm	*d2,d3,d4<-imm
	pop	d1
	tst.l	d0
	bmi	vbi_end
	cmpi.w	#2,first_type(a5)
	beq.s	dbi_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	vbi_end
dbi_op1_ok:
	cmpi.w	#2,second_type(a5)
	beq.s	dbi_op2_ok
	lea	op2_vect(pc),a0
	bsr.l	pass1_error
	bra	vbi_end
dbi_op2_ok:
	cmpi.w	#3,third_type(a5)
	beq.s	dbi_op3_ok
	lea	op3_imm(pc),a0
	bsr.l	pass1_error
	bra	vbi_end
dbi_op3_ok:
**Check size of op3 is 0->31
	cmpi.l	#0,d4
	blt.s	unumb_bad
	cmpi.l	#31,d4
	ble.s	unumb_good
unumb_bad:
	lea	op3_imm_bad_size(pc),a0
	bsr.l	pass1_error
	bra	vbi_end
unumb_good:
	
**mix in regs to instruction in d1
	swap	d1
	lsl.l	#5,d2	*vd
	or.w	d2,d1
	or.w	d4,d1	*uimm
	swap	d1
	lsl.l	#8,d3
	lsl.l	#3,d3
	or.w	d3,d1	*op2 - vb
	bsr.l	put_ppc
	global	do_vbasic_im
vbi_end:
	rts_	"do_vbasic_im"

do_vsl:
	push	d1
	bsr	get_3_vec_1_imm	*d2,d3,d4<-imm
	pop	d1
	tst.l	d0
	bmi	vsl_end
	cmpi.w	#2,first_type(a5)
	beq.s	vsl_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	vsl_end
vsl_op1_ok:
	cmpi.w	#2,second_type(a5)
	beq.s	vsl_op2_ok
	lea	op2_vect(pc),a0
	bsr.l	pass1_error
	bra	vsl_end
vsl_op2_ok:
	cmpi.w	#2,third_type(a5)
	beq.s	vsl_op3_ok
	lea	op3_vect(pc),a0
	bsr.l	pass1_error
	bra	vsl_end
vsl_op3_ok:
	cmpi.w	#3,fourth_type(a5)
	beq.s	vsl_op4_ok
	lea	op4_imm(pc),a0
	bsr.l	pass1_error
	bra	vsl_end
vsl_op4_ok:
**Check size of op3 is 0->31
	cmpi.l	#0,d5
	blt.s	vsl_shift_bad
	cmpi.l	#7,d5
	ble.s	vsl_shift_good
vsl_shift_bad:
	lea	vsl_shift_bad_size(pc),a0
	bsr.l	pass1_error
	bra	vsl_end
vsl_shift_good:
	
**mix in regs to instruction in d1
	swap	d1
	lsl.l	#5,d2	*vd
	or.w	d2,d1
	or.w	d3,d1	*va
	swap	d1
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1	*op2 - vb
	lsl.l	#6,d5	*sh
	or.w	d5,d1
	bsr.l	put_ppc
	global	do_vsl
vsl_end:
	rts_	"do_vsl"



do_v_sim:
	push	d1
	bsr	get_1_vec_1_imm	*d2,d3,d4<-imm
	pop	d1
	tst.l	d0
	bmi	vsim_end
	cmpi.w	#2,first_type(a5)
	beq.s	dsim_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	vsim_end
dsim_op1_ok:
	cmpi.w	#3,second_type(a5)
	beq.s	dsim_op2_ok
	lea	op2_simm(pc),a0
	bsr.l	pass1_error
	bra	vsim_end
dsim_op2_ok:
**Check size of op2 is 0->31
	cmpi.l	#-15,d3
	blt.s	snumb_bad1
	cmpi.l	#15,d3
	ble.s	snumb_good1
snumb_bad1:
	lea	op2_simm(pc),a0
	bsr.l	pass1_error
	bra	vsim_end
snumb_good1:
	andi.l	#0x1f,d3	*signed data	
**mix in regs to instruction in d1
	swap	d1
	lsl.l	#5,d2	*vd
	or.w	d2,d1
	or.l	d3,d1	*simm
	swap	d1
	bsr.l	put_ppc
	global	do_v_sim
vsim_end:
	rts_	"do_v_sim"



do_vect4:
	global	do_vect4
	push	d1
	bsr	get_4_vec	*d2,d3,d4
	pop	d1
	tst.l	d0
	bmi	v4_end
	cmpi.w	#2,first_type(a5)
	beq.s	d4_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	v4_end
d4_op1_ok:
	cmpi.w	#2,second_type(a5)
	beq.s	d4_op2_ok
	lea	op2_vect(pc),a0
	bsr.l	pass1_error
	bra	v4_end
d4_op2_ok:
	cmpi.w	#2,third_type(a5)
	beq.s	d4_op3_ok
	lea	op3_vect(pc),a0
	bsr.l	pass1_error
	bra	v4_end
d4_op3_ok:
	cmpi.w	#2,fourth_type(a5)
	beq.s	d4_op4_ok
	lea	op4_vect(pc),a0
	bsr.l	pass1_error
	bra	v4_end
d4_op4_ok:

**mix in regs to instruction in d1
	swap	d1
	lsl.l	#5,d2	*op1
	or.w	d2,d1
	or.w	d3,d1	*op2
	swap	d1
	lsl.l	#8,d4
	lsl.l	#3,d4
	or.w	d4,d1
	lsl.l	#6,d5
	or.w	d5,d1
	bsr.l	put_ppc

v4_end:
	rts_	"do_vect4"
	
do_vect2:
	global	do_vect2
	push	d1
	bsr	get_2_vec	*d2,d3,d4
	pop	d1
	tst.l	d0
	bmi	v2_end
	cmpi.w	#2,first_type(a5)
	beq.s	d2_op1_ok
	lea	op1_vect(pc),a0
	bsr.l	pass1_error
	bra	v2_end
d2_op1_ok:
	cmpi.w	#2,second_type(a5)
	beq.s	d2_op2_ok
	lea	op2_vect(pc),a0
	bsr.l	pass1_error
	bra	v2_end
d2_op2_ok:
**mix in regs to instruction in d1
	swap	d1
	lsl.l	#5,d2	*op1 - vd
	or.w	d2,d1
	swap	d1
	lsl.l	#8,d3
	lsl.l	#3,d3	*op2 - vb
	or.w	d3,d1
	bsr.l	put_ppc

v2_end:
	rts_	"do_vect2"
***********************************************************************************
get_1_vec:	*in d2,d3 and d4
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#1,d1
	beq.s	got_ops2
	lea	ops1vr_needed(pc),a0
	bsr.l	pass1_error
	bra	failedv
got_ops2:
	bsr.l	get_one	*get one operands
	clr.l	d0
g1v_end:
	rts_	"get_1_vex"
failedv:
	qmoveq	#-1,d0
	bra	g1v_end


get_1_vec_2_gpr:	*in d2,d3 and d4
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#3,d1
	beq.s	got_ops1
	lea	ops3vr_needed(pc),a0
	bsr.l	pass1_error
	bra	failed
got_ops1:
	bsr.l	get_three	*get three operands
	clr.l	d0
g1v2g_end:
	rts_	"get_1_vec_2_gpr"
failed:
	qmoveq	#-1,d0
	bra	g1v2g_end

get_3_vec:	*in d2,d3 and d4
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#3,d1
	beq.s	got_ops3
	lea	ops3vrn(pc),a0
	bsr.l	pass1_error
	bra	failed3
got_ops3:
	bsr.l	get_three	*get three operands
	clr.l	d0
g3v_end:
	rts_	"get_1_vec_2_gpr"
failed3:
	qmoveq	#-1,d0
	bra	g3v_end

get_2_vec:	*in d2,d3
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#2,d1
	beq.s	got_ops2v
	lea	ops2vrn(pc),a0
	bsr.l	pass1_error
	bra	failed2v
got_ops2v:
	bsr.l	get_two	*get two operands
	clr.l	d0
g22v_end:
	rts_	"get_2_vecSB160898"
failed2v:
	qmoveq	#-1,d0
	bra	g22v_end



get_2_vec_1_imm:	*in d2,d3 and d4
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#3,d1
	beq.s	got_ops4
	lea	ops2v1i(pc),a0
	bsr.l	pass1_error
	bra	failed4
got_ops4:
	bset	#2,ppc_immediate_data_operand(a5)	*op3 is immediate
	bsr.l	get_three	*get three operands
	clr.l	d0
g2vi_end:
	rts_	"get_2_vec_1_imm"
failed4:
	qmoveq	#-1,d0
	bra	g2vi_end

get_3_vec_1_imm:	*in d2,d3 and d4
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#4,d1
	beq.s	got_ops31
	lea	ops4v1i(pc),a0
	bsr.l	pass1_error
	bra	failed31
got_ops31:
	bset	#3,ppc_immediate_data_operand(a5)	*op4 is immediate
	bsr.l	get_four	*get three operands
	clr.l	d0
g31vi_end:
	rts_	"get_2_vec_1_imm"
failed31:
	qmoveq	#-1,d0
	bra	g31vi_end



get_1_vec_1_imm:	*in d2,d3 and d4
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#2,d1
	beq.s	got_ops41
	lea	ops1v1si(pc),a0
	bsr.l	pass1_error
	bra	failed41
got_ops41:
	bset	#1,ppc_immediate_data_operand(a5)	*op2 is immediate
	bsr.l	get_two	*get two operands
	clr.l	d0
g41vi_end:
	rts_	"get_1_vec_1_imm"
failed41:
	qmoveq	#-1,d0
	bra	g41vi_end

get_1_imm:	*in d2,d3 and d4
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#1,d1
	beq.s	got_ops41a
	lea	ops1si(pc),a0
	bsr.l	pass1_error
	bra	failed41a
got_ops41a:
	bset	#0,ppc_immediate_data_operand(a5)	*op1 is immediate
	bsr.l	get_one	*get one operands
	clr.l	d0
g41via_end:
	rts_	"get_1_vec_1_imm"
failed41a:
	qmoveq	#-1,d0
	bra	g41via_end


get_4_vec:	*in d2,d3 and d4
	bsr.l	get_ops_ppc	*in op1,op2 etc. Number of ops in d1
	cmpi.l	#4,d1
	beq.s	got_ops5
	lea	ops4vrn(pc),a0
	bsr.l	pass1_error
	bra	failed5
got_ops5:
	bsr.l	get_four	*get three operands
	clr.l	d0
g5v_end:
	rts_	"get_1_vec_2_gpr"
failed5:
	qmoveq	#-1,d0
	bra	g5v_end
		
unsupported:	dc.b	"WARNING: Replaced with NOP - unavailable instruction.",13,
	dc.b	"AltiVec stream instructions are not supported in this version of Fantasm.",13
	dc.b	"Instructions currently unavailable:",13
	dc.b	"dst,dstst,dststt,dstt.",13
	dc.b	"The instuction has been replaced with a nop.",13,0
	align
ops3vr_needed:	dc.b	"This instruction requires 3 operands: vN,rA,rB",13,0
	align
ops1vr_needed:	dc.b	"This instruction requires just one operand: vN",13,0
	align
ops3vrn:	dc.b	"This instruction requires 3 vector register operands: vD,VA,vB",13,0
	align
ops4vrn:	dc.b	"This instruction requires 4 vector register operands: vD,VA,vB,vC",13,0
	align
ops2vrn:	dc.b	"This instruction requires 2 vector register operands: vD,VB",13,0
	align
ops4v1i:	dc.b	"This instruction requires four operands; vD,vA,vB,SH",13,0
	align
ops1si:	dc.b	"This instruction requires one operand; STRM",13,0
	align
op1_vect:	dc.b	"Operand 1 must be a vector register such as v3 (v0 to v31 allowed).",13,0
	align
op2_vect:	dc.b	"Operand 2 must be a vector register such as v21 (v0 to v31 allowed).",13,0
	align
op3_vect:	dc.b	"Operand 3 must be a vector register such as v17 (v0 to v31 allowed).",13,0
	align
op4_vect:	dc.b	"Operand 4 must be a vector register such as v11 (v0 to v31 allowed).",13,0
	align
op4_imm:	dc.b	"Operand 4 must be immediate data for this shift instruction (0-7).",13,0
	align

ops2v1i:	dc.b	"This instruction requires 2 vector registers and immediate data as its operands: vD,vB,IMM",13,0
	align
op2_gpr:	dc.b	"Operand 2 must be a GPR such as r3.",13,0
	align
op3_gpr:	dc.b	"Operand 3 must be a GPR such as r11.",13,0
	align
op1_gpr:	dc.b	"Operand 1 must be a GPR such as r5.",13,0
	align

op3_imm:	dc.b	"Operand 3 must be immediate data for this instruction.",13,0
	align
op3_imm_bad_size:	dc.b	"Operand 3 must by unsigned immediate data in the range of 0 to 31.",13,0
	align
ops1v1si:	dc.b	"This instruction requires one vector register, and one signed +/-15 immediate operand.",13,0
	align
op2_simm:	dc.b	"Operand 2 must be signed immediate data in the range +/-15.",13,0
	align
vsl_shift_bad_size:	dc.b	"Operand 4, the shift value, must be in the range 0-7.",13,0
	align
stream_err:	dc.b	"The stream must be in the range 0 to 3.",13,0
	align
touch_bit_err:	dc.b	"The touch field may be either 1 or 0.",13,0
	align
	extern	put_ppc,pass1_error,get_ops_ppc,get_ppc_operand,get_three,get_one,get_four
	extern	get_two,pass1_warning