//
//  MusicalExpressions.h
//
//
//  Created by
//  Andreas Borg (communic@tion.to) @_andreasborg
//  Grace Avery (grace@thehackerati.com)
//  Sundar Raman (sundar@localprojects.net)
//  Mark van de Korput (markkorput@localprojects.net)
//
//  on 27/11/14.
//  for UN presentation on Humanicy - Technology and Art


//  Notes by Borg
//
//  Note on midi in Logic...read this to separate different channels
//  http://compusition.com/writings/logic-multitrack-midi
//
//  Learn to assign properties of midi to parameters of your tracks
//  https://www.youtube.com/watch?v=vrBpzYq9HRs
//
//  You can override any control params (http://www.indiana.edu/~emusic/cntrlnumb.html)
//  Using pan for something else than pan for instance you need to
//  first block pan in Environment>click>transformer...then assign it to something else.
//  A bit tricky, but use learn mode in Controller Assignments
//  and in value probably want to select 0-127, unsigned, and direct mode
//  Can prob just use 16-19 instead as they are unassigned control channels.
//
//
//  This project is totally based on Kyle McDonald's wonderful stuff.
//  https://vimeo.com/26098366



#pragma once

#include "ofMain.h"

#import <Foundation/Foundation.h>
#include "VideoFacer.h"
#include "ofxXmlSettings.h"
#include "ofxMidi.h"
#include "ofxMTCReceiver.h"//midi time code

@class SoundClipManager;

class MusicalExpressions : public ofBaseApp, public ofxMidiListener, public ofxMidiConnectionListener {
    

#define DT (1.0/60.0)


    
public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void keyPressed(int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);
    
    
    void panic();//mute all

    int videosPerRow;
    
    float globalVolume;//0-1
    
    
    int videoWidth,videoHeight,screenWidth,screenHeight;//from xml
    
    float globalScale;
    
    float currScale;//normal/fullscreen diff
    
    vector<VideoFacer*>videos;
    VideoFacer* activeVideo;
    VideoFacer* activeFullscreenVideo;
    
    void toggleActivefullscreenVideo(int n);
    
    ofxXmlSettings config;
    
    bool drawPlot,drawVideo,drawFace;
    
    
    bool showHelp;
    
    void sendNoteOn(int channel,int note,int velocity);
    void sendNoteOff(int channel,int note,int velocity);
    void sendPitchBend(int channel, int value);//0 - MIDI_MAX_BEND
    void sendAftertouch(int channel, int touch);
    void sendPan(int channel, int pan);
    void sendControlChange(int channel,int control, int pan);
    
    vector<ofxMidiOut*> outputs;
    
    //inputs to sync with logic
    void newMidiMessage(ofxMidiMessage& eventArgs);
    vector<ofxMidiIn*> inputs;
    ofxMidiMessage midiMessage;
    //keeps track of time from logic, need to be enables indise preferences>midi>sync
    ofxMTCReceiver MTCReceiver;
    void newMTCMessage(MTCEventArgs& _args);
    int midiMinutes,midiSeconds,midiFrames;
    
    
    void midiInputAdded(string name, bool isNetwork=false);
    void midiInputRemoved(string name, bool isNetwork=false);
    
    void midiOutputAdded(string nam, bool isNetwork=false);
    void midiOutputRemoved(string name, bool isNetwork=false);

    
    bool muteMetro;
    ofSoundPlayer metroOn,metroOff, snd;
    int syncedTick,syncedBeat;//24/qtr
    bool isPaused;
    
    void newBeat(int n);//1,2,3,4 from Logic
    void newBar(int n);//1,2,3 NOT from Logic...not sent with clock
    
    int currBar,totalBars;
    map<int,vector<int> >clipsInBar;//links a chord to a bar
    vector<int> clipsToSelectFromThisBar;//long names are good for you
    
    
    //int controlChannel;//using one channel for fx controls
    int maxControls,currControl;//this is to be able to teach Logic/Ableton about one control value
    //at a time, and connect it to a parameter of the synth
    //if all sending at same time difficult
    bool isCyclingThroughControls;
    
};

