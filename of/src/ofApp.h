#pragma once

#include "ofMain.h"
#include "ofxOsc.h"
#include "WordInstance.h"

// Enum para las escenas
enum Scene {
    LANDSCAPES = 0,
    DUALISMOS = 1
};

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
    
    // Funciones de escenas
    void changeScene(Scene newScene);
    void drawLandscapes();
    void drawDualismos();
    
    // Función para crear nuevo par de dualidades
    void spawnNewPair();
    
    // Receptor OSC
    ofxOscReceiver oscReceiver;
    
    // Escena actual
    Scene currentScene;
    
    // Gestor de palabras (para escena Dualismos)
    std::vector<WordInstance> words;
    
    // Fuente para dibujar
    ofTrueTypeFont font;
    
    // Dualidades de Platón
    std::vector<std::pair<std::string, std::string>> dualities;
    
    // Imágenes para escena Landscapes
    std::vector<ofImage> landscapeImages;
    int currentLandscapeIndex;
    float landscapeAlpha;
    float targetLandscapeAlpha;
    
    // LANDSCAPES: Variables para efectos sonoros reactivos
    float imageReveal;         // Revelación progresiva (0-1, de oscuro a visible)
    float erosionAmount;       // Erosión/disolución de imagen (0-1)
    float blurAmount;          // Blur dinámico según densidad sonora
    float waveDisplacement;    // Desplazamiento ondulatorio
    float feedbackDecay;       // Decay del feedback loop (0.9-1.0)
    
    // Control de fase (soundscape puro → efectos)
    bool effectsEnabled;       // Si los efectos están activos
    float globalIntensity;     // Intensidad global de efectos (0-1)
    
    // Efectos legacy (mantener compatibilidad)
    float glitchAmount;        // Cantidad de glitch (0-1)
    float targetGlitchAmount;
    float zoomLevel;           // Zoom de la imagen (1.0 = normal)
    float targetZoomLevel;
    ofColor tintColor;         // Tinte de color sobre imagen
    float brightness;          // Brillo general
    float scanlineIntensity;   // Intensidad de scanlines
    float pixelationAmount;    // Cantidad de pixelación
    float chromaShift;         // Desplazamiento cromático
    ofFbo feedbackFbo;         // Para efecto de feedback/rastro
    bool feedbackInit;         // Si el FBO está inicializado
    
    // DUALISMOS: Variables para contraste rítmico
    float wordSizeMultiplier;  // Multiplicador de tamaño de palabras
    float rotationSpeed;       // Velocidad de rotación
    int currentDualitySet;     // Set de dualidades actual (0=Platón, 1=Música, 2=Textura)
    
    // Color de fondo
    ofColor bgColor;
};
