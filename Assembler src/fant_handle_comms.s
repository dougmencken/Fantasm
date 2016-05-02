*************FAnt_handle_Comms
handle_comms:
	rts

************

send_and_wait:
	rts
	
;	 tst.w	 integrated(a5)
;	 beq.s	 no_comms
;	 move.w	#25000,transmitter_counter(a5)	*v4.15 increases time out
;send_and_wait1:
;	 subq.w	#1,transmitter_counter(a5)
;	 beq.s	 edd_timed_out	 	 *eddie is not receiving
;	 bsr.l	 events
;	 move.l	comms_buffer_Addr(A5),a0	 *Check for any messages to Eddie
;	 cmpi.b	#2,2(a0)	 	 *message still there?
;	 beq.s	 send_and_wait1	
;	 bra.s	 no_comms
;edd_timed_out:
;	 lea	edd_fail(pc),a0
;	 bsr.l	 printit
;	 clr.w	 integrated(a5)		 *not integrated any more!
;	 move.l	comms_buffer_Addr(a5),a1	 *set up string
;	 clr.l	 (a1)
;	 clr.w	 build_remote(a5)
;	 clr.w	 ass_remote(a5)	*loop protection! - 4.15
;	 moveq	 #-1,d0
;	 rts
;no_comms:
;	 clr.l	 d0
;	 rts_	 "Send_and_wait"

integrated_text:	dc.b	13,"Eddie is ready.",13,0
	even
ed_quit_text:	dc.b	13,"***Eddie has quit!***",13,"Fantasm will not be able to re-integrate.",13
	dc.b	"***Ready***",13,13,0
	even
ed_quit1_text:	dc.b	"Quit command received from Eddie.",13,0
edd_fail:	dc.b	"***Possible fatal error - Eddie appears to have terminated! Please Quit and restart Eddie***.",13,0
	even
	global	handle_comms,send_and_wait
	extern	printit,events,do_kbd