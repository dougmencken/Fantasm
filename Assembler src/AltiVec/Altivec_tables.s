**These tables handle all instructions starting with v
**ppc vector processor tables
	if	68k
ppc_vector_jumptable:
	else
ppc_vector_jumptable:	toc_routine
	endif
	bsr.l	do_vaddcuw	*vaddcuw
	extern	do_vaddcuw
	rts44
	bsr.l	do_vaddcuw	*vaddfp
	rts44
	bsr.l	do_vaddcuw	*vaddsbs
	rts44
	bsr.l	do_vaddcuw	*vaddshs
	rts44
	bsr.l	do_vaddcuw	*vaddsws
	rts44
	bsr.l	do_vaddcuw	*vaddubm
	rts44
	bsr.l	do_vaddcuw	*vaddubs
	rts44
	bsr.l	do_vaddcuw	*vadduhm
	rts44
	bsr.l	do_vaddcuw	*vadduhs
	rts44
	bsr.l	do_vaddcuw	*vadduwm
	rts44
	bsr.l	do_vaddcuw	*vadduws
	rts44
	bsr.l	do_vaddcuw	*vand
	rts44
	bsr.l	do_vaddcuw	*vandc
	rts44
	bsr.l	do_vaddcuw	*vavgsb
	rts44
	bsr.l	do_vaddcuw	*vavgsh
	rts44
	bsr.l	do_vaddcuw	*vavgsw
	rts44
	bsr.l	do_vaddcuw	*vavgub
	rts44
	bsr.l	do_vaddcuw	*vavguh
	rts44
	bsr.l	do_vaddcuw	*vavguw
	rts44

	bsr.l	do_vaddcuw	*vmaxfp
	rts44
	bsr.l	do_vaddcuw	*vmaxsb
	rts44
	bsr.l	do_vaddcuw	*vmaxsh
	rts44
	bsr.l	do_vaddcuw	*vmaxsw
	rts44
	bsr.l	do_vaddcuw	*vmaxub
	rts44
	bsr.l	do_vaddcuw	*vmaxuh
	rts44
	bsr.l	do_vaddcuw	*vmaxuw
	rts44

	bsr.l	do_vaddcuw	*vminfp
	rts44
	bsr.l	do_vaddcuw	*vminsb
	rts44
	bsr.l	do_vaddcuw	*vminsh
	rts44
	bsr.l	do_vaddcuw	*vminsw
	rts44
	bsr.l	do_vaddcuw	*vminub
	rts44
	bsr.l	do_vaddcuw	*vminuh
	rts44
	bsr.l	do_vaddcuw	*vminuw
	rts44

	bsr.l	do_vaddcuw	*vmrghb
	rts44
	bsr.l	do_vaddcuw	*vmrghh
	rts44
	bsr.l	do_vaddcuw	*vmrghw
	rts44
	bsr.l	do_vaddcuw	*vmrglb
	rts44
	bsr.l	do_vaddcuw	*vmrglh
	rts44
	bsr.l	do_vaddcuw	*vmrglw
	rts44

	bsr.l	do_vaddcuw	*vmulesb
	rts44
	bsr.l	do_vaddcuw	*vmulesh
	rts44
	bsr.l	do_vaddcuw	*vmuleub
	rts44
	bsr.l	do_vaddcuw	*vmuleuh
	rts44
	bsr.l	do_vaddcuw	*vmulosb
	rts44
	bsr.l	do_vaddcuw	*vmulosh
	rts44
	bsr.l	do_vaddcuw	*vmuloub
	rts44
	bsr.l	do_vaddcuw	*vmulouh
	rts44

	bsr.l	do_vaddcuw	*vpkshss
	rts44
	bsr.l	do_vaddcuw	*vpkshus
	rts44
	bsr.l	do_vaddcuw	*vpkswss
	rts44
	bsr.l	do_vaddcuw	*vpkuhum
	rts44
	bsr.l	do_vaddcuw	*vpkuhus
	rts44
	bsr.l	do_vaddcuw	*vpkuwum
	rts44
	bsr.l	do_vaddcuw	*vpkuwus
	rts44

	bsr.l	do_vaddcuw	*vrlb
	rts44
	bsr.l	do_vaddcuw	*vrlh
	rts44
	bsr.l	do_vaddcuw	*vrlw
	rts44

	bsr.l	do_vaddcuw	*vsl
	rts44
	bsr.l	do_vaddcuw	*vslb
	rts44
	bsr.l	do_vaddcuw	*vslh
	rts44
	bsr.l	do_vaddcuw	*vslo
	rts44
	bsr.l	do_vaddcuw	*vslw
	rts44


	bsr.l	do_vaddcuw	*vsr
	rts44
	bsr.l	do_vaddcuw	*vsrab
	rts44
	bsr.l	do_vaddcuw	*vsrah
	rts44
	bsr.l	do_vaddcuw	*vsraw
	rts44
	bsr.l	do_vaddcuw	*vsrb
	rts44
	bsr.l	do_vaddcuw	*vsrh
	rts44
	bsr.l	do_vaddcuw	*vsro
	rts44
	bsr.l	do_vaddcuw	*vsrw
	rts44
	bsr.l	do_vaddcuw	*vsubcuw
	rts44
	bsr.l	do_vaddcuw	*vsubfp
	rts44
	bsr.l	do_vaddcuw	*vsubsbs
	rts44
	bsr.l	do_vaddcuw	*vsubshs
	rts44
	bsr.l	do_vaddcuw	*vsubsws
	rts44
	bsr.l	do_vaddcuw	*vsububm
	rts44

	bsr.l	do_vbasic_dot4	 *vcmpbfpx
	extern	do_vbasic_dot4
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpbfp (same as above)
	rts44

	bsr.l	do_vbasic_dot4	 *vcmpeqfx[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpeqf[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpeqfp[.]
	rts44

	bsr.l	do_vbasic_dot4	 *vcmpequb[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpequbx[.]
	rts44

	bsr.l	do_vbasic_dot4	 *vcmpequh[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpequhx[.]
	rts44

	bsr.l	do_vbasic_dot4	 *vcmpequw[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpequwx[.]
	rts44

	bsr.l	do_vbasic_dot4	 *vcmpgefp[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpgefpx[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpgtfp[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpgtsb[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpgtsh[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpgtsw[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpgtub[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpgtuh[.]
	rts44
	bsr.l	do_vbasic_dot4	 *vcmpgtuw[.]
	rts44

**unsigned integer operands
	bsr.l	do_vbasic_im	*vcfsx
	rts44
	extern	do_vbasic_im
	bsr.l	do_vbasic_im	*vcfux
	rts44
	bsr.l	do_vbasic_im	*vctsxs
	rts44
	bsr.l	do_vbasic_im	*vctuxs
	rts44

	bsr.l	do_vbasic_im	*vspltb
	rts44
	bsr.l	do_vbasic_im	*vsplth
	rts44
	bsr.l	do_vbasic_im	*vspltw
	rts44

	bsr.l	do_vaddcuw	*vnor
	rts44
	bsr.l	do_vaddcuw	*vor
	rts44

	bsr.l	do_vect4	*vmsummbm
	extern	do_vect4
	rts44
	bsr.l	do_vect4	*vmsumshm
	rts44
	bsr.l	do_vect4	*vmsumshs
	rts44
	bsr.l	do_vect4	*vmsumubm
	rts44
	bsr.l	do_vect4	*vmsumuhm
	rts44
	bsr.l	do_vect4	*vmsumuhs
	rts44
	bsr.l	do_vect4	*vnmsubfp
	rts44
	bsr.l	do_vect4	*vperm
	rts44

	bsr.l	do_vect4	*vmhaddshs
	rts44
	bsr.l	do_vect4	*vmhraddshs
	rts44
	bsr.l	do_vect4	*vmaddfp
	rts44
	bsr.l	do_vect4	*vmladduhm
	rts44
	bsr.l	do_vect4	*vsel
	rts44

	bsr.l	do_vect2	*vexptefp
	extern	do_vect2
	rts44
	bsr.l	do_vect2	*vlogefp
	rts44

	bsr.l	do_vect2	*vrfip
	rts44
	bsr.l	do_vect2	*vrfiz
	rts44
	bsr.l	do_vect2	*vrsqrtefp
	rts44
	bsr.l	do_vect2	*vrefp
	rts44
	bsr.l	do_vect2	*vrfim
	rts44
	bsr.l	do_vect2	*vrfin
	rts44

	bsr.l	do_vaddcuw	*vpkpx
	rts44

	bsr.l	do_v_sim	*vspltisb
	extern	do_v_sim
	rts44
	bsr.l	do_v_sim	*vspltish
	rts44
	bsr.l	do_v_sim	*vspltisw
	rts44
	bsr.l	do_vsl	*vsldoi
	extern	do_vsl
	rts44
	
	bsr.l	do_vaddcuw	*vsubuhm
	rts44
	bsr.l	do_vaddcuw	*sububs
	rts44
	bsr.l	do_vaddcuw	*vsubuhs
	rts44
	bsr.l	do_vaddcuw	*vsubuwm
	rts44
	bsr.l	do_vaddcuw	*vsubuws
	rts44
	bsr.l	do_vaddcuw	*vsumsws
	rts44
	bsr.l	do_vaddcuw	*vsum2sws
	rts44
	bsr.l	do_vaddcuw	*vsum4sbs
	rts44
	bsr.l	do_vaddcuw	*vsum4shs
	rts44
	bsr.l	do_vaddcuw	*vsum4ubs
	rts44


	bsr.l	do_vect2	*vupkhpx
	rts44
	bsr.l	do_vect2	*vupkhsb
	rts44
	bsr.l	do_vect2	*vupkhsh
	rts44
	bsr.l	do_vect2	*vupklpx
	rts44
	bsr.l	do_vect2	*vupklsb
	rts44
	bsr.l	do_vect2	*vupklsh
	rts44

	bsr.l	do_vaddcuw	*vxor
	rts44

**each entry is 12 bytes
ppc_vector_string_table:	dc.b	"vaddcuw",0,0,0,0,0
	dc.b	"vaddfp",0,0,0,0,0,0
	dc.b	"vaddsbs",0,0,0,0,0
	dc.b	"vaddshs",0,0,0,0,0
	dc.b	"vaddsws",0,0,0,0,0
	dc.b	"vaddubm",0,0,0,0,0
	dc.b	"vaddubs",0,0,0,0,0
	dc.b	"vadduhm",0,0,0,0,0
	dc.b	"vadduhs",0,0,0,0,0
	dc.b	"vadduwm",0,0,0,0,0
	dc.b	"vadduws",0,0,0,0,0
	
	dc.b	"vand",0,0,0,0,0,0,0,0
	dc.b	"vandc",0,0,0,0,0,0,0
	dc.b	"vavgsb",0,0,0,0,0,0
	dc.b	"vavgsh",0,0,0,0,0,0
	dc.b	"vavgsw",0,0,0,0,0,0
	dc.b	"vavgub",0,0,0,0,0,0
	dc.b	"vavguh",0,0,0,0,0,0
	dc.b	"vavguw",0,0,0,0,0,0
	
	dc.b	"vmaxfp",0,0,0,0,0,0
	dc.b	"vmaxsb",0,0,0,0,0,0
	dc.b	"vmaxsh",0,0,0,0,0,0
	dc.b	"vmaxsw",0,0,0,0,0,0
	dc.b	"vmaxub",0,0,0,0,0,0
	dc.b	"vmaxuh",0,0,0,0,0,0
	dc.b	"vmaxuw",0,0,0,0,0,0

	dc.b	"vminfp",0,0,0,0,0,0
	dc.b	"vminsb",0,0,0,0,0,0
	dc.b	"vminsh",0,0,0,0,0,0
	dc.b	"vminsw",0,0,0,0,0,0
	dc.b	"vminub",0,0,0,0,0,0
	dc.b	"vminuh",0,0,0,0,0,0
	dc.b	"vminuw",0,0,0,0,0,0

	dc.b	"vmrghb",0,0,0,0,0,0
	dc.b	"vmrghh",0,0,0,0,0,0
	dc.b	"vmrghw",0,0,0,0,0,0
	dc.b	"vmrglb",0,0,0,0,0,0
	dc.b	"vmrglh",0,0,0,0,0,0
	dc.b	"vmrglw",0,0,0,0,0,0

	dc.b	"vmulesb",0,0,0,0,0
	dc.b	"vmulesh",0,0,0,0,0
	dc.b	"vmuleub",0,0,0,0,0
	dc.b	"vmuleuh",0,0,0,0,0
	dc.b	"vmulosb",0,0,0,0,0
	dc.b	"vmulosh",0,0,0,0,0
	dc.b	"vmuloub",0,0,0,0,0
	dc.b	"vmulouh",0,0,0,0,0

	dc.b	"vpkshss",0,0,0,0,0
	dc.b	"vpkshus",0,0,0,0,0
	dc.b	"vpkswss",0,0,0,0,0
	dc.b	"vpkuhum",0,0,0,0,0
	dc.b	"vpkuhus",0,0,0,0,0
	dc.b	"vpkuwum",0,0,0,0,0
	dc.b	"vpkuwus",0,0,0,0,0

	dc.b	"vrlb",0,0,0,0,0,0,0,0
	dc.b	"vrlh",0,0,0,0,0,0,0,0
	dc.b	"vrlw",0,0,0,0,0,0,0,0

	dc.b	"vsl",0,0,0,0,0,0,0,0,0
	dc.b	"vslb",0,0,0,0,0,0,0,0
	dc.b	"vslh",0,0,0,0,0,0,0,0
	dc.b	"vslo",0,0,0,0,0,0,0,0
	dc.b	"vslw",0,0,0,0,0,0,0,0

	dc.b	"vsr",0,0,0,0,0,0,0,0,0
	dc.b	"vsrab",0,0,0,0,0,0,0
	dc.b	"vsrah",0,0,0,0,0,0,0
	dc.b	"vsraw",0,0,0,0,0,0,0
	dc.b	"vsrb",0,0,0,0,0,0,0,0
	dc.b	"vsrh",0,0,0,0,0,0,0,0
	dc.b	"vsro",0,0,0,0,0,0,0,0
	dc.b	"vsrw",0,0,0,0,0,0,0,0
	dc.b	"vsubcuw",0,0,0,0,0
	dc.b	"vsubfp",0,0,0,0,0,0
	dc.b	"vsubsbs",0,0,0,0,0
	dc.b	"vsubshs",0,0,0,0,0
	dc.b	"vsubsws",0,0,0,0,0
	dc.b	"vsububm",0,0,0,0,0

	dc.b	"vcmpbfp",0,0,0,0,0
	dc.b	"vcmpbfpx",0,0,0,0	*we do both cause it's confusing whether the x is necessary
	dc.b	"vcmpeqf",0,0,0,0,0
	dc.b	"vcmpeqfp",0,0,0,0
	dc.b	"vcmpeqfx",0,0,0,0
	dc.b	"vcmpequb",0,0,0,0
	dc.b	"vcmpequbx",0,0,0
	dc.b	"vcmpequh",0,0,0,0
	dc.b	"vcmpequhx",0,0,0
	dc.b	"vcmpequw",0,0,0,0
	dc.b	"vcmpequwx",0,0,0
	dc.b	"vcmpgefp",0,0,0,0
	dc.b	"vcmpgefpx",0,0,0
	dc.b	"vcmpgtfp",0,0,0,0
	dc.b	"vcmpgtsb",0,0,0,0
	dc.b	"vcmpgtsh",0,0,0,0
	dc.b	"vcmpgtsw",0,0,0,0
	dc.b	"vcmpgtub",0,0,0,0
	dc.b	"vcmpgtuh",0,0,0,0
	dc.b	"vcmpgtuw",0,0,0,0


	dc.b	"vcfsx",0,0,0,0,0,0,0
	dc.b	"vcfux",0,0,0,0,0,0,0
	dc.b	"vctsxs",0,0,0,0,0,0
	dc.b	"vctuxs",0,0,0,0,0,0
	dc.b	"vspltb",0,0,0,0,0,0
	dc.b	"vsplth",0,0,0,0,0,0
	dc.b	"vspltw",0,0,0,0,0,0
	dc.b	"vnor",0,0,0,0,0,0,0,0
	dc.b	"vor",0,0,0,0,0,0,0,0,0
	dc.b	"vmsummbm",0,0,0,0
	dc.b	"vmsumshm",0,0,0,0
	dc.b	"vmsumshs",0,0,0,0
	dc.b	"vmsumubm",0,0,0,0
	dc.b	"vmsumuhm",0,0,0,0
	dc.b	"vmsumuhs",0,0,0,0
	dc.b	"vnmsubfp",0,0,0,0
	dc.b	"vperm",0,0,0,0,0,0,0
	
	dc.b	"vmhaddshs",0,0,0
	dc.b	"vmhraddshs",0,0
	dc.b	"vmaddfp",0,0,0,0,0
	
	dc.b	"vmladduhm",0,0,0
	dc.b	"vsel",0,0,0,0,0,0,0,0
	dc.b	"vexptefp",0,0,0,0
	dc.b	"vlogefp",0,0,0,0,0
	
	dc.b	"vrfip",0,0,0,0,0,0,0
	dc.b	"vrfiz",0,0,0,0,0,0,0
	dc.b	"vrsqrtefp",0,0,0
	dc.b	"vrefp",0,0,0,0,0,0,0
	dc.b	"vrfim",0,0,0,0,0,0,0
	dc.b	"vrfin",0,0,0,0,0,0,0
	dc.b	"vpkpx",0,0,0,0,0,0,0
	dc.b	"vspltisb",0,0,0,0
	dc.b	"vspltish",0,0,0,0
	dc.b	"vspltisw",0,0,0,0
	dc.b	"vsldoi",0,0,0,0,0,0

	dc.b	"vsubuhm",0,0,0,0,0
	dc.b	"vsububs",0,0,0,0,0
	dc.b	"vsubuhs",0,0,0,0,0
	dc.b	"vsubuwm",0,0,0,0,0
	dc.b	"vsubuws",0,0,0,0,0
	dc.b	"vsumsws",0,0,0,0,0
	
	dc.b	"vsum2sws",0,0,0,0
	dc.b	"vsum4sbs",0,0,0,0
	dc.b	"vsum4shs",0,0,0,0
	dc.b	"vsum4ubs",0,0,0,0
	dc.b	"vupkhpx",0,0,0,0,0
	dc.b	"vupkhsb",0,0,0,0,0
	dc.b	"vupkhsh",0,0,0,0,0
	dc.b	"vupklpx",0,0,0,0,0
	dc.b	"vupklsb",0,0,0,0,0
	dc.b	"vupklsh",0,0,0,0,0
	dc.b	"vxor",0,0,0,0,0,0,0,0
	dc.l	-1,-1,-1

ppc_vector_code_table:	dc.l	$10000180	*vaddcuw
	dc.l	$1000000a	*vaddfp
	dc.l	$10000300	*vaddsbs
	dc.l	$10000340	*vaddshs
	dc.l	$10000380	*vaddsws
	dc.l	$10000000	*vaddubm
	dc.l	$10000200	*vaddubs
	dc.l	$10000040	*vadduhm
	dc.l	$10000240	*vadduhs
	dc.l	$10000080	*vadduwm
	dc.l	$10000280	*vadduws
	dc.l	$10000404	*vand
	dc.l	$10000444	*vandc
	dc.l	$10000502	*vavgsb
	dc.l	$10000542	*vavgsh
	dc.l	$10000582	*vavgsw
	dc.l	$10000402	*vavgub
	dc.l	$10000442	*vavguh
	dc.l	$10000482	*vavguw

	dc.l	$1000040a	*vmaxfp
	dc.l	$10000102	*vmaxsb
	dc.l	$10000142	*vmaxsh
	dc.l	$10000182	*vmaxsw
	dc.l	$10000002	*vmaxub
	dc.l	$10000042	*vmaxuh
	dc.l	$10000082	*vmaxuw
	
	dc.l	$1000044a	*vminfp
	dc.l	$10000302	*vminsb
	dc.l	$10000342	*vminsh
	dc.l	$10000382	*vminsw
	dc.l	$10000202	*vminub
	dc.l	$10000242	*vminuh
	dc.l	$10000282	*vminuw

	dc.l	$1000000c	*vmrghb
	dc.l	$1000004c	*vmrghh
	dc.l	$1000008c	*vmrghw
	dc.l	$1000010c	*vmrglb
	dc.l	$1000014c	*vmrglh
	dc.l	$1000018c	*vmrglw

	dc.l	$10000308	*vmulesb
	dc.l	$10000348	*vmulesh
	dc.l	$10000208	*vmuleub
	dc.l	$10000248	*vmuleuh
	dc.l	$10000108	*vmulosb
	dc.l	$10000148	*vmulosh
	dc.l	$10000008	*vmuloub
	dc.l	$10000048	*vmulouh

	dc.l	$1000018e	*vpkshss
	dc.l	$1000010e	*vpkshus
	dc.l	$100001ce	*vpkswss
	dc.l	$1000000e	*vpkuhum
	dc.l	$1000008e	*vpkuhus
	dc.l	$1000004e	*vpkuwum
	dc.l	$100000ce	*vpkusus

	dc.l	$10000004	*vrlb
	dc.l	$10000044	*vrlh
	dc.l	$10000084	*vrlw

	dc.l	$100001c4	*vsl
	dc.l	$10000104	*vslb
	dc.l	$10000144	*vslh
	dc.l	$1000040c	*vslo
	dc.l	$10000184	*vslw

	dc.l	$100002c4	*vsr
	dc.l	$10000304	*vsrab
	dc.l	$10000344	*vsrah
	dc.l	$10000384	*vsraw
	dc.l	$10000204	*vsrb
	dc.l	$10000244	*vsrh
	dc.l	$1000044c	*vsro
	dc.l	$10000284	*vsrw
	dc.l	$10000580	*vsubcuw
	dc.l	$1000004a	*vsubfp
	dc.l	$10000700	*vsubsbs
	dc.l	$10000740	*vsubshs
	dc.l	$10000780	*vsubsws
	dc.l	$10000400	*vsububm
	
	dc.l	$100003c6	*vcmpbfp[.]	*vbasic_dot
	dc.l	$100003c6	*vcmpbfpx[.]	*vbasic_dot
	dc.l	$100000c6	*vcmpeqf[.]	*vbasic_dot
	dc.l	$100000c6	*vcmpeqfp[.]	*vbasic_dot
	dc.l	$100000c6	*vcmpeqfx[.]	*vbasic_dot
	dc.l	$10000006	*vcmpequb[.]	*vbasic_dot
	dc.l	$10000006	*vcmpequbx[.]	*vbasic_dot
	dc.l	$10000046	*vcmpequh[.]	*vbasic_dot
	dc.l	$10000046	*vcmpequhx[.]	*vbasic_dot
	dc.l	$10000086	*vcmpequw[.]	*vbasic_dot
	dc.l	$10000086	*vcmpequwx[.]	*vbasic_dot
	dc.l	$100001c6	*vcmpgefp[.]	*vbasic_dot
	dc.l	$100001c6	*vcmpgefpx[.]	*vbasic_dot
	dc.l	$100002c6	*vcmpgtfp[.]	*vbasic_dot
	dc.l	$10000306	*vcmpgtsb[.]	*vbasic_dot
	dc.l	$10000346	*vcmpgtsh[.]	*vbasic_dot
	dc.l	$10000386	*vcmpgtsw[.]	*vbasic_dot
	dc.l	$10000206	*vcmpgtub[.]	*vbasic_dot
	dc.l	$10000246	*vcmpgtuh[.]	*vbasic_dot
	dc.l	$10000286	*vcmpgtuw[.]	*vbasic_dot
	
	dc.l	$1000034a	*vcfsx
	dc.l	$1000030a	*vcfux
	dc.l	$100003ca	*vctsxs
	dc.l	$1000038a	*vctuxs

	dc.l	$1000020c	*vspltb
	dc.l	$1000024c	*vsplth
	dc.l	$1000028c	*vspltw

	dc.l	$10000504	*vnor
	dc.l	$10000484	*vor
	
	dc.l	$10000025	*vmsummbm
	dc.l	$10000028	*vmsumshm
	dc.l	$10000029	*vmsumshs
	dc.l	$10000024	*vmsumubm
	dc.l	$10000026	*vmsumuhm
	dc.l	$10000027	*vmsumuhs
	
	dc.l	$1000002f	*vnmsubfp
	dc.l	$1000002b	*vperm
	
	dc.l	$10000020	*vmhaddshs
	dc.l	$10000021	*vmhraddshs
	dc.l	$1000002e	*vmaddfp
	
	dc.l	$10000022	*vmladduhm
	dc.l	$1000002a	*vsel
	
	dc.l	$1000018a	*vexptefp
	dc.l	$100001ca	*vlogefp
	dc.l	$1000028a	*vrfip
	dc.l	$1000024a	*vrfiz
	dc.l	$1000014a	*vrsqrtefp

	dc.l	$1000010a	*vrefp
	dc.l	$100002ca	*vrfim
	dc.l	$1000020a	*vrfin
	
	dc.l	$1000030e	*vpkpx
	
	dc.l	$1000030c	*vspltisb
	dc.l	$1000034c	*vspltish
	dc.l	$1000038c	*vspltisw	
	
	dc.l	$1000002c	*vsldoi
	
	dc.l	$10000440	*vsubuhm
	dc.l	$10000600	*vsububs
	dc.l	$10000640	*vsubuhs
	dc.l	$10000480	*vsubuwm
	dc.l	$10000680	*vsubuws
	dc.l	$10000788	*vsumsws
	dc.l	$10000688	*vsum2sws
	dc.l	$10000708	*vsum4sbs
	dc.l	$10000648	*vsum4shs
	dc.l	$10000608	*vsum4ubs
	dc.l	$1000034e	*vupkhpx
	dc.l	$1000020e	*vupkhsb
	dc.l	$1000024e	*vupkkhsh
	dc.l	$100003ce	*vupklpx
	dc.l	$1000028e	*vupklsb
	dc.l	$100002ce	*vupklsh
	dc.l	$100004c4	*vxor

	global	ppc_vector_jumptable,ppc_vector_string_table,ppc_vector_code_table
