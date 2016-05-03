	ifne	powerf
	if	68k
ppc_cmp_jumptable:
	else
ppc_cmp_jumptable:	toc_routine
	endif
**Fixed point loads
	bsr.l	cmpip
	rts44
	bsr.l	cmpwi
	rts44
	bsr.l	cmpwi_warn
	rts44
	bsr.l	cmpip	*CMPLI
	rts44
	bsr.l	cmpwi	*CMPLWI
	rts44
	bsr.l	cmpwi_warn
	rts44			*CMPLDI	
	bsr.l	cmpp
	rts44
	bsr.l	cmpw
	rts44
	bsr.l	cmpw_warn
	rts44
	bsr.l	cmpp	*cmpl
	rts44
	bsr.l	cmpw	*cmplw
	rts44
	bsr.l	cmpw_warn	*cmpld
	rts44
	
**64 bit warning
cmpwi_warn:
	bsr.l	sixty_four_warn
	bsr.l	cmpwi
	rts_	"CMPDI_WARN"
**64 bit warning
cmpw_warn:
	bsr.l	sixty_four_warn
	bsr.l	cmpw
	rts_	"CMPDI_WARN"
	
			
ppc_cmp_string_table:	dc.b	"cmpi",0,0,0,0
	dc.b	"cmpwi",0,0,0
	dc.b	"cmpdi",0,0,0
	dc.b	"cmpli",0,0,0
	dc.b	"cmplwi",0,0
	dc.b	"cmpldi",0,0
	dc.b	"cmp",0,0,0,0,0
	dc.b	"cmpw",0,0,0,0
	dc.b	"cmpd",0,0,0,0		
	dc.b	"cmpl",0,0,0,0
	dc.b	"cmplw",0,0,0
	dc.b	"cmpld",0,0,0
	
;ppc_cmp_code_table:	dc.l	$2c000000	*CMPI
;	dc.l	$2c000000	*CMPWI
;	dc.l	$2c200000	*CMPDI
;	dc.l	$28000000	*CMPLI
;	dc.l	$28000000	*CMPLWI
;	dc.l	$28200000	*CMPLDI
;	dc.l	$7c000000	*CMP
;	dc.l	$7c000000	*cmpw
;	dc.l	$7c200000	*cmpd
;	dc.l	$7c000040	*cmpl
;	dc.l	$7c000040	*CMPLW
;	dc.l	$7c200040	*cmpld
;	rts_	"PPC_cmp_ass_table_Rev1"
;	align

	global	ppc_cmp_jumptable,ppc_cmp_string_table
;	global	ppc_cmp_code_table
	extern	cmpip,cmpwi,sixty_four_warn,cmpp,cmpw
	else
ppc_cmp_jumptable
	nop
	global	ppc_cmp_jumptable
	endif	