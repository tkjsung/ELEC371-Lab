#-----------------------------------------------------------------------------
# template source file for ELEC 371 Lab 1 Part 3
#-----------------------------------------------------------------------------

	.text		# start a code segment 

	.global	_start	# export _start symbol for linker 

#-----------------------------------------------------------------------------
# define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

	.equ	BUTTONS_MASK_REGISTER, ??????
	.equ	BUTTONS_EDGE_REGISTER, ??????

	.equ	LEDS_DATA_REGISTER, ?????

#-----------------------------------------------------------------------------

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main	# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# branch to start of interrupt service routine 
			# (rather than placing all of the service code here) 

#-----------------------------------------------------------------------------

main:
				# initialize stack pointer

mainloop:
				# body of loop in main() routine
	br mainloop

#-----------------------------------------------------------------------------

Init:
				# body of Init() subroutine
      ret

#-----------------------------------------------------------------------------
# The code for the interrupt service routine is below. Note that the branch
# instruction at 0x0020 is executed first upon recognition of interrupts,
# and that branch brings the flow of execution to the code below.
# This exercise involves only hardware-generated interrupts. Therefore, the
# return-address adjustment on the ea register is performed unconditionally.
#-----------------------------------------------------------------------------

isr:
	addi	ea, ea, -4	# this is _required_ for hardware interrupts

				# body of interrupt service routine
				# (save/restore registers that are modified
				#  except ea which must be modified as above)

	eret			# interrupt service routines end _differently_
				# than normal subroutines; the eret goes back
				# to wherever execution was at the time the
				# interrupt request triggered invocation of
				# the service routine

	.end
