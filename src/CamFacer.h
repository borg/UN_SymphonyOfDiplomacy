//
//  CamFacer.h
//  musicalExpressions
//
//  Created by Mark van de Korput on 27/11/14.
//
//

#ifndef __musicalExpressions__CamFacer__
#define __musicalExpressions__CamFacer__

#include "ofMain.h"
#include "ofxFaceTrackerThreaded.h"
#include "TrackerTranslator.h"


class CamFacer{
public:
    void setup(int camW, int camH);
    void draw(float x, float y);
    void update(float dt);
    void close();
public:
    ofVideoGrabber cam;
    ofxFaceTrackerThreaded tracker;
    // ExpressionClassifier classifier;
    TrackerTranslator translator;
};

#endif /* defined(__musicalExpressions__CamFacer__) */
