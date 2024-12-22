// main.cpp
#include <nds.h>
#include <stdio.h>

int main() {
    // Initialize both screens
    videoSetMode(MODE_0_2D);
    videoSetModeSub(MODE_0_2D);

    // Initialize console on bottom screen
    consoleDemoInit();

    // Set up background for top screen
    vramSetBankA(VRAM_A_MAIN_BG);
    PrintConsole topScreen;
    consoleInit(&topScreen, 3, BgType_Text4bpp, BgSize_T_256x256, 31, 0, true, true);

    // Print messages
    consoleSelect(&topScreen);
    printf("\x1b[10;5HHello from the top screen!");
    
    consoleSelect(&consoleDemoInitDefault());
    printf("\x1b[10;5HHello from the bottom screen!");

    // Main game loop
    while(1) {
        swiWaitForVBlank();
        scanKeys();
        
        // Exit if Start button is pressed
        if(keysDown() & KEY_START) break;
    }

    return 0;
}