	include	r2d2_support_macros
*******************************************************************************
*Project:                                                                     *
*Author:        Lob                                                           *
*Filename:      Untitled 2                                                    *
*Version:                                                                     *
*Date started:  21:29:33 on 28th August 1997                                  *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************

	macs_last
; 8. Place at least three independant floating-point instructions between an instructions
; which updates the FPR and an instruction which uses the updated value. This will prevent
; the FPU from stalling until the data is available. Multi-cycle floating-point instructions
; will require additional instructions to be inserted.


fpr_update_warn:
		sub_in
		
		lwz		r6,prefs_flags_ptr(`bss)
		lwz		r6,(r6)

		bl		convert_prefs_to_search_level

		
; we want to check fromcc-tocc problems
		find_insert_record	r7

		lwz		r3,pipeR_instr_class(r7)
		andi.	r3,r3,float_class
		beq		fuw_not_this_check			; if not float instruction, skip
				
		lwz		r4,pipeR_regA(r7)
		cmpwi	r4,-1
		bne		fuw_skip_reload
		li		r4,-9					; random unused value
fuw_skip_reload:
		
		lwz		r5,pipeR_regB(r7)
		cmpwi	r5,-1
		bne		fuw_skip_reload2
		li		r5,-9
fuw_skip_reload2:

; we need the regT for stores as well
		lwz		r3,pipeR_Tneeded(r7)
		cmpwi	r3,-1
		bne		its_a_store
		li		r8,-2					; not a store
		b		fuw_skip_reload3
		
its_a_store:
		lwz		r8,pipeR_regT(r7)
		cmpwi	r8,-1
		bne		fuw_skip_reload3
		li		r8,-9
fuw_skip_reload3:

;;;;		li		r6,8		; go back only eight instructions
		mtctr	r6

; look back until we find (a) unrelated float instruction (i.e. non load of either
; register), (b) a memory read instruction with a the load of this reg - issue a warning.
;
fuw_do_checking:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		fuw_not_this_check				; abort if not valid

		lwz		r3,pipeR_instr_class(r7)
		andi.	r3,r3,float_class
		beq		fuw_next_check			; if not float instruction, go to next instruction


		lwz		r3,pipeR_memory_read(r7)
		cmpwi	r3,1
		bne		fuw_next_check			; next check if this isn't a memory read

		cmpwi	r8,-2
		bne		fuw_store_checking
		
		lwz		r3,pipeR_regT(r7)	; the target????
		cmpw	r3,r4
		beq		fuw_nearly_warning
		
		cmpw	r3,r5
		beq		fuw_nearly_warning
		b		fuw_next_check
		
fuw_store_checking:
		lwz		r3,pipeR_regT(r7)
		cmpw	r3,r8					; compare two target registers for store
		beq		fuw_nearly_warning
		
fuw_next_check:
		bdnz	fuw_do_checking
		b		fuw_not_this_check
		
fuw_nearly_warning:
		lwz		r3,pipeR_memory_read(r7)
		cmpwi	r3,1
		bne		fuw_not_this_check

		lwz	r3,fpr_not_ready_message(rtoc)
		lwz	r4,fpr_not_ready_warning(rtoc)
		bl		do_pass1_warning

fuw_not_this_check:
		sub_out


;-------------beginning of convert prefs to search level ---------------
convert_prefs_to_search_level:

		cmpwi	r6,warn_hot
		bne		not_hot
		li		r6,3
		b		out_conv
not_hot:		
;;;;;; check medium ;;;;;;;;;;
		cmpwi	r6,warn_medium
		bne		not_med
		li		r6,2
		b		out_conv
not_med:
;;;;;;; must be low;;;;;;;;
		li		r6,1

out_conv:
		mtctr	r6
		blr
;-------------end of convert prefs to search level ---------------



fpr_not_ready_message:	cstring	"***Stall Warning*** FPR may not be ready!",13
fpr_not_ready_warning: cstring " three fpu instructions between update and use of an FPR",13
	align

	global	fpr_update_warn
	extern	do_pass1_warning
	
; for debugging purposes
	global	fuw_not_this_check,fuw_nearly_warning,fuw_next_check,fuw_do_checking
	global	fuw_skip_reload2,fuw_skip_reload


