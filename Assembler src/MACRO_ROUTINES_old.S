*********************************************************************
*MODULE:	MACRO ROUTINES FOR V1.02                            *
*DATE:	230894			    *
*LAST MODIFIED:	280894			    *
*PROGRAMMER:	S.BALL			    *
*VERSION:	2			    *
*FANT REL VER:	2.00			    *
*DESCRIPTION:	VARIOUS ROUTINES USED TO IMPLEMENT MACROS	    *
*********************************************************************

**V1.02 - MACROS
**TRY_MACRO SEARCHES MACRO LABEL TABLE TO SEE IF MACRO IS DEFINED.
**IF NOT RETURNS -1, ELSE 0 IN D0
**SET FLAGS2[0] IF MACRO.
try_macro:
	qmove.l	a0,-(sp)
	lea	field_2(a5),a3
	move.l	macro_labels(a5),a4
	bsr.l	search_mac	search a4 for a3
	tst.l	d0
	bmi	not_macro	return -1
**dont touch d0!!!!!!!!!
**v5.1 - save if_depth for use by break
	lea	saved_if_depth_array(a5),a3
	clr.l	d1
	qmove.b	saved_if_depth_array_index(a5),d1
	add.l	d1,a3
	qmove.b	if_depth(a5),(a3)	*save if depth going into macro for break
	lea	saved_repeat_depth_array(a5),a3
	add.l	d1,a3
**save repeat flag
	clr.l	d2
	btst	#3,flags2(a5)
	beq.s	repeat_off
	moveq	#1,d2
repeat_off:	qmove.b	d2,(a3)	*save in repeat loop flag
**for next
	addq.l	#1,d1	*no need to error check - macro nesting does that for us
	qmove.b	d1,saved_if_depth_array_index(a5)

**v3.86 - copy macro name to macro_name(a5) for error reporting purps
	lea	field_2(a5),a3
	lea	macro_name(a5),a6
copy_mname:	move.b	(a3)+,(a6)+
	bne.s	copy_mname
**v3.75 - search for \@ and replace with m_label_count(a5)
	bsr	replace_auto_lab
**if tron then print **macro - name
	btst	#0,flags(a5)
	beq.s	no_tron_ma	ass off
	btst	#1,flags(a5)	1=pass 2
	beq.s	no_tron_ma
	btst	#1,flags6(a5)	tron
	beq.s	no_tron_ma

	save_all		*print label if tron on
	lea	from_macro(pc),a0
	bsr.l	printit
	lea	field_2(a5),a0
	bsr.l	printit
	lea	cr_text(pc),a0
	bsr.l	printit
	restore_all
no_tron_ma:	move.b	(a1),d1	check for size char
;	tst.b	d1
	bne.s	size_char_ok	we have one
	moveq.b	#"W",d1	we dont ,so use .w
size_char_ok:
**v3.75 - see fantasm macros v2 for info
	move.l	macro_counters(a5),a4	increment this counter
**LXT chage
	qpush1	a4
	qpush2	d0
	lsl.l	#1,d0
	add.l	d0,a4
	addq.w	#1,(a4)
	qpop2	d0
	qpop1	a4
;	addq.w	#1,0(a4,d0.l*2)	
	qmove.l	macro_nest_depth(a5),d2
	lea	counter_save(a5),a6	oooh, a6 at last
**LXT change
	qpush1	a6
	qpush2	d2
;	andi.l	#0xffff,d2
	lsl.l	#1,d2
	add.l	d2,a6
	qmove.w	m_label_count(a5),(a6)
	qpop2	d2
	qpop1	a6
;	move.w	m_label_count(a5),0(a6,d2.w*2)	save in counter_save
**LXT
	qpush1	d0
	qpush2	a4
	lsl.l	#1,d0
	add.l	d0,a4
	qmove.w	(a4),m_label_count(a5)	
	qpop2	a4
	qpop1	d0
;	move.w	0(a4,d0.l*2),m_label_count(a5)	counter for this macro
		
**v3.2x
	lea	m_param_0(pc),a4
	qmove.l	macro_nest_depth(a5),d2
	
	qmove.b	d1,0(a4,d2.l)	save size parameter

	bsr	get_params	get params in macro_param(a5) 140*10 bytes

**now swap source file for macro text
	
	qbset	#1,flags2(a5)	assemble from macro text!
	
	move.l	(sp)+,a0	get source file address
	lea	source_pointer_save(a5),a1
	qmove.l	source_pointer_save_index(a5),d1	debug purps
;	ext.l	d1
	add.l	d1,a1
	move.l	a0,(a1)	save currrent source address in sps list
	addq.l	#4,source_pointer_save_index(a5)
	add.l	#parameter_size*number_of_parameters,macro_depth_index(a5)
	addq.l	#1,macro_nest_depth(a5)
	qmove.l	macro_nest_depth(a5),d1
	cmpi.l	#macro_depth_limit,d1
	bgt	macro_nest_fail		**fatal error - depth too deep
	
	
	move.l	m_labels_index(a5),a1	now point to right place in macro text
**LXT
	qpush1	a1
	andi.l	#0xffff,d0
	lsl.l	#2,d0
	add.l	d0,a1
	qmove.l	(a1),d0
	qpop1	a1
;	move.l	0(a1,d0.w*4),d0	index into macro text as longs
	move.l	macro_address(a5),a0
	add.l	d0,a0	a0->macro text (i hope)
	clr.l	d0	return all ok
	rts

not_macro:	move.l	(sp)+,a0
	moveq	#-1,d0	macro not found
	rts_	"try_macr"
	align
**replace auto_lab checks field 3 for \@. if found it replaces it with m_label_count(a5)
**we copy the field 3 to field_3_new then back again.
replace_auto_lab:
	lea	field_3_new(a5),a3
	lea	field_3(a5),a2
copy_f3m:	cmpi.w	#0x5c40,(a2)	*"\@"
	beq.s	got_auto
	tst.b	(a2)
	beq.s	got_term
	qmove.b	(a2)+,(a3)+
	bra.s	copy_f3m
**insert auto label
got_auto:	move.w	m_label_count(a5),d0
	bsr.l	print_mem	*insert auto label in field_3_new
	addq.l	#2,a2		*This is an addition in 5.1!
	bra.s	copy_f3m
	
got_term:	clr.b	(a3)
	lea	field_3_new(a5),a3
	lea	field_3(a5),a2
copy_back:	tst.b	(a3)
	beq.s	ral_end
	qmove.b	(a3)+,(a2)+
	bra.s	copy_back
ral_end:	clr.b	(a2)
	rts
	
**get params gets the parameters from field 3, and stores them in macro_param(a5)
**macro_param(a5) is a two dimensional array of size 140*9
**i.e. each parameter can be 140 bytes in length, and is termed with 0
**v3.2x change:
**macro_param is now a pointer to a block of size 
**macro_depth_limit * parameter_size * number_of_parameters
get_params:	clr.l	narg_count(a5)	*number of arguments
	move.l	macro_param(a5),a3	clear params
**point to right param block
	qmove.l	macro_depth_index(a5),d2	position in param block
	add.l	d2,a3
	move.l	a3,a4	copy
;	move.l	#350,d2	*((140*10)/4)-1
	qcmove.w	#350,d2
cpl:	clr.l	(a3)+	clear
	qdbra	d2,cpl
	move.l	a4,a3	restore
	
	lea	field_3(a5),a4	point to param list

	move.l	#parameter_size,d2	each param is 140 bytes long
	qmove.l	a3,d3	save start of this param
	tst.b	(a4)
	beq.s	mp_finished	no params

move_params:	move.b	(a4)+,d1	get byte
	beq.s	mp_end

	cmpi.b	#0x2c,d1	*comma
	beq.s	mp_end
	qmove.b	d1,(a3)+
	bra.s	move_params

mp_end:	addq.l	#1,narg_count(a5)	*inc number of args
	tst.b	d1	zero is end of list
	beq.s	mp_finished
	move.l	d3,a3	reset param pointer
	add.l	d2,a3
	qmove.l	a3,d3	save new param pointer
	bra.s	move_params

mp_finished:	rts_	"get_para"

***v1.02 - macro copy to buffer
copy_macro:	lea	field_2(a5),a2
	cmpi.l	#"MACR",(a2)
	beq.s	macro_nest_error
	cmpi.l	#"macr",(a2)	*5.10a4
	beq.s	macro_nest_error

	move.l	source_save(a5),a2	*start of line
	move.l	macro_address(a5),a3	*macro text buffer
	qmove.l	m_text_pos(a5),d0	*where we are in buffer
	add.l	d0,a3		*right place in buffer
cm1:	qmove.b	(a2)+,(a3)+		*copy macro
	addq.l	#1,d0
	cmp.l	mac_buff_size(a5),d0
	bge.s	outta_mem_mac
	cmp.l	a2,a0
	bne.s	cm1


	qmove.l	d0,m_text_pos(a5)	*update pos
*	move.l	d0,m_text_size(a5)	*save total size
	clr.l	d0	*no error
	rts
outta_mem_mac:
	save_all
	lea	fatal_mac_error(pc),a0
	bsr.l	pass1_error
	restore_all
	qmove.l	#-1,d0
	rts
	
macro_nest_error:
	qmove.l	a0,-(sp)
	lea	macro_2_err(pc),a0
	bsr.l	pass1_error
	move.l	(sp)+,a0
	rts_	"cpy_macr"
	align
**finish macro 
*8first check if field 1 has a label (a2). if it does copy it.
**if we're assembling from macro, then clear flag and switch text pointers(a0)
**if we're copying a macro to buffer (flags2[1]=0) then copy endm, update buffer 
**indexes and turn off macro copy flag (flags2[0]=0)

finish_macro:	btst	#1,flags2(a5)
	bne.s	end_assm_macro		*assembling from a macro
	move.l	source_save(a5),a2	*start of line
	move.l	macro_address(a5),a3	*macro text buffer
	qmove.l	m_text_pos(a5),d0	*where we are in buffer
	add.l	d0,a3		*right place in buffer
cmf1:	qmove.b	(a2)+,(a3)+		*copy macro line
	addq.l	#1,d0
	cmp.l	a2,a0
	bne.s	cmf1
	move.l	d0,m_text_pos(a5)	*update pos
*	move.l	d0,m_text_size(a5)	*save total size

	qbclr	#0,flags2(a5)		*turn off macro copy flag
	rts_	"finish_m"
	align
	
**come here is assembling from macro on pass 1!
end_assm_macro:
**check field 1 for label
	tst.b	(a2)
	beq.s	no_lab_to_def		*no lab to define

	bsr	replace_params		*get label name
	bsr.l	copy_label		insert label and address
*print label if tron
	btst	#0,flags(a5)
	beq.s	no_tron
	btst	#1,flags6(a5)
	beq.s	no_tron

	save_all		*print label if tron on
	lea	field_1(a5),a0
	bsr.l	printit
	bsr.l	print_space
	restore_all
no_tron:
no_lab_to_def:
**v3.2x mods in accordance with fm_171194_01
	subq.l	#4,source_pointer_save_index(a5)
	lea	source_pointer_save(a5),a1
	qmove.l	source_pointer_save_index(a5),d1
;	ext.l	d1
	add.l	d1,a1
	move.l	(a1),a0	*source from next level up
	
	tst.l	source_pointer_save_index(a5)
	bne.s	not_top_level	not in source text yet
	qbclr	#1,flags2(a5)	yes, no macro paramter processing please
not_top_level:	sub.l	#parameter_size*number_of_parameters,macro_depth_index(a5)

*v3.75
**get the counter from counter_save(macro_nest-depth)
**and puts it into m_label_count
	lea	counter_save(a5),a6
	subq.l	#1,macro_nest_depth(a5)	*oops, forgot this
*v3.75
**get the counter from counter_save(macro_nest-depth)
**and puts it into m_label_count
	lea	counter_save(a5),a6
	qmove.l	macro_nest_depth(a5),d0
**LXT
	qpush1	d0
	qpush2	a6
;	andi.l	#0xffff,d0
	lsl.l	#1,d0
	add.l	d0,a6
	qmove.w	(a6),m_label_count(a5)
	qpop2	a6
	qpop1	d0
;	move.w	0(a6,d0.w*2),m_label_count(a5)	*previous counter!

**v4.04 - count number of params for narg on exit from macro to replace old narg!

	move.l	macro_param(a5),a3
	qmove.l	macro_depth_index(a5),d1
**mdi is inc to next macro, so dec it**
	sub.l	#parameter_size*number_of_parameters,d1
	add.l	d1,a3	point to right param block
	clr.l	narg_count(a5)
count_narg:
	tst.b	(a3)
	beq.s	end_narg_count
	addq.l	#1,narg_count(a5)
	add.l	#parameter_size,a3
	bra.s	count_narg
end_narg_count:

*print end of macro if tron
	btst	#0,flags(a5)
	beq.s	no_tron_endm	assm off
	btst	#1,flags(a5)	1=pass 2
	beq.s	no_tron_endm

	btst	#1,flags6(a5)
	beq.s	no_tron_endm	tron off
	
	save_all
	lea	from_source(pc),a0
	bsr.l	printit		*end of macro call
	restore_all
no_tron_endm:	rts_	"end_as_m"
	align

*****************************replace params******************************************
**replace_params replaces \1,\2 etc when assembling from macro buffer
**replaces any params with actual params.
**params are identified as \0 for size,\1-\9 and \@ for an unique label.
**we use two new fields - field_2_new and field_3_new to generate the fields, then
*8copy them back to field_2 and field_3 after translation.
replace_params2:	*called when we have a label at a macro call
;	lea	field_2(a5),a1
;	cmpi.l	#$53455400,(a1)
;	beq	done_m_set	*set
;	cmpi.l	#$73657400,(a1)
;	beq	done_m_set	*set
	bra	done_m_f1	*no macro label

replace_params:		*v1.02/modded v3.2x
**modded 050896 for set directive to work with real labels!
*first do labels in field 1
**labels can be x.\@
*we have to search for \@
**406 - field 2 = set?
	lea	field_1(a5),a1
	tst.b	(a1)
	beq	done_m_f1	*no macro label
find_f1_al:	move.b	(a1),d1
	beq.s	m_label_err_poss	*cant have a real label!
	cmpi.b	#0x5c,d1	*\
	beq	gotbs
	addq.l	#1,a1
	bra.s	find_f1_al

m_label_err_poss:
	lea	field_2(a5),a1
	qmove.l	(a1),d0
	cmpi.l	#$53455400,d0
	beq	done_m_f1	*set
	cmpi.l	#$73657400,d0
	beq	done_m_f1	*set
**asc$
	cmpi.l	#"ASC$",d0
	beq	done_m_f1
	cmpi.l	#"asc$",d0
	beq	done_m_f1
**len
	cmpi.l	#0x4c454e00,d0
	beq	done_m_f1
	cmpi.l	#0x6c656e00,d0
	beq	done_m_f1
**fndc
	cmpi.l	#"fndc",d0
	beq	done_m_f1
	cmpi.l	#"FNDC",d0
	beq	done_m_f1
**we can also use string directives in macros!
**so check field 1 for a valid string id
	lea	field_1(a5),a3
	cmpi.b	#"[",(a3)
	bne.s	not_string
	cmpi.b	#"$",2(a3)
	bne.s	not_string
	cmpi.b	#"]",3(a3)
	bne.s	not_string
	move.b	4(a3),d0
	beq.s	done_m_f1	*[x$]
	cmpi.b	#":",d0
	beq.s	done_m_f1	*[x$]:
	
not_string:	


**ok, we've found \
gotbs:	qmove.b	1(a1),d1	*get param char
	cmpi.b	#"@",d1	*auto label?
	bne.s	not_auto	*no a parameter
**auto generate a label	
	move.l	a1,a3	*print mem works with a3
	qmove.w	m_label_count(a5),d0
	bsr.l	print_mem	*insert auto label, with no colon!
	clr.b	(a3)	*terminate field
	bra.s	done_m_f1

**insert a parameter label
not_auto:
	subi.b	#"0",d1	make real number
	subq.b	#1,d1	replacements go 0-8
	bmi	m_label_err	<0
	cmpi.b	#9,d1
	bgt	m_label_err	>9
	extb.l	d1
	qmove.l	d1,d0			*400b15h
	muls	#parameter_size,d0	index into param stores
	move.l	macro_param(a5),a3
	move.l	macro_depth_index(a5),d1
**mdi is inc to next macro, so dec it**
	sub.l	#parameter_size*number_of_parameters,d1
	add.l	d1,a3	point to right param block
	add.l	d0,a3	actual parameter

;	muls	#parameter_size,d1	index into param stores
;	move.l	macro_param(a5),a3
;	add.l	d1,a3	actual parameter
cop_param1:	move.b	(a3)+,d1
	beq.s	done_labelr	end of replacement
	qmove.b	d1,(a1)+
	bra.s	cop_param1
	
done_labelr:	clr.b	(a1)+	term field
done_m_set:	*simply copy label in toto

**now do field 2 and field 3
done_m_f1:	lea	field_2_new(a5),a1
	lea	field_3_new(a5),a2
	lea	field_2(a5),a3
	lea	field_3(a5),a4
**first check size param on field_2
find_size_p:	move.b	(a3)+,d0	get byte
	cmpi.b	#0x5c,d0
	beq.s	replace_size
	move.b	d0,(a1)+	copy
;	tst.b	d0
	beq.s	done_fr_2
	bra.s	find_size_p

replace_size:
	lea	m_param_0(pc),a4
	qmove.l	macro_nest_depth(a5),d2
	subq.l	#1,d2	because mnd is pointing at next loc
**LXT change
	qpush1	a4
	add.l	d2,a4
	qmove.b	(a4),(a1)+
	qpop1	a4
;	move.b	0(a4,d2.w),(a1)+	replace size character
	clr.b	(a1)+	term field 2

**check field 3
done_fr_2:
	lea	field_3(a5),a4	
do_fr_2:	move.b	(a4)+,d0
	cmpi.b	#0x5c,d0	*parameter?
	beq.s	replace_param	*yep
	move.b	d0,(a2)+	*no, just copy
	beq.s	rp_done	yep
	bra.s	do_fr_2	no
replace_param:
	qmove.b	(a4)+,d0
*8check for auto label
	cmpi.b	#"@",d0	*auto label name?
	beq.s	rep_auto
	cmpi.b	#"0",d0
	beq.s	replace_size_field_3
	
	subi.b	#"0",d0	make real number
	subq.b	#1,d0	replacements go 0-8
	bmi	parameter_error	<0
	cmpi.b	#9,d0
	bgt	parameter_error	>9
	extb.l	d0
	muls	#parameter_size,d0	index into param stores
	move.l	macro_param(a5),a3
	qmove.l	macro_depth_index(a5),d1
**mdi is inc to next macro, so dec it**
	sub.l	#parameter_size*number_of_parameters,d1
	add.l	d1,a3	point to right param block
	add.l	d0,a3	actual parameter
;	tst.b	(a3)
;	beq	param_stop	*400b15g
cop_param:	move.b	(a3)+,d0
	beq.s	do_fr_2	end of replacement
	qmove.b	d0,(a2)+
	bra.s	cop_param
	
rep_auto:			*insert auto label into a2
	movem.l	a3/a4,-(sp)	*save field source
	move.l	a2,a3	*print mem works with a3
	qmove.w	m_label_count(a5),d0
	bsr.l	print_mem	*no colon here - just xxxxx
	move.l	a3,a2	*where line is built
	movem.l	(sp)+,a3/a4	*get field source
	bra.s	do_fr_2	*check next param
	
rp_done:	clr.b	(a2)+	term field	
reset_fields:	lea	field_2_new(a5),a1
	lea	field_2(a5),a3
copy_f2:	move.b	(a1)+,(a3)+
	bne.s	copy_f2
	lea	field_3_new(a5),a2
	lea	field_3(a5),a4
copy_f3:	move.b	(a2)+,(a4)+
	bne.s	copy_f3
	lea	field_1(a5),a2	*reset all fields
	lea	field_2(a5),a3
	lea	field_3(a5),a4
	rts_	"rep_para"

replace_size_field_3:
	qmove.l	a4,-(sp)	*save where we are
	lea	m_param_0(pc),a4
	qmove.l	macro_nest_depth(a5),d2
	subq.l	#1,d2	because mnd is pointing at next loc
**LXT
;	push	a4
	add.l	d2,a4
	qmove.b	(a4),(a2)+
;	pop	a4
;	move.b	0(a4,d2.w),(a2)+	replace size character
	move.l	(sp)+,a4	*restore where we were
	bra	do_fr_2
************	
param_stop:
	qmove.l	a0,-(sp)
	lea	macro_7_err(pc),a0
	bsr.l	pass1_error
	qbset	#4,flags2(a5)	*set fatal flag
	move.l	(sp)+,a0

	rts_	"no_param!"
	
parameter_error:	qmove.l	a0,-(sp)
	lea	macro_4_err(pc),a0
	bsr.l	pass1_error
	move.l	(sp)+,a0
	rts
m_label_err:	qmove.l	a0,-(sp)
	lea	macro_5_err(pc),a0
	bsr.l	pass1_error
	qbset	#4,flags2(a5)	*set fatal flag
	move.l	(sp)+,a0
	rts
	align
macro_nest_fail:	qmove.l	a0,-(sp)
	lea	macro_6_err(pc),a0
	bsr.l	pass1_error
	qbset	#4,flags2(a5)	*set fatal flag
	move.l	(sp)+,a0
	rts_	"m_nest_f"
	align
			
m_param_0:	DS.B	macro_depth_limit+1	*.B MACRO PARAM 0 = SIZE CHARACTER.
;source_pointer_save:	ds.b	macro_depth_limit*5	*source pointers saved here
						*in a5 for v4

macro_2_err:	DC.B	"Can not define a macro inside a macro.",13,13,0
macro_4_err:	DC.B	"Invalid parameter for Macro - must be 0-9.",13,13,0
macro_5_err:	DC.B	"**FATAL** Cant use real label names in macro",13,"Use SET if you want to modify an EQU or SET label.",13,13,0
macro_6_err:	dc.b	"**FATAL** Macro nesting too deep.",13,13,0
macro_7_err:	dc.b	"**FATAL** Nil label being defined!",13,13,0
from_macro:	dc.b	"***Macro called - ",0
from_source:	dc.b	"***End of macro call."	*note, runs into cr_text
fatal_mac_error:	cstring	"***FATAL*** Not enough memory (Macro).",13,"Please increase Anvil's partition size.",13,13,0
	align
cr_text:	dc.b	13,0
	align
	public	try_macro,get_params,copy_macro,finish_macro
	public	replace_params,replace_params2
	
	extern	pass1_error,copy_label
	extern	print_mem,search_mac,printit,print_space