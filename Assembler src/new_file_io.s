************************************************************
*Fantasm V3.20                                             *
*New_file_io.s                                             *
*SB 190895                                                 *
************************************************************
ioNameptr:	equ	18	*long
ioCompletion:	equ	12	*long
ioVrefnum:	equ	22	*word
ioFDirindex:	equ	28	*word
ioDirID:	equ	48	*long

	
**READ_FILE NEEDS A0->FILENAME
**	D0=VOLPTR
**	A0=FILENAME
**	LONGVAR(A5)->BUFFER ADDRESS

**Needs:
**a0->Fsspec
**longvar(a5)->Buffer address
**returns d0=-1 if bad or length

read_file:
;	clr.w	-(sp)
;	move.l	a0,-(sp)	fsspec
;	move.b	#2,-(sp)	permission
;	pea	refnum(pc)
;	move.w	#2,d0	opendf
;	dc.w	_highlevelFSdispatch	*Fspopendf
;	move.w	(sp)+,d0
	moveq	#1,d1
	lea	refnum(pc),a1
	OSFSpOpenDF	a0,d1,a1,d0	
	tst.w	d0
	beq.s	open_ok
	ext.l	d0
	rts
open_ok:	move.w	refnum(pc),d0
	move.w	d0,-(sp)
	move.l	#10000000,d0
	move.l	d0,-(sp)		*read all (well upto 10e6 anyway)
	move.l	long_var(a5),-(sp)	buffer
	bsr	fsread	returns size in d1
	lea	file_size(pc),a0
	move.l	d1,(a0)
	cmpi.w	#-39,d0
	beq.s	read_ok	eof
	tst.w	d0
	bge.s	read_ok	unusua
;	moveq.l	#-1,d0	error
	ext.l	d0
	rts
read_ok:
	move.w	refnum(pc),d0
	move.w	d0,-(sp)
	bsr	fsclose
	bsr	append_cr
	move.l	file_size(pc),d0
	rts_	"readfile"
	align	 
************************
*WRITE NEED:
*A0=FILE NAME
*A1=BUFFER TO WRITE
*DO=VOLPTR
*D1=LENGTH OF BUFFER
*SCRATCH_1(A5)=TYPE.L IE "TEXT" OR "APPL"

**Needs:
**a0->Fsspec
**a1->Buffer
**d1=size
**returns d0=-1 if bad or length
write_file:
	move.l	d1,d0	*Fant gives size in d1
	move.l	a0,d6
	move.l	d0,d7	copy size
	move.l	a1,long_var1(a5)
create_ent:	movem.l	d6/d7,-(sp)
;	clr.w	-(sp)
;	move.l	a0,-(sp)	fsspec
;	move.b	#2,-(sp)	permission
;	pea	refnum(pc)
;	move.w	#2,d0	opendf
;	dc.w	_highlevelFSdispatch
;	move.w	(sp)+,d0
	moveq.l	#2,d1	*perm
	lea	refnum(pc),a1
	OSFSpOpenDF	a0,d1,a1,d0
	movem.l	(sp)+,d6/d7
	tst.w	d0
	beq	openw_ok
	cmpi.w	#-43,d0
	beq.s	create_file
	ext.l	d0
	rts_	"CreatEnt"
	align
**file could not be opened
create_file:
	move.l	d7,-(sp)	save size

;	clr.w	-(sp)
;	move.l	d6,-(sp)	FSspec
;	move.l	#"PF40",-(sp)	creator
;	move.l	scratch_1(a5),-(sp)	type
;	clr.w	-(sp)	   roman script
;	move.w	#4,d0
;	dc.w	_highlevelFSdispatch
;	move.w	(sp)+,d0
	move.l	#"PF40",d1
	move.l	scratch_1(a5),d2
	clr.l	d3	*Script
	OSFSpCreate	d6,d1,d2,d3,d0
	move.l	(sp)+,d7	get size back
	move.w	#1,scratch_2(a5)	we created a file
	move.l	d6,a0		*set up fsspec
	tst.w	d0
	beq.s	got_data_fork
	ext.l	d0
	rts_	"Creatfil"
	align
got_data_fork:
**create res fork
;	clr.w	-(sp)
;	move.l	d6,-(sp)	*FSSpec
;	move.l	#"PF40",-(sp)
;	move.l	scratch_1(a5),-(sp)
;	clr.w	-(sp)
;	move.w	#$e,d0
;	dc.w	_highlevelFSdispatch
;	move.w	(sp)+,d0
	move.l	#"PF40",d1
	move.l	scratch_1(a5),d2
	clr.l	d3	*Script
	OSFSpCreateResFile	d6,d1,d2,d3,d0
	
	move.l	d6,a0
	tst.w	d0
	beq	create_ent	now open again
	ext.l	d0
	rts_	"Creatres"
	align
openw_ok:	move.w	refnum(pc),d0
	move.w	d0,-(sp)
	move.l	d7,scratch_3(a5)	save size
	move.l	d7,-(sp)	size
	move.l	long_var1(a5),-(sp)	buffer
	bsr	fswrite	ERROR IN D0
	tst.w	d0
	beq.s	write_ok
	ext.l	d0
	rts_	"Openw_ok"
	align
write_ok:	move.l	scratch_3(a5),d7
	move.l	d7,-(sp)
	move.w	refnum(pc),d0
	move.w	d0,-(sp)
	bsr	fsseteof
	tst.w	d0
	beq.s	set_eof_ok
	ext.l	d0
	rts_	"Write_ok"
	align
set_eof_ok:
	move.w	refnum(pc),d0
	move.w	d0,-(sp)
	bsr	fsclose	ERROR IN D0
	move.l	d6,-(sp)	FSSpec
	bsr	fsflushvol
	clr.l	d0
	rts_	"SeteofOk"
	align


append_cr:
**now find eof and insert a cr so assembler doesnt miss last line!
	move.l	file_size(pc),d1	*get size
	movea.l	long_var(a5),a0	*point to start of file
	add.l	d1,a0	*eof hopefully
	move.b	#13,(a0)+	*cr for last line
	clr.w	(a0)+	*terminate
	rts_	"appendcr"
	align
;open_folder:
;	 lea	 temp_pb(a5),a0
;	 clr.l	 iocompletion(a0)	 no completion routine
;	 lea	 6(a3),a1
;	 move.l	a1,ionameptr(a0)
;	 move.w	0(a3),iovrefnum(a0)
;	 move.l	2(a3),ioDirID(a0)
;	 clr.w	 iofdirindex(a0)
;	 move.w	#9,d0
;	 dc.w	 _HFSDispatch	 registered call
;	 tst.w	 d0
;	 beq.s	 got_folder
;	 moveq	 #-1,d0
;	 rts
;got_folder:
;**now change destination FSspec to the folders...
;;	  lea	  temp_pb(A5),a0
;	 lea	 sfreply(pc),a1	*For dest FSspec
;	 move.w	(a3),d0	*Vrefnum
;	 move.l	ioDirid(a0),d1	*new DirID
;	 lea	 6(a3),a0	 *name
;	 bsr	 Make_FSSpec
;	 lea	 sfreply(pc),a3	
;	 rts_	 "Find_backup_folder"
;
;sfreply:	 ds.b	 80
;null_string:	 dc.b	 0,0
;	 align	  
;**Get file date 3.20
;**Needs FSspec in a0
;get_file_date:
;	 move.l	a0,a1
;	 lea	 temp_pb(a5),a0
;	 clr.l	 iocompletion(a0)	 *no completion routine cause I'm hard
;	 lea	 6(a1),a3
;	 move.l	a3,ionameptr(a0)
;	 move.w	0(a1),iovrefnum(a0)
;	 move.l	2(a1),ioDirID(a0)
;	 clr.w	 iofdirindex(a0)
;	 move.w	#9,d0
;	 dc.w	 _HFSDispatch	 *Good old getcatinfo :-) !registered call
;	 tst.w	 d0
;	 beq.s	 got_file
;	 moveq	 #-1,d0
;	 rts
;got_file:
;	 lea	 temp_pb(a5),a0
;	 move.l	76(a0),d0	  
;	 rts_	 "Get_file_date"
;	 align	  
********************************************
***These routines emulate FSwrite etc from Pascal
********************************************
*struct FInfo {
*0    OSType fdType;                      /*the type of the file*/
*4    OSType fdCreator;                   /*file's creator*/
*8    unsigned short fdFlags;             /*flags ex. hasbundle,invisible,locked, etc.*/
*10    Point fdLocation;                   /*file's location in folder*/
*14    short fdFldr;                       /*folder containing file*/
*16};

**Takes a0->Fsspec,d0=creator,d1=type
;FSp_setinfo
;	 movem.l	d0-d1/a0,-(sp)	*save FSspec
;	 lea	 temp_Fs(pc),a1	*Where Finfo goes
;	 clr.w	 -(sp)
;	 move.l	a0,-(sp)	 *FSspec
;	 move.l	a1,-(sp)	 *where info to go
;	 move.w	#7,d0
;	 dc.w	 _highlevelFSdispatch
;	 move.w	(sp)+,d0
;
;	 movem.l	(sp)+,d0-d1/a0
;
;	 lea	 temp_FS(pc),a1
;	 move.l	d1,0(a1)	 *Set type
;	 move.l	d0,4(a1)	 *set creator
;	 clr.w	 -(sp)
;	 move.l	a0,-(sp)
;	 move.l	a1,-(sp)
;	 move.w	#8,d0
;	 dc.w	 _highlevelFSdispatch
;	 move.w	(sp)+,d0
;	 ext.l	 d0
;	 rts_	 "FSp_setinfo"
;
;temp_FS:	 ds.b	 82
;	 align
**NEW - Needs:
**a0->FSspec
**A1->Name of file
**Outputs
**Temp_Fsspec(a5)=new fsspec
make_temp_fsspec:
;	clr.w	-(sp)
;	move.w	0(a0),-(sp)	*Vrefnum
;	move.l	2(a0),-(sp)	*Dirid
;	move.l	a1,-(sp)	*name
;	pea	temp_FSspec(a5)	*where	  
;	moveq	#1,d0
;	dc.w	$aa52
;	move.w	(Sp)+,d0
	move.w	(a0),d0
	move.l	2(a0),d1
	lea	temp_fsspec(a5),a2
	OSMakeFSspec	d0,d1,a1,a2,d0
	ext.l	d0
	rts_	"Make_temp_Fsspec"
	
**needs Vrefnum in d0.w
**DirID in d1.l
**pointer to name in a0
**pointer to FSspec_record in a1
make_fsspec:	
;	clr.w	-(sp)
;	move.w	d0,-(sp)	vrefnum
;	move.l	d1,-(sp)	dirID
;	move.l	a0,-(sp)	name
;	move.l	a1,-(sp)	where
;	move.w	#1,d0
;	dc.w	$aa52
;	move.w	(sp)+,d0
	OSMakeFSspec	d0,d1,a0,a1,d0
	ext.l	d0
	rts_	"Make_FSspec"


**ERASE_F NEEDS A0=FILENAME, D0=VOLPTR.W, D1-DIRECTORY ID.L
**NEW needs a0->FSspec
erase_f:
	bsr.s	fspdelete
	rts_	"Erase_f "
	
fspdelete:
;	clr.w	-(sp)
;	move.l	a0,-(sp)
;	move.w	#6,d0
;	dc.w	_highlevelfsdispatch
;	move.w	(sp)+,d0
	OSFSpDelete	a0,d0
	ext.l	d0
	rts_	"fspdelete"


fsread:	move.l	(sp)+,d5	*get return address
	bsr	get_temp_pb	*a0->temp pb
	move.l	(sp)+,32(a0)	*buffer
	move.l	(sp)+,36(a0)	*size
	move.w	(sp)+,24(a0)	*refnum
	OSPBRead	a0,d0
;	DC.W	_READ
	lea	temp_pb(a5),a0
	move.l	40(a0),d1	*return size
	move.l	d5,a0
	jmp	(a0)	rts
	rts

fsgeteof:	move.l	(sp)+,a4	*get return address
	bsr	get_temp_pb	*a0->temp pb
	move.w	(sp)+,24(a0)	*refnum
	OSPBGetEOF	a0,d0
;	dc.w	_geteof
	lea	temp_pb(a5),a0
	move.l	28(a0),d0	*return size - phys end of data fork
	jmp	(a4)	rts
	rts_	"fsgeteof"
	align
fsseteof:	move.l	(sp)+,a4	get return address
	bsr	get_temp_pb	a0->temp pb
	lea	temp_pb(a5),a0
	move.w	(sp)+,24(a0)	refnum
	move.l	(sp)+,28(a0)	eof here
	OSPBSetEOF	a0,d0
;	dc.w	_seteof
	jmp	(a4)	rts
	rts_	"fsseteof"
	align

fsflushvol:
	move.l	(sp)+,d5	get return address
	bsr.s	get_temp_pb	a0->temp pb
	move.l	(sp)+,a1	vrefnum
	move.w	(a1),24(a0)
	OSPBFlushVol	a0,d0
;	dc.w	_flushvol
	move.l	d5,a0	 
	jmp	(a0)	rts
	rts_	"flushvol"
	align
	rts	
fswrite:	move.l	(sp)+,d5	get return address
	bsr.s	get_temp_pb	a0->temp pb
	move.l	(sp)+,32(a0)	buffer
	move.l	(sp)+,36(a0)	size
	move.w	(sp)+,24(a0)	refnum
	move.w	#65,44(a0)	posmode from start of file and write/read verify on
	OSPBWrite	a0,d0
;	dc.w	_write
	move.l	d5,a0
	jmp	(a0)	rts
	rts_	"fswrite "
	align
	
fsclose:	move.l	(sp)+,d5	get return address
	bsr.s	get_temp_pb	a0->temp pb
	lea	temp_pb(a5),a0
	move.w	(sp)+,24(a0)	refnum
	OSPBClose	a0,d0
;	dc.w	_close
	move.l	d5,a0
	jmp	(a0)	rts
	rts_	"fsclose "
	align

get_temp_pb:
	lea	temp_pb(a5),a0
	move.l	#200/4-1,d0
ctp:	clr.l	(a0)+
	dbra	d0,ctp
	lea	temp_pb(a5),a0
	rts_	"get_temp_pb"
	align
copy_fsspec:
	moveq	#19,d1
cfl:	move.l	(a0)+,(a1)+
	dbra	d1,cfl
	rts_	"copy_fss"
	align	     
untitled:	dc.b	8,"Untitled"
	align
refnum:	dc.w	1	*Sys 7 refnum from opendf
file_size:	ds.l	1	*temp for file size

	global	read_file,write_file
	global	erase_f,get_temp_pb
;	global	save_prefs,save_prefs_name
;	global	read_global_prefs,read_prefs,save_master_prefs
	global	make_fsspec,make_temp_fsspec
;	global	fsp_setinfo
	extern	set_up_fname,set_up_pname,do_checks
	extern	set_up_prefname,get_time,disable_810
