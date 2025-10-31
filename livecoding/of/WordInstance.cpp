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
	// 1. Reducir tiempo de vida
	timeToLive -= 1.0f;
	if (timeToLive < 0.0f) {
		timeToLive = 0.0f;
	}

	// 2. Aplicar damping al tamaño (convergencia suave hacia tamaño base)
	size *= 0.95f;

	// 3. Hacer fade out del alpha cuando timeToLive se agota
	// Cuando timeToLive llega a 0, alpha debe bajar a 0 progresivamente
	if (maxTimeToLive > 0.0f) {
		// Factor de vida: 1.0 (vida completa) -> 0.0 (sin vida)
		float lifeFactor = timeToLive / maxTimeToLive;
        
		// Fade out más pronunciado en los últimos frames
		// Usamos una curva exponencial para que el fade sea más visible al final
		float fadeThreshold = 0.3f; // Empieza a hacer fade cuando queda 30% de vida
        
		if (lifeFactor < fadeThreshold) {
			// Mapear el rango [0, fadeThreshold] a [0, 1] para calcular fade
			float fadeProgress = lifeFactor / fadeThreshold;
			alpha = 255.0f * fadeProgress;
		} else {
			// Si aún hay suficiente vida, mantener opacidad completa
			alpha = 255.0f;
		}
	} else {
		// Si maxTimeToLive es 0, hacer fade inmediato
		alpha = 0.0f;
	}

	// Asegurar que alpha no sea negativa
	if (alpha < 0.0f) {
		alpha = 0.0f;
	}
}

// Comprueba si la palabra ha terminado su ciclo de vida
bool WordInstance::isDead() {
	return alpha <= 0.0f;
}

// Dibuja la palabra en pantalla usando la fuente proporcionada
void WordInstance::draw(ofTrueTypeFont &font) {
	// Solo dibujar si la palabra está visible (alpha > 0)
	if (alpha <= 0.0f) return;

	// Guardar el estado actual de transformaciones
	ofPushMatrix();
	ofPushStyle();

	// Mover al punto de posición de la palabra
	ofTranslate(pos.x, pos.y);

	// Aplicar escala (size)
	// El tamaño base de la fuente se multiplica por 'size'
	ofScale(size, size);

	// Aplicar color con alpha
	ofColor drawColor = color;
	drawColor.a = static_cast<unsigned char>(alpha);
	ofSetColor(drawColor);

	// Calcular el bounding box del texto para centrarlo
	ofRectangle bbox = font.getStringBoundingBox(text, 0, 0);
	float textWidth = bbox.width;
	float textHeight = bbox.height;

	// Dibujar el texto centrado en la posición
	// Ajustamos para que el centro del texto esté en pos (x, y)
	font.drawString(text, -textWidth / 2.0f, textHeight / 2.0f);

	// Restaurar el estado de transformaciones y estilo
	ofPopStyle();
	ofPopMatrix();
}

// "Reactiva" la palabra cambiando su tamaño y reiniciando su vida
void WordInstance::trigger(float newSize) {
	size = newSize;
	timeToLive = maxTimeToLive; // Reiniciar contador de vida
	alpha = 255.0f;              // Restaurar opacidad completa
}

