#!/bin/bash
# Lanzador de ZAR Vanguard Capital Partners — sirve la carpeta por http:// en vez de file://
# Necesario para que Firebase Google Sign-In funcione y para que index.html y
# directorio_zar_vanguard.html compartan el mismo localStorage (vanguardApiKey).
cd "$(dirname "$0")"
PORT=8899

echo "Iniciando servidor local para ZAR Vanguard en el puerto $PORT..."
python3 -m http.server "$PORT" &
SERVER_PID=$!
sleep 1

echo "Abriendo dashboard principal y directorio..."
open "http://localhost:$PORT/index.html"
open "http://localhost:$PORT/directorio_zar_vanguard.html"

echo ""
echo "Dashboard:  http://localhost:$PORT/index.html"
echo "Directorio: http://localhost:$PORT/directorio_zar_vanguard.html"
echo ""
echo "Servidor corriendo (PID $SERVER_PID). Cerrá esta ventana de Terminal para apagarlo."
wait $SERVER_PID
