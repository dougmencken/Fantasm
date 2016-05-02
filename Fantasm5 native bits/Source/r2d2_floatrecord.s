	include	r2d2_support_macros
*******************************************************************************
*Project:                                                                     *
*Author:        Rob                                                           *
*Filename:      r2d2_floatrecord.s                                            *
*Version:                                                                     *
*Date started:  20:01:35 on 27th August 1997                                  *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************

	macs_last

; 6. For a flaoting-point instruction with the Record bit set and a branch dependent on the 
; results of that instruction, place at least three independant fixed-point instructions before
; the floating-point instruction, and at least five independant fixed- or floating-point 
; instructions between the floating-point and branch insturctions. This will guarantee that the
; results of the floating-point instruction are availble whenthe branch is executed.



float_record_bit_bra_warn:
		sub_in
		
;		lwz		r6,prefs_flags_ptr(`bss)
;		lwz		r6,(r6)
;
;		bl		convert_prefs_to_search_level

		
; we want to check fromcc-tocc problems
		find_insert_record	r7
		lwz		r4,pipeR_fromcc(r7)
		cmpwi	r4,-1
		beq		not_this_check
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,bra_class
		bne		not_this_check

;		Debug

;		li		r6,5
;		mtctr	r6
		

do_checking:
		previous_record	r7
		lwz		r3,pipeR_entry_valid(r7)
		cmpwi	r3,FALSE
		beq		not_this_check

; if this instruction matches the compare, but does not match the float class, quit checking
; if this instruction matches the compare, and does match the float class with record bit
;										   set, then issue warning
; otherwise next instruction


		lwz		r3,pipeR_tocc(r7)
		cmpw	r3,r4
		bne		next_check
		
		lwz		r3,pipeR_instr_class(r7)
		cmpwi	r3,float_class
		bne		not_this_check
		b		send_warning	

next_check:
		bdnz	do_checking
		b		not_this_check

;; now we need to check back to see if we can find 
;; the a floating record entry before this that relates to it....
;
;	 	 subfic	r6,r6,pipe_num_records		 ; number of records remaining
;	 	 mtctr	 r6
;
;do_checking2:
;	 	 previous_record	r7
;	 	 lwz		 r3,pipeR_entry_valid(r7)
;	 	 cmpwi	 r3,FALSE
;	 	 beq		 not_this_check2
;
;; if this instruction matches the compare, but does not match the float class, quit checking
;; if this instruction matches the compare, and does match the float class with record bit
;;	 	 	 	 	 	 	 	 	 	    set, then we have found the float to check 
;;	 	 	 	 	 	 	 	 	 	 	 before
;;
;; otherwise next instruction
;
;
;	 	 lwz		 r3,pipeR_tocc(r7)
;	 	 cmpw	 r3,r4
;	 	 bne		 next_check
;	 	 
;	 	 lwz		 r3,pipeR_instr_class(r7)
;	 	 cmpwi	 r3,float_class
;	 	 bne		 not_this_check2
;	 	 b	 	 send_	 
;
;next_check:
;	 	 bdnz	 do_checking2
;
;	 	 
;	 	 b	 	 not_this_check2
;	 	 
send_warning:			; Send stall warning to log
	lwz	r3,cc3_not_ready_message(rtoc)
	lwz	r4,cc3_not_ready_warning(rtoc)
	bl	do_pass1_warning
;not_this_check2:

not_this_check:
		sub_out
		


;-------------beginning of convert prefs to search level ---------------
convert_prefs_to_search_level:
		cmpwi	r6,warn_hot
		bne		not_hot
		li		r6,5
		b		out_conv
not_hot:		
;;;;;; check medium ;;;;;;;;;;
		cmpwi	r6,warn_medium
		bne		not_med
		li		r6,3
		b		out_conv
not_med:
;;;;;;; must be low;;;;;;;;
		li		r6,2
out_conv:
		mtctr	r6
		
		blr
;-------------end of convert prefs to search level ---------------



cc3_not_ready_message:	cstring	"***Stall Warning*** Condition Code may not be ready!",13
cc3_not_ready_warning:	cstring "Insert at least five independant fixed or floating point in-between ",13," and three independant fixed point before the floating point instruction.",13
	align

	global	float_record_bit_bra_warn
	extern	do_pass1_warning
	