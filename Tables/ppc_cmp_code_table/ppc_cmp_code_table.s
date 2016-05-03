* extract from ppc_cmp_assm_tables.s
* it goes to "dTab" resource

	global	ppc_cmp_code_table

ppc_cmp_code_table:	dc.l	$2c000000	*CMPI
	dc.l	$2c000000	*CMPWI
	dc.l	$2c200000	*CMPDI
	dc.l	$28000000	*CMPLI
	dc.l	$28000000	*CMPLWI
	dc.l	$28200000	*CMPLDI
	dc.l	$7c000000	*CMP
	dc.l	$7c000000	*cmpw
	dc.l	$7c200000	*cmpd
	dc.l	$7c000040	*cmpl
	dc.l	$7c000040	*CMPLW
	dc.l	$7c200040	*cmpld
	rts_	"PPC_cmp_code_table_Rev1"
	align
