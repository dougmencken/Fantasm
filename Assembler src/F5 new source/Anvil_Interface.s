
	include	client_commands.def

*******************************************************************************
*Project:       Anvil                                                         *
*Author:        Stuart Ball                                                   *
*Filename:      Anvil_Interface.s                                             *
*Version:                                                                     *
*Date started:  3:41:04 on 24th March 1997                                    *
*Rev. History:                                                                *
*                                                                             *
*                                                                             *
*******************************************************************************
	include call_ccp_macro

**needs C string in a0
send_to_error:
	reset_locals
	local.b	my_pb1,300
	link	a4,#-400
	qmove.l	a0,d1		*string
	lea	my_pb1(a4),a0
	qmove.l	#300,(a0)	*command
	qmove.l	d1,4(a0)	*param1
;	move.l	a0,-(sp)	*request parameter block to anvil
;	move.l	callback(a5),a0
;	jsr	(A0)
;	addq.l	#4,sp			*tidy up stack (Ah)	
	call_ccp
	unlk	a4
	rts_	"Send_to_error"	
	


**needs c string in a0
send_to_log:
	reset_locals
	local.b	my_pb2,300
	sub_entry	a4
	qmove.l	a0,d1		*String
	lea	my_pb2(a4),a0
	qmove.l	#320,(a0)	*command
	qmove.l	d1,4(a0)	*param1
;	move.l	a0,-(sp)	*request parameter block to anvil
;	move.l	callback(a5),a0
;	jsr	(A0)
;	addq.l	#4,sp			*tidy up stack (Ah)
	call_ccp
	sub_exit	a4
	rts_	"Send_to_log"

do_idle:
	qmove.l	#A_idle,d0
	qmove.l	#0,d1		*no 1st param
	qmove.l	#0,d2		  	*no 2nd param
	bsr.s	send_2
	qmove.l	my_pb_handle(a5),d0
	OSDisposeHandle	d0
;	dc.w	_disposehandle
	rts_	"Fant_do_idle"
*****************************************
;send_1:
;	move.l	my_pb_h(a4),a0
;	move.l	(a0),a0
;	lea	my_pb(a4),a0
;	move.l	d0,(a0)	*command
;	move.l	d1,4(A0)	*param1
;	move.l	a0,-(sp)	*request parameter block to anvil
;	move.l	callback(a5),a0
;	jsr	(A0)
;	addq.l	#4,sp			*tidy up stack (Ah)
;fault1:
;	rts_	"Send_1"

send_2:
	movem.l	d0/d1/d2,-(sp)	*Save params
	qmove.l	#256,d0		*NO alias will be bigger than this
	OSNewHandleClear	d0,a0
;	dc.w	_newhandleclear
	movem.l	(sp)+,d0/d1/d2
	move.l	a0,d7
	bne.s	mem_ok8
	debug
mem_ok8:
	movem.l	d0/d1/d2,-(sp)
	qmove.l	d7,my_pb_handle(a5)
	OSHLock	a0
;	dc.w	_hlock
	movem.l	(sp)+,d0/d1/d2
	move.l	my_pb_handle(a5),a0
	move.l	(a0),a0
	qmove.l	d0,(a0)	*command
	qmove.l	d1,4(a0)	*param1
	qmove.l	d2,8(a0)	*param2
;	move.l	a0,-(sp)	*request parameter block to anvil
;	move.l	callback(a5),a0
;	jsr	(A0)
;	addq.l	#4,sp			*tidy up stack (Ah)
	call_ccp
fault2:
	rts_	"Send_2"

check_idle:
	if	PPC
	qmove.l	#7500,time_to_idle(a5)
	else
	qmove.l	#2500,time_to_idle(a5)
	endif
	qmove.l	a0,-(sp)
**Check for ctrl+alt+apple	
	bsr.s	check_escape
	bsr	do_idle
	move.l	(sp)+,a0
no_idle:
	rts_	"check_idle"
check_escape:
**check for ctrl+alt+apple key
	bsr.l	getkey_turbo	*lib, returns keymap in a0
	move.b	7(a0),d0	*8=ctrl, 4=alt
	beq.s	no_key
	or.b	6(a0),d0	*80=apple
	cmpi.b	#0x8c,d0
	bne.s	no_key
	qmoveq	#-1,d0
	qmove.b	d0,abort(a5)
	bra.s	got_key
no_key:
	moveq	#0,d0
got_key:
	rts_	"F5_check_escape"
getkey_turbo:
	global	getkey_turbo
	lea		my_keys(pc),a1
	OSGetKeys	a1
**StuMOD - this code should in theory be more efficient than the commented out code?
	lea		my_keys(pc),a1
		qmove.l	#0,d0					; clear result
		or.l	(a1),d0
		qmove.l	4(a1),d1
		andi.w	#$fffd,d1		; get rid of caps lock bit
		or.l	d1,d0
		or.l	8(a1),d0
		or.l	12(a1),d0
		tst.l	d0
		bne.s	something_pressed
		bra			exit_pressed

something_pressed:
really_nothing_pressed:
nothing_pressed:
		qmove.l	#1,d0
		bra		exit_pressed
quit_key_pressed:	
		qmoveq.l	#-1,d0
exit_pressed:
		tst.b	d0
		lea	my_keys(pc),a0
		rts_	"check_keys"
	rts

strcmp:
        tst.b   (a1)
        beq.s    strcmp_end_test

        cmpm.b   (a1)+,(a0)+
        beq     strcmp                  ; if equal, next one

        blt.s     strcmp_end_lessthan     ; unsigned compare

        moveq.l #1,d0   ; its greater than
        rts

strcmp_end_test:
        tst.b   (a0)
        bne.s     strcmp_end_lessthan

        moveq.l #0,d0
        rts

strcmp_end_lessthan:
        moveq.l #-1,d0
        rts_	"STRINGLIB_strcmp"

**A leaf routine, use qbsr
toupper:
;	ext.w	d0
**check is upper case
	cmpi.l	#"a",d0
	blt.s	not_lower
	cmpi.l	#"z",d0
	bgt.s	not_lower
	sub.l	#$20,d0	make upper
not_lower:	qrts
	
ai_anvil_info:	dc.l	0xF2		*4 data regs in, 1 long out, C
	dc.b	0		*resvd
	dc.b	0		*ppc (68k=0)
	dc.w	0		*Routine flags 4=native + 2=needs init + 1=offset
my_keys:	ds.l	30
	global	strcmp
	global	send_to_log,send_to_error,send_2,do_idle
	global	check_idle,check_escape,toupper
