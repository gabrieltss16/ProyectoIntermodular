# Defensa de Seguridad en Firestore — FisioIA

## Resumen ejecutivo
FisioIA implementa seguridad de acceso por usuario (Row-Level Security) en Firestore mediante reglas de firewall declarativas. Cada usuario solo puede leer/escribir sus propios datos de rutinas y perfil.

---

## Arquitectura de datos

### Modelo
```
/users/{uid}                    ← Documento del usuario (perfil, email)
/users/{uid}/routines/{id}      ← Rutinas del usuario (subcolección privada)
```

### Flujo de acceso
1. Usuario se autentica con Firebase Auth (email/contraseña)
2. App obtiene token JWT con su `uid`
3. Firestore verifica token + compara `uid` en cada lectura/escritura
4. Si `uid` no coincide, deniega la operación (**403 Forbidden**)

---

## Reglas implementadas

**Archivo:** `app/firestore.rules` (versionado)

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

### Análisis línea a línea
| Regla | Efecto | Defensa |
|-------|--------|---------|
| `isSignedIn()` | Bloquea acceso anónimo | ✓ Modo invitado local, Firestore protegido |
| `isOwner(userId)` | Compara `uid` del token vs. ruta | ✓ Imposible falsificar uid (JWT verificado por Firebase) |
| `allow create: if isOwner(userId)` | Solo tu usuario puede crear su doc | ✓ Previne inyección en otra colección |
| `allow read/update/delete: if isOwner(userId)` | Aislamiento completo | ✓ No hay fuga entre usuarios |
| Subcolección `routines` heredada | Rutinas heredan regla padre | ✓ Rutinas de A no visibles para B |

---

## Casos de ataque bloqueados

### Ataque 1: Leer rutinas de otro usuario
**Intento:** User A hace request GET a `/users/userB123/routines/`
**Defensa:** Firestore rechaza (auth.uid ≠ userB123)
**Verificación:** Test 1, Test 5

---

### Ataque 2: Escribir en perfil ajeno
**Intento:** User A intenta UPDATE en `/users/userB123` (ej. cambiar email del B)
**Defensa:** Firestore rechaza (auth.uid ≠ userB123)
**Verificación:** Test 4, Test 5

---

### Ataque 3: Crear rutina para otro usuario
**Intento:** User A intenta POST a `/users/userB456/routines/newRoutine`
**Defensa:** Firestore rechaza (create rule requiere isOwner)
**Verificación:** Test 4

---

### Ataque 4: Acceso sin autenticación
**Intento:** Request anónimo a cualquier colección
**Defensa:** Firestore rechaza (isSignedIn() == false)
**Verificación:** Set test mode a "Production" y verifica "read denied"

---

## Plan de activación

1. **Hoy:** Desplegar reglas
   ```bash
   cd app
   npm install -g firebase-tools        # Si no está
   firebase login
   firebase use --add
   firebase deploy --only firestore:rules
   ```

2. **Validación:** Ejecutar 5 tests de seguridad (ver `firestore_security_deployment.md`)

3. **Documentación:** Capturar pantallas de:
   - Rules simulator mostrando "Denied"
   - Firestore console con documentos aislados por uid
   - Test de User A/B sin cruce de datos

---

## Referencias y estándares

- **Firebase Security Rules:** https://firebase.google.com/docs/firestore/security/get-started
- **OWASP:** Principle of Least Privilege (cada usuario solo accede al mínimo necesario)
- **CWE-639:** Authorization Bypass (estamos previniendo esto)

---

## Limitaciones conocidas (y plan de cierre)

| Limitación | Impacto | Plan futuro |
|-----------|--------|------------|
| Reglas lado cliente (app puede fallar) | Bajo (Firebase aún verifica) | Límite diario en backend (Cloud Function) |
| Sin auditoria de modificaciones | Bajo (app nueva) | Cloud Firestore audit logs (premium) |
| Sin encryption end-to-end | Bajo (datos no sensibles; email/nombre) | Opcional para v2 |

---

## Evidencia de pruebas

**Antes de defensa, ejecuta y documenta:**
- [ ] Test 1: User A vs User B (rutinas aisladas)
- [ ] Test 3: Hot reload respeta sesión
- [ ] Test 5: Rules simulator muestra denegación
- [ ] Captura de Firestore console mostrando estructura: `/users/{uid}/routines/{id}`

---

**Conclusión:**
FisioIA implementa Row-Level Security (RLS) con Firestore Rules, asegurando que cada usuario solo accede a sus datos. Las reglas se verifican en el servidor (Google's infrastructure) y no dependen de validación solo en cliente.
