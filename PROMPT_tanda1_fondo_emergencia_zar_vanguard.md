# PROMPT PARA EL REACTOR — ZAR Vanguard Capital Partners — Tanda 1
**Fondo de Emergencia + sub-buckets + meta activada**

Pegar este prompt en el Reactor junto con el `index.html` completo de ZAR Finance como
contexto de referencia (estilo visual y patrón de Firebase/Auth — NO se toca ni se importa
ese archivo, es solo para copiar el criterio).

---

## Qué es esto

"ZAR Vanguard Capital Partners" es un dashboard nuevo, standalone, para trackear con plata
real un Fondo de Emergencia con sub-buckets. Es un producto separado de ZAR Finance (Alfy,
presupuesto) y de ZAR Capital Management (el simulador de trading, plata ficticia) — nunca se
mezclan ni comparten UI, aunque sí comparten el mismo backend de Firebase.

**Alcance de ESTA tanda, nada más:**
- Fondo de Emergencia con 4 sub-buckets fijos y su meta activada
- Login y persistencia real en Firebase

**Explícitamente NO construir en esta tanda** (van en tandas futuras, dejar la estructura
lista para enchufarlas sin reescribir, pero no implementarlas):
- Glide path por fase (0-40% / 40-75% / 75-100%+) — Tanda 3
- Regla de suavizado de aportes (adaptación Yale 80/20) — Tanda 3
- Portafolio nuevo en Cocos Capital — Tanda 2
- Directorio de 5 cargos / tutor / Modo Revisión de Cartera — Tanda 4, archivo HTML aparte

## Infraestructura

- Archivo HTML único, standalone, sin frameworks — mismo criterio técnico que ZAR Finance.
- Deploy: repo nuevo y dedicado en GitHub Pages, `zar-vanguard` — no el mismo repo de ZAR
  Finance.
- Firebase: el MISMO proyecto que ya usa ZAR Finance (mismo `FB_CFG`, mismo patrón de auth).
  Pedro pega su config real al momento de generar — no inventar valores.
- Auth: idéntico patrón a ZAR Finance — login obligatorio con Google
  (`signInWithPopup` + `GoogleAuthProvider`), sin auth anónima (las reglas de la DB exigen
  `auth.uid == uid` contra el UID fijo de los datos, ya confirmado por PERMISSION_DENIED con
  anónima en ZAR Finance).
- Nodo de datos NUEVO, sin tocar ningún nodo existente de ZAR Finance (gastos, ingresos,
  deudas, objetivos, vivienda, tarjeta, carteraHist, comprasPendientes, boveda). Preparado
  multi-cliente desde el arranque (spec sección 6, para sumar a la madre después sin
  reestructurar):

  ```
  clientes/{clienteId}/vanguard/fondoEmergencia/buckets/{bucketId}
    → { nombre, metaARS }
  clientes/{clienteId}/vanguard/fondoEmergencia/buckets/{bucketId}/aportes/{id}
    → { monto, fecha, timestamp }
  ```

  `clienteId = "pedro"` hardcodeado por ahora, pero todo el código debe leerlo de una
  constante única (no repetir el string suelto), para que sumar un segundo cliente después
  sea cambiar una lista, no reescribir lógica.

  Aportes: mismo patrón que `objetivos/{uid}/aportes` en ZAR Finance — `push()` para crear,
  `set()` puntual sobre un id para editar (nunca pisa los demás aportes), `remove()` para
  borrar uno solo.

## Seed inicial (una sola vez, solo si el nodo no existe todavía)

Mismo patrón que `DEUDAS_ESTADO_SEED` en ZAR Finance: al cargar, si
`clientes/pedro/vanguard/fondoEmergencia/buckets` no existe, se siembra una única vez con:

| bucketId | nombre | metaARS |
|---|---|---|
| `desempleo` | Desempleo | 1800000 |
| `accidentesFisicos` | Accidentes físicos | 720000 |
| `multasLegales` | Multas / imprevistos legales | 540000 |
| `otros` | Otros | 540000 |

Meta total (suma de los 4, mostrada como referencia, no un nodo separado): **$3.600.000 ARS**.

No resembrar en cargas siguientes aunque el código cambie — si el nodo ya existe, respetarlo
tal cual está (mismo criterio que ZAR Finance con `deudasFijasEstado`).

## UI de esta tanda

- Pantalla de login idéntica en patrón funcional a ZAR Finance (botón "Ingresar con Google",
  bloqueado hasta autenticar).
- Card resumen arriba de todo: acumulado total (suma de los 4 buckets) vs. $3.600.000, barra
  de progreso agregada, % alcanzado.
- 4 cards, una por bucket, mismo componente visual `card` / `card-ttl` que ZAR Finance:
  - nombre del bucket
  - meta ARS y acumulado real (suma de sus aportes)
  - barra de progreso reusando la clase `dti-bg` / `dti-fill` ya usada en ZAR Finance
  - % de meta alcanzada
  - formulario "agregar aporte" (monto + fecha) con los mismos componentes `sim-field` /
    `sim-lbl` / `sim-input` y botón `hdr-btn pri`
  - listado de aportes cargados a ese bucket, cada uno editable y borrable individualmente
    (mismo patrón que la lista de aportes de `objetivos` en ZAR Finance)
- Mismo dark theme, misma paleta de variables CSS (`--blue`, `--green`, `--amber`, `--text3`,
  `--border`, `--bg`, etc.) y tipografía que ZAR Finance — copiar la paleta tal cual, no
  reinventar colores nuevos.
- Sin gráfico de evolución todavía (se suma en Tanda 3 junto con el glide path, si Pedro lo
  pide entonces).

## QC al recibir el resultado (recordatorio para la sesión de Cowork, no para el Reactor)

- `node --check` sobre el JS embebido
- Balance de tags HTML
- Confirmar que el nodo `clientes/pedro/vanguard/...` no colisiona con ningún nodo existente
  de ZAR Finance
- Confirmar que el login exige Google real (no cuela auth anónima)
- Confirmar que la suma de metas de los 4 buckets da exactamente $3.600.000

---
*Preparado por Claude Sonnet 5 — 14/09/2026, a partir del SPEC y CHANGELOG cerrados el mismo
día, más el index.html real de ZAR Finance (Firebase/auth) y los datos confirmados por Pedro
(meta $3.600.000 ARS, desglose de buckets, cobertura OSDE 310, deploy en repo nuevo).*
