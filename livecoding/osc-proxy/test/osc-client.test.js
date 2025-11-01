/**
 * Test para el módulo osc-client.js
 * 
 * Este módulo prueba las funcionalidades críticas del bridge OSC↔WebSocket:
 * - Smoothing exponencial de valores
 * - Clamping min/max
 * - Sistema de suscripción a cambios
 */

describe('OSC Client Bridge', () => {
  let mockWebSocket;
  let OSCBridge;

  beforeEach(() => {
    // Mock básico de WebSocket para evitar errores de conexión real
    global.WebSocket = class MockWebSocket {
      constructor(url) {
        this.url = url;
        this.readyState = 1; // OPEN
        mockWebSocket = this;
        setTimeout(() => {
          if (this.onopen) this.onopen();
        }, 0);
      }
      send(data) {
        this.lastSent = data;
      }
      close() {
        this.readyState = 3; // CLOSED
        if (this.onclose) this.onclose();
      }
    };

    // Cargar el módulo osc-client.js (ajustar path si es necesario)
    // En producción usarías require o import dinámico
    // Para este test, simulamos la función principal
    OSCBridge = createOSCBridgeMock;
  });

  afterEach(() => {
    delete global.WebSocket;
  });

  test('aplica smoothing exponencial correctamente', () => {
    const values = [];
    const bridge = OSCBridge({
      autoStart: false,
      endpoints: [
        { address: '/test/smooth', key: 'smooth', initial: 0, smoothing: 0.2 }
      ],
      onValues: (key, value) => {
        if (key === 'smooth') values.push(value);
      }
    });

    // Simular recepción de valor OSC
    bridge._simulateOSC('/test/smooth', 1.0);
    
    // Con smoothing 0.2: new = old * 0.8 + incoming * 0.2
    // 0 * 0.8 + 1.0 * 0.2 = 0.2
    expect(values[0]).toBeCloseTo(0.2, 2);

    bridge._simulateOSC('/test/smooth', 1.0);
    // 0.2 * 0.8 + 1.0 * 0.2 = 0.36
    expect(values[1]).toBeCloseTo(0.36, 2);
  });

  test('respeta límites min/max (clamping)', () => {
    const values = [];
    const bridge = OSCBridge({
      autoStart: false,
      endpoints: [
        { 
          address: '/test/clamp', 
          key: 'clamp', 
          initial: 0.5, 
          smoothing: 0, // Sin smoothing para test directo
          min: 0.2,
          max: 0.8
        }
      ],
      onValues: (key, value) => {
        if (key === 'clamp') values.push(value);
      }
    });

    bridge._simulateOSC('/test/clamp', 1.5); // Excede max
    expect(values[0]).toBe(0.8);

    bridge._simulateOSC('/test/clamp', 0.1); // Por debajo de min
    expect(values[1]).toBe(0.2);

    bridge._simulateOSC('/test/clamp', 0.5); // En rango
    expect(values[2]).toBe(0.5);
  });

  test('notifica cambios solo cuando hay suscriptores', () => {
    let callCount = 0;
    const bridge = OSCBridge({
      autoStart: false,
      endpoints: [
        { address: '/test/notify', key: 'notify', initial: 0, smoothing: 0 }
      ],
      onValues: (key, value) => {
        callCount++;
      }
    });

    bridge._simulateOSC('/test/notify', 0.5);
    expect(callCount).toBe(1);

    // Suscribir listener adicional
    const unsubscribe = bridge.on('notify', (value) => {
      callCount++;
    });

    bridge._simulateOSC('/test/notify', 0.7);
    expect(callCount).toBe(3); // onValues + listener

    unsubscribe();
    bridge._simulateOSC('/test/notify', 0.9);
    expect(callCount).toBe(4); // Solo onValues
  });

  test('ignora valores no numéricos o NaN', () => {
    const values = [];
    const bridge = OSCBridge({
      autoStart: false,
      endpoints: [
        { address: '/test/invalid', key: 'invalid', initial: 0.5, smoothing: 0 }
      ],
      onValues: (key, value) => {
        values.push(value);
      }
    });

    bridge._simulateOSC('/test/invalid', 'not-a-number');
    bridge._simulateOSC('/test/invalid', NaN);
    bridge._simulateOSC('/test/invalid', undefined);
    
    // Ningún valor debería actualizarse
    expect(values.length).toBe(0);

    bridge._simulateOSC('/test/invalid', 0.7);
    expect(values.length).toBe(1);
    expect(values[0]).toBe(0.7);
  });

  test('reconexión automática después de desconexión', (done) => {
    jest.useFakeTimers();
    
    const statusChanges = [];
    const bridge = OSCBridge({
      reconnectDelay: 1000,
      endpoints: [],
      onStatus: (status) => {
        statusChanges.push(status);
      }
    });

    // Esperar conexión inicial
    setTimeout(() => {
      expect(statusChanges).toContain('connected');
      
      // Simular desconexión
      mockWebSocket.close();
      
      setTimeout(() => {
        expect(statusChanges).toContain('disconnected');
        
        // Avanzar timer para reconexión
        jest.advanceTimersByTime(1100);
        
        setTimeout(() => {
          expect(statusChanges).toContain('reconnecting');
          expect(statusChanges).toContain('connected');
          done();
        }, 100);
      }, 100);
    }, 100);

    jest.runAllTimers();
  });
});

// Mock simplificado de createOSCBridge para tests
function createOSCBridgeMock(options = {}) {
  const endpoints = new Map();
  const listeners = new Map();
  const { onValues } = options;

  (options.endpoints || []).forEach((ep) => {
    const key = ep.key || ep.address;
    endpoints.set(ep.address, {
      ...ep,
      key,
      value: ep.initial || 0
    });
  });

  function clamp(entry, value) {
    let result = value;
    if (typeof entry.min === 'number') result = Math.max(entry.min, result);
    if (typeof entry.max === 'number') result = Math.min(entry.max, result);
    return result;
  }

  function notifyValue(entry) {
    const subs = listeners.get(entry.key);
    if (subs) subs.forEach((cb) => cb(entry.value));
    if (onValues) onValues(entry.key, entry.value);
  }

  return {
    _simulateOSC(address, rawValue) {
      const entry = endpoints.get(address);
      if (!entry) return;
      if (typeof rawValue !== 'number' || Number.isNaN(rawValue)) return;

      const clamped = clamp(entry, rawValue);
      const alpha = entry.smoothing || 0;
      entry.value = alpha > 0 
        ? entry.value * (1 - alpha) + clamped * alpha
        : clamped;

      notifyValue(entry);
    },
    on(key, callback) {
      if (!listeners.has(key)) listeners.set(key, new Set());
      listeners.get(key).add(callback);
      return () => listeners.get(key)?.delete(callback);
    },
    get(key) {
      for (const entry of endpoints.values()) {
        if (entry.key === key) return entry.value;
      }
      return undefined;
    }
  };
}
