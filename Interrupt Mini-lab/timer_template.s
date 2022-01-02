#--------------------------------------------------------------------------
# ELEC 371 template file for basic use of timer interrupt
# (the original timer interface from the DE0 computer system is used)
#--------------------------------------------------------------------------

# directives to define symbolic labels for addresses/constants 

	.equ	INITIAL_STACK_TOP, 0x007FFFFC	# start of stack in RAM 

	.equ	LEDS, 0x10000010		# LED output port address 

	.equ	TIMER_STATUS, 0x10002000	# timer status register 
	.equ	TIMER_CONTROL, 0x10002004	# timer control register 
	.equ	TIMER_START_LO, 0x10002008	# low bits of start value 
	.equ	TIMER_START_HI, 0x1000200C	# high bits of start value 
	.equ	TIMER_SNAP_LO, 0x10002010	# low bits of count value 
	.equ	TIMER_SNAP_HI, 0x10002014	# high bits of count value 

	.equ TIMER_TO_BIT, 0x1			# pattern to represent the
						# bit in timer status register
						# that is set on timeout
						# (when count reaches zero)

	.equ	IENABLE_TIMER_IE, 0x1		# pattern to represent the
						# bit in procr ienable reg. 
						# for recognizing interrupts 
						# from timer hardware 

	.equ	NIOS2_IE, 0x1			# pattern to represent the
						# bit in procr status reg. 
						# for global recognition 
						# of all interrupts 

#--------------------------------------------------------------------------

	.text		# start a code segment 

	.global	_start	# export _start symbol for linker 

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main	# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# branch to start of interrupt service routine 
			# (rather than placing all of the service code here) 

#--------------------------------------------------------------------------


main:
	# initialize stack pointer (make it a habit to always do this)


	# perform initialization


	# main loop
mloop:

	br	mloop

#--------------------------------------------------------------------------

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
