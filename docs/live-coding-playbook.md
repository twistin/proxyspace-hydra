# Live Coding Audio/Visual Playbook

Guía para preparar sesiones profesionales de live coding combinando SuperCollider (audio) y Hydra (visuales).

---

## 1. Visión general del flujo

```
┌────────────┐      OSC /sc/*       ┌──────────────┐       WebSocket         ┌──────────────┐
│ SuperCollider ├──────────────────▶│ Node Proxy   │◀───────────────────────▶│ Hydra Client │
│ (audio + OSC)│                    │ osc_ws_proxy │                        │ (visual)     │
└────────────┘      Control bidireccional opcional                           └──────────────┘
         ▲                      ▲                     ▲                                │
         │                      │                     │                                │
         │          Macros MIDI/OSC extras            │             Escenas/Overlays   │
         └────────────────────────────────────────────┴────────────────────────────────┘
```

1. SuperCollider genera audio y publica datos por OSC (`/sc/rhythm`, `/sc/bass`, etc.).
2. Un proxy Node.js (`osc-proxy/osc_ws_proxy.js`) traduce OSC a WebSocket.
3. Los patches Hydra escuchan esos datos vía `createOSCBridge` y adaptan visuales (ver `templates/hydra/base_template.html`).
4. Opcionalmente, controles MIDI u OSC adicionales pueden modificar ambos lados.

---

## 2. Diccionario de parámetros (ejemplo)

| Ruta OSC     | Rango sugerido | Uso principal                             | Efecto visual típico              |
| ------------ | -------------- | ----------------------------------------- | --------------------------------- |
| `/sc/rhythm` | 0.1 – 0.9      | Amplitud global / pulso                   | Escala, brillo, rotación          |
| `/sc/bass`   | 0.1 – 0.9      | Energía en bajos (<150 Hz)                | Distorsión, feedback, contraste   |
| `/sc/high`   | 0.1 – 0.9      | Transitorios en agudos (>3 kHz)           | Detalle, grain, velocidad noise   |
| `/sc/scene`  | 0 – n          | Selección de escena/overlay (entero)      | Cambiar patch completo            |
| `/sc/glitch` | 0 – 1          | Intensidad de glitch o efectos especiales | Mezcla con buffers experimentales |

Documenta este diccionario al inicio de tu set y ajusta los rangos según tu mezcla.

---

## 3. Flujo de trabajo recomendado

### 3.1 Preparación de audio (SuperCollider)

1. Arranca servidor (`s.boot`) y TempoClock.
2. Define `topEnvironment[\hydraAddr] = NetAddr(...)` para el proxy.
3. Diseña SynthDefs y patrones; crea funciones/macros (`~burst.()`, `~fill.()`).
4. En un proxy de control (`~osc_ctrl`) mide RMS/filtros y envía con `SendTrig`.
5. Registra `OSCdef` que traducen triggers `/tr` a rutas OSC (`/sc/rhythm`).

### 3.2 Preparación de visuales (Hydra)

1. Carga `osc-proxy/js/osc-client.js` en tus HTML.
2. Define `const bridge = createOSCBridge({...})` con todos los endpoints.
3. Crea funciones utilitarias `const rhythm = () => bridge.getValue('rhythm', 0.1)`. 
4. Construye capas Hydra (shape, osc, noise, voronoi) modulando con esas funciones.
5. Añade overlays (estado, valores numéricos) para debug durante el show.

### 3.3 Sincronización y control

- **Macros SC → Visual**: cada vez que llames `~burst.()`, envía `/sc/scene` con un índice para activar una escena en Hydra.
- **Controladores externos**: mapea knobs a Synth params y envía simultáneamente `/sc/macro1` para Hydra.
- **Audio-reactivo + manual**: combina los valores OSC con ruido determinista (`Math.sin(time * base)`) para mantener variedad visual.

---

## 4. Ejemplo de escena (ritmo + bajos + agudos)

### SuperCollider (extracto de `sound2.scd`)

```supercollider
~osc_ctrl = {
    var verbSig = ~verb.ar(1),
        ampRMS, rhythmValue,
        bassSig, ampBass, bassValue,
        highSig, ampHigh, highValue;

    ampRMS = Amplitude.kr(verbSig, 0.0, 0.01);
    rhythmValue = Lag.kr(ampRMS, 0.15).linlin(0.0, 0.2, 0.1, 0.95);
    SendTrig.kr(Impulse.kr(12), 1, rhythmValue);

    bassSig = LPF.ar(verbSig, 150);
    bassValue = Lag.kr(Amplitude.kr(bassSig, 0.0, 0.02), 0.2).linlin(0.0, 0.15, 0.1, 0.95);
    SendTrig.kr(Impulse.kr(12), 2, bassValue);

    highSig = HPF.ar(verbSig, 3000);
    highValue = Lag.kr(Amplitude.kr(highSig, 0.0, 0.01), 0.05).linlin(0.0, 0.1, 0.1, 0.9);
    SendTrig.kr(Impulse.kr(12), 3, highValue);

    Silent.ar;
};

OSCdef(\sendMultisensors, { |msg|
    var id = msg[2], value = msg[3], address, addr;
    address = [nil, "/sc/rhythm", "/sc/bass", "/sc/high"][id];
    addr = topEnvironment[\hydraAddr] ?? { NetAddr("127.0.0.1", 57121) };
    addr.sendMsg(address, value);
}, '/tr');
```

### Hydra (`templates/hydra/base_template.html`, escena multisensor)

```javascript
const bridge = createOSCBridge({
  url: 'ws://127.0.0.1:8080',
  endpoints: [
    { address: '/sc/rhythm', key: 'rhythm', smoothing: 0.18 },
    { address: '/sc/bass', key: 'bass', smoothing: 0.22 },
    { address: '/sc/high', key: 'high', smoothing: 0.15 },
    { address: '/sc/scene', key: 'scene', smoothing: 1, transform: (_, raw) => Math.round(raw ?? 0) }
  ]
});

const rhythm = () => bridge.getValue('rhythm', 0.1);
const bass = () => bridge.getValue('bass', 0.1);
const high = () => bridge.getValue('high', 0.1);

osc(() => 4 + rhythm() * 6, 0.05, () => 1 + high() * 0.45)
  .modulate(noise(() => 1.2 + bass() * 10).scale(() => 1 + bass() * 0.5), () => high() * 0.4)
  .color(
    () => 0.45 + rhythm() * 0.35,
    () => 0.28 + bass() * 0.4,
    () => 0.5 + high() * 0.5
  )
  .contrast(() => 1.15 + high() * 0.35)
  .add(src(o0).scale(() => 1.001 + rhythm() * 0.002), 0.38)
  .out(o0);
```

---

## 5. Checklist antes de salir al escenario

- [ ] Proxy `npm run proxy` funcionando (sin errores en consola).
- [ ] SuperCollider: `topEnvironment[\hydraAddr]` definido y `OSCdef` activos.
- [ ] Patches Hydra cargados en navegador (overlay muestra `CONECTADO`).
- [ ] Controladores MIDI/OSC probados (si aplica).
- [ ] Macros SC documentadas y accesibles (atajos, comentarios en código).
- [ ] Plan de escenas visuales (intro, build, clímax, outro).
- [ ] Script de limpieza (`Cmd+.`) verificado.

---

## 6. Mantenimiento y versión

- Usa Git para etiquetar versiones estables (`v1-show-2025-10`).
- Documenta cambios en los `.scd` (comentarios con fechas y notas de sesión).
- Considera empaquetar los HTML con Vite/Parcel si quieres subirlos a un servidor estático o a un proyector web.

---

## 7. Próximos pasos creativos

1. **Presets visuales**: crea un módulo en Hydra que escuche `/sc/scene` y conmuta entre funciones `scene0()`, `scene1()`.
2. **Grabaciones de ensayo**: loggea las salidas OSC en JSON para reproducir visuales sin audio real (útil para testing en solitario).
3. **Live reload**: usa `npm install --save-dev live-server` y ejecuta `npx live-server` en `hydra/` para recarga automática.
4. **Colaboración**: comparte el proxy con otros músicos; cada uno envía sus rutas OSC (usa `ALLOWED_OSC_ADDRESSES` para segmentar).

Con esta base tendrás un set consistente, reutilizable y fácil de extender tanto en audio como en visual, manteniendo control creativo durante el live coding.
