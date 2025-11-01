#include "ofApp.h"
#include <array>
#include <algorithm>

//--------------------------------------------------------------
void ofApp::setup() {
    ofSetFrameRate(60);
    ofSetVerticalSync(true);
    
    // Color de fondo negro
    bgColor = ofColor(0, 0, 0);
    
    // Iniciar en escena LANDSCAPES
    currentScene = LANDSCAPES;
    currentLandscapeIndex = 0;
    
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
    hasPreviousLandscape = false;
    transitionActive = false;
    transitionProgress = 1.0f;
    transitionDuration = 1.5f;
    landscapeTime = 0.0f;
    meshColumns = 60;
    meshRows = 40;
    
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
                if (landscapeImages.empty()) {
                    ofLogWarning("ofApp") << "Kick recibido pero no hay imagenes en of/bin/data/landscapes/";
                } else {
                    if (landscapeImages[currentLandscapeIndex].isAllocated()) {
                        previousLandscape = landscapeImages[currentLandscapeIndex];
                        hasPreviousLandscape = true;
                    }
                    currentLandscapeIndex = (currentLandscapeIndex + 1) % landscapeImages.size();
                    transitionActive = true;
                    transitionProgress = 0.0f;
                    landscapeTime = 0.0f;
                }

                // Pulso de erosión momentáneo
                erosionAmount = ofClamp(erosionAmount + 0.3f, 0.0f, 1.0f);
                
                // Activar efectos si aún no están activos
                if (!effectsEnabled) {
                    effectsEnabled = true;
                    ofLogNotice("ofApp") << "Efectos LANDSCAPES activados";
                }
                
                if (!landscapeImages.empty()) {
                    ofLogNotice("ofApp") << "Kick: transición a imagen " << currentLandscapeIndex;
                }
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
                    globalIntensity = ofMap(bassLevel, 0.0f, 1.0f, 0.08f, 1.0f, true);
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
    }

    if (currentScene == LANDSCAPES) {
        landscapeTime += ofGetLastFrameTime();
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
    if (landscapeImages.empty() || currentLandscapeIndex >= landscapeImages.size()) {
        ofSetColor(180);
        const std::string msg = "LANDSCAPES\nColoca imágenes en livecoding/of/bin/data/landscapes/";
        ofDrawBitmapString(msg, ofGetWidth() * 0.5f - 180.0f, ofGetHeight() * 0.5f);
        return;
    }

    ensureLandscapeBuffers();
    updateLandscapeTransition(ofGetLastFrameTime());

    const ofImage& currentImage = landscapeImages[currentLandscapeIndex];
    if (!currentImage.isAllocated()) {
        ofSetColor(255);
        ofDrawBitmapString("Imagen inválida en LANDSCAPES", 40, 40);
        return;
    }

    // Calcular dimensiones respetando aspecto
    const float screenRatio = static_cast<float>(ofGetWidth()) / static_cast<float>(ofGetHeight());
    const float imgRatio = static_cast<float>(currentImage.getWidth()) / static_cast<float>(currentImage.getHeight());

    float drawWidth = 0.0f;
    float drawHeight = 0.0f;
    if (screenRatio > imgRatio) {
        drawWidth = ofGetWidth();
        drawHeight = drawWidth / imgRatio;
    } else {
        drawHeight = ofGetHeight();
        drawWidth = drawHeight * imgRatio;
    }
    const float originX = (ofGetWidth() - drawWidth) * 0.5f;
    const float originY = (ofGetHeight() - drawHeight) * 0.5f;

    updateLandscapeMesh(drawWidth, drawHeight, currentImage.getWidth(), currentImage.getHeight(), originX, originY);

    landscapeFbo.begin();
    ofEnableAlphaBlending();
    ofClear(0, 0, 0, 0);

    if (transitionActive && hasPreviousLandscape && previousLandscape.isAllocated()) {
        const float previousAlpha = ofMap(transitionProgress, 0.0f, 1.0f, 255.0f, 0.0f, true);
        drawLandscapeToFbo(previousLandscape, drawWidth, drawHeight, originX, originY, previousAlpha);
    }

    const float baseAlpha = 255.0f * imageReveal;
    ofSetColor(255, baseAlpha);
    currentImage.getTexture().bind();
    landscapeMesh.draw();
    currentImage.getTexture().unbind();

    if (effectsEnabled && globalIntensity > 0.01f) {
        const float time = landscapeTime * 0.35f;
        const float erosionStrength = ofClamp(erosionAmount * globalIntensity, 0.0f, 1.0f);

        // Erosión orgánica con ruido perlin
        if (erosionStrength > 0.01f) {
            ofPushStyle();
            ofEnableBlendMode(OF_BLENDMODE_MULTIPLY);
            const int cells = 72;
            const float cellW = drawWidth / cells;
            const float cellH = drawHeight / cells;
            for (int y = 0; y < cells; ++y) {
                for (int x = 0; x < cells; ++x) {
                    const float u = static_cast<float>(x) / cells;
                    const float v = static_cast<float>(y) / cells;
                    const float noiseVal = ofNoise(u * 2.4f + time, v * 2.4f + time * 0.8f);
                    const float alpha = ofMap(noiseVal, 0.35f, 0.75f, 0.0f, 180.0f * erosionStrength, true);
                    if (alpha <= 2.0f) {
                        continue;
                    }
                    ofSetColor(0, 0, 0, alpha);
                    ofDrawRectangle(originX + x * cellW, originY + y * cellH, cellW * 1.2f, cellH * 1.2f);
                }
            }
            ofDisableBlendMode();
            ofPopStyle();
        }

        // Tinte cromático
        if (tintColor.getSaturation() > 10) {
            const float tintAlpha = ofMap(tintColor.getSaturation(), 10, 255, 0, 140, true) * globalIntensity;
            ofSetColor(tintColor, tintAlpha);
            ofDrawRectangle(originX, originY, drawWidth, drawHeight);
        }

        // Vignette suave
        ofMesh vignette;
        vignette.setMode(OF_PRIMITIVE_TRIANGLE_FAN);
        const glm::vec2 centre(ofGetWidth() * 0.5f, ofGetHeight() * 0.5f);
        vignette.addVertex(glm::vec3(centre, 0.0f));
        vignette.addColor(ofColor(0, 0, 0, 0));
        const float vignetteAlpha = ofMap(globalIntensity, 0.0f, 1.0f, 0.0f, 190.0f, true);
        std::array<glm::vec2, 4> corners = {
            glm::vec2(0, 0),
            glm::vec2(ofGetWidth(), 0),
            glm::vec2(ofGetWidth(), ofGetHeight()),
            glm::vec2(0, ofGetHeight())
        };
        for (const auto& corner : corners) {
            vignette.addVertex(glm::vec3(corner, 0.0f));
            vignette.addColor(ofColor(0, 0, 0, vignetteAlpha));
        }
        ofEnableAlphaBlending();
        vignette.draw();
        ofDisableAlphaBlending();
    }

    landscapeFbo.end();

    if (feedbackInit && globalIntensity > 0.02f) {
        ofSetColor(255, ofMap(globalIntensity, 0.0f, 1.0f, 0, 160, true));
        feedbackFbo.draw(0, 0);
    }

    ofSetColor(255);
    landscapeFbo.draw(0, 0);

    updateFeedbackBuffer();
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
    ensureLandscapeBuffers();
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg) {
    
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo) {
    
}

//--------------------------------------------------------------
void ofApp::ensureLandscapeBuffers() {
    const int width = ofGetWidth();
    const int height = ofGetHeight();

    if (!landscapeFbo.isAllocated() ||
        landscapeFbo.getWidth() != width ||
        landscapeFbo.getHeight() != height) {
        landscapeFbo.allocate(width, height, GL_RGBA);
        landscapeFbo.begin();
        ofClear(0, 0, 0, 0);
        landscapeFbo.end();
    }

    if (!feedbackFbo.isAllocated() ||
        feedbackFbo.getWidth() != width ||
        feedbackFbo.getHeight() != height) {
        feedbackFbo.allocate(width, height, GL_RGBA);
        feedbackFbo.begin();
        ofClear(0, 0, 0, 255);
        feedbackFbo.end();
        feedbackInit = true;
    }
}

//--------------------------------------------------------------
void ofApp::updateLandscapeTransition(float deltaSeconds) {
    if (!transitionActive) {
        return;
    }
    if (transitionDuration <= 0.0f) {
        transitionProgress = 1.0f;
        transitionActive = false;
        hasPreviousLandscape = false;
        return;
    }

    transitionProgress += deltaSeconds / transitionDuration;
    if (transitionProgress >= 1.0f) {
        transitionProgress = 1.0f;
        transitionActive = false;
        hasPreviousLandscape = false;
    }
}

//--------------------------------------------------------------
void ofApp::updateLandscapeMesh(float drawWidth, float drawHeight, float imgWidth, float imgHeight, float originX, float originY) {
    const int cols = std::max(1, meshColumns);
    const int rows = std::max(1, meshRows);

    landscapeMesh.clear();
    baseMeshVertices.clear();
    landscapeMesh.setMode(OF_PRIMITIVE_TRIANGLES);
    baseMeshVertices.reserve((cols + 1) * (rows + 1));

    for (int row = 0; row <= rows; ++row) {
        const float v = static_cast<float>(row) / rows;
        for (int col = 0; col <= cols; ++col) {
            const float u = static_cast<float>(col) / cols;
            const float px = originX + u * drawWidth;
            const float py = originY + v * drawHeight;
            landscapeMesh.addVertex(glm::vec3(px, py, 0.0f));
            baseMeshVertices.emplace_back(px, py, 0.0f);
            landscapeMesh.addTexCoord(glm::vec2(u * imgWidth, v * imgHeight));
        }
    }

    const int stride = cols + 1;
    for (int row = 0; row < rows; ++row) {
        for (int col = 0; col < cols; ++col) {
            const int i1 = row * stride + col;
            const int i2 = i1 + 1;
            const int i3 = i1 + stride;
            const int i4 = i3 + 1;
            landscapeMesh.addIndex(i1);
            landscapeMesh.addIndex(i3);
            landscapeMesh.addIndex(i2);
            landscapeMesh.addIndex(i2);
            landscapeMesh.addIndex(i3);
            landscapeMesh.addIndex(i4);
        }
    }

    const float time = landscapeTime;
    const float displacement = waveDisplacement;
    const float effectIntensity = effectsEnabled ? globalIntensity : 0.0f;

    for (std::size_t i = 0; i < landscapeMesh.getNumVertices(); ++i) {
        const glm::vec3 base = baseMeshVertices[i];
        const glm::vec2 texCoord = landscapeMesh.getTexCoord(i);
        const float u = imgWidth > 0.0f ? texCoord.x / imgWidth : 0.0f;
        const float v = imgHeight > 0.0f ? texCoord.y / imgHeight : 0.0f;

        const float waveHorizontal = sinf((u * 8.0f + time * 0.8f) * TWO_PI) * displacement * 0.35f;
        const float waveVertical = sinf((v * 6.0f + time * 0.6f) * TWO_PI) * displacement * 0.2f;
        const float erosionField = (ofNoise(u * 2.0f + time * 0.3f, v * 2.0f + time * 0.3f) - 0.5f) * erosionAmount * 120.0f;
        const float depth = (ofNoise(u * 4.0f, v * 4.0f, time * 0.5f) - 0.5f) * 18.0f * effectIntensity;

        const glm::vec3 offset((waveHorizontal + waveVertical) * effectIntensity,
                               erosionField * effectIntensity,
                               depth);
        landscapeMesh.setVertex(i, base + offset);
    }
}

//--------------------------------------------------------------
void ofApp::updateFeedbackBuffer() {
    if (!feedbackFbo.isAllocated() || !landscapeFbo.isAllocated()) {
        return;
    }
    feedbackFbo.begin();
    ofEnableAlphaBlending();
    const float fadeAlpha = ofMap(feedbackDecay, 0.85f, 0.99f, 42.0f, 6.0f, true);
    ofSetColor(0, 0, 0, fadeAlpha);
    ofDrawRectangle(0, 0, feedbackFbo.getWidth(), feedbackFbo.getHeight());
    ofSetColor(255);
    landscapeFbo.draw(0, 0);
    feedbackFbo.end();
}

//--------------------------------------------------------------
void ofApp::drawLandscapeToFbo(const ofImage& img, float drawWidth, float drawHeight, float originX, float originY, float alpha) {
    if (!img.isAllocated() || alpha <= 0.0f) {
        return;
    }
    ofPushStyle();
    ofSetColor(255, alpha);
    img.draw(originX, originY, drawWidth, drawHeight);
    ofPopStyle();
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
