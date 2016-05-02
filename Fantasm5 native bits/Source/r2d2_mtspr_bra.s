	include	r2d2_support_macros
*******************************************************************************
*Project:                                                                     *
*Author:        Lob                                                           *
*Filename:      r2d2_intrecord.s                                              *
*Version:                                                                     *
*Date started:  21:30:00 on 26th August 1997                                  *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************


	macs_last

; 3. Place at least four independant fixed-point instructions between a mtlr or mtctr 
; instruction and a branch dependant on the SPR. As long as a previous instruction doesn't
; cause the move to SPR instruction to stall, this will cause the instruction to be executed
; at the same time the SPR is being updated.


mtSPR_bSPR_warn:
		sub_in
		
		lwz		r6,prefs_flags_ptr(`bss)
		lwz		r6,(r6)

		bl		mb_convert_prefs_to_search_l

		find_insert_record	r7

; check we are in this ball park
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,bra_class
		bne		mb_not_this_check

; we want to check mtlr problems
		lwz		r4,pipeR_fromlink(r7)
		cmpwi	r4,-1
		beq		mb_try_ctr
	
;		Debug
;		mtctr	r6			; also a debug line	
		
mb_do_checking:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		mb_not_this_check
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,int_class
		bne		mb_next_check
		
		lwz		r3,pipeR_tolink(r7)
		cmpw	r3,r4
		beq		mb_send_warning

mb_next_check:
		bdnz	mb_do_checking
		b		mb_not_this_check
		
mb_send_warning:			; Send stall warning to log
	lwz	r3,link_not_ready_message(rtoc)
	lwz	r4,link_not_ready_warning(rtoc)
	bl	do_pass1_warning
	b	mb_not_this_check

; NOTE: this instruction can be either be a
; bctr or a blr, not both!
mb_try_ctr:

;		Debug
;		mtctr	r6			; also a debug line	

; we want to check mtctr problems
		lwz		r4,pipeR_fromctr(r7)
		cmpwi	r4,-1
		beq		mb_not_this_check



mb_do_checking2:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		mb_not_this_check
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,int_class
		bne		mb_next_check2
		
		lwz		r3,pipeR_toctr(r7)
		cmpw	r3,r4
		beq		mb_send_warning2

mb_next_check2:
		bdnz	mb_do_checking2
		b		mb_not_this_check
		
mb_send_warning2:			; Send stall warning to log
	lwz	r3,ctr_not_ready_message(rtoc)
	lwz	r4,ctr_not_ready_warning(rtoc)
	bl	do_pass1_warning



mb_not_this_check:
		sub_out
		


;-------------beginning of convert prefs to search level ---------------
mb_convert_prefs_to_search_l:
		cmpwi	r6,warn_hot
		bne		mb_not_hot
		li		r6,4
		b		mb_out_conv
mb_not_hot:		
;;;;;; check medium ;;;;;;;;;;
		cmpwi	r6,warn_medium
		bne		mb_not_med
		li		r6,3
		b		mb_out_conv
mb_not_med:
;;;;;;; must be low;;;;;;;;
		li		r6,1
mb_out_conv:
		mtctr	r6
		
		blr
;-------------end of convert prefs to search level ---------------



ctr_not_ready_message:	cstring	"***Stall Warning*** Counter Register may not be ready!",13
ctr_not_ready_warning:	cstring "Insert at least four independant fixed point in-between ",13
link_not_ready_message:	cstring	"***Stall Warning*** Link Register may not be ready!",13
link_not_ready_warning:	cstring "Insert at least four independant fixed point in-between ",13

	align

	global	mtSPR_bSPR_warn
	extern	do_pass1_warning
	
; debugging only

	global mb_send_warning2,mb_next_check2,mb_do_checking2,mb_try_ctr
	global mb_send_warning,mb_next_check,mb_do_checking
	global mb_not_this_check
	global mb_convert_prefs_to_search_l,mb_not_hot,mb_not_med,mb_out_conv
	
	
	
	
	
	
	
	
	
	
								
	