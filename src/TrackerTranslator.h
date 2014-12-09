//
//  TrackerTranslator.h
//  musicalExpressions
//
//  Created by Mark van de Korput and Andreas Borg
//
//

#ifndef __musicalExpressions__TrackerTranslator__
#define __musicalExpressions__TrackerTranslator__

#include "ofxFaceTrackerThreaded.h"
#include "GestureNote.h"
#include "ofMain.h"
#include "ofxMusicTheory.h"

using  namespace MusicTheory;

#define MAX_NOTES 7


class VideoFacer;
class MusicalExpressions;

class TrackerTranslator{

public:
    enum GESTURE_INDEXES {
        MOUTH_WIDTH = 0,
        MOUTH_HEIGHT,
        LEFT_EYEBROW_HEIGHT,
        RIGHT_EYEBROW_HEIGHT,
        JAW_OPENNESS,
        HEAD_TILT_Z,
        HEAD_TILT_X
    };

public:
    void setup(MusicalExpressions* app,ofxFaceTrackerThreaded* _tracker,int midiChannel = 1,int controlChannel=16,int controlValue=5, float minControl=-30, float maxControl=30,string chord="CM");
    void update(float dt);
    
    void muteAll();
    
    deque<Note> notes;

protected:
    MusicalExpressions* _app;
    ofxFaceTrackerThreaded *tracker;
    float gestureValues[MAX_NOTES];
    GestureNote gestureNotes[MAX_NOTES];
    
     int _midiChannel;
    int _controlChannel;
    int _controlValue;
    int _minControl,_maxControl;
    
friend class VideoFacer;
};

#endif /* defined(__musicalExpressions__TrackerTranslator__) */
