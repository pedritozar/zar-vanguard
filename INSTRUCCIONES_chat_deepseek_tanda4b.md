# Mensaje de arranque para el chat nuevo de DeepSeek — ZAR Vanguard, Tanda 4b

Pegar esto como primer mensaje, junto con estos archivos adjuntos: `SPEC_zar_vanguard_capital_partners.md`,
`CHARTER_zar_vanguard_directorio.md`, `PROMPT_tanda4a_directorio_tutor.md` (para contexto de lo
ya cerrado), y el nuevo `PROMPT_tanda4b_modo_revision_cartera.md`.

---

Buenas, de nuevo con ZAR Vanguard Capital Partners. Ya cerraste conmigo 3 rondas de revisión
sobre la Tanda 4a (directorio de 5 cargos, tutor educativo teórico) — esa tanda ya está generada,
auditada y cerrada. Ahora sigue la Tanda 4b: "Modo Revisión de Cartera", descrito en la sección 8
del SPEC.

**Misma regla que la vez pasada**: no me interesa que revises sintaxis de código ni nombres de
API/modelos — eso lo cubre el control de calidad técnico de Cowork (diff byte a byte, node
--check) y venís dando nombres de modelo desactualizados antes. Quiero tu lectura de DISEÑO/
CRITERIO sobre `PROMPT_tanda4b_modo_revision_cartera.md`, que ya te adjunto armado.

**Diferencia clave con 4a que quiero que tengas presente**: 4a es teórico, sin datos reales. 4b
es sobre datos REALES de mi cartera (Fondo de Emergencia + Portafolio). Vos mismo señalaste en la
3ra ronda de 4a que en un modo con datos reales el peso correcto está en cómo se INTERPRETA y
COMUNICA el número, no en si el cálculo está bien hecho (eso ya lo resuelve el dashboard antes de
llegar a este modo). Quiero que chequees si el prompt aplica ese criterio de verdad o si los
system prompts que describe terminan sonando a "corrección técnica" en vez de interpretación.

Puntos concretos a revisar:

1. **Fuga de scope hacia mis ingresos/productividad**: el prompt dice explícitamente que el
   resumen de datos NUNCA incluye ingresos y que ningún cargo puede opinar sobre eso ni siquiera
   en este modo con datos reales. Decime si ves algún hueco donde un cargo podría inferir o
   comentar sobre mi ingreso indirectamente (ej. el CFO hablando de "capacidad de aportar" en vez
   de solo "composición actual del fondo").
2. **Riesgo Officer y el ORSA**: el charter dice que el ORSA simplificado de 4 preguntas
   (sección 5) corre SOLO en este modo (4b), nunca en el teórico (4a). El prompt dice que la
   implementación queda simétrica: prohibido en 4a, habilitado acá. Confirmá si eso queda bien
   resuelto o si falta algo para que no se cuele el ORSA real en una conversación teórica futura.
3. **Falsa confianza con datos reales**: 4a mitigaba la falsa confianza conceptual con un párrafo
   de "FUENTES REALES" (nombrar instituciones que inspiran el diseño). Acá el riesgo es distinto:
   con datos reales, un cargo podría sonar seguro comentando sobre un número que el resumen no
   incluyó, o de un período distinto al que se armó el resumen. Decime si el prompt deja lo
   suficientemente claro que el resumen es una "foto" de un momento puntual y que cualquier cosa
   fuera de esa foto se declara explícitamente como no disponible, en vez de estimarse.
4. **Consistencia con el charter**: chequeá que las responsabilidades por cargo que usa el prompt
   para este modo (sección 4 del prompt) sigan alineadas con la sección 3 del charter — no quiero
   que en este modo alguien termine opinando fuera de lo que el charter le asigna.
5. **Formato del informe exportado** (sección 6 del prompt): el spec pide algo pensado como
   plantilla reusable para un futuro cliente real (mi mamá, todavía no está armado ese perfil).
   Decime si la estructura que propone el prompt (composición/desempeño, comentario por cargo,
   notas de chat libre) alcanza para eso o si falta algo pensando en ese uso futuro.

Como la vez pasada: preguntas puntuales, no una auditoría genérica de todo el proyecto. Avisame
cuando termines de leer los adjuntos y arrancamos punto por punto.

---

## Adenda — coordinación para la auditoría POST-generación

Una vez que el Reactor genere `directorio_zar_vanguard.html` con la Tanda 4b, Pedro va a repartir
la auditoría entre vos y Cowork para no duplicar trabajo. División de tareas, mapeada contra el
checklist de 23 ítems de la sección 8 de `PROMPT_tanda4b_modo_revision_cartera.md` (Pedro te va a
pasar el código generado + ese mismo prompt como referencia):

**Cowork audita (técnico — no hace falta que vos mires esto):**
- `node --check` sobre el JS extraído.
- Diff contra la Tanda 4a: que selector/chat/backup/export viejo sigan intactos byte a byte.
- Que las funciones pegadas literales (`calcularValuacionRentaFija`, `valorMercadoHolding`,
  `ingresoPromedioReciente`, `aporteMesAnterior`, `calcularAporteSugerido`, `fmt`,
  `faseGlidePath`, `initFirebaseWithRetry`) se reprodujeron exactas, sin reescribir lógica.
- Paleta: variables CSS existentes, cero valores nuevos inventados.
- Los 3 `<script>` de Firebase, `db`/`auth` declarados.

**Vos auditás (diseño/criterio — para esto te lo vamos a pasar):**
- Que el system prompt del Director tenga las 4 prohibiciones completas (incluida la cláusula
  anti-inferencia que agregamos en la 2da ronda) y que `RESUMEN_DIRECTOR_TEXTO` no filtre
  `ingresoProm` en ningún string real que se le mande a la API.
- Que el Risk Officer responda las 4 preguntas del ORSA contra el resumen real (no las enumere en
  abstracto) y que la pregunta 2 diga explícitamente "no tengo revisión anterior" en vez de
  inventar que no hubo cambios.
- Que ningún cargo (los otros 4, sin acceso a `RESUMEN_DIRECTOR_TEXTO`) mencione ingresos o
  productividad de Pedro, ni siquiera de forma indirecta.
- Que el informe exportado siga la estructura de la sección 6 (encabezado con fecha+hora al tope,
  cargos fallidos listados como "— no generado") y que el formato de `RESUMEN_CARTERA_TEXTO`
  serializado se parezca al ejemplo de la sección 3, no un dump de objeto.
- Cualquier fuga de scope nueva que no esté en el checklist — para eso te llamamos a vos y no
  solo a un checklist fijo.

Si encontrás algo que cae del lado de Cowork (sintaxis, diffs), no hace falta que lo señales — ya
está cubierto. Si encontrás un desvío de diseño/criterio nuevo, marcalo como en las rondas
anteriores: punto concreto, severidad, fix propuesto.

*Agregado por Claude Sonnet 5 — 2026-09-16, a pedido de Pedro.*
