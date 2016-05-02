	include	r2d2_support_macros
*******************************************************************************
*Project:       Fanatsm                                                       *
*Author:        LS97                                                          *
*Filename:      R2D2 top level                                                *
*Version:                                                                     *
*Date started:  1:55:07 on 22nd August 1997                                   *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************
*requires 1 ptr to field1. Each field is 528 bytes each. r6
*requires address of pass1_error in r4 (a2 in 68k side)
*requires current instruction in r3 (d0 in 68k side)
*requires ptr to prefs flags in r5

	macs_last
r2d2:
	mflr r0
	stw r0,8(sp)		*Store link register on the stack
	stmw r10,-88(sp)	*Save r10-r31
	stwu sp,-64+88(sp)	*Skip over the stack space
;	lwz r30,(rtoc)		*Load global data (bss) pointer (first entry in TOC)
	stw r2,20(sp)		*Save RTOC;

	stw	r3,the_instruction(`bss)
	stw	r4,pass1_error_ptr(`bss)
	stw	r5,prefs_flags_ptr(`bss)
	stw r6,field_1_ptr(`bss)	*field 2 is field1-field_size
**wizard bits go here
	bl	r2d2_main


************************************
**Test send message to log
;   li	r4,0					; no warning
;	lwz	r3,test_message(rtoc)
;	bl	do_pass1_warning

**returns - global 68k flag for fantasm which is 
**0=r2d2 finished, 1=needs to run again.
	movei	r3,0
	lwz r0,64+8+88(sp)	*good bye
	mtlr r0
	addi sp,sp,64+88		*Reset stack pointer
	lmw r10,-88(sp)			*Restore r10-r31
	blr					*back to Anvil
	
	
r2d2_init:
	mflr r0
	stw r0,8(sp)		*Store link register on the stack
	stmw r10,-88(sp)	*Save r10-r31
	stwu sp,-64+88(sp)	*Skip over the stack space
;	lwz r30,(rtoc)		*Load global data (bss) pointer (first entry in TOC)
	stw r2,20(sp)		*Save RTOC;

	bl	pipe_init

	lwz r0,64+8+88(sp)	*good bye
	mtlr r0
	addi sp,sp,64+88		*Reset stack pointer
	lmw r10,-88(sp)			*Restore r10-r31
	blr					*back to Anvil



r2d2_term:	section	term
	mflr r0
	stw r0,8(sp)		*Store link register on the stack
	stmw r10,-88(sp)	*Save r10-r31
	stwu sp,-64+88(sp)	*Skip over the stack space
;	lwz r30,(rtoc)		*Load global data (bss) pointer (first entry in TOC)
	stw r2,20(sp)		*Save RTOC;

	bl		pipe_dead?			; shouldn't run anything if pipe is dead
	cmpwi	r3,0
	beq		.exit			; quit then

	bl	pipe_dispose

.exit:
	lwz r0,64+8+88(sp)	*good bye
	mtlr r0
	addi sp,sp,64+88		*Reset stack pointer
	lmw r10,-88(sp)			*Restore r10-r31
	blr					*back to Anvil

	global	r2d2,r2d2_term,r2d2_init
	extern	do_pass1_warning,r2d2_main,pipe_init,pipe_dispose,pipe_dead?
	

	
	
	
	
	
	
	