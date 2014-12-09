//
//  CamFacer.cpp
//  musicalExpressions
//
//  Created by Mark van de Korput on 27/11/14.
//
//

#include "CamFacer.h"

using namespace ofxCv;
using namespace cv;

void CamFacer::setup(int camW, int camH){
    tracker.setup();
    cam.initGrabber(camW, camH);
    translator.setup(&tracker);
}

void CamFacer::draw(float x, float y){
    
    ofPushMatrix();
    ofTranslate(x,y);
    cam.draw(0,0);
    
    ofSetLineWidth(2);
    //tracker.draw();
    
    tracker.getImageFeature(tracker.LEFT_EYE).draw();
    tracker.getImageFeature(tracker.RIGHT_EYE).draw();
    tracker.getImageFeature(tracker.LEFT_EYEBROW).draw();
    tracker.getImageFeature(tracker.RIGHT_EYEBROW).draw();
    tracker.getImageFeature(tracker.NOSE_BRIDGE).draw();
    tracker.getImageFeature(tracker.NOSE_BASE).draw();
    tracker.getImageFeature(tracker.INNER_MOUTH).draw();
    tracker.getImageFeature(tracker.OUTER_MOUTH).draw();
    tracker.getImageFeature(tracker.JAW).draw();
    
    
    ofSetLineWidth(1);
    //tracker.getImageMesh().drawWireframe();
    ofPopMatrix();

}

void CamFacer::update(float dt){
    cam.update();
    if(cam.isFrameNew()){
        tracker.update(toCv(cam));
    }
    
    translator.update(dt);
}


void CamFacer::close(){
    tracker.waitForThread();
    translator.muteAll();
};