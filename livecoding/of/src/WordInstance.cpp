#include "WordInstance.h"

// Constructor por defecto
WordInstance::WordInstance() {
    pos = ofPoint(0, 0);
    color = ofColor(255, 255, 255);
    size = 1.0f;
    alpha = 255.0f;
    text = "";
    timeToLive = 0.0f;
    maxTimeToLive = 0.0f;
    
    // Tipografía generativa
    rotation = 0.0f;
    letterSpacing = 0.0f;
    waveOffset = ofRandom(TWO_PI);
    glitchAmount = 0.0f;
    useVerticalText = false;
    disperseAmount = 0.0f;
}

// Inicializa la palabra con todos sus parámetros
void WordInstance::setup(std::string t, ofPoint p, float s, ofColor c, float life) {
    text = t;
    pos = p;
    size = s;
    color = c;
    timeToLive = life;
    maxTimeToLive = life; // Guardamos el valor inicial para calcular fade out
    alpha = 255.0f;       // Empieza completamente opaca
}

// Actualiza el estado de la palabra cada frame
void WordInstance::update() {
    // Reducir tiempo de vida
    timeToLive -= 1.0f;
    
    // NO DAMPING - las palabras se quedan estables
    // size *= 0.85f; // DESACTIVADO - ya no cambia el tamaño
    
    // Fade out progresivo en el último 30% de vida
    float lifeFactor = timeToLive / maxTimeToLive;
    if (lifeFactor < 0.3f) {
        float fadeThreshold = 0.3f;
        alpha = ofMap(lifeFactor, 0.0f, fadeThreshold, 0.0f, 255.0f);
        alpha = ofClamp(alpha, 0.0f, 255.0f);
    }
}

// Comprueba si la palabra ha terminado su ciclo de vida
bool WordInstance::isDead() {
    return alpha <= 0.0f;
}

// Dibuja la palabra en pantalla usando la fuente proporcionada
void WordInstance::draw(ofTrueTypeFont &font) {
    if (text.empty()) return; // Seguridad
    
    ofPushMatrix();
    ofPushStyle();
    
    // Aplicar transformación a la posición
    ofTranslate(pos.x, pos.y);
    
    float scaleFactor = size > 0.0f ? size : 1.0f;
    ofScale(scaleFactor, scaleFactor);
    
    // Rotación generativa
    if (abs(rotation) > 0.1f) {
        ofRotateDeg(rotation);
    }
    
    // === DIBUJAR LETRA POR LETRA CON EFECTOS ===
    
    ofRectangle bbox = font.getStringBoundingBox(text, 0, 0);
    float totalWidth = bbox.width;
    float xPos = -totalWidth / 2.0f; // Centrar
    
    for (size_t i = 0; i < text.length(); i++) {
        string letter = text.substr(i, 1);
        ofRectangle letterBox = font.getStringBoundingBox(letter, 0, 0);
        
        float letterX = xPos;
        float letterY = 0; // Baseline
        
        // EFECTO 1: Onda sinusoidal (siempre activo sutilmente)
        float phase = waveOffset + ofGetElapsedTimef() * 2.0f + i * 0.3f;
        float waveY = sin(phase) * 3.0f;
        letterY += waveY;
        
        // EFECTO 2: Glitch (desplazamiento aleatorio)
        if (glitchAmount > 0.05f) {
            letterX += ofRandom(-glitchAmount * 8, glitchAmount * 8);
            letterY += ofRandom(-glitchAmount * 12, glitchAmount * 12);
            
            // Color glitch aleatorio en algunos caracteres
            if (ofRandom(1.0f) < glitchAmount * 0.3f) {
                ofSetColor(ofRandom(150, 255), ofRandom(100, 255), ofRandom(100, 255), alpha);
            } else {
                ofSetColor(color, alpha);
            }
        } else {
            ofSetColor(color, alpha);
        }
        
        // EFECTO 3: Dispersión radial
        if (disperseAmount > 5.0f) {
            float angle = ofMap(i, 0, text.length() - 1, 0, TWO_PI);
            letterX += cos(angle) * disperseAmount;
            letterY += sin(angle) * disperseAmount;
        }
        
        // EFECTO 4: Modo vertical (reorganiza completamente)
        if (useVerticalText) {
            letterX = -letterBox.width / 2.0f;
            letterY = -totalWidth / 2.0f + i * (letterBox.height + letterSpacing + 5);
        }
        
        // Dibujar la letra
        font.drawString(letter, letterX, letterY);
        
        // Avanzar posición horizontal (para texto normal)
        if (!useVerticalText) {
            xPos += letterBox.width + letterSpacing;
        }
    }
    
    ofPopStyle();
    ofPopMatrix();
}

// "Reactiva" la palabra cambiando su tamaño y reiniciando su vida
void WordInstance::trigger(float newSize) {
    size = newSize;
    timeToLive = maxTimeToLive; // Reiniciar contador de vida
    alpha = 255.0f;              // Restaurar opacidad completa
}
