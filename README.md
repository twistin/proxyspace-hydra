# ProxySpace Hydra Bundle

Toolkit para sesiones de live coding donde SuperCollider genera audio (y datos de análisis) que modulan visuales hechos con Hydra en el navegador. Todo el flujo se orquesta mediante un proxy Node.js que recibe OSC y lo reenvía por WebSocket.

```
SuperCollider → OSC (UDP 57121) → Node Proxy → WebSocket 8080 → Hydra (browser)
```

## Estructura del proyecto

```
proxyspace-hydra/
├─ docs/
│  └─ live-coding-playbook.md    # Estrategias ampliadas para sets híbridos
├─ hydra/
│  ├─ js/osc-client.js           # Cliente WebSocket con smoothing y reconexión
│  ├─ osc_ws_proxy.js            # Proxy OSC ↔ WS en Node.js (única versión soportada)
│  ├─ package.json               # Dependencias (osc, ws) y scripts npm
│  └─ package-lock.json
├─ images/
│  ├─ cdv.jpeg                   # Textura principal para la escena glitch
│  └─ cdv2.jpeg                  # Textura auxiliar para blend/pixelate
├─ scd/
│  ├─ sound.scd                  # Demo mínima → /sc/rhythm
│  ├─ sound1.scd                 # Patrón percusivo → /sc/rhythm
│  └─ sound2.scd                 # Análisis multibanda → /sc/rhythm,/sc/bass,/sc/high
├─ templates/
│  ├─ hydra/base_template.html   # Cliente Hydra completo con escenas y HUD
│  └─ scd/                       # Plantillas SC adicionales (ProxySpace, Zhen)
└─ README.md
```

## Requisitos

- Node.js 18 o superior
- SuperCollider 3.13 o superior
- Navegador con soporte WebGL (Chromium, Firefox o similares)

## Instalación rápida

```bash
cd hydra
npm install
```

## Puesta en marcha básica

1. **Proxy OSC → WS + HTTP** (OSC 57121, WebSocket/HTTP 8080 por defecto):
   ```bash
   cd hydra
   npm run proxy
   ```
   Variables útiles:
   - `SC_OSC_HOST` y `SC_OSC_PORT`: IP/puerto donde escucha OSC.
   - `HYDRA_WS_PORT`: puerto compartido para HTTP y WebSocket.
   - `HYDRA_INDEX`: ruta (desde la raíz del repo) del HTML que se sirve en `/` (por defecto `templates/hydra/layer_mixer_template.html`).
   - `ALLOWED_OSC_ADDRESSES`: lista de rutas permitidas (ej. `/sc/rhythm,/sc/bass`).

2. **SuperCollider**: abre uno de los archivos en `scd/` y evalúa las secciones numeradas para generar audio y datos.

   | Archivo       | Qué envía | Notas |
   |---------------|-----------|-------|
   | `sound.scd`   | `/sc/rhythm` (LFO controlado por drone) | Demo mínima para probar el canal único |
   | `sound1.scd`  | `/sc/rhythm` (medición de RMS de percusión) | Usa ProxySpace y Tdefs para ritmo |
   | `sound2.scd`  | `/sc/rhythm`, `/sc/bass`, `/sc/high` | Divide la mezcla en tres bandas para visual multisensor |

   Cada script guarda `topEnvironment[\hydraAddr]` y limpia `OSCdef`/Synths con `CmdPeriod.doOnce`.

3. **Visuales Hydra**: con el proxy en marcha visita `http://localhost:8080/templates/hydra/base_template.html` (o la página que definas con `HYDRA_INDEX`). El servidor Node expone automáticamente `templates/`, `images/` y `hydra/`, evitando los bloqueos CORS cuando se usan texturas locales.

   El HUD refleja estado del bridge y valores `/sc/rhythm`, `/sc/bass`, `/sc/high`; `bridge.on('scene')` conmuta entre las escenas:
   - `0 · Lienzo base`: texturas geométricas moduladas por ritmo/bajos.
   - `1 · Anillos difracción`: osciladores kaleidoscópicos a partir del ritmo.
   - `2 · Dualidades`: overlay tipográfico reactivo, oculta el word overlay.
   - `3 · Glitch imagen`: mezcla de `images/cdv*.jpeg` con desplazamientos y glitch.

## Personalización rápida

- **Sensibilidad visual**: ajusta los `Lag.kr` y mapeos `linlin` en los `.scd`, o cambia las funciones `rhythm()`, `bass()`, `high()` en el HTML.
- **Nuevas rutas OSC**: añade endpoints al array `createOSCBridge({ endpoints: [...] })` y crea los `SendTrig` correspondientes en SuperCollider.
- **Escenas adicionales**: agrega objetos al array `scenes` en `base_template.html` y dispara cambios con `/sc/scene`.
- **Servir desde otra herramienta**: cualquier servidor HTTP estático vale (Node, Rust, etc.); sólo asegúrate de publicar `images/` y `templates/` bajo la misma raíz.

## Mantenimiento y limpieza

- `Cmd+.` en SuperCollider libera Synths, `OSCdef` y elimina `hydraAddr`.
- El proxy Node captura `SIGINT`/`SIGTERM` y cierra ambos servidores ordenadamente.
- Si el HTML deja de reaccionar revisa la consola: el bridge muestra estados (`Inactivo`, `Conectando`, `Conectado`, etc.) y reconecta cada 3 s.
- El árbol se ha depurado para evitar duplicados (`hydra_client*.html`, `osc_ws_proxy*`). Mantén nuevas iteraciones en `templates/` o documentadas en `docs/`.

## Troubleshooting

### Proxy no arranca (EADDRINUSE)

**Síntoma**: `Error: listen EADDRINUSE: address already in use :::8080` o `:::57121`

**Solución**:
```bash
# Encuentra el proceso usando los puertos
lsof -i :8080 -i :57121

# Termina el proceso (reemplaza PID con el número de arriba)
kill <PID>

# O automáticamente
pkill -f 'npm run proxy'
```

### Hydra muestra "Conectando" pero nunca "Conectado"

**Diagnóstico**:
1. Verifica que el proxy esté corriendo: debe mostrar `[WS] Servidor WebSocket activo en puerto 8080`
2. Abre la consola del navegador (F12): busca errores de WebSocket
3. Confirma la URL en el HTML: debe ser `ws://127.0.0.1:8080` (no `wss://`)

**Soluciones**:
- Si el proxy está en otro puerto, edita `url: 'ws://127.0.0.1:PUERTO'` en el HTML
- Reinicia el navegador si el WebSocket quedó colgado

### SuperCollider envía OSC pero Hydra no reacciona

**Diagnóstico**:
1. Verifica en la terminal del proxy: debe aparecer `[OSC] /sc/rhythm -> args=[...] value=...`
2. Si NO aparece, el problema está en SuperCollider:
   - Confirma `topEnvironment[\hydraAddr] = NetAddr("127.0.0.1", 57121)`
   - Verifica que `~osc_ctrl.play` esté ejecutado
   - En `sound2.scd`: ejecuta `~a1.resume` (el patrón está pausado por defecto)
3. Si aparece en proxy pero no en Hydra:
   - Revisa la consola del navegador: debe mostrar `[OSC] rhythm = 0.xxxx`
   - Confirma que el HUD muestre valores actualizándose (no estáticos en 0.1000)

**Solución rápida**: Prueba enviar manualmente desde SuperCollider:
```supercollider
NetAddr("127.0.0.1", 57121).sendMsg("/sc/rhythm", 0.6);
```

### Texturas/imágenes no cargan (CORS)

**Síntoma**: Consola muestra `Access to Image ... has been blocked by CORS policy` o escena 3 (Glitch) no muestra fotos

**Solución**:
```bash
# NO uses file:// (abriendo el HTML directamente)
# En su lugar, sirve desde HTTP:
cd /ruta/a/proxyspace-hydra
python3 -m http.server 8000

# Luego abre:
# http://localhost:8000/templates/hydra/base_template.html
```

### Valores OSC se quedan en 0.1000

**Causa**: SuperCollider no está enviando datos o el mapeo es incorrecto

**Soluciones**:
1. **Verifica el audio**: `~verb.play` debe estar corriendo; escucha si hay sonido
2. **Ajusta el mapeo**: en `sound2.scd`, las líneas `linlin(0.0, 0.2, 0.1, 0.9)` mapean RMS. Si tu mezcla es muy baja, incrementa el rango superior (ej. `0.4` en vez de `0.2`)
3. **Confirma el trigger**: el `Impulse.kr(10)` debe enviar 10 mensajes/segundo; revisa el Post Window de SC

### Escenas visuales se ven "lentas" o con lag

**Soluciones**:
- Reduce la resolución del canvas en el HTML:
  ```javascript
  const hydra = new Hydra({
    canvas,
    width: 1280,  // en vez de window.innerWidth
    height: 720   // en vez de window.innerHeight
  });
  ```
- Baja el smoothing en los endpoints (ej. `0.1` en vez de `0.2`) para respuesta más rápida
- Simplifica las escenas: menos buffers (o1, o2, o3) o menos efectos encadenados

### Proxy imprime demasiados logs

**Solución temporal**: redirige stderr a `/dev/null`:
```bash
npm run proxy 2>/dev/null
```

**Solución permanente**: Edita `osc_ws_proxy.js` y comenta las líneas:
```javascript
// console.log(`[OSC] ${address} -> args=...`);
```

---

## Ideas para trabajar en vivo

- Ejecuta el proxy con `npx nodemon osc_ws_proxy.js` para autorecargar al editar.
- Usa shortcuts de SuperCollider para enviar `/sc/scene` y alternar overlays en directo.
- Captura logs OSC (`s.recordOSC`) para recrear visuales sin audio en ensayos.
- Versiona escenas complejas en `templates/hydra/` y enlázalas desde el README conforme evolucionen.

---

## Setup automatizado

```bash
# Ejecuta una sola vez para verificar requisitos e instalar
chmod +x setup.sh
./setup.sh

# Después, inicia todo con:
./start.sh

# Detén los servicios:
./stop.sh
```

Con este bundle la preparación se reduce a tres pasos (proxy, SuperCollider, Hydra servida vía HTTP), dejando todo el control creativo al live coding de audio y visuales.
