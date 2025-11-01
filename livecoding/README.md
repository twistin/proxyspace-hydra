# Livecoding Bundle

Todo lo necesario para montar una sesión ProxySpace Hydra quedó encapsulado en esta carpeta. Aquí conviven el arranque de SuperCollider, el proxy OSC ↔ WebSocket, el proyecto openFrameworks y las plantillas de sesión.

---

## 🚀 Puesta en marcha exprés

```bash
cd livecoding
./start_live_session.sh
```

El script:
- arranca el proxy Node (`osc-proxy/`),
- abre el proyecto visual (`of/bin/ofDebug.app`, o `of/of.xcodeproj` si no existe el binario),
- lanza SuperCollider con la plantilla `scd/sound2.scd`.

En SuperCollider evalúa todo el archivo y ejecuta:

```supercollider
SoundSessionStartAll.();   // Inicializa servidor, buffers y red OSC
SoundSessionPlay.();       // Arranca el patrón base (~a1)
```

Para pausar/limpiar:

```supercollider
SoundSessionStop.();
SoundSessionCleanup.();    // Equivalente a Cmd+.
```

---

## 🗂️ Tour rápido por el bundle

```
livecoding/
├── start_live_session.sh   # Script maestro (proxy + oF + plantilla SC)
├── setup/                  # Boilerplate SuperCollider (Setup.scd, Snippets, SynthDefs…)
├── samples/                # Estructura para audio (audio/, set1/, set1lfx/)
├── sesiones/               # Plantillas de show (sound2.scd, _TEMPLATE_SESION.scd, etc.)
├── osc-proxy/              # Proxy Node.js (osc ↔ ws) con tests y package.json
└── of/                     # Proyecto openFrameworks de visuales
```

- **setup/**: Evalúa `Setup.scd` cuando levantas una sesión; carga buffers, snippets y activa StageLimiter.
- **samples/**: guarda aquí tus bancos. `sound2.scd` espera audio en `samples/set1/set-sounds/` (ajusta `~samplesRelative` si cambia).
- **sesiones/**: plantillas de flujo; `2024-10-29_ejemplo_completo.scd` y `2025-10-29_landscapes.scd` sirven de guía. Usa `_TEMPLATE_SESION.scd` como punto de partida profesional para nuevos shows. `scd/sound2.scd` es la plantilla base invocada por el script.
- **osc-proxy/**: contiene `osc_ws_proxy.js`, `package.json` y los tests Jest (`npm test`). Puedes correrlo a mano con `npm run proxy`.
- **of/**: proyecto oF con todo el código en `src/`. Si no existe `bin/ofDebug.app`, compila con Xcode (`open of/of.xcodeproj`) o mediante make (`cd of && make`).

---

## 🎛️ SuperCollider

- Evalúa `setup/Setup.scd` para inicializar server, cargar snippets y StageLimiter.
- Usa `SoundSession` (definido en `scd/sound2.scd`) para levantar patrones, buffers y OSCdefs:
  - `/kick` → genera pares de dualidades en ofApp.
  - `/bass_level` → controla fondo y efectos LANDSCAPES.
  - `/melody_note` → colorea palabras/imágenes.
- Añade tus proxies personalizados en la sección “ESPACIO PARA TU SET” de `sound2.scd`.

---

## 🌐 Proxy OSC ↔ WebSocket (`osc-proxy/`)

- Configuración por defecto: escucha OSC en `0.0.0.0:57121` y sirve HTTP/WebSocket en `:8080`.
- Variables de entorno útiles: `SC_OSC_HOST`, `SC_OSC_PORT`, `HYDRA_WS_PORT`, `HYDRA_INDEX`, `ALLOWED_OSC_ADDRESSES`.
- Comandos:
  ```bash
  cd livecoding/osc-proxy
  npm install        # una sola vez
  npm run proxy      # modo normal
  DEBUG=true npm run dev   # hot reload con nodemon
  npm test           # ejecuta los tests Jest
  ```

---

## 🎨 openFrameworks (`of/`)

- Todo el código vive en `src/` (`ofApp.cpp`, `WordInstance.cpp`, etc.). Lee `of/README.md` para detalles.
- `config.make` y `Project.xcconfig` apuntan al core de oF en `/Users/sdcarr/Documents/of_v0.12.1_osx_release`. Ajusta `OF_ROOT` si lo mueves.
- Compila una vez (`make` o Xcode) para generar `bin/ofDebug.app`, que luego abre automáticamente el script de arranque.
- Assets: coloca tus imágenes en `bin/data/landscapes/` (hay un `README.md` con instrucciones).

---

## 🧰 Tips y mantenimiento

- Ejecuta `Cmd+.` en SuperCollider al terminar; el `CmdPeriod.doOnce` limpia OSCdefs y libera el proxy.
- El script `start_live_session.sh` es idempotente: si el proxy ya corre, lo detecta y evita duplicados.
- Guarda sesiones nuevas duplicando la plantilla `sesiones/sound2.scd` y personalizando `SoundSession`.
- Si empaquetas este bundle para otro equipo, incluye `osc-proxy/node_modules` sólo si lo necesitas; basta con `npm install` al otro lado.
- Para actualizar openFrameworks, recuerda regenerar el proyecto con el Project Generator incluyendo `ofxOsc`.

---

¡Con esto tienes un entorno portátil para live coding audiovisual listo para salir a escena! Ajusta lo necesario y versiona tus cambios dentro de esta carpeta. 
