#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {
    ofSetFrameRate(60);
    ofSetVerticalSync(true);
    
    // Color de fondo negro
    bgColor = ofColor(0, 0, 0);
    
    // Cargar fuente del sistema (no requiere archivos externos)
    bool fontLoaded = font.load(OF_TTF_SANS, 36, true, true);
    if (!fontLoaded) {
        ofLogError("ofApp") << "No se pudo cargar la fuente del sistema.";
    } else {
        ofLogNotice("ofApp") << "Fuente del sistema cargada correctamente";
    }
    font.setLetterSpacing(1.037);
    
    // Configurar receptor OSC en puerto 12345
    oscReceiver.setup(12345);
    ofLogNotice("ofApp") << "OSC receptor iniciado en puerto 12345";
    
    // Inicializar dualidades de Platón
    dualities.push_back({"CUERPO", "ALMA"});
    dualities.push_back({"MUNDO SENSIBLE", "MUNDO INTELIGIBLE"});
    dualities.push_back({"APARIENCIA", "ESENCIA"});
    dualities.push_back({"DEVENIR", "SER"});
    
    ofLogNotice("ofApp") << "Escena de Platón inicializada con " 
                         << dualities.size() << " dualidades";
}

//--------------------------------------------------------------
void ofApp::update() {
    // Procesar mensajes OSC entrantes
    while (oscReceiver.hasWaitingMessages()) {
        ofxOscMessage msg;
        oscReceiver.getNextMessage(msg);
        
        ofLogVerbose("ofApp") << "OSC recibido: " << msg.getAddress();
        
        // /kick - Crear nuevo par de dualidades y trigger palabras existentes
        if (msg.getAddress() == "/kick") {
            // Crear nuevo par de palabras de Platón
            spawnNewPair();
            
            // Trigger todas las palabras existentes con tamaño 100
            for (auto &word : words) {
                word.trigger(100.0f);
            }
            
            ofLogNotice("ofApp") << "Kick recibido: nuevo par creado y palabras triggereadas";
        }
        
        // /bass_level - Cambiar color de fondo según nivel de bajo
        if (msg.getAddress() == "/bass_level") {
            if (msg.getNumArgs() > 0) {
                float bassLevel = msg.getArgAsFloat(0);
                // Mapear 0-1 a un rango de colores oscuros
                // A mayor nivel de bajo, más brillante el fondo
                float brightness = ofMap(bassLevel, 0.0f, 1.0f, 0.0f, 80.0f, true);
                bgColor = ofColor(brightness * 0.8, brightness * 0.4, brightness);
                
                ofLogNotice("ofApp") << "Bass level: " << bassLevel 
                                     << " -> Fondo: " << brightness;
            }
        }
        
        // /melody_note - Cambiar color de palabra aleatoria según nota
        if (msg.getAddress() == "/melody_note") {
            if (msg.getNumArgs() > 0 && words.size() > 0) {
                float note = msg.getArgAsFloat(0);
                
                // Mapear nota a hue (0-255 en oF)
                // Asumiendo notas MIDI (0-127) o normalizadas (0-1)
                float hue = 0;
                if (note > 1.0f) {
                    // Nota MIDI (0-127)
                    hue = ofMap(note, 0, 127, 0, 255);
                } else {
                    // Nota normalizada (0-1)
                    hue = ofMap(note, 0.0f, 1.0f, 0, 255);
                }
                
                // Crear color desde HSB
                ofColor newColor = ofColor::fromHsb(hue, 255, 255);
                
                // Elegir palabra aleatoria y cambiar su color
                int randomIndex = ofRandom(words.size());
                words[randomIndex].color = newColor;
                
                ofLogNotice("ofApp") << "Melody note: " << note 
                                     << " -> Color HSB(" << hue << ")";
            }
        }
    }
    
    // Actualizar todas las palabras
    for (auto &word : words) {
        word.update();
    }
    
    // Eliminar palabras muertas de forma segura
    // std::remove_if reordena el vector moviendo los elementos "muertos" al final
    // y retorna un iterador al inicio de la "zona muerta"
    // erase() elimina desde ese punto hasta el final
    words.erase(
        std::remove_if(words.begin(), words.end(),
            [](WordInstance &w) { 
                return w.isDead(); 
            }),
        words.end()
    );
}

//--------------------------------------------------------------
void ofApp::draw() {
    // Limpiar fondo
    ofBackground(bgColor);
    
    // Dibujar todas las palabras
    for (auto &word : words) {
        word.draw(font);
    }
    
    // Información de debug en pantalla
    ofSetColor(100, 255, 100, 200);
    ofDrawBitmapString("FPS: " + ofToString(ofGetFrameRate(), 1), 20, 20);
    ofDrawBitmapString("Palabras activas: " + ofToString(words.size()), 20, 40);
    ofDrawBitmapString("Dualidades disponibles: " + ofToString(dualities.size()), 20, 60);
    
    // Instrucciones
    ofSetColor(150, 150, 150, 180);
    ofDrawBitmapString("Controles:", 20, ofGetHeight() - 100);
    ofDrawBitmapString("  ESPACIO: trigger todas las palabras", 20, ofGetHeight() - 80);
    ofDrawBitmapString("  'n': crear palabra aleatoria", 20, ofGetHeight() - 60);
    ofDrawBitmapString("  '1-4': activar dualidad de Platon", 20, ofGetHeight() - 40);
    ofDrawBitmapString("  'c': limpiar todas las palabras", 20, ofGetHeight() - 20);
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key) {
    // ESPACIO: trigger todas las palabras
    if (key == ' ') {
        for (auto &word : words) {
            word.trigger(2.0f + ofRandom(1.0f));
        }
        ofLogNotice("ofApp") << "Trigger manual de todas las palabras";
    }
    
    // 'n': crear palabra aleatoria
    if (key == 'n') {
        WordInstance newWord;
        newWord.setup(
            "PALABRA",
            ofPoint(ofRandom(ofGetWidth()), ofRandom(ofGetHeight())),
            1.5f + ofRandom(0.5f),
            ofColor(ofRandom(150, 255), ofRandom(150, 255), ofRandom(150, 255)),
            120.0f + ofRandom(60.0f)
        );
        words.push_back(newWord);
        ofLogNotice("ofApp") << "Palabra aleatoria creada";
    }
    
    // '1'-'4': activar dualidades
    if (key >= '1' && key <= '4') {
        int index = key - '1';
        if (index < dualities.size()) {
            auto &pair = dualities[index];
            
            // Palabra izquierda
            WordInstance word1;
            word1.setup(
                pair.first,
                ofPoint(ofGetWidth() * 0.3f, ofGetHeight() * 0.5f),
                2.0f,
                ofColor(255, 100, 150),
                240.0f
            );
            words.push_back(word1);
            
            // Palabra derecha
            WordInstance word2;
            word2.setup(
                pair.second,
                ofPoint(ofGetWidth() * 0.7f, ofGetHeight() * 0.5f),
                2.0f,
                ofColor(100, 150, 255),
                240.0f
            );
            words.push_back(word2);
            
            ofLogNotice("ofApp") << "Dualidad " << (index + 1) << ": " 
                                 << pair.first << " / " << pair.second;
        }
    }
    
    // 'c': limpiar todas las palabras
    if (key == 'c') {
        words.clear();
        ofLogNotice("ofApp") << "Todas las palabras eliminadas";
    }
    
    // 'b': cambiar color de fondo
    if (key == 'b') {
        bgColor = ofColor(ofRandom(50), ofRandom(50), ofRandom(50));
    }
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key) {
    
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y) {
    
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button) {
    
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button) {
    // Crear palabra en la posición del mouse
    WordInstance newWord;
    newWord.setup(
        "CLICK",
        ofPoint(x, y),
        1.8f,
        ofColor(255, 200, 100),
        150.0f
    );
    words.push_back(newWord);
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button) {
    
}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y) {
    
}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y) {
    
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h) {
    
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg) {
    
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo) {
    
}

//--------------------------------------------------------------
void ofApp::spawnNewPair() {
    // Verificar que hay dualidades disponibles
    if (dualities.empty()) {
        ofLogWarning("ofApp") << "No hay dualidades disponibles";
        return;
    }
    
    // Elegir un par aleatorio del vector de dualidades
    int randomIndex = ofRandom(dualities.size());
    auto &pair = dualities[randomIndex];
    
    // Generar posiciones aleatorias para ambas palabras
    // Mantener cierta separación horizontal para el efecto de dualidad
    float xPos1 = ofRandom(ofGetWidth() * 0.1f, ofGetWidth() * 0.4f);
    float xPos2 = ofRandom(ofGetWidth() * 0.6f, ofGetWidth() * 0.9f);
    float yPos = ofRandom(ofGetHeight() * 0.2f, ofGetHeight() * 0.8f);
    
    // Crear primera palabra del par (izquierda)
    WordInstance word1;
    word1.setup(
        pair.first,                      // Texto: primera palabra
        ofPoint(xPos1, yPos),           // Posición aleatoria izquierda
        2.5f,                            // Tamaño grande para impacto
        ofColor(255, 100, 150),         // Color rosa/rojo
        300.0f                           // 5 segundos de vida a 60fps
    );
    words.push_back(word1);
    
    // Crear segunda palabra del par (derecha)
    WordInstance word2;
    word2.setup(
        pair.second,                     // Texto: segunda palabra
        ofPoint(xPos2, yPos),           // Posición aleatoria derecha (misma altura)
        2.5f,                            // Mismo tamaño
        ofColor(100, 150, 255),         // Color azul/cyan (complementario)
        300.0f                           // Misma duración
    );
    words.push_back(word2);
    
    ofLogNotice("ofApp") << "Nuevo par spawneado: " 
                         << pair.first << " / " << pair.second;
}
