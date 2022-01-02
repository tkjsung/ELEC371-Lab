#include "nios2_control.h"
#include "timer.h"
#include "chario.h"

int flag;

void	Init (void)
{
  /* initialize software variables */
    flag = 0;

  /* set timer start value for interval of HALF SECOND (0.5 sec) */
    // 50MHz = 20ns. We want 0.5s. 0.5s/20ns = 25,000,000 = 0x017D7840
    *TIMER_START_LO = 0x7840;
    *TIMER_START_HI = 0x017D;
	
  /* clear extraneous timer interrupt */
    // I'm not sure about this...clearing extraneous timer interrupt?
    *TIMER_STATUS = 0x1;

  /* set ITO, CONT, and START bits of timer control register */
    // 0x7 is the value we are writing to the register
    *TIMER_CONTROL = 0x7;

  /* set device-specific bit for timer in Nios II ienable register */
    // timer is positioned at bit 0
    NIOS2_WRITE_IENABLE(0x1);

  /* set IE bit in Nios II status register */
    // setting IE bit to 1 to enable interrupts
    NIOS2_WRITE_STATUS(0x1);
}


int	main (void)
{

  /* perform initialization */
  Init ();
  PrintString("ELEC371 Lab 3\n");
  /* main program is an empty infinite loop */
    while (1){
        interrupt_handler();
		if(flag != 0){
			flag = 0;
			PrintChar('*');
		}
    }

  return 0; /* never reached, but needed to avoid compiler warning */
}
