#-----------------------------------------------------------------------------
# source file for ELEC 371 Lab 1 Part 3
#-----------------------------------------------------------------------------

	.text		# start a code segment 

	.global	_start	# export _start symbol for linker 

#-----------------------------------------------------------------------------
# define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

	.equ	BUTTONS_MASK_REGISTER, 0x10000058
	.equ	BUTTONS_EDGE_REGISTER, 0x1000005C

	.equ	LEDS_DATA_REGISTER, 0x10000010

#-----------------------------------------------------------------------------

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main	# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# branch to start of interrupt service routine 
			# (rather than placing all of the service code here) 

#-----------------------------------------------------------------------------

main:
	movia   sp, 0x007FFFFC			# initialize stack pointer

    call    Init
    movi     r5, 0(r0)
mainloop:
    addi    r5, r5, 1

				# body of loop in main() routine
	br mainloop

#-----------------------------------------------------------------------------

Init:

# Diable LEDs after button is released
    movia   r4, LEDS_DATA_REGISTER
    stwio   r0, 0(r4)

# Enable interrupts on pshbtn 0
    movia   r6, BUTTONS_MASK_REGISTER
    movi    r7, 0b0110
    stwio   r7, 0(r6)

    movia   r2, BUTTONS_EDGE_REGISTER
    stwio   r0, 0(r2)

# Enable procr to recognize pshbtn interrupt
    movi    r7, 0b010
    wrctl   ienable, r7

# Enable procr to respond to all interrupts
    movi    r7, 1
    wrctl   status, r7

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

# perform processor-specific register update
# read special register with pending interrupts
# if (pshbtn interrupt is pending) then
#   clear pshbtn interrupt source
#   toggle LED0 using XOR operation
# end if

    subi    sp, sp, 20
    stw     r11, 0(sp)
    stw     r10, 4(sp)
    stw     r12, 8(sp)
    stw     r13, 12(sp)
    stw     r14, 16(sp)

    movia   r14, BUTTONS_EDGE_REGISTER
    ldwio   r10, 0(r14)   # read edge capture register
    stwio   r0, 0(r14)    # clear the interrupt

    rdctl   et, ipending    # read ipending to see if there is pending operations

    andi    r11, et, 0b10   # if the pushbutton is not pressed (nothing in ipending)
    beq     r11, r0, END_ISR    # end the interrupt

# clear pushpin interrupt source

# toggle LED0 using XOR
    movia   r12, LEDS_DATA_REGISTER
    movi    r13, 0(r0)
    addi    r13, r13, 0b1
    stwio   r13, 0(r12)

END_ISR:
    ldw     r11, 0(sp)
    ldw     r10, 4(sp)
    ldw     r12, 8(sp)
    ldw     r13, 12(sp)
    ldw     r14, 16(sp)
    addi    sp, sp, 20
				# body of interrupt service routine
				# (save/restore registers that are modified
				#  except ea which must be modified as above)

	eret			# interrupt service routines end _differently_
				# than normal subroutines; the eret goes back
				# to wherever execution was at the time the
				# interrupt request triggered invocation of
				# the service routine

	.end
