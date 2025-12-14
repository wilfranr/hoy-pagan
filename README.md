# Control de Gastos en Flutter (KIPU)

## Descripción General

Este es un proyecto de Flutter que implementa una aplicación simple para el control de gastos personales. La aplicación permite al usuario gestionar un presupuesto mensual, registrar gastos y hacer un seguimiento de cuáles han sido pagados.

El proyecto fue creado siguiendo los requisitos de un usuario, con un enfoque en la estructura del código y la lógica de negocio, utilizando `StatefulWidget` para el manejo del estado y `shared_preferences` para la persistencia de datos. No se han aplicado estilos personalizados complejos, utilizando principalmente los widgets de Material Design.

## Tecnologías Utilizadas

- **Framework:** Flutter
- **Lenguaje:** Dart
- **Manejo de Estado:** `StatefulWidget` con `setState()`
- **Persistencia:** `shared_preferences`
- **Formato de Moneda:** `intl`

## Estructura del Proyecto

El código fuente principal se encuentra en el directorio `lib/` y está organizado de la siguiente manera:

-   `lib/main.dart`: El punto de entrada de la aplicación. Configura `MaterialApp` y la pantalla principal.
-   `lib/models/gasto_model.dart`: Define la clase `Gasto`, que es el modelo de datos para cada gasto. Incluye métodos `toJson` y `fromJson` para la serialización.
-   `lib/screens/home_screen.dart`: Contiene la pantalla principal de la aplicación. Es un `StatefulWidget` que maneja toda la lógica de la aplicación, incluyendo:
    -   Visualización del saldo disponible.
    -   Lista de gastos.
    -   El botón "Recibí mi pago" que procesa el ingreso mensual.
    -   Carga y guardado de datos usando `shared_preferences`.
    -   Una función que imprime alertas en la consola para pagos pendientes.

## Cómo Ejecutar la Aplicación

### Configuración local en este equipo

Flutter está instalado en `~/development/flutter`. Para usar esa instalación sin modificar el PATH global, puedes definir `FLUTTER_HOME` (opcional) y añadir el binario al PATH en la terminal donde ejecutes los comandos:

```bash
export FLUTTER_HOME="$HOME/development/flutter"
export PATH="$FLUTTER_HOME/bin:$PATH"
```

El script `run_iphone12pro.sh` detecta automáticamente `FLUTTER_HOME` y, si no está definido, toma `~/development/flutter` como valor por defecto.

### Pasos para ejecutar

1.  Abre una terminal en el directorio raíz del proyecto.
2.  Instala las dependencias:
    ```bash
    "$HOME/development/flutter/bin/flutter" pub get
    ```
3.  Ejecuta la aplicación en un emulador o dispositivo conectado:
    ```bash
    "$HOME/development/flutter/bin/flutter" run
    ```
4.  Para emular rápidamente la resolución de un iPhone 12 Pro en Chrome:
    ```bash
    ./run_iphone12pro.sh
    ```

## Funcionalidades Clave Implementadas

-   **Persistencia de Estado:** El saldo y la lista de gastos se guardan en el dispositivo y se cargan al iniciar la app.
-   **Lógica de Pago Mensual:** Al presionar "Recibí mi pago", el saldo se incrementa con el ingreso mensual, se resetean los estados de los gastos y se pagan automáticamente los que corresponden al primer día.
-   **Pago Manual:** Se puede marcar un gasto como pagado o no pagado directamente desde la lista, ajustando el saldo disponible.
-   **Alertas en Consola:** Al iniciar la app, se revisan los gastos y se imprime un mensaje en la consola de depuración si un pago está próximo a vencer.