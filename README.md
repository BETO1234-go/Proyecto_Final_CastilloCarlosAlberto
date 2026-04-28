# Control de Inventario - Proyecto Final Flutter

Aplicacion movil multiplataforma desarrollada en Flutter para administrar productos de un pequeno negocio.

El proyecto implementa alta, edicion y eliminacion de productos, control de movimientos de inventario, reportes y exportacion de informacion.

## Descripcion general

Este proyecto corresponde a la opcion de proyecto:

- Proyecto 2: Control de Inventario

La app permite llevar el control de productos con los siguientes campos:

- Nombre
- SKU
- Categoria
- Unidad
- Stock
- Stock minimo
- Costo
- Precio

Tambien permite registrar movimientos de entrada, salida y ajuste para mantener el inventario actualizado en tiempo real.

## Funcionalidades principales

- Dashboard con metricas clave:
- Cantidad de productos
- Unidades en stock
- Productos con stock bajo
- Gestion de productos:
- Crear producto
- Editar producto
- Eliminar producto
- Busqueda por nombre, SKU o categoria
- Escaneo de codigo para filtrar/buscar SKU
- Gestion de movimientos:
- Registro de entradas, salidas y ajustes
- Listado historico de movimientos
- Validaciones de negocio (por ejemplo, no permitir stock negativo)
- Reportes:
- Filtros por categoria y periodo
- Exportacion a CSV
- Exportacion a PDF

## Requerimientos tecnicos implementados

- Flutter con null safety
- Navegacion entre multiples pantallas
- Manejo de estado con Riverpod
- Persistencia local con SQLite (sqflite)
- Simulacion de datos estructurados iniciales
- Diseno responsivo con Material Design
- Formularios con validaciones
- Manejo de estados de carga y error
- Separacion por capas (UI, logica, datos)

## Estructura del proyecto

- lib/app: configuracion principal de la app y rutas
- lib/core: utilidades compartidas de infraestructura
- lib/features/inventory:
- application: servicios de aplicacion (reportes/exportacion)
- data: repositorios e implementacion de acceso a datos
- domain: entidades del dominio
- presentation: pantallas, providers y widgets
- lib/shared: tema y estilos compartidos

## Tecnologias y paquetes

- flutter_riverpod
- go_router
- sqflite
- path_provider
- mobile_scanner
- barcode_widget
- pdf
- share_plus
- intl

## Instrucciones de ejecucion

1. Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd examen_final
```

2. Instalar dependencias

```bash
flutter pub get
```

3. Ejecutar la aplicacion en modo debug

```bash
flutter run
```

4. Ejecutar analisis estatico

```bash
flutter analyze
```

5. Ejecutar pruebas

```bash
flutter test
```

6. Generar APK

```bash
flutter build apk --release
```

El APK generado se encuentra en:

- build/app/outputs/flutter-apk/app-release.apk

## Evidencia de cumplimiento de rubrica

- Minimo 3 pantallas funcionales: Dashboard, Productos, Movimientos, Reportes
- Navegacion funcional: barra inferior y NavigationRail adaptativo
- Persistencia local: base SQLite con tablas de productos y movimientos
- Manejo de estado: StateNotifier + Riverpod
- Formularios con validaciones: alta y edicion de productos
- Manejo de errores y carga: SnackBar + indicadores de progreso

## Autor

- Nombre del estudiante: Carlos Alberto Castillo Pinzon
- Institucion: ITES Rene Descartes
- Ciclo: Enero - Abril 2026 (26-2)
