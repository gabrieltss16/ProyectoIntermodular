# Despliegue de Reglas de Seguridad en Firestore

## Objetivo
Desplegar reglas que aseguren que cada usuario solo acceda a sus propios datos (`users/{uid}` y `users/{uid}/routines`).

## Requisitos previos
1. Tener Firebase CLI instalado:
   ```bash
   npm install -g firebase-tools
   ```
2. Tener una cuenta en Firebase Console con tu proyecto `FisioIA` creado y navegable.
3. Estar en la carpeta `ProyectoIntermodular/app` del proyecto.

## Paso 1: Autenticarse en Firebase
```bash
firebase login
```
Abrirá navegador para que apruebes acceso. Sigue pantalla.

## Paso 2: Conectar el proyecto local a Firebase
```bash
firebase use --add
```
Selecciona tu proyecto `FisioIA` de la lista y dale un alias (ej: `default`).

Verifica que quedó configurado:
```bash
firebase projects:list
```

## Paso 3: Desplegar las reglas
Desde `ProyectoIntermodular/app`:
```bash
firebase deploy --only firestore:rules
```

**Salida esperada:**
```
┌──────────────────────────────┐
│          Firestore           │
├──────────────────────────────┤
│ ✔  Deploy complete!          │
└──────────────────────────────┘
```

> Si hay error de permisos, comprueba en Firebase Console que tu usuario tiene rol Editor o Firestore Admin.

## Paso 4: Verificar reglas en Firebase Console
1. Entra en https://console.firebase.google.com/
2. Proyecto `FisioIA` → Build → Firestore Database
3. Pestaña **Rules** → verifica que aparecen las nuevas reglas

Debería verse algo como:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow create: if isOwner(userId);
      allow read, update, delete: if isOwner(userId);

      match /routines/{routineId} {
        allow create, read, update, delete: if isOwner(userId);
      }
    }
  }
}
```

---

# Plan de Pruebas de Seguridad

Objetivo: validar que las reglas funcionan correctamente (cada usuario solo accede a sus datos).

## Test 1: Usuario A crea rutina → Usuario B NO puede verla
### Setup
1. Abre app en emulador/móvil
2. Crea cuenta **User A** (ej: `userA@test.com` / `password123`)
3. Crea una rutina llamada "Rutina A"
4. Cierra sesión

### Prueba
5. Crea cuenta **User B** (ej: `userB@test.com` / `password123`)
6. Abre "Mis rutinas" → **Debería estar vacío (no ver "Rutina A")**

### Resultado esperado
✓ User B ve lista vacía
✗ Si User B ve "Rutina A", las reglas no funcionan

---

## Test 2: Intento directo en Firestore (via consola)
### Setup en Firestore Emulator (opcional, si quieres test local)
Si quieres emular antes de desplegar:

1. Descarga Firebase Emulator Suite:
   ```bash
   firebase init emulators
   ```
2. Selecciona Firestore (y Auth si quieres)
3. Inicia emulador:
   ```bash
   firebase emulators:start
   ```

### Prueba en consola de Firebase
1. Abre la consola de Firestore (live, no emulador)
2. Crea documento en `users/userA123/routines/rutina1` con datos fictos
3. Intenta crear documento en `users/userB456/routines/rutina1` sin estar logueado
   - **Debería fallar: "Missing or insufficient permissions"**

---

## Test 3: Hot Reload + Cambio de sesión
### Setup
1. Usuario A abierto, tiene "Mis rutinas" cargado
2. Hotkey `r` en flutter run (hot reload)

### Prueba
3. Usuario A cierra sesión desde UI
4. Inicia sesión como User B
5. Abre "Mis rutinas" → **Debería cargar lista de User B, no la de A**

### Resultado esperado
✓ La transición de sesión respeta las reglas
✗ Si quedan rutinas de A visibles, hay problema de caché o reglas

---

## Test 4: Creación de rutina justo después de login
### Setup
1. User A inicia sesión
2. Crea Nueva rutina
3. Verifica en Firestore Console que aparece en `users/{uidA}/routines/{id}`

### Prueba
4. Cierra sesión
5. Inicia sesión como User B
6. Crea nueva rutina
7. Verifica en Firestore Console que aparece en `users/{uidB}/routines/{id}` (**diferente colección**)

### Resultado esperado
✓ Las rutinas quedan isoladas por uid
✗ Si aparecen en la misma colección, hay error en el app code

---

## Test 5: Intento de editar documento ajeno (nivel avanzado)
Si tienes acceso a herramientas como Postman o curl:

1. Obtén token JWT de User A (disponible en Firebase Auth console)
2. Intenta hacer PATCH a `users/{uidB}/routines/{id}` con token de A
   - **Debería fallar con 403 Forbidden**

Alternativa más simple: usa Firestore online rules simulator:
1. Firebase Console → Firestore → Rules → Simulator
2. Request: `update`
3. Path: `users/userB123/routines/rutina1`
4. Auth UID: `userA123`
5. Run → **Debería mostrar "Denied"**

---

## Checklist de Aceptación (para defender en clase)
- [ ] Reglas desplegadas sin error (`firebase deploy --only firestore:rules`)
- [ ] User A crea rutina, User B no la ve (Test 1)
- [ ] Firestore rule simulator muestra denegación para usuario ajeno (Test 5)
- [ ] Hot reload respeta límites de sesión (Test 3)
- [ ] Cada usuario solo escribe en su subcolección (Test 4)
- [ ] Documentación de reglas clara en `firestore.rules` y disponible en repo

## Troubleshooting

### "firebase command not found"
```bash
npm install -g firebase-tools
```

### "Authentication required"
```bash
firebase logout
firebase login
firebase use --add
```

### "Permission denied" al desplegar
- Firebase Console → IAM → comprueba que tu usuario tiene rol **Editor** o **Firestore Admin**

### Las reglas no se aplican
- Asegúrate de que despliegue dice "✔ Deploy complete!"
- Espera 10-15 segundos (tarda en propagarse)
- Recarga emulador/app desde cero (mata y reinicia `flutter run`)
