#include "ofMain.h"
#include "MusicalExpressions.h"
//#include "ofAppGlutWindow.h"

//better for fullscreen on second monitor
#include "ofAppGLFWWindow.h"


#import "GAConstants.h"
#include "ofxXmlSettings.h"

int main( ){
    
    //ofAppGlutWindow window;
    
    ofAppGLFWWindow* window = new ofAppGLFWWindow();
    window->setMultiDisplayFullscreen(true);
    
    
    //oF08 osx bug with datapath not set
    ofDisableDataPath();
    ofxXmlSettings config;
    config.loadFile("data/config.xml");
    ofEnableDataPath();
    
    

    
    int w = config.getValue("screenWidth",1280);
    int h = config.getValue("screenHeight",720);
    int l = config.getValue("screenLeft",0);
    int t = config.getValue("screenTop",-100);
    
    
    bool fullscreen = config.getValue("fullscreen",false);
    if(fullscreen){
        ofSetupOpenGL(window, w,h, OF_FULLSCREEN);			// <-------- setup the GL context
        
    }else{
        
        ofSetupOpenGL(window, w,h, OF_WINDOW);			// <-------- setup the GL context
        ofSetWindowPosition(l,t);
    }
    
    bool showMouse = config.getValue("showMouse",1);
    
    if(!showMouse){
        ofHideCursor();
    }
    

    ofRunApp(new MusicalExpressions());
}
