* extract from ppc_float_tables.s
* it goes to "dTab" resource

	global	ppc_fcode_table

ppc_fcode_table:	dc.l	$fc000090	*FMR
	dc.l	$FC000050	*FNEG
	dc.l	$FC000210	*FABS
	dc.l	$FC000110	*FNABS
	dc.l	$FC000018	*FRSP
	dc.l	$fc00065c	*FCTID
	dc.l	$fc00065e	*FCTIDZ
	dc.l	$fc00001c	*FCTIW
	dc.l	$FC00001e	*FCTIWZ
	dc.l	$FC00069e	*FCFID

	dc.l	$fc00002a	*FADD
	dc.l	$ec00002a	*FADDS
	dc.l	$FC000028	*FSUB
	dc.l	$ec000028	*FSUBS
	dc.l	$FC000024	*FDIV
	dc.l	$EC000024	*FDIVS
	dc.l	$FC000032	*FMUL
	dc.l	$ec000032	*FMULS
	dc.l	$fc00003a	*FMADD
	dc.l	$ec00003a	*FMADDS
	dc.l	$FC000038
	dc.l	$EC000038	*FMSUBS
	dc.l	$FC00003c	*FNMSUB
	dc.l	$EC00003c	*FNMSUBS
	dc.l	$FC00003e	*FnMADD
	dc.l	$EC00003e	*FNMADDS
	dc.l	$fc000000	*FCMPU
	dc.l	$FC000040	*FCMPO
	dc.l	$fc00002c	*FSQRT - unofficial
	dc.l	$ec00002c	*FSQRTS - unofficial
	dc.l	$ec000030	*FRES - unofficial
	dc.l	$fc000034	*frsqrte - unofficial
	align
