* extract from ppc_float_tables.s
* it goes to "dTab" resource

	global	ppc_fsyntax_table

ppc_fsyntax_table:
	dc.b	"fmr",0,0,0,0,0
	dc.b	"fneg",0,0,0,0
	dc.b	"fabs",0,0,0,0
	dc.b	"fnabs",0,0,0
	dc.b	"frsp",0,0,0,0
	dc.b	"fctid",0,0,0	*64 bit only
	dc.b	"fctidz",0,0	*64 bit only
	dc.b	"fctiw",0,0,0
	dc.b	"fctiwz",0,0
	dc.b	"fcfid",0,0,0
	dc.b	"fadd",0,0,0,0
	dc.b	"fadds",0,0,0
	dc.b	"fsub",0,0,0,0
	dc.b	"fsubs",0,0,0
	dc.b	"fdiv",0,0,0,0
	dc.b	"fdivs",0,0,0
	dc.b	"fmul",0,0,0,0
	dc.b	"fmuls",0,0,0
	dc.b	"fmadd",0,0,0
	dc.b	"fmadds",0,0
	dc.b	"fmsub",0,0,0
	dc.b	"fmsubs",0,0
	dc.b	"fnmsub",0,0
	dc.b	"fnmsubs",0
	dc.b	"fnmadd",0,0
	dc.b	"fnmadds",0
	dc.b	"fcmpu",0,0,0
	dc.b	"fcmpo",0,0,0
	dc.b	"fsqrt",0,0,0	*510
	dc.b	"fsqrts",0,0
	dc.b	"fres",0,0,0,0
	dc.b	"frsqrte",0
	dc.l	-1,-1
