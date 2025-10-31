#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {
    ofSetFrameRate(60);
    ofSetVerticalSync(true);
    
    // Color de fondo negro
    bgColor = ofColor(0, 0, 0);
    
    // Iniciar en escena LANDSCAPES
    currentScene = LANDSCAPES;
    currentLandscapeIndex = 0;
    landscapeAlpha = 255;
    targetLandscapeAlpha = 255;
    
    // Inicializar variables LANDSCAPES (efectos sonoros reactivos)
    imageReveal = 1.0f;        // Empieza completamente visible
    erosionAmount = 0.0f;      // Sin erosión inicial
    blurAmount = 0.0f;         // Sin blur inicial
    waveDisplacement = 0.0f;   // Sin ondulación
    feedbackDecay = 0.98f;     // Decay suave para feedback
    effectsEnabled = false;    // Inicia con efectos desactivados (solo imagen)
    globalIntensity = 0.0f;    // Sin efectos al inicio
    
    // Variables legacy (compatibilidad)
    glitchAmount = 0.0f;
    targetGlitchAmount = 0.0f;
    zoomLevel = 1.0f;
    targetZoomLevel = 1.0f;
    tintColor = ofColor(255, 255, 255); // Sin tinte por defecto
    brightness = 1.0f;
    scanlineIntensity = 0.0f;
    pixelationAmount = 0.0f;
    chromaShift = 0.0f;
    feedbackInit = false;
    
    // Inicializar variables DUALISMOS (rítmico/dinámico)
    wordSizeMultiplier = 1.0f;
    rotationSpeed = 0.0f;
    currentDualitySet = 0; // Empezar con Platón
    
    // Cargar fuente del sistema (no requiere archivos externos)
    bool fontLoaded = font.load(OF_TTF_SANS, 72, true, true);
    if (!fontLoaded) {
        ofLogError("ofApp") << "No se pudo cargar la fuente del sistema.";
    } else {
        ofLogNotice("ofApp") << "Fuente del sistema cargada correctamente";
    }
    font.setLetterSpacing(1.037);
    
    // Configurar receptor OSC en puerto 12345
    oscReceiver.setup(12345);
    ofLogNotice("ofApp") << "OSC receptor iniciado en puerto 12345";
    
    // SET 0: Dualidades de Platón (filosofía)
    dualities.push_back({"CUERPO", "ALMA"});
    dualities.push_back({"MUNDO SENSIBLE", "MUNDO INTELIGIBLE"});
    dualities.push_back({"APARIENCIA", "ESENCIA"});
    dualities.push_back({"DEVENIR", "SER"});
    
    // SET 1: Dualidades Musicales (para tema rítmico)
    dualities.push_back({"RITMO", "MELODÍA"});
    dualities.push_back({"GRAVE", "AGUDO"});
    dualities.push_back({"TENSO", "RELAJADO"});
    dualities.push_back({"STACCATO", "LEGATO"});
    
    // SET 2: Dualidades de Textura (contraste sonoro)
    dualities.push_back({"DENSO", "DISPERSO"});
    dualities.push_back({"ÁSPERO", "SUAVE"});
    dualities.push_back({"OSCURO", "BRILLANTE"});
    dualities.push_back({"CAOS", "ORDEN"});
    
    // Cargar imágenes de landscapes desde carpeta bin/data/landscapes/
    ofDirectory dir;
    dir.listDir("landscapes");
    dir.allowExt("jpg");
    dir.allowExt("jpeg");
    dir.allowExt("png");
    dir.sort();
    
    for (int i = 0; i < dir.size(); i++) {
        ofImage img;
        if (img.load(dir.getPath(i))) {
            landscapeImages.push_back(img);
            ofLogNotice("ofApp") << "Imagen cargada: " << dir.getName(i);
        }
    }
    
    ofLogNotice("ofApp") << "Sistema de escenas inicializado";
    ofLogNotice("ofApp") << landscapeImages.size() << " imagenes cargadas para LANDSCAPES";
    ofLogNotice("ofApp") << "Presiona '1' para LANDSCAPES, '2' para DUALISMOS";
}

// ...resto del archivo (update, draw, etc.)...
