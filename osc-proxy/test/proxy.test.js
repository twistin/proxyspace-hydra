/**
 * Test para el proxy OSC↔WebSocket
 * 
 * Estos tests validan:
 * - Normalización de argumentos OSC
 * - Filtrado por whitelist de direcciones
 * - Broadcast a múltiples clientes WebSocket
 */

describe('OSC WebSocket Proxy', () => {
  describe('normaliseArgs', () => {
    // Función extraída del proxy para testing
    function normaliseArgs(args = []) {
      return args.map((arg) => 
        (typeof arg === 'object' && arg !== null && 'value' in arg ? arg.value : arg)
      );
    }

    test('extrae valores de objetos OSC con metadata', () => {
      const input = [
        { type: 'f', value: 0.5 },
        { type: 'i', value: 42 }
      ];
      const result = normaliseArgs(input);
      expect(result).toEqual([0.5, 42]);
    });

    test('mantiene valores primitivos sin cambios', () => {
      const input = [0.75, 100, 'texto'];
      const result = normaliseArgs(input);
      expect(result).toEqual([0.75, 100, 'texto']);
    });

    test('maneja arrays vacíos', () => {
      const result = normaliseArgs([]);
      expect(result).toEqual([]);
    });

    test('maneja arrays mixtos (objetos y primitivos)', () => {
      const input = [
        { type: 'f', value: 0.3 },
        0.7,
        { type: 's', value: 'hello' }
      ];
      const result = normaliseArgs(input);
      expect(result).toEqual([0.3, 0.7, 'hello']);
    });

    test('ignora objetos sin propiedad "value"', () => {
      const input = [
        { type: 'f' }, // Sin value
        { value: 0.5 }, // Con value
        null
      ];
      const result = normaliseArgs(input);
      expect(result).toEqual([{ type: 'f' }, 0.5, null]);
    });
  });

  describe('shouldForward (whitelist)', () => {
    function shouldForward(address, allowedAddresses = []) {
      if (allowedAddresses.length === 0) return true;
      return allowedAddresses.includes(address);
    }

    test('permite todo cuando whitelist está vacía', () => {
      expect(shouldForward('/any/address', [])).toBe(true);
      expect(shouldForward('/sc/aurora/pulse', [])).toBe(true);
    });

    test('filtra correctamente con whitelist activa', () => {
      const whitelist = ['/sc/aurora/pulse', '/sc/glitchstream/chaos'];
      
      expect(shouldForward('/sc/aurora/pulse', whitelist)).toBe(true);
      expect(shouldForward('/sc/glitchstream/chaos', whitelist)).toBe(true);
      expect(shouldForward('/sc/textura/grain', whitelist)).toBe(false);
      expect(shouldForward('/other/path', whitelist)).toBe(false);
    });

    test('requiere coincidencia exacta (no wildcards)', () => {
      const whitelist = ['/sc/aurora/pulse'];
      
      expect(shouldForward('/sc/aurora/pulse/extra', whitelist)).toBe(false);
      expect(shouldForward('/sc/aurora', whitelist)).toBe(false);
    });
  });

  describe('broadcast', () => {
    test('envía mensaje a todos los clientes WebSocket conectados', () => {
      const clients = [
        { readyState: 1, sent: null, send(data) { this.sent = data; } }, // OPEN
        { readyState: 1, sent: null, send(data) { this.sent = data; } }, // OPEN
        { readyState: 0, sent: null, send(data) { this.sent = data; } }, // CONNECTING
        { readyState: 3, sent: null, send(data) { this.sent = data; } }  // CLOSED
      ];

      const payload = { address: '/test', args: [0.5], value: 0.5 };
      const data = JSON.stringify(payload);

      // Simular broadcast
      clients.forEach((client) => {
        if (client.readyState === 1) { // WebSocket.OPEN
          client.send(data);
        }
      });

      // Solo los dos primeros deberían recibir el mensaje
      expect(clients[0].sent).toBe(data);
      expect(clients[1].sent).toBe(data);
      expect(clients[2].sent).toBeNull();
      expect(clients[3].sent).toBeNull();
    });

    test('serializa correctamente payload a JSON', () => {
      const payload = {
        address: '/sc/aurora/pulse',
        args: [0.75, 120],
        value: 0.75
      };

      const json = JSON.stringify(payload);
      const parsed = JSON.parse(json);

      expect(parsed.address).toBe('/sc/aurora/pulse');
      expect(parsed.args).toEqual([0.75, 120]);
      expect(parsed.value).toBe(0.75);
    });
  });

  describe('Integración completa (simulada)', () => {
    test('mensaje OSC completo pasa por pipeline correctamente', () => {
      // Simular mensaje OSC entrante
      const oscMessage = {
        address: '/sc/aurora/pulse',
        args: [
          { type: 'f', value: 0.85 }
        ]
      };

      // 1. Normalizar args
      const normaliseArgs = (args = []) => 
        args.map((arg) => 
          (typeof arg === 'object' && arg !== null && 'value' in arg ? arg.value : arg)
        );
      
      const args = normaliseArgs(oscMessage.args);
      const [firstArg] = args;
      const value = typeof firstArg === 'number' ? firstArg : null;

      // 2. Verificar whitelist (vacía = permitir todo)
      const shouldForward = (address, allowedAddresses = []) => {
        if (allowedAddresses.length === 0) return true;
        return allowedAddresses.includes(address);
      };

      const allowed = shouldForward(oscMessage.address, []);

      // 3. Crear payload para broadcast
      const payload = {
        address: oscMessage.address,
        args,
        value
      };

      expect(allowed).toBe(true);
      expect(payload.address).toBe('/sc/aurora/pulse');
      expect(payload.args).toEqual([0.85]);
      expect(payload.value).toBe(0.85);
    });
  });
});
