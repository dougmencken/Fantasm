	include	client_commands.def
clearlog:
	qmove.l	#A_clear_log,d0 
	qmove.l	#0,d1
	qmove.l	#0,d2
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0

	rts_	"f5pl_clearlog"
**gotoxy x,y
	reset_locals
	local.w	save_x,1
	local.w	save_y,1
goto_xy:
	sub_entry	a4
**get x and y
	lea	field_3(a5),a1
	bsr.l	get_numb
	tst.w	d1
	beq.s	got_x
	lea	syntax_error(pc),a0
	bsr.l	pass1_error
	bra.s	goto_xy_end
got_x:
	qmove.w	d0,save_x(a4)

	bsr.l	get_numb
	tst.w	d1
	beq.s	got_y
	lea	syntax_error(pc),a0
	bsr.l	pass1_error
	bra.s	goto_xy_end
got_y:
	move.w	d0,save_y(a4)
	
	qmove.l	#A_gotoxy_log,d0
	qmove.w	save_x(a4),d1
	qmove.w	save_y(a4),d2
	push	a4
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0

	pop	a4
goto_xy_end:
	sub_exit	a4
	rts_	"f5pl_gotoxy"

	reset_locals
	local.b	crap_string,1024	
send_print:
	sub_entry	a4
	lea	field_3(a5),a1
	cmpi.b	#0x22,(a1)
	beq.s	got_start_quotes
	lea	q1_error(pc),a0
	bsr.l	pass1_error
	bra.s	sp_end
got_start_quotes:
**find end of string
	move.l	a1,a2
find_end:
	tst.b	(a2)+
	bne.s	find_end
	subq.l	#2,a2
	cmpi.b	#0x22,(a2)
	beq.s	got_end_quotes
	lea	q2_error(pc),a0
	bsr.l	pass1_error
	bra.s	sp_end
got_end_quotes:
*copy from a1+1 to a2 to temp_string(a4)
	lea	crap_string(a4),a0
	addq.l	#1,a1
copy:
	cmp.l	a2,a1
	bge.s	got_string
	qmove.b	(a1)+,(a0)+
	bra.s	copy
got_string:
	clr.b	(a0)
	qmove.l	#A_print_in_log,d0
	lea	crap_string(a4),a0
	qmove.l	a0,d1
	qmove.l	#0,d2
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0
sp_end:
	sub_exit	a4
	rts_	"f5pl_send_print"
	
print_to_log:
	global	print_to_log
	section
	reset_locals
	local.b	crap_string1,1024
	sub_entry	a4
	lea	field_3(a5),a1
	cmpi.b	#0x22,(a1)
	beq.s	.got_start_quotes
	lea	q1_error(pc),a0
	bsr.l	pass1_error
	bra.s	.sp_end
.got_start_quotes:
**find end of string
	move.l	a1,a2
.find_end:
	tst.b	(a2)+
	bne.s	.find_end
	subq.l	#2,a2
	cmpi.b	#0x22,(a2)
	beq.s	.got_end_quotes
	lea	q2_error(pc),a0
	bsr.l	pass1_error
	bra.s	.sp_end
.got_end_quotes:
*copy from a1+1 to a2 to temp_string(a4)
	lea	crap_string1(a4),a0
	addq.l	#1,a1
.copy:
	cmp.l	a2,a1
	bge.s	.got_string
	qmove.b	(a1)+,(a0)+
	bra.s	.copy
.got_string:
	qmove.b	#13,(a0)+
	clr.b	(a0)
	qmove.l	#A_string_in_log,d0
	lea	crap_string1(a4),a0
	qmove.l	a0,d1
	qmove.l	#0,d2
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0
.sp_end:
	sub_exit	a4
	rts_	"f5pl_print_to_log"

pause:
	bsr.l	getkey_turbo
	tst.w	d0
	beq.s	pause

;	CLR.L	-(SP)
;	DC.W	TICKCOUNT
;	MOVE.L	(SP)+,d7	debounce
	OSTickCount	d7
	add.l	#4,d7
debounce:
;	CLR.L	-(SP)
;	DC.W	TICKCOUNT
;	MOVE.L	(SP)+,d6	START TIMER
	OSTickCount	d6
	cmp.l	d6,d7
	bge.s	debounce
**Call flushevents for keys
	qmove.l	#0,d1
	qmove.l	#0x38,d0
;	move.l	#0x000038,d0	*event mask low (keys), stop mask high
	OSFlushEvents	d0,d1
;	dc.w	_flushevents

	rts_	"f5pl_pause"
beep:
	qmove.l	#A_play_sound,d0
	qmove.l	beep_handle(a5),d1
	qmove.l	#0,d2
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0
;	dc.w	_DisposeHandle

	rts_	"f5pl_beep"

set_finder_size:
	global	set_finder_size

**Syntax:	fndrsize size_in_bytes
	lea	field_3(a5),a1
	bsr.l	get_numb
	tst.w	d1
	beq.s	got_size
	lea	syntax_error(pc),a0
	bsr.l	pass1_error
	bra.s	set_fndrsize_end
got_size:	*in d0
	qmove.l	d0,d1
	qmove.l	#A_set_finder_size,d0
	qmove.l	#0,d2
	bsr.l	send_2
	move.l	my_pb_handle(a5),a0
	OSDisposeHandle	a0

set_fndrsize_end:
	rts_	"f5pl_set_fndrsize"
	

q1_error:	cstring	"Double quotes expected at start of string.",13
	align
q2_error:	cstring	"Double quotes expected at end of string.",13
	align	
syntax_error:	cstring	"Syntax error - operand missing."
	align	
	global	clearlog,goto_xy,send_print,pause,beep

	extern	send_2,get_numb,pass1_error,send_to_log,getkey_turbo
	extern	printnum_no_lead_mem,set