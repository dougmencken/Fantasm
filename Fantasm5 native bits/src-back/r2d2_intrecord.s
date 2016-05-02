*******************************************************************************
*Project:                                                                     *
*Author:        Lob                                                           *
*Filename:      r2d2_intrecord.s                                              *
*Version:                                                                     *
*Date started:  20:40:00 on 26th August 1997                                  *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************



; 2. Place at least four independent fixed-point instructions between a fixed-point instruction 
; with the Record bit set and a branch dependant on the results. As long as a previous 
; instruction doesn't cause the fixed-point instruction to stall, this will cause the branch
; to be executed at the same time as the fixed-point instruction is writing its results to
; the CR. Multi-cycle fixed point instructions will require additional instructions to be 
; inserted.


int_record_bit_bra_warn:
		sub_in
		
		lwz		r6,prefs_flags_ptr(`bss)
		lwz		r6,(r6)

		bl		convert_prefs_to_search_level

		
; we want to check fromcc-tocc problems
		find_insert_record	r7
		lwz		r4,pipeR_fromcc(r7)
		cmpwi	r4,-1
		beq		not_this_check
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,bra_class
		bne		not_this_check

do_checking:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		not_this_check
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,int_class
		bne		next_check
		
		lwz		r3,pipeR_tocc(r7)
		cmpw	r3,r4
		beq		send_warning

next_check:
		bdnz	do_checking
		b		not_this_check
		
send_warning:			; Send stall warning to log
	lwz	r3,cc2_not_ready_message(rtoc)
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



cc2_not_ready_message:	cstring	"***Stall Warning*** Condition Code may not be ready!",13," ...insert at least four independant fixed point in-between ",13," (multi-cycle integer instructions require more)",13
	align

	global	int_record_bit_bra_warn
	extern	do_pass1_warning
	
	
	
	
	