#pragma once

#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <memory>

#include <filesystem.h>
#include <nds.h>
#include <NEMain.h>
#include <nf_lib.h>

using namespace std;

class Game
{
public:
    // Main tick logic
    void Tick();
    void Update();
    void Render();
};