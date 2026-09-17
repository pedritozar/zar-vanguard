# ZAR VANGUARD CAPITAL PARTNERS — CHANGELOG
**Proyecto:** Fondo de Emergencia + Portafolio nuevo (Cocos Capital), plata real
**Estado:** Diseño cerrado, no generado todavía — arrancar Tanda 1 en chat nuevo dedicado a la
generación con el Reactor
**Archivos de esta sesión:** `RESEARCH_family_office_pensiones_seguros.md`,
`SPEC_zar_vanguard_capital_partners.md` (este changelog los resume, léanse ambos completos en el
chat nuevo antes de generar)

---

## Sesión 2026-09-14 — Diseño completo desde cero, sesión de scoping/spec (Cowork)

### Punto de partida
Pedro adjuntó carpetas de contexto (trading-desk, reactor IA, macro argentina, finanzas
personales, Mundo corpo, excels, simulator sandbox) para dar visión de su ecosistema antes de
armar un nuevo chat dedicado a Fondo de Emergencia + un portafolio nuevo, sin tocar ZAR Finance
ni la cartera Alfy que ya existen ahí.

### Decisiones cerradas
- **Fondo de Emergencia**: activa la meta ya existente en la hoja "Fondo Emergencia" de
  `FINANCE ZAR.xlsx` (medida en meses de gastos), en vez de empezar de cero.
- **Portafolio nuevo**: plata real, bróker **Cocos Capital** (cuenta todavía sin crear), perfil
  defensivo — mayoría renta fija en moneda dura, porción menor variable. Reusa la lógica de
  valuación de bonos ya construida en `Mundo corpo` (`bonos_tracker.html`, `renta_fija_tutor.html`,
  `valuacion_tutor.html`) en vez de que el Reactor la reinvente.
- **Infraestructura**: mismo Firebase/login de Google que ZAR Finance, patrón ya probado con ZAR
  Tactical Ledger — nodo nuevo, sin cargar plata dos veces. Esquema pensado multi-cliente desde el
  arranque (nodo por cliente) porque a futuro se suma la madre como segundo cliente con su propio
  fondo de emergencia — no construir eso ahora, solo dejar la estructura lista.
- **Nombre**: "ZAR Vanguard Capital Partners" — se descartó "ZAR Capital Asset Management" por
  colisión de namespace con ZAR Capital Management (el simulador de trading existente, plata
  ficticia).

### Research hecho en esta sesión (independiente del research de mesas de trading que Pedro ya
tenía en `RESEARCH_ideas_wallstreet.txt`)
Se comparon 3 ángulos — family office real (Willett Advisors de Bloomberg, gobernanza Creative
Planning, charter Family Office Exchange), J.P. Morgan Private Bank (los 4 lentes: Liquidez /
Estilo de vida / Legado / Crecimiento) y Yale Investments Office (gobierno + regla de gasto) —
contra el research de pensiones/seguros/family offices que ya estaba en la Tanda 3 del archivo de
mesas de trading. Detalle completo en `RESEARCH_family_office_pensiones_seguros.md`.

### Estructura de diseño (detalle completo en el SPEC)
1. **4 lentes de J.P. Morgan** como marco superior — Liquidez (Fondo de Emergencia) y Crecimiento
   (Portafolio) activos; Estilo de vida y Legado reservados para el futuro.
2. **Sub-buckets por contingencia** dentro del Fondo de Emergencia (patrón family office),
   cada uno con glide path "through" (matiz PIMCO sobre LDI de pensiones) disparado por % de meta
   alcanzado, no por fecha — nunca se aplana al 100%.
3. **Directorio de 5 cargos** (Chair, CIO, CFO, Risk Officer, Director de Oficina de Inversiones)
   — charter de 5 elementos (Family Office Exchange) + cadencia trimestral estilo Yale (staff
   propone, comité aprueba) + revisión ORSA simplificada en 4 preguntas.
4. **Regla de suavizado de aportes** — adaptación de la Yale Spending Rule (80/20) al problema real
   de Pedro (ingresos irregulares de trader/estudiante), no al gasto de una perpetuidad.
5. **Tutor educativo bajo demanda** — el directorio explica su función y toma examen, reusando el
   motor de `valuacion_tutor.html` (más maduro que `renta_fija_tutor.html`: backup/restore JSON,
   set de keywords de examen más rico). Se mantiene como archivo HTML separado, nunca mezclado con
   los tutores existentes — mismo criterio que Pedro ya documentó en `CHANGELOG_cmt_tutor.md` al
   decidir no fusionar Valuación con CMT (mezclar diluye el system prompt y el foco de ambos).
6. **Modo Revisión de Cartera** (agregado al final de la sesión, trimestral/bimestral, disparo
   manual) — el directorio comenta sobre datos REALES de composición/desempeño (no teoría),
   ciñéndose estrictamente a los números dados para evitar el problema de "falsa confianza" que
   Pedro ya señaló en el debate de Modo Auditor del Reactor. Incluye chat libre con el directorio
   sobre esos datos, y exporta como informe formal — doble propósito: preparación real para cuando
   la madre sea clienta, y ejercicio de aprendizaje de cómo armar un informe de cartera.

### Pendiente para el chat de generación
- [ ] Destino de deploy: ¿mismo repo de GitHub Pages que ZAR Finance, o uno nuevo?
- [ ] Confirmado: **4 Tandas** con el Reactor, mismo patrón que Economías Globales:
      Tanda 1 = Fondo de Emergencia + buckets + meta activada (sin directorio, sin glide path,
      sin portafolio). Tanda 2 = Portafolio nuevo (Cocos Capital) + lógica de valuación de renta
      fija. Tanda 3 = glide path + regla de suavizado de aportes. Tanda 4 = directorio (tutor +
      modo revisión de cartera), archivo HTML aparte.
- [ ] QC de cada tanda: diff byte a byte contra la anterior, `node --check`, balance de tags —
      mismo estándar que Economías Globales (ver `2026-09-08_auditoria_dashboard_economias_globales.txt`).

---

*Sesión cerrada 2026-09-14 — Cowork (Claude Sonnet 5), a pedido de Pedro para poder abrir un chat
nuevo dedicado a la generación sin perder el diseño acordado acá.*

---

## Sesión 2026-09-15 — Generación (Tanda 1 + 2), deploy, y Tanda 3 en curso (Cowork)

### Estado actualizado
Ya NO es "diseño cerrado, no generado todavía" — Tanda 1 y Tanda 2 están generadas,
QC'd y deployadas. Tanda 3 en generación en este momento.

### Tanda 1 — Fondo de Emergencia (CERRADA)
Generada por el Reactor, QC en Cowork (node --check, tags balanceados, estructura
Firebase y seed de buckets exactos). Único desvío: paleta de colores inventada en
vez de copiada — corregido por Cowork (paleta clara real de ZAR Finance + paleta
oscura automática vía `prefers-color-scheme`). SDK Firebase compat confirmado, API
key hardcodeada. Auditoría completa en
`reactor IA/2026-09-15_auditoria_zar_vanguard_tanda1_fondo_emergencia.txt`.

### Tanda 2 — Portafolio Cocos Capital (CERRADA)
Generada por el Reactor (2do intento, 60.000 tokens de salida — el primero con
25.000 truncó). QC en Cowork: cero desvíos de lógica (motor de valuación de renta
fija y extracción por visión, copias fieles del código literal pegado en el
prompt), diff byte a byte confirma Fondo de Emergencia intacto. Dos desvíos
cosméticos de texto corregidos. Auditoría completa en
`reactor IA/2026-09-15_auditoria_zar_vanguard_tanda2_portafolio_cocos.txt`.

### Deploy (CERRADO)
Repo nuevo dedicado `pedritozar/zar-vanguard` en GitHub Pages (no el mismo repo
que ZAR Finance ni trading-desk). `.gitignore` con protección de capturas de
Cocos Capital y secretos. Push hecho por Pedro desde su Terminal. Los archivos de
diseño (`SPEC`, este `CHANGELOG`, los `PROMPT_tanda*.md`) quedan LOCALES, fuera
del repo — decisión de Cowork por default (reducir superficie pública a solo la
app), no confirmada explícitamente con Pedro todavía — ver nota abajo.

### Tanda 3 — Glide path + suavizado de aportes + Chart.js (EN CURSO)
`PROMPT_tanda3_glide_path_suavizado.md` armado con: glide path por bucket
(umbrales 40%/75%, sin aplanar al 100%), regla de suavizado de aportes (adaptación
Yale 80/20 — tasa objetivo 10%, banda 10%-15%, ventana de 3 meses, ingreso leído
en vivo del nodo `ingresos` de ZAR Finance, reparto proporcional a metas de
bucket), y 3 charts con Chart.js (gauge de bucket por fase, composición del
Portafolio, vista TIR/duración) — este último punto se agregó porque el spec ya
lo pedía (sección de Visualización) y ninguna tanda anterior lo había construido.
Decisión de scope: el ingreso mensual entra solo como insumo numérico de la regla
de suavizado, nunca como tema de opinión del futuro directorio (Tanda 4) — se
mantiene la separación de disciplinas ya establecida para los tutores.

### Pendiente / nota abierta
- Confirmar con Pedro si los docs de diseño (SPEC/CHANGELOG/PROMPTs) deberían
  subirse también al repo `zar-vanguard` o quedarse locales como están ahora.

*Agregado por Claude Sonnet 5 — 2026-09-15, a pedido de Pedro (revisión de carpeta
mientras corría la generación de Tanda 3).*

---

## Sesión 2026-09-15 (noche) — Tanda 3 cerrada + deploy final, diseño de Tanda 4a (Cowork + DeepSeek)

### Nota abierta anterior: RESUELTA
Los docs de diseño (SPEC/CHANGELOG/PROMPTs) quedan LOCALES, fuera del repo
público — decisión confirmada explícitamente por Pedro ("mejor dejamos, mas
ordenado"). No tienen función en la app deployada y contienen detalle
financiero personal.

### Tanda 3 — Glide path + suavizado de aportes + Chart.js (CERRADA)
Generada por el Reactor con 60.000 tokens (sin truncar). QC en Cowork: mejor
resultado de las tres tandas — cero desvíos de lógica (`faseGlidePath`,
constantes de suavizado, los 3 charts de Chart.js reusando la paleta
existente sin inventar colores nuevos). Único desvío: footer-note de Fondo de
Emergencia con texto de alcance desactualizado — corregido por Cowork. Commit
local + push de Pedro completados. Auditoría completa en
`reactor IA/2026-09-15_auditoria_zar_vanguard_tanda3_glide_path_suavizado.txt`.

### Deploy — Tanda 1+2+3 en producción (CERRADO)
`pedritozar/zar-vanguard` en GitHub Pages, con Tanda 1, 2 y 3 pusheadas y en
vivo.

### DeepSeek sumado como segunda revisión (para Tanda 4)
Se armó `INSTRUCCIONES_chat_deepseek_zar_vanguard.md` para un chat nuevo
dedicado a revisar DISEÑO/CRITERIO de los system prompts del directorio (no
sintaxis de código, ya cubierta por el QC de Cowork) — con la advertencia
explícita de no confiar ciegamente en hechos técnicos puntuales de DeepSeek
(precedente: nombres de modelo desactualizados en una revisión anterior).

### Tanda 4 partida en 4a / 4b
Mismo criterio que Economías Globales para evitar el riesgo de truncamiento:
4a = esqueleto del tutor (selector de 5 cargos, motor de chat BYOK, los 5
system prompts, tag `[[NEXT_MODEL:x]]` unificado, backup/restore, export a
markdown). 4b = Modo Revisión de Cartera (datos reales de Firebase,
comentario ceñido a esos números, ORSA real) — queda para después de cerrar
4a.

### PROMPT_tanda4a_directorio_tutor.md — 3 rondas de revisión de DeepSeek, todas cerradas
1. **Primera ronda**: riesgo de scope desparejo entre cargos (Director de
   Oficina en mayor riesgo por depender del ingreso), falta el export a
   markdown que pedía el spec (se agregó, literal de `valuacion_tutor.html`),
   y excedente de bucket sin definir (Pedro decidió: se queda como colchón
   acumulando interés en el mismo bucket).
2. **Segunda ronda**: (a) hueco en la aclaración del Director — no impedía
   evaluar "previsibilidad/estabilidad" del ingreso, cerrado con una frase
   explícita; (b) CFO y Risk Officer sin aclaración propia — se agregó
   "LÍMITE ESPECÍFICO" a cada uno (CFO no gira "meses de cobertura" hacia el
   ingreso; Risk Officer no corre el ORSA real en modo educativo, eso es
   exclusivo de 4b); (c) el Chair citaba un charter que no existía por
   escrito — se creó `CHARTER_zar_vanguard_directorio.md` (patrón FOX de 5
   elementos) y el Chair ahora lo cita textual; (d) dualidad "staff propone /
   comité aprueba" resuelta con la lógica ya existente del spec (separación
   de sombreros dentro de la misma persona, no aprobación circular),
   redactada en el system prompt del Chair y en la sección Reuniones del
   charter.
3. **Tercera ronda**: reencuadre pedagógico del directorio (analogía
   simulador de vuelo — el "juego" es el diseño correcto para practicar sin
   que el costo de un error sea plata real) — evaluado y aceptado, con una
   nota para cuando se escriba el prompt de 4b (pesar interpretación/
   comunicación por sobre corrección técnica). Riesgo nuevo identificado:
   "falsa confianza conceptual" — un cargo puede explicar mal un concepto con
   tono seguro sin ancla de datos reales que lo contraste, y Pedro lo
   internaliza como verdad. Mitigación aplicada: párrafo "FUENTES REALES" en
   el bloque común de los 5 system prompts (nombra las instituciones reales
   que inspiran el diseño — Willett, Creative Planning, FOX, JPM, Yale — y
   exige decir explícitamente cuando no se está seguro de un dato puntual, en
   vez de inventarlo).

### Aclaración de diseño adicional (fuera de las rondas de DeepSeek)
$3.600.000 es el PISO del Fondo de Emergencia, no un techo — con interés
compuesto y aportes el monto puede seguir escalando. El directorio de 5
cargos no está dimensionado para ese número estático, es infraestructura
pensada para un fondo que va a crecer en tamaño y complejidad — refuerza el
reencuadre pedagógico de la tercera ronda. No requirió cambios de código: el
glide path ya trabaja por % de meta alcanzada, no por peso absoluto.

### Estado al cierre de la sesión
`PROMPT_tanda4a_directorio_tutor.md` y `CHARTER_zar_vanguard_directorio.md`
en su versión final, entregados y guardados en esta carpeta. Listos para
generar en el Reactor (60.000 tokens de salida, pegar el prompt junto con el
charter, no hace falta `index.html`). Pendiente: retomar mañana — confirmar
si queda alguna duda entre Pedro y DeepSeek sobre las 3 rondas antes de
generar, o generar directo.

*Agregado por Claude Sonnet 5 — 2026-09-15 (noche), a pedido de Pedro (revisión
antes de dormir).*

## 2026-09-16 — Tanda 4a generada, auditada y cerrada

Retomando lo del cierre de la sesión anterior: DeepSeek hizo una 3ra ronda
sobre `PROMPT_tanda4a_directorio_tutor.md` con 5 puntos sin resolver
(charter en runtime ambiguo, "compliance" sin corregir en el CFO, FUENTES
REALES débil, MODO EXAMEN sin cláusula anti-evasiva, charter solo para el
Chair). Cowork aplicó las 5 correcciones sobre el prompt (9 ediciones) con
los matices que aportó DeepSeek en su respuesta de coordinación.

Generado en el Reactor (Sonnet 5, 60.000 tokens) →
`directorio_zar_vanguard.html`. QC de Cowork encontró un desvío: la paleta
volvió a estar invertida/inventada (mismo patrón que Tanda 1) — corregido
copiando los valores reales de `index.html`. DeepSeek auditó los 5 puntos
de contenido (todos confirmados correctos) y encontró 2 desvíos de paleta
adicionales que la primera corrección de Cowork no cubría: fuentes
(faltaba cargar DM Sans/DM Mono) y la clase `.card` reescrita en vez de
reusar el patrón real de `.bucket-card`. Corregidos por Cowork, junto con
2 ajustes cosméticos de redacción que sugirió DeepSeek (FUENTES REALES y
MODO EXAMEN).

Auditoría detallada en
`reactor IA/2026-09-16_auditoria_zar_vanguard_tanda4a_directorio.txt`.

**Tanda 4a queda completamente cerrada.** Siguiente paso: Tanda 4b (Modo
Revisión de Cartera) — queda para otra sesión, a coordinar con Pedro.

*Agregado por Claude Sonnet 5 — 2026-09-16, a pedido de Pedro.*

## 2026-09-16 (cont.) — Verificación post-cierre de 4a + "piso, no techo" + prompt de 4b

DeepSeek reabrió dos dudas antes de dar 4a por cerrada de verdad: (1) si el desvío de paleta
(`--blue` con contraste roto en modo claro) seguía pendiente, y (2) si los 4 lugares donde se
había hablado de aplicar "piso, no techo" ($3.600.000 como mínimo, no como meta final) ya
estaban hechos. Cowork verificó directo sobre el código real, sin asumir el estado por el
CHANGELOG:

- **Paleta**: confirmado que ya estaba bien — `--blue:#0066FF` en modo claro (valor real de
  `index.html`), `--blue:#58a6ff` solo existe dentro del `@media (prefers-color-scheme: dark)`,
  nunca se aplica en claro. Fuentes DM Sans/DM Mono cargadas. `.card` reusa los mismos tokens
  (`--white`, `--border`, `--r`, `--sh`) que `.bucket-card`. Los 3 desvíos de la ronda anterior
  quedan confirmados corregidos — **4a cierra sin pendientes**.
- **"Piso, no techo"**: de los 4 lugares, solo el CHANGELOG lo tenía. Se agregó ahora: párrafo en
  `SPEC_zar_vanguard_capital_partners.md` sección 2 (después del glide path), párrafo en
  `CHARTER_zar_vanguard_directorio.md` sección "Propósito", y el mensaje de `res-nota` en
  `index.html` (antes "🏆 Meta del Fondo de Emergencia cubierta.", ahora aclara que es un piso
  y que el excedente sigue sumando como colchón). `node --check` sobre el JS inline de
  `index.html`: OK.
- **Endurecimiento del Director para 4b**: DeepSeek señaló que en el Modo Revisión de Cartera el
  Director SÍ necesita ver un número derivado del ingreso (el aporte sugerido de la regla de
  suavizado, que es su responsabilidad central) — a diferencia de los otros 4 cargos, que no ven
  nada de ingresos. `PROMPT_tanda4b_modo_revision_cartera.md` actualizado: nuevo bloque
  `RESUMEN_DIRECTOR_TEXTO` (solo para ese cargo, con `sugeridoTotal`/`porBucket` derivados —
  `ingresoProm` en sí NUNCA sale de JavaScript hacia la API) y un párrafo de endurecimiento
  específico en su system prompt (prohíbe calificar el monto como "bajo/alto" respecto de lo que
  Pedro "debería" ganar, sacar conclusiones de desempeño, o especular sobre ingreso futuro — se
  limita a si el aporte real está en línea con lo sugerido y a la mecánica de la regla).

Pendiente: terminar la ronda de DeepSeek sobre `PROMPT_tanda4b_modo_revision_cartera.md` (los 5
puntos de diseño ya planteados) antes de generar en el Reactor.

*Agregado por Claude Sonnet 5 — 2026-09-16, a pedido de Pedro.*

## 2026-09-16 (cont. 2) — Segunda ronda de DeepSeek sobre PROMPT_tanda4b: 4 gaps técnicos + 1 hueco de diseño

DeepSeek revisó `PROMPT_tanda4b_modo_revision_cartera.md` completo y marcó 7 puntos (3 altos, 1
medio, 3 menores). Los 7 se corrigieron directo sobre el prompt, sin dejar nada para una tercera
ronda salvo la lectura final de DeepSeek sobre el resultado:

1. **Alto — el Director podía inferir el ingreso de Pedro** a partir del aporte sugerido + la
   fórmula completa en su propio system prompt (despeje de una incógnita, trivial para un LLM).
   La prohibición existente cubría "calificar"/"sacar conclusiones"/"especular sobre futuro" pero
   no "inferir y mencionar el número actual". Agregada cláusula (d) explícita en el párrafo de
   endurecimiento del Director + ítem de QC dedicado.
2. **Alto — faltaban los 3 `<script>` de Firebase compat** en la sección 1 (el prompt copiaba
   `FB_CFG` pero nunca decía que había que cargar la SDK). Agregados literales, v10.7.1, misma
   versión que `index.html`.
3. **Alto — `calcularAporteSugerido()` depende de `ingresoPromedioReciente()` y
   `aporteMesAnterior()`**, ninguna de las dos mencionada en el prompt original (mismo patrón que
   el desvío de paleta de Tanda 1: función con dependencias no resueltas → el Reactor improvisa
   un stub). Las tres pegadas literales, con instrucción de poblar `APORTES_LIVE`/`BUCKETS_LIVE`
   vía `.once('value')` antes de llamarlas (en `revisionView` no hay listeners en vivo). Nota
   agregada: si `ingresoPromedioReciente()` no puede leer `ingresos/{uid}/...` por reglas de
   Firebase, el Director se queda sin sugerencia — riesgo que ya venía de Tanda 3, ahora más
   crítico.
4. **Medio — `calcularValuacionRentaFija()` ambigua**: el prompt decía "calcular TIR/duración
   SOLO si ya existe la función en el proyecto" pero también decía "no hace falta pegar
   `index.html` completo", así que el Reactor nunca la iba a tener en contexto y default a campos
   crudos. Resuelto pegándola literal (mismo criterio que ya funcionó sin desvíos en Tanda 2) —
   el resumen de renta fija ahora sí muestra TIR/duración real.
5. **Menor** — "5 llamadas secuenciales o en paralelo, a elección del Reactor" → pinchado
   explícito a secuencial (evita condiciones de carrera, más fácil de debuggear si una falla).
6. **Menor** — "agregar el ORSA" era ambiguo entre mencionarlo y correrlo → explicitado que el
   Risk Officer debe RESPONDER las 4 preguntas aplicadas al resumen real, no enumerarlas en
   abstracto.
7. **Cosmético** — el timestamp del resumen pasa al encabezado del informe exportado (no solo
   mencionado en el cuerpo), y se agregó a "Qué NO hacer" que el Reactor no debe agregar
   `localStorage` para persistir la sesión de revisión (es intencional que se pierda si se cierra
   la pestaña — el mecanismo de persistencia es el export, no el navegador).

`PROMPT_tanda4b_modo_revision_cartera.md` queda en su versión con estas 7 correcciones. Pendiente:
que DeepSeek confirme que los gaps quedaron cerrados antes de disparar el Reactor.

*Agregado por Claude Sonnet 5 — 2026-09-16, a pedido de Pedro.*

## 2026-09-16 (cont. 3) — Cierre de dependencias completo en PROMPT_tanda4b (respuesta al patrón de "huecos nuevos cada ronda")

Tercera ronda de DeepSeek sobre `PROMPT_tanda4b_modo_revision_cartera.md`: al integrar las 4
correcciones grandes de la ronda anterior, el prompt abrió 3 huecos nuevos + 3 menores. Patrón
identificado (no es ruido ni alucinación de DeepSeek): pegar código literal para cerrar un hueco
introduce nuevas dependencias (una función que llama a otra función) que no estaban en el radar
hasta que se pegó la primera. Cada ronda venía cerrando un hueco a la vez en vez de auditar el
árbol de dependencias completo.

Esta vez, en lugar de aplicar solo los 2 puntos que DeepSeek marcó como bloqueantes (su propia
auto-crítica: de 6 hallazgos, solo 2-3 eran de alto valor, el resto era ruido de "modo encontrar
problemas" después de varias rondas), Cowork hizo una pasada de cierre de TODAS las dependencias
sueltas de una vez:

- `valorMercadoHolding()` (index.html) pegada literal — sin ella no había valor total del
  Portafolio ni composición RF/variable.
- `let db = null, auth = null;` declarado (initFirebaseWithRetry los asigna, nadie los declaraba).
- `fmt()` (formato de moneda ARS) pegada literal — encontrada en la misma auditoría, no estaba en
  la lista de DeepSeek.
- Formato de ejemplo agregado para `RESUMEN_CARTERA_TEXTO` (antes decía "texto plano" sin más).
- Risk Officer: instrucción explícita de decir "no tengo revisión anterior" en la pregunta 2 del
  ORSA, en vez de inventar "no hubo cambios".
- Informe exportado: cargos con llamada fallida se listan como "— no generado", no se omiten.
- `await` explícito antes de usar el resultado de `calcularAporteSugerido()` (es `async`).

Checklist de QC ampliado con 6 ítems nuevos correspondientes. Objetivo: que la próxima lectura de
DeepSeek sea la última antes de generar — si aparece un cuarto hueco, va a ser sobre algo
genuinamente nuevo, no sobre otra dependencia de lo ya pegado.

*Agregado por Claude Sonnet 5 — 2026-09-16, a pedido de Pedro.*

## 2026-09-16 (cont. 4) — DeepSeek cierra la revisión de PROMPT_tanda4b

DeepSeek confirmó los 5 cierres de la pasada anterior (valorMercadoHolding, db/auth, fmt(),
formato de ejemplo, ORSA pregunta 2, cargos fallidos) y marcó un último punto sin abrir ronda
nueva: `fmt()` usa siempre `$`, y el resumen tiene holdings en USD — riesgo de que un informe
exportado muestre "$950" sobre un bono en dólares.

Verificado contra `index.html` real: NO es un desvío a corregir, es el mismo criterio que el
dashboard ya usa en producción — `renderHoldingCard()` llama `fmt(valor)` con `$` para cualquier
holding sin importar su moneda, y lo que desambigua es el tag `(moneda)` pegado al nombre, nunca
el símbolo. Se aclaró esto en la sección 3 del prompt para que el Reactor no "corrija" algo que
ya es el comportamiento real del proyecto.

**`PROMPT_tanda4b_modo_revision_cartera.md` queda cerrado.** DeepSeek dio el visto bueno sin
condicionarlo a una vuelta más. Checklist de QC en 23 ítems. Siguiente paso: pegar el prompt en
el Reactor (60.000 tokens de salida) y hacer el QC de siempre sobre el resultado.

*Agregado por Claude Sonnet 5 — 2026-09-16, a pedido de Pedro.*

## 2026-09-16 (cont. 5) — Lección metodológica consolidada: revisión Claude+DeepSeek pre-generación

Resumen de las 3 rondas de revisión de `PROMPT_tanda4b_modo_revision_cartera.md` (secciones
anteriores de este CHANGELOG), para tenerlo a mano antes de armar el prompt de Tanda 5 o
cualquier prompt futuro con código literal pegado:

**El patrón que se repitió 2 veces — "cierre de árbol por capas":** pegar código literal para
cerrar un desvío (ej. `calcularValuacionRentaFija`) introduce dependencias propias de esa función
(`valorMercadoHolding`, `db`/`auth`, `fmt()`) que no estaban en el radar hasta pegar la primera.
Corregir una dependencia a la vez, ronda tras ronda, no tiene piso — cada capa destapa la
siguiente. La salida que funcionó fue parar de parchear reactivamente y hacer UNA pasada de
auditoría completa: listar todo lo que el prompt nombra (funciones, variables, constantes) y
verificar, para cada una, si ya existe en el archivo base o si hace falta pegarla — todo de una
vez, no de a una por ronda. Para prompts futuros con código pegado: hacer esa auditoría de
dependencias ANTES de la primera ronda con DeepSeek, no después de que la encuentre.

**Rol de DeepSeek en este proyecto, confirmado por su propio criterio:** DeepSeek revisa diseño/
criterio (scope de los system prompts, coherencia con el charter, riesgos de "falsa confianza"),
nunca sintaxis — eso ya lo cubre el QC de Cowork. Cuando DeepSeek se autocorrigió ("subestimé
`db`/`auth` y `fmt()` como menores, no lo eran"), el criterio para diferenciar ruido de hallazgo
real terminó siendo: ¿esto impide que el código corra o produzca el output esperado, o es
preferencia de estilo? Los "menores" que sí importaban eran los que rompían ejecución
(`ReferenceError`, formato roto antes de que el Director viera algo); los que sí eran ruido
(nombrado por el propio DeepSeek) eran ajustes que el QC post-generación iba a pescar solo.

**Convención confirmada, no un bug:** cuando el diseño nuevo parece inconsistente con el código
real (ej. `fmt()` mostrando `$` sobre holdings en USD), chequear el código YA EN PRODUCCIÓN antes
de asumir que hay que corregir algo — en este caso `index.html` ya hace exactamente eso
(`renderHoldingCard` usa `fmt()` para toda moneda y desambigua con el tag `(moneda)` al lado del
nombre), así que "corregirlo" en el prompt nuevo habría sido inconsistente con el dashboard que
Pedro ya usa a diario.

Nota de desempeño equivalente (para el historial cruzado entre proyectos) agregada en
`reactor IA/CHANGELOG_reactor.md`.

*Agregado por Claude Sonnet 5 — 2026-09-16, a pedido de Pedro.*

## 2026-09-17 — Tanda 4b generada y QC técnico de Cowork: limpio

Generada en el Reactor (Sonnet 5, 60.000 tokens, sin truncar). QC técnico completo de Cowork
sobre `directorio_zar_vanguard.html` (801 → 1509 líneas): **cero desvíos** — la generación más
limpia del proyecto hasta ahora. Detalle completo en
`reactor IA/2026-09-17_auditoria_zar_vanguard_tanda4b_revision_cartera.txt`.

Resumen: `node --check` OK; diff línea a línea confirma Tanda 4a intacta al 100% (selector, chat
tutor, export, backup/restore); paleta agregó `--amber` con los valores REALES de `index.html`
(necesario para `faseGlidePath`, no existía en la paleta de 4a); las 7 funciones pegadas
literales en el prompt (`initFirebaseWithRetry`, `faseGlidePath`, `valorMercadoHolding`,
`calcularValuacionRentaFija`, `ingresoPromedioReciente`, `aporteMesAnterior`,
`calcularAporteSugerido`, `fmt`) se reprodujeron exactas; el endurecimiento del Director (las 4
prohibiciones, incluida la anti-inferencia) está completo y `RESUMEN_DIRECTOR_TEXTO` nunca
serializa `ingresoProm`; el Risk Officer responde el ORSA contra datos reales y declara
explícitamente no tener revisión anterior en la pregunta 2; las 5 llamadas de comentarios son
secuenciales con manejo de fallos parciales; cero `localStorage` nuevo; cero Chart.js agregado;
export de informe con encabezado fecha+hora y tablas de composición.

**Extensión no pedida pero bien resuelta:** el Reactor agregó `aporteMesAnteriorBucket(bucketId)`
para desglosar el aporte real por bucket (necesario para comparar contra el sugerido por bucket,
tal como pedía el prompt) en vez de forzar una función pegada a hacer algo que no hacía — señal
de que entendió el propósito, no solo copió literal.

Archivo guardado en `directorio_zar_vanguard.html`, commit local hecho (sin push). Pendiente:
lectura de diseño/criterio de DeepSeek (varios puntos de su checklist ya verificados acá y
correctos: anti-inferencia del Director, ORSA pregunta 2, scoping de `RESUMEN_DIRECTOR_TEXTO`).

**Tanda 4b queda técnicamente cerrada.** Con esto, el proyecto ZAR Vanguard Capital Partners
tiene las 4 tandas completas (Fondo de Emergencia, Portafolio, glide path/suavizado, directorio
completo con tutor + revisión de cartera). Falta: push de Tanda 3 y Tanda 4b, y el visto bueno
final de DeepSeek.

*Agregado por Claude Sonnet 5 — 2026-09-17, a pedido de Pedro.*

## 2026-09-17 — Tanda 4b, ronda de fix post-auditoría de diseño de DeepSeek

DeepSeek hizo la auditoría de diseño/criterio post-generación sobre el código ya generado
(coordinación pactada en `INSTRUCCIONES_chat_deepseek_tanda4b.md`). De sus 5 puntos, 3 salieron
limpios (fuga de scope hacia ingresos, consistencia con el charter, formato del informe
exportado). Los otros 2 se verificaron por lectura directa del código — no por confianza en el
reporte — y ambos resultaron reales:

**1. Contradicción real en el system prompt del Risk Officer (el hallazgo más importante de la
ronda).** `buildSystemPromptRevision(cargo)` arma el prompt de Modo Revisión de Cartera pegando
`cargo.specific` literal (línea `TU ROL ESPECÍFICO... ${cargo.specific}`), que para el Risk
Officer es `RISK_SPECIFIC` — el mismo bloque de Tanda 4a, sin tocar. Ese bloque dice
explícitamente: *"en ESTE modo (educativo, Tanda 4a) [...] NUNCA lo corrés de verdad [...] Si
Pedro te dice 'corré la revisión ahora' [...] aclarale que acá es solo teoría y que la revisión
real está en la otra pantalla."* El problema: "la otra pantalla" que ese texto describe ES este
mismo modo (4b). Un párrafo más abajo, el propio `buildSystemPromptRevision` agrega: *"SOS EL
RISK OFFICER EN MODO REVISIÓN REAL: acá SÍ corrés el ORSA simplificado en serio"* — instrucción
directamente opuesta, en el mismo system prompt. Fix aplicado (sin tocar `RISK_SPECIFIC`, que
sigue siendo correcto tal cual para 4a): se agregó un párrafo "OVERRIDE EXPLÍCITO" al inicio del
bloque `if(cargo.id === 'risk')`, que nombra la frase puntual a ignorar y aclara por qué no
aplica en esta sesión.

**2. Falta el párrafo "FUENTES REALES" en el header de 4b (gap menor, confirmado).** Ese párrafo
(anti-atribución-inventada a instituciones reales — Willett Advisors, Yale, JPM, etc.) vive en
`COMMON_PROMPT_BLOCK`, que es exclusivo de Tanda 4a. `buildSystemPromptRevision` no lo hereda ni
tiene uno propio. DeepSeek señaló correctamente que el riesgo es mayor en 4b, no menor: con datos
reales de Pedro delante, un cargo sonando seguro sobre una cifra inventada de una institución es
más creíble que en una charla puramente conceptual. Fix aplicado: versión adaptada del párrafo,
agregada al header común de `buildSystemPromptRevision` (aplica a los 5 cargos).

Verificación técnica de ambos fixes: `node --check` limpio; diff línea a línea contra la versión
ya auditada (2026-09-17, entrada anterior) confirma que los únicos cambios son los dos párrafos
agregados — cero regresión sobre lo ya verificado. Archivo actualizado en
`directorio_zar_vanguard.html`, commit local hecho (sin push, commit `301b2c7`).

**Método confirmado una vez más:** ninguno de los dos hallazgos se aceptó por el reporte de
DeepSeek solo — se confirmaron leyendo `buildSystemPromptRevision` y `RISK_SPECIFIC` línea por
línea antes de tocar código. La diferencia entre esta clase de bug y los de rondas anteriores
(dependencias faltantes): acá el código es sintácticamente válido y ambos bloques de texto
"existen" — el problema es semántico/de contenido (dos instrucciones que se contradicen dentro
del mismo prompt), no algo que un `node --check` o un diff de dependencias detecte por sí solo.
Este tipo de contradicción solo aparece auditando el *contenido* del prompt ya ensamblado, no sus
piezas por separado — vale la pena, en prompts futuros que reutilicen bloques `specific` entre
modos con reglas opuestas, armar el prompt final completo y leerlo de corrido antes de darlo por
cerrado, no solo revisar cada bloque nuevo en aislamiento.

**Con esto, Tanda 4b queda cerrada** (pendiente solo el visto bueno final de DeepSeek sobre este
fix puntual, y el push manual de Pedro).

*Agregado por Claude Sonnet 5 — 2026-09-17, a pedido de Pedro.*

## Evaluación de desempeño de DeepSeek — auditoría de diseño Tanda 4b — 2026-09-17

Resumen corto (detalle completo en `reactor IA/CHANGELOG_reactor.md`): de los 5 puntos de la
auditoría de diseño post-generación, DeepSeek entregó 2 hallazgos reales y precisos (la
contradicción del Risk Officer, correctamente marcada como "el hallazgo más importante de la
ronda"; el gap de FUENTES REALES, correctamente marcado como menor) y 3 puntos limpios sin
inflar la ronda. El hallazgo del Risk Officer en particular es una clase de bug que el QC
técnico de Cowork no puede atrapar por diseño (dos bloques de texto sintácticamente válidos que
se contradicen solo cuando se leen juntos) — buena evidencia de que la división de trabajo entre
Cowork (técnico) y DeepSeek (diseño/criterio) sigue funcionando como se pensó.

*Agregado por Claude Sonnet 5 — 2026-09-17, a pedido de Pedro.*
