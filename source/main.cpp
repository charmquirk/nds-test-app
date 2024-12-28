/*---------------------------------------------------------------------------------

	$Id: main.cpp,v 1.13 2008-12-02 20:21:20 dovoto Exp $

	Simple console print demo
	-- dovoto


---------------------------------------------------------------------------------*/
#include <nds.h>

#include <stdio.h>

static volatile int frame = 0;
static volatile int fps = 0;
static volatile int elapsedSeconds = 0;

//---------------------------------------------------------------------------------
// VBlank interrupt handler. This function is executed in IRQ mode - be careful!
//---------------------------------------------------------------------------------
static void Vblank() {
//---------------------------------------------------------------------------------
	frame++;
}

static void countFPS() {
	elapsedSeconds++;
	fps = frame;

	// Reset for the next second
	frame = 0;
}

//---------------------------------------------------------------------------------
int main(void) {
//---------------------------------------------------------------------------------
	touchPosition touchXY;

	irqSet(IRQ_VBLANK, Vblank); // Set up VBlank interrupt
    irqSet(IRQ_TIMER0, countFPS); // Set up Timer0 interrupt for FPS counting
    irqEnable(IRQ_VBLANK | IRQ_TIMER0);  // Enable VBlank and Timer0 interrupts

	consoleDemoInit();

	iprintf("\x1b[0;0HTesting Application\x1b[39m\n");

	timerStart(0, ClockDivider_1024, TIMER_FREQ_1024(1), countFPS);

	while(pmMainLoop()) {

		swiWaitForVBlank();

		scanKeys();
		int keys = keysDown();
		if (keys & KEY_START) break;

		touchRead(&touchXY);

		// print at using ansi escape sequence \x1b[line;columnH
		iprintf("\x1b[2;0H\x1b[2KTouch point = (%d, %d)\n", touchXY.rawx, touchXY.rawy);
		iprintf("\x1b[3;0H\x1b[2KTouch pixel = (%d px, %d px)\n", touchXY.px, touchXY.py);

		// Print FPS to the console
		iprintf("\x1b[4;0HFPS = %02d", fps);

		// Print the time elapsed to the console
		iprintf("\x1b[5;0HTime Elapsed: %02d:%02d:%02d\x1b[39m\n", elapsedSeconds/3600, (elapsedSeconds/60) % 60, elapsedSeconds % 60);
		if (elapsedSeconds > 60) {
			iprintf("\x1b[6;0HSeconds Elapsed: %d\x1b[39m\n", elapsedSeconds);
		}
	}

	return 0;
}