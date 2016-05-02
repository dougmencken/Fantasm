	include	r2d2_support_macros
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

	macs_last
cmp_routine:
	sub_in
**Extract bf from 6-9
	li	r3,pipe_B+pipe_A
	lwz	r4,the_instruction(r25)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
**now set BF in pipeR_tocc
	extrwi	r5,r4,3,6
	stw	r5,pipeR_tocc(r20)
	li	r5,int_class+cmp_class
	stw	r5,pipeR_instr_class(r20)

	sub_out
	global	cmp_routine
tw:
	sub_in
**Extract bf from 6-9
	li	r3,pipe_B+pipe_A
	lwz	r4,the_instruction(r25)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,bra_class	*4=bra
	stw	r5,pipeR_instr_class(r20)

	sub_out
	global	tw

three_dot_no_load:
	section
	sub_in
**Extract bf from 6-9
	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(r25)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)
**check dot
	lwz	r4,the_instruction(r25)
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
	li	r3,pipe_A+pipe_DS
	lwz	r4,the_instruction(r25)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)
**check dot
	lwz	r4,the_instruction(r25)
	andi.	r4,r4,1
	beq	.no_dot
	li	r5,0	*4=bra
	stw	r5,pipeR_tocc(r20)

.no_dot:
	sub_out
	global	two_dot_no_load

one_no_dot_load:
	section
	sub_in
**Extract bf from 6-9
	li	r3,pipe_DS
	lwz	r4,the_instruction(r25)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)
	li	r6,1	*1=reading from mem
	stw	r6,pipeR_memory_read(r20)

	sub_out
	global	one_no_dot_load


*Condition reg to reg
mfcr_routine:
	sub_in
	lwz	r4,the_instruction(r25)
	li	r3,pipe_DS
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	mfcr_routine
three_load:
	sub_in
	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)

	sub_out
	global	three_load
float_three_load:
	sub_in
	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_float_pipe_fii	*decodes r3 and sets pipe fields
	li	r5,float_class
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)
	sub_out
	global	float_three_load
	extern	IDecode_set_float_pipe_fii

float_two_load:
	sub_in
	li	r3,pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_float_pipe_fi	*decodes r3 and sets pipe fields
	li	r5,float_class
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)
	sub_out
	global	float_two_load
float_two_store:
	sub_in
	li	r3,pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_float_pipe_fi	*decodes r3 and sets pipe fields
	li	r5,float_class
	stw	r5,pipeR_instr_class(r20)
	li	r6,1	*T needs to be settled
	stw	r6,pipeR_Tneeded(r20)
	sub_out
	global	float_two_store

	extern	IDecode_set_float_pipe_fi

three_no_load:
	sub_in
	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class	*2=int
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	three_no_load

three_no_load_and_flush:
	sub_in
	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class+flush_class
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	three_no_load_and_flush

three_load_and_flush:
	sub_in
	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class+flush_class
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)
	sub_out
	global	three_load_and_flush

two_load:
	sub_in

	li	r3,pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)

	sub_out
	global	two_load

two_load_and_flush:
	sub_in

	li	r3,pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class+flush_class	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*1=reading from mem
	stw	r5,pipeR_memory_read(r20)

	sub_out
	global	two_load_and_flush

nil_dependencies:
	blr
just_A:
	sub_in
	li	r3,pipe_A
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class	*2=int
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	just_A

store_DS:	*ROB!
	sub_in

	li	r3,pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*T needs to be settled
	stw	r5,pipeR_Tneeded(r20)

	sub_out
	global	store_DS
	
store_DS_lrctr:	*ROB!
	sub_in
	section
	li	r3,pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class	*2=int
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*T needs to be settled
	stw	r5,pipeR_Tneeded(r20)
***Check spr
**Get spr in r7 - book III pg 385
	extrwi	r5,r4,5,11	spr 0-4
	extrwi	r6,r4,5,16	spr 5-9
	slwi	r7,r6,5
	or	r7,r7,r5
**
	cmpwi	r7,8
	beq	.to_lr
	cmpwi	r7,9
	beq	.to_ctr
	b	.do_nothing
.to_lr:
	li	r5,1
	stw	r5,pipeR_tolink(r20)
	b	.do_nothing
.to_ctr:
	li	r5,1
	stw	r5,pipeR_toctr(r20)
	
.do_nothing:
	sub_out
	global	store_DS_lrctr

move_from_spr:	*ROB!
	sub_in
	section
	li	r3,pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class	*2=int
	stw	r5,pipeR_instr_class(r20)
***Check spr
**Get spr in r7 - book III pg 385
	extrwi	r5,r4,5,11	spr 0-4
	extrwi	r6,r4,5,16	spr 5-9
	slwi	r7,r6,5
	or	r7,r7,r5
**
	cmpwi	r7,8
	beq	.to_lr
	cmpwi	r7,9
	beq	.to_ctr
	b	.do_nothing
.to_lr:
	li	r5,1
	stw	r5,pipeR_fromlink(r20)
	b	.do_nothing
.to_ctr:
	li	r5,1
	stw	r5,pipeR_fromctr(r20)
	
.do_nothing:
	sub_out
	global	move_from_spr
	
ab_no_ds:	*cache instructions mainly
	sub_in
	li	r3,pipe_A+pipe_B
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	ab_no_ds

store_two:
	sub_in
	li	r3,pipe_DS+pipe_A
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)
	li	r6,1	*T needs to be settled
	stw	r6,pipeR_Tneeded(r20)

	sub_out
	global	store_two

store_two_and_flush:
	sub_in
	li	r3,pipe_DS+pipe_A
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class+flush_class
	stw	r5,pipeR_instr_class(r20)
	li	r6,1	*T needs to be settled
	stw	r6,pipeR_Tneeded(r20)

	sub_out
	global	store_two_and_flush

store_three:
	sub_in
	li	r3,pipe_DS+pipe_A+pipe_B
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)
	li	r6,1	*T needs to be settled
	stw	r6,pipeR_Tneeded(r20)

	sub_out
	global	store_three
store_three_and_flush:
	sub_in
	li	r3,pipe_DS+pipe_A+pipe_B
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class+flush_class
	stw	r5,pipeR_instr_class(r20)
	li	r6,1	*T needs to be settled
	stw	r6,pipeR_Tneeded(r20)

	sub_out
	global	store_three_and_flush

store_three_dot:
	section
	sub_in
	li	r3,pipe_DS+pipe_A+pipe_B
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_int_pipe	*decodes r3 and sets pipe fields
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)
	li	r5,1	*T needs to be settled
	stw	r5,pipeR_Tneeded(r20)
	li	r6,0	*4=bra
	stw	r6,pipeR_tocc(r20)
**check dot
	lwz	r4,the_instruction(`bss)
	andi.	r4,r4,1
	beq	.no_dot
	li	r5,0	*4=bra
	stw	r5,pipeR_tocc(r20)

.no_dot:

	sub_out
	global	store_three_dot

store_float_three:
	sub_in

	li	r3,pipe_B+pipe_A+pipe_DS
	lwz	r4,the_instruction(`bss)
	bl	IDecode_set_float_pipe_fii	*decodes r3 and sets pipe fields
	li	r5,float_class
	stw	r5,pipeR_instr_class(r20)
	li	r6,1	*T needs to be settled
	stw	r6,pipeR_Tneeded(r20)
	sub_out
	global	store_float_three



to_cr:
	sub_in
	find_insert_record	r20
	lwz	r4,the_instruction(`bss)
	extrwi	r5,r4,3,6
	stw	r5,pipeR_tocc(r20)
	li	r5,int_class
	stw	r5,pipeR_instr_class(r20)	
	sub_out
	global	to_cr
do_flush:
	section
	sub_in
	li	r5,flush_class
	stw	r5,pipeR_instr_class(r20)
	sub_out
	global	do_flush

	global	nil_dependencies
	extern	IDecode_set_int_pipe