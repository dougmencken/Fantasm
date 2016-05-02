*************************************************************************
*LIGHTSOFT STANDARD MACROS                                              *
*************************************************************************
**Calls mixedmode to switch from 68k to ppc. 
**When you enter your PPC routine, you should save the contents of LR as it has
**your return address.
**To return from your PPC routine load LR with the return address (as above) and execute
**a "blr" instruction, which will return you to the 68k emulator.
**You should save and restore r0,r1,r10,r31,lr,ctr in your routine
**Usage:
*	go_ppc
*	processor=ppc
*	your ppc code
*	blr
*Go_ppc does not support parameter passing. See IM PPC system s/w for info on how to
*modify the universal proc pointer (at univ_pointer\@) to handle params.
Go_PPC:	macro
	processor=68k
	bra.s	m1\@
	align	4
m1\@:
	lea	ppc_routine\@(pc),a0	*address of routine to run
	lea	my_tv\@(pc),a1
	move.l	a0,(a1)		*pointer to routine in tv
	lea	proc_pointer\@(pc),a0
	move.l	a1,(a0)		*put tv in header header
	lea	univ_pointer\@(pc),a0
	jsr	(a0)			*into ppc?
	rts
	dc.b	"Go_PPC_MACRO"
	even	
my_tv\@:	ds.l	2
	align 4

***Mode switch code to PPC
univ_pointer\@:
	dc.w	$aafe		*mixedmodemagic trap
	dc.b	7		*version of mixed mode
	dc.b	0		*selectors (not used here)
	dc.l	0		*res1
	dc.b	0		*res2
	dc.b	0		*selector info
	dc.w	0		*number of routines (array index!)
**Procinforec
	dc.l	0		*procinfo 0=no parameters, see IM PPC sys s/w
	dc.b	0		*resvd
	dc.b	1		*ppc (68k=0)
	dc.w	4		*Routine flags 4=native + 2=needs init + 1=offset

proc_pointer\@:
	ds.l	1		*proc pointer (to transition vector actually!)
	dc.l	0		*resvd
	dc.l	0		*resvd

**The PPC routine
	align	8
ppc_routine\@:
	endm

*************************************************************
**Insert a macsbug label
**call as rts_ "label_string"

rts_:	MACRO
	rts
	ifne	use_labels	*if use labels is 1 then use labels
	  dc.b	  $80+end\@-start\@
start\@:  dc.b	\1
end\@:	
	even
	dc.w	0
	endif
	endm
	
*************************************************************
**INC ADDS 1 TO A SELECTED REGISTER.
**TAKES SIZE AND REGISTER FROM PARAMETERS
INC:	MACRO
	IFC	"","\1"
	FAIL
	ENDC
	ADDq.\0	#1,\1
	ENDM
	
*************************************************************
**DEC SUBS 1 FROM A SELECTED REGISTER
**TAKES SIZE AND REGISTER FROM PARAMETERS
DEC:	MACRO
	IFC	"","\1"
	FAIL
	ENDC
	SUBQ.\0	#1,\1
	ENDM
	
*************************************************************
**SAVE_ALL SAVES D0-D7/A0-A6 ON STACK
SAVE_ALL:	MACRO
	MOVEM.L	D0-D7/A0-A6,-(SP)
	ENDM

*************************************************************
**RESTORE_ALL GETS D0-D7/A0-A6 OFF STACK
RESTORE_ALL:	MACRO
	MOVEM.L	(SP)+,D0-D7/A0-A6
	ENDM
	
*************************************************************
push_a0:	macro
	move.l	a0,-(sp)
	endm
*************************************************************
pop_a0:	macro
	move.l	(sp)+,a0
	endm
*************************************************************
reset_locals:	macro
	globreset
	endm
	
local:	macro
	ifne	narg-2
	fail	"Number of parameters wrong"
	endif
\1	globoff.\0	\2
	endm
****