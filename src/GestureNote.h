//
//  GestureNote.h
//  musicalExpressions
//
//  Created by Mark van de Korput on 27/11/14.
//
//

#ifndef __musicalExpressions__GestureNote__
#define __musicalExpressions__GestureNote__

#include "ofMain.h"

class GestureNote {
public:
    GestureNote();

    void setup(float _treshold = 0.5,int _note = 100){
        treshold = _treshold;
        note = _note;
    }
    void update(float value);
    
    void setNote(int n){
        note = n;
    }
    
    bool isOn(){ return state; }
    bool hasChanged(){ return changed; }

    float treshold;
    bool state, changed;
    float max,min;
    int note;
};

#endif /* defined(__musicalExpressions__GestureNote__) */
