#include "nios2_control.h"
#include "leds.h"
#include "timer.h"

extern int flag;

void interrupt_handler(void)
{
	unsigned int ipending;

	/* read current value in ipending register */
    
    // rdctl    r2, ipending
    ipending = NIOS2_READ_IPENDING();
    
	/* _if_ ipending bit for timer is set,
	   _then_
	       clear timer interrupt,
	       and toggle the least-sig. LED
	       (use the C '^' operator for XOR with constant 1)
	*/
    // ipending bit 0 is for timer (corresponds to ienable)
    if(ipending & 0x1){
		
        // clear timer interrupt - set bit to 0
        *TIMER_STATUS = 0;
        // toggle least-significant LED: bit 0
		*LEDS = *LEDS^0x1;
		// set flag
        flag = 1;
    }
}
