const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const osc = require('osc');
const WebSocket = require('ws');

const OSC_HOST = process.env.SC_OSC_HOST || '0.0.0.0';
const OSC_PORT = parseInt(process.env.SC_OSC_PORT || process.env.OSC_PORT || '57121', 10);
const SERVER_PORT = parseInt(process.env.HYDRA_WS_PORT || process.env.WS_PORT || '8080', 10);
const DEBUG = process.env.DEBUG === 'true' || process.env.DEBUG === '1';
const DEFAULT_PAGE = process.env.HYDRA_INDEX || '/templates/hydra/osc_monitor.html';

const PROJECT_ROOT = path.resolve(__dirname, '..');
const STATIC_MIME_TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.js': 'application/javascript; charset=utf-8',
    '.mjs': 'application/javascript; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.webp': 'image/webp',
    '.ico': 'image/x-icon',
    '.mp4': 'video/mp4',
    '.webm': 'video/webm',
    '.wav': 'audio/wav',
    '.mp3': 'audio/mpeg'
};

const allowedAddresses = (process.env.ALLOWED_OSC_ADDRESSES || '')
    .split(',')
    .map((addr) => addr.trim())
    .filter(Boolean);

const udp = new osc.UDPPort({
    localAddress: OSC_HOST,
    localPort: OSC_PORT,
    metadata: true
});

// Cliente OSC hacia openFrameworks (oF) en 127.0.0.1:12345
// Usamos la misma librería `osc` ya presente en el proyecto.
const OF_REMOTE_ADDRESS = process.env.OF_OSC_HOST || '127.0.0.1';
const OF_REMOTE_PORT = parseInt(process.env.OF_OSC_PORT || '12345', 10);

const ofClient = new osc.UDPPort({
    remoteAddress: OF_REMOTE_ADDRESS,
    remotePort: OF_REMOTE_PORT,
    metadata: true
});

ofClient.on('ready', () => {
    log('info', `[OSC->oF] Cliente OSC listo ${OF_REMOTE_ADDRESS}:${OF_REMOTE_PORT}`);
});
ofClient.on('error', (err) => {
    log('error', '[OSC->oF] Error cliente oF:', err && err.message ? err.message : String(err));
});
// Abrir cliente oF (no bloqueará el server si no está disponible)
try {
    ofClient.open();
} catch (err) {
    log('error', '[OSC->oF] No se pudo abrir cliente OSC:', err && err.message ? err.message : String(err));
}

const httpServer = http.createServer(handleHttpRequest);
const wss = new WebSocket.Server({ server: httpServer });

function log(level, ...args) {
    const timestamp = new Date().toISOString().split('T')[1].slice(0, -1);
    if (level === 'debug' && !DEBUG) return;
    console.log(`[${timestamp}]`, ...args);
}

function safeResolve(requestPath) {
    const decoded = decodeURIComponent(requestPath || '');
    const sanitized = decoded.replace(/^\/+/, '');
    const basePath = sanitized.length > 0
        ? path.join(PROJECT_ROOT, sanitized)
        : PROJECT_ROOT;
    const fullPath = path.normalize(basePath);
    if (
        fullPath !== PROJECT_ROOT &&
        !fullPath.startsWith(`${PROJECT_ROOT}${path.sep}`)
    ) {
        return null;
    }
    return fullPath;
}

function setCorsHeaders(res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Range');
}

function serveFile(filePath, res) {
    const ext = path.extname(filePath).toLowerCase();
    const contentType = STATIC_MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(filePath, (err, data) => {
        if (err) {
            if (err.code === 'ENOENT') {
                res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8', 'Access-Control-Allow-Origin': '*' });
                res.end('404 Not Found');
                return;
            }
            res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8', 'Access-Control-Allow-Origin': '*' });
            res.end('500 Internal Server Error');
            log('error', '[HTTP] Error leyendo', filePath, err.message);
            return;
        }
        res.writeHead(200, { 'Content-Type': contentType, 'Access-Control-Allow-Origin': '*' });
        res.end(data);
    });
}

function handleDirectory(directoryPath, res) {
    const indexFile = path.join(directoryPath, 'index.html');
    fs.stat(indexFile, (err, stats) => {
        if (!err && stats.isFile()) {
            serveFile(indexFile, res);
            return;
        }
        res.writeHead(403, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end('403 Forbidden');
    });
}

function handleHttpRequest(req, res) {
    if (req.method && req.method.toUpperCase() === 'OPTIONS') {
        setCorsHeaders(res);
        res.writeHead(204);
        res.end();
        return;
    }

    setCorsHeaders(res);
    const { pathname } = url.parse(req.url || '/');
    const targetPath = safeResolve(pathname === '/' ? DEFAULT_PAGE : pathname);

    if (!targetPath) {
        res.writeHead(403, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end('403 Forbidden');
        return;
    }

    fs.stat(targetPath, (err, stats) => {
        if (err) {
            if ((pathname === '/' || pathname === '') && DEFAULT_PAGE) {
                const defaultPath = safeResolve(DEFAULT_PAGE);
                if (defaultPath) {
                    fs.stat(defaultPath, (defaultErr, defaultStats) => {
                        if (!defaultErr && defaultStats.isFile()) {
                            serveFile(defaultPath, res);
                        } else {
                            res.writeHead(404, {
                                'Content-Type': 'text/plain; charset=utf-8',
                                'Access-Control-Allow-Origin': '*'
                            });
                            res.end('404 Not Found');
                        }
                    });
                    return;
                }
            }
            res.writeHead(404, {
                'Content-Type': 'text/plain; charset=utf-8',
                'Access-Control-Allow-Origin': '*'
            });
            res.end('404 Not Found');
            return;
        }

        if (stats.isDirectory()) {
            handleDirectory(targetPath, res);
            return;
        }

        serveFile(targetPath, res);
    });
}

function normaliseArgs(args = []) {
    return args.map((arg) => (typeof arg === 'object' && arg !== null && 'value' in arg ? arg.value : arg));
}

function shouldForward(address) {
    if (allowedAddresses.length === 0) return true;
    return allowedAddresses.includes(address);
}

function broadcast(payload) {
    const data = JSON.stringify(payload);
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(data);
        }
    });
}

httpServer.on('listening', () => {
    log('info', `[HTTP] Servidor estático activo en puerto ${SERVER_PORT}`);
    log('info', `[WS] Servidor WebSocket activo en el mismo puerto`);
    log('info', `[HTTP] Página por defecto: ${DEFAULT_PAGE}`);
});

wss.on('connection', (ws) => {
    log('info', '[WS] Cliente conectado');
    ws.on('close', () => log('info', '[WS] Cliente desconectado'));
});

wss.on('error', (error) => {
    log('error', '[WS] Error del servidor WebSocket:', error.message);
});

udp.on('ready', () => {
    log('info', `[OSC] Escuchando en ${OSC_HOST}:${OSC_PORT}`);
    if (DEBUG) {
        log('debug', '[OSC] Modo DEBUG activado - todos los mensajes serán logueados');
    }
    if (allowedAddresses.length > 0) {
        log('info', `[OSC] Whitelist activa: ${allowedAddresses.join(', ')}`);
    }
});

udp.on('message', (oscMessage) => {
    const { address } = oscMessage;
    if (!address || !shouldForward(address)) return;

    const args = normaliseArgs(oscMessage.args);
    const [firstArg] = args;
    const value = typeof firstArg === 'number' ? firstArg : null;

    // Debug logging (solo si DEBUG=true)
    if (DEBUG) {
        try {
            log('debug', `[OSC] ${address} -> args=${JSON.stringify(args)} value=${value}`);
        } catch (e) {
            log('debug', '[OSC] message received', address);
        }
    }

    broadcast({ address, args, value });
    // Reenviar a openFrameworks (si el cliente está listo)
    try {
        if (ofClient && typeof ofClient.send === 'function') {
            const forwardArgs = Array.isArray(oscMessage.args)
                ? normaliseArgs(oscMessage.args)
                : [];
            const metaArgs = forwardArgs.map((v) => {
                if (typeof v === 'number') return { type: 'f', value: v };
                if (typeof v === 'string') return { type: 's', value: v };
                // fallback: stringify other types
                return { type: 's', value: String(v) };
            });
            // If the ofClient was configured with remoteAddress/remotePort we can call send()
            ofClient.send({ address, args: metaArgs });
            // Also log short info when DEBUG
            if (DEBUG) log('debug', `[OSC->oF] Forwarded ${address} -> ${OF_REMOTE_ADDRESS}:${OF_REMOTE_PORT} args=${JSON.stringify(forwardArgs)}`);
        }
    } catch (err) {
        log('error', '[OSC->oF] Error reenviando mensaje:', err && err.message ? err.message : String(err));
    }
});

udp.on('error', (error) => {
    log('error', '[OSC] Error en el puerto OSC:', error.message);
});

function shutdown() {
    log('info', '\nCerrando servidores...');
    wss.close(() => log('info', '[WS] Cerrado'));
    httpServer.close(() => log('info', '[HTTP] Cerrado'));
    udp.close();
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

udp.open();
httpServer.listen(SERVER_PORT);
