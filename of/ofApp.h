#pragma once

#include "ofMain.h"
#include "ofxOsc.h"
#include "WordInstance.h"

class ofApp : public ofBaseApp {
public:
    void setup();
    void update();
    void draw();
    void keyPressed(int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y);
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void mouseEntered(int x, int y);
    void mouseExited(int x, int y);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);
    
    // Función para crear nuevo par de dualidades
    void spawnNewPair();
    
    // Receptor OSC
    ofxOscReceiver oscReceiver;
    
    // Gestor de palabras
    std::vector<WordInstance> words;
    
    // Fuente para dibujar
    ofTrueTypeFont font;
    
    // Dualidades de Platón
    std::vector<std::pair<std::string, std::string>> dualities;
    
    // Color de fondo
    ofColor bgColor;
};
