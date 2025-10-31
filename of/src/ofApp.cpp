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

//--------------------------------------------------------------
void ofApp::update() {
    // Procesar mensajes OSC entrantes
    while (oscReceiver.hasWaitingMessages()) {
        ofxOscMessage msg;
        oscReceiver.getNextMessage(msg);
        
        ofLogVerbose("ofApp") << "OSC recibido: " << msg.getAddress();
        
        // /kick - Comportamiento según escena
        if (msg.getAddress() == "/kick") {
            if (currentScene == DUALISMOS) {
                spawnNewPair();
                
                // Solo trigger simple - los efectos se controlan con OSC
                for (auto &word : words) {
                    word.trigger(100.0f);
                    
                    // Reset de efectos al valor actual (no aleatorio)
                    // Los valores se controlan con /bass_level, /melody_note, /texture
                }
                ofLogNotice("ofApp") << "Kick recibido: nuevo par creado";
            } 
            else if (currentScene == LANDSCAPES) {
                // KICK: Cambiar imagen (transición suave)
                currentLandscapeIndex = (currentLandscapeIndex + 1) % landscapeImages.size();
                
                // Pulso de erosión momentáneo
                erosionAmount = ofClamp(erosionAmount + 0.3f, 0.0f, 1.0f);
                
                // Activar efectos si aún no están activos
                if (!effectsEnabled) {
                    effectsEnabled = true;
                    ofLogNotice("ofApp") << "Efectos LANDSCAPES activados";
                }
                
                ofLogNotice("ofApp") << "Kick: cambio a imagen " << currentLandscapeIndex;
            }
        }
        
        // /bass_level - Control continuo de intensidad
        if (msg.getAddress() == "/bass_level") {
            if (msg.getNumArgs() > 0) {
                float bassLevel = msg.getArgAsFloat(0);
                
                if (currentScene == DUALISMOS) {
                    // Controlar brillo del fondo
                    float brightness = ofMap(bassLevel, 0.0f, 1.0f, 0.0f, 80.0f, true);
                    bgColor = ofColor(brightness * 0.8, brightness * 0.4, brightness);
                    
                    // Tamaño de palabras según bass
                    wordSizeMultiplier = ofMap(bassLevel, 0.0f, 1.0f, 0.8f, 1.3f, true);
                    
                    // Rotación continua según bass
                    for (auto &word : words) {
                        word.rotation = ofMap(bassLevel, 0.0f, 1.0f, -30, 30, true);
                    }
                } 
                else if (currentScene == LANDSCAPES) {
                    // BASS: Erosión sonora + blur dinámico
                    erosionAmount = ofMap(bassLevel, 0.0f, 1.0f, 0.0f, 0.8f, true);
                    blurAmount = ofMap(bassLevel, 0.0f, 1.0f, 0.0f, 15.0f, true);
                    
                    // Intensidad global de efectos
                    globalIntensity = ofMap(bassLevel, 0.0f, 1.0f, 0.0f, 1.0f, true);
                }
            }
        }
        
        // /melody_note - Control de color/tinte
        if (msg.getAddress() == "/melody_note") {
            if (msg.getNumArgs() > 0) {
                float note = msg.getArgAsFloat(0);
                
                if (currentScene == DUALISMOS) {
                    // Color de palabras (dinámico)
                    if (words.size() > 0) {
                        float hue = (note > 1.0f) ? 
                            ofMap(note, 0, 127, 0, 255) : 
                            ofMap(note, 0.0f, 1.0f, 0, 255);
                        
                        ofColor newColor = ofColor::fromHsb(hue, 255, 255);
                        int randomIndex = ofRandom(words.size());
                        words[randomIndex].color = newColor;
                        
                        // Dispersión de letras según melodía
                        for (auto &word : words) {
                            word.disperseAmount = ofMap(note, 0.0f, 1.0f, 0, 100, true);
                        }
                    }
                }
                else if (currentScene == LANDSCAPES) {
                    // MELODY: Revelación progresiva + tinte de color
                    float hue = (note > 1.0f) ? 
                        ofMap(note, 0, 127, 0, 255) :
                        ofMap(note, 0.0f, 1.0f, 0, 255);
                    
                    // Controlar revelación (0 = oscuro, 1 = visible)
                    imageReveal = ofMap(note, 0.0f, 1.0f, 0.3f, 1.0f, true);
                    
                    // Tinte sutil basado en melodía
                    float saturation = ofMap(note, 0.0f, 1.0f, 0, 120, true);
                    tintColor = ofColor::fromHsb(hue, saturation, 255);
                }
            }
        }
        
        // /texture - Control de desplazamiento ondulatorio y feedback
        if (msg.getAddress() == "/texture") {
            if (msg.getNumArgs() > 0) {
                float textureAmount = msg.getArgAsFloat(0);
                
                if (currentScene == LANDSCAPES) {
                    // TEXTURE: Wave displacement + feedback decay
                    waveDisplacement = ofMap(textureAmount, 0.0f, 1.0f, 0.0f, 30.0f, true);
                    feedbackDecay = ofMap(textureAmount, 0.0f, 1.0f, 0.98f, 0.85f, true);
                }
                else if (currentScene == DUALISMOS) {
                    // Glitch tipográfico según texture
                    for (auto &word : words) {
                        word.glitchAmount = ofMap(textureAmount, 0.0f, 1.0f, 0.0f, 0.8f, true);
                    }
                }
            }
        }
        
        // /contrast - NUEVO: Controlar rotación de palabras (DUALISMOS)
        if (msg.getAddress() == "/contrast") {
            if (msg.getNumArgs() > 0 && currentScene == DUALISMOS) {
                float contrast = msg.getArgAsFloat(0);
                rotationSpeed = ofMap(contrast, 0.0f, 1.0f, 0.0f, 2.0f, true);
            }
        }
    }
    
    // Actualizar según escena
    if (currentScene == DUALISMOS) {
        // Actualizar todas las palabras
        for (auto &word : words) {
            word.update();
        }
        
        // Eliminar palabras muertas
        words.erase(
            std::remove_if(words.begin(), words.end(),
                [](WordInstance &w) { return w.isDead(); }),
            words.end()
        );
    }
    else if (currentScene == LANDSCAPES) {
        // Decay suave de efectos (vuelven a estado base gradualmente)
        erosionAmount *= 0.95f;       // Erosión se desvanece
        waveDisplacement *= 0.93f;    // Ondulación se calma
        feedbackDecay += (0.98f - feedbackDecay) * 0.05f; // Feedback vuelve a decay alto
        
        // Inicializar FBO para feedback si es necesario
        if (!feedbackInit && landscapeImages.size() > 0) {
            feedbackFbo.allocate(ofGetWidth(), ofGetHeight(), GL_RGBA);
            feedbackFbo.begin();
            ofClear(0, 0, 0, 255);
            feedbackFbo.end();
            feedbackInit = true;
        }
        
        // Actualizar FBO con frame actual (para feedback visual)
        if (feedbackInit) {
            feedbackFbo.begin();
            ofClear(0, 0, 0, 0);
            // Aquí se dibuja el contenido actual (se hace en draw())
            feedbackFbo.end();
        }
    }
}

//--------------------------------------------------------------
void ofApp::draw() {
    // Limpiar ventana completamente con fondo negro
    ofBackground(0);
    
    // Dibujar según escena actual
    if (currentScene == LANDSCAPES) {
        drawLandscapes();
    } 
    else if (currentScene == DUALISMOS) {
        drawDualismos();
    }
    
    // === INFORMACIÓN DE DEBUG CON FONDO LEGIBLE ===
    // Fondo oscuro semitransparente para info
    ofSetColor(0, 0, 0, 180);
    ofDrawRectangle(10, 10, 300, 90);
    
    // Texto de información
    ofSetColor(0, 255, 100, 255);
    ofDrawBitmapString("FPS: " + ofToString(ofGetFrameRate(), 1), 20, 25);
    
    // Info según escena
    if (currentScene == LANDSCAPES) {
        ofSetColor(100, 200, 255, 255);
        ofDrawBitmapString("ESCENA: LANDSCAPES (1)", 20, 45);
        ofSetColor(150, 150, 150, 255);
        ofDrawBitmapString("Efectos: " + string(effectsEnabled ? "ON" : "OFF"), 20, 65);
        ofDrawBitmapString("Erosion: " + ofToString(erosionAmount, 2) + 
                          " | Reveal: " + ofToString(imageReveal, 2), 20, 85);
    } 
    else if (currentScene == DUALISMOS) {
        ofSetColor(255, 150, 100, 255);
        ofDrawBitmapString("ESCENA: DUALISMOS (2)", 20, 45);
        ofSetColor(150, 150, 150, 255);
        ofDrawBitmapString("Palabras activas: " + ofToString(words.size()), 20, 65);
        ofDrawBitmapString("Set: " + ofToString(currentDualitySet) + 
                          " (3-5 para cambiar)", 20, 85);
    }
    
    // === CONTROLES CON FONDO ===
    // Fondo oscuro para controles
    ofSetColor(0, 0, 0, 180);
    ofDrawRectangle(10, ofGetHeight() - 100, 200, 90);
    
    // Instrucciones
    ofSetColor(200, 200, 200, 255);
    ofDrawBitmapString("Controles:", 20, ofGetHeight() - 85);
    ofSetColor(150, 150, 150, 255);
    ofDrawBitmapString("  1: LANDSCAPES", 20, ofGetHeight() - 65);
    ofDrawBitmapString("  2: DUALISMOS", 20, ofGetHeight() - 45);
    ofDrawBitmapString("  3-5: Sets (DUAL)", 20, ofGetHeight() - 25);
}

//--------------------------------------------------------------
void ofApp::drawLandscapes() {
    // Verificar que hay imágenes
    if (landscapeImages.size() == 0 || currentLandscapeIndex >= landscapeImages.size()) {
        ofSetColor(255);
        string msg = "LANDSCAPES\nColoca imagenes en: of/bin/data/landscapes/";
        ofDrawBitmapString(msg, ofGetWidth()/2 - 150, ofGetHeight()/2);
        return;
    }
    
    // === FASE 1: IMAGEN BASE NÍTIDA (Soundscape puro) ===
    
    ofPushMatrix();
    ofPushStyle();
    
    // Calcular tamaño para cubrir ventana
    float screenRatio = (float)ofGetWidth() / (float)ofGetHeight();
    float imgRatio = landscapeImages[currentLandscapeIndex].getWidth() / 
                    landscapeImages[currentLandscapeIndex].getHeight();
    
    float drawWidth, drawHeight;
    if (screenRatio > imgRatio) {
        drawWidth = ofGetWidth();
        drawHeight = drawWidth / imgRatio;
    } else {
        drawHeight = ofGetHeight();
        drawWidth = drawHeight * imgRatio;
    }
    
    float x = (ofGetWidth() - drawWidth) / 2.0f;
    float y = (ofGetHeight() - drawHeight) / 2.0f;
    
    // === EFECTO 1: REVELACIÓN PROGRESIVA (Fade in según melody) ===
    float finalAlpha = 255 * imageReveal;
    ofSetColor(255, 255, 255, finalAlpha);
    
    // Dibujar imagen base
    landscapeImages[currentLandscapeIndex].draw(x, y, drawWidth, drawHeight);
    
    // === FASE 2: EFECTOS SONOROS (Solo si están habilitados) ===
    
    if (effectsEnabled && globalIntensity > 0.01f) {
        
        // === EFECTO 2: EROSIÓN SONORA (Bass-driven dissolution) ===
        if (erosionAmount > 0.1f) {
            ofEnableBlendMode(OF_BLENDMODE_MULTIPLY);
            
            // Patrón de ruido erosivo
            int numBlocks = 30 + (int)(erosionAmount * 100);
            for (int i = 0; i < numBlocks; i++) {
                float blockX = ofRandom(ofGetWidth());
                float blockY = ofRandom(ofGetHeight());
                float blockSize = ofRandom(10, 80) * erosionAmount;
                
                float alpha = erosionAmount * 100;
                ofSetColor(0, 0, 0, alpha);
                ofDrawRectangle(blockX, blockY, blockSize, blockSize);
            }
            
            ofDisableBlendMode();
        }
        
        // === EFECTO 3: WAVE DISPLACEMENT (Texture-driven vibration) ===
        if (waveDisplacement > 5.0f) {
            ofPushMatrix();
            
            // Ondulación en franjas horizontales
            int numStrips = 20;
            float stripHeight = ofGetHeight() / numStrips;
            
            for (int i = 0; i < numStrips; i++) {
                float phase = ofGetElapsedTimef() * 3.0f + i * 0.5f;
                float offsetX = sin(phase) * waveDisplacement;
                
                ofSetColor(255, 255, 255, 180);
                
                float srcY = i * stripHeight;
                float imgSrcY = srcY * (landscapeImages[currentLandscapeIndex].getHeight() / drawHeight);
                float imgStripHeight = stripHeight * (landscapeImages[currentLandscapeIndex].getHeight() / drawHeight);
                
                landscapeImages[currentLandscapeIndex].drawSubsection(
                    x + offsetX, y + srcY,
                    drawWidth, stripHeight,
                    0, imgSrcY,
                    landscapeImages[currentLandscapeIndex].getWidth(), imgStripHeight
                );
            }
            
            ofPopMatrix();
        }
        
        // === EFECTO 4: TINTE DE COLOR (Melody-driven hue) ===
        if (tintColor.getSaturation() > 10) {
            ofEnableBlendMode(OF_BLENDMODE_MULTIPLY);
            float tintAlpha = ofMap(tintColor.getSaturation(), 10, 255, 0, 150, true);
            ofSetColor(tintColor, tintAlpha * globalIntensity);
            ofDrawRectangle(x, y, drawWidth, drawHeight);
            ofDisableBlendMode();
        }
        
        // === EFECTO 5: FEEDBACK LOOP (Echo visual / Memoria) ===
        if (feedbackInit && feedbackDecay < 0.97f) {
            ofEnableBlendMode(OF_BLENDMODE_ALPHA);
            float feedbackAlpha = ofMap(feedbackDecay, 0.85f, 0.97f, 200, 245, true);
            ofSetColor(255, 255, 255, feedbackAlpha);
            feedbackFbo.draw(0, 0);
            ofDisableBlendMode();
        }
    }
    
    ofPopStyle();
    ofPopMatrix();
}

//--------------------------------------------------------------
void ofApp::drawDualismos() {
    ofBackground(bgColor);
    
    // Dibujar todas las palabras
    for (auto &word : words) {
        word.draw(font);
    }
}

//--------------------------------------------------------------
void ofApp::changeScene(Scene newScene) {
    if (currentScene != newScene) {
        currentScene = newScene;
        ofLogNotice("ofApp") << "Cambio a escena: " << 
            (currentScene == LANDSCAPES ? "LANDSCAPES" : "DUALISMOS");
    }
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key) {
    // Cambio de escenas
    if (key == '1') {
        changeScene(LANDSCAPES);
    }
    if (key == '2') {
        changeScene(DUALISMOS);
    }
    
    // 'c': limpiar escena
    if (key == 'c') {
        if (currentScene == DUALISMOS) {
            words.clear();
            ofLogNotice("ofApp") << "Palabras eliminadas";
        }
    }
    
    // Controles específicos de DUALISMOS
    if (currentScene == DUALISMOS) {
        // ESPACIO: trigger todas las palabras
        if (key == ' ') {
            for (auto &word : words) {
                word.trigger(2.0f + ofRandom(1.0f));
            }
            ofLogNotice("ofApp") << "Trigger manual de todas las palabras";
        }
        
        // 'n': crear nueva dualidad
        if (key == 'n') {
            spawnNewPair();
            ofLogNotice("ofApp") << "Nueva dualidad creada manualmente";
        }
        
        // '3','4','5': cambiar set de dualidades
        if (key == '3') {
            currentDualitySet = 0; // Platón (filosofía)
            ofLogNotice("ofApp") << "SET 0: Dualidades de Platón";
        }
        if (key == '4') {
            currentDualitySet = 1; // Musicales (ritmo/melodía)
            ofLogNotice("ofApp") << "SET 1: Dualidades Musicales";
        }
        if (key == '5') {
            currentDualitySet = 2; // Texturas (contraste)
            ofLogNotice("ofApp") << "SET 2: Dualidades de Textura";
        }
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
    
    // Elegir dualidad según set actual (12 dualidades total: 4 por set)
    int setSize = 4;
    int setStart = currentDualitySet * setSize;
    int setEnd = std::min(setStart + setSize, (int)dualities.size());
    
    int randomIndexInSet = setStart + ofRandom(setEnd - setStart);
    auto &pair = dualities[randomIndexInSet];
    
    // Generar posiciones aleatorias para ambas palabras
    float xPos1 = ofRandom(ofGetWidth() * 0.1f, ofGetWidth() * 0.4f);
    float xPos2 = ofRandom(ofGetWidth() * 0.6f, ofGetWidth() * 0.9f);
    float yPos = ofRandom(ofGetHeight() * 0.2f, ofGetHeight() * 0.8f);
    
    // Tamaño base ajustado por multiplicador (reacciona a bass)
    float finalSize = 1.0f * wordSizeMultiplier;
    
    // Crear primera palabra del par (izquierda)
    WordInstance word1;
    word1.setup(
        pair.first,
        ofPoint(xPos1, yPos),
        finalSize,                       // Tamaño reactivo
        ofColor(255, 100, 150),         // Rosa/rojo
        360.0f                           // 6 segundos
    );
    words.push_back(word1);
    
    // Crear segunda palabra del par (derecha)
    WordInstance word2;
    word2.setup(
        pair.second,
        ofPoint(xPos2, yPos),
        finalSize,                       // Tamaño reactivo
        ofColor(100, 150, 255),         // Azul/cyan
        360.0f                           // 6 segundos
    );
    words.push_back(word2);
    
    ofLogNotice("ofApp") << "Nuevo par (Set " << currentDualitySet << "): " 
                         << pair.first << " / " << pair.second
                         << " | Total palabras: " << words.size()
                         << " | Pos: (" << xPos1 << "," << yPos << ") / (" << xPos2 << "," << yPos << ")";
}
