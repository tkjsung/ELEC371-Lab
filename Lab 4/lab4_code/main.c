#include "nios2_control.h"
#include "timer.h"
#include "chario.h"
#include "hex_displays.h"
#include "adc.h"
#include "leds.h"
#include "buttons.h"

extern int flag;
extern int run;

void	Init (void)
{
  /* initialize software variables */
    flag = 0;

  /* set timer start value for interval of HALF SECOND (0.5 sec) */
    // 50MHz = 20ns. We want 1s. 1s/20ns = 50,000,000 = 0x02FAF080
    *TIMER_START_LO = 0xF080;
    *TIMER_START_HI = 0x02FA;
	
  /* clear extraneous timer interrupt */
    // I'm not sure about this...clearing extraneous timer interrupt?
    *TIMER_STATUS = 0x1;

  /* set ITO, CONT, and START bits of timer control register */
    // 0x7 is the value we are writing to the register
    *TIMER_CONTROL = 0x7;
	
	// We want 0.1s. 0.1s/20ns = 12,500,000 = 0x004C4B40
	*T0_START_LO = 0x4B40;
	*T0_START_HI = 0x004C;
	*T0_STATUS = TIMER_T0_BIT;
	*T0_CONTROL = 0x7;

  /* set device-specific bit for timer in Nios II ienable register */
    // timer is positioned at bit 0
    NIOS2_WRITE_IENABLE(0x2003);

  /* set IE bit in Nios II status register */
    // setting IE bit to 1 to enable interrupts
    NIOS2_WRITE_STATUS(0x1);
    
  /* set HEX displays to off */
    *HEX_DISPLAY = 0x0;
	
	*LEDS = 0x200;
	
	*BUTTONS_MASK_REGISTER = 0x6;
	
	run = 0;

}

/* For lab 4, the following pseudocode is provided
 main()::
    PrintString ("ELEC 371 Lab 4\n")
    InitADC(<chip_id for potentiometer>, <mux_sel for potentiometer>)
    loop
        value = ADConvert()
        write value to LED parallel port data register
 end loop
*/


int	main (void)
{
  int value;
  /* perform initialization */
  Init();
  PrintString("ELEC 371 Lab 4\n ");
  InitADC(2,2);
  /* main program is an empty infinite loop */
    while (1){
		value = ADConvert();
		
		if(flag != 0){
			flag = 0;
			PrintChar('\b');
			if(value<128){
				PrintChar('<');
			}
			else{
				PrintChar('>');
			}
		}
    }

  return 0; /* never reached, but needed to avoid compiler warning */
}
