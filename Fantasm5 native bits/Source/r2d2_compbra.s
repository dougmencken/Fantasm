	include	r2d2_support_macros
*******************************************************************************
*Project:                                                                     *
*Author:        Lob                                                           *
*Filename:      r2d2_compbra.s                                                *
*Version:                                                                     *
*Date started:  20:57:23 on 24th August 1997                                  *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************

	macs_last



; 1. Place at least three independent fixed point instructions between a compare and a branch
; dependent on that compare. As long as a previous instructions doesn't cause the compare
; to stall, this will guarantee that the branch is not dispatched until the compare results
; are available.

;
; Mod this routine so that it doesn't give a warning if it finds a non-conditional branch 
; before it finds the condition that it is dependant on ---- see patch code below....
;
compare_branch_warn:
		sub_in
		
		lwz		r6,prefs_flags_ptr(`bss)
		lwz		r6,(r6)

		bl		convert_prefs_to_search_level

		
; we want to check fromcc-tocc problems
		find_insert_record	r7
		lwz		r4,pipeR_fromcc(r7)
		cmpwi	r4,-1
		beq		not_this_check			;  was maybe_dual_source_cc
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,bra_class
		bne		not_this_check

do_checking:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		not_this_check


		lwz		r3,pipeR_instr_class(r7)
; ---------- patch code ---------
		cmpwi	r3,bra_class
		bne		continue_normally
		
		lwz		r3,pipeR_fromcc(r7)
		cmpwi	r3,-1
		beq		not_this_check			; break out if non-conditional branch
continue_normally:
; ------- end patch code ----------

		andi.	r3,r3,cmp_class
		beq		next_check			; if not compare, skip

		lwz		r3,pipeR_tocc(r7)
		cmpw	r3,r4
		beq		send_warning

next_check:
		bdnz	do_checking
		b		not_this_check
		
send_warning:			; Send stall warning to log
	lwz	r3,cc_not_ready_message(rtoc)
	lwz	r4,cc_not_ready_warning(rtoc)
	bl	do_pass1_warning


not_this_check:
		sub_out
		

;maybe_dual_source_cc:
;		
;; we want to check dual fromcc - tocc problems
;	 	 lwz		 r4,pipeR_regT(r7)
;	 	 cmpwi	 r4,-2
;	 	 bne		 no_more_checks
;	 	 	 
;	 	 lwz		 r4,pipeR_regA(r7)
;	 	 lwz		 r5,pipeR_regB(r7)
;	 	 
;
;do_checking:
;	 	 previous_record	r7
;	 	 lwz		 r3,pipeR_entry_valid(r7)
;	 	 cmpwi	 r3,FALSE
;	 	 beq		 not_this_check
;	 	 
;	 	 lwz		 r3,pipeR_tocc(r7)
;	 	 cmpw	 r3,r4
;	 	 beq		 send_warning2
;	 	 
;	 	 cmpw	 r3,r5
;	 	 beq		 send_warning2
;	 	 
;	 	 bdnz	 do_checking
;	 	 b	 	 not_this_check
;	 	 
;send_warning2:		 	 	 	 	 	 	 ; Send stall warning to log
;	 		 lwz	r3,cc_not_ready_message(rtoc)
;	 	 bl	do_pass1_warning
;
;no_more_checks:
;	 	 sub_out
		


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



cc_not_ready_message:	cstring	"***Stall Warning*** Condition Code may not be ready!",13
cc_not_ready_warning:	cstring "Insert at least three independant fixed-point",13,"instructions in-between.",13
	align

	global	compare_branch_warn
	extern	do_pass1_warning
	
	
	
	
	