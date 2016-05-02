	if	68k
ppc_fass_table:
	else
ppc_fass_table:	toc_routine
	endif
	bsr.l	fmr
	rts44		*fmr
	bsr.l	fmr	*FNEG
	rts44
	bsr.l	fmr	*FABS
	rts44
	bsr.l	fmr	*FNABS
	rts44
	bsr.l	fmr	*frsp
	rts44
	bsr.l	fmr_warn	*fctid
	rts44			
	bsr.l	fmr_warn	*FCTIDZ
	rts44
	bsr.l	fmr		*FCTIW
	rts44
	bsr.l	fmr		*FCTIWZ
	rts44
	bsr.l	fmr_warn	*fcfid
	rts44
	bsr.l	fadd		*FADD
	rts44			
	bsr.l	fadd		*FADDS
	rts44
	bsr.l	fadd		*FSUB
	rts44
	bsr.l	fadd		*FSUBS
	rts44
	bsr.l	fadd	*FDIV
	rts44
	bsr.l	fadd	*FDIVS
	rts44	
	bsr.l	fmul
	rts44
	bsr.l	fmul
	rts44
	bsr.l	fmadd
	rts44	
	bsr.l	fmadd
	rts44		*FMADDS
	bsr.l	fmadd	*FMSUB
	rts44
	bsr.l	fmadd	*FMSUBS
	rts44
	bsr.l	fmadd	*FNMSUB
	rts44
	bsr.l	fmadd	*FNMSUBS
	rts44
	bsr.l	fmadd	*FNMadd
	rts44
	bsr.l	fmadd	*FNMadds
	rts44
	bsr.l	cmpf	*FCMPU
	rts44
	bsr.l	cmpf	*FCMPO
	rts44
**Additions for Fantasm 510
	bsr.l	fmr	*fsqrt[.]
	rts44
	bsr.l	fmr	*fsqrts[.]
	rts44
	bsr.l	fmr	*fres[.]
	rts44
	bsr.l	fmr	*fsqrt[.]
	rts44
	bsr.l	fmr	*frsqrte[.]
	rts44

	rts_	"PPC_Fass_Table"

fmr_warn:
	btst	#3,flags7(a5)
	bne.s	no_64_1
	move.l	d1,-(sp)
	lea	ft_sixty_four_warning(pc),a0
	bsr.l	pass1_warning
	move.l	(sp)+,d1	
no_64_1:
	bra.l	fmr
	if	68k	
ppc_flass_table:
	else
ppc_flass_table:	toc_routine
	endif
	
	bsr.l	lfs
	rts44

	bsr.l	lfs	*LFSU
	rts44

	bsr.l	lfs	*LFD
	rts44

	bsr.l	lfs	*LFDU
	rts44
	
	bsr.l	lfsx	
	rts44
	bsr.l	lfsx
	rts44			*lfsux

	bsr.l	lfsx	*lfdx
	rts44
	
	bsr.l	lfsx	*lfdux
	rts44
	

	bsr.l	lfs	*STFS
	rts44
	
	
	bsr.l	lfs	*STFSU
	rts44
	
	bsr.l	lfs	*STFD
	rts44
	
	bsr.l	lfs	*STFDU
	rts44
	

	bsr.l	lfsx	*stfsx
	rts44
	

	bsr.l	lfsx	*stfsux
	rts44
	
	bsr.l	lfsx	*stfdx
	rts44
	
	bsr.l	lfsx	*stfdux
	rts44
	

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

ppc_fsyntax_table:	dc.b	"fmr",0,0,0,0,0
	dc.b	"fneg",0,0,0,0
	dc.b	"fabs",0,0,0,0
	dc.b	"fnabs",0,0,0
	dc.b	"frsp",0,0,0,0
	dc.b	"fctid",0,0,0	*64 bit only
	dc.b	"fctidz",0,0	*64 bit only!	
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
ft_sixty_four_warning:	dc.b	"***WARNING*** This is a 64 bit instruction and is not legal on 32 bit processors such as the 601 and 603.",13,0
	align

	global	ppc_fass_table,ppc_fsyntax_table,ppc_fcode_table
	global	ppc_flass_table,ppc_flsyntax_table,ppc_flcode_table

	extern	fmr,pass1_warning,fadd,fmul,fmadd,cmpf,mffs
	extern	lfs,lfsx
	extern	pass1_error

dummy5:
	nop
	global	dummy5

		   *End of demo rip out
