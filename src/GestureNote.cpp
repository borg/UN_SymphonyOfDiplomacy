//
//  GestureNote.cpp
//  musicalExpressions
//
//  Created by Mark van de Korput on 27/11/14.
//
//

#include "GestureNote.h"

GestureNote::GestureNote() : state(false), treshold(0.3), max(0.0), min(0.0) {
    setup();
    //note = std::floor(ofRandom(127));
}

void GestureNote::update(float value){
    bool prevState = state;

    if(value < min){
        min = value;
        treshold = (max + min) / 2;
    }

    if(value > max){
        max = value;
        treshold = (max + min) / 2;
    }
    
    if(value > treshold)
        state = true;
    else
        state = false;
    
    changed = state != prevState;
}