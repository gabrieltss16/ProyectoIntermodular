# Cierre de entrega FisioIA

## Estado actual

- Sesión persistente implementada y validada
- Logout funcional desde menú principal y perfil
- Navegación protegida para evitar volver a login con botón atrás
- Reglas base de Firestore preparadas
- Catálogo ampliado con 5 zonas y múltiples ejercicios por zona
- Chat reforzado con comandos, límites y manejo de errores

## Checklist de validación final

1. Autenticación
   - Login correcto con usuario válido
   - Registro de nuevo usuario
   - Reinicio de app con sesión persistente
   - Logout desde menú principal
   - Logout desde perfil

2. Catálogo
   - Listado de zonas visible
   - Acceso a ejercicios por cada zona
   - Apertura de detalle de ejercicio
   - Creación de rutina desde ejercicio

3. Rutinas
   - Guardado de rutina IA
   - Edición y guardado de rutina IA
   - Duplicado de rutina
   - Restricción en modo invitado

4. Chat
   - Respuesta para zonas y ejercicios
   - Comando `ayuda`
   - Comando `limpiar chat`
   - Comando `cancelar rutina`
   - Guardado de rutina pendiente
   - Mensaje controlado para errores o límites

5. Seguridad
   - Despliegue de `firestore.rules`
   - Pruebas básicas de aislamiento por usuario

## Demo en móvil físico

1. Conectar dispositivo con depuración USB habilitada
2. Ejecutar `flutter devices` y comprobar detección
3. Ejecutar `flutter run -d <deviceId>`
4. Probar flujo completo:
   - Login
   - Navegación por zonas
   - Rutina por chat
   - Guardado en Mis rutinas
   - Cierre y reapertura de app (sesión persistente)

## Evidencias recomendadas para defensa

- Captura 1: Home + botones de acceso
- Captura 2: Menú principal con sesión iniciada
- Captura 3: Zonas y ejercicios
- Captura 4: Chat generando rutina
- Captura 5: Mis rutinas con rutina guardada
- Captura 6: Perfil y logout
- Captura 7: Documento de reglas Firestore desplegadas

## Riesgos pendientes

- Sin imágenes reales en `assets/images`, se usa fallback visual (icono)
- Si no hay dispositivo/emulador activo, `flutter run` fallará aunque `flutter analyze` sea correcto
- Si Firebase no está inicializado en entorno final, habrá modo demo en partes de la app
