;
; Local Label Handler Module
;
;
;
;
; RP 19/7/97 v1.00 - Learnt Fantasm points of interest to this code, brainstormed 
;					 possibilities, designed module, coded.
;
; RP 20/7/97 v1.01 - Put in version comments, added entry points from main code (all
;					 marked with "LLBLS-RP200797", debugged.
;
;
;



; TEST_FOR_LOCALS
; Front end for make_locals .... since it appears in so many places
;
; IN: a3=lobel to check
; Changed: a3
;
test_for_locals:
	movem.l	d0/a0/a1,-(sp)		; save source pointer, and that other one??
	
 	cmp.b #".",(a3)
 	bne.s	not_a_local_label
 	
 	bsr	make_local
 		
not_a_local_label:
	movem.l	(sp)+,d0/a0/a1
	rts_	"test_for_locals"


; This routine is called before an assembly to set up all the data to do with 
; local labels, strangely enough.
;
; DESTROYS: d0,d1,d2,a0,a1
init_local_label_handler:

; grab the system time ... as a good 'random' starting number
	movem.l	d1/d2/a0/a1/a2,-(sp)
;	clr.l	-(sp)
;	dc.w	TickCount
;	move.l	(sp)+,d0
	OSTickCount	d0
	movem.l	(sp)+,d1/d2/a0/a1/a2

; store the start value
	lea		pass_random(pc),a0
	move.l	d0,(a0)
	
	lea		sequential_count(pc),a0
	moveq.l	#0,d0
	move.l	d0,(a0)
	
	bsr auto_generate_a_prefix	  

	rts_	"init_local_label_handler"



; DESTROYS d0,d1,d2,a0,a1
pass2_init_local_labels:

	lea	sequential_count(pc),a0
	moveq.l	#0,d0
	move.l	d0,(a0)
	
	bsr	auto_generate_a_prefix
	rts_	"pass2_init_local_labels"



	

; MAKE_LOCAL
; Convert a label to a local label
;
; Used by: test_for_locals
;
; IN: a3=text to put local infront of.
; DESTROYS: d0,a0,a1
; OUT: a3=temporary new text
make_local:
	push	d1	*511b2
		lea	current_local_text(pc),a1
		lea	new_local_space(pc),a0
		qmove.l	#0,d1	*counter	
ml_localsec:
		qmove.b	(a1)+,d0
		move.b	d0,(a0)+
		bne		ml_localsec
		
		subq.l	#1,a0			; reverse over space
		
ml_copylab:
		qmove.b	(a3)+,d0
		addq.l	#1,d1
		move.b	d0,(a0)+
		bne		ml_copylab
	
		cmpi.l	#18,d1	*max length of locals
		ble.s	loc_len_ok
		save_all
		lea	loclen_text(pc),a0	
		bsr.l	pass1_error

		restore_all
loc_len_ok:	
		lea		new_local_space(pc),a3
		pop	d1
		rts_	"make_local"
		



; old version
;; This is called from copy_label, from pass1 when a field 1 entry is found, and
;; it is started with a ".".
;;
;; Basically it puts a piece of text in from of the macro, as defined by a local 
;; "section"ing directive.
;;
;
;; IN: a0= text to put local infront of.
;; DESTROYS: d0,d1,a0,a1,a2
;make_local:
;
;; lets find how big our prefix section is, so we can shift up the label that
;; many places
;	 lea	current_local_text(pc),a1
;	 moveq.l	#-1,d0
;	 
;ml_count_loop:
;	 addq.l	#1,d0
;	 tst.b	 (a1)+
;	 bne		 ml_count_loop
;
;; shift up the label - first by finding the end of the label, and
;; working backwards, since otherwise we may overwrite an earlier section.
;
;	 move.l	a0,a1
;	 moveq.l	#-1,d1
;ml_endfind_loop:
;	 addq.l	#1,d1
;	 tst.b	 (a1)+
;	 bne		 ml_endfind_loop
;	 
;; a1 is now the source (end of string)
;	 lea	(a1,d0.l),a2	 	 ; destination (end of string)
;
;ml_shift_loop:
;	 move.b	-(a1),d0
;	 move.b	d0,-(a2)
;	 dbf		 d1,ml_shift_loop
;	 
;; insert ours at the bottom
;	 lea		 current_local_text(pc),a1
;	 
;ml_insert_loop:
;	 move.b	(a1)+,d0
;	 beq		 dont_insert_space
;	 move.b	d0,(a0)+
;	 bra		 ml_insert_loop
;dont_insert_space:
;
;	 rts_	 "make_local"


; This will put the text following this directive before all subsequent local labels.
; If the text is missing, then we'll autogenerate a unique label for the user.
; (I allow the user to enter their own text so that they can use them as non local
; labels)

; IN: a0=field 3 text
; DESTROYS: a0,a1,d0,d1,d2
local_sectioning_directive:
	tst.b	(a0)
	beq.s		no_label_supplied

; past in the text as our label pre-pender
	lea	current_local_text(pc),a1	
lsd_copy_loop:
	move.b	(a0)+,d1
	move.b	d1,(a1)+
	bne		lsd_copy_loop
	
	bra.s		exit_lsd
	
; do our own label
no_label_supplied:
	bsr.s auto_generate_a_prefix

exit_lsd:
	rts_	"local_sectioning_directive"


;
;
;
; I N T E R N A L   R O U T I N E S
;
;
;
; The auto generated prefix is 10 digits currently....
;
; The format is:- _xxxxxxyyy
;
;   where xxxxxx is a 6 digit random base-32 number based on the system time
;				to uniquely identify a particular pass 1.
;         yyy is a 3 digit sequential base-32 number which is initialised at
;            each pass assembly start to at 0..
;

; copy the standard label into the current label, and add a number on top
auto_generate_a_prefix:
	lea std_local_text(pc),a0
	lea	current_local_text(pc),a1


str_copy_loop:
	move.b	(a0)+,d1
	move.b	d1,(a1)+
	bne		str_copy_loop
	subq.l	#1,a1		; roll back onto old zero terminator


	move.l	pass_random(pc),d0
; chuck 30 bits of it into the string
	move.l	a1,a0
	moveq.l	#6,d2			; number of digits
	bsr.s	num_to_reverse_base32_string

; now put a 15 bit sequential number
	move.l	sequential_count(pc),d0
	moveq.l	#3,d2	; number of digits
	bsr.s		num_to_reverse_base32_string

	lea		sequential_count(pc),a0
	addq.l	#1,(a0)

	rts_	"auto_generate_a_prefix"




; IN: a0=target string ptr
; 	  d0=number
;	  d2.w=number of digits
; OUT: input ptr will contain c string with number as ascii
;      a0=pointing at zero terminator
;	   d0=garbage
;	   d1=garbage
;	   d2=garbage

num_to_reverse_base32_string:

	subq.w #1,d2
	
some_digits:
	move.w	d0,d1
	andi.w	#$1f,d1
**LXT change
	if	PPC
	push	a1
	lea	base32_array(pc),a1
	add.w	d1,a1
	qmove.b	(a1),(a0)+
	pop	a1
	macs_last
	*check this rotate!
	rotrwi	r3,r3,5	*lower bits are now in upper
	extrwi	`temp_reg1,r3,5,0	*Extract upper five bits
	insrwi	r3,`temp_reg1,5,16	*insert into bits 15-10
	macs_first
	else
	move.b	base32_array(pc,d1.w),(a0)+
	ror.w	#5,d0
	endif
	dbra.w	d2,some_digits
	
	
	move.b	#0,(a0)		; zero terminate string
	rts_	"num_to_base32_string"
	align
base32_array:	dc.b	"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"
				dc.b	"G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V"

new_local_space:	ds.b	256
					align
; module level variables
std_local_text:	cstring	"_"
current_local_text:	ds.b	256
sequential_count:	dc.l	1
pass_random:	dc.l	1
loclen_text:	dc.b	"This local label is illegal - too many chars. ",13,13,0
	align
	public	test_for_locals,init_local_label_handler,local_sectioning_directive
	public	pass2_init_local_labels
	extern	pass1_error
	
	
	