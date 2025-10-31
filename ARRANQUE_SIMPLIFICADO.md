# 🚀 Arranque Simplificado - TODO DESDE SUPERCOLLIDER

## ✨ Nueva Funcionalidad

Ahora **solo necesitas 2 pasos**:

### **1. Abrir openFrameworks** 🎨
```bash
# En Xcode:
open ~/Desktop/proxyspace-hydra/of/proxyspace-hydra.xcodeproj
# Luego: Cmd+R
```

### **2. Ejecutar el bloque de setup en SuperCollider** 🎵
```supercollider
// Ejecutar BLOQUE 1 (líneas 19-45 o donde esté el bloque de setup)
// Cmd+Return
```

**¡Eso es todo!** El proxy Node.js se arranca automáticamente mediante `start_proxy.sh`. 🎉

---

## 🔧 Si el proxy NO arranca automáticamente

**Opción A: Arranque manual** (recomendado)
```bash
cd ~/Desktop/proxyspace-hydra
./start_proxy.sh
```

**Opción B: Desde terminal**
```bash
cd ~/Desktop/proxyspace-hydra/hydra
SC_OSC_PORT=57122 npm run proxy &
```

---

## 🔧 Cómo Funciona

La plantilla de sesión ahora incluye:

### **Arranque automático del proxy** (líneas 17-26)
```supercollider
(
// Arrancar proxy OSC en background
"Arrancando proxy Node.js...".postln;
("cd " ++ thisProcess.nowExecutingPath.dirname.dirname +/+ "hydra && SC_OSC_PORT=57122 npm run proxy > /tmp/hydra_proxy.log 2>&1 &").unixCmd;
"✅ Proxy arrancado en background (puerto 57122)".postln;
"   Para ver logs: tail -f /tmp/hydra_proxy.log".postln;

// Esperar 2 segundos a que arranque el proxy
2.wait;
)
```

### **Detención automática del proxy** (líneas 50-54)
```supercollider
// Matar proxy al cerrar SuperCollider
ServerQuit.add({
    "🛑 Deteniendo proxy Node.js...".postln;
    "pkill -f 'node.*osc_ws_proxy'".unixCmd;
});
```

---

## 📋 Workflow Completo

### **Inicio de Sesión:**
1. **Abrir Xcode** → Cmd+R (openFrameworks)
2. **Abrir SuperCollider** → Abrir sesión → Cmd+A + Cmd+Return
3. **Esperar mensajes**:
   ```
   ✅ Proxy arrancado en background (puerto 57122)
   ✅ Setup done!
   ✅ OSC configurado en 127.0.0.1:57122
   ```
4. **Test**:
   ```supercollider
   topEnvironment[\hydraAddr].sendMsg("/kick");
   // Debe cambiar imagen en oF
   ```

### **Durante la Sesión:**
- Live coding en SuperCollider
- Cambiar escenas con teclado en oF (1, 2, 3, 4, 5)
- Si haces Cmd+Period, los OSCdefs se limpian pero el proxy sigue corriendo

### **Finalizar Sesión:**
- **Cerrar SuperCollider** (Cmd+Q) → El proxy se detiene automáticamente
- **Cerrar openFrameworks** (Cmd+Q)

---

## 🔍 Verificar que Funciona

### **Ver logs del proxy en tiempo real:**
```bash
tail -f /tmp/hydra_proxy.log
```

### **Comprobar que el proxy está corriendo:**
```bash
lsof -i :57122
# Debe mostrar: node (PID)
```

### **Si necesitas detener el proxy manualmente:**
```bash
pkill -f 'node.*osc_ws_proxy'
```

---

## ⚠️ Notas Importantes

### **¿Qué pasa si ejecuto la sesión dos veces?**
- El script intenta arrancar el proxy otra vez
- Si ya está corriendo, verás un error en `/tmp/hydra_proxy.log` (EADDRINUSE)
- **No es grave**: el proxy anterior sigue funcionando
- **Solución**: Mata el proxy antes de re-ejecutar:
  ```supercollider
  "pkill -f 'node.*osc_ws_proxy'".unixCmd;
  2.wait; // Esperar 2 segundos
  // Luego ejecutar sesión de nuevo
  ```

### **¿Puedo seguir arrancando el proxy manualmente?**
Sí, si prefieres el control manual:

1. **Comenta las líneas 17-26** en tu sesión (arranque automático)
2. **Comenta las líneas 50-54** (detención automática)
3. **Arranca el proxy en terminal**:
   ```bash
   cd ~/Desktop/proxyspace-hydra/hydra
   SC_OSC_PORT=57122 npm run proxy
   ```

### **Ventajas del arranque automático:**
✅ Un solo archivo arranca todo
✅ No olvidas arrancar el proxy
✅ Se limpia automáticamente al cerrar SC
✅ Logs guardados en `/tmp/hydra_proxy.log`

### **Desventajas:**
⚠️ Si el proxy crashea, no lo ves inmediatamente (hay que revisar logs)
⚠️ Ejecutar sesión dos veces puede causar conflictos de puerto

---

## 🎯 Resumen: Solo 2 Componentes

| Componente | Cómo Arranca | Cómo Detiene |
|------------|--------------|--------------|
| **openFrameworks** | Manual (Xcode Cmd+R) | Manual (Cmd+Q) |
| **SuperCollider** | Manual (abrir + ejecutar) | Manual (Cmd+Q) |
| **Proxy Node.js** | ✨ **AUTOMÁTICO** desde SC | ✨ **AUTOMÁTICO** al cerrar SC |

---

## 📚 Archivos Actualizados

- ✅ `templates/session_template.scd` → Arranque automático
- ✅ `sesiones/2024-10-29_ejemplo_completo.scd` → Arranque automático
- 📖 `ARRANQUE_SISTEMA.md` → Info del sistema original (manual)
- 📖 Este archivo → Info del nuevo sistema (automático)

---

## 🎵 ¡A tocar!

Ahora tu workflow es:
1. **Xcode → Cmd+R**
2. **SuperCollider → Cmd+A + Cmd+Return**
3. **Live coding! 🎶**

**Todo lo demás es automático.** 🚀
