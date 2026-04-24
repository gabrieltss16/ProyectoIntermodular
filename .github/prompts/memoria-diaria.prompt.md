---
name: memoria-diaria
description: "Actualiza la memoria total (un solo archivo) a partir del borrador automático (git log/diff) generado por tools/generate_memoria.ps1."
---

# Memoria total (un solo archivo) — actualización diaria (desde git log/diff)

Vas a escribir una **entrada diaria** para la memoria de un proyecto escolar (Flutter + Firebase + Azure OpenAI), basándote en el texto que te paso (borrador automático generado por un script).

## Entradas
Te proporcionaré:
1) El borrador automático (incluye rango de commits, diff stat, archivos tocados y cambios sin commitear).
2) (Opcional) Notas rápidas mías (objetivo del día, bloqueos, capturas realizadas, decisiones).

## Reglas de redacción (muy importante)
- Escribe en **español**, tono **neutral y profesional** (voz de alumno), **sin mencionar IA** ni frases tipo “como modelo de IA”.
- No inventes datos: si algo no aparece en el borrador, pregúntalo o deja un placeholder.
- **Nunca** copies ni incluyas secretos (API keys, tokens, endpoints con credenciales, `google-services.json`, etc.). Si aparecen, sustitúyelos por `[REDACTADO]`.
- Sé concreto: 5–12 bullets máximo por sección.

## Salida requerida (Markdown listo para pegar en UN SOLO ARCHIVO)
Devuelve **solo** este bloque, sin explicaciones adicionales.

Tu salida debe estar pensada para pegarse en el archivo maestro de memoria (estructura oficial):
1. Fundamentación
2. Destinatarios
3. Objetivos
4. Metodología
5. Temporalización (incluye Diario)
6. Recursos
7. Conclusiones
8. Bibliografía/Webgrafía

### 1) Entrada de Diario (para pegar en 5.1)
- Crea una entrada nueva `#### Diario YYYY-MM-DD` (o actualízala si ya existe en el archivo).

### 2) Propuestas de actualización del resto de secciones (si procede)
- Solo incluye cambios que se desprendan del borrador.
- Si una sección no cambia, pon: `Sin cambios`.

### 3) Propuesta de actualización de RF (si aplica)
- Lista cambios de estado sugeridos (ej. RF06: Firestore OK).

### 4) Archivos clave tocados
- 5–12 rutas.

## Plantilla exacta
Usa esta plantilla tal cual (rellenando contenido). Si no hay datos para una parte, deja `(...)`:

#### Diario YYYY-MM-DD
- **Resumen:** ...
- **Evidencias (tests/demo/capturas):** ...
- **Cambios técnicos relevantes:** ...
- **Decisiones y justificación:** ...
- **Riesgos / pendientes:** ...
- **Próximo paso:** ...

---

### Propuestas de actualización de la memoria total

**1. Fundamentación**
- Sin cambios | Cambios: ...

**2. Destinatarios**
- Sin cambios | Cambios: ...

**3. Objetivos**
- Sin cambios | Cambios: ...

**4. Metodología**
- Sin cambios | Cambios: ...

**5. Temporalización**
- Sin cambios | Cambios: ...

**6. Recursos**
- Sin cambios | Cambios: ...

**7. Conclusiones**
- Sin cambios | Cambios: ...

**8. Bibliografía y Webgrafía**
- Sin cambios | Cambios: ...

---

### RF (propuesta de cambios)
- ...

### Archivos clave
- ...
