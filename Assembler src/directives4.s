**Directives4.s
do_macros_first:
	qmove.b	#1,macros_first(a5)
	rts_	"macros_first"
do_macros_last:
	clr.b	macros_first(a5)
	rts_	"do_macros_last"
	global	do_macros_first,do_macros_last
do_size_68k:
	btst	#0,flags7(a5)
	beq.s	skip_half_size	*if 68k then dont do it!

	qmove.b	#1,half_size(a5)
skip_half_size:
	rts_	"do_size_68k"
	global	do_size_68k
do_size_ppc:
	clr.b	half_size(a5)
	rts	
do_break:
	qmove.b	#1,break_flag(a5)
	rts
	global	do_break	
	global	do_size_ppc