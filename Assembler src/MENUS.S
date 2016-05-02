ass_remote_entry:	 
	clr.w	test_flag(a5)	we really want o/p
	bsr	tx_opts
	bclr	#4,flags6(a5)	not build tx

	bsr	fant_entry
	bra.s	end_menus
end_menus:
	clr.l	d0
	rts

;null_string:	dc.b	0,0	
;ds_save:	ds.l	1	save for curdirstore
	global	ass_remote_entry
	extern	fant_entry,tx_opts
