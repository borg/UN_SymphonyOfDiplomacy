#include "MusicalExpressions.h"
#import "SoundClipManager.h"
#import "GAConstants.h"


void MusicalExpressions::setup(){

    ofLogToFile("log.txt", true);
    activeVideo = 0;

    activeFullscreenVideo = 0;
    
    
    
    
    currBar = 1;//1-4
    
    // enables the network midi session between iOS and Mac OSX on a
    // local wifi network
    //
    // in ofxMidi: open the input/outport network ports named " "
    //
    // on OSX: use the Audio MIDI Setup Utility to connect to the iOS device
    //
    ofxMidi::enableNetworking();
    
    // list the number of available input & output ports
    ofxMidiIn::listPorts();
    ofxMidiOut::listPorts();
    
    
    
    //ofxMidiIn::getNumPorts()
    for(int i = 0; i < ofxMidiIn::getNumPorts(); i++) {
        
        // new object
        inputs.push_back(new ofxMidiIn());
        
        // set this class to receive incoming midi events
        inputs[i]->addListener(this);
        
        // don't ignore sysex, timing, & active sense messages,
        // these are ignored by default
        
        inputs[i]->ignoreTypes(false, false, true);//(bool midiSysex=true, bool midiTiming=true, bool midiSense=true);
        
        // open input port via port number
        inputs[i]->openPort(i);
    }
    
    if(inputs.size()){
        //  int portIndex = inputs[0]->getPort();
        //  MTCReceiver.init( portIndex );
        
        //NOTE: LOGIC DOESN'T SEEM TO SEND TO ALL, BUT YOU NEED TO SELECT IAC DRIVER BUS
        
        ofAddListener( MTCReceiver.MTCEvent, this, &MusicalExpressions::newMTCMessage  );
    }

    
    // create and open output ports
    for(int i = 0; i < ofxMidiOut::getNumPorts(); ++i) {
        outputs.push_back(new ofxMidiOut());
        outputs[i]->openPort(i);
    }
    
    
    //LOGIC TIME RELATED
    
    metroOn.loadSound("sounds/metro1/1.wav");
    metroOn.setLoop(false);
    metroOff.loadSound("sounds/metro1/2.wav");
    metroOff.setLoop(false);
    
    snd.loadSound("sounds/metro3/2.wav");
    snd.setLoop(false);
    
    syncedBeat = 0;
    syncedTick = 0;
    
    midiMinutes = 0;
    midiSeconds = 0;
    midiFrames = 0;
    
    
    isPaused = 1;
    //
    
    config.loadFile("config.xml");
    drawPlot = config.getValue("drawPlot",true);
    drawVideo = config.getValue("drawVideo",true);
    drawFace = config.getValue("drawFace",true);
    screenWidth = config.getValue("screenWidth",1280);//size we adapt design to
    screenHeight = config.getValue("screenHeight",720);//size we adapt design to
    videoWidth = config.getValue("videoWidth",426);
    videoHeight = config.getValue("videoHeight",240);
    videosPerRow = config.getValue("videosPerRow",3);
    
    globalVolume = config.getValue("globalVolume",1.0f);
    
    muteMetro = config.getValue("muteMetro",true);
    totalBars = config.getValue("totalBars",4);//before goes back to first bar
    //controlChannel  = config.getValue("controlChannel",true);
    
    maxControls  = config.getValue("maxControls",4);
    currControl = 0;
    isCyclingThroughControls = false;//one at a time for calibration

    
    showHelp = 1;//always on at start
    //showHelp = config.getValue("showHelp",1);
    
    currScale = screenWidth / (float)(videoWidth*videosPerRow);

    ofSetVerticalSync(true);
    
    
    int vidNum = config.getNumTags("video");
    string file;
    bool isCam;
    int midiChannel;
    int controlChannel,controlValue;
    float minControl,maxControl;
    string chord;//eg. CM, Am7, Dsus2
    vector<string>bars;
    for(int i=0;i<vidNum;i++){
        videos.push_back(new VideoFacer());
        
        isCam = config.getAttribute("video","isCam",false,i);
        midiChannel = config.getAttribute("video","midiChannel",1,i);
        chord = config.getAttribute("video","chord","CM",i);
        bars = ofSplitString(config.getAttribute("video","bars","1",i),",");
        
        
        controlChannel  = config.getAttribute("video","controlChannel",16,i);
        controlValue  = config.getAttribute("video","controlValue",5,i);
        minControl  = config.getAttribute("video","min",-30.0f,i);
        maxControl  = config.getAttribute("video","max",30.0f,i);
        
        
        if(isCam){
            videos[i]->setup(this,videoWidth, videoHeight, true,midiChannel,controlChannel,controlValue,  minControl,maxControl, chord);
        }else{
            file = config.getAttribute("video","src","video/usa.mov",i);
            videos[i]->setup(this,videoWidth, videoHeight, false,midiChannel,controlChannel,controlValue,  minControl,maxControl,chord,file);
        }
        
        //map videos in a musical bar, so that their chordal notes will play nicely
        int v = bars.size();
        while(v--){
            clipsInBar[ofToInt(bars[v])].push_back(i);
        }
        
        
    }
        
    int v = videos.size();
    while(v--){
        videos[v]->setDrawFace(drawFace);
        videos[v]->setDrawVideo(drawVideo);
        videos[v]->setDrawPlot(drawPlot);
    }
    
}


void MusicalExpressions::update(){
    
    if(activeFullscreenVideo){
        activeFullscreenVideo->update(DT);
    }else{
        int v = videos.size();
        while(v--){
            videos[v]->update(DT);
        }
    }
    
    
    //sendControlChange(3,0, ofMap(ofGetMouseY()/ (float)ofGetHeight(),0,1.0f,0,127,true));
    
    //sendControlChange(3,1, ofMap(ofGetMouseX()/ (float)ofGetWidth(),0,1.0f,0,127,true));
    
    //sendAftertouch(3, ofGetMouseX()/ (float)ofGetWidth());
}

void MusicalExpressions::draw(){
    ofBackground(0);
    
    ofSetColor(255);
    
    ofPushMatrix();
    
    
    if(activeFullscreenVideo){
        
        float soloScale = ofGetWidth()/(float)videoWidth;
        ofScale(soloScale,soloScale);
        activeFullscreenVideo->draw(0,0);
        
    }else{
        //grid render
        ofScale(currScale,currScale);
        bool moreVids = true;
        int currV = 0;
        for(int r = 0; moreVids;r++){
            for(int c = 0;c<videosPerRow && moreVids;c++){
                videos[currV]->draw(videoWidth*c,videoHeight*r);
                
                currV++;
                if(currV==videos.size()){
                    moreVids = false;
                }
            }
        }
    }
    


    
    ofPopMatrix();
    
    if(showHelp){
        stringstream ss;
        
        if(isCyclingThroughControls){
            ss<<"Cycle mode\n";
            ss<<"sending "<<currControl<<" of "<<maxControls<<" controls\n";
            ss<<"arrows to change\n";
            ss<<"l - turn off cycling\n\n";
        }else{
            ss<<"blackspace - play/stop\n";
            ss<<"f - fullscreen\n";
            ss<<"v - show videos\n";
            ss<<"c - show faces\n";
            ss<<"p - show graphs\n";
            ss<<"h - show help\n";
            ss<<"1-9 - focus video\n";
            ss<<"q - PANIC!\n";
            ss<<"s - screengrab\n";
            ss<<"m - toggle metro\n";
            ss<<"l - cycle controls\n";
        }
        
        ss<<"FPS: "<<ofToString((int) ofGetFrameRate())<<"\n";
        ss<<"MIDI: "<<ofToString((int) midiMinutes)<<":"<<ofToString((int) midiSeconds)<<":"<<ofToString((int) midiFrames)<<"\n";
        ss<<"BEAT: "<<ofToString(syncedBeat)<<"/4\n";
        ss<<"BAR: "<<ofToString(currBar)<<"/"<<ofToString(totalBars)<<"\n";
       
        
        ofSetColor(0,0,0,50);
        ofRect(10, 10, 200, 220);
        ofSetColor(255);
        ofDrawBitmapString(ss.str(), 20, 30);
    }
}


void MusicalExpressions::panic(){
    int v = videos.size();
    while(v--){
        videos[v]->stop();
    }

};

void MusicalExpressions::toggleActivefullscreenVideo(int n){
    if(videos.size()<=n){
        return;
    }
    
   // if(!activeFullscreenVideo){
        //turn all others off and start active
        int v = videos.size();
        while(v--){
            if(v != n){
                videos[v]->stop();
            }
        }
        
    //}
    
    
    videos[n]->start();
    
    
    if(videos.size()>n){
        if(activeFullscreenVideo == videos[n]){
            activeFullscreenVideo = 0;
        }else{
            activeFullscreenVideo = videos[n];
        };
    }
};

void MusicalExpressions::keyPressed(int key){
    cout<<key<<endl;
    //49-57 are keys 1-9
    
    int num = key-49;

    if(num>-1 && num<9){
        toggleActivefullscreenVideo(num);
    }

    
    if(key == ' ' && (activeVideo || activeFullscreenVideo)){
        
        if(activeFullscreenVideo){
            if(activeFullscreenVideo->isRunning()){
                activeFullscreenVideo->stop();
            }else{
                activeFullscreenVideo->start();
            }
        }else{
            if(activeVideo->isRunning()){
                activeVideo->stop();
            }else{
                activeVideo->start();
            }
        }

    }
    
    if(key == 'h') {
        showHelp = !showHelp;
        //config.setValue("showHelp",showHelp);
        //config.saveFile();
    }
    
    
    if(key == 'q') {
        panic();
    }
    
    
    if(key == 'f') {
        ofToggleFullscreen();
    }
    
    if(key == 'p') {
        drawPlot = !drawPlot;
        config.setValue("drawPlot",drawPlot);
        config.saveFile();
    }
    
    if(key == 'c') {
        drawFace = !drawFace;
        config.setValue("drawFace",drawFace);
        config.saveFile();
    }
    
    
    if(key == 'v') {
        drawVideo = !drawVideo;
        config.setValue("drawVideo",drawVideo);
        config.saveFile();
    }
    
    
    if(key == 'm') {
        muteMetro = !muteMetro;
        config.setValue("muteMetro",muteMetro);
        config.saveFile();
    }
    
    
    
    int v = videos.size();
    while(v--){
        videos[v]->setDrawFace(drawFace);
        videos[v]->setDrawVideo(drawVideo);
        videos[v]->setDrawPlot(drawPlot);
    }
    
    
    if(key == 's') {
        
        ofDirectory cache("screengrabs/");
        if(!cache.exists()){
            cache.create(true);
        }
        
        ofSaveScreen("screengrabs/"+ofGetTimestampString()+".png");
    }
    
    if(key == 'l') {
        isCyclingThroughControls = !isCyclingThroughControls;
    }

    
    if(key == 356){
        //left arrow
        currControl--;
        if(currControl<0){
            currControl = maxControls-1;
        }
        
    }
    if(key == 358){
        //right arrow
        currControl++;
        if(currControl>=maxControls){
            currControl = 0;
        }
    }
    
    
    if(key == 'r'){
        int v = videos.size();
        while(v--){
            videos[v]->getTracker()->reset();
        }
    }
}

void MusicalExpressions::windowResized(int w, int h){
    currScale =  ofGetWidth() / (float)(videoWidth*videosPerRow);
}


void MusicalExpressions::exit(){
    int v = videos.size();
    while(v--){
        videos[v]->close();
    }
    
    for(int i = 0; i < outputs.size(); i++) {
        outputs[i]->closePort();
    }
    
    // clean up
    for(int i = 0; i < inputs.size(); i++) {
        inputs[i]->closePort();
        inputs[i]->removeListener(this);
    }
}



void MusicalExpressions::keyReleased(int key){}
void MusicalExpressions::mouseMoved(int x, int y ){
    
    bool moreVids = true;
    int currV = 0;
    ofRectangle hitarea;
    ofPoint p(x/(float)currScale,y/(float)currScale);
    bool wasOver = 0;
    for(int r = 0; moreVids;r++){
        for(int c = 0;c<videosPerRow && moreVids;c++){
            
            
            hitarea.set(videoWidth*c,videoHeight*r,videoWidth,videoHeight);
            if(hitarea.inside(p)){
                videos[currV]->setMouseOver(true);
                activeVideo = videos[currV];
                wasOver = 1;
            }else{
                videos[currV]->setMouseOver(false);
            }
       
            currV++;
            if(currV==videos.size()){
                moreVids = false;
            }
        }
    }
    
    if(!wasOver){
        activeVideo = 0;
    }

}
void MusicalExpressions::mouseDragged(int x, int y, int button){
    globalVolume = x / (float)ofGetWidth();

}
void MusicalExpressions::mousePressed(int x, int y, int button){
    
    bool moreVids = true;
    int currV = 0;
    ofRectangle hitarea;
    ofPoint p(x/(float)currScale,y/(float)currScale);
    
    for(int r = 0; moreVids;r++){
        for(int c = 0;c<videosPerRow && moreVids;c++){
            
            
            hitarea.set(videoWidth*c,videoHeight*r,videoWidth,videoHeight);
            if(hitarea.inside(p)){
                videos[currV]->setMouseDown(true);
            }else{
                videos[currV]->setMouseDown(false);
            }
            
            currV++;
            if(currV==videos.size()){
                moreVids = false;
            }
        }
    }
    


}

//from Logic 1,2,3,4

void MusicalExpressions::newBeat(int n){
    
    

    metroOn.stop();
    metroOn.setPosition(0);
    
    metroOff.stop();
    metroOff.setPosition(0);
    
    
    if(!muteMetro){
        if(n==1){
            metroOn.play();
            
            //toggleActivefullscreenVideo(ofRandom(videos.size()));
        }else{
            //1,2,3
            metroOff.play();
        }
    }

    
    /*
    if(clipsToSelectFromThisBar.size()){
        int a = ofRandom(clipsToSelectFromThisBar.size());//pick one video, with chords that fit this bar
        int v = videos.size();
        while(v--){
            if(v != a){
                videos[v]->stop();
            }
        }
        videos[clipsToSelectFromThisBar[a]]->start();//play notes from this chord this bar
    }
     */

};


//NOT from Logic 1,2,3,4

void MusicalExpressions::newBar(int n){
    clipsToSelectFromThisBar.clear();
    
    int v = clipsInBar[n].size();
    while(v--){
        clipsToSelectFromThisBar.push_back(clipsInBar[n][v]);
        //cout<<"clipsInBar[n][v] "<<clipsInBar[n][v]<<endl;
    }
    
}


void MusicalExpressions::mouseReleased(int x, int y, int button){}
void MusicalExpressions::gotMessage(ofMessage msg){}
void MusicalExpressions::dragEvent(ofDragInfo dragInfo){}


void MusicalExpressions::sendNoteOn(int channel,int note,int velocity){
    
    cout<<"channel: "<<channel<<", note: "<<note<<", velocity: "<<velocity*globalVolume<<endl;
    
    for(int i=0;i<outputs.size();i++){
        outputs[i]->sendNoteOn(channel,note,  velocity*globalVolume);
    }
};


void MusicalExpressions::sendNoteOff(int channel,int note,int velocity){
    for(int i=0;i<outputs.size();i++){
        outputs[i]->sendNoteOff(channel,note,  velocity*globalVolume);
    }
};



void MusicalExpressions::sendPitchBend(int channel, int value){
    
    cout<<"MusicalExpressions::sendPitchBend "<< channel<<" "<<value<<endl;
    for(int i=0;i<outputs.size();i++){
        outputs[i]->sendPitchBend(channel,value);
    }

};



void MusicalExpressions::sendAftertouch(int channel, int touch){
    cout<<"MusicalExpressions::sendAftertouch "<< channel<<" "<<touch<<endl;
    for(int i=0;i<outputs.size();i++){
        outputs[i]->sendAftertouch(channel,touch);
    }
};

//0-127
void MusicalExpressions::sendPan(int channel, int pan){

    cout<<"MusicalExpressions::sendPan "<< channel<<" "<<pan<<endl;
    for(int i=0;i<outputs.size();i++){
        outputs[i]->sendControlChange(channel, 10, pan);
    }
};


void MusicalExpressions::sendControlChange(int channel,int control, int value){
    
    if(isCyclingThroughControls && control != currControl){
        cout<<"Cycling mode: MusicalExpressions::sendControlChange blocking"<< channel<<" "<<control<<" " <<value<<endl;
        return;
    }
    //cout<<"MusicalExpressions::sendControlChange "<< channel<<" "<<control<<" " <<value<<endl;
    for(int i=0;i<outputs.size();i++){
        outputs[i]->sendControlChange(channel, control, value);
    }

};

//--------------------------------------------------------------
void MusicalExpressions::newMidiMessage(ofxMidiMessage& msg) {
    
    // make a copy of the latest message
    midiMessage = msg;
    
    if(msg.status == MIDI_TIME_CODE){
        MTCReceiver.newMidiMessage( msg);//pass it on for parsing...using this instead of as a separate midi listener...still sends event above
    }else if(msg.status == MIDI_TIME_CLOCK){
        //MIDI_TIME_CLOCK 248
         if(syncedTick%24==0){
             syncedBeat++;
             if((syncedBeat-1)%4==0){
                 syncedBeat = 1;
                 
                 currBar++;
                 if((currBar-1)%totalBars==0){
                     currBar=1;
                }
                 //sending newBar before newBeat
                 newBar(currBar);
                 
             }
             newBeat(syncedBeat);
         }
         
         syncedTick++;
        
    }else if(msg.status == MIDI_STOP){
        //cout<<"MIDI_STOP RECEIVED FROM EXTERNAL SOURCE. SLAP THEM"<<endl;
    }else if(msg.status == MIDI_START){
        //cout<<"MIDI_START RECEIVED FROM EXTERNAL SOURCE. SLAP THEM"<<endl;
        
    }else if(msg.status == MIDI_SONG_POS_POINTER){
        //cout<<"MIDI_SONG_POS_POINTER"<<endl;
    }
    
}


void MusicalExpressions::newMTCMessage(MTCEventArgs& _args){
    midiMinutes = _args.minutes;
    midiSeconds = _args.seconds;
    midiFrames = _args.frames;
};


void MusicalExpressions::midiInputAdded(string name, bool isNetwork){
    cout<<"MusicalExpressions::midiInputAdded "<<name<<endl;
};

void MusicalExpressions::midiInputRemoved(string name, bool isNetwork){
    cout<<"MusicalExpressions::midiInputRemoved "<<name<<endl;
};

void MusicalExpressions::midiOutputAdded(string name, bool isNetwork){
    cout<<"MusicalExpressions::midiOutputAdded "<<name<<endl;
};

void MusicalExpressions::midiOutputRemoved(string name, bool isNetwork){
    cout<<"MusicalExpressions::midiOutputRemoved "<<name<<endl;
};

