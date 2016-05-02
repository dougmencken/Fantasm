	include	r2d2_support_macros
*******************************************************************************
*Project:                                                                     *
*Author:        Everybody except Rob n Stu.                                   *
*Filename:      r2d2_main                                                     *
*Version:                                                                     *
*Date started:  10:20:36 on 24th August 1997                                  *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************
	macs_last

r2d2_main:		section
	sub_in

	bl		pipe_dead?			; shouldn't run anything if pipe is dead
	cmpwi	r3,0
	beq		exit			; quit then


;; ---test patch----
;	lwz	r4,prefs_flags_ptr(`bss)
;	li	r3,warn_hot
;	 stw	r3,(r4)		 ; store 3 in the prefs
;; ---end test patch---


; otherwise carry on with life
	bl	recall_pipe
	bl	pipe_input		; r3=instruction
; decode
	bl	r2d2_Idecode
; examine
	bl	compare_branch_warn
	bl	int_record_bit_bra_warn
	bl	mtSPR_bSPR_warn

	bl	branch_tagging_warn
	bl	float_record_bit_bra_warn
	bl	load_gpr_warn
	
	bl	fpr_update_warn
	
; get out of here
	bl	store_pipe

exit:
	sub_out


	global	r2d2_main
	extern recall_pipe,store_pipe,pipe_input,pipe_dead?
	extern r2d2_Idecode
	extern compare_branch_warn,int_record_bit_bra_warn,mtSPR_bSPR_warn
	extern branch_tagging_warn,float_record_bit_bra_warn,load_gpr_warn
	extern fpr_update_warn
	