* extract from ppc_float_tables.s
* it goes to "dTab" resource

	global	ppc_flsyntax_table

ppc_flsyntax_table:	dc.b	"lfs",0,0,0,0,0
	dc.b	"lfsu",0,0,0,0
	dc.b	"lfd",0,0,0,0,0
	dc.b	"lfdu",0,0,0,0
	dc.b	"lfsx",0,0,0,0
	dc.b	"lfsux",0,0,0
	dc.b	"lfdx",0,0,0,0
	dc.b	"lfdux",0,0,0
	dc.b	"stfs",0,0,0,0
	dc.b	"stfsu",0,0,0
	dc.b	"stfd",0,0,0,0
	dc.b	"stfdu",0,0,0
	dc.b	"stfsx",0,0,0
	dc.b	"stfsux",0,0
	dc.b	"stfdx",0,0,0
	dc.b	"stfdux",0,0
	dc.l	-1,-1
