#pragma once

#include "ofMain.h"
#include "ofxMidi.h"

#include "ofxMusicTheory.h"

#include "ofxMusicEditor.h"

using  namespace MusicTheory;

class testApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();
        void exit();

		void keyPressed  (int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
    
     ofxMidiOut midiOut;
    int channel;
	
	unsigned int currentPgm;
	int note, velocity;
	int pan, bend, touch, polytouch;
    
    void playChord(Chord c);
    
    
    Composition comp;
    void onNoteOn(MusicEvent &e);
    void onNoteOff(MusicEvent &e);
    
    ofxMusicEditor editor;
		
};
