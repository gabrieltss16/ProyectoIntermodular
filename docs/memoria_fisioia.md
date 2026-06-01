# MEMORIA DEL PROYECTO

## FisioIA — Aplicación móvil de rehabilitación con asistente de inteligencia artificial

**Alumno:** Gabriel T.S.  
**Tutor/a:** [Nombre del tutor/a]  
**Curso:** 2025–2026  
**Ciclo:** CFGS Desarrollo de Aplicaciones Multiplataforma  
**Centro:** [Nombre del centro] — Valladolid

---

## Índice

1. Fundamentación
2. Destinatarios
3. Objetivos
4. Metodología
5. Temporalización
6. Recursos
7. Guía de usuario
8. Conclusiones
9. Bibliografía y webgrafía

---

## 1. Fundamentación

### 1.1 Descripción del proyecto

FisioIA es una aplicación móvil multiplataforma, desarrollada con el *framework* *Flutter*, que ofrece a personas con molestias articulares o en proceso de rehabilitación un catálogo completo de ejercicios terapéuticos organizados por zona corporal, un sistema de rutinas personalizadas y un asistente conversacional basado en inteligencia artificial. La aplicación está diseñada para funcionar tanto en dispositivos Android como iOS a partir de una única base de código, y combina almacenamiento en la nube mediante *Firebase* con un modo de funcionamiento local que garantiza la accesibilidad incluso sin conexión permanente.

### 1.2 El problema: la brecha entre la consulta y el domicilio

Las patologías del aparato locomotor constituyen una de las principales causas de consulta sanitaria en España. Según datos del Instituto Nacional de Estadística, los trastornos musculoesqueléticos representan cerca del 30 % de las bajas laborales, y condiciones como la lumbalgia, la tendinitis o la artrosis afectan a millones de personas cada año. El tratamiento de estas dolencias suele incluir ejercicios de rehabilitación pautados por un fisioterapeuta, que el paciente debe realizar de forma autónoma en su domicilio durante semanas o incluso meses.

Sin embargo, la realidad muestra que la adherencia a los programas de ejercicio domiciliario es baja. Diversos estudios sitúan las tasas de cumplimiento entre el 30 % y el 50 % cuando el paciente no cuenta con supervisión continuada. Las causas son variadas: falta de motivación, olvido de las pautas, inseguridad sobre la ejecución correcta de los ejercicios, o simplemente la ausencia de un canal de comunicación ágil con el profesional sanitario entre sesiones presenciales.

A esto se suma un problema de accesibilidad. No todos los pacientes pueden permitirse sesiones frecuentes de fisioterapia privada, y las listas de espera en el sistema público pueden prolongarse semanas. En este contexto, surge una oportunidad real para la tecnología móvil: ofrecer un acompañamiento complementario que no sustituya al profesional, pero que sí ayude al usuario a mantener la constancia, resolver dudas básicas y organizar su rutina de ejercicios de forma estructurada.

### 1.3 Justificación de la propuesta

FisioIA nace de la confluencia de tres factores. En primer lugar, la necesidad detectada: personas con molestias articulares que necesitan una guía accesible para sus ejercicios de rehabilitación. En segundo lugar, la viabilidad tecnológica: las herramientas actuales permiten desarrollar una aplicación multiplataforma con inteligencia artificial integrada a un coste razonable, aprovechando servicios en la nube con programas educativos gratuitos como *Azure for Students*. En tercer lugar, el interés formativo: el proyecto permite aplicar de forma práctica competencias del ciclo de Desarrollo de Aplicaciones Multiplataforma —diseño de interfaces, persistencia de datos, integración de servicios externos, seguridad y despliegue— dentro de un caso de uso real y socialmente relevante.

La propuesta se diferencia de las aplicaciones genéricas de fitness en varios aspectos. No se trata de un catálogo pasivo de ejercicios, sino de un sistema que combina contenido estructurado con un asistente conversacional capaz de interpretar la situación del usuario, sugerir rutinas adaptadas a su zona afectada y ofrecer explicaciones contextualizadas. Además, la aplicación incorpora mecanismos de seguridad —como el aviso médico obligatorio y la limitación de consultas diarias— que reflejan un uso responsable de la inteligencia artificial en el ámbito de la salud.

### 1.4 Justificación tecnológica

La elección de *Flutter* como *framework* de desarrollo responde a la necesidad de alcanzar tanto usuarios de Android como de iOS con un único proyecto, reduciendo el tiempo de desarrollo y garantizando una experiencia visual coherente en ambas plataformas. *Firebase* proporciona autenticación, base de datos en tiempo real y reglas de seguridad sin necesidad de mantener un servidor propio, lo que resulta ideal para un proyecto individual con recursos limitados. Por su parte, *Azure OpenAI* ofrece acceso a modelos de lenguaje de última generación con control granular del gasto, aspecto crítico cuando se trabaja con créditos educativos.

---

## 2. Destinatarios

### 2.1 Perfil del usuario principal

FisioIA está dirigida a un público amplio pero con un perfil bien definido: personas adultas, de entre 18 y 65 años, que experimentan molestias o lesiones articulares de carácter leve a moderado, o que se encuentran en fase de rehabilitación tras una intervención o un episodio agudo. Este perfil incluye tanto a personas sedentarias que comienzan a notar las consecuencias de la falta de movimiento como a deportistas amateur que necesitan ejercicios de recuperación tras una lesión.

El nivel tecnológico de estos usuarios es variable. Por ello, la aplicación prioriza una navegación simple e intuitiva, con botones claros, textos comprensibles y un flujo lineal que no exige conocimientos previos sobre aplicaciones de salud o *fitness*. Se ha prestado especial atención a que la interfaz sea legible, con contrastes adecuados y tamaños de texto confortables, pensando en usuarios que puedan tener limitaciones visuales leves asociadas a la edad.

### 2.2 Necesidades que cubre la aplicación

Las necesidades identificadas en el público objetivo son las siguientes. En primer lugar, la necesidad de consultar ejercicios de rehabilitación de forma autónoma, sin depender exclusivamente de la memoria tras una sesión presencial con el fisioterapeuta. En segundo lugar, la necesidad de organizar esos ejercicios en rutinas personalizadas que puedan consultarse en cualquier momento y desde cualquier lugar. En tercer lugar, la necesidad de resolver dudas básicas sobre los ejercicios —cuántas repeticiones, para qué sirve cada uno, qué zona trabaja— sin tener que esperar a la siguiente cita. Y en cuarto lugar, la posibilidad de probar la aplicación sin compromiso, mediante un modo invitado que permite explorar el catálogo y el asistente antes de decidir registrarse.

Es importante señalar que FisioIA no pretende sustituir al profesional sanitario. La aplicación incluye un aviso médico obligatorio antes de acceder al asistente, y el propio chatbot está programado para recomendar la consulta presencial ante cualquier señal de alarma. El objetivo es complementar, no reemplazar, la atención profesional.

---

## 3. Objetivos

### 3.1 Objetivo general

Desarrollar una aplicación móvil multiplataforma que ayude a personas con molestias articulares o en rehabilitación a realizar ejercicios terapéuticos de forma guiada, combinando un catálogo estructurado por zonas corporales, un sistema de rutinas personalizadas y un asistente conversacional basado en inteligencia artificial que ofrezca acompañamiento informativo y motivacional.

### 3.2 Objetivos específicos

El proyecto se plantea los siguientes objetivos específicos, formulados como metas medibles del trabajo realizado:

Garantizar un acceso seguro y personalizado a la aplicación mediante un sistema de autenticación que permita al usuario mantener su progreso entre sesiones, incluyendo registro por correo electrónico con verificación, inicio de sesión con contraseña e integración con *Google Sign-In* como alternativa rápida.

Facilitar la consulta autónoma de ejercicios terapéuticos mediante un catálogo organizado por zona corporal que incluya información detallada de cada ejercicio —nombre, descripción, series y repeticiones—, permitiendo al usuario localizar rápidamente el contenido relevante para su situación.

Proporcionar un sistema de rutinas personalizadas que permita al usuario crear, editar, duplicar y eliminar secuencias de ejercicios, con almacenamiento persistente en la nube para usuarios registrados y almacenamiento local como alternativa para el modo invitado o situaciones sin conectividad.

Ofrecer un acompañamiento inteligente mediante un asistente conversacional que interprete las consultas del usuario, detecte la zona corporal mencionada y sugiera rutinas adaptadas a su condición, manteniendo un tono empático y responsable que incluya advertencias médicas cuando sea necesario.

Garantizar la viabilidad económica del asistente de inteligencia artificial mediante un sistema de control de uso diario que limite el número de consultas por usuario y día, y un mecanismo de respuesta local (*fallback*) que mantenga la aplicación funcional incluso cuando el servicio de IA no esté disponible.

Mantener un nivel de calidad verificable mediante el uso de herramientas de análisis estático (*flutter analyze*) y pruebas funcionales en emulador y dispositivo físico, asegurando que la aplicación se ejecute sin errores en los escenarios de uso principales.

---

## 4. Metodología

### 4.1 Elección del *framework*: *Flutter* y *Dart*

El desarrollo de FisioIA se ha realizado íntegramente con *Flutter*, el *framework* de código abierto de Google para la creación de aplicaciones multiplataforma. La decisión de utilizar *Flutter* se fundamenta en varias razones. En primer lugar, permite generar aplicaciones nativas tanto para Android como para iOS a partir de una única base de código, lo que reduce drásticamente el tiempo de desarrollo para un proyecto individual. En segundo lugar, *Flutter* utiliza *Dart* como lenguaje de programación, un lenguaje tipado y orientado a objetos cuya sintaxis resulta familiar para quien ya conoce Kotlin o Java, lo que facilita la transición desde el desarrollo Android nativo estudiado durante el ciclo formativo.

Además, *Flutter* ofrece un sistema de *widgets* composicionales que permite construir interfaces complejas de forma declarativa, un *hot reload* que acelera enormemente el ciclo de desarrollo, y una comunidad activa con abundante documentación y paquetes disponibles. El soporte nativo de *Material Design 3* fue también un factor decisivo, ya que permite aplicar las directrices de diseño más actuales de Google sin necesidad de bibliotecas externas.

### 4.2 Arquitectura de la aplicación

La aplicación sigue una arquitectura por capas que separa claramente las responsabilidades del código en tres niveles: modelos, servicios y pantallas.

La capa de **modelos** define las estructuras de datos de la aplicación mediante clases *Dart* inmutables. Cada modelo —`Exercise`, `Zone`, `Routine` y `UserProfile`— encapsula los campos necesarios y proporciona métodos de serialización (`fromJson` y `toJson`) para convertir entre objetos *Dart* y formato JSON, que es el utilizado tanto por *Firestore* como por *SharedPreferences*. El uso del patrón `copyWith` en los modelos permite crear copias modificadas sin alterar el original, lo que facilita la gestión del estado y reduce errores derivados de la mutabilidad.

La capa de **servicios** contiene toda la lógica de negocio y la comunicación con sistemas externos. Aquí se encuentran los servicios de autenticación, el servicio de catálogo que carga los datos desde un archivo JSON local, el repositorio de rutinas que implementa la persistencia dual, el servicio de *Azure OpenAI* que gestiona la comunicación con la API de inteligencia artificial, y utilidades como el limitador de uso diario o el validador de correo electrónico.

La capa de **pantallas** (*screens*) se ocupa exclusivamente de la interfaz de usuario. Cada pantalla es un *widget* de *Flutter* que recibe los datos necesarios a través de su constructor y delega la lógica de negocio en los servicios correspondientes. Esta separación permite que las pantallas sean ligeras y se centren en la presentación visual, mientras que los servicios pueden reutilizarse desde cualquier punto de la aplicación.

Esta arquitectura se eligió por su claridad y mantenibilidad. Al estar cada responsabilidad aislada en su propia capa, resulta sencillo localizar y modificar cualquier funcionalidad sin afectar al resto del sistema. Además, la separación facilita la realización de pruebas unitarias sobre los servicios de forma independiente a la interfaz gráfica.

### 4.3 Persistencia dual (*Dual-Path*)

Una de las decisiones técnicas más relevantes del proyecto es el sistema de persistencia dual. La aplicación utiliza dos mecanismos de almacenamiento en función del contexto del usuario:

Para el **catálogo de ejercicios**, los datos se almacenan en un archivo JSON local (`assets/exercises.json`) que se distribuye con la propia aplicación. Esta decisión responde a que el catálogo es contenido estático que no varía por usuario, y permite que la aplicación funcione completamente *offline* en lo que respecta a la consulta de ejercicios. El archivo contiene 82 ejercicios distribuidos en 9 zonas articulares, cada uno con nombre, descripción, series, repeticiones y etiquetas de clasificación por condición clínica.

Para las **rutinas del usuario**, se implementa un repositorio con doble camino. Si el usuario está autenticado y *Firebase* está disponible, las rutinas se almacenan en *Cloud Firestore* bajo la ruta `users/{uid}/routines/{routineId}`, garantizando la sincronización entre dispositivos y la persistencia a largo plazo. Si el usuario no ha iniciado sesión, o si *Firebase* no está configurado en el entorno de ejecución, las rutinas se almacenan localmente mediante *SharedPreferences*, proporcionando un *fallback* funcional que permite usar la aplicación en modo invitado o en situaciones de demostración.

Esta decisión aporta dos ventajas fundamentales. Por un lado, la aplicación nunca se bloquea por falta de conectividad o por una configuración incompleta de *Firebase*. Por otro, permite que el modo invitado sea completamente funcional para explorar la aplicación antes de registrarse, mejorando la experiencia de primer uso.

### 4.4 Integración de inteligencia artificial

La integración del asistente conversacional con *Azure OpenAI* constituye el elemento diferenciador del proyecto. El sistema se compone de varios niveles que trabajan de forma coordinada.

**El *system prompt* contextualizado.** Cada vez que el usuario envía un mensaje, la aplicación construye una petición a la API de *Azure OpenAI* que incluye un *prompt* de sistema extenso y cuidadosamente diseñado. Este *prompt* define el comportamiento del asistente: su personalidad (cercano, empático, motivador), la estructura de sus respuestas (empatía, justificación de rutina y pregunta de personalización), las situaciones en las que no debe sugerir ejercicios, y las condiciones de seguridad que debe respetar. Además, el *prompt* incluye el catálogo completo de ejercicios de la aplicación como contexto, de modo que la IA pueda fundamentar sus sugerencias en ejercicios reales disponibles en la app.

**La detección multi-capa de intenciones.** Antes de enviar el mensaje a la API, la aplicación analiza el texto del usuario de forma local mediante un sistema de detección por capas. La primera capa identifica palabras clave que indican intención de obtener una rutina ("rutina", "plan", "ejercicios", "dolor", "molestia"). La segunda capa extrae las zonas corporales mencionadas, tanto por nombre directo ("rodilla", "hombro") como por condición clínica asociada ("hernia" se mapea a zona lumbar, "epicondilitis" a codo, "esguince" a tobillo). Una tercera capa permite detectar múltiples zonas en un mismo mensaje para generar rutinas combinadas. Este análisis local permite que la aplicación genere la tarjeta visual de ejercicios sugeridos de forma inmediata, sin depender exclusivamente del procesamiento de la IA.

**El control de gasto.** Dado que cada consulta a *Azure OpenAI* tiene un coste asociado en tokens, la aplicación implementa un limitador de uso diario (*rate limiter*). El sistema registra en *SharedPreferences* el número de consultas realizadas por cada usuario en el día actual, y rechaza nuevas peticiones cuando se supera el límite configurado (10 consultas por defecto, ampliable mediante parámetros de compilación). Esta medida es imprescindible cuando se trabaja con créditos educativos limitados, y demuestra una gestión responsable de recursos en un entorno real.

**El *fallback* a modo demo.** Si las credenciales de *Azure OpenAI* no están configuradas, si la API devuelve un error, o si el usuario ha agotado su límite diario, la aplicación no se detiene. En su lugar, activa un modo de respuesta local que utiliza el catálogo de ejercicios para ofrecer sugerencias básicas basadas en la zona mencionada. De este modo, la experiencia del usuario no se interrumpe nunca, aunque la calidad de las respuestas sea menor que con el modelo de IA.

### 4.5 Seguridad y protección de datos

La seguridad se ha abordado desde múltiples perspectivas. A nivel de autenticación, *Firebase Authentication* gestiona el registro y el inicio de sesión, con verificación obligatoria de correo electrónico antes de permitir el acceso completo a la aplicación. Las contraseñas nunca se almacenan en el código ni en el dispositivo, ya que su gestión queda delegada íntegramente en *Firebase*.

A nivel de base de datos, las reglas de seguridad de *Firestore* garantizan que cada usuario solo puede leer y escribir sus propios documentos. La regla `isOwner(userId)` verifica que el identificador del usuario autenticado coincide con la ruta del documento solicitado, impidiendo el acceso cruzado entre cuentas.

A nivel de credenciales de la API de inteligencia artificial, las claves de *Azure OpenAI* se inyectan mediante variables de entorno en tiempo de compilación (`--dart-define`), de modo que nunca aparecen en el código fuente ni en el repositorio de control de versiones. Esta práctica sigue las recomendaciones de seguridad estándar para el manejo de secretos en aplicaciones móviles.

### 4.6 Interfaz de usuario y *Material Design 3*

La interfaz de FisioIA se ha diseñado siguiendo las directrices de *Material Design 3*, el sistema de diseño más reciente de Google. Se ha definido un esquema de color personalizado basado en tonos azules (#047CE3 como color primario, #020F70 como azul profundo para textos) que transmite profesionalidad y confianza, cualidades importantes en una aplicación relacionada con la salud.

La navegación principal se organiza mediante una barra inferior (*NavigationBar*) con cinco destinos para usuarios registrados (Explorar, Rutinas, IA, Perfil y Salir) y tres para invitados (Explorar, Rutinas y Salir). El contenido de cada pestaña se gestiona con un *PageView* que permite transiciones fluidas entre secciones sin recargar los datos.

Se han incorporado animaciones sutiles de aparición escalonada en las listas de zonas y rutinas, utilizando *TweenAnimationBuilder* para suavizar la entrada de cada elemento. Estas animaciones mejoran la percepción de calidad de la aplicación sin impactar negativamente en el rendimiento.

### 4.7 Requisitos funcionales implementados

A continuación se describen los requisitos funcionales que se han completado durante el desarrollo del proyecto:

RF01 — Gestión de usuarios: registro con correo electrónico y contraseña, inicio de sesión, cierre de sesión, verificación de correo obligatoria e integración con *Google Sign-In*.

RF02 — Catálogo por zona: 82 ejercicios distribuidos en 9 zonas articulares (rodilla, hombro, lumbar, cervical, tobillo, cadera, espalda dorsal, codo y muñeca), cargados desde un archivo JSON local.

RF03 — Detalle de ejercicio: cada ejercicio muestra nombre, descripción textual y orientación de series y repeticiones.

RF04 — Rutinas personalizadas: creación, visualización, edición, duplicado y eliminación de rutinas, con almacenamiento dual en *Firestore* o *SharedPreferences*.

RF05 — Asistente conversacional: integración con *Azure OpenAI* con *system prompt* personalizado, detección de intenciones, generación de rutinas adaptadas y modo demo como *fallback*.

RF06 — Persistencia de rutinas por usuario: almacenamiento en *Firestore* bajo la colección del usuario autenticado, con soporte *offline* mediante almacenamiento local.

RF07 — Aviso médico: diálogo bloqueante obligatorio antes de acceder al asistente, recordando que la aplicación no sustituye a un profesional sanitario.

RF08 — Modo invitado: acceso al catálogo y al chat en modo demo sin necesidad de registro, con restricción de guardado de rutinas e indicación informativa.

RF09 — Autenticación social: inicio de sesión con *Google Sign-In* como alternativa al correo y contraseña.

RF10 — Limitación de uso: máximo de 10 consultas diarias a la API de *Azure OpenAI* por usuario, configurable mediante parámetros de compilación.

RF11 — Persistencia del chat: historial de conversación almacenado por usuario en *SharedPreferences*, con restauración automática al reabrir la aplicación (últimos 120 mensajes).

RF12 — Tema visual: *Material Design 3* con esquema de color azul personalizado, contraste accesible y coherencia visual en todas las pantallas.

RF13 — Validación de datos: comprobación de formato de correo electrónico con detección de errores tipográficos comunes, confirmación de contraseña en registro, y validaciones en los modelos de datos.

### 4.8 Uso de inteligencia artificial en el desarrollo

De acuerdo con las directrices del módulo, se declara el uso de herramientas de inteligencia artificial como apoyo durante el desarrollo del proyecto. La herramienta utilizada ha sido *GitHub Copilot*, integrada en el editor *Visual Studio Code*.

Se ha empleado para acelerar tareas repetitivas como la generación de estructuras básicas de pantallas y servicios, la escritura de métodos de serialización JSON, y la propuesta de soluciones iniciales para problemas concretos de implementación. También se ha utilizado como apoyo para la redacción y estructuración de documentación.

En todos los casos, el código y el contenido generado con asistencia de IA han sido revisados, adaptados y validados manualmente. Todas las funcionalidades se han probado en ejecución real (emulador y dispositivo físico) y se han verificado con la herramienta de análisis estático `flutter analyze`. El uso de IA no exime del cumplimiento de las obligaciones de autoría, cita de fuentes y comprensión del trabajo presentado.

---

## 5. Temporalización

### 5.1 Organización del trabajo

El proyecto se inició el 16 de marzo de 2026 y se ha desarrollado de forma progresiva durante el periodo de prácticas formativas en empresa. La disponibilidad real para el proyecto era de lunes a miércoles con cinco horas diarias, y sábado y domingo con cuatro horas diarias. Los jueves y viernes no era posible dedicar tiempo al proyecto por compromisos laborales. Esta distribución supone una disponibilidad máxima teórica de aproximadamente 220 horas en todo el periodo.

La planificación se organizó por bloques funcionales: primero el aprendizaje del *framework* y la configuración del entorno, después la construcción de la estructura base, y finalmente la implementación progresiva de funcionalidades completas. Se priorizó tener una versión funcional lo antes posible para poder iterar sobre ella, en lugar de desarrollar módulos aislados que se integrasen al final.

### 5.2 Fases del proyecto

**Hito 1 — Inicio del proyecto (16–25 de marzo).** Durante la primera semana y media se definió el alcance del proyecto, se creó el repositorio en *GitHub*, se elaboró el diagrama entidad-relación del modelo de datos y se dedicó tiempo al aprendizaje inicial de *Dart* y *Flutter*. La prioridad fue comprender la estructura de un proyecto *Flutter* (carpetas, *widgets*, ciclo de vida) y conseguir que la aplicación se ejecutase correctamente en el emulador. Se crearon las primeras pantallas básicas y se estableció la separación en carpetas (modelos, servicios, pantallas) que se mantendría durante todo el desarrollo.

**Hito 2 — Primera base funcional (26 de marzo – 10 de abril).** En esta fase se implementó la pantalla de inicio, el catálogo inicial de ejercicios y la estructura mínima de navegación. El objetivo era disponer de una aplicación visualmente funcional que pudiera mostrarse en una primera revisión con la tutora, aunque aún no tuviera lógica de negocio completa. Se probó la navegación entre pantallas, la carga de datos desde JSON y la visualización básica de ejercicios por zona.

**Hito 3 — Desarrollo avanzado (11 de abril – 5 de mayo).** Esta fue la fase más intensa del proyecto. Se implementaron la autenticación completa (registro, inicio de sesión, verificación de correo, *Google Sign-In*), el sistema de rutinas con persistencia dual, el asistente conversacional con integración de *Azure OpenAI*, la persistencia del historial de chat, las reglas de seguridad de *Firestore*, el perfil de usuario y el modo invitado con restricciones. Se dedicaron varias sesiones a refinar la detección de intenciones del chat y a diseñar el *system prompt* para que las respuestas de la IA fuesen útiles y seguras.

**Hito 4 — Pulido y cierre (6–31 de mayo).** La última fase se centró en la coherencia visual de la aplicación, la consistencia de textos y títulos entre pantallas, la integración del logo y los iconos definitivos, y la preparación de la documentación final. Se revisaron todos los flujos de usuario buscando errores o inconsistencias, y se verificó el funcionamiento completo en dispositivo físico.

### 5.3 Diario de trabajo

**Semana 1 (16–18 de marzo) — Arranque y aprendizaje.** Se dedicaron estas primeras sesiones a definir la idea del proyecto y a estudiar la base de *Dart* como lenguaje de programación. Se creó el repositorio en *GitHub* con la estructura documental inicial y se elaboró el diagrama entidad-relación que serviría como referencia para el modelo de datos. La decisión más importante de esta fase fue separar la carpeta de documentación de la carpeta de la aplicación para poder avanzar en ambas de forma independiente. Se estimaron unas 12 horas de trabajo dedicadas principalmente a formación.

**Semana 2 (21–25 de marzo) — Primera aplicación visible.** Se inicializó el proyecto *Flutter* dentro de la carpeta `app` y se configuró el entorno de desarrollo (*VS Code*, *Android SDK*, emulador). Se creó la pantalla de inicio (*HomeScreen*) y un pequeño catálogo con las primeras zonas y ejercicios. La prioridad fue verificar que la aplicación abría correctamente en el emulador y que la navegación básica funcionaba. Se estimaron unas 15 horas de trabajo.

**Semana 3–4 (28 de marzo – 10 de abril) — Estructura y navegación.** Se construyó la estructura de navegación principal con la barra inferior, se implementaron las pantallas de zonas y ejercicios por zona, y se definió la arquitectura de servicios que se utilizaría en el resto del proyecto. Se tomó la decisión de usar un *PageView* para la navegación entre pestañas, lo que evita la recarga de datos al cambiar de sección. Se estimaron unas 25 horas de trabajo.

**Semana 5–6 (11–26 de abril) — Módulos principales.** Se implementó la autenticación con *Firebase* (registro, inicio de sesión, verificación de correo), el sistema de rutinas con almacenamiento dual, el chat con *Azure OpenAI* y el perfil de usuario. Se diseñó e implementó el *system prompt* del asistente, se programó la detección de intenciones y la generación de rutinas desde el chat. Se añadieron las reglas de seguridad de *Firestore* y se automatizó parte del seguimiento del proyecto. Se estimaron unas 50 horas de trabajo en esta fase intensiva.

**Semana 7 (28 de abril) — Coherencia visual.** Se ajustaron los estilos de texto y la consistencia de los títulos en las distintas pantallas. Se unificaron los tamaños de fuente, los márgenes y los colores para que toda la aplicación se percibiera como un producto visual coherente. Se estimaron unas 8 horas de trabajo.

**Semana 8–9 (mayo, primera quincena) — Pruebas y correcciones.** Se realizaron pruebas completas del flujo de usuario en emulador y en dispositivo físico. Se corrigieron errores encontrados en la persistencia del chat, en la navegación del modo invitado y en la validación de formularios. Se verificó que `flutter analyze` no reportase ningún problema. Se estimaron unas 15 horas de trabajo.

**Semana 10 (20 de mayo) — *Branding* final.** Se incorporó el logo definitivo de la aplicación y los iconos para la barra de navegación y las distintas secciones. Se organizó el sistema de *assets* para mantener consistencia en las imágenes. Se estimaron unas 5 horas de trabajo.

**Semana 11–12 (21 mayo – 1 junio) — Documentación y memoria.** Se dedicó este periodo final a la redacción de la memoria del proyecto, la preparación de la presentación de diapositivas y la revisión general del código y la documentación. Se estimaron unas 20 horas de trabajo.

### 5.4 Horas dedicadas por tipo de tarea (estimación)

| Tipo de tarea | Horas estimadas |
|---|---|
| Aprendizaje inicial de *Flutter* y *Dart* | 20–25 |
| Diseño y arquitectura | 20–25 |
| Desarrollo de pantallas y navegación | 45–55 |
| Autenticación, *Firestore* y rutinas | 45–55 |
| Chat con IA, persistencia y seguridad | 40–50 |
| Pruebas, correcciones y *branding* | 20–25 |
| Documentación y memoria | 20–25 |
| **Total estimado** | **210–260** |

---

## 6. Recursos

### 6.1 Recursos humanos

El proyecto ha sido desarrollado íntegramente por un único alumno, que ha asumido las funciones de análisis, diseño, desarrollo, pruebas y documentación. La tutora del proyecto ha proporcionado supervisión periódica, validación de los hitos establecidos y orientación sobre los criterios de evaluación.

### 6.2 Recursos espaciales

El desarrollo se ha realizado en entorno doméstico con conexión a Internet, necesaria para la configuración y el uso de los servicios en la nube (*Firebase* y *Azure OpenAI*). No se ha requerido acceso a infraestructura especial ni a servidores físicos.

### 6.3 Recursos materiales y tecnológicos

El equipamiento utilizado incluye un ordenador personal con sistema operativo *Windows*, el editor *Visual Studio Code* como entorno de desarrollo, el *SDK* de *Flutter* junto con el *Android SDK* y *Android Studio* para la compilación y el emulador, y un dispositivo Android físico para las pruebas finales.

En cuanto a servicios en la nube, se ha utilizado una cuenta de *Firebase* (que proporciona *Authentication* y *Cloud Firestore* en su capa gratuita) y una cuenta de *Azure for Students* para el acceso a *Azure OpenAI* con control de gasto mediante alertas de presupuesto. El control de versiones se ha gestionado con *Git* y *GitHub* como repositorio remoto.

---

## 7. Guía de usuario

### 7.1 Acceso inicial

Al abrir la aplicación por primera vez, el usuario se encuentra con la pantalla de bienvenida, que muestra el logotipo de FisioIA, una breve descripción del propósito de la aplicación y dos opciones de acceso: entrar como invitado o iniciar sesión.

*Figura 1. Pantalla de bienvenida con opciones de acceso (HomeScreen).*

Si el usuario no tiene cuenta, puede pulsar «Iniciar sesión» y desde ahí acceder a la pantalla de registro, donde deberá proporcionar un correo electrónico válido y una contraseña de al menos seis caracteres. Tras el registro, la aplicación envía un correo de verificación que el usuario debe confirmar antes de poder iniciar sesión por primera vez. Esta medida garantiza que las cuentas estén vinculadas a direcciones de correo reales.

*Figura 2. Pantalla de inicio de sesión con formulario y opciones de acceso.*

Si el usuario ya tiene cuenta, puede iniciar sesión con correo y contraseña o mediante *Google Sign-In*, que permite acceder con la cuenta de Google sin necesidad de recordar una contraseña adicional.

### 7.2 Modo invitado

El modo invitado permite explorar las funcionalidades principales de la aplicación sin necesidad de crear una cuenta. En este modo, el usuario puede navegar por el catálogo de ejercicios organizado por zonas y utilizar el asistente en modo demo. Sin embargo, no puede guardar rutinas personalizadas ni acceder a las opciones de perfil, ya que estas funcionalidades requieren autenticación para asociar los datos a un usuario concreto.

La barra de navegación en modo invitado se simplifica a tres secciones (Explorar, Rutinas y Salir), frente a las cinco del modo autenticado. Si el usuario intenta guardar una rutina estando en modo invitado, la aplicación le informa de la restricción y le sugiere registrarse para desbloquear esta funcionalidad.

### 7.3 Catálogo de ejercicios

La sección «Explorar» presenta las nueve zonas articulares disponibles en forma de lista, cada una con su icono representativo. Al pulsar sobre una zona, se despliega la lista de ejercicios correspondientes, mostrando el nombre de cada ejercicio junto con la información básica de series y repeticiones.

*Figura 3. Pantalla de zonas articulares (ZonesScreen).*

*Figura 4. Lista de ejercicios de una zona concreta (ZoneExercisesScreen).*

Cada ejercicio puede seleccionarse para ver su descripción completa, que incluye una explicación textual del movimiento y la orientación de carga recomendada. Desde esta vista, el usuario puede añadir el ejercicio a una rutina nueva o existente.

### 7.4 Rutinas personalizadas

La sección «Rutinas» se organiza en dos pestañas para usuarios registrados: «Mis rutinas», donde aparecen las rutinas creadas o guardadas por el usuario, y «Predeterminadas», donde se muestran rutinas base generadas automáticamente para cada zona articular.

*Figura 5. Pantalla de rutinas del usuario con opciones de gestión.*

El usuario puede crear una rutina manualmente seleccionando ejercicios del catálogo, o puede guardar directamente una rutina sugerida por el asistente de IA. Cada rutina puede editarse (modificar nombre, descripción o ejercicios incluidos), duplicarse para crear variantes, o eliminarse cuando ya no sea necesaria. Las rutinas se almacenan en la nube para usuarios registrados, de modo que están disponibles desde cualquier dispositivo donde inicien sesión.

### 7.5 Asistente de inteligencia artificial

Antes de acceder por primera vez al asistente, la aplicación muestra un aviso médico obligatorio que recuerda al usuario que FisioIA es una herramienta informativa y no sustituye a un profesional sanitario. El usuario debe aceptar este aviso para continuar.

*Figura 6. Aviso médico obligatorio antes del acceso al chat.*

Una vez en la pantalla del asistente, el usuario puede escribir mensajes en lenguaje natural describiendo su situación, su zona de molestia o el tipo de ejercicios que busca. El asistente interpreta el mensaje, ofrece una respuesta empática y, cuando detecta que el usuario busca ejercicios, genera automáticamente una tarjeta con una rutina sugerida que puede guardarse directamente o editarse antes de guardar.

*Figura 7. Conversación con el asistente y tarjeta de rutina sugerida.*

El historial de conversación se mantiene entre sesiones, de modo que al reabrir la aplicación el usuario puede retomar la conversación donde la dejó. Un botón de «Nuevo chat» permite reiniciar la conversación cuando se desee.

### 7.6 Perfil y cierre de sesión

En la sección de perfil, el usuario puede completar su información personal: nombre, edad, nivel de experiencia y zona articular principal. Esta información se almacena en *Firestore* y permite personalizar la experiencia en futuras versiones de la aplicación.

*Figura 8. Pantalla de perfil con campos editables.*

Desde la barra de navegación, el botón «Salir» muestra un diálogo de confirmación antes de cerrar la sesión. Tras el cierre, el usuario regresa a la pantalla de bienvenida inicial.

### 7.7 Recomendaciones de uso

Se recomienda utilizar FisioIA como apoyo complementario para rutinas suaves y de orientación general, no como sustituto de un tratamiento profesional. Antes de seguir cualquier rutina, el usuario debe asegurarse de que los ejercicios seleccionados son apropiados para su situación particular. Ante cualquier molestia significativa, dolor agudo o empeoramiento de los síntomas, la aplicación recomienda consultar con un profesional sanitario cualificado.

---

## 8. Conclusiones

### 8.1 Conclusiones técnicas

El desarrollo de FisioIA ha supuesto un proceso de aprendizaje intenso en un *framework* completamente nuevo. Partiendo de una base sólida en desarrollo Android con *Kotlin*, la transición a *Flutter* y *Dart* resultó más fluida de lo esperado en lo que respecta a la lógica de la aplicación, pero requirió un esfuerzo considerable en la comprensión del sistema de *widgets*, la gestión del estado y las particularidades de la programación declarativa de interfaces.

Una de las lecciones técnicas más valiosas ha sido comprender la importancia de diseñar la arquitectura antes de escribir código. La separación en capas (modelos, servicios y pantallas) no solo facilita el mantenimiento del código, sino que permite abordar cambios significativos —como la adición de un nuevo servicio o la modificación de un modelo de datos— sin necesidad de reescribir múltiples pantallas. Esta decisión, tomada al inicio del proyecto, ha ahorrado un tiempo considerable en las fases posteriores.

La integración de *Azure OpenAI* ha sido probablemente el aspecto más desafiante y a la vez más enriquecedor del proyecto. Diseñar un *system prompt* efectivo requiere un proceso iterativo de prueba y ajuste que va mucho más allá de simplemente conectar una API. La calidad de las respuestas depende directamente de la precisión con la que se define el comportamiento esperado, los límites de actuación y el contexto proporcionado al modelo. Aprender a manejar esta tecnología de forma responsable —con limitadores de uso, *fallbacks* y advertencias de seguridad— es una competencia que resultará relevante en el contexto profesional actual.

### 8.2 Conclusiones de planificación

La organización del trabajo en bloques cortos y funcionales ha resultado ser una estrategia eficaz para un proyecto individual. Frente a la alternativa de planificar todo el desarrollo de antemano y ejecutarlo de forma lineal, el enfoque iterativo adoptado —implementar una funcionalidad completa, probarla, ajustarla y pasar a la siguiente— ha permitido disponer de una versión funcional de la aplicación desde fases tempranas del proyecto, lo que facilita tanto las revisiones con la tutora como la motivación personal.

Sin embargo, la documentación es un aspecto que debería haberse abordado con más constancia desde el principio. Concentrar la redacción de la memoria en las últimas semanas genera una carga de trabajo elevada y dificulta reflejar con precisión las decisiones y los razonamientos que se tomaron meses antes. En futuros proyectos, mantener un registro detallado y redactado (no solo notas) desde la primera semana sería una mejora significativa.

Otra lección aprendida es la importancia de reservar tiempo suficiente para el pulido visual y las pruebas finales. Las funcionalidades pueden estar completas desde el punto de vista lógico, pero la coherencia visual, la consistencia de textos y la ausencia de errores en los flujos completos requieren un esfuerzo adicional que no debe subestimarse.

### 8.3 Líneas futuras

FisioIA se ha desarrollado como un producto mínimo viable funcional, pero existen múltiples líneas de mejora que podrían abordarse en desarrollos futuros:

Incorporación de contenido multimedia. Actualmente, los ejercicios se describen mediante texto. La adición de vídeos demostrativos o animaciones de los movimientos mejoraría significativamente la comprensión y la seguridad en la ejecución de los ejercicios.

Sistema de notificaciones y recordatorios. Integrar *Firebase Cloud Messaging* para enviar recordatorios periódicos al usuario ayudaría a mejorar la adherencia al programa de ejercicios, que es precisamente uno de los problemas que la aplicación pretende resolver.

Integración con dispositivos *wearable*. Conectar la aplicación con pulseras de actividad o relojes inteligentes permitiría registrar datos objetivos sobre la actividad física del usuario y personalizar las recomendaciones en función de su nivel de actividad real.

Modo *offline* completo. Aunque el catálogo ya funciona sin conexión, las rutinas del usuario podrían sincronizarse bidireccionalmente con un sistema de *cache* local más robusto, permitiendo crear y modificar rutinas sin conectividad y sincronizarlas cuando se recupere la conexión.

Personalización avanzada del asistente. Con los datos del perfil del usuario (zona principal, nivel de experiencia, objetivos), el *system prompt* podría adaptarse dinámicamente para ofrecer respuestas más relevantes desde el primer mensaje, sin necesidad de que el usuario explique su situación cada vez.

---

## 9. Bibliografía y webgrafía

### Documentación oficial de *frameworks* y plataformas

Flutter Team. (2024). *Flutter documentation*. Google. https://docs.flutter.dev/

Dart Team. (2024). *Dart programming language documentation*. Google. https://dart.dev/guides

Firebase. (2024). *Firebase documentation*. Google. https://firebase.google.com/docs

Firebase. (2024). *Cloud Firestore documentation*. Google. https://firebase.google.com/docs/firestore

Firebase. (2024). *Firebase Authentication documentation*. Google. https://firebase.google.com/docs/auth

Microsoft. (2024). *Azure OpenAI Service REST API reference*. Microsoft Learn. https://learn.microsoft.com/en-us/azure/ai-services/openai/reference

Microsoft. (2024). *Azure OpenAI Service documentation*. Microsoft Learn. https://learn.microsoft.com/en-us/azure/ai-services/openai/

### Paquetes y bibliotecas utilizadas

Pub.dev. (2024). *shared_preferences* — Flutter package. https://pub.dev/packages/shared_preferences

Pub.dev. (2024). *firebase_core* — Flutter package. https://pub.dev/packages/firebase_core

Pub.dev. (2024). *firebase_auth* — Flutter package. https://pub.dev/packages/firebase_auth

Pub.dev. (2024). *cloud_firestore* — Flutter package. https://pub.dev/packages/cloud_firestore

Pub.dev. (2024). *google_sign_in* — Flutter package. https://pub.dev/packages/google_sign_in

Pub.dev. (2024). *http* — Dart package. https://pub.dev/packages/http

### Diseño y experiencia de usuario

Google. (2024). *Material Design 3 — Design guidelines*. https://m3.material.io/

### Referencias sobre rehabilitación y adherencia

World Health Organization. (2022). *Musculoskeletal health*. WHO Fact Sheets. https://www.who.int/news-room/fact-sheets/detail/musculoskeletal-conditions

Jack, K., McLean, S. M., Moffett, J. K., & Gardiner, E. (2010). Barriers to treatment adherence in physiotherapy outpatient clinics: A systematic review. *Manual Therapy*, 15(3), 220–228. https://doi.org/10.1016/j.math.2009.12.004

### Herramientas de desarrollo

GitHub. (2024). *GitHub Copilot documentation*. https://docs.github.com/en/copilot

Microsoft. (2024). *Visual Studio Code documentation*. https://code.visualstudio.com/docs

---

*Documento generado como memoria del Proyecto Intermodular — CFGS Desarrollo de Aplicaciones Multiplataforma — Curso 2025–2026.*
