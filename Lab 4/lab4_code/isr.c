#include "nios2_control.h"
#include "leds.h"
#include "timer.h"
#include "hex_displays.h"
#include "buttons.h"

int flag;
int i;
int run;

// global variables
unsigned int minutes_tens, minutes_ones, seconds_tens, seconds_ones;

// hex table
unsigned int hex_table[] =
{
    0x3F, 0x06, 0x5B, 0x4F,
    0x66, 0x6D, 0x7D, 0x07,
    0x7F, 0x6F, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00
};

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
        
        // time updates
        seconds_ones++;
        if(seconds_ones == 10){
            seconds_ones = 0;
            seconds_tens++;
            if(seconds_tens == 6){
                seconds_tens = 0;
                minutes_ones++;
                if(minutes_ones == 10){
                    minutes_ones = 0;
                    minutes_tens++;
					if(minutes_tens == 6){
						minutes_tens = 0;
						*HEX_DISPLAY = 0x0;
					}
                }
            }
        }
        
       *HEX_DISPLAY = (hex_table[minutes_tens] << 24) | \
		(hex_table[minutes_ones] << 16) | \
		(hex_table[seconds_tens] << 8) | \
		(hex_table[seconds_ones]);
        
        // toggle least-significant LED: bit 0
		//*LEDS = *LEDS^0x1;
		// set flag
        flag = 1;
    }
	
	if(ipending & 0x2){
		*BUTTONS_EDGE_REGISTER = 0x6;
		if(run == 0){
			run = 1;
		}
		else{
			run = 0;
		}
	}
	
	if(ipending & 0x2000){
		*T0_STATUS = 0;
		if(run == 1){
			i = *LEDS;
			*LEDS = i >> 1;
			if(i == 0x1){
				*LEDS = 0x200;
			}
		}
		
		
		//*LEDS = *LEDS^0x2;
		//flag = 1;
	}
	
}


