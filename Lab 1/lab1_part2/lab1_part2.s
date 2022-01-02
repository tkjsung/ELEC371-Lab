#-----------------------------------------------------------------------------
# source file for ELEC 371 Lab 1 Part 2
#-----------------------------------------------------------------------------

	.text			# inform assembler that code section begins
				#   (but note that in this course, we also
				#    place "data" in what would normally be
				#    a section with only instructions)
	.global _start		# export _start symbol for linker

#-----------------------------------------------------------------------------
# define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

	.equ	SWITCHES_DATA_REGISTER, 0x10000040

	.equ	HEX_DISPLAYS_DATA_REGISTER, 0x10000020

#-----------------------------------------------------------------------------

	.org 0x00			# place first instruction below at address 0
_start:				# start of main() routine in this case
				# initialize stack pointer
    movia		sp, 0x007FFFFC
    movia       r3, SWITCHES_DATA_REGISTER
    movia       r4, HEX_DISPLAYS_DATA_REGISTER
mainloop:
	call	ReadSwitches
	call 	WriteHexDisplays

				# body of loop in main() routine
br mainloop

#-----------------------------------------------------------------------------

ReadSwitches:
				# body of ReadSwitches() subroutine
				ldwio   r2, 0(r3)
	ret

#-----------------------------------------------------------------------------

WriteHexDisplays:
				# body of WriteHexDisplays() subroutine
				stwio  r2, 0(r4)

	ret

	.end
