# SPEC — ZAR Vanguard Capital Partners
Fondo de Emergencia + Portafolio nuevo (Cocos Capital) — plata real
Síntesis de los 3 ángulos de research: family office (Willett Advisors, Creative Planning, FOX),
J.P. Morgan Private Bank (goals-based investing) y Yale Investments Office.

---

## 1. Estructura superior — los 4 lentes de J.P. Morgan

Dos lentes activos desde el día uno, dos reservados para el futuro (esquema pensado para
extender sin rehacer nada):

- **Liquidez** → Fondo de Emergencia (activo)
- **Crecimiento** → Portafolio nuevo, Cocos Capital (activo)
- **Estilo de vida** → sin uso por ahora (slot reservado)
- **Legado** → sin uso por ahora (slot reservado — NO es el fondo de la madre; ese es un cliente
  aparte dentro del mismo sistema, ver sección 6, no una lente)

## 2. Lente Liquidez — Fondo de Emergencia

**Sub-buckets por tipo de contingencia** (patrón family office — diversificar, no un pozo único),
cada uno con su propia meta como % del total: accidentes físicos, desempleo (cubre meses de
gastos operativos/fijos), multas/imprevistos legales, otros. La meta agregada es la que ya existe
en la hoja "Fondo Emergencia" de FINANCE ZAR.xlsx — se reparte entre buckets, no se duplica.

**Glide path "through" por bucket** (matiz PIMCO sobre LDI de pensiones), disparado por % de la
meta del bucket alcanzado, no por fecha — y sigue vigente después de llegar al 100%, no se aplana:

- 0-40%: algo de rendimiento tolerado (plazo fijo corto, money market)
- 40-75%: transición — aportes nuevos y parte de lo acumulado migran a liquidez
- 75-100%+: liquidez total, revisión continua (nunca "termina")

**$3.600.000 es un PISO, no un techo** — con interés compuesto y aportes el acumulado puede
seguir creciendo por encima de la meta indefinidamente (cuanto más preparado para imprevistos,
mejor). El glide path ya trabaja por % de la meta alcanzada, no por peso absoluto, así que el
crecimiento por encima del 100% lo absorbe sin ajuste — el excedente queda como colchón en el
mismo bucket, acumulando interés, no se retira ni se reparte a otro bucket.

## 3. Lente Crecimiento — Portafolio nuevo (Cocos Capital)

Perfil defensivo: mayoría renta fija en moneda dura, porción menor en variable. Sin sub-buckets
por ahora (una sola cuenta, un solo perfil). Reusa la lógica de valuación/tracking ya construida
en `Mundo corpo` (`bonos_tracker.html`, `renta_fija_tutor.html`, `valuacion_tutor.html`) en vez de
que el Reactor invente matemática de bonos de cero — campos tipo TIR/YTM, duración, vencimiento,
cupón, moneda.

## 4. Gobierno — mezcla family office + Yale

**Charter escrito** (patrón Family Office Exchange, 5 elementos): Autoridad, Propósito,
Responsabilidades, Membresía, Reuniones — un documento corto, una sola vez, no un feature del
dashboard.

**Cadencia: revisión trimestral estilo Yale** — vos (el "staff"/Oficina de Inversiones) proponés,
el "comité" revisa y aprueba. Contenido de la revisión = ORSA simplificado en 4 preguntas: ¿cuáles
son los riesgos hoy?, ¿cambió algo desde la última revisión?, ¿la asignación real coincide con la
fase del glide path?, ¿hace falta un plan de contingencia?

**5 cargos** (modelo Hybrid — Creative Planning: capa temática separada de la capa funcional; sin
API por miembro, sin debate simulado):

| Cargo | Dueño de | Inspiración |
|---|---|---|
| Chair/CEO | Visión general, revisa objetivos con "la familia" (vos) | Willett Advisors (Rattner) |
| CIO | Estrategia del Portafolio nuevo — crecimiento | Willett Advisors (Mulderry/Briner), J.P. Morgan |
| CFO | Preservación, tesorería, compliance del Fondo de Emergencia | Family office genérico |
| Risk Officer | Expone concentración/liquidez, corre la revisión trimestral (ORSA) | Seguros (ORSA), Family office (stress test) |
| Director/a de Oficina de Inversiones | Regla de suavizado de aportes (sección 5), propone estrategia al resto | Yale Investments Office |

## 5. Regla de suavizado de aportes (adaptación de la Yale Spending Rule)

La regla real de Yale: 80% del gasto del año anterior + 20% de una tasa objetivo (5,25%) sobre el
valor de hace 2 años, dentro de una banda 4,5%-6,0% — pensada para que la volatilidad de mercado
no golpee el presupuesto de un año a otro.

Adaptada a este fondo (el problema real es el otro lado: ingresos irregulares de trader/estudiante,
no gasto de una perpetuidad): **aporte del mes = 80% del aporte del mes anterior + 20% de una tasa
objetivo aplicada al ingreso promedio reciente**, dentro de una banda mínima/máxima — así un mes
de ingresos flojos no te hace saltear el aporte del todo, y un mes fuerte no dispara un aporte que
después no podés sostener.

## 6. Multi-cliente (preparado para la madre, no construido todavía)

Esquema de Firebase con nodo por cliente desde el arranque (`clientes/{clienteId}/...`), aunque
hoy solo exista el nodo de Pedro. Evita rediseñar la estructura de datos cuando se sume el segundo
perfil.

## 7. Directorio — tutor educativo bajo demanda

HTML aparte (no se mezcla con `renta_fija_tutor.html` ni `valuacion_tutor.html` — mismo criterio
que Pedro ya documentó en `CHANGELOG_cmt_tutor.md` para no diluir el foco de un tutor mezclando
disciplinas). Reusa el motor de `valuacion_tutor.html` como referencia técnica para el Reactor:
system prompt dinámico, Modo Examen con el set de keywords de valuación, tag único
`[[NEXT_MODEL:x]]` (unifica la inconsistencia entre los dos tutores existentes), backup/restore
JSON, export de sesión a changelog markdown. 5 system-prompts (uno por cargo de la tabla en la
sección 4), activados bajo demanda desde un botón por cargo en el dashboard principal — no hay
llamada a la API hasta que Pedro elige hablar con uno.

## 8. Modo Revisión de Cartera (trimestral/bimestral) — agregado 2026-09-14

Distinto del tutor educativo de la sección 7: acá el directorio comenta sobre datos REALES, no
sobre teoría. Cadencia elegida por Pedro (trimestral o bimestral), disparada manualmente, nunca
automática.

**Mecánica**: al abrir el modo, se arma un resumen de la composición y desempeño actual del
Fondo de Emergencia + Portafolio (extraído de Firebase, mismo patrón que "enviar al tutor" ya
usado en `valuacion_tutor.html`/`renta_fija_tutor.html`) y se carga como contexto fijo de la
sesión. Cada cargo del directorio (sección 4) da su comentario **ciñéndose estrictamente a esos
números** — el system prompt de cada uno lo restringe explícitamente a interpretar los datos
dados, no opinar en general ni inventar cifras que no están en el resumen. Esto es intencional:
mitiga el riesgo de "falsa confianza" que Pedro ya documentó en el debate de "Modo Auditor" del
Reactor (un LLM sonando seguro de sí mismo estando equivocado, sin verificación real detrás) —
acá la verificación real es que solo puede hablar de lo que efectivamente está en el resumen.

**Chat libre**: además de la ronda de comentarios por cargo, Pedro puede tipear y preguntar al
directorio sobre esos mismos datos — mismo motor de chat que el tutor educativo, mismo tag
`[[NEXT_MODEL:x]]`, misma sesión.

**Salida**: exporta como informe formal (no como changelog crudo de sesión) — composición,
desempeño, comentario por cargo, notas de la conversación — pensado como plantilla reusable el
día que haya un cliente real (la madre) del otro lado. Doble propósito reconocido por Pedro: sirve
de comunicación real con un futuro cliente, y le sirve a él mismo para aprender a armar un informe
de cartera desde cero, algo que nunca hizo.

## 9. Infraestructura

Mismo Firebase/login de Google que ZAR Finance (patrón Tactical Ledger) — nodo nuevo, sin cargar
ninguna plata dos veces.

---

*Preparado por Claude Sonnet 5 — 2026-09-14, síntesis de RESEARCH_ideas_wallstreet.txt (Tanda 3),
RESEARCH_family_office_pensiones_seguros.md, y research en vivo sobre Yale Investments Office,
a pedido de Pedro. Nada de esto está generado todavía — es el spec para pasarle al Reactor.*
