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



; 3. Place at least four independant fixed-point instructions between a mtlr or mtctr 
; instruction and a branch dependant on the SPR. As long as a previous instruction doesn't
; cause the move to SPR instruction to stall, this will cause the instruction to be executed
; at the same time the SPR is being updated.


mtSPR_bSPR_warn:
		sub_in
		
		lwz		r6,prefs_flags_ptr(`bss)
		lwz		r6,(r6)

		bl		convert_prefs_to_search_level

; check we are in this ball park
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,bra_class
		bne		not_this_check

; we want to check mtlr problems
		find_insert_record	r7
		lwz		r4,pipeR_fromlink(r7)
		cmpwi	r4,-1
		beq		try_ctr
		
do_checking:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		not_this_check
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,int_class
		bne		next_check
		
		lwz		r3,pipeR_tolink(r7)
		cmpwi	r3,-1
		bne		send_warning

next_check:
		bdnz	do_checking
		b		not_this_check
		
send_warning:			; Send stall warning to log
	lwz	r3,link_not_ready_message(rtoc)
	bl	do_pass1_warning
	b	not_this_check

; NOTE: this instruction can be either be a
; bctr or a blr, not both!
try_ctr:
; we want to check mtctr problems
		lwz		r4,pipeR_fromctr(r7)
		cmpwi	r4,-1
		beq		not_this_check

do_checking2:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		not_this_check
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,int_class
		bne		next_check
		
		lwz		r3,pipeR_toctr(r7)
		cmpwi	r3,-1
		bne		send_warning

next_check:
		bdnz	do_checking2
		b		not_this_check
		
send_warning:			; Send stall warning to log
	lwz	r3,ctr_not_ready_message(rtoc)
	bl	do_pass1_warning



not_this_check:
		sub_out
		


;-------------beginning of convert prefs to search level ---------------
convert_prefs_to_search_level:
		cmpwi	r6,warn_hot
		bne		not_hot
		li		r6,4
		b		do_checking
not_hot:		
;;;;;; check medium ;;;;;;;;;;
		cmpwi	r6,warn_medium
		bne		not_med
		li		r6,3
		b		do_checking
not_med:
;;;;;;; must be low;;;;;;;;
		li		r6,1

		mtctr	r6
		
		sub_out
;-------------end of convert prefs to search level ---------------



ctr_not_ready_message:	cstring	"***Stall Warning*** Counter Register may not be ready!",13," ...insert at least four independant fixed point in-between ",13
link_not_ready_message:	cstring	"***Stall Warning*** Link Register may not be ready!",13," ...insert at least four independant fixed point in-between ",13

	align

	global	mtSPR_bSPR_warn
	extern	do_pass1_warning
	
	
	
	
	