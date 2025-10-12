# 📱 KIPU - Configuración iPhone 12 Pro

## 🚀 Ejecutar con Resolución iPhone 12 Pro

### Opción 1: Script Automático
```bash
./run_iphone12pro.sh
```

### Opción 2: Comando Manual
```bash
flutter run -d chrome --web-port=8080 --web-hostname=localhost
```

## 📏 Especificaciones iPhone 12 Pro

- **Resolución CSS**: 390 × 844 píxeles
- **Resolución Física**: 1170 × 2532 píxeles  
- **Densidad**: 460 ppi
- **Ratio**: 19.5:9
- **Pixel Ratio**: 3.0x

## 🎯 Configuración Aplicada

### 1. Viewport HTML
```html
<meta content="width=390, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport">
```

### 2. Estilos CSS
```css
body {
  max-width: 390px;
  margin: 0 auto;
  box-shadow: 0 0 20px rgba(0,0,0,0.3);
  border-radius: 20px;
  overflow: hidden;
}
```

### 3. Nuevo Toggle Personalizado
- ✅ Implementado con estilo CSS personalizado
- ✅ Animación suave de 400ms
- ✅ Efecto de sombra azul cuando está activo
- ✅ Bordes redondeados y colores personalizables

## 🔧 Comandos Útiles

### Verificar Dispositivos
```bash
flutter devices
```

### Análisis de Código
```bash
flutter analyze
```

### Limpiar Build
```bash
flutter clean
flutter pub get
```

## 🌐 Acceso Web

- **URL**: http://localhost:8080
- **DevTools**: Disponible en el navegador (F12)
- **Modo Responsivo**: Activar en DevTools para simular iPhone 12 Pro

## 📱 Simulación en Navegador

1. Abrir DevTools (F12)
2. Hacer clic en el ícono de dispositivo móvil
3. Seleccionar "iPhone 12 Pro" de la lista
4. La aplicación se ajustará automáticamente

## ✨ Características del Nuevo Toggle

- **Dimensiones**: 56px × 32px (3.5em × 2em)
- **Animación**: Transición suave con cubic-bezier
- **Colores**: 
  - Inactivo: #414141
  - Activo: #0974F1 con sombra
- **Funcionalidad**: Idéntica al Switch original
