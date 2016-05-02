	include	r2d2_IDecode_set_pipe.def
*******************************************************************************
*Project:                                                                     *
*Author:        ???                                                           *
*Filename:      Untitled 2                                                    *
*Version:                                                                     *
*Date started:  0:25:54 on 26th August 1997                                   *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************
cmp:
	sub_in
**Extract bf from 6-9
	li	r3,pipe_B+pipe_A
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
**now set BF in pipeR_tocc
	extrwi	r5,r4,3,6
	stw	r5,pipeR_tocc(r20)
	li	r5,4	*4=bra
	stw	r5,pipeR_instr_class(r20)

	sub_out
	global	cmp
tw:
	sub_in
**Extract bf from 6-9
	li	r3,pipe_B+pipe_A
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,4	*4=bra
	stw	r5,pipeR_instr_class(r20)

	sub_out
	global	tw

three_dot_no_load:
	section
	sub_in
	Debug
**Extract bf from 6-9
	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*4=bra
	stw	r5,pipeR_instr_class(r20)
**check dot
	lwz	r4,the_instruction(`bss)
	andi.	r4,r4,1
	beq	.no_dot
	li	r5,0	*4=bra
	stw	r5,pipeR_tocc(r20)

.no_dot:
	sub_out
	global	three_dot_no_load
two_dot_no_load:
	section
	sub_in
**Extract bf from 6-9
	li	r3,pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*4=bra
	stw	r5,pipeR_instr_class(r20)
**check dot
	lwz	r4,the_instruction(`bss)
	andi.	r4,r4,1
	beq	.no_dot
	li	r5,0	*4=bra
	stw	r5,pipeR_tocc(r20)

.no_dot:
	sub_out
	global	two_dot_no_load

*Condition reg to reg
mfcr:
	sub_in
	lwz	r4,the_instruction(`bss)
	li	r3,pipe_DS
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*2=int
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	mfcr
three_load:
	sub_in

	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)

	sub_out
	global	three_load
float_three_load:
	sub_in
	Debug
	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_float_pipe_fii	*decodes r3 and sets pipe fields
	li	r5,4	*4=float
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)

	sub_out
	global	float_three_load
	extern	IDecode_set_float_pipe_fii
three_no_load:
	sub_in

	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*2=int
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	three_no_load

two_load:
	sub_in

	li	r3,pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)

	sub_out
	global	two_load
nil_dependencies:
	blr
just_A:
	sub_in
	li	r3,pipe_A
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*2=int
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	just_A

store_DS:	*ROB!
	sub_in

	li	r3,pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*T needs to be settled
	stw	r5,pipeR_Tneeded(r20)

	sub_out
	global	store_DS

store_three:	*ROB!
	sub_in
	li	r3,pipe_DS+pipe_A+pipe_B
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*T needs to be settled
	stw	r5,pipeR_Tneeded(r20)

	sub_out
	global	store_three

store_three_dot:
	section
	sub_in
	li	r3,pipe_DS+pipe_A+pipe_B
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,2	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*T needs to be settled
	stw	r5,pipeR_Tneeded(r20)
	li	r5,0	*4=bra
	stw	r5,pipeR_tocc(r20)
**check dot
	lwz	r4,the_instruction(`bss)
	andi.	r4,r4,1
	beq	.no_dot
	li	r5,0	*4=bra
	stw	r5,pipeR_tocc(r20)

.no_dot:

	sub_out
	global	store_three_dot
to_cr:
	sub_in
	find_insert_record	r20
	lwz	r4,the_instruction(`bss)
	extrwi	r5,r4,3,6
	stw	r5,pipeR_tocc(r20)	
	sub_out
	global	to_cr
	global	nil_dependencies
	extern	IDecode_set_int_pipe