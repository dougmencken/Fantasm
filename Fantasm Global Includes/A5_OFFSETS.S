
curs_x:	globoff.w	 1	 *cursor x
curs_y:	globoff.w	1	*cursor y .w
	rs_align
source_buff:	globoff.l	1
file_buff1:	globoff.l	1	*file buffegloboff
file_buff2:	globoff.l	1
file_buff3:	globoff.l	1
file_pos1:	globoff.l	1	*where we are in each file
file_pos2:	globoff.l	1
file_pos3:	globoff.l	1
long_var:	globoff.l	1	*gp long for param passing
line_count:	globoff.l	1	*line counter .l
char_count:	globoff.l	1	*total length of source.l
labels:	globoff.l	1	*where the labels live .l
lab_val:	globoff.l	1	*label values live here
lt_pos:	globoff.l	1	*lable table index .l (32=1)
lt_num:	globoff.w	1	*number of real labels.w
	rs_align
equates:	globoff.l	1	*table of equates values .l
eq_val:	globoff.l	1	*equates values.l
eq_pos:	globoff.l	1	*equates pos
error_size:	globoff.l	1	*size of error buffer
events_count:	globoff.w	1	*frame counter for events call
events_reload:	globoff.w	1	*frame counter reset value
los:	globoff.w	1	*length of string for eval2

misc_options:	globoff.b	1	*sound flag etc

flags:	globoff.b	1	*gp flags (internal to the assembler)
**gp assembler flags
**0=assembly on/off 1=assemble
**1=pass 2
**2=used in get_op_code_num for -ve testing
**4=long address detected in get_mode
**5=put extension 1 in reloc table
**6=put extension 2 in reloc table
**7=error dtected flag

flags2:	globoff.b	1
**gp flags for macros and brackets
**0=we're defining macro definition
**1=we're assembling from macro buffer
**2=we're ignoring a macro definition on pass 2
**3=in a repeat loop if set
**4=fatal error on pass 1
**5=dont report errors (used in ifd and ifnd directives)
**6=label not found for ifd and ifnd
**7=open bracket found in field 3 (in get_fields)

flags3:	globoff.b	1
**preferences flags
**0=save log to disk
**1=auto assemble on launch
**2=sound on
**3=minimal background
**4= scrambled code
**5=ints off
**6=no brackets
**7=show optimisations

flags4:	globoff.b	1
**optimisation flags
**o=warn of fwd bra
**1=do back branch
**2=add to lea
**3=add to addq
**4=move to moveq
**5=show abs long refs
**6=voice on
**7=no cfrg - 416

**flags 5 is more gp flags
flags5:	globoff.b	1
**0=dont check errrors in printit
**1=get labels on pass 1 in eval (used in branch)
**2=zero flag for evaluator
**3=log full on any pass
**4=abs label found for 020 insts (see bf)
**5=in a conditional - superceded by if_depth.b - 3.20
**6=linkable code
**7=defall encountered somewhere - set all labels global at end of pass 1

**flags 6 is gp flags for linkable stuff
flags6:	globoff.b	1
**bit 0 = 1 if mode 7,2 or 7.3 and label is external - reset at start of get_mode
**bit 1 = 1 if tron else 0
**bit 2 = 1 if requ defd already - used in requ
**bit 3 = 1 if complete reassembly reqd in build
**bit 4 = 1 if text in build_receive to include
**bit 5 = 1 if includeg is found in find_incs, so global folder searched
**bit 6 = 1 if an error occurs in fantasm, so build doesnt run link
**bit 7 = 1 if includeh is found in find_incs, so headers folder searched

**bit0=default ppc
**bit1=dont show warnings
**bit2=short warnings
**bit3=dont show 64 bit warnings
**bit4=dont show advice
flags7:	globoff.b	1

**bit 0=extern_data found in eval
**bit 1=get immediate data for ppc operand
**bit 2=report lab not found for dc.x on pass1
flags8:	globoff.b	1

ppc_immediate_data_operand:	globoff.b	1	*4=op5=immediate,3=op4=immediate etc
**fantasm returns error to build in fant_return_code
fant_return_code:	globoff.b	1
if_depth:	globoff.b	1	depth counter for nested ifs
	rs_align	
option_flags:	globoff.w	1
**0=dont dump labels in object file - opt n
**1=binary file only - no header,reloc or labels - opt b
**2=dump label file to disk -opt l
**3=dump complete source to disk - opt s
**4=dont write anything, run in mac!


f_save:	globoff.w	1	*save area for flags on pass1
	rs_align
pc:	globoff.l	1	*our program counter .l
code_buffer:	globoff.l	1	*buffer for code o/p

error_count	globoff.l	1	*line counter for errogloboff
warning_count:	globoff.w	1	*counter for warnings
	rs_align
file_counter:	globoff.l	1	*used to find file name
source_save:	globoff.l	1	*source position pointer for error report
extension:	globoff.l	1	*extension 1 goes here (why is this a long??)
extension2:	globoff.l	1	*extension 2 goes here
size:	globoff.w 	1	* size of 1st extension
size2:	globoff.w	1	*size of 2nd extension
	rs_align
scratch_1:	globoff.l	1	*scratch variables
scratch_2:	globoff.l	1
scratch_3:	globoff.l	1
scratch_4:	globoff.l	1
scratch_5:	globoff.l	1
scratch_6:	globoff.l	1	used in bf
scratch_7:	globoff.l	1	used as temp during get_mode calls
code_start:	globoff.l	1	*.l start address of o/p code
org_address:	globoff.l	1	*.l absolute start address of assembled code
reloc_tab_pos:	globoff.l	1	*.l relocation table index
reloc_tab:	globoff.l	1	*.l addr of long table
st_labels:	globoff.l	1	*.l st label table built here
st_reloc:	globoff.l	1	*.l address of reloc table
f_name_addr:	globoff.l	1	*.l address of master filename from _proj_fname in c file
error_buffer:	globoff.l	1	*.l address of the error file buffer
text_count:	globoff.w	1	*.w index into error_buffer
	rs_align
max_f_size:	globoff.l	1 	*.l maximum file size from init mem
base_buff:	globoff.l	1	*.l base address of free memory block for buffegloboff
end_buff:	globoff.l	1	*.l end address of free memory for buffers
pointer_pos:	globoff.l	1	*.l internal pointer for memory block (my_alloc)
max_s_size:	globoff.l	1	*.l max size of total source
max_reloc_size:	globoff.l	1	*max size of reloc info
rs_counter:	globoff.l	1	*.l rs directive counter
globoff_counter:	globoff.l	1	*global offset counter
labels_sz:	globoff.l	1	*.l size of labels buffer
equ_num:	globoff.l	1	*.w total number of equates
equ_sz:	globoff.l	1	*.l size of equates buffer
code_end:	globoff.l	1	*.l pc end of code
code_sz:	globoff.l	1	*.l size of code buffer
max_global_size:	globoff.l	1
global_buff:	globoff.l	1
global_count:	globoff.l	1
max_extern_size:	globoff.l	1
extern_buff:	globoff.l	1
max_extern_buff_size:	globoff.l	1
extern_count:	globoff.l	1
extern_buff_tab:	globoff.l	1	for link header
extern_buff_tab_pos:	globoff.l	1	position intab on pass 2
proj_buff_h:	globoff.l	1
proj_buff:	globoff.l	1	*project file buffer
max_proj_buff_size:	globoff.l	1
ws_err:	globoff.w	1	-1 if error writing seg
***macro vars
	rs_align
macro_address:	globoff.l	1	*.l address of macro text buffer
mac_buff_size:	globoff.l	1	* max size of macro text
macro_labels:	globoff.l	1	*.l address of macro name table
m_labels_index:	globoff.l	1	*.l index into macro labels
m_labels_size:	globoff.l	1	*.l size of m label table
macro_pos:	globoff.l	1	*.l position in m_labels_index
m_text_pos:	globoff.l	1	*.l position in macro text
m_text_size:	globoff.l	1	*.l size of macro text
m_label_count:	globoff.w	1	*.l label counter for internal macro labels
	rs_align
macro_num:	globoff.l	1	*.w number of macros
source_save_m:	globoff.l	1	*.l saved address of source file when in macro text.
macro_param_h:	globoff.l	1	*handle of macro params
macro_param:	globoff.l	1	*.l macro paramtegloboff table
repeat_addr:	globoff.l	1	*.l address in source of line following repeat statement
narg_count:	globoff.l	1	*.w number of arguments for this macro
	rs_align
macro_depth_index:	globoff.l	1	*index into macro_param
source_pointer_save_index:	globoff.l	1	*index into source_pointer_save
macro_nest_depth:	globoff.l	1	*depth of macro nesting
	rs_align
macro_counters:	globoff.l	1	*label counters for macros
macro_counters_h:	globoff.l	1	*handle of macro_counters
macro_name:	globoff.b	256	*name of current macro expansion

***frame variables
	rs_align
freemem:	globoff.l	1	*.l
aline_pos:	globoff.l	1	*current line pos for assm window
applemenu:	globoff.l	1	*.l handle of apple menu
assmenu:	globoff.l	1	*.l
acurtop:	globoff.l	1	*curent top line for assembler
our_folder:	globoff.w	1	*.w the folder we start in
	rs_align
assopts:	globoff.l	1	*.l handle of options menu

pref_hnd:	globoff.l	1	*.l handle of pref resource
pref_directory:	globoff.l	1	*directory that project file is in - saved in prefs


ext_options:	globoff.w	1	*.w flags for options/menus
*bit 1 is st prg
*bit 2 is bin
*bit 3 is mac app
*bit 4 is linkable

appl_volptr:	globoff.w	1	*.w our appl pointer
	rs_align
asshand:	globoff.l	1	*.l handle for assemble menu
projhand:	globoff.l	1	* handle for project menu
test_flag:	globoff.w	1	*.w tell assembler whether this is test (=1)
	rs_align
start_count:	globoff.l	1	*.l start time of assembly
newptr_result:	globoff.l	1	*.l where the result of newptr goes
uwindptr:	globoff.l	1	*.l use window handle
wwindptr:	globoff.l	1	*.l pointer to goto window
good_sound:	globoff.l	1	*.l handle of good sound globoffrc
bad_sound:	globoff.l	1	*.l handle of fail sound rsrc
beep_sound:	globoff.l	1	*.l handle of menu beep sound
d_handle:	globoff.l	1	*.l handle of prefs dilog - 1618 bytes
log_length:	globoff.w	1	*counter of log length - 1620
optimisation_count:	globoff.w	1
optimisation_saving:	globoff.w	1	*1624
	rs_align
save_pc_pass1:	globoff.l	1	(pc at end of pass 1) 231094
dirty:	globoff.w	1	set if prefs changed
*******************linker vars************************
	rs_align
l_code_pos:	globoff.l	1	code pos in source_buff 1650
l_head_pos:	globoff.l	1	pos in headers_accum
l_number_of_files:	globoff.l	1
file_table:	equ	labels	*for the linker
file_headers:	equ	file_buff1	*the headers go in file_buff1-3
file_names:	equ	lab_val	*.o file names here in linker
	rs_align
file_code_size:	globoff.l	1	*size of file code
header_start:	globoff.l	1	*do_link
tot_number_of_files:	globoff.l	1
link_e_flag:	globoff.b	1	error flag from link
fant_quiet_flag:	globoff.b	1
build_options:	globoff.b	1
libs_read:	globoff.b	1
rebuild:	globoff.b	1	*set to one if complete rebuild
*bit 0 = quiet mode
*bit 1 = 1 if /n (no libs) found
*bit 2 = 1 if res output, else 0
b_start_count:	globoff.l	1	start time of build
link_file_counter:	globoff.l	1	incs by for every file linked - error rep
**requ names_h is handle to requ_names on sys heap
**31 bytes for name, then last byte is upper nibble address reg, lower nibble data reg.
requ_names_h:	globoff.l	1	handle of requ names memory
requ_names_count:	globoff.w	1	count of requs
build_text:	globoff.l	1	pointer to build include text
build_text_h:	globoff.l	1	handle for build text
last_global_size:	globoff.l	1	last known size of globals
title_length:	globoff.w	1	v3.6 header info
input_length:	globoff.w	1
output_length:	globoff.w	1
 
libraries_h:	globoff.l	1	handle of libraries
libraries_size:	globoff.l	1	size of libs
number_of_libraries:	globoff.w	1	how many

resid:	globoff.w	1	id of res if res o/p
	rs_align
resname:	globoff.l	1	name of res if res o/p
resfile_name:	globoff.b	100	name of output file if res
old_dirid:	globoff.l	1	old dir id for custom file
**voice vars
chan:	globoff.l	1
sound:	globoff.l	1
;voice_handles:	globoff.l	50	space for 50 phrases
************old pc vars
qdglob:	globoff.b	206
gci_blk:	globoff.b	200	get_cat_info pb
deskname:	globoff.b	256	for apple menu
temp_string2:	globoff.b	256	where the eval of bracks go
temp_string3:	globoff.b	64	temp string for toc-routine directive
temp_string4:	globoff.b	520	*general usage for single routines only!
bracks_express:	globoff.b	256	where expression is built
input_string:	globoff.b	256	goes here for recursive eval
code_val:	globoff.b	200	codes buit here
temp_pb:	globoff.b	256	read_libs
awrecord:	globoff.b	200	window record
c_buff:	globoff.b	100
temp_string:	globoff.b	128	tempory holding for eval intermediate strs
temp_string_warn:	globoff.b	1024
dest_op:	globoff.b	100	*source operand
source_op:	globoff.b	100	*destination operand
op_3:	globoff.b	100
op_4:	globoff.b	100
op_5:	globoff.b	100
******************************************************
**fantasm v3.10
	rs_align
new_creator:	globoff.l	1	creator text from bcf

arrow_curs_h:	globoff.l	1	arrow
beam_curs_h:	globoff.l	1
rainbow_curs_h:	globoff.l	1
title_curs_h:	globoff.l	1	small arrows for title
grow_curs_h:	globoff.l	1	arrows for grow box
busy_curs_h:	globoff.l	1	cursors
mem_curs_h:	globoff.l	1
in_background:	globoff.w	1
	rs_align
installed_time:	globoff.l	1	time installed
unreg_menu:	globoff.l	1	unreg in menu bar (handle) 

******************************************************
**fantasm v3.20 - 180895
test_fsspec:	globoff.b	80	*testing for paths dialog *v4
source_fsspec:	globoff.b	80	*build source files
global_incs_fsspec:	globoff.b	80	*global incs 
build_output_fsspec:	globoff.b	80
op_name:	globoff.b	80
;incbins_fsspec:	globoff.b	 80	*incbins folder
;sa_source_fsspec:	 globoff.b	 80	*stand alone source file name
;sa_output_fsspec:	 globoff.b	 80	*sa output path
;standard_libs_fsspec:	 globoff.b	 80	*standard libs path
;user_libs_fsspec:	 globoff.b	 80	*user libs path
headers_fsspec:	globoff.b	80		*headers path
	rs_align
long_var1:	globoff.l	1	*file routines use this
build_fsspec:	 globoff.b	 80	*build file fsspec
temp_fsspec:	globoff.b	80	*tempory fsspec used in make_temp_fsspec
new_fname:	globoff.b	128		*where temp names go
pref_fsspec:	globoff.b	80	*project file fsspec
assembler_source_fsspec:	globoff.b	 80	*assembler source file name
assembler_output_fsspec:	globoff.b	80	*assembler output ile name
	rs_align
return_ae_address:	globoff.l	1
hub_psn2:	globoff.l	1
hub_psn1:	globoff.l	1
ae_created:	globoff.l	6	*the actual apple event types (as it were)
ae_reply:	globoff.l	6
status:	globoff.w	1
	rs_align
tx_size:	globoff.l	1
rx_size:	globoff.l	1
tx_buffer_h:	globoff.l	1
rx_buffer_h:	globoff.l	1
rx_buffer_ptr:	globoff.l	1
tx_buffer_ptr:	globoff.l	1
build_remote:	globoff.w	1	*set to 1 if a build command comes in
ass_remote:	globoff.w	1	*set to one if remote assemble command comes in
rebuild_remote:	globoff.w	1	*remote rebuild
integrated:	globoff.w	1	*set to 1 if in lide
	rs_align
lide_error_window_ref:	globoff.l	1	*eddie error window id
error_window_open:	globoff.w	1	*flag for fantasm
	rs_align
error_string_save:	globoff.l	1	*address of the error string
building?:	globoff.w	1	*set to 1 if build in progress
quit_tool:	globoff.w	1	*set to 1 if lide wants us quit

**********************v4 ppc vars
**bit 0=powerpc directive
**bit 1=stripped op code, use error_op_field to report error
**bit 2=align off
**bit 3=pass 2 (another)
**bit 4=handling a directive
ppc_flags1:	globoff.b	1
ppc_flags2:	globoff.b	1
**bit 0 = dot
**bit 1 = a
**bit 2 = l
**bit 3 = lr
**bit 4 = ctr
*bit 5 = +

**ppc_flags3
**bit 0 = dat_sect if 1
ppc_flags3:	globoff.b	1
postfix_flags:	globoff.b	1
field_1: globoff.b	528
field_2: globoff.b	528
field_3: globoff.b	528
field_3_guard:	globoff.w	1	*set to zero so we can detect if we run off the start of field 3
error_op_field:	globoff.b	256
	rs_align
second_operand:	globoff.l	1		*get_ppc_operands temp storage
third_operand:	globoff.l	1
fourth_operand:	globoff.l	1
fifth_operand:	globoff.l	1
field_2_new:	globoff.b	parameter_size
field_3_new:	globoff.b	parameter_size
	rs_align
first_type:	globoff.w	1
second_type:	globoff.w	1	*operand types from get_n (get_one, get_two etc)
third_type:	globoff.w	1
fourth_type:	globoff.w	1
fifth_type:	globoff.w	1
counter_save:	globoff.w	macro_depth_limit+1	*label counter saves
source_pointer_save:	globoff.l	macro_depth_limit+5		*source pointers saved here
	rs_align
library_starts:	globoff.l	max_number_of_libs

*********************toc stuff*******************
toc_names_table_h:	globoff.l	1	*handle of system heap toc_names
toc_offsets_table_h:	globoff.l	1	*handle of toc offsets in system heap
toc_names_table:	globoff.l	1	*pointer from h
toc_offsets_table:	globoff.l	1	*pointer from h
toc_offset_counter:	globoff.l	1	*the offset (+ve) inc'd by 8
toc_names_pos:	globoff.l	1	*index into toc_names_table
total_imports_num:	globoff.l	1	*total number of imports
total_imports_num_from_pass1:	globoff.w	1	*total number of imports after pass1

*******************frag xcoff stuff**************
	rs_align
xcoff_va_of_entry:	globoff.l	1	*entry point va
xcoff_data_size:	globoff.l	1
xcoff_data_va:	globoff.l	1
xcoff_code_size:	globoff.l	1
xcoff_loader_size:	globoff.l	1
xcoff_file_size:	globoff.l	1	*total size of frag to write
xcoff_code_va:	globoff.l	1	*va of code section
xcoff_bss_size:	globoff.l	1	*bss size - filled in by fantasm as gobals size
xcoff_toc_size:	globoff.l	1	*toc size less function entry (12 bytes)
code_pointers_va:	globoff.l	1	*pointer to code pointers in toc
data_buffer_h:	globoff.l	1	*handle of data buffer on system heap
data_buffer:	globoff.l	1	*pointer to data_buffer
data_buffer_index:	globoff.l	1	*index into data buffer - goes into offsets
data_item_count:	globoff.l	1	*count of number of data items to go in toc
data_item_offsets_h:	globoff.l	1	*handle of offsets table in data
data_item_offsets:	globoff.l	1	*pointer to offsets table in data

long_labels_counter:	globoff.l	1	*size of long laebls text
long_labels_h:	globoff.l	1		*handle of long labels
long_labels:	globoff.l	1		*derefed handle

toc_code_names_h:	globoff.l	1	*handle of toc code names in toc
toc_code_names:	globoff.l	1	*derefd contents of above
toc_code_offsets_h:	globoff.l	1
toc_code_offsets:	globoff.l	1	*offsets of code labels from zero

toc_code_count:	globoff.l	1		*counter of entries
toc_code_names_pos:	globoff.l	1	*code names counter (incd 32)
is_ppc:	globoff.w	1		*set to 1 if machine is ppc
	rs_align
ppc_data_buffer_size:	globoff.l	1	*calculate size of data buffer
ppc_number_of_imports:	globoff.l	1		*calculated number of imports allowed
ppc_number_of_code_defs:	globoff.w	1
ppc_number_of_data_defs:	globoff.w	1
	rs_align
entry_point:	globoff.l	1		*the entry point into the code

**linkable output stuff
imports_output_table_h:	globoff.l	1
data_ptrs_output_table_h:	globoff.l	1
code_ptrs_output_table_h:	globoff.l	1	*only in linkable mode

imports_output_table:	globoff.l	1
data_ptrs_output_table:	globoff.l	1
code_ptrs_output_table:	globoff.l	1	*only in linkable mode

total_imports_used:	globoff.l	1	*number of imports actually used
total_code_ptrs_used:	globoff.l	1	*number of code pointers used
total_data_ptrs_used:	globoff.l	1	*number of toc data pointers used

******new link vars
ppc_data_buffer_handle:	globoff.l	1	*v4.04 data area (128k)
ppc_data_buffer_pointer:	globoff.l	1	
file_data_size:	globoff.l	1	*data section size of file
l_data_pos:	globoff.l	1	*data position in link accumulation.
l_data_start:	equ	ppc_data_buffer_pointer	*we use the assm's source buffer for the data in link ppc.
	rs_align
f_len_of_imports:	globoff.l	1	*number of imports in a linker file
f_len_of_code_ptrs:	globoff.l	1
f_len_of_data_ptrs:	globoff.l	1	
import_count:	globoff.l	1	*number of entries in link import table
code_ptrs_count:	globoff.l	1	*total number of code ptrs in link	
data_ptrs_count:	globoff.l	1
rebuild_flag:	globoff.w	1		*if 1, link restarts

***new dialogs vars
flash_rect:	globoff.l	2		*rectangle for flash rect in dialog
flash_colour:	globoff.w	1	*counter for rectangles
box:	globoff.w	4

**new menu vars
prefs_sub_hand:	globoff.l	1	*handle of prefs sub menu
size_size_res:	globoff.l	1	*size in size resource
min_size_size_res:	globoff.l	1	*minimum size in size resource
size_flags1:	globoff.b	1	*upper 8 bits of size flags
size_flags2:	globoff.b	1	*lower 8 bits of size flags
frame_count:	globoff.w	1	*controller for about box
print_x:	globoff.w	1
print_y:	globoff.w	1
scroll_count:	globoff.w	1	*if gets past 8, new char printed
mess_pos:	globoff.w	1		*string index
colour_counter:	globoff.w	1	*colours index
	rs_align
mess_handle:	globoff.l	1	*handle of message resource
mess_pointer:	globoff.l	1	*derefed
delta_y:	globoff.w	1
	rs_align
y_off:	globoff.w	1
dll_flags1:	globoff.b	1
*bit0=controlstrip
*1=displaylib
*2=inputsprocket
*3=netsprocket
*4=drawsprocket
*5=soundsprocket

dll_flags2:	globoff.b	1
	rs_align
save_length_of_files:	globoff.l	1
save_number_of_libs:	globoff.l	1	*save addresses in xcoff to fill in.
;comms_buffer_addr:	globoff.l	1	*eddies comms buffer - deleted
comms_buffer:	globoff.b	1024	*comms buffer
eddie_psn:	globoff.l	2		*eddies psn goes here on comms link up
transmitter_counter:	globoff.w	1	*fail down counter
pix_depth:	globoff.w	1		*screen depth
fatal_flag:	globoff.w	1		*fantasm assembler fatal
incs_counter:	globoff.w	1	*counts number of included files

**pf404 - if depth array
max_if_depth:	equ	256
if_depth_array:	globoff.b	max_if_depth
if_counter:	globoff.b	1
if_scan:	globoff.b	1	*see f4 nested ifs document
saved_depth:	globoff.b	1	*ditto
**pf405 - rs accumulator for bss
	rs_align
rs_accumulator:	globoff.l	1
globoff_accumulator:	globoff.l	1

**pf406
eval2_item_count:	globoff.l	1	*counter of items being built up from brackets
global_err:	globoff.b	1		*global error flag for 406
dsw_warn_flag_off:	globoff.b	1	*if 1, we dont get zero ds warnings for data directive.
start_macro_copy:	globoff.b	1	*if starting assembling from macro

**v4.11
any_errors?:	globoff.b	1	*set to 1 if errors on build
rs_autoalign:	globoff.b	1	*set to 1 is rs auto align
	rs_align
sl_connections:	globoff.l	64	*space for 64 shared lib connections
sl_connections_slot:	globoff.l	1	*index into sl_connections
number_of_extra_sls:	globoff.l	1	*how many extra sls there are
lib_names_pointer:	globoff.l	1	*save for pointer to lib names
number_of_symbols_to_resolve:	globoff.l	1	*how many symbols we must resolve in wxf
loader_symbol_table_ptr:	globoff.l	1	*pointer to loader sym table
loader_string_table_ptr:	globoff.l	1
fants_res_id:	globoff.w	1
seventrec:	globoff.b	16			*events record
temp_filename:	globoff.b	256		*for assembler send filename to eddie
**420
entry_set:	globoff.b	1			*set to 1 when we encounter an entry, used for error checking

frag_loaded:	globoff.b	1
	rs_align
edd_frag_conn_id:	globoff.l	1
err_name:	globoff.b	256
edd_frag_main_addr:	globoff.l	1	*address of eddies accelerator

**v5
callback:	globoff.l	1
callback_toc:	globoff.l	1
the_file:	globoff.l	1		*pointer to file to translate
fant_end_error:	globoff.l	1	*final error to anvil
command_save:	globoff.l	1	*Command ptr from anvil
output_file_handle:	globoff.l	1	*Where output file goes
output_file_size:	globoff.l	1	*size of output file
my_pb_handle:	globoff.l	1
**
pline_index:	globoff.l	1	*used for printing to Anvil
the_line:	globoff.b	1024
**
incldes_h:	globoff.l	1				*space for 48 * 80 byte include files 
tot_number_of_includes:	globoff.l	1	*how many includes in this tu
the_code_size:	globoff.l	1	*code and data size for report back to caller

***V4.6
***Trees
max_number_of_labels:	globoff.l	1
actual_number_of_labels:	globoff.l	1
max_number_of_equates:	globoff.l	1
labels_tree:	globoff.l	1	*memory for labs tree
word_buff:	globoff.b	68
tree_strings_ptr:	globoff.l	1
last_tree_address_used:	globoff.l	1
equ_last_tree_address_used:	globoff.l	1
equates_tree:	globoff.l	1
actual_number_of_equates:	globoff.l	1

actual_number_of_tocnames:	globoff.l	1	*imports
tocnames_tree:	globoff.l	1
tocnames_last_tree_address_used:	globoff.l	1
max_number_of_tocnames:	globoff.l	1
time_to_idle:	globoff.l	1	*when zero we call idle
**f5
	rs_align
save_possible_local:	globoff.l	1	*save a3 for dbra
fantasm_ppc_handle:	globoff.l	1
frag_conn_id:	globoff.l	1
frag_main_addr:	globoff.l	1
to_single_fd:	globoff.l	1	*function descriptor of to_float function
to_double_fd:	globoff.l	1
to_single_sin_fd:	globoff.l	1
to_double_sin_fd:	globoff.l	1
r2d2_fd:	globoff.l	1
r2d2_init_fd:	globoff.l	1
r2d2_term_fd:	globoff.l	1

symclass:	globoff.l	1
possible_string_in_field_3:	globoff.b	1	*Set to 1 if field 3 contains a dollar so we can scan for string expansions
possible_string_in_field_2:	globoff.b	1	*Set to 1 if field 2 ditto
	rs_align
internal_strings_h:	globoff.l	1	*handle for storage of A$-Z$ (256 bytes each)
dest_string_addr:	globoff.l	1
src_string1_addr:	globoff.l	1
src_string2_addr:	globoff.l	1
arguments_start:	globoff.l	1	*used in string handling
mid_arg_2:	globoff.l	1
mid_arg_1:	globoff.l	1	*used in mid$ handling
restore_comma:	globoff.l	1	*again
output_counter:	globoff.l	1
abort:	globoff.b	1	*Set to 1 if ctrl+alt+apple picked up in idle
pass_id:	globoff.l	1	*Set to 1 on pass 1 and 2 on pass 2
beep_handle:	globoff.l	1	*handle of beep sound
r2d2_prefs:	globoff.l	1

**f5
neg_label:	equ	0
eval_extra_flags:	globoff.w	1
	rs_align
return_string_ptr:	globoff.l	1
**f5.1
macros_first:	globoff.b	1	*if 1, macros are searched first
half_size:	globoff.b	1	*if set, ppc sizes become half
break_flag:	globoff.b	1	*Set to 1 if break encountered in macro
saved_if_depth:	globoff.b	1	*when start assembling from macro we save here for break
saved_if_depth_array_index:	globoff.b	1	*used for break
saved_if_depth_array:	globoff.b	macro_depth_limit	*array for saved if depths going into a macro
saved_repeat_depth_array:	globoff.b	macro_depth_limit	*Array for saved in repeat flags for break
	rs_align
max_eq_val_size:	globoff.l	1
globisrs_flag:	globoff.l	1	*if set, globoff calls rs
code_buff_hand:	globoff.l	1	*handle to output code
fant_has_been_initted:	globoff.w	1	*set to 1 after first init

**f5.1
**r2d2
the_instruction:	globoff.l	1
pass1_error_ptr:	globoff.l	1
prefs_flags_ptr:	globoff.l	 1
field_1_ptr:	globoff.l	 1

pipe_handle:		globoff.l	 1
pipe_entry_offset_store:	globoff.l	 1
pipe_exit_offset_store:		globoff.l	 1

**f6
newptr_handle:	globoff.l	1	*newhandleclear for mem block
f_debug_flag:	globoff.l	1	*gen debug info from build
line_numbers_table_h:	globoff.l	1	*linenumebrs handle
line_numbers_table:	globoff.l	1
file_names_table_h:	globoff.l	1
file_names_table:	globoff.l	1

max_linenumbers:	globoff.l	1
line_number_index:	globoff.l	1
