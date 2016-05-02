;
; Idiot PowerPC Programmer Detector
;
;  ...also known as....
;
; PowerPC  Pipeline Stall Warning Generator
;
;
; RP 20/7/97 v1.00 - Learnt Fantasm points of interest to this code, brainstormed 
;					 possibilities, designed module, coded, added entry points from 
;					 main code (all	marked with "PPCSWG-RP200797", debugged.
;
; 
; Design Notes.
;
; I need to consider several things:
;	(1) Which processor. I will initially concentrate on 6 0 1 type architecture. Although
;   this isn't the latest Power P C structure, I do have more data on it.
;   (2) How to simulate the mechanism as we process the assembly language. Perhaps an
;   instruction queue? This must be in parallel with watching the CR's.
;   (3) Where to insert in the main code of Fantasm. This will obviously be as the 
;   instructions are either checked or assembled.
;
;
;

; 601 Optimisations Currently considering:
; 
; Note: these following 8 points, are NOT (c) Lightsoft, but come from p677 of Optimizing 
; PowerPC code.
;
; 1. Place at least three independent fixed point instructions between a compare and a branch
; dependent on that compare. As long as a previous instructions doesn't cause the compare
; to stall, this will guarantee that the branch is not dispatched until the compare results
; are available.
;
; 2. Place at least four independent fixed-point instructions between a fixed-point instruction 
; with the Record bit set and a branch dependant on the results. As long as a previous 
; instruction doesn't cause the fixed-point instruction to stall, this will cause the branch
; to be executed at the same time as the fixed-point instruction is writing its results to
; the CR. Multi-cycle fixed point instructions will require additional instructions to be 
; inserted.
;
; 3. Place at least four independant fixed-point instructions between a mtlr or mtctr 
; instruction and a branch dependant on the SPR. As long as a previous instruction doesn't
; cause the move to SPR instruction to stall, this will cause the instruction to be executed
; at the same time the SPR is being updated.
;
; 4. For each conditional branch, make sure that there is a fixed-point instruction within three
; instructions before the branch. This insures that the branch has an instruction to tag and prevents it
; from generating a bubble. This is especially important for a series of coniditional branches which 
; are not taken - each branch instruction needs its own fixed-point instruction to tag. 
; Alternating branches and fixed-point insturctions is a common way of addressing this problem.
;
; 5. Between two branch instructions that are taken up to two fixed-point instructions can be 
; inserted. If the first branch jumped directly to the second branch, there would be a stall 
; in the integer pipe while the target of the second branch was being fetched. Inserting the
; two instructions allows the processor to perform useful work during this time.
;
; 6. For a flaoting-point instruction with the Record bit set and a branch dependent on the 
; results of that instruction, place at least three independant fixed-point instructions before
; the floating-point instruction, and at least five independant fixed- or floating-point 
; instructions between the floating-point and branch insturctions. This will guarantee that the
; results of the floating-point instruction are availble whenthe branch is executed.
;
; 7. Place at least one independent fixed-point instruction between a load of a GPR and an
; instruction which uses the loaded register value. This extra instruction will cover the 
; delay assuming a cache hit. More inpendent instructions are necessary to cover the delay due
; to a cache miss.
;
; 8. Place at least three independant floating-point instructions between an instructions
; which updates the FPR and an instruction which uses the updated value. This will prevent
; the FPU from stalling until the data is available. Multi-cycle floating-point instructions
; will require additional instructions to be inserted.
;








