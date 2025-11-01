(function (global) {
  function createOSCBridge(options = {}) {
    const {
      url = 'ws://127.0.0.1:8080',
      endpoints = [],
      reconnectDelay = 3000,
      autoStart = true
    } = options;

    const WS = global.WebSocket;
    if (typeof WS !== 'function') {
      throw new Error('WebSocket no disponible en este entorno.');
    }

    const byKey = new Map();
    const byAddress = new Map();
    const listeners = new Map();
    const statusListeners = new Set();

    let status = 'idle';
    let ws = null;
    let reconnectTimer = null;
    let shouldReconnect = false;

    if (typeof options.onStatus === 'function') {
      statusListeners.add(options.onStatus);
    }

    const onValues = typeof options.onValues === 'function' ? options.onValues : null;

    endpoints.forEach((endpoint) => {
      const key = endpoint.key || endpoint.address;
      const initial = typeof endpoint.initial === 'number' ? endpoint.initial : 0;
      const smoothing = typeof endpoint.smoothing === 'number' ? endpoint.smoothing : 0.2;
      const entry = {
        ...endpoint,
        key,
        initial,
        smoothing,
        min: endpoint.min,
        max: endpoint.max,
        value: initial
      };

      byKey.set(key, entry);
      byAddress.set(endpoint.address, entry);
    });

    function setStatus(next) {
      if (status === next) return;
      status = next;
      statusListeners.forEach((callback) => callback(next));
    }

    function clamp(entry, value) {
      let result = value;
      if (typeof entry.min === 'number') {
        result = Math.max(entry.min, result);
      }
      if (typeof entry.max === 'number') {
        result = Math.min(entry.max, result);
      }
      return result;
    }

    function notifyValue(entry) {
      const subs = listeners.get(entry.key);
      if (subs) {
        subs.forEach((callback) => callback(entry.value));
      }
      if (onValues) {
        onValues(entry.key, entry.value);
      }
    }

    function updateEntry(entry, rawValue) {
      if (typeof rawValue !== 'number' || Number.isNaN(rawValue)) return;
      const clamped = clamp(entry, rawValue);
      const alpha = entry.smoothing;
      const nextValue = typeof alpha === 'number'
        ? entry.value + alpha * (clamped - entry.value)
        : clamped;

      entry.value = nextValue;
      notifyValue(entry);
    }

    function extractValue(payload) {
      if (typeof payload.value === 'number') return payload.value;
      if (Array.isArray(payload.args)) {
        const numericArg = payload.args.find((arg) => typeof arg === 'number');
        if (typeof numericArg === 'number') return numericArg;
      }
      return null;
    }

    function handlePayload(payload) {
      if (!payload || typeof payload.address !== 'string') return;
      const entry = byAddress.get(payload.address);
      if (!entry) return;

      const value = typeof entry.transform === 'function'
        ? entry.transform(payload, extractValue(payload))
        : extractValue(payload);

      updateEntry(entry, value);
    }

    function scheduleReconnect() {
      if (!shouldReconnect) return;
      if (reconnectTimer) return;
      reconnectTimer = setTimeout(() => {
        reconnectTimer = null;
        connect();
      }, reconnectDelay);
    }

    function clearReconnect() {
      if (reconnectTimer) {
        clearTimeout(reconnectTimer);
        reconnectTimer = null;
      }
    }

    function connect() {
      clearReconnect();
      if (ws && (ws.readyState === WebSocket.OPEN || ws.readyState === WebSocket.CONNECTING)) {
        return;
      }

      setStatus('connecting');

      try {
        ws = new WS(url);
      } catch (error) {
        console.error('[OSCBridge] Error creando WebSocket:', error);
        setStatus('error');
        scheduleReconnect();
        return;
      }

      ws.onopen = () => {
        setStatus('connected');
      };

      ws.onclose = () => {
        setStatus('disconnected');
        ws = null;
        scheduleReconnect();
      };

      ws.onerror = () => {
        setStatus('error');
      };

      ws.onmessage = (event) => {
        try {
          const payload = JSON.parse(event.data);
          handlePayload(payload);
        } catch (error) {
          console.error('[OSCBridge] Error parseando mensaje WS:', error);
        }
      };
    }

    function start() {
      shouldReconnect = true;
      connect();
    }

    function stop() {
      shouldReconnect = false;
      clearReconnect();
      if (ws) {
        ws.close();
        ws = null;
      }
    }

    function getValue(key, fallback = 0) {
      const entry = byKey.get(key);
      return entry ? entry.value : fallback;
    }

    function on(key, callback) {
      if (!listeners.has(key)) {
        listeners.set(key, new Set());
      }
      const subs = listeners.get(key);
      subs.add(callback);
      const entry = byKey.get(key);
      if (entry) {
        callback(entry.value);
      }
      return () => {
        subs.delete(callback);
      };
    }

    function onStatus(callback) {
      statusListeners.add(callback);
      callback(status);
      return () => statusListeners.delete(callback);
    }

    function resetValues() {
      byKey.forEach((entry) => {
        entry.value = entry.initial;
        notifyValue(entry);
      });
    }

    const bridge = {
      start,
      stop,
      getValue,
      on,
      onStatus,
      reset: resetValues,
      status: () => status
    };

    if (autoStart) {
      start();
    }

    return bridge;
  }

  global.createOSCBridge = createOSCBridge;
})(window);
