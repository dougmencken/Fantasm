	align
**Each entry is 8 bytes for 68k and 64 bytes for ppc
**Op-code jump
	if	68k
ass_table:
	else
ass_table:	toc_routine
	endif
	bsr.l	move	0
	rts44
	
	bsr.l	bra	bsr1
	rts44
	
	bsr.l	simple	rts2
	rts44

	bsr.l	add	12
	rts44
	
	bsr.l	bra	bra3
	rts44
	
	bsr.l	bra	bne4	bne
	rts44
	
	bsr.l	bra	beq5
	rts44

	
	bsr.l	bra	bge6
	rts44
	bsr.l	bra	ble7
	rts44
	bsr.l	bra	bgt8
	rts44
	bsr.l	bra	blt9
	rts44
	bsr.l	bra	bmi10
	rts44
	bsr.l	bra	bpl11
	rts44

	bsr.l	add	adda13
	rts44
	bsr.l	addi	14
	rts44
	bsr.l	addq	15
	rts44
	bsr.l	sub	16
	rts44

	bsr.l	sub	suba17
	rts44
	bsr.l	subi	18
	rts44
	bsr.l	subq	19
	rts44
	bsr.l	cmp	20
	rts44

	
	bsr.l	cmpa	21
	rts44
	
	bsr.l	cmpi	22
	rts44
	
	bsr.l	dbra	23
	rts44
	
	bsr.l	type_11	tst24
	rts44
	
	bsr.l	dbra	dbf25
	rts44
	
	bsr.l	ext	26
	rts44
	
	bsr.l	lea	27
	rts44
	
	bsr.l	movem	28
	rts44
	
	bsr.l	moveq	29
	rts44
	
	bsr.l	type_11	neg30
	rts44
	bsr.l	trap	31
	rts44
	bsr.l	and	32
	rts44
	bsr.l	andi	33
	rts44
	bsr.l	type13	bclr34
	rts44
	bsr.l	type13	bchg35
	rts44
	bsr.l	type13	bset36
	rts44
	bsr.l	type13	btst37
	rts44
	bsr.l	type_11	clr38
	rts44
	bsr.l	type2	divs39
	rts44
	bsr.l	type2	divu40
	rts44
	bsr.l	exg	41
	rts44
	bsr.l	jsr	jmp42
	rts44
	bsr.l	jsr	43
	rts44
	bsr.l	lsl	44
	rts44
	bsr.l	lsr	45
	rts44
	bsr.l	type2	muls46
	rts44
	bsr.l	type2	mulu47
	rts44
	bsr.l	simple	nop48
	rts44
	bsr.l	type_11	not49
	rts44
	bsr.l	or	50
	rts44
	bsr.l	ori	51
	rts44
	bsr.l	pea	52
	rts44
	bsr.l	asl	53
	rts44
	bsr.l	asr	54
	rts44
	bsr.l	rol	55
	rts44
	bsr.l	ror	56
	rts44
	bsr.l	simple	rte57	ee
	rts44
	bsr.l	scc	58
	rts44
	bsr.l	scc	scs59
	rts44
	bsr.l	scc	seq60
	rts44
	bsr.l	scc	sge61
	rts44
	bsr.l	scc	sgt62
	rts44
	bsr.l	scc	shi63
	rts44
	bsr.l	scc	sle64
	rts44
	bsr.l	scc	sls65
	rts44
	bsr.l	scc	slt66
	rts44
	bsr.l	scc	smi67
	rts44
	bsr.l	scc	sne68
	rts44
	bsr.l	scc	spl69
	rts44
	bsr.l	scc	svc70
	rts44
	bsr.l	scc	svs71
	rts44
	bsr.l	scc	sf72
	rts44
	bsr.l	scc	st73
	rts44
	bsr.l	swap	74
	rts44
	bsr.l	tas	75
	rts44
	bsr.l	unlk	76
	rts44
	bsr.l	link	77
	rts44
	bsr.l	eor	78
	rts44
	bsr.l	eori	79
	rts44
	bsr.l	movep	80
	rts44
	bsr.l	simple	illegal81
	rts44
	bsr.l	not_implemented	spare82
	rts44
	bsr.l	bra	bhi83
	rts44
	bsr.l	bra	bls84
	rts44
	bsr.l	bra	bcc85
	rts44
	bsr.l	bra	bcs86
	rts44
	bsr.l	bra	bvc87
	rts44
	bsr.l	bra	bvs88
	rts44
	bsr.l	abcd	89
	rts44
	bsr.l	addx	90
	rts44
	bsr.l	chk	91
	rts44
	bsr.l	cmpm	92
	rts44
	bsr.l	dbra	dbt93
	rts44
	bsr.l	dbra	dbf94
	rts44
	bsr.l	dbra	dbhi95
	rts44
	bsr.l	dbra	dbls96
	rts44
	bsr.l	dbra	dbcc97
	rts44
	bsr.l	dbra	dbcs98
	rts44
	bsr.l	dbra	dbne99
	rts44
	bsr.l	dbra	dbeq100
	rts44
	bsr.l	dbra	dbvc101
	rts44
	bsr.l	dbra	dbvs102
	rts44
	bsr.l	dbra	dbpl103
	rts44
	bsr.l	dbra	dbmi104
	rts44
	bsr.l	dbra	dbge105
	rts44
	bsr.l	dbra	dblt106
	rts44
	bsr.l	dbra	dbgt107
	rts44
	bsr.l	dbra	dble108
	rts44
	bsr.l	nbcd	109
	rts44
	bsr.l	negx	110
	rts44
	bsr.l	simple	reset111
	rts44
	bsr.l	roxl	112
	rts44
	bsr.l	roxr	113
	rts44
	bsr.l	simple	rtr114
	rts44
	bsr.l	sbcd	115
	rts44
	bsr.l	stop	116
	rts44
	bsr.l	subx	117
	rts44
	bsr.l	trapv	118
	rts44
	bsr.l	move	movea119
	rts44
	bsr.l	bf1	bfchg 120
	rts44
	bsr.l	bf1	bfclr
	rts44
	bsr.l	bf1	bfset 122
	rts44
	bsr.l	bf1	bftst 123
	rts44
	bsr.l	bf1	bfexts 124  - goes to bf2
	rts44
	bsr.l	bf1	bfextu 125  - goes to bf2
	rts44
	bsr.l	bf1	bfffo 126   - goes to bf2
	rts44
	bsr.l	bf1	bfins 127 - goes to bf3
	rts44
	bsr.l	cas	cas 128
	rts44
	bsr.l	cas	cas2 129
	rts44
	bsr.l	chk2	chk2 130
	rts44
	bsr.l	cmp2	cmp2 131
	rts44
	bsr.l	ext	extb.l 132
	rts44
	bsr.l	move16	move16 133
	rts44
	bsr.l	trapcc	t	134
	rts44
	bsr.l	trapcc	f	135
	rts44
	bsr.l	trapcc	hi	
	rts44
	bsr.l	trapcc	ls
	rts44
	bsr.l	trapcc	cc	138
	rts44
	bsr.l	trapcc	cs	139
	rts44
	bsr.l	trapcc	ne	140
	rts44
	bsr.l	trapcc	eq	141
	rts44
	bsr.l	trapcc	vc	142
	rts44
	bsr.l	trapcc	vs	143
	rts44
	bsr.l	trapcc	pl	144
	rts44
	bsr.l	trapcc	mi	145
	rts44
	bsr.l	trapcc	ge	146
	rts44
	bsr.l	trapcc	lt	147
	rts44
	bsr.l	trapcc	gt	148
	rts44
	bsr.l	trapcc	le	149
	rts44
	bsr.l	not_implemented	just in case
	rts44
	bsr.l	not_implemented
	rts44
	
	global	ass_table
	
	xref	move,bra,simple,add,addi,addq,sub,subi,subq,cmp,cmpa,cmpi,dbra
	xref	type_11,ext,lea,movem,moveq,trap,and,andi,type13,type2,exg,jsr,lsl,lsr,or
	xref	ori,pea,asl,asr,rol,ror,scc,swap,tas,unlk,link,eor,eori,movep,not_implemented
	xref	abcd,addx,chk,cmpm,nbcd,negx,roxl,roxr,sbcd,stop,subx,trapv,bf1
	xref	cas,chk2,cmp2
	xref	move16,trapcc
	align