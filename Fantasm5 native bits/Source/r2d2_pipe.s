	include	r2d2_support_macros
;	includeh	memory.def

*******************************************************************************
*Project:       Fanatsm                                                       *
*Author:        LS97                                                          *
*Filename:      R2D2 pipeline control                                         *
*Version:                                                                     *
*Date started:  9:48:07 on 24th August 1997                                   *
*
*Rev. History:  24/08/97 - Rob - Created basic shell
*
*
*******************************************************************************
	
	
	macs_last
	proc_ppc
;
; CHANGES !!!!!!
;
;
; Move locking and unlocking to init and term
;  Move block high then lock.
;
; do we need to de-ref every time if locked????
;


	
;
;
pipe_init:		section
	sub_in
; get some memory
	movei	r3,total_pipe_size
	Xcall	NewHandle
	macs_last
	stw		r3,pipe_handle(`bss)

	cmpwi	r3,0
	beq		exit_init			; quit then

;	lwz		r3,pipe_handle(`bss)
	Xcall HLock	
	macs_last
; setup pipe_top register to point at the first entry
	lwz		r3,pipe_handle(`bss)	; fetch master pointer address
	lwz		`pipe_top,(r3)			; fetch address of data
; setup pipe_bottom register to point at the LAST entry
	addi	`pipe_bottom,`pipe_top,total_pipe_size-pipeR_size

; set up entry and exit registers
	mr		`pipe_entry,`pipe_top
	mr		`pipe_exit,`pipe_entry
	next_record	`pipe_exit


; make all entries invalid
	mr	r4,`pipe_top
	li	r5,FALSE
.invalidate_loop

	stw	r5,pipeR_entry_valid(r4)
	next_record	r4
	
; carry on looping until we find the top of the loop again
	cmpw	r4,`pipe_top
	bne		.invalidate_loop
	
	
	bl	store_pipe		; store the pipe      (no s**t!)

exit_init:
	sub_out
	blr



; OUT r3=good pipe. If r3=0 DO NOT RUN ANYTHING BUT INIT
pipe_dead?:
	lwz		r3,pipe_handle(`bss)
	blr


pipe_dispose:	section
	sub_in

	lwz		r3,pipe_handle(`bss)
	Xcall DisposeHandle	
	macs_last
	sub_out


;
; Turn the pipe on by loading all of the registers back
;	
recall_pipe:
	sub_in
	lwz		r3,pipe_handle(`bss)
	Xcall HLock	
	macs_last
; setup pipe_top register to point at the first entry
	lwz		r3,pipe_handle(`bss)	; fetch master pointer address
	lwz		`pipe_top,(r3)			; fetch address of data
; setup pipe_bottom register to point at the LAST entry
	addi	`pipe_bottom,`pipe_top,total_pipe_size-pipeR_size


; re-synthesize the entry and exit points
	lwz		 r3,pipe_entry_offset_store(`bss)	
	lwz		 r4,pipe_exit_offset_store(`bss)
	
	add		`pipe_entry,`pipe_top,r3
	add		`pipe_exit,`pipe_bottom,r4

	sub_out
	blr

;
; store all of the registers we need
;
store_pipe:
	sub_in
	subf	r3,`pipe_top,`pipe_entry		; r3=entry-top
	subf	r4,`pipe_top,`pipe_exit			; r4=exit-top

	stw		r3,pipe_entry_offset_store(`bss)	
	stw		r4,pipe_exit_offset_store(`bss)


	lwz		r3,pipe_handle(`bss)
	Xcall HUnlock
	macs_last	 
	sub_out
	blr


; Input an intruction to the pipe
;
; IN: r3=instruction
; DESTROYED:	r4,r5
; ALTERED:		`pipe_entry, `pipe_exit  and pipeR
;
pipe_input:
; step over last instruction
	next_record		`pipe_entry
	next_record		`pipe_exit

; lets store the instruction
	find_insert_record	r4
	stw	r3,pipeR_instruction(r4)
	
; make this entry valid
	li	r5,TRUE
	stw	r5,pipeR_entry_valid(r4)

	blr

	global	pipe_init,recall_pipe,store_pipe,pipe_input,pipe_dead?,pipe_dispose
	
	

	