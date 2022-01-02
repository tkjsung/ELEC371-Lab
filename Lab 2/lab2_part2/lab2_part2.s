#--------------------------------------------------------------------------
# ELEC 371 Laboratory 2 Part 2 Assembly Code
# Fall 2018
# Author: Tom Sung

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

	.equ    TIMER_TO_BIT, 0x1			# pattern to represent the
						# bit in timer status register
						# that is set on timeout
						# (when count reaches zero)

	.equ	IENABLE_TIMER_IE, 0x1		# pattern to represent the
						# bit in procr ienable reg. 
						# for recognizing interrupts 
						# from timer hardware
    .equ    IENABLE_BUTTONS_IE, 0b10

	.equ	NIOS2_IE, 0x1			# pattern to represent the
						# bit in procr status reg. 
						# for global recognition 
						# of all interrupts 
    .equ    BUTTONS_MASK_REGISTER,  0x10000058
    .equ    BUTTONS_EDGE_REGISTER,  0x1000005C

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
    movia   sp,INITIAL_STACK_TOP

	# perform initialization
    call    Init

	# main loop
mloop:

	br	mloop

#--------------------------------------------------------------------------

Init:
# save register values
    subi    sp,sp,8
    stw     r2,0(sp)
    stw     r3,4(sp)

# turn off LEDs
    movia   r2, LEDS
    movi    r3, 0
    stwio   r3, 0(r2)

# clear extraneous pending timer interrupt
    wrctl   ienable, r0

# num_cycles = 25,000,000. In HEX: 0x017D7840
# write upper/lower 16 bits of num_cycles
    movia   r2, TIMER_START_LO
    movi    r3, 0x7840
    stwio   r3, 0(r2)
    movia   r2, TIMER_START_HI
    movi    r3, 0x017D
    stwio   r3, 0(r2)

# write 0x7 to timer control register to start timer in continuous mode with interrupts
    movia   r2, TIMER_CONTROL
    movi    r3, 0x7
    stwio   r3, 0(r2)

# set up pushbutton
    movia   r2, BUTTONS_MASK_REGISTER
    movi    r3, 0x6
    stwio   r3, 0(r2)

# set bit for pushbutton ienable
    movi    r3, 0b11
    wrctl   ienable, r3

# set IE bit in NIOS II status register to 1
    movi    r3, NIOS2_IE
    wrctl   status, r3

# restore registers
    ldw     r2,0(sp)
    ldw     r3,4(sp)
    addi    sp,sp,8
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

# perform processor specific register update
    subi    sp,sp,12
    stw     r2,0(sp)
    stw     r3,4(sp)
    stw     r4,8(sp)

# read special regiser for pending interrupts
    rdctl   r2,ipending

# see if interrupt source is timer
    andi    r3,r2,0x1
    beq     r3,r0,check_buttons

isr_timer:
# clear timer interrupt when ipending bit is 1
	movia	r2,TIMER_STATUS
	stwio	r0,0(r2)

# toggle LED bit 1 using XOR operation for timer
    movia   r2, LEDS
    ldwio   r3, 0(r2)
    xori    r3,r3,0x2
    stwio   r3, 0(r2)

# go to end of isr
    br      end_isr

check_buttons:
# see if interrupt source is pushbutton
    andi    r3,r2,0b10
    beq     r3,r0,end_isr

isr_buttons:
# read and clear BUTTON_EDGE register
    movia   r2, BUTTONS_EDGE_REGISTER
    ldwio   r4, 0(r2) # r4 contains edge register... need this for something
    movi    r3, 0x6 # '1' to edge register clears (?) register
    stwio   r3, 0(r2)

# toggle LED bit 0 using XOR operation for timer
    movia   r2, LEDS
    ldwio   r3, 0(r2)
    xori    r3,r3,0x1
    stwio   r3, 0(r2)

end_isr:
# restore register values
    ldw     r2,0(sp)
    ldw     r3,4(sp)
    ldw     r4,8(sp)
    addi    sp,sp,12

# end service routine
	eret

	.end
