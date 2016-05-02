********************************************************
*THIS IS THE INSTRUCTION TABLE.
***COMMONLY USED INSTRUCTIONS ARE AT THE FRONT FOR SPEED
***ALL INSTRUCTIONS TEXT ARE 8 BYTES LONG
	public	inst_table
s1:	nop
	rts
	align
inst_table:		DC.B	"MOVE",0,0,0,0 	* 0
	DC.B	"BSR",0,0,0,0,0	* 1
	DC.B	"RTS",0,0,0,0,0	* 2
	DC.B	"ADD",0,0,0,0,0	*12
	DC.B	"BRA",0,0,0,0,0	* 3
	DC.B	"BNE",0,0,0,0,0	* 4
	DC.B	"BEQ",0,0,0,0,0	* 5
	DC.B	"BGE",0,0,0,0,0	* 6
	DC.B	"BLE",0,0,0,0,0	* 7
	DC.B	"BGT",0,0,0,0,0	* 8
	DC.B	"BLT",0,0,0,0,0	* 9
	DC.B	"BMI",0,0,0,0,0	*10
	DC.B	"BPL",0,0,0,0,0	*11

	DC.B	"ADDA",0,0,0,0	*13
	DC.B	"ADDI",0,0,0,0	*14
	DC.B	"ADDQ",0,0,0,0	*15
	DC.B	"SUB",0,0,0,0,0	*16
	DC.B	"SUBA",0,0,0,0	*17
	DC.B	"SUBI",0,0,0,0	*18
	DC.B	"SUBQ",0,0,0,0	*19
	DC.B	"CMP",0,0,0,0,0	*20
	DC.B	"CMPA",0,0,0,0	*21
	DC.B	"CMPI",0,0,0,0	*22
	DC.B	"DBRA",0,0,0,0	*23
	DC.B	"TST",0,0,0,0,0	*24
	DC.B	"DBF",0,0,0,0,0	*25
	DC.B	"EXT",0,0,0,0,0	*26
	DC.B	"LEA",0,0,0,0,0	*27
	DC.B	"MOVEM",0,0,0	*28
	DC.B	"MOVEQ",0,0,0	*29
	DC.B	"NEG",0,0,0,0,0	*30
	DC.B	"TRAP",0,0,0,0	*31
	DC.B	"AND",0,0,0,0,0	*32
****
	DC.B	"ANDI",0,0,0,0	*33
	DC.B	"BCLR",0,0,0,0	*34
	DC.B	"BCHG",0,0,0,0	*35
	DC.B	"BSET",0,0,0,0	*36
	DC.B	"BTST",0,0,0,0	*37
	DC.B	"CLR",0,0,0,0,0	*38
	DC.B	"DIVS",0,0,0,0	*39
	DC.B	"DIVU",0,0,0,0	*40
	DC.B	"EXG",0,0,0,0,0	*41
	DC.B	"JMP",0,0,0,0,0	*42
	DC.B	"JSR",0,0,0,0,0	*43
	DC.B	"LSL",0,0,0,0,0	*44
	DC.B	"LSR",0,0,0,0,0	*45
	DC.B	"MULS",0,0,0,0	*46
	DC.B	"MULU",0,0,0,0	*47
	DC.B	"NOP",0,0,0,0,0	*48
	DC.B	"NOT",0,0,0,0,0	*49
	DC.B	"OR",0,0,0,0,0,0	*50
	DC.B	"ORI",0,0,0,0,0	*51
	DC.B	"PEA",0,0,0,0,0	*52
	DC.B	"ASL",0,0,0,0,0	*53
	DC.B	"ASR",0,0,0,0,0	*54
	DC.B	"ROL",0,0,0,0,0	*55
	DC.B	"ROR",0,0,0,0,0	*56
	DC.B	"RTE",0,0,0,0,0	*57
	DC.B	"SCC",0,0,0,0,0	*58
	DC.B	"SCS",0,0,0,0,0	*59
	DC.B	"SEQ",0,0,0,0,0	*60
	DC.B	"SGE",0,0,0,0,0	*61
	DC.B	"SGT",0,0,0,0,0	*62
	DC.B	"SHI",0,0,0,0,0	*63
	DC.B	"SLE",0,0,0,0,0	*64
	DC.B	"SLS",0,0,0,0,0	*65
	DC.B	"SLT",0,0,0,0,0	*66
	DC.B	"SMI",0,0,0,0,0	*67
	DC.B	"SNE",0,0,0,0,0	*68
	DC.B	"SPL",0,0,0,0,0	*69
	DC.B	"SVC",0,0,0,0,0	*70
	DC.B	"SVS",0,0,0,0,0	*71
	DC.B	"SF",0,0,0,0,0,0	*72
	DC.B	"ST",0,0,0,0,0,0	*73
	DC.B	"SWAP",0,0,0,0	*74
	DC.B	"TAS",0,0,0,0,0	*75
	DC.B	"UNLK",0,0,0,0	*76
	DC.B	"LINK",0,0,0,0	*77
	DC.B	"EOR",0,0,0,0,0	*78
	DC.B	"EORI",0,0,0,0	*79
	DC.B	"MOVEP",0,0,0	*80
	DC.B	"ILLEGAL",0	*81
	DC.B	"XXX",0,0,0,0,0	*THERES NO CODE 1 FOR Bcc
	DC.B	"BHI",0,0,0,0,0	*83
	DC.B	"BLS",0,0,0,0,0	*84
	DC.B	"BCC",0,0,0,0,0	*85
	DC.B	"BCS",0,0,0,0,0	*86
	DC.B	"BVC",0,0,0,0,0	*87
	DC.B	"BVS",0,0,0,0,0	*88

***NOW THE REALLY OBSCURE INSTRUCTIONS THAT I NEVER USE!
	DC.B	"ABCD",0,0,0,0	*89
	DC.B	"ADDX",0,0,0,0	*90
	DC.B	"CHK",0,0,0,0,0	*91
	DC.B	"CMPM",0,0,0,0	*DIDNT EVEN KNOW THIS EXISTED!
	DC.B	"DBT",0,0,0,0,0	*93
	DC.B	"DBF",0,0,0,0,0	*DEFINED TWICE TO MAKE DECODING EASIER
	DC.B	"DBHI",0,0,0,0	*95
	DC.B	"DBLS",0,0,0,0	*96
	DC.B	"DBCC",0,0,0,0	*97
	DC.B	"DBCS",0,0,0,0	*98
	DC.B	"DBNE",0,0,0,0	*99
	DC.B	"DBEQ",0,0,0,0	*100
	DC.B	"DBVC",0,0,0,0	*101
	DC.B	"DBVS",0,0,0,0	*102
	DC.B	"DBPL",0,0,0,0	*103
	DC.B	"DBMI",0,0,0,0	*104
	DC.B	"DBGE",0,0,0,0	*105
	DC.B	"DBLT",0,0,0,0	*106
	DC.B	"DBGT",0,0,0,0	*107
	DC.B	"DBLE",0,0,0,0	*108
	DC.B	"NBCD",0,0,0,0	*109
	DC.B	"NEGX",0,0,0,0	*110
	DC.B	"RESET",0,0,0	*111
	DC.B	"ROXL",0,0,0,0	*112
	DC.B	"ROXR",0,0,0,0	*113
	DC.B	"RTR",0,0,0,0,0	*114
	DC.B	"SBCD",0,0,0,0	*115
	DC.B	"STOP",0,0,0,0	*116
	DC.B	"SUBX",0,0,0,0	*117
	DC.B	"TRAPV",0,0,0	*118
	DC.B	"MOVEA",0,0,0	*119
**NEW INSTRUCTIONS
	DC.B	"BFCHG",0,0,0	*120
	DC.B	"BFCLR",0,0,0
	DC.B	"BFSET",0,0,0	*122
	DC.B	"BFTST",0,0,0
	DC.B	"BFEXTS",0,0	*124
	DC.B	"BFEXTU",0,0
	DC.B	"BFFFO",0,0,0	*126
	DC.B	"BFINS",0,0,0	*127
	DC.B	"CAS",0,0,0,0,0	*128
	DC.B	"CAS2",0,0,0,0	*129
	DC.B	"CHK2",0,0,0,0	*130
	DC.B	"CMP2",0,0,0,0	*131
	DC.B	"EXTB",0,0,0,0	*132
	DC.B	"MOVE16",0,0	*133	040 ONLY
	DC.B	"TRAPT*",0,0	*134
	DC.B	"TRAPF*",0,0	
	DC.B	"TRAPHI",0,0	*136
	DC.B	"TRAPLS",0,0
	DC.B	"TRAPCC",0,0	*138
	DC.B	"TRAPCS",0,0	
	DC.B	"TRAPNE",0,0	*140
	DC.B	"TRAPEQ",0,0
	DC.B	"TRAPVC",0,0	*142
	DC.B	"TRAPVS",0,0
	DC.B	"TRAPPL",0,0	*144
	DC.B	"TRAPMI",0,0
	DC.B	"TRAPGE",0,0	*146
	DC.B	"TRAPLT",0,0
	DC.B	"TRAPGT",0,0	*148
	DC.B	"TRAPLE",0,0	*149
	DC.L	-1,-1	TERMINATOR
	align
	
	public	inst_table_lower
inst_table_lower:	dc.b	"move",0,0,0,0 	* 0
	dc.b	"bsr",0,0,0,0,0	* 1
	dc.b	"rts",0,0,0,0,0	* 2
	dc.b	"add",0,0,0,0,0	*12
	dc.b	"bra",0,0,0,0,0	* 3
	dc.b	"bne",0,0,0,0,0	* 4
	dc.b	"beq",0,0,0,0,0	* 5
	dc.b	"bge",0,0,0,0,0	* 6
	dc.b	"ble",0,0,0,0,0	* 7
	dc.b	"bgt",0,0,0,0,0	* 8
	dc.b	"blt",0,0,0,0,0	* 9
	dc.b	"bmi",0,0,0,0,0	*10
	dc.b	"bpl",0,0,0,0,0	*11

	dc.b	"adda",0,0,0,0	*13
	dc.b	"addi",0,0,0,0	*14
	dc.b	"addq",0,0,0,0	*15
	dc.b	"sub",0,0,0,0,0	*16
	dc.b	"suba",0,0,0,0	*17
	dc.b	"subi",0,0,0,0	*18
	dc.b	"subq",0,0,0,0	*19
	dc.b	"cmp",0,0,0,0,0	*20
	dc.b	"cmpa",0,0,0,0	*21
	dc.b	"cmpi",0,0,0,0	*22
	dc.b	"dbra",0,0,0,0	*23
	dc.b	"tst",0,0,0,0,0	*24
	dc.b	"dbf",0,0,0,0,0	*25
	dc.b	"ext",0,0,0,0,0	*26
	dc.b	"lea",0,0,0,0,0	*27
	dc.b	"movem",0,0,0	*28
	dc.b	"moveq",0,0,0	*29
	dc.b	"neg",0,0,0,0,0	*30
	dc.b	"trap",0,0,0,0	*31
	dc.b	"and",0,0,0,0,0	*32
****
	dc.b	"andi",0,0,0,0	*33
	dc.b	"bclr",0,0,0,0	*34
	dc.b	"bchg",0,0,0,0	*35
	dc.b	"bset",0,0,0,0	*36
	dc.b	"btst",0,0,0,0	*37
	dc.b	"clr",0,0,0,0,0	*38
	dc.b	"divs",0,0,0,0	*39
	dc.b	"divu",0,0,0,0	*40
	dc.b	"exg",0,0,0,0,0	*41
	dc.b	"jmp",0,0,0,0,0	*42
	dc.b	"jsr",0,0,0,0,0	*43
	dc.b	"lsl",0,0,0,0,0	*44
	dc.b	"lsr",0,0,0,0,0	*45
	dc.b	"muls",0,0,0,0	*46
	dc.b	"mulu",0,0,0,0	*47
	dc.b	"nop",0,0,0,0,0	*48
	dc.b	"not",0,0,0,0,0	*49
	dc.b	"or",0,0,0,0,0,0	*50
	dc.b	"ori",0,0,0,0,0	*51
	dc.b	"pea",0,0,0,0,0	*52
	dc.b	"asl",0,0,0,0,0	*53
	dc.b	"asr",0,0,0,0,0	*54
	dc.b	"rol",0,0,0,0,0	*55
	dc.b	"ror",0,0,0,0,0	*56
	dc.b	"rte",0,0,0,0,0	*57
	dc.b	"scc",0,0,0,0,0	*58
	dc.b	"scs",0,0,0,0,0	*59
	dc.b	"seq",0,0,0,0,0	*60
	dc.b	"sge",0,0,0,0,0	*61
	dc.b	"sgt",0,0,0,0,0	*62
	dc.b	"shi",0,0,0,0,0	*63
	dc.b	"sle",0,0,0,0,0	*64
	dc.b	"sls",0,0,0,0,0	*65
	dc.b	"slt",0,0,0,0,0	*66
	dc.b	"smi",0,0,0,0,0	*67
	dc.b	"sne",0,0,0,0,0	*68
	dc.b	"spl",0,0,0,0,0	*69
	dc.b	"svc",0,0,0,0,0	*70
	dc.b	"svs",0,0,0,0,0	*71
	dc.b	"sf",0,0,0,0,0,0	*72
	dc.b	"st",0,0,0,0,0,0	*73
	dc.b	"swap",0,0,0,0	*74
	dc.b	"tas",0,0,0,0,0	*75
	dc.b	"unlk",0,0,0,0	*76
	dc.b	"link",0,0,0,0	*77
	dc.b	"eor",0,0,0,0,0	*78
	dc.b	"eori",0,0,0,0	*79
	dc.b	"movep",0,0,0	*80
	dc.b	"illegal",0	*81
	dc.b	"xxx",0,0,0,0,0	*theres no code 1 for bcc
	dc.b	"bhi",0,0,0,0,0	*83
	dc.b	"bls",0,0,0,0,0	*84
	dc.b	"bcc",0,0,0,0,0	*85
	dc.b	"bcs",0,0,0,0,0	*86
	dc.b	"bvc",0,0,0,0,0	*87
	dc.b	"bvs",0,0,0,0,0	*88

***now the really obscure instructions that i never use!
	dc.b	"abcd",0,0,0,0	*89
	dc.b	"addx",0,0,0,0	*90
	dc.b	"chk",0,0,0,0,0	*91
	dc.b	"cmpm",0,0,0,0	*didnt even know this existed!
	dc.b	"dbt",0,0,0,0,0	*93
	dc.b	"dbf",0,0,0,0,0	*defined twice to make decoding easier
	dc.b	"dbhi",0,0,0,0	*95
	dc.b	"dbls",0,0,0,0	*96
	dc.b	"dbcc",0,0,0,0	*97
	dc.b	"dbcs",0,0,0,0	*98
	dc.b	"dbne",0,0,0,0	*99
	dc.b	"dbeq",0,0,0,0	*100
	dc.b	"dbvc",0,0,0,0	*101
	dc.b	"dbvs",0,0,0,0	*102
	dc.b	"dbpl",0,0,0,0	*103
	dc.b	"dbmi",0,0,0,0	*104
	dc.b	"dbge",0,0,0,0	*105
	dc.b	"dblt",0,0,0,0	*106
	dc.b	"dbgt",0,0,0,0	*107
	dc.b	"dble",0,0,0,0	*108
	dc.b	"nbcd",0,0,0,0	*109
	dc.b	"negx",0,0,0,0	*110
	dc.b	"reset",0,0,0	*111
	dc.b	"roxl",0,0,0,0	*112
	dc.b	"roxr",0,0,0,0	*113
	dc.b	"rtr",0,0,0,0,0	*114
	dc.b	"sbcd",0,0,0,0	*115
	dc.b	"stop",0,0,0,0	*116
	dc.b	"subx",0,0,0,0	*117
	dc.b	"trapv",0,0,0	*118
	dc.b	"movea",0,0,0	*119
**new instructions
	dc.b	"bfchg",0,0,0	*120
	dc.b	"bfclr",0,0,0
	dc.b	"bfset",0,0,0	*122
	dc.b	"bftst",0,0,0
	dc.b	"bfexts",0,0	*124
	dc.b	"bfextu",0,0
	dc.b	"bfffo",0,0,0	*126
	dc.b	"bfins",0,0,0	*127
	dc.b	"cas",0,0,0,0,0	*128
	dc.b	"cas2",0,0,0,0	*129
	dc.b	"chk2",0,0,0,0	*130
	dc.b	"cmp2",0,0,0,0	*131
	dc.b	"extb",0,0,0,0	*132
	dc.b	"move16",0,0	*133	040 only
	dc.b	"trapt*",0,0	*134
	dc.b	"trapf*",0,0	
	dc.b	"traphi",0,0	*136
	dc.b	"trapls",0,0
	dc.b	"trapcc",0,0	*138
	dc.b	"trapcs",0,0	
	dc.b	"trapne",0,0	*140
	dc.b	"trapeq",0,0
	dc.b	"trapvc",0,0	*142
	dc.b	"trapvs",0,0
	dc.b	"trappl",0,0	*144
	dc.b	"trapmi",0,0
	dc.b	"trapge",0,0	*146
	dc.b	"traplt",0,0
	dc.b	"trapgt",0,0	*148
	dc.b	"traple",0,0	*149
	dc.l	-1,-1	terminator
	align

	public	code_table
code_table:		DC.W	$0000 	*MOVE 0
	DC.W	$6100 	*BSR 1
	DC.W	$4E75 	*RTS 2
	DC.W	$D000 	ADD 12

	DC.W	$6000 	*BRA 3
	DC.W	$6600 	*BNE 4
	DC.W	$6700 	*BEQ 5
	DC.W	$6C00 	*BGE 6
	DC.W	$6F00 	*BLE 7
	DC.W	$6E00 	*BGT 8
	DC.W	$6D00 	*BLT 9
	DC.W	$6B00 	*BMI 10
	DC.W	$6A00 	*BPL 11
	DC.W	$D0C0 	ADDA 13
	DC.W	$0600 	ADDI 14
	DC.W	$5000 	ADDQ 15
	DC.W	$9000 	SUB 16
	DC.W	$90C0 	SUBA 17
	DC.W	$0400 	SUBI 18
	DC.W	$5100 	SUBQ 19
	DC.W	$B000 	CMP 20
	DC.W	$B0C0 	CMPA 21
	DC.W	$0B00 	CMPI 22
	DC.W	$51C8 	DBRA 23
	DC.W	$4A00 	TST 24
	DC.W	$51C8 	DBF 25 
	DC.W	$4800 	EXT 26
	DC.W	$41C0 	LEA 27
	DC.W	$4880 	MOVEM 28
	DC.W	$7000 	MOVEQ 29 
	DC.W	$4400 	NEG 30
	DC.W	$4E40 	TRAP 31
	DC.W	$C000 	AND 32
	DC.W	$0200 	ANDI 33
	DC.W	$0180 	BCLR 34
	DC.W	$0140 	BCHG 35
	DC.W	$01C0 	BSET 36
	DC.W	$0100 	BTST 37
	DC.W	$4200 	CLR 38
	DC.W	$81C0 	DIVS 39
	DC.W	$80C0 	DIVU 40
	DC.W	$C140 	EXG 41
	DC.W	$4EC0 	JMP 42
	DC.W	$4E80 	JSR 43
	DC.W	$E108 	LSL 44
	DC.W	$E008 	LSR 45
	DC.W	$C1C0 	MULS 46
	DC.W	$C0C0 	MULU 47
	DC.W	$4E71 	NOP 48
	DC.W	$4600 	NOT 49
	DC.W	$8000 	OR 50
	DC.W	$0000 	ORI 51
	DC.W	$4840 	PEA 52
	DC.W	$E100 	ASL 53
	DC.W	$E000 	ASR 54
	DC.W	$E118 	ROL 55
	DC.W	$E018 	ROR 56
	DC.W	$4E73 	RTE 57
	DC.W	$54C0 	SCC 58
	DC.W	$55C0 	SCS 59
	DC.W	$57C0 	SEQ 60
	DC.W	$5CC0 	SGE 61
	DC.W	$5EC0 	SGT 62
	DC.W	$52C0 	SHI 63
	DC.W	$5FC0 	SLE 64
	DC.W	$53C0 	SLS 65
	DC.W	$5DC0 	SLT 66
	DC.W	$5BC0 	SMI 67
	DC.W	$56C0 	SNE 68
	DC.W	$5AC0 	SPL 69
	DC.W	$58C0 	SVC 70
	DC.W	$59C0 	SVS 71
	DC.W	$51C0 	SF 72
	DC.W	$50C0 	ST 73
	DC.W	$4840 	SWAP 74
	DC.W	$4AC0 	TAS 75
	DC.W	$4E58 	UNLK 76
	DC.W	$4E50 	LINK 77
	DC.W	$B100 	EOR
	DC.W	$0A00 	EORI 79
	DC.W	$0108 	MOVEP
	DC.W	$4AFC 	ILLEGAL 81
	DC.W	$0000 	SPARE 82
	DC.W	$6200 	BHI 83
	DC.W	$6300 	BLS
	DC.W	$6400 	BCC
	DC.W	$6500 	BCS
	DC.W	$6800 	BVC
	DC.W	$6900 	BVS 88
 
****OBSCURE ONES
	DC.W	$C100 	ABCD 89
	DC.W	$D100 	ADDX
	DC.W	$4180 	CHK
	DC.W	$B108 	CMPM 92
	DC.W	$50C8 	DBT 93
	DC.W	$51C8 	DBF 94
	DC.W	$52C8 	DBHI 95
	DC.W	$53C8 	DBLS
	DC.W	$54C8 	DBCC
	DC.W	$55C8 	DBCS
	DC.W	$56C8 	DBNE
	DC.W	$57C8 	DBEQ 100
	DC.W	$58C8 	DBVC
	DC.W	$59C8 	DBVS
	DC.W	$5AC8 	DBPL
	DC.W	$5BC8 	DBMI
	DC.W	$5CC8 	DBGE 105
	DC.W	$5DC8 	DBLT
	DC.W	$5EC8 	DBGT
	DC.W	$5FC8 	DBLE
	DC.W	$4800 	NBCD
	DC.W	$4000 	NEGX 110
	DC.W	$4E70 	RESET
	DC.W	$E110 	ROXL
	DC.W	$E010 	ROXR
	DC.W	$4E77 	RTR
	DC.W	$8100 	SBCD
	DC.W	$4E72 	STOP
	DC.W	$9100 	SUBX
	DC.W	$4E76 	TRAPV
	DC.W	$0000 	MOVEA 119
	DC.W	$EAC0	BFCHG 120
	DC.W	$ECC0	BFCLR 121
	DC.W	$EEC0	BFSET 122
	DC.W	$E8C0	BFTST 123
	DC.W	$EBC0	BFEXTS 124
	DC.W	$E9C0	BFEXTU 125
	DC.W	$EDC0	BFFFO 126
	DC.W	$EFC0	BFINS 127
	DC.W	$08C0	CAS
	DC.W	$08FC	CAS2
	DC.W	$00C0	CHK2
	DC.W	$00C0	CMP2
	DC.W	$0000	EXTB.L
	DC.W	$F600	MOVE16	*040 ONLY
	DC.W	$50F8	TRAPT*
	DC.W	$51F8	TRAPF*
	DC.W	$52F8	TRAPHI
	DC.W	$53F8	TRAPLS
	DC.W	$54F8	TRAPCC
	DC.W	$55F8	TRAPCS
	DC.W	$56F8	TRAPNE
	DC.W	$57F8	TRAPEQ
	DC.W	$58F8	TRAPVC
	DC.W	$59F8	TRAPVS
	DC.W	$5AF8	TRAPPL
	DC.W	$5BF8	TRAPMI
	DC.W	$5CF8	TRAPGE
	DC.W	$5DF8	TRAPLT
	DC.W	$5EF8	TRAPGT
	DC.W	$5FF8	TRAPLE
	
	align