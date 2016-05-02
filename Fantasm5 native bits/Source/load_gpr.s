	include	r2d2_support_macros
*******************************************************************************
*Project:                                                                     *
*Author:        Rob                                                           *
*Filename:      load_gpr.s                                                      *
*Version:                                                                     *
*Date started:  20:28:47 on 28th August 1997                                  *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************

	macs_last

; 7. Place at least one independent fixed-point instruction between a load of a GPR and an
; instruction which uses the loaded register value. This extra instruction will cover the 
; delay assuming a cache hit. More inpendent instructions are necessary to cover the delay due
; to a cache miss.



load_gpr_warn:
		sub_in
		
		lwz		r6,prefs_flags_ptr(r25)
		lwz		r6,(r6)

		bl		convert_prefs_to_search_level

		
; we want to check fromcc-tocc problems
		find_insert_record	r7

		lwz		r3,pipeR_instr_class(r7)
		andi.	r3,r3,int_class
		beq		lgw_not_this_check			; if not integer instruction, skip
				
		lwz		r4,pipeR_regA(r7)
		cmpwi	r4,-1
		bne		lgw_skip_reload
		li		r4,-9					; random unused value
lgw_skip_reload:
		
		lwz		r5,pipeR_regB(r7)
		cmpwi	r5,-1
		bne		lgw_skip_reload2
		li		r5,-9
lgw_skip_reload2:

; we need the regT for stores as well
		lwz		r3,pipeR_Tneeded(r7)
		cmpwi	r3,-1
		bne		its_a_store
		li		r8,-2					; not a store
		b		lgw_skip_reload3
		
its_a_store:
		lwz		r8,pipeR_regT(r7)
		cmpwi	r8,-1
		bne		lgw_skip_reload3
		li		r8,-9
lgw_skip_reload3:

;;;;		li		r6,8		; go back only eight instructions
		mtctr	r6

; look back until we find (a) unrelated integer instruction (i.e. non load of either
; register), (b) a memory read instruction with a the load of this reg - issue a warning.
;
lgw_do_checking:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		lgw_not_this_check				; abort if not valid

		lwz		r3,pipeR_instr_class(r7)
		andi.	r3,r3,int_class
		beq		lgw_next_check			; if not integer instruction, go to next instruction


; T_needed is like source in store
; ???? the target?????
;		lwz		r3,pipeR_Tneeded(r7)
;		cmpwi	r3,-1
;		bne		its_a_store

		lwz		r3,pipeR_memory_read(r7)
		cmpwi	r3,1
		bne		lgw_next_check			; next check if this isn't a memory read
		
		cmpwi	r8,-2
		bne		lgw_store_checking
		
		lwz		r3,pipeR_regT(r7)	; the target????
		cmpw	r3,r4
		beq		lgw_nearly_warning
		
		cmpw	r3,r5
		beq		lgw_nearly_warning
		b		lgw_next_check
		
lgw_store_checking:
		lwz		r3,pipeR_regT(r7)
		cmpw	r3,r8					; compare two target registers for store
		beq		lgw_nearly_warning
		
lgw_next_check:
		bdnz	lgw_do_checking
		b		lgw_not_this_check
		
lgw_nearly_warning:
		lwz		r3,pipeR_memory_read(r7)
		cmpwi	r3,1
		bne		lgw_not_this_check

		lwz	r3,load_not_ready_message(rtoc)
		lwz	r4,load_not_ready_warning(rtoc)
		bl		do_pass1_warning

lgw_not_this_check:
		sub_out

;-------------beginning of convert prefs to search level ---------------
convert_prefs_to_search_level:

		cmpwi	r6,warn_hot
		bne		not_hot
		li		r6,8
		b		out_conv
not_hot:		
;;;;;; check medium ;;;;;;;;;;
		cmpwi	r6,warn_medium
		bne		not_med
		li		r6,4
		b		out_conv
not_med:
;;;;;;; must be low;;;;;;;;
		li		r6,1

out_conv:
		mtctr	r6
		blr
;-------------end of convert prefs to search level ---------------


load_not_ready_message:	cstring	"***Stall Warning*** GPR may not be ready!",13
load_not_ready_warning: cstring "One fixed instruction can execute with a cache hit, more for a cache miss.",13
	align

	global	load_gpr_warn
	extern	do_pass1_warning
	
; for debugging purposes
	global	lgw_not_this_check,lgw_nearly_warning,lgw_next_check,lgw_do_checking
	global lgw_skip_reload2,lgw_skip_reload
	
	