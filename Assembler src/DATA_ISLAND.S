**THIS FILE IS A DATA ISLAND
	nop
ppc_reserved_table:	dc.b	"lt",0	*equates to 0
	dc.b	"gt",0	*1
	dc.b	"eq",0	*2
	dc.b	"so",0	*3
	dc.b	"un",0	*3
	dc.b	"cr0",0	*0
	dc.b	"cr1",0	*1
	dc.b	"cr2",0
	dc.b	"cr3",0
	dc.b	"cr4",0
	dc.b	"cr5",0
	dc.b	"cr6",0
	dc.b	"cr7",0	*7
	dc.b	"life",0	*42
	dc.b	"true",0	*-1
	dc.b	"false",0	*0

	DC.B	"LT",0
	DC.B	"GT",0
	DC.B	"EQ",0
	DC.B	"SO",0
	DC.B	"UN",0
	DC.B	"CR0",0
	DC.B	"CR1",0
	DC.B	"CR2",0
	DC.B	"CR3",0
	DC.B	"CR4",0
	DC.B	"CR5",0
	DC.B	"CR6",0
	DC.B	"CR7",0
	DC.B	"LIFE",0	*42
	DC.B	"TRUE",0
	DC.B	"FALSE",0
	dc.b	0,0,0,0
	align
reserved_values:	dc.b	0,1,2,3,3,0,1,2,3,4,5,6,7,42,-1,0	*values of ppc reserved labs
	dc.b	0,1,2,3,3,0,1,2,3,4,5,6,7,42,-1,0
	align
	
link_title:	DC.B	"Unspecified"
	ds.b	390	*Was 389
	
input:	dc.b	"Unspecified"
	ds.b	313	*was 313	*v4b16e
output:	dc.b	"Unspecified"
	ds.b	289	300
	

	align
	global	link_title,input,output,ppc_reserved_table,reserved_values