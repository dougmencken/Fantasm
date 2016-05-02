	ifne	powerf
*********************************
*PPC_TRAP_ASSM_TABLES.S
*011196 - SB
	if	68k
ppc_trap_jumptable:
	else
ppc_trap_jumptable:	toc_routine
	endif
	bsr.l	tdi_warn
	rts44
	bsr.l	tdi	*twi
	rts44
	bsr.l	td_warn
	rts44
	bsr.l	td
	rts44

**Extended
	bsr.l	twei	*TWLTI
	rts44
	bsr.l	twei	*TWLEI
	rts44
	bsr.l	twei	*TWEQI
	rts44
	bsr.l	twei	*TWgeI
	rts44
	bsr.l	twei	*TWgtI
	rts44
	bsr.l	twei	*TWnlI
	rts44
	bsr.l	twei	*TWneI
	rts44
	bsr.l	twei	*TWngI
	rts44
	bsr.l	twei	*TWLLTI
	rts44
	bsr.l	twei	*TWLLEI
	rts44
	bsr.l	twei	*TWLGEI
	rts44
	bsr.l	twei	*TWLGTI
	rts44
	bsr.l	twei	*TWLNLI
	rts44
	bsr.l	twei	*TWLNGI
	rts44
*
	bsr.l	twe	*TWLT
	rts44
	bsr.l	twe	*TWLE
	rts44
	bsr.l	twe	*TWEQ
	rts44
	bsr.l	twe	*TWge
	rts44
	bsr.l	twe	*TWgt
	rts44
	bsr.l	twe	*TWnl
	rts44
	bsr.l	twe	*TWne
	rts44
	bsr.l	twe	*TWng
	rts44
	bsr.l	twe	*TWLLT
	rts44
	bsr.l	twe	*TWLLE
	rts44
	bsr.l	twe	*TWLGE
	rts44
	bsr.l	twe	*TWLGT
	rts44
	bsr.l	twe	*TWLNL
	rts44
	bsr.l	twe	*TWLNG
	rts44

**Extended Doubles
	bsr.l	twei	*TWLTI
	rts44
	bsr.l	twei	*TWLEI
	rts44
	bsr.l	twei	*TWEQI
	rts44
	bsr.l	twei	*TWgeI
	rts44
	bsr.l	twei	*TWgtI
	rts44
	bsr.l	twei	*TWnlI
	rts44
	bsr.l	twei	*TWneI
	rts44
	bsr.l	twei	*TWngI
	rts44
	bsr.l	twei	*TWLLTI
	rts44
	bsr.l	twei	*TWLLEI
	rts44
	bsr.l	twei	*TWLGEI
	rts44
	bsr.l	twei	*TWLGTI
	rts44
	bsr.l	twei	*TWLNLI
	rts44
	bsr.l	twei	*TWLNGI
	rts44
*
	bsr.l	twe	*TWLT
	rts44
	bsr.l	twe	*TWLE
	rts44
	bsr.l	twe	*TWEQ
	rts44
	bsr.l	twe	*TWge
	rts44
	bsr.l	twe	*TWgt
	rts44
	bsr.l	twe	*TWnl
	rts44
	bsr.l	twe	*TWne
	rts44
	bsr.l	twe	*TWng
	rts44
	bsr.l	twe	*TWLLT
	rts44
	bsr.l	twe	*TWLLE
	rts44
	bsr.l	twe	*TWLGE
	rts44
	bsr.l	twe	*TWLGT
	rts44
	bsr.l	twe	*TWLNL
	rts44
	bsr.l	twe	*TWLNG
	rts44
					
tdi_warn:
	bsr.l	sixty_four_warn
	bsr.l	tdi
	rts
	
td_warn:
	bsr.l	sixty_four_warn
	bsr.l	td
	rts
		
ppc_trap_string_table:	dc.b	"tdi",0,0,0,0,0
	dc.b	"twi",0,0,0,0,0	
	dc.b	"td",0,0,0,0,0,0
	dc.b	"tw",0,0,0,0,0,0
**entended words
	dc.b	"twlti",0,0,0
	dc.b	"twlei",0,0,0	
	dc.b	"tweqi",0,0,0
	dc.b	"twgei",0,0,0
	dc.b	"twgti",0,0,0
	dc.b	"twnli",0,0,0
	dc.b	"twnei",0,0,0
	dc.b	"twngi",0,0,0
	dc.b	"twllti",0,0
	dc.b	"twllei",0,0
	dc.b	"twlgei",0,0
	dc.b	"twlgti",0,0
	dc.b	"twlnli",0,0
	dc.b	"twlngi",0,0

	dc.b	"twlt",0,0,0,0
	dc.b	"twle",0,0,0,0	
	dc.b	"tweq",0,0,0,0
	dc.b	"twge",0,0,0,0
	dc.b	"twgt",0,0,0,0
	dc.b	"twnl",0,0,0,0
	dc.b	"twne",0,0,0,0
	dc.b	"twng",0,0,0,0
	dc.b	"twllt",0,0,0
	dc.b	"twlle",0,0,0
	dc.b	"twlge",0,0,0
	dc.b	"twlgt",0,0,0
	dc.b	"twlnl",0,0,0
	dc.b	"twlng",0,0,0

**entended doubles
	dc.b	"tdlti",0,0,0
	dc.b	"tdlei",0,0,0	
	dc.b	"tdeqi",0,0,0
	dc.b	"tdgei",0,0,0
	dc.b	"tdgti",0,0,0
	dc.b	"tdnli",0,0,0
	dc.b	"tdnei",0,0,0
	dc.b	"tdngi",0,0,0
	dc.b	"tdllti",0,0
	dc.b	"tdllei",0,0
	dc.b	"tdlgei",0,0
	dc.b	"tdlgti",0,0
	dc.b	"tdlnli",0,0
	dc.b	"tdlngi",0,0

	dc.b	"tdlt",0,0,0,0
	dc.b	"tdle",0,0,0,0	
	dc.b	"tdeq",0,0,0,0
	dc.b	"tdge",0,0,0,0
	dc.b	"tdgt",0,0,0,0
	dc.b	"tdnl",0,0,0,0
	dc.b	"tdne",0,0,0,0
	dc.b	"tdng",0,0,0,0
	dc.b	"tdllt",0,0,0
	dc.b	"tdlle",0,0,0
	dc.b	"tdlge",0,0,0
	dc.b	"tdlgt",0,0,0
	dc.b	"tdlnl",0,0,0
	dc.b	"tdlng",0,0,0
	dc.l	-1,-1
	
ppc_trap_code_table:	dc.l	$08000000	*TDI
	dc.l	$0c000000	*TWI	
	dc.l	$7c000088	*TD
	dc.l	$7c000008	*TW

	dc.l	$0e000000	*TWLTI
	dc.l	$0e800000	*TWLEI	
	dc.l	$0c800000	*TWEQI
	dc.l	$0d800000	*TWGEI
	dc.l	$0d000000	*TWGTI
	dc.l	$0d800000	*TWNLI
	dc.l	$0f000000	*TWNEI
	dc.l	$0e800000	*TWNGI
	dc.l	$0c400000	*TWLLTI
	dc.l	$0cc00000	*TWLLEI
	dc.l	$0ca00000	*TWLgei
	dc.l	$0C200000	*TWLGTI
	dc.l	$0ca00000	*TWLNLI
	dc.l	$0Cc00000	*TWlngi

	dc.l	$7e000008	*TWLT
	dc.l	$7e800008	*TWLE	
	dc.l	$7c800008	*TWEQ
	dc.l	$7d800008	*TWGE
	dc.l	$7d000008	*TWGT
	dc.l	$7d800008	*TWNL
	dc.l	$7f000008	*TWNE
	dc.l	$7e800008	*TWNG
	dc.l	$7c400008	*TWLLT
	dc.l	$7cc00008	*TWLLE
	dc.l	$7ca00008	*TWLge
	dc.l	$7C200008	*TWLGT
	dc.l	$7ca00008	*TWLNL
	dc.l	$7Cc00008	*TWlng

	dc.l	$0a000000	*TdLTI
	dc.l	$0a800000	*TdLEI	
	dc.l	$08800000	*TdEQI
	dc.l	$09800000	*TdGEI
	dc.l	$09000000	*TdGTI
	dc.l	$09800000	*TdNLI
	dc.l	$0b000000	*TdNEI
	dc.l	$0a800000	*TdNGI
	dc.l	$08400000	*TdLLTI
	dc.l	$08c00000	*TdLLEI
	dc.l	$08a00000	*TdLgei
	dc.l	$08200000	*TdLGTI
	dc.l	$08a00000	*TdLNLI
	dc.l	$08c00000	*Tdlngi

	dc.l	$7e000088	*TDLT
	dc.l	$7e800088	*TDLE	
	dc.l	$7c800088	*TDEQ
	dc.l	$7d800088	*TDGE
	dc.l	$7d000088	*TDGT
	dc.l	$7d800088	*TDNL
	dc.l	$7f000088	*TdNE
	dc.l	$7e800088	*TdNG
	dc.l	$7c400088	*TdLLT
	dc.l	$7cc00088	*TdLLE
	dc.l	$7ca00088	*TdLge
	dc.l	$7C200088	*TdLGT
	dc.l	$7ca00088	*TdLNL
	dc.l	$7Cc00088	*Tdlng

	global	ppc_trap_jumptable,ppc_trap_string_table,ppc_trap_code_table
	extern	sixty_four_warn
	extern	tdi,td,twei,twe
	else
ppc_trap_jumptable:
	nop
	global	ppc_trap_jumptable	*normal fant
	endif