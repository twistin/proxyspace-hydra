#pragma once

#include "ofMain.h"

/**
 * WordInstance: Representa una palabra individual en pantalla.
 * 
 * Propiedades:
 * - pos: posición en 2D
 * - color: color base (RGB)
 * - size: tamaño de la palabra (usado al dibujar)
 * - alpha: transparencia (0-255); se hace fade out con el tiempo
 * - text: contenido de la palabra
 * - timeToLive: contador de tiempo en frames; se reduce cada update
 * 
 * Flujo:
 * 1. setup(...) inicializa la palabra con texto, posición, tamaño, color y vida.
 * 2. update() reduce timeToLive, aplica damping al tamaño y hace fade out del alpha.
 * 3. isDead() devuelve true cuando alpha <= 0 (palabra lista para eliminar).
 * 4. draw(...) renderiza la palabra usando la fuente proporcionada.
 * 5. trigger(...) reactiva la palabra cambiando su tamaño y reiniciando su vida.
 */
class WordInstance {
public:
    // Propiedades
    ofPoint pos;           // Posición en pantalla (x, y)
    ofColor color;         // Color base de la palabra
    float size;            // Tamaño (escala) actual de la palabra
    float alpha;           // Transparencia (0-255)
    std::string text;      // Texto de la palabra
    float timeToLive;      // Tiempo restante en frames (countdown)

    // Constructor por defecto
    WordInstance();

    /**
     * Inicializa la palabra con todos sus parámetros.
     * @param t Texto a mostrar
     * @param p Posición inicial
     * @param s Tamaño inicial
     * @param c Color base
     * @param life Tiempo de vida inicial (frames)
     */
    void setup(std::string t, ofPoint p, float s, ofColor c, float life);

    /**
     * Actualiza el estado de la palabra cada frame:
     * - Reduce timeToLive
     * - Aplica damping al tamaño (size *= 0.95)
     * - Hace fade out del alpha cuando timeToLive se agota
     */
    void update();

    /**
     * Comprueba si la palabra ha terminado su ciclo de vida.
     * @return true si alpha <= 0 (palabra invisible/muerta)
     */
    bool isDead();

    /**
     * Dibuja la palabra en pantalla usando la fuente proporcionada.
     * Aplica el tamaño, color y alpha actuales.
     * @param font Fuente TrueType para renderizar el texto
     */
    void draw(ofTrueTypeFont &font);

    /**
     * "Reactiva" la palabra cambiando su tamaño y reiniciando su vida.
     * Útil para efectos de pulso o trigger OSC.
     * @param newSize Nuevo tamaño (escala) para la palabra
     */
    void trigger(float newSize);

private:
    float maxTimeToLive;   // Valor inicial de timeToLive (para calcular fade out)
};
