#!/bin/bash

# Script para ejecutar Flutter con resolución de iPhone 12 Pro
# Resolución: 390x844 (CSS pixels) - equivalente a 1170x2532 píxeles físicos

echo "🚀 Iniciando KIPU con resolución iPhone 12 Pro..."
echo "📱 Resolución: 390x844 CSS pixels"
echo "📏 Equivalente a: 1170x2532 píxeles físicos"
echo ""

FLUTTER_HOME=${FLUTTER_HOME:-"$HOME/development/flutter"}
FLUTTER_BIN="$FLUTTER_HOME/bin/flutter"

if [ ! -x "$FLUTTER_BIN" ]; then
  echo "ERROR: No se encontró Flutter en: $FLUTTER_BIN"
  echo "AYUDA: Ajusta la variable FLUTTER_HOME o instala Flutter en ~/development/flutter"
  exit 1
fi

# Detener cualquier proceso anterior
pkill -f "flutter run"

# Ejecutar con Chrome en modo iPhone 12 Pro
"$FLUTTER_BIN" run -d chrome \
  --web-port=8080 \
  --web-hostname=localhost \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.33.0/bin/

echo ""
echo "✅ Aplicación ejecutándose en: http://localhost:8080"
echo "📱 Simulando iPhone 12 Pro (390x844)"
echo ""
echo "💡 Para cambiar el tamaño de la ventana del navegador:"
echo "   - Presiona F12 para abrir DevTools"
echo "   - Haz clic en el ícono de dispositivo móvil"
echo "   - Selecciona 'iPhone 12 Pro' en la lista"
echo ""
