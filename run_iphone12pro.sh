#!/bin/bash

# Script para ejecutar Flutter con resolución de iPhone 12 Pro
# Resolución: 390x844 (CSS pixels) - equivalente a 1170x2532 píxeles físicos

echo "🚀 Iniciando KIPU con resolución iPhone 12 Pro..."
echo "📱 Resolución: 390x844 CSS pixels"
echo "📏 Equivalente a: 1170x2532 píxeles físicos"
echo ""

# Detener cualquier proceso anterior
pkill -f "flutter run"

# Ejecutar con Chrome en modo iPhone 12 Pro
flutter run -d chrome \
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
