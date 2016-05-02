**********************************
*PPC instruction tables
*First the extended instructions:
**Each entry is 8 bytes for 68k and 64 bytes for PPC
	ifne	powerf
	if	68K
ppc_ass_table:
	else
ppc_ass_table:	toc_routine
	endif
	bsr.l	blr
	rts44

	
	bsr.l	bc	*bne
	rts44
	
	bsr.l	bc	*beq
	rts44
	
	bsr.l	bc	*bdnz
	rts44
	
	bsr.l	bc	*bgt
	rts44
	
	bsr.l	bc	*blt
	rts44
	
	bsr.l	bc	*ble
	rts44
	
	bsr.l	bc	*bge
	rts44
	
	bsr.l	bc	*bnl
	rts44
	bsr.l	bc	*bng
	rts44
	bsr.l	bc	*bso
	rts44
	bsr.l	bc	*bns
	rts44
	bsr.l	bc	*bun
	rts44
	bsr.l	bc	*bnu
	rts44
	bsr.l	branch_l
	rts44
	bsr.l	cr_logical	*crand
	rts44
	bsr.l	cr_logical	*cror
	rts44
	bsr.l	cr_logical	*crxor
	rts44
	bsr.l	cr_logical	*crnand
	rts44
	bsr.l	cr_logical	*crnor
	rts44
	bsr.l	cr_logical	*creqv
	rts44
	bsr.l	cr_logical	*crandc
	rts44
	bsr.l	cr_logical	*crorc
	rts44
	bsr.l	mcrf		*mcrf
	rts44	
**Extended cond reg
	bsr.l	crmove
	rts44
	bsr.l	crclr
	rts44
	bsr.l	crmove	*actually crnot, just op code is diff.
	rts44
	bsr.l	crclr	*crset with diff opcode (creqv).
	rts44
	bsr.l	b_logical	*bf
	rts44	
	bsr.l	b_logical	*bt
	rts44
	bsr.l	b_logical	*bdnzf
	rts44
	bsr.l	b_logical	*bdnzt
	rts44
	bsr.l	bc			*bdz
	rts44
	bsr.l	b_logical	*bdzf
	rts44
	bsr.l	b_logical	*bdzt
	rts44
					
	bsr.l	sc
	rts44
**Non-extended insts
	bsr.l	bc	*eg bc	16,0,target (bdnz target)
	rts44
			
**NOw the insturction string padded to 8 byts with zeros
**Strings must be upper case
ppc_string_table:	dc.b	"blr",0,0,0,0,0
	dc.b	"bne",0,0,0,0,0
	dc.b	"beq",0,0,0,0,0
	dc.b	"bdnz",0,0,0,0
	dc.b	"bgt",0,0,0,0,0
	dc.b	"blt",0,0,0,0,0
	dc.b	"ble",0,0,0,0,0
	dc.b	"bge",0,0,0,0,0		
	dc.b	"bnl",0,0,0,0,0
	dc.b	"bng",0,0,0,0,0
	dc.b	"bso",0,0,0,0,0
	dc.b	"bns",0,0,0,0,0
	dc.b	"bun",0,0,0,0,0
	dc.b	"bnu",0,0,0,0,0
	dc.b	"b",0,0,0,0,0,0,0
	dc.b	"crand",0,0,0
	dc.b	"cror",0,0,0,0
	dc.b	"crxor",0,0,0
	dc.b	"crnand",0,0
	dc.b	"crnor",0,0,0
	dc.b	"creqv",0,0,0
	dc.b	"crandc",0,0
	dc.b	"crorc",0,0,0
	dc.b	"mcrf",0,0,0,0
**extended crs
	dc.b	"crmove",0,0
	dc.b	"crclr",0,0,0	
	dc.b	"crnot",0,0,0
	dc.b	"crset",0,0,0
	dc.b	"bf",0,0,0,0,0,0
	dc.b	"bt",0,0,0,0,0,0
	dc.b	"bdnzf",0,0,0
	dc.b	"bdnzt",0,0,0	
	dc.b	"bdz",0,0,0,0,0
	dc.b	"bdzf",0,0,0,0
	dc.b	"bdzt",0,0,0,0
		
**system call
	dc.b	"sc",0,0,0,0,0,0
**non-extended insts
	dc.b	"bc",0,0,0,0,0,0
	dc.l	-1,-1
	
	
ppc_code_table:	dc.l	$4e800020	*blr
	dc.l	$40820000	*bne
	dc.l	$41820000	*beq
	dc.l	$42000000	*bdnz
	dc.l	$41810000	*bgt
	dc.l	$41800000	*blt
	dc.l	$40810000	*ble
	dc.l	$40800000	*bge
	dc.l	$40800000	*bnl (not less than)
	dc.l	$40810000	*bng
	dc.l	$41830000	*bso
	dc.l	$40830000	*bns
	dc.l	$41830000	*bun
	dc.l	$40830000	*bnu
	dc.l	$48000000	*b
	dc.l	$4c000202	*crand
	dc.l	$4c000382	*cror	
	dc.l	$4c000182	*crxor
	dc.l	$4c0001c2	*crnand
	dc.l	$4c000042	*crnor
	dc.l	$4c000242	*creqv
	dc.l	$4c000102	*crandc
	dc.l	$4c000342	*crorc
	dc.l	$4c000000	*mcrf
	dc.l	$4c000382	*crmove - cror bx,by,by
	dc.l	$4c000182	*crclr - crxor bx,bx,bx
	dc.l	$4c000042	*crnot - crnor bx,by,by - uses crmove.
	dc.l	$4c000242	*crset - creqv bx,bx,bx
	dc.l	$40800000	*bf
	dc.l	$41800000	*bt
	dc.l	$40000000	*bdnzf	
	dc.l	$41000000	*bdnzt
	dc.l	$42400000	*bdz
	dc.l	$40400000	*bdzf
	dc.l	$41400000	*bdzt
		
	dc.l	$44000002	*sc - system call
**non-extended instructions
	dc.l	$40000000	*bc
	align	
	public	ppc_ass_table,ppc_string_table,ppc_code_table
	extern	blr,bc,branch_l,sc,cr_logical,mcrf
	extern	crmove,crclr,b_logical
	else		*fant4
ppc_ass_table:	
	nop
	public	ppc_ass_table

	endif