	ifne	powerf
**Entries in this table MUST be 8 bytes long, so short bra's need a nop.
**For LXT each entry is 64 bytes in PPC
	if	68k
ppc_int_jumptable:
	else
ppc_int_jumptable:	toc_routine
	endif

**Fixed point loads
	bsr.l	lbz
	rts44	
	bsr.l	lbzdu	*lbzu - if ra=0 or ra=rt then invalid
	rts44
	bsr.l	lbz
	rts44
	bsr.l	lbzdu
	rts44
	bsr.l	lbz	*lha
	rts44
	bsr.l	lbzdu	*lhau
	rts44
	bsr.l	lbz	*lwz
	rts44
	bsr.l	lbzdu	*lwzu
	rts44				

	bsr.l	lwa	*lwa - 64bit warning
	rts44
	bsr.l	lwa	*ld - 64 bit warning
	rts44	
	
	bsr.l	lwa	*LDU - 64 bit only
	rts44
	bsr.l	lbzx
	rts44
	bsr.l	lbzux	*lbzux
	rts44		
	bsr.l	lbzx	*lhzx
	rts44
	bsr.l	lbzux	*lhzux
	rts44	
	bsr.l	lbzx	*lhax
	rts44
	bsr.l	lbzux	*lhaux
	rts44
	bsr.l	lbzx	*LWZX
	rts44
	bsr.l	lbzux	*LWZUX
	rts44
	bsr.l	lwax	*LWAX - 64 bit
	rts44
	
	bsr.l	lwaxt	*LWAUX - 64 bit
	rts44
	
	bsr.l	lwax
	rts44		*LDX - 64bit
					
	bsr.l	lwaxt	*LDUX - 64 bit
	rts44
	
**fixed point stores
	bsr.l	lbz	*same as load, but op is different
	rts44
	bsr.l	lbzx	*STBx
	rts44
	bsr.l	lbz	*sth
	rts44
	bsr.l	sbdu	*stbu
	rts44
	bsr.l	stbux	*stbux
	rts44
	bsr.l	lbzx	*STHX
	rts44
	bsr.l	sbdu	*STHU
	rts44
	bsr.l	stbux	*sthux
	rts44
	bsr.l	lbz	*STW
	rts44	
	bsr.l	lbzx	*stwx
	rts44
	bsr.l	sbdu	*stwu
	rts44
	bsr.l	stbux	*stwux
	rts44
	bsr.l	lwa	*STD - 64bit
	rts44				
	bsr.l	lwax	*STDX - 64bit
	rts44
	bsr.l	lwa	*STD - 64 bit. **WRONG** Should check for ra=0=invalid!
	rts44	
	bsr.l	lwax	*STDUX - 64 bit. **WRONG** SHould check for ra=0=invalid!
	rts44
***load/store with byte reversal
	bsr.l	lbzx	*LHBRX
	rts44
	bsr.l	lbzx	*LWBRX
	rts44
	bsr.l	lbzx	*sthbrx
	rts44	
	bsr.l	lbzx	*STWBRX
	rts44
**LOAD/store multiple
	bsr.l	lbz	*LMW
	rts44
	bsr.l	lbz	*STMW
	rts44
**Strings
	bsr.l	lswi	*LSWI start reg,address reg,n
	rts44
	bsr.l	stswi
	rts44
	bsr.l	lswx
	rts44
	bsr.l	lswx	*STSWX
	rts44
**SYNCH
	bsr.l	lbzx	*LWARX
	rts44
	bsr.l	lwax	*LDARX - 64 bit
	rts44
	
	bsr.l	stwcx	*STWCX.
	rts44
	bsr.l	lwax	*STDCX.
	rts44
	
	bsr.l	eieio	*sync
	rts44			
**Fixed point mafematiks
	bsr.l	addip		*Addi
	rts44	
	bsr.l	li		*Extended load immediate addi rx,0,value
	rts44
	bsr.l	lbz		*LA rx,disp(ry)
	rts44
	bsr.l	subip	*subi rx,ry,value
	rts44
	bsr.l	addip	*addis
	rts44
	bsr.l	li	*lis
	rts44
	bsr.l	subip	*SUBIS
	rts44
	bsr.l	addxo	add
	rts44			
	bsr.l	addxo	addo
	rts44
	bsr.l	ext_sub	sub
	rts44
	bsr.l	addxo	subo
	rts44

	bsr.l	addxo	subf
	rts44
	bsr.l	addxo	subfo
	rts44

	bsr.l	addip	addic
	rts44
	bsr.l	subip	*subic
	rts44
	bsr.l	addip	subfic
	rts44
	bsr.l	addxo	addc
	rts44
	bsr.l	addxo	addco
	rts44					
	bsr.l	addxo	subfc
	rts44
	bsr.l	addxo	subfco
	rts44
	bsr.l	ext_sub	subc
	rts44
	bsr.l	addxo	subco
	rts44
	bsr.l	addxo	adde
	rts44
	bsr.l	addxo	addeo
	rts44
	bsr.l	addxo	subfe
	rts44
	bsr.l	addxo	subfeo
	rts44
	bsr.l	addme	same as addxo but only two ops
	rts44
	bsr.l	addme	addmeo
	rts44
	bsr.l	addme	subfme
	rts44
	bsr.l	addme	subfmeo
	rts44
	bsr.l	addme	addze
	rts44
	bsr.l	addme	addzeo
	rts44
	bsr.l	addme	subfze
	rts44
	bsr.l	addme	subfzeo
	rts44
	bsr.l	addme	neg
	rts44
	bsr.l	addme	nego
	rts44

	bsr.l	addip	*mulli
	rts44
						
	bsr.l	addxo_warn	*mulld
	rts44

	bsr.l	addxo_warn	*mulldo
	rts44

	bsr.l	addxo	*mullw
	rts44
	bsr.l	addxo	*mullwo
	rts44	
	bsr.l	addxo_warn	*mulhd
	rts44
	
	bsr.l	addxo	*mulhw
	rts44

	bsr.l	addxo_warn	*mulhdu
	rts44	

	bsr.l	addxo	*mulhu
	rts44	

	bsr.l	addxo_warn	*divd
	rts44
	bsr.l	addxo_warn	*divdo
	rts44
	
	bsr.l	addxo	*divw
	rts44
	bsr.l	addxo	*divwo
	rts44

	bsr.l	addxo_warn	*divdu
	rts44
	bsr.l	addxo_warn	*divduo
	rts44

	
	bsr.l	addxo	*divwu
	rts44
	bsr.l	addxo	*divwuo
	rts44
	bsr.l	eieio	*trap
	rts44
**LOGICAL
	bsr.l	logici_dot	*ANDI.
	rts44	
	bsr.l	logici_dot	*andis.
	rts44
	bsr.l	logici	*ori
	rts44	
	bsr.l	logici	*oris
	rts44
	bsr.l	eieio	*NOP
	rts44
	bsr.l	logici	*XORI
	rts44
	bsr.l	logici	*XORIS
	rts44
	bsr.l	andx	*and (.)
	rts44		
	bsr.l	andx	*or(.)
	rts44
	bsr.l	mr	*
	rts44
	bsr.l	andx	*xor(.)
	rts44
	bsr.l	andx	*NAND(.)
	rts44
	bsr.l	andx	*NOR(.)
	rts44
	bsr.l	andx	*EQV(.)
	rts44
	bsr.l	andx	*ANDC(.)
	rts44
	bsr.l	mr	*NOT
	rts44
	bsr.l	andx	*orc
	rts44
	bsr.l	extsb	*extsb
	rts44			
	bsr.l	extsb	*extsh
	rts44
	bsr.l	extsb	*cntlzw
	rts44
	bsr.l	extsb_warn	*extsw
	rts44
	bsr.l	extsb_warn	*cntlzd
	rts44
	bsr.l	rldicl		*64bit - in #3
	rts44
	bsr.l	rldicl		*rldicr64bit - in #3
	rts44
	bsr.l	rldicl		*rldic 64bit - in #3
	rts44
	bsr.l	rldicl		*rldimi 64bit - in #3
	rts44
	bsr.l	rlwinm
	rts44
	bsr.l	rlwnm	*RLWNM
	rts44	
	bsr.l	rlwinm	*RLWIMI
	rts44
	bsr.l	extlwi
	rts44
	bsr.l	extrwi
	rts44
	bsr.l	clrlslwi
	rts44
	bsr.l	inslwi
	rts44
	bsr.l	insrwi
	rts44
	bsr.l	rotlwi
	rts44
	bsr.l	rotrwi
	rts44
	bsr.l	rotlw
	rts44
	bsr.l	srwi
	rts44
	bsr.l	slwi
	rts44
	bsr.l	clrlwi
	rts44
	bsr.l	clrrwi
	rts44				
	bsr.l	andx_warn	*SLD
	rts44
	bsr.l	andx	*SLW
	rts44
	bsr.l	andx_warn	*SRD
	rts44
	bsr.l	andx	*SRW
	rts44
	bsr.l	andx_warn	*SRAD
	rts44
	bsr.l	andx	*SRAW
	rts44
	bsr.l	sradi
	rts44		
	bsr.l	srawi
	rts44
	bsr.l	mtspr
	rts44
	bsr.l	mfspr
	rts44
	bsr.l	mtxer
	rts44
	bsr.l	mtxer	*from actually :-)
	rts44
	bsr.l	mtlr
	rts44
	bsr.l	mtlr
	rts44	
	bsr.l	mtctr
	rts44
	bsr.l	mtctr
	rts44	
	bsr.l	mtcrf
	rts44
	bsr.l	mcrxr
	rts44
	bsr.l	mfcr
	rts44
	bsr.l	mffs
	rts44
		
	bsr.l	mcrfs
	rts44
	
	bsr.l	mtfsfi
	rts44
	
	bsr.l	mtfsf
	rts44

	bsr.l	mtfsb0	*mtfsb0
	rts44
	
	bsr.l	mtfsb0	*mtfsb1
	rts44
					
	bsr.l	icbi	*in int#4
	rts44
	bsr.l	eieio	*isync
	rts44
	
	bsr.l	icbi	*DCBT
	rts44
	bsr.l	icbi	*dcbtst
	rts44
	bsr.l	icbi	*dcbz
	rts44
	bsr.l	icbi	*dcbst
	rts44
	bsr.l	icbi	*dcbf
	rts44
	bsr.l	eieio	*eieio
	rts44
	
	bsr.l	mftb	
	rts44
	bsr.l	mftb	*MFTBU
	rts44

	bsr.l	put_ppc	*SC
	rts44
	bsr.l	eieio	*rfi
	rts44
	bsr.l	mtmsr
	rts44
	bsr.l	mtmsr	*MFMSR
	rts44
*5.3 - AltiVec
	bsr.l	do_dst	*dst
	extern	do_dst
	rts44
	bsr.l	do_dst	*dstst
	rts44
	bsr.l	do_dst	*dststt
	rts44
	bsr.l	do_dst	*dstt
	rts44
	bsr.l	do_dss	*dss
	extern	do_dss
	rts44
	bsr.l	put_ppc	*dssall
	rts44
	bsr.l	do_load_vreg	*lvebx
	extern	do_load_vreg
	rts44
	
	bsr.l	do_load_vreg	*lvehx
	rts44
	bsr.l	do_load_vreg	*lvewx
	rts44
	bsr.l	do_load_vreg	*lvsl
	rts44
	bsr.l	do_load_vreg	*lvsr
	rts44
	bsr.l	do_load_vreg	*lvx
	rts44
	bsr.l	do_load_vreg	*lvxl
	rts44

	bsr.l	do_mfvscr
	extern	do_mfvscr
	rts44
	bsr.l	do_mtvscr
	extern	do_mtvscr
	rts44

	bsr.l	do_load_vreg	*stvebx
	rts44
	bsr.l	do_load_vreg	*stvehx
	rts44
	bsr.l	do_load_vreg	*stvewx
	rts44
	bsr.l	do_load_vreg	*stvx
	rts44
	bsr.l	do_load_vreg	*stvxl
	rts44
	bsr.l	mtvrsave	*mtvrsave
	rts44
	bsr.l	mtvrsave	*mfvrsave
	rts44
	extern	mtvrsave
eieio:
;	move.l	  d1,-(sp)
;	bsr.l	get_ops_ppc
;	tst.w	d1
;	beq.s	ei_ok
;	lea	no_ops_needed(pc),a0
;	bsr.l	pass1_warning
;ei_ok:	move.l	(sp)+,d1	
	bsr	put_ppc		 	 	 	 
	rts_	"eieio"
	
**LBA is a sixty four bit instruction only!
lwa:	
	btst	#3,flags7(a5)
	bne.s	no_64_1
	move.l	d1,-(sp)
	lea	sixty_four_warning(pc),a0
	bsr.l	pass1_warning
	move.l	(sp)+,d1	
no_64_1:
	bra.l	lbz
extsb_warn:
	btst	#3,flags7(a5)
	bne.s	no_64_2
	move.l	d1,-(sp)
	lea	sixty_four_warning1(pc),a0
	bsr.l	pass1_warning
	move.l	(sp)+,d1	
no_64_2:
	bra.l	extsb


lwax:
	btst	#3,flags7(a5)
	bne.s	no_64_3
	move.l	d1,-(sp)
	lea	sixty_four_warning1(pc),a0
	bsr.l	pass1_warning
	move.l	(sp)+,d1	
no_64_3	bra.l	stwcx

lwaxt:
	btst	#3,flags7(a5)
	bne.s	no_64_4
	move.l	d1,-(sp)
	lea	sixty_four_warning1(pc),a0
	bsr.l	pass1_warning
	move.l	(sp)+,d1	
no_64_4:
	bra.l	lbzux		*with zero test

addxo_warn:
	btst	#3,flags7(a5)
	bne.s	no_64_5
	move.l	d1,-(sp)
	lea	sixty_four_warning1(pc),a0
	bsr.l	pass1_warning
	move.l	(sp)+,d1	
no_64_5	bra.l	addxo

andx_warn:
	btst	#3,flags7(a5)
	bne.s	no_64_6
	move.l	d1,-(sp)
	lea	sixty_four_warning1(pc),a0
	bsr.l	pass1_warning
	move.l	(sp)+,d1	
no_64_6	bra.l	andx
	
ppc_int_string_table:	dc.b	"lbz",0,0,0,0,0
	dc.b	"lbzu",0,0,0,0
	dc.b	"lhz",0,0,0,0,0
	dc.b	"lhzu",0,0,0,0
	dc.b	"lha",0,0,0,0,0
	dc.b	"lhau",0,0,0,0
	dc.b	"lwz",0,0,0,0,0
	dc.b	"lwzu",0,0,0,0
	dc.b	"lwa",0,0,0,0,0
	dc.b	"ld",0,0,0,0,0,0
	dc.b	"ldu",0,0,0,0,0

**indexed loads
	dc.b	"lbzx",0,0,0,0
	dc.b	"lbzux",0,0,0
	dc.b	"lhzx",0,0,0,0
	dc.b	"lhzux",0,0,0
	dc.b	"lhax",0,0,0,0
	dc.b	"lhaux",0,0,0
	dc.b	"lwzx",0,0,0,0
	dc.b	"lwzux",0,0,0
	dc.b	"lwax",0,0,0,0	- 64 bit
	dc.b	"lwaux",0,0,0	- 64 bit
	dc.b	"ldx",0,0,0,0,0	- 64 bit
	dc.b	"ldux",0,0,0,0	- 64 bit	
**stores
	dc.b	"stb",0,0,0,0,0
	dc.b	"stbx",0,0,0,0
	dc.b	"sth",0,0,0,0,0
	dc.b	"stbu",0,0,0,0
	dc.b	"stbux",0,0,0
	dc.b	"sthx",0,0,0,0
	dc.b	"sthu",0,0,0,0
	dc.b	"sthux",0,0,0
	dc.b	"stw",0,0,0,0,0
	dc.b	"stwx",0,0,0,0
	dc.b	"stwu",0,0,0,0
	dc.b	"stwux",0,0,0
	dc.b	"std",0,0,0,0,0	- 64 bit
	dc.b	"stdx",0,0,0,0	- 64 bit
	dc.b	"stdu",0,0,0,0	- 64 bit
	dc.b	"stdux",0,0,0	- 64 bit
	dc.b	"lhbrx",0,0,0
	dc.b	"lwbrx",0,0,0
	dc.b	"sthbrx",0,0
	dc.b	"stwbrx",0,0
**load/store multiple
	dc.b	"lmw",0,0,0,0,0
	dc.b	"stmw",0,0,0,0	
*string
	dc.b	"lswi",0,0,0,0
	dc.b	"stswi",0,0,0	
	dc.b	"lswx",0,0,0,0
	dc.b	"stswx",0,0,0
*synch
	dc.b	"lwarx",0,0,0
	dc.b	"ldarx",0,0,0 - 64 bit!
	dc.b	"stwcx",0,0,0
	dc.b	"stdcx",0,0,0
	dc.b	"sync",0,0,0,0
**fixed point arithmetic
	dc.b	"addi",0,0,0,0
	dc.b	"li",0,0,0,0,0,0	*load immediate
	dc.b	"la",0,0,0,0,0,0	*load address - la rx,disp(ry)
	dc.b	"subi",0,0,0,0		*subi rx,ry,value
	dc.b	"addis",0,0,0
	dc.b	"lis",0,0,0,0,0		*lis
	dc.b	"subis",0,0,0		*subis

	dc.b	"add",0,0,0,0,0
	dc.b	"addo",0,0,0,0
	dc.b	"sub",0,0,0,0,0
	dc.b	"subo",0,0,0,0
	dc.b	"subf",0,0,0,0
	dc.b	"subfo",0,0,0
	dc.b	"addic",0,0,0
	dc.b	"subic",0,0,0
	dc.b	"subfic",0,0
	dc.b	"addc",0,0,0,0
	dc.b	"addco",0,0,0
	dc.b	"subfc",0,0,0
	dc.b	"subfco",0,0
	dc.b	"subc",0,0,0,0
	dc.b	"subco",0,0,0
	dc.b	"adde",0,0,0,0
	dc.b	"addeo",0,0,0
	dc.b	"subfe",0,0,0
	dc.b	"subfeo",0,0
	dc.b	"addme",0,0,0
	dc.b	"addmeo",0,0
	dc.b	"subfme",0,0
	dc.b	"subfmeo",0
	dc.b	"addze",0,0,0
	dc.b	"addzeo",0,0
	dc.b	"subfze",0,0
	dc.b	"subfzeo",0
	dc.b	"neg",0,0,0,0,0
	dc.b	"nego",0,0,0,0
	dc.b	"mulli",0,0,0
	dc.b	"mulld",0,0,0
	dc.b	"mulldo",0,0
	dc.b	"mullw",0,0,0
	dc.b	"mullwo",0,0
	dc.b	"mulhd",0,0,0
	dc.b	"mulhw",0,0,0
	dc.b	"mulhdu",0,0
	dc.b	"mulhwu",0,0
	dc.b	"divd",0,0,0,0
	dc.b	"divdo",0,0,0
	dc.b	"divw",0,0,0,0
	dc.b	"divwo",0,0,0
	dc.b	"divdu",0,0,0
	dc.b	"divduo",0,0
	dc.b	"divwu",0,0,0
	dc.b	"divwuo",0,0
	dc.b	"trap",0,0,0,0	
	dc.b	"andi",0,0,0,0
	dc.b	"andis",0,0,0
	dc.b	"ori",0,0,0,0,0
	dc.b	"oris",0,0,0,0
	dc.b	"nop",0,0,0,0,0
	dc.b	"xori",0,0,0,0
	dc.b	"xoris",0,0,0
	dc.b	"and",0,0,0,0,0
	dc.b	"or",0,0,0,0,0,0
	dc.b	"mr",0,0,0,0,0,0
	dc.b	"xor",0,0,0,0,0
	dc.b	"nand",0,0,0,0
	dc.b	"nor",0,0,0,0,0
	dc.b	"eqv",0,0,0,0,0
	dc.b	"andc",0,0,0,0
	dc.b	"not",0,0,0,0,0
	dc.b	"orc",0,0,0,0,0
	dc.b	"extsb",0,0,0
	dc.b	"extsh",0,0,0
	dc.b	"cntlzw",0,0
	dc.b	"extsw",0,0,0
	dc.b	"cntlzd",0,0
	dc.b	"rldicl",0,0
	dc.b	"rldicr",0,0
	dc.b	"rldic",0,0,0
	dc.b	"rldimi",0,0
	dc.b	"rlwinm",0,0
	dc.b	"rlwnm",0,0,0
	dc.b	"rlwimi",0,0
	
**extended rots
	dc.b	"extlwi",0,0
	dc.b	"extrwi",0,0	
	dc.b	"clrlslwi"
	dc.b	"inslwi",0,0
	dc.b	"insrwi",0,0
	dc.b	"rotlwi",0,0
	dc.b	"rotrwi",0,0
	dc.b	"rotlw",0,0,0
	dc.b	"srwi",0,0,0,0
	dc.b	"slwi",0,0,0,0
	dc.b	"clrlwi",0,0
	dc.b	"clrrwi",0,0

**shifts
	dc.b	"sld",0,0,0,0,0
	dc.b	"slw",0,0,0,0,0
	dc.b	"srd",0,0,0,0,0
	dc.b	"srw",0,0,0,0,0
	dc.b	"srad",0,0,0,0
	dc.b	"sraw",0,0,0,0
	dc.b	"sradi",0,0,0
	dc.b	"srawi",0,0,0

	dc.b	"mtspr",0,0,0
	dc.b	"mfspr",0,0,0
	dc.b	"mtxer",0,0,0
	dc.b	"mfxer",0,0,0
	dc.b	"mtlr",0,0,0,0
	dc.b	"mflr",0,0,0,0
	dc.b	"mtctr",0,0,0
	dc.b	"mfctr",0,0,0
	dc.b	"mtcrf",0,0,0
	dc.b	"mcrxr",0,0,0
	dc.b	"mfcr",0,0,0,0
	dc.b	"mffs",0,0,0,0
	dc.b	"mcrfs",0,0,0
	dc.b	"mtfsfi",0,0
	dc.b	"mtfsf",0,0,0
	dc.b	"mtfsb0",0,0
	dc.b	"mtfsb1",0,0

	dc.b	"icbi",0,0,0,0
	dc.b	"isync",0,0,0
	dc.b	"dcbt",0,0,0,0
	dc.b	"dcbtst",0,0
	dc.b	"dcbz",0,0,0,0
	dc.b	"dcbst",0,0,0
	dc.b	"dcbf",0,0,0,0
	dc.b	"eieio",0,0,0

	dc.b	"mftb",0,0,0,0
	dc.b	"mftbu",0,0,0
	
	dc.b	"sc",0,0,0,0,0,0
	dc.b	"rfi",0,0,0,0,0

	dc.b	"mtmsr",0,0,0
	dc.b	"mfmsr",0,0,0
**altivec misc (altivec vector instructions all start with "v" and are handled by the vector_table
**5.30
	dc.b	"dst",0,0,0,0,0
	dc.b	"dstst",0,0,0
	dc.b	"dststt",0,0
	dc.b	"dstt",0,0,0,0
	dc.b	"dss",0,0,0,0,0
	dc.b	"dssall",0,0
	
	dc.b	"lvebx",0,0,0
	dc.b	"lvehx",0,0,0
	dc.b	"lvewx",0,0,0
	dc.b	"lvsl",0,0,0,0
	dc.b	"lvsr",0,0,0,0
	dc.b	"lvx",0,0,0,0,0
	dc.b	"lvxl",0,0,0,0
	
	dc.b	"mfvscr",0,0
	dc.b	"mtvscr",0,0
	
	dc.b	"stvebx",0,0
	dc.b	"stvehx",0,0
	dc.b	"stvewx",0,0
	dc.b	"stvx",0,0,0,0
	dc.b	"stvxl",0,0,0
	
	dc.b	"mtvrsave"
	dc.b	"mfvrsave"

	dc.l	-1,-1
		
ppc_int_code_table:	dc.l	$88000000	*lbz
	dc.l	$8c000000	*lbzu
	dc.l	$a0000000	*lhz
	dc.l	$a4000000	*lhzu			
	dc.l	$a8000000	*lha
	dc.l	$ac000000	*lhau
	dc.l	$80000000	*lwz
	dc.l	$84000000	*lwzu
	dc.l	$e8000002	*lwa
	dc.l	$e8000000	*ld
	dc.l	$e8000001	*ldu
**INDEXED LOADS
	dc.l	$7c0000ae	*lbzx
	dc.l	$7c0000ee	*lbzux
	dc.l	$7c00022e	*lhzx
	dc.l	$7c00026e	*lhzux
	dc.l	$7c0002ae	*lhax			
	dc.l	$7c0002ee	*lhaux
	dc.l	$7c00002e	*lwzx
	dc.l	$7c00006e	*LWZUX
	dc.l	$7c0002aa	*LWAX - 64bit	
	dc.l	$7c0002ea	*LWAUX - 64bit
	dc.l	$7c00002a	*LDX - 64 bit
	dc.l	$7c00006a	*LDUX - 64bit	
**Fixed point stores - displacement stores
	dc.l	$98000000	*stb
	dc.l	$7c0001ae	*stbx
	dc.l	$b0000000	*sth
	dc.l	$9c000000	*stbu
	dc.l	$7c0001ee	*stbux
	dc.l	$7c00032e	*STHX
	dc.l	$b4000000	*STHU
	dc.l	$7c00036e	*STHUX
	dc.l	$90000000	*STW
	dc.l	$7c00012e	*stwx
	dc.l	$94000000	*stwu
	dc.l	$7c00016e	*STWUX
	dc.l	$f8000000	*STD - 64 bit
	dc.l	$7c00012a	*STDX - 64bit
	dc.l	$F8000001	*STDU - 64 bit  - no error checking for ra=0!
	dc.l	$7c00016a	*STDUX - 64 bit - no error checking for ra=0!
**Byte revsal insts
	dc.l	$7c00062c	*LHBRX
	dc.l	$7c00042c	*LWBRX
	dc.l	$7c00072c	*STHBRX
	dc.l	$7c00052c	*STWBRX
**multiple loads/stores
	dc.l	$b8000000	*LMW
	dc.l	$BC000000	*STMW
**STRING
	dc.l	$7c0004aa	*lswi
	dc.l	$7c0005aa	*stswi	
	dc.l	$7c00042a	*lswx
	dc.l	$7c00052a	*STSWX
**Synch instructions
	dc.l	$7c000028	*LWARX
	dc.l	$7c0000a8	*LDARX - goes lwax
	dc.l	$7c00012d	*STWCX. - goes lbzx :-)
	dc.l	$7c0001ad	*STDCX. - goes lwax	
	dc.l	$7c0004ac	*SYNC - goes straight in
**fixed point maffs
	dc.l	$38000000	*addi
	dc.l	$38000000	*LI
	dc.l	$38000000	*la
	dc.l	$38000000	*subi	
	dc.l	$3c000000	*addis
	dc.l	$3c000000	*LIS
	dc.l	$3c000000	*subis

	dc.l	$7c000214	*add
	dc.l	$7c000614	*addo
	dc.l	$7c000050	*sub
	dc.l	$7c000450	*subo
	dc.l	$7c000050	*subf
	dc.l	$7c000450	*subfo
		
	dc.l	$30000000	*addic
	dc.l	$30000000	*subic
	dc.l	$20000000	*subfic	

	dc.l	$7c000014	*addc
	dc.l	$7c000414	*adco
	dc.l	$7c000010	*subfc
	dc.l	$7c000410	*subfco
	dc.l	$7c000010	*subc
	dc.l	$7c000410	*subco	

	dc.l	$7c000114	*adde
	dc.l	$7c000514	*addeo
	dc.l	$7c000110	*subfe
	dc.l	$7c000510	*subfeo

	dc.l	$7c0001d4	*addme
	dc.l	$7c0005d4	*addmeo
	dc.l	$7c0001d0	*subfme
	dc.l	$7c0005d0	*subfmeo
	dc.l	$7c000194	*addze
	dc.l	$7c000594	*addzeo
	dc.l	$7c000190	*subfze
	dc.l	$7c000590	*subfzeo
	dc.l	$7c0000d0	*neg
	dc.l	$7c0004d0	*nego
	dc.l	$1c000000	*mulli
	dc.l	$7c0001d2	*mulld
	dc.l	$7c0005d2	*mulldo
	dc.l	$7c0001d6	*mullw
	dc.l	$7c0005d6	*mullwo
	dc.l	$7c000092	*mullhd
	dc.l	$7c000096	*mulhw
	dc.l	$7c000012	*mulhdu
	dc.l	$7c000016	*mulhwu	

	dc.l	$7c0003d2	*DIVD
	dc.l	$7c0007d2	*DIVDO
	
	dc.l	$7c0003d6	*divw
	dc.l	$7c0007d6	*divwo
	
	dc.l	$7c000392	*DIVDU
	dc.l	$7c000792	*DIVDUO
	
	dc.l	$7c000396	*DIVWU
	dc.l	$7c000796	*DIVWUO
	dc.l	$7fe00008	*TRAP		
	dc.l	$70000000	*ANDI.
	dc.l	$74000000	*ANDIS
	dc.l	$60000000	*ori
	dc.l	$64000000	*oris	
	dc.l	$60000000	*nop
	dc.l	$68000000	*XORI
	dc.l	$6C000000	*XORIS
	dc.l	$7c000038	*andX (.)
	dc.l	$7c000378	*orX(.)
	dc.l	$7c000378	*mr
	dc.l	$7c000278	*xor
	dc.l	$7c0003b8	*nand
	dc.l	$7c0000f8	*nor
	dc.l	$7c000238	*eqv
	dc.l	$7c000078	*andc
	dc.l	$7c0000f8	*NOT(nor)
	dc.l	$7c000338	*orc
	dc.l	$7c000774	*extsb
	dc.l	$7c000734	*extsh
	dc.l	$7c000034	*cntlzw
	dc.l	$7c0007b4	*extsw
	dc.l	$7c000074	*CNTLZD

	dc.l	$78000000	*RLDICL (.)
	dc.l	$78000004	*RLDICR (.)
	dc.l	$78000008	*RLDIC (.)
	dc.l	$7800000c	*rldimi (.)
	DC.L	$54000000	*RLWINM (.)
	dc.l	$5c000000	*RLWNM (.)
	dc.l	$50000000	*RLWIMI	
	dc.l	$54000000	*EXTLWI
	dc.l	$54000000	*EXTRWI	
	dc.l	$54000000	*CLRLSLWI
	dc.l	$50000000	*inslwi
	dc.l	$50000000	*INSRWI
	dc.l	$54000000	*rotlwi
	dc.l	$54000000	*Rotrwi
	dc.l	$5c000000	*rotlw
	dc.l	$54000000	*SLWI
	dc.l	$54000000	*SRWI
	dc.l	$54000000	*clrlwi
	dc.l	$54000000	*clrrwi

	dc.l	$7c000036	*SLD
	dc.l	$7c000030	*SLW
	dc.l	$7c000436	*SRD
	dc.l	$7c000430	*SRW
	dc.l	$7c000634	*SRAD
	dc.l	$7c000630	*SRAW
	dc.l	$7c000674	*SRADi
	dc.l	$7c000670	*SRAWI	
	
	dc.l	$7c0003a6	*MTSPR
	dc.l	$7c0002a6	*mfspr
	dc.l	$7c0003a6	*mtxer
	dc.l	$7c0002a6	*mfxer
	dc.l	$7c0003a6	*mtlr
	dc.l	$7c0002a6	*mflr
	dc.l	$7c0003a6	*mtctr
	dc.l	$7c0002a6	*mfctr
	dc.l	$7c000120	*MTCRF
	dc.l	$7c000400	*MCRXR	
	dc.l	$7c000026	*MFCR
	dc.l	$fc00048e	*MFFS
	dc.l	$FC000080	*mcrfs
	dc.l	$FC00010c	*MTFSFI
	dc.l	$fc00058e	*MTFSF
	dc.l	$fc00008c	*MTFSB0
	dc.l	$fc00004c	*MTFSB1

	dc.l	$7c0007ac	*ICBI
	dc.l	$4c00012c	*isync
	dc.l	$7c00022c	*dcbt	
	dc.l	$7c0001ec	*dcbtst
	dc.l	$7c0007ec	*DCBZ
	dc.l	$7c00006c	*DCBST
	dc.l	$7c0000ac	*DCBF
	dc.l	$7c0006ac	*EIEIO, and on that farm...	
	
	dc.l	$7c0c42e6	*mftb
	dc.l	$7c0d42e6	*mftbu
	
	dc.l	$44000002	*sc
	dc.l	$4c000064	*rfi
	
	dc.l	$7c000124	*MTMSR
	dc.l	$7c0000A6	*mfmsr
*5.3 - altivec
	dc.l	$7c0002ac	*dst
	dc.l	$7c0002ec	*dstst
	dc.l	$7e0002ec	*dststt
	dc.l	$7e0002ac	*dstt
	dc.l	$7c00066c	*dss
	dc.l	$7e00066c	*dssall
	
	dc.l	$7c00000e	*lvebx
	dc.l	$7c00004e	*lvehx
	dc.l	$7c00008e	*lvewx
	dc.l	$7c00000c	*lvsl
	dc.l	$7c00004c	*lvsr
	dc.l	$7c0000ce	*lvx
	dc.l	$7c0002ce	*lvxl
	
	dc.l	$10000604	*mfvscr
	dc.l	$10000644	*mtvscr
	
	dc.l	$7c00010e
	dc.l	$7c00014e
	dc.l	$7c00018e
	dc.l	$7c0001ce
	dc.l	$7c0003ce

	dc.l	$7c0003a6	*mtvrsave
	dc.l	$7c0002a6	*mfvrsave
	
	rts_	"PPC_int_ass_table_Rev1"

sixty_four_warning:	dc.b	"***WARNING***WARNING***WARNING***",13
	dc.b	"This is a 64 bit instruction and is",13
	dc.b	"illegal on 32 bit processors "
	dc.b	"such as the 601 and 603!",13
	dc.b	"It has however been assembled.",13
	dc.b	"**NOTE** Doubleword instructions assume your",13
	dc.b	"data is aligned on an 8 byte boundry.",13,0
	even	
sixty_four_warning1:	dc.b	"***WARNING***WARNING***WARNING***",13
	dc.b	"This is a 64 bit instruction and is",13
	dc.b	"illegal on 32 bit processors "
	dc.b	"such as the 601 and 603!",13
	dc.b	"It has however been assembled.",13,0
	even	

	global	ppc_int_jumptable,ppc_int_string_table,ppc_int_code_table
	extern	lbz,lbzx,pass1_warning,lbzux,sbdu,lbzdu,stbux,lswi
	extern	stswi,lswx,no_operands,addip,li,subip
	extern	addxo,addme,put_ppc,logici,andx,mr,extsb,rldicl,rlwinm,rlwnm
	extern	extlwi,extrwi,clrlslwi,inslwi,insrwi,rotlwi,rotrwi,rotlw,sradi
	extern	slwi,srwi,clrlwi,clrrwi,srawi,mtspr,mfspr,mtxer,mtlr,mtctr,mtcrf
	extern	mcrxr,mfcr,mffs,mcrfs,mtfsfi,mtfsf,mtfsb0,icbi,mftb,mtmsr,no_ops_needed
	extern	get_ops_ppc,stwcx,ext_sub,logici_dot
	else
ppc_int_jumptable:
	nop
	public	ppc_int_jumptable
	endif