# Sistema de Monitorización Remota de Pacientes

Una aplicación desarrollada en Flutter para la monitorización remota de signos vitales de pacientes.

## Descripción

Esta aplicación permite al personal sanitario monitorizar de forma remota los signos vitales de sus pacientes, recibir alertas cuando los valores se encuentran fuera de los rangos normales, y gestionar la información de pacientes y sus lecturas.

## Funcionalidades

- **Autenticación**: Inicio de sesión para personal sanitario.
- **Dashboard**: Vista general de pacientes y alertas pendientes.
- **Gestión de Pacientes**: Listado y detalles de pacientes.
- **Monitorización de Signos Vitales**: Visualización de lecturas recientes y tendencias. "En desarrollo"
- **Sistema de Alertas**: Notificaciones cuando los valores están fuera de rango. "En desarrollo"
- **Configuración de Umbrales**: Personalización de los valores considerados normales. "En desarrollo"
- **Simulación de Datos**: Herramienta para simular lecturas de signos vitales. "En desarrollo"

## Tecnologías Utilizadas

- **Frontend**: Flutter
- **Backend**: Spring
- **Gráficos**: fl_chart

## Requisitos para Desarrollo

- Flutter 3.0.0 o superior
- Dart 2.18.0 o superior
- Firebase CLI (para despliegue)

## Instalación y Ejecución

1. Clonar el repositorio:
   ```
   git clone https://github.com/juapasfer2/TFG.git
   ```

2. Instalar dependencias:
   ```
   flutter pub get
   ```

3. Ejecutar la aplicación:
   ```
   flutter run
   ```

## Estructura del Proyecto

```
lib/
├── models/        # Modelos de datos
├── screens/       # Pantallas de la aplicación
├── services/      # Servicios para API y backend
├── utils/         # Utilidades y helpers
└── widgets/       # Widgets reutilizables
```

## Modo Demo

La versión actual se encuentra en desarrollo lo que quiere decir que hay cosas que no estan implementadas y no tienen funcionamiento.

