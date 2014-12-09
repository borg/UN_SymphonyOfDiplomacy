//
//  VideoFacer.cpp
//  musicalExpressions
//
//  Created by Mark van de Korput on 27/11/14.
//
//

#include "VideoFacer.h"
#include "MusicalExpressions.h"

ofxHistoryPlot* createPlot(string description, float min = 0, float max = 15){
    int numSamples = 350;
    ofxHistoryPlot* plot;
    plot = new ofxHistoryPlot( NULL, description, numSamples, false); //NULL cos we don't want it to auto-update. confirmed by "true"
    plot->setRange(min, max); //hard range, will not adapt to values off-scale
    //plot->addHorizontalGuide(ofGetHeight()/2, ofColor(255,0,0)); //add custom reference guides
    plot->setColor( ofColor(0,255,0) ); //color of the plot line
    plot->setShowNumericalInfo(true);  //show the current value and the scale in the plot
    plot->setRespectBorders(true);	   //dont let the plot draw on top of text
    plot->setLineWidth(1);				//plot line width
    plot->setBackgroundColor(ofColor(0,0,0,50)); //custom bg color
    //custom grid setup
    plot->setDrawGrid(false);
    plot->setGridColor(ofColor(30)); //grid lines color
    plot->setGridUnit(14);
    return plot;
}

using namespace ofxCv;
using namespace cv;


void VideoFacer::setup(MusicalExpressions* app, int w, int h, bool isCam , int midiChannel,int controlChannel,int controlValue, float minControl, float maxControl,string chord, string videoPath){
    
    _app = app;
    _isCam = isCam;
    
    
    _drawPlot = 0;
    _drawVideo = 1;
    _drawFace = 1;
    
    _hasInited = 0;
    _isRunning = 0;
    _isOver = 0;
    _isDown = 0;
    
    _w = w;
    _h = h;
    
    _camScale = 2.0f;

    _tracker.setup();

    if(!_isCam){
        _vidPlayer.loadMovie(videoPath);
        _vidPlayer.play();
        _vidPlayer.setVolume(0.0);
    }else{
        _cam.initGrabber(w*_camScale,h*_camScale);
        _ofxCvImg.allocate(w*_camScale,h*_camScale);
    }
    _translator.setup(_app, &_tracker,midiChannel,controlChannel, controlValue, minControl, maxControl,chord);
    
    /*
     MOUTH_WIDTH = 0,
     MOUTH_HEIGHT,
     LEFT_EYEBROW_HEIGHT,
     RIGHT_EYEBROW_HEIGHT,
     JAW_OPENNESS,
     HEAD_TILT_X,
     HEAD_TILT_Z
     */
    
    plot[0] = createPlot("mouth W", 10, 30);
    plot[1] = createPlot("mouth H",0,10);
    plot[2] = createPlot("brow L",3,10);
    plot[3] = createPlot("brow R",3,10);
    plot[4] = createPlot("jaw", 10, 30);
    plot[5] = createPlot("head tilt",-70,70);
    plot[6] = createPlot("bow",-10,50);
    //plot[7] = createPlot("nostril");
}


void VideoFacer::update(float dt){
    
    if(!_isRunning && _hasInited){
        return;
    }
    
    _hasInited = 1;//need to capture at least first frame
    
    if(!_isCam){
        _vidPlayer.update();
        if(_vidPlayer.isFrameNew()){
            _tracker.update(toCv(_vidPlayer));
        }
    }else{
        _cam.update();
        if(_cam.isFrameNew()){
            
            _ofxCvImg = _cam.getPixels();
            _ofxCvImg.mirror( false, true);
            _tracker.update(toCv(_ofxCvImg));
            
            //_tracker.update(toCv(_cam));//if no mirroring
        }
    }
    if(_tracker.getFound()){
        _translator.update(dt);
    }
    
    
    for(int i=0; i<MAX_PLOTS; i++){
        if(plot[i]){
            plot[i]->update(_translator.gestureValues[i]);

        }
    }
}



void VideoFacer::draw(int x, int y, int w, int h){
    
    
    int w0 = w;
    int h0 = h;
    
    if(w == -1){
        w0 = _w;
    }
    if(h == -1){
        h0 = _h;
    }
    
    ofPushMatrix();
    
    if(_isOver){
        ofSetColor(255,150,150);
    }else{
        ofSetColor(255);
    }
    
    ofTranslate(x,y);
    
    if(_drawVideo){
        if(!_isCam){
            _vidPlayer.draw(0,0,w0,h0);
        }else{
            _ofxCvImg.draw(0,0,w0,h0);
            //_cam.draw(0,0,w0,h0);
        }
    }
    ofSetLineWidth(2);
    //_tracker.draw();
    
    if(_isCam){
        ofScale(1.0f/_camScale,1.0f/_camScale);//trying to get better tracking with higher res camera
    }
    if(_drawFace){
        _tracker.getImageFeature(_tracker.LEFT_EYE).draw();
        _tracker.getImageFeature(_tracker.RIGHT_EYE).draw();
        _tracker.getImageFeature(_tracker.LEFT_EYEBROW).draw();
        _tracker.getImageFeature(_tracker.RIGHT_EYEBROW).draw();
        _tracker.getImageFeature(_tracker.NOSE_BRIDGE).draw();
        _tracker.getImageFeature(_tracker.NOSE_BASE).draw();
        _tracker.getImageFeature(_tracker.INNER_MOUTH).draw();
        _tracker.getImageFeature(_tracker.OUTER_MOUTH).draw();
        _tracker.getImageFeature(_tracker.JAW).draw();
    }
    
    ofSetLineWidth(1);
    //_tracker.getImageMesh().drawWireframe();
    
    if(_drawPlot && _isRunning){
       
        /*
        ofPushMatrix();
        ofDrawArrow(ofVec3f(0,0,0),_tracker.getOrientation());
        ofVec3f pos = _tracker.getPosition();
        ofMatrix4x4 rotationMatrix = _tracker.getRotationMatrix();
        
        //cout<<rotationMatrix.getRotate().getEuler().x<<endl;
        ofTranslate(pos);
        applyMatrix(rotationMatrix);
        ofDrawAxis(-100);
        ofPopMatrix();
         */
    }
    if(_isCam){
        ofScale(_camScale,_camScale);
    }
    
    float plotH = h0/(float)(MAX_PLOTS);
    
    for(int i=0; i<MAX_PLOTS && _drawPlot && _isRunning; i++){
        if(plot[i] == NULL){ continue;}
        plot[i]->draw(0, i*plotH, w0, plotH);
    }
    
    
    
    ofPopMatrix();
}

void VideoFacer::close(){
    _tracker.waitForThread();
    _translator.muteAll();
    
    
    for(int i=0; i<MAX_PLOTS; i++) {
        if(plot[i]){
            delete plot[i];
        }
    }
};