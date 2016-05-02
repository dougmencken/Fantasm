**new for F320
**needs error in d0
report_disk_error:
	qmove.l	d0,-(sp)	save error
	lea	mac(pc),a0
	bsr.l	printit
	qmove.l	(sp),d0
	ext.l	d0
	bsr.l	printnum_signed
	lea	trans(pc),a0
	bsr.l	printit
	qmove.l	(sp)+,d0
	cmpi.w	#$ffd4,d0
	bne.s	not_locked
	lea	locked_text(pc),a0
	bsr.l	printit
	bra.s	done
not_locked:
	cmpi.w	#-34,d0
	bne.s	not_full
	lea	full_text(pc),a0
	bsr.l	printit
	bra.s	done
not_full:
	cmpi.w	#-46,d0
	bne.s	unknown
	lea	slocked(pc),a0
	bsr.l	printit
	bra.s	done
unknown:
	lea	unknown_error(pc),a0
	bsr.l	printit
done:
	lea	stopped_text(pc),a0
	bsr.l	printit
	moveq	#-1,d0
	rts_		"RepDiErr"
	even
**data
mac:	dc.b	"MacOS error: ",0
trans:	dc.b	13,"Translation: ",0
locked_text:	dc.b	"Can't write file because the disk is locked.",13,0
	even
unknown_error:	 dc.b	 "Can't write file because of an unknown I/O error.",13,0
	even
full_text:	dc.b	"Can't write file because there is not enough space on the disk.",13,0
	even
slocked:	dc.b	"Can't write file because disk is software locked.",13,0
	even
stopped_text:	 dc.b	 "***Assembly halted.***",13,13,0
	even
	global	report_disk_error	 
	extern	printit,printnum_signed