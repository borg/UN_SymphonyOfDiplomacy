//
//  VideoFacer.h
//  musicalExpressions
//
//  Created by Mark van de Korput on 27/11/14.
//
//

#ifndef __musicalExpressions__VideoFacer__
#define __musicalExpressions__VideoFacer__

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxCv.h"

#include "ofxFaceTrackerThreaded.h"
#include "TrackerTranslator.h"
#include "ofxHistoryPlot.h"


#define MAX_PLOTS 7

class MusicalExpressions;
//using namespace ofxCv;


class VideoFacer{
public:
    void setup(MusicalExpressions* app,int w, int h, bool isCam = true,int midiChannel = 1,int controlChannel=16,int controlValue=5, float minControl=-30, float maxControl=30,string chord="CM", string videoPath = "");
    void draw(int x, int y, int w = -1, int h = -1);
    void update(float dt);
    void close();
    
    ofVideoPlayer * getVideoPlayer(){
        return &_vidPlayer;
    }
    ofVideoGrabber * getCamera(){
        return &_cam;
    }
    
    void setSize(int w, int h){
        _w = w;
        _h = h;
    }
    
    ofRectangle getSize(){
        return ofRectangle(0,0,_w,_h);
    }
    
    bool isCamera(){
        return _isCam;
    }
    
    void setDrawFace(bool v){
        _drawFace = v;
    }
    void setDrawVideo(bool v){
        _drawVideo = v;
    }
    void setDrawPlot(bool v){
        _drawPlot = v;
    }
    
    void start(){
        _isRunning = 1;
    }

    void stop(){
        _isRunning = 0;
        _translator.muteAll();
    }
    
    bool isRunning(){
        return _isRunning;
    }
    
    void setMouseOver(bool v){
        _isOver = v;
    }
    
    void setMouseDown(bool v){
        _isDown = v;
    }
    
    
    ofxFaceTrackerThreaded * getTracker(){
        return &_tracker;
    }
protected:
    
    
   
    
    MusicalExpressions* _app;
    
    bool _isRunning,_hasInited;
    bool _isOver,_isDown;
    
    bool _isCam;
    bool _drawPlot,_drawVideo,_drawFace;
    
    ofVideoPlayer _vidPlayer;
    ofVideoGrabber _cam;
    ofxCvColorImage _ofxCvImg;//to flip mirror
    ofxFaceTrackerThreaded _tracker;
    TrackerTranslator _translator;
    
    int _w,_h;
    float _camScale;
    
    ofxHistoryPlot* plot[MAX_PLOTS];
};

#endif /* defined(__musicalExpressions__VideoFacer__) */
