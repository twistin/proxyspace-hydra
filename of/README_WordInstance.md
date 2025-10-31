# WordInstance - Clase para Palabras Animadas en openFrameworks

Clase C++ completa que representa una palabra individual en pantalla con efectos de fade out, damping y triggers.

## Archivos

- `WordInstance.h` - Header con declaración de propiedades y métodos
- `WordInstance.cpp` - Implementación completa

## Propiedades

```cpp
ofPoint pos;           // Posición en pantalla (x, y)
ofColor color;         // Color base de la palabra
float size;            // Tamaño (escala) actual
float alpha;           // Transparencia (0-255)
std::string text;      // Texto a mostrar
float timeToLive;      // Contador de vida (frames)
```

## Métodos Públicos

### `void setup(string t, ofPoint p, float s, ofColor c, float life)`
Inicializa la palabra con todos sus parámetros.

**Parámetros:**
- `t` - Texto a mostrar
- `p` - Posición inicial (ofPoint)
- `s` - Tamaño inicial (escala)
- `c` - Color base (ofColor)
- `life` - Tiempo de vida en frames

### `void update()`
Actualiza el estado cada frame:
1. Reduce `timeToLive` en 1.0
2. Aplica damping al tamaño: `size *= 0.95` (convergencia suave)
3. Hace fade out del alpha cuando quedan menos del 30% de frames

### `bool isDead()`
Devuelve `true` si `alpha <= 0` (palabra lista para eliminar).

### `void draw(ofTrueTypeFont &font)`
Dibuja la palabra en pantalla:
- Aplica transformación a `pos`
- Escala según `size`
- Aplica `color` con `alpha`
- Centra el texto en la posición

### `void trigger(float newSize)`
Reactiva la palabra:
- Establece nuevo `size`
- Reinicia `timeToLive` al valor máximo
- Restaura `alpha` a 255

## Ejemplo de Uso

### ofApp.h
```cpp
#pragma once

#include "ofMain.h"
#include "WordInstance.h"

class ofApp : public ofBaseApp {
public:
    void setup();
    void update();
    void draw();
    void keyPressed(int key);

    // Lista de palabras
    vector<WordInstance> words;
    
    // Fuente para renderizar
    ofTrueTypeFont font;
};
```

### ofApp.cpp
```cpp
#include "ofApp.h"

void ofApp::setup() {
    ofSetFrameRate(60);
    ofBackground(0);
    
    // Cargar fuente
    font.load("fonts/verdana.ttf", 48, true, true);
    font.setLetterSpacing(1.037);
    
    // Crear una palabra de ejemplo
    WordInstance word;
    word.setup(
        "DEVENIR",                        // texto
        ofPoint(ofGetWidth()/2, ofGetHeight()/2), // posición centrada
        1.5f,                             // tamaño inicial
        ofColor(255, 100, 200),          // color rosa
        180.0f                            // vida: 3 segundos a 60fps
    );
    words.push_back(word);
}

void ofApp::update() {
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

void ofApp::draw() {
    // Dibujar todas las palabras
    for (auto &word : words) {
        word.draw(font);
    }
    
    // Info en pantalla
    ofSetColor(255);
    ofDrawBitmapString("Palabras activas: " + ofToString(words.size()), 20, 20);
}

void ofApp::keyPressed(int key) {
    if (key == ' ') {
        // Trigger: reactivar todas las palabras con nuevo tamaño
        for (auto &word : words) {
            word.trigger(2.0f + ofRandom(1.0f));
        }
    }
    
    if (key == 'n') {
        // Crear nueva palabra en posición aleatoria
        WordInstance newWord;
        newWord.setup(
            "PALABRA",
            ofPoint(ofRandom(ofGetWidth()), ofRandom(ofGetHeight())),
            1.2f,
            ofColor(ofRandom(255), ofRandom(255), ofRandom(255)),
            120.0f
        );
        words.push_back(newWord);
    }
}
```

## Características Implementadas

### Fade Out Progresivo
- Cuando quedan menos del 30% de frames (`timeToLive / maxTimeToLive < 0.3`), el alpha empieza a bajar
- Mapeo lineal: 30% vida → alpha 255, 0% vida → alpha 0
- Transición suave y visible

### Damping del Tamaño
- Cada frame: `size *= 0.95`
- Convergencia exponencial hacia tamaño base
- Efecto de "rebote" o "elasticidad"

### Dibujo Centrado
- Calcula bounding box del texto
- Ajusta posición para que el centro del texto coincida con `pos`
- Transformaciones con push/pop para no afectar otros elementos

### Trigger Reactivo
- Reinicia vida completa
- Cambia tamaño (útil para pulsos OSC)
- Restaura opacidad

## Integración con OSC

Para usar con mensajes OSC de SuperCollider:

```cpp
// En tu ofApp.h
#include "ofxOsc.h"

ofxOscReceiver oscReceiver;

// En ofApp::setup()
oscReceiver.setup(12345);

// En ofApp::update()
while (oscReceiver.hasWaitingMessages()) {
    ofxOscMessage msg;
    oscReceiver.getNextMessage(msg);
    
    if (msg.getAddress() == "/kick") {
        float value = msg.getArgAsFloat(0);
        
        // Trigger todas las palabras con intensidad según valor OSC
        for (auto &word : words) {
            word.trigger(1.0f + value * 2.0f);
        }
    }
}
```

## Notas de Implementación

1. **Thread Safety**: La clase no es thread-safe. Si usas OSC en otro thread, protege el acceso a `words` con mutex.

2. **Fuentes**: Asegúrate de cargar la fuente antes de llamar a `draw()`. Si la fuente no está cargada, `font.drawString()` no hará nada.

3. **Optimización**: Para muchas palabras (>100), considera usar instanced rendering o VBOs en lugar de dibujar cada una individualmente.

4. **Damping Ajustable**: El valor `0.95` en `update()` es configurable. Valores más cercanos a 1.0 hacen el damping más lento.

5. **Fade Out Threshold**: El umbral `0.3f` (30%) es ajustable. Valores más altos hacen que el fade empiece antes.

## Compilación

Añade los archivos al proyecto openFrameworks:

1. Copia `WordInstance.h` y `WordInstance.cpp` a `src/`
2. Si usas Xcode/Visual Studio, añade los archivos al proyecto
3. Si usas Makefile, asegúrate de que `src/*.cpp` esté incluido

## Dependencias

- openFrameworks 0.11.0 o superior
- Addon `ofxOsc` (opcional, solo para recepción OSC)

## Próximos Pasos

1. Crear una clase `WordPairScene` que gestione pares de palabras
2. Implementar posicionamiento dinámico (columnas, grids)
3. Añadir efectos de partículas o trails
4. Integrar con el flujo OSC completo desde SuperCollider
