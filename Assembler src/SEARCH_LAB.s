*********************************************************************************
*FILE:	SEARCH_LAB.S				*
*MOTHER FILE:	FANTASM2XX.S				*
*DATE:	270994				*
*PROGRAMMER:	STUART BALL				*
*DESCRIPTION:	**DO NOT USE TO SEARCH EQUATES TABLE, ONLY LABELS**	*
*					*
*	A4 POINTS TO A TABLE OF LABEL NAMES, WHERE EACH LABEL STARTS    *
*	ON A 32 BYTE BOUNDRY. A3 POINTS TO THE LABEL TO BE FOUND.	*
*	BEHAVES IN TWO DIFFERENT WAYS DEPENDING ON PASS		*
*	PASS1 - SEARCHES TABLE BACKWARDS FROM CURRENT POSITION (END)	*
*	PASS2 - SEARCHES TABLE FROM PC BACKWARDS FOR 30 LABELS, OR	*
*	UNTIL START OF TABLE IS FOUND.			*
*	IF NOT FOUND, SEARCHES FROM CURRENT PC TO END OF TABLE.	*
*INPUT:	A4=TABLE				*
*	A3=LABEL				*
*					*
*OUTPUT:	D0=-1 IF NOT FOUND, ELSE POSITION		*
*********************************************************************************
***SEARCH A TABLE (A4) FOR (A3)
***RETURN D0=-1 IF NOT FOUND
*ELSE D0=POSITION
;SEARCH_LAB:
;;	 tst.b	 frag_loaded(a5)
;;	 bne	 search_lab_ppc
;**CHECK PASS
;;	 BTST	 #1,FLAGS(A5)	 1=PASS 2
;;	 BNE.S	 SEARCH_LABP2	 PASS 2 TYPE SEARCH PATTERN
;	 bra.s	 search_labp2
;**THIS IS PASS 1 SEARCH PATTERN - FROM END TO START - SPEEDS UP BY 4.8%
;	 MOVE.L	A0,-(SP)	 SAVE SOURCE
;	 MOVE.L	LT_POS(A5),D0	 LABEL TABLE POSITION*32
;	 SUB.L	 #32,D0	POINT TO PREVIOUS LABEL
;	 	 
;	 ADD.L	 D0,A4	 END OF TABLE
;	 LSR.L	 #5,D0	 DIV 32 = POSITION COUNTER
;	 ADDQ.L	#1,D0	 ACCOUNT FOR SUB AT START OF LOOP
;	 
;	 MOVEA.L A3,A0	 	 *SAVE_LABEL
;	 tst.b	 (a3)
;	 beq.s	 search_lab_end
;	 MOVEA.L A4,A1
;	 LEA -32(A1),A1		 *A1 POINTS TO NEXT ENTRY
;SER_LAB_LOOP:	 SUBQ.L #1,D0 	 	 *THIS NEEDS TO BE MOVED TO END, TO REMOVE ADD ABOVE.
;
;	 TST.B (A4) 	 	 *END OF LABELS
;	 BEQ.S SEARCH_LAB_END 	 *YES
;SER_LAB_LP1:	 MOVE.B (A3)+,D1
;	 BEQ.S FOUND_LAB		 *FOUND MATCH
;	 CMP.B (A4)+,D1  	 *COMPARE STRINGS
;	 BEQ.S SER_LAB_LP1
; 
;SER_LAB_2: 	 	 *NO MATCH
;	 MOVE.L A1,A4	 	 *NOT FOUND SO POINT TO NEXT ENTRY
;	 LEA -32(A1),A1
;	 MOVE.L A0,A3	 	 *RESET LABEL
;	 BRA.S SER_LAB_LOOP
;**HERE THE LABEL HAS TERMINATED, BUT WE NEED TO SEE IF
;**THE TABLE ENTRY HAS TERMINATED
;FOUND_LAB:
;	 TST.B (A4)
;	 BNE.S SER_LAB_2		 *NO, SO WE HAVENT FOUND IT
;	 MOVEA.L A0,A3	 	 *RESTORE LABEL
;	 MOVEA.L (sp)+,A0
;	 tst.l	 d0	 *4.11
;	 RTS 	 	 *DO CONTAINS POSITION
;
;SEARCH_LAB_END:	MOVEA.L A0,A3	 	 *RESTORE LABEL
;SLE_1:	MOVEA.L (sp)+,A0 	 *RESTORE SOURCE POSITION
;	 MOVEQ #-1,D0
;	 RTS_	 "SRCH_LAB"
;	 EVEN


***SEARCH A TABLE (A4) FOR (A3)
***RETURN D0=-1 IF NOT FOUND
*ELSE D0=POSITION
search_labp2:
	qmove.l	a0,-(sp)	*save source
	qmoveq #-1,d0 	 	 *position counter
	movea.l a3,a0		*save_label
	tst.b	(a3)
	beq.s	no_lab
	movea.l a4,a1
	lea 32(a1),a1		*a1 points to next entry
ser_lab_loopp2:	addq.l #1,d0 		*inc table position counter
	tst.b (a4) 		*end of labels
	beq.s search_lab_endp2 	*yes
ser_lab_lp1p2:	move.b (a3)+,d1
	beq.s found_labp2	*found match
	cmp.b (a4)+,d1  	*compare strings
	beq.s ser_lab_lp1p2
 
ser_lab_2p2: 		*no match
	move.l a1,a4		*not found so point to next entry
	lea 32(a1),a1
	move.l a0,a3		*reset label
	bra.s ser_lab_loopp2
**here the label has terminated, but we need to see if
**the table entry has terminated
found_labp2:
	tst.b (a4)
	bne.s ser_lab_2p2	*no, so we havent found it
	movea.l a0,a3		*restore label
no_lab:	movea.l (sp)+,a0
	tst.l	d0
	rts 		*do contains position

search_lab_endp2:	movea.l a0,a3		*restore label
	movea.l (sp)+,a0 	*restore source position
	moveq #-1,d0
	rts_	"srch_lab"
	align

***search a table (a2) for (a3)
*the table entries are all 8 bytes long
**return d0=-1 if not found
*else d0=position
inst_search:
**first copy inst to local buffer, ignoring size
	lea	inst_buff(pc),a1
	qmoveq	#".",d1
remove_size:	move.b	(a3)+,d0
	beq.s	got_sz	no .size
	cmp.b	d1,d0	is it .?
	beq.s	got_sz	yes
	qmove.b	d0,(a1)+	save byte
	bra.s	remove_size
	
got_sz:	clr.l	(a1)
	clr.l	4(a1)	terminate
	lea	inst_buff(pc),a3
	qmoveq	#-1,d0	*position counter
	movea.l	a3,a1	*save instruction
is_loop::	inc.l	d0	*inc table position counter
	tst.l	(a2)
	bmi.s	inst_nf	*end of table	
	cmpm.l	(a3)+,(a2)+
	bne.s	nm_1	no match
	cmpm.l	(a3)+,(a2)+
	bne.s	nm_2
**found - we need to point a4 to size character
*	lea	field_2+2(pc),a4	+2 because of or inst
	lea	field_2+2(a5),a4
;	addq.l	#2,a4	
find_sc:	move.b	(a4)+,d1
	beq.s	fsc_dot
	cmpi.b	#".",d1
	bne.s	find_sc
fsc_dot:	rts

nm_1:	move.l	a1,a3	restore inst
	addq.l	#4,a2	point to next in list
	bra.s	is_loop
nm_2:	move.l	a1,a3
	bra.s	is_loop
	
inst_nf:	moveq	#-1,d0
	rts_	"srch_lab",0,0



inst_search12:
	global	inst_search12
**first copy inst to local buffer, ignoring size
	lea	inst_buff(pc),a1
	qmoveq.b	#".",d1
remove_size12:	move.b	(a3)+,d0
	beq.s	got_sz12	no .size
	cmp.b	d1,d0	is it .?
	beq.s	got_sz12	yes
	qmove.b	d0,(a1)+	save byte
	bra.s	remove_size12
	
got_sz12:	clr.l	(a1)
	clr.l	4(a1)	terminate
	clr.l	8(a1)
	lea	inst_buff(pc),a3
	qmoveq	#-1,d0	*position counter
	movea.l	a3,a1	*save instruction
is_loop12:	inc.l	d0	*inc table position counter
	tst.l	(a2)
	bmi.s	inst_nf12	*end of table	
	cmpm.l	(a3)+,(a2)+
	bne.s	nm_112	no match
	cmpm.l	(a3)+,(a2)+
	bne.s	nm_212
	cmpm.l	(a3)+,(a2)+
	bne.s	nm_312

**found - we need to point a4 to size character
	lea	field_2+2(a5),a4
find_sc12:	move.b	(a4)+,d1
	beq.s	fsc_dot12
	cmpi.b	#".",d1
	bne.s	find_sc12
fsc_dot12:	rts

nm_112:	move.l	a1,a3	restore inst
	addq.l	#8,a2	point to next in list
	bra.s	is_loop12
nm_212:	move.l	a1,a3
	addq.l	#4,a2
	bra.s	is_loop12
nm_312:	move.l	a1,a3
	bra.s	is_loop12
	
inst_nf12:	moveq	#-1,d0
	rts_	"srch_lab12"
	align
inst_buff:	ds.b	200	space for instruction copy
****************************************************************************
**Need to pass d0,a3,a4,a5,returns in d0
**which translates to a1,a2,a3
;search_lab_ppc:
;	 movem.l	a0/a3,-(sp)
;	 moveq	 #0,d0	 	 *parameter to frag. 0=chroma 68k,ppc
;	 move.l	a3,a1
;	 move.l	a5,a3
;	 move.l	a4,a2
;	 lea	 proc_pointer(pc),a0
;	 move.l	edd_frag_main_addr(a5),(a0)	 *This is a pointer to entry's TV
;	 bsr.s	 univ_pointer
;	 movem.l	(sp)+,a0/a3
;	 tst.l	 d0
;	 RTS_	 "search_lab_ppc"
;
;***MODE SWITCH CODE TO PPC
;UNIV_POINTER:
;	 DC.W	 $AAFE	 	 *MIXEDMODEMAGIC TRAP
;	 DC.B	 7	 	 *VERSION OF MIXED MODE
;	 DC.B	 0	 	 *
;	 DC.L	 0	 	 *RES1
;	 DC.B	 0	 	 *RES2
;	 DC.B	 0	 	 *SELECTOR INFO
;	 DC.W	 0	 	 *NUMBER OF ROUTINES (ARRAY INDEX!)
;**PROCINFOREC
;
;**We need to pass a5 and a3
;**               a1   a3   a2   d0   returns in d0
;**	 	  r6   r5   r4   r3 
;	 dc.l	 %1011111111110110001100000110010	 *register based call - procinfo
;	 DC.B	 0	 	 *RESVD
;	 DC.B	 1	 	 *PPC (68K=0)
;	 DC.W	 4	 	 *ROUTINE FLAGS 4=NATIVE + 2=NEEDS INIT + 1=OFFSET
;
;PROC_POINTER:
;	 DS.L	 1	 	 *PROC POINTER (TO TRANSITION VECTOR ACTUALLY!)
;	 DC.L	 0	 	 *RESVD
;	 DC.L	 0	 	 *RESVD	
;
;
;
	align
	public	search_labp2,inst_search
