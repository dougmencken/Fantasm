* extract from ppc_float_tables.s
* it goes to "dTab" resource

	global	ppc_flcode_table

ppc_flcode_table:	dc.l	$c0000000	*lfs
	dc.l	$c4000000	*lfsu
	dc.l	$c8000000	*lfd
	dc.l	$CC000000	*LFDU

	dc.l	$7c00042e	*lfsx
	dc.l	$7c00046e	*LFSUX
	dc.l	$7c0004ae	*LFDX
	dc.l	$7c0004ee	*lfdux

	dc.l	$d0000000	*STFS
	dc.l	$d4000000	*STFSU
	dc.l	$d8000000	*STFD
	dc.l	$dc000000	*STFDU

	dc.l	$7c00052e	*STFSX
	dc.l	$7c00056e	*STFSUX
	dc.l	$7c0005ae	*STFDX
	dc.l	$7c0005ee	*STFDUX
