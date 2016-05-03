***Fant_trees.s
***SB 97
tree_node:
	rsreset
tree_string_offset:	rs.l	1
tree_next_left:	rs.l	1
tree_next_right:	rs.l	1
node_size:	equ	12
*node size is 12 bytes - see equs for def.
**Needs a2->tree
**needs word_buff(a5)=string to search for
lab_tree_insert:
	qmove.l	a0,-(sp)
	qmove.l	a2,d7			*save top of the tree
search_tree:
;	lea	word_buff(a5),a0
	move.l	a3,a0			*the thing we're looking
**get the string
	move.l	a2,a6			*save node pointer
	qmove.l	(a2),d0			*pointer to the string
**A0->string we wish to insert
**a2->string we are testing - is the node empty?
	cmpi.l	#-1,d0
	beq.s	got_empty_node		*yes - it.s not found, so insert away, Jimmy!
**now we have:
**a0->the word
**a2->the string offset for this node
	move.l	tree_strings_ptr(a5),a1
	add.l	d0,a1			*correct place in strings

	qbsr	strcmp1			*Compare em. d0=0=match,d0=-1=word is less than, +1=word is greater than
					*Leaves a2 alone
	beq.s	match!		
	bgt.s	go_right

**This is go left as string we are comparing is less than node contents
	qmove.l	tree_next_left(a2),d0	*offset to left node
;	move.l	tree_h(a5),a1
	move.l	d7,a2			*tree top
	add.l	d0,a2
	bra	search_tree		*walk the walk...

go_right:
	qmove.l	tree_next_right(a2),d0	*offset to right node
;	move.l	tree_h(a5),a1
	move.l	d7,a2			*tree top
	add.l	d0,a2			*could kill for trinary op here!
	bra	search_tree		*check next node

got_empty_node:
**Copy string to string_list
**insert string offset and next left/right
**first copy current string index into node - i.e. the node string pointer
	qmove.l lt_pos(a5),d0
	qmove.l	d0,(a6)			*like that
**now also set it defined
;	st	tree_id_deffed(a3)	*like that
**inc number of nodes used
	addq.l	#1,actual_number_of_labels(a5)
	qmove.l	max_number_of_labels(a5),d1
	cmp.l	actual_number_of_labels(a5),d1
	bne.s	tree_size_ok
	qmove.l	#5050,d0	alert
	bsr.l	do_alert
	OSExitToShell
;	DC.W	EXITTOSHELL	EMERGENCY EXIT
;	 pea	tree_max_entries(pc)	 
;	 dc.w	 _debugstr
tree_size_ok:
**now copy identifier to strings
;	lea	word_buff(a5),a0
	move.l	a3,a0
	move.l	tree_strings_ptr(a5),a1
	add.l	lt_pos(a5),a1			*correct place in labels strings
css:	
;	addq.l	#1,d0			*update string counter
	move.b	(a0)+,(a1)+
	bne.s	css
	
;**now check strings size against counter (we have a 2048 byte buffer for slackness)
;	 cmp.l	 tree_strings_current_size(a5),d0
;	 ble.s	 strings_size_ok
;**make the strings table bigger
;	 add.l	 #20*1024,d0
;	 move.l	d0,tree_strings_current_size(a5)
;	 sub.l	 #2048,tree_strings_current_size(a5)	*some slop for later use
;	 pea	tree_string_grow(pc)
;	 dc.w	 _debugstr
;	 move.l	tree_strings_h(a5),a0
;	 dc.w	 _sethandlesize
;	 tst.w	 d0
;	 beq.s	 grow_ok
;	 move.w	#1,mem_error(a5)
;grow_ok:
;strings_size_ok:
**now we have to set left/right pointers from this node - crucial bit of theory...

	qmove.l	last_tree_address_used(a5),d0
	add.l	#node_size,d0			*each node is 16 bytes in size
	qmove.l	d0,tree_next_left(a6)
	add.l	#node_size,d0
	qmove.l	d0,tree_next_right(a6)		*a6 is copy of node pointer
	qmove.l	d0,last_tree_address_used(a5)
	qmove.l	(sp)+,a0
	clr.l	d0
	rts_	"Btree_insert"

match!:
;	lea	macro_deffed(pc),a0
;	bsr	printit
	qmove.l	(sp)+,a0
	moveq	#-1,d0
	rts_	"BT_Insert_Match"
;tree_max_entries:	pstring	"Fantasm fatal memory error (Tree). Exit and increase Anvil's memory paritition."
;	align
**************************************************
*search the tree for the identifier in a0
*node size is 18 bytes - see equs for def.
*uses a0-a3,d0,d1,d7
*returns d0=-1 if not found else string index 
lab_tree_search:
;	move.l	tree_h(a5),a2
;	move.l	(a2),a2			*First entry is the string
	qmove.l	a0,-(sp)
	qmove.l	a2,d7			*save top of the tree
search_tree1:
;	lea	word_buff(a5),a0
	move.l	a3,a0			*the thing we're looking for
**get the string
;	move.l	a2,a6			*save node pointer
	qmove.l	(a2),d0			*pointer to the string
	cmpi.l	#-1,d0
**A0->string we wish to insert
**a2->string we are testing - is the node empty?
	beq.s	got_empty_node1		*yes - it.s not found
**now we have:
**a0->the word
**a2->the string offset for this node
	move.l	tree_strings_ptr(a5),a1
;	move.l	(a1),a1
	add.l	d0,a1			*correct place in strings

	qbsr	strcmp1			*Compare em. d0=0=match,d0=-1=word is less than, +1=word is greater than
					*Leaves a2 alone
	beq.s	match1		
	bgt.s	go_right1

**This is go left as string we are comparing is less than node contents
	qmove.l	tree_next_left(a2),d0	*offset to left node
;	move.l	tree_h(a5),a1
	move.l	d7,a2			*tree top
	add.l	d0,a2
	bra.s	search_tree1		*walk the walk...

go_right1:
	qmove.l	tree_next_right(a2),d0	*offset to right node
;	move.l	tree_h(a5),a1
	move.l	d7,a2			*tree top
	add.l	d0,a2			*could kill for trinary op here!
	bra.s	search_tree1		*check next node

got_empty_node1:			**Not found
	qmove.l	(sp)+,a0
	moveq	#-1,d0		
	rts_	"BT_Search"

match1:
**A2 is at the node
	qmove.l	(sp)+,a0
	qmove.l	(a2),d0			*pointer to the string (times 32 as each string is 32 bytes)
	lsr.l	#5,d0
	rts_	"BT_Search_Match"


**************************************************************************

*node size is 12 bytes - see equs for def.
**Needs a2->tree
**A3=string to look for
equ_tree_insert:
	qmove.l	a0,-(sp)
	qmove.l	a2,d7			*save top of the tree
search_tree4:
;	lea	word_buff(a5),a0
	move.l	a3,a0			*the thing we're looking
**get the string
	move.l	a2,a6			*save node pointer
	qmove.l	(a2),d0			*pointer to the string
**A0->string we wish to insert
**a2->string we are testing - is the node empty?
	cmpi.l	#-1,d0
	beq.s	got_empty_node4		*yes - it.s not found, so insert away, Jimmy!
**now we have:
**a0->the word
**a2->the string offset for this node
	move.l	tree_strings_ptr(a5),a1
	add.l	d0,a1			*correct place in strings
	move.l	a1,return_string_ptr(a5)
	qbsr	strcmp1			*Compare em. d0=0=match,d0=-1=word is less than, +1=word is greater than
					*Leaves a2 alone
	beq.s	match!4		
	bgt.s	go_right4

**This is go left as string we are comparing is less than node contents
	qmove.l	tree_next_left(a2),d0	*offset to left node
;	move.l	tree_h(a5),a1
	qmove.l	d7,a2			*tree top
	add.l	d0,a2
	bra	search_tree4		*walk the walk...

go_right4:
	qmove.l	tree_next_right(a2),d0	*offset to right node
;	move.l	tree_h(a5),a1
	qmove.l	d7,a2			*tree top
	add.l	d0,a2			*could kill for trinary op here!
	bra	search_tree4		*check next node

got_empty_node4:
**Copy string to string_list
**insert string offset and next left/right
**first copy current string index into node - i.e. the node string pointer
	qmove.l eq_pos(a5),d0	 *For equates
	qmove.l	d0,(a6)			*like that
**now also set it defined
;	st	tree_id_deffed(a3)	*like that
**inc number of nodes used
	addq.l	#1,actual_number_of_equates(a5)
	qmove.l	max_number_of_equates(a5),d1
	cmp.l	actual_number_of_equates(a5),d1
	bne.s	tree_size_ok4
	qmove.l	#5050,d0	alert
	bsr.l	do_alert
	OSExitToShell
;	DC.W	EXITTOSHELL	EMERGENCY EXIT

;	pea	tree_max_entries(pc)	
;	dc.w	_debugstr
tree_size_ok4:
**now copy identifier to strings
;	lea	word_buff(a5),a0
	move.l	a3,a0
	move.l	tree_strings_ptr(a5),a1
	add.l	eq_pos(a5),a1			*correct place in equs strings
css4:	
;	addq.l	#1,d0			*update string counter
	move.b	(a0)+,(a1)+
	bne.s	css4
**now we have to set left/right pointers from this node - crucial bit of theory...

	qmove.l	equ_last_tree_address_used(a5),d0
	add.l	#node_size,d0			*each node is 16 bytes in size
	qmove.l	d0,tree_next_left(a6)
	add.l	#node_size,d0
	qmove.l	d0,tree_next_right(a6)		*a6 is copy of node pointer
	qmove.l	d0,equ_last_tree_address_used(a5)
	qmove.l	(sp)+,a0
	clr.l	d0
	rts_	"EQU_Btree_insert"

match!4:
**we need to check if it's undefined and if so, redefine it (SB BUG fix 160997)
	qmove.l	return_string_ptr(a5),a0
	cmpi.b	#0xe5,31(a0)
	bne.s	equ_!undefined
	clr.b	31(a0)
	qmove.l	(sp)+,a0
	clr.l	d0
	rts
	
equ_!undefined:
;	lea	macro_deffed(pc),a0
;	bsr	printit
	qmove.l	(sp)+,a0
	moveq	#-1,d0
	rts_	"EQU_BT_Insert_Match"

**************************************************
*search the tree for the identifier in a0
*node size is 18 bytes - see equs for def.
*uses a0-a3,d0,d1,d7
*returns d0=-1 if not found else string index 
equ_tree_search:
;	move.l	tree_h(a5),a2
;	move.l	(a2),a2			*First entry is the string
	qmove.l	a0,-(sp)
	qmove.l	a2,d7			*save top of the tree
search_tree2:
;	lea	word_buff(a5),a0
	move.l	a3,a0			*the thing we're looking for
**get the string
;	move.l	a2,a6			*save node pointer
	qmove.l	(a2),d0			*pointer to the string
	cmpi.l	#-1,d0
**A0->string we wish to insert
**a2->string we are testing - is the node empty?
	beq.s	got_empty_node2		*yes - it.s not found
**now we have:
**a0->the word
**a2->the string offset for this node
	move.l	tree_strings_ptr(a5),a1
;	move.l	(a1),a1
	add.l	d0,a1			*correct place in strings
	qmove.l	a1,return_string_ptr(a5)
	qbsr	strcmp1			*Compare em. d0=0=match,d0=-1=word is less than, +1=word is greater than
					*Leaves a2 alone
	beq.s	match2		
	bgt.s	go_right2

**This is go left as string we are comparing is less than node contents
	qmove.l	tree_next_left(a2),d0	*offset to left node
;	move.l	tree_h(a5),a1
	qmove.l	d7,a2			*tree top
	add.l	d0,a2
	bra	search_tree2		*walk the walk...

go_right2:
	qmove.l	tree_next_right(a2),d0	*offset to right node
;	move.l	tree_h(a5),a1
	move.l	d7,a2			*tree top
	add.l	d0,a2			*could kill for trinary op here!
	bra	search_tree2		*check next node

got_empty_node2:			**Not found
	qmove.l	(sp)+,a0
	moveq	#-1,d0		
	rts_	"EQU_BT_Search"

match2:
**A2 is at the node
	qmove.l	(sp)+,a0
	qmove.l	(a2),d0			*pointer to the string (times 32 as each string is 32 bytes)
	lsr.l	#5,d0
**finally, check if it's undefined!!!!! (SB bug fix 160997)
	qmove.l	return_string_ptr(a5),a1
	cmpi.b	#0xe5,31(a1)	*has it been undefined?
	bne.s	equ_match
**here it has been undefined
	moveq	#-1,d0
equ_match:
	rts_	"BT_EQUSearch_Match"


**************************************************************************

*node size is 12 bytes - see equs for def.
**Needs a2->tree
**A3=string to look for
tn_tree_insert:
	qmove.l	a0,-(sp)
	qmove.l	a2,d7			*save top of the tree
search_tree5:
;	lea	word_buff(a5),a0
	move.l	a3,a0			*the thing we're looking
**get the string
	move.l	a2,a6			*save node pointer
	qmove.l	(a2),d0			*pointer to the string
**A0->string we wish to insert
**a2->string we are testing - is the node empty?
	cmpi.l	#-1,d0
	beq.s	got_empty_node5		*yes - it.s not found, so insert away, Jimmy!
**now we have:
**a0->the word
**a2->the string offset for this node
	move.l	tree_strings_ptr(a5),a1
	add.l	d0,a1			*correct place in strings

	qbsr	strcmp1			*Compare em. d0=0=match,d0=-1=word is less than, +1=word is greater than
					*Leaves a2 alone
	beq.s	match!5		
	bgt.s	go_right5

**This is go left as string we are comparing is less than node contents
	qmove.l	tree_next_left(a2),d0	*offset to left node
;	move.l	tree_h(a5),a1
	move.l	d7,a2			*tree top
	add.l	d0,a2
	bra.s	search_tree5		*walk the walk...

go_right5:
	qmove.l	tree_next_right(a2),d0	*offset to right node
;	move.l	tree_h(a5),a1
	move.l	d7,a2			*tree top
	add.l	d0,a2			*could kill for trinary op here!
	bra.s	search_tree5		*check next node

got_empty_node5:
**Copy string to string_list
**insert string offset and next left/right
**first copy current string index into node - i.e. the node string pointer
	qmove.l toc_names_pos(a5),d0	*For equates
	qmove.l	d0,(a6)			*like that
**now also set it defined
;	st	tree_id_deffed(a3)	*like that
**inc number of nodes used
	addq.l	#1,actual_number_of_tocnames(a5)
	qmove.l	max_number_of_tocnames(a5),d1
	cmp.l	actual_number_of_tocnames(a5),d1
	bne.s	tree_size_ok5
	qmove.l	#5050,d0	alert
	bsr.l	do_alert
	OSExitToShell
;	DC.W	EXITTOSHELL	EMERGENCY EXIT

;	pea	tree_max_entries(pc)	
;	dc.w	_debugstr
tree_size_ok5:
**now copy identifier to strings
;	lea	word_buff(a5),a0
	move.l	a3,a0
	qmove.l	tree_strings_ptr(a5),a1
	add.l	toc_names_pos(a5),a1			*correct place in equs strings
css5:	
;	addq.l	#1,d0			*update string counter
	move.b	(a0)+,(a1)+
	bne.s	css5
**now we have to set left/right pointers from this node - crucial bit of theory...

	qmove.l	tocnames_last_tree_address_used(a5),d0
	add.l	#node_size,d0			*each node is 16 bytes in size
	qmove.l	d0,tree_next_left(a6)
	add.l	#node_size,d0
	qmove.l	d0,tree_next_right(a6)		*a6 is copy of node pointer
	qmove.l	d0,tocnames_last_tree_address_used(a5)
	qmove.l	(sp)+,a0
	clr.l	d0
	rts_	"tn_Btree_insert"

match!5:
;	lea	macro_deffed(pc),a0
;	bsr	printit
	qmove.l	(sp)+,a0
	moveq	#-1,d0
	rts_	"TN_BT_Insert_Match"

**************************************************
*search the tree for the identifier in a0
*node size is 18 bytes - see equs for def.
*uses a0-a3,d0,d1,d7
*returns d0=-1 if not found else string index 
tn_tree_search:
;	move.l	tree_h(a5),a2
;	move.l	(a2),a2			*First entry is the string
	qmove.l	a0,-(sp)
	qmove.l	a2,d7			*save top of the tree
search_tree6:
;	lea	word_buff(a5),a0
	move.l	a3,a0			*the thing we're looking for
**get the string
;	move.l	a2,a6			*save node pointer
	qmove.l	(a2),d0			*pointer to the string
	cmpi.l	#-1,d0
**A0->string we wish to insert
**a2->string we are testing - is the node empty?
	beq.s	got_empty_node6		*yes - it.s not found
**now we have:
**a0->the word
**a2->the string offset for this node
	move.l	tree_strings_ptr(a5),a1
;	move.l	(a1),a1
	add.l	d0,a1			*correct place in strings

	qbsr.s	strcmp1			*Compare em. d0=0=match,d0=-1=word is less than, +1=word is greater than
					*Leaves a2 alone
	beq.s	match6		
	bgt.s	go_right6

**This is go left as string we are comparing is less than node contents
	qmove.l	tree_next_left(a2),d0	*offset to left node
	move.l	d7,a2			*tree top
	add.l	d0,a2
;	add.l	tree_next_left(a2),a2
	bra.s	search_tree6		*walk the walk...

go_right6:

	qmove.l	tree_next_right(a2),d0	*offset to right node
	move.l	d7,a2			*tree top
	add.l	d0,a2			*could kill for trinary op here!
	bra.s	search_tree6		*check next node

got_empty_node6:			**Not found
	qmove.l	(sp)+,a0
	moveq	#-1,d0		
	rts_	"tn_BT_Search"

match6:
**A2 is at the node
	qmove.l	(sp)+,a0
	qmove.l	(a2),d0			*pointer to the string (times 32 as each string is 32 bytes)
	lsr.l	#5,d0
	rts_	"BT_Search_Match"
	
***********
**a0 against a1
**quick branch to this one
strcmp1:
        tst.b   (a1)
        beq.s    strcmp_end_test
        cmpm.b   (a1)+,(a0)+
        beq     strcmp1                 ; if equal, next one
        blt.s     strcmp_end_lessthan   ; unsigned compare
        moveq.l #1,d0   		; its greater than
        bra	end_strcmp
strcmp_end_test:
        tst.b   (a0)
        bne.s     strcmp_end_lessthan
        moveq.l #0,d0			;equal
        bra	end_strcmp
strcmp_end_lessthan:
        moveq.l #-1,d0
end_strcmp:
        qrts

macro_deffed:	cstring	"Macro already defined!",13
	align
	global	lab_tree_insert,lab_tree_search,strcmp1
	global	equ_tree_insert,equ_tree_search
	global	tn_tree_insert,tn_tree_search
	extern	do_alert