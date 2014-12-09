//
//  TrackerTranslator.cpp
//  musicalExpressions
//
//  Created by Mark van de Korput on 27/11/14.
//
//

#include "TrackerTranslator.h"
#include "MusicalExpressions.h"


void TrackerTranslator::setup(MusicalExpressions* app,ofxFaceTrackerThreaded* _tracker,int midiChannel,int controlChannel,int controlValue, float minControl, float maxControl,string chord){
    _app = app;
    tracker = _tracker;
    _midiChannel = midiChannel;
    
    _controlChannel = controlChannel;
    _controlValue = controlValue;
    
    _minControl = minControl;
    _maxControl = maxControl;
    
    Chord ch(chord);
    notes = ch.notes;//harmonic chord tones
    
    int rand;
    for(int i=0; i<8; i++){
        rand = ofRandom(notes.size());        
        gestureNotes[i].setNote(notes[rand].toInt());
        
    }
}

void TrackerTranslator::update(float dt){
    if(!tracker->getFound()){
        return;
    }
    
    
    #define READ(name) gestureValues[name] = tracker->getGesture(ofxFaceTracker::name);
    READ(MOUTH_WIDTH)
    READ(MOUTH_HEIGHT)
    READ(LEFT_EYEBROW_HEIGHT)
    READ(RIGHT_EYEBROW_HEIGHT)
   // READ(LEFT_EYE_OPENNESS)
   // READ(RIGHT_EYE_OPENNESS)
    READ(JAW_OPENNESS)
   // READ(NOSTRIL_FLARE)
    
     ofMatrix4x4 rotationMatrix = tracker->getRotationMatrix();
    ofQuaternion rotQuat = rotationMatrix.getRotate();
    ofVec3f Z_AXIS(0,0,1);
    ofVec3f X_AXIS(1,0,0);
    ofVec3f euler = rotQuat.getEuler();
    
    
    gestureValues[HEAD_TILT_Z] = euler.z;
    gestureValues[HEAD_TILT_X] = euler.x;
    
    
    /*
     MOUTH_WIDTH = 0,
     MOUTH_HEIGHT,
     LEFT_EYEBROW_HEIGHT,
     RIGHT_EYEBROW_HEIGHT,
     JAW_OPENNESS,
     HEAD_TILT_X,
     HEAD_TILT_Z
     
     */
    
    
    //XML values come through here
    //whatever feature you wanted to use as control value gets detected and sent here
    
    _app->sendControlChange(_controlChannel,0, ofMap(gestureValues[_controlValue],_minControl,_maxControl,0,127,true));
    //_app->sendControlChange(_app->controlChannel,1, ofMap(gestureValues[HEAD_TILT_X],-10,50,0,127,true));
    //_app->sendControlChange(_app->controlChannel,2, ofMap(gestureValues[MOUTH_HEIGHT],0,10,0,127,true));

        
    for(int i=0; i<MAX_NOTES; i++){
        gestureNotes[i].update(gestureValues[i]);
        
        if(gestureNotes[i].hasChanged()){
            if(gestureNotes[i].isOn()){
                //ofLog() << "sending note on: " << gestureNotes[i].note;
                _app->sendNoteOn(_midiChannel, gestureNotes[i].note, 100);
            } else {
                //ofLog() << "sending note off: " << gestureNotes[i].note;
                _app->sendNoteOff(_midiChannel, gestureNotes[i].note, 100);
            }
        }
    }
}



void TrackerTranslator::muteAll(){
    //mute all
    for(int i=0; i<8; i++){
        if(gestureNotes[i].isOn()){
            _app->sendNoteOff(_midiChannel, gestureNotes[i].note, 100);
        }
    }
};