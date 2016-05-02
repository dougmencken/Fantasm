	include	r2d2_support_macros
*******************************************************************************
*Project:                                                                     *
*Author:        Lob                                                           *
*Filename:      r2d2_bra_tagging.s                                            *
*Version:                                                                     *
*Date started:  19:44:38 on 27th August 1997                                  *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************

	macs_last
; 4. For each conditional branch, make sure that there is a fixed-point instruction within three
; instructions before the branch. This insures that the branch has an instruction to tag and prevents it
; from generating a bubble. This is especially important for a series of coniditional branches which 
; are not taken - each branch instruction needs its own fixed-point instruction to tag. 
; Alternating branches and fixed-point insturctions is a common way of addressing this problem.


branch_tagging_warn:
		sub_in

;		lwz		r6,prefs_flags_ptr(`bss)
;		lwz		r6,(r6)
;		bl		convert_prefs_to_search_level

		
; we want to check conditional branch problems
		find_insert_record	r7

		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,bra_class
		bne		bt_not_this_check

		lwz		r4,pipeR_fromcc(r7)
		cmpwi	r4,-1
		beq		bt_not_this_check			;  must be conditional branch

;		Debug

		li		r6,3			; must be within 3 instruction otherwise a warning
		mtctr	r6

bt_do_checking:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		bt_not_this_check
		
		lwz		r3,pipeR_instr_class(r7)
		andi.	r3,r3,int_class
		beq		bt_next_check			; if not integer instruction, skip

		lwz		r3,pipeR_branch_tagged(r7)
		cmpwi	r3,-1
		beq		bt_found_non_tagged_int

bt_next_check:
		bdnz	bt_do_checking

bt_send_warning:			; Send stall warning to log
	lwz	r3,bra_tag_message(rtoc)
	lwz	r4,bra_tag_warning(rtoc)
	bl	do_pass1_warning
	b	bt_not_this_check


bt_found_non_tagged_int:
		li	r3,0
		stw	r3,pipeR_branch_tagged(r7)

bt_not_this_check:
		sub_out



;;-------------beginning of convert prefs to search level ---------------
;convert_prefs_to_search_level:
;	 	 cmpwi	 r6,warn_hot
;	 	 bne		 not_hot
;	 	 li		 r6,3
;	 	 b	 	 out_conv
;not_hot:	 	 
;;;;;;; check medium ;;;;;;;;;;
;	 	 cmpwi	 r6,warn_medium
;	 	 bne		 not_med
;	 	 li		 r6,2
;	 	 b	 	 out_conv
;not_med:
;;;;;;;; must be low;;;;;;;;
;	 	 li		 r6,1
;out_conv:
;	 	 mtctr	 r6
;	 	 
;	 	 blr
;;-------------end of convert prefs to search level ---------------



bra_tag_message:	cstring	"***Stall Warning*** Conditional Branch does not have an instruction to tag!",13
bra_tag_warning:	cstring "Ensure there is a fixed-point instruction within three instructions before the branch.",13
	align

	global	branch_tagging_warn
	extern	do_pass1_warning
	
	
	global	bt_do_checking,bt_found_non_tagged_int,bt_not_this_check
	global	bt_next_check,bt_send_warning
	
	
	


