# PROMPT PARA EL REACTOR — ZAR Vanguard Capital Partners — Tanda 3
**Glide path por bucket + regla de suavizado de aportes + visualización con Chart.js**

Pegar este prompt en el Reactor junto con el `index.html` ACTUAL de ZAR Vanguard
(Tanda 1 + Tanda 2 ya deployadas en `pedritozar.github.io/zar-vanguard`) como
contexto. **Esto EXTIENDE ese archivo, no lo reescribe.** Todo el bloque de
Fondo de Emergencia (buckets, aportes, seed) y todo el bloque de Portafolio
(holdings, motor de valuación, extracción por visión) tienen que quedar 100%
intactos, byte a byte — no tocarlos, no reordenarlos, no "mejorarlos" de paso.

---

## Alcance de esta tanda, nada más

- **Glide path por bucket**: cada bucket del Fondo de Emergencia muestra una
  "fase" según el % de SU PROPIA meta alcanzado (no de la meta total), con las
  3 fases y sus umbrales EXACTOS de la sección 1. Incluye un gauge visual
  (Chart.js) por bucket.
- **Regla de suavizado de aportes**: una card nueva de solo lectura que
  calcula y muestra un "aporte sugerido del mes" (total + desglose por
  bucket), usando la fórmula EXACTA de la sección 2. No escribe nada en
  Firebase, no carga ningún aporte sola — es una referencia para que Pedro
  después cargue el aporte real a mano con el formulario que ya existe.
- **Visualización con Chart.js** (sección 3, agregado en esta sesión al
  revisar que el spec ya lo pedía y no se había hecho en ninguna tanda
  anterior): gauge de progreso por bucket coloreado según la fase del glide
  path, gráfico de composición del Portafolio (renta fija vs. variable), y
  vista TIR/duración de las tenencias de renta fija.

**Explícitamente NO construir en esta tanda:**
- Directorio de 5 cargos, tutor educativo, Modo Revisión de Cartera — Tanda 4
- Ningún botón que aplique el aporte sugerido automáticamente a un bucket —
  la carga real de aportes sigue siendo 100% manual, esto es solo una
  sugerencia numérica
- Ninguna conversión de moneda (ver nota sobre ingresos en USD más abajo)
- Ninguna paleta de colores nueva para los charts — ver sección 3, se
  reusan las variables CSS que ya existen (`--blue`, `--green`, `--amber`,
  `--txt`, `--text3`), nada de colores hardcodeados nuevos

## Por qué los números y el código van literales acá

Esta tanda tiene números específicos (umbrales del glide path, tasa objetivo
y banda de la regla de suavizado) y patrones de código ya probados en otro
archivo real de Pedro (`trading-desk/index.html`, sección Chart.js) que NO
son "criterio de diseño" reinterpretable. Van pegados tal cual abajo. No
inventar umbrales, tasas, colores nuevos, ni una librería de charts distinta
a Chart.js.

## 1. Glide path por bucket — COPIAR TAL CUAL

```js
// Glide path "through": no se aplana al llegar a 100%, sigue vigente.
// colorVar es el NOMBRE de la variable CSS (sin var(), sin #) para poder
// usarse tanto en CSS inline (var(--x)) como resuelta en JS con cssVar()
// para Chart.js -- ver sección 3.
function faseGlidePath(pct){
  if (pct < 40){
    return {
      fase: 'acumulacion',
      etiqueta: 'Acumulación',
      colorVar: '--blue',
      nota: 'Meta lejos: algo de rendimiento tolerado (plazo fijo corto, money market).'
    };
  }
  if (pct < 75){
    return {
      fase: 'transicion',
      etiqueta: 'Transición',
      colorVar: '--amber',
      nota: 'Aportes nuevos y parte de lo acumulado migran a liquidez.'
    };
  }
  return {
    fase: 'liquidez_total',
    etiqueta: 'Liquidez total',
    colorVar: '--green',
    nota: 'Meta alcanzada o superada: liquidez total, revisión continua (nunca "termina").'
  };
}
```

Los umbrales (40 y 75) y las 3 fases son del spec, no se negocian.

**UI**: en `renderBucketCard()`, agregar una badge chica con
`style="background:var(${fase.colorVar})"` mostrando `etiqueta`, la `nota`
como texto chico debajo (mismo criterio tipográfico que `res-nota`), y un
`<canvas id="gauge-${bucketId}" width="56" height="56"></canvas>` — el
gauge se dibuja después de insertar el HTML, ver sección 3.

## 2. Regla de suavizado de aportes — COPIAR TAL CUAL

Parámetros decididos por Pedro (no recalcular ni ajustar):

```js
const TASA_OBJETIVO = 0.10;   // 10% del ingreso promedio reciente
const BANDA_MIN = 0.10;       // piso: 10% del ingreso promedio (mismo % que ya destina a otra cuenta)
const BANDA_MAX = 0.15;       // techo: 15% del ingreso promedio
const VENTANA_MESES = 3;      // promedio de ingresos de los últimos 3 meses calendario
```

**Fuente del ingreso**: se lee EN VIVO del nodo `ingresos` que ya existe en el
mismo proyecto Firebase de ZAR Finance (no se duplica ni se vuelve a cargar).
La ruta real, verificada en el `index.html` de ZAR Finance, es
`ingresos/{uid}/{y}/{m}/{pushId}` con cada entrada `{fecha, monto, moneda,
categoria, nota, timestamp}`. Usar la MISMA constante `UID_AUTORIZADO` que ya
existe en el archivo de Vanguard (no crear un uid nuevo ni pedirlo de nuevo,
es el mismo usuario). Sumar solo entradas con `moneda === 'ARS'` — si hay
ingresos cargados en USD en ZAR Finance, se ignoran para este cálculo (no hay
conversión de moneda en esta tanda):

```js
async function ingresoPromedioReciente(){
  const hoy = new Date();
  let total = 0, meses = 0;
  for (let i = 0; i < VENTANA_MESES; i++){
    const d = new Date(hoy.getFullYear(), hoy.getMonth() - i, 1);
    const y = d.getFullYear(), m = String(d.getMonth() + 1).padStart(2, '0');
    const snap = await db.ref(`ingresos/${UID_AUTORIZADO}/${y}/${m}`).once('value');
    const entradas = Object.values(snap.val() || {});
    const totalMes = entradas
      .filter(e => (e.moneda || 'ARS') === 'ARS')
      .reduce((s, e) => s + (Number(e.monto) || 0), 0);
    total += totalMes;
    meses++;
  }
  return meses > 0 ? total / meses : 0;
}
```

**Aporte del mes anterior**: se calcula en vivo sumando TODOS los aportes
(los 4 buckets juntos) cuya `fecha` cae en el mes calendario anterior —
reusa `APORTES_LIVE` y `ORDEN_BUCKETS` que ya existen, no agrega ningún nodo
nuevo a Firebase:

```js
function aporteMesAnterior(){
  const hoy = new Date();
  const prev = new Date(hoy.getFullYear(), hoy.getMonth() - 1, 1);
  const yPrev = prev.getFullYear(), mPrev = String(prev.getMonth() + 1).padStart(2, '0');
  let total = 0;
  ORDEN_BUCKETS.forEach(bucketId => {
    Object.values(APORTES_LIVE[bucketId] || {}).forEach(a => {
      if (a.fecha && a.fecha.startsWith(`${yPrev}-${mPrev}`)) total += Number(a.monto) || 0;
    });
  });
  return total;
}
```

**Fórmula de suavizado** (adaptación de la Yale Spending Rule, sección 5 del
SPEC): 80% del aporte del mes anterior + 20% de la tasa objetivo aplicada al
ingreso promedio, clampeado a la banda. Si no hay aporte del mes anterior
(primer mes de uso, sin historial), arranca directo en el objetivo en vez de
suavizar contra cero:

```js
async function calcularAporteSugerido(){
  const ingresoProm = await ingresoPromedioReciente();
  const objetivo = ingresoProm * TASA_OBJETIVO;
  const anterior = aporteMesAnterior();
  const base = anterior > 0 ? (0.8 * anterior + 0.2 * objetivo) : objetivo;
  const piso = ingresoProm * BANDA_MIN;
  const techo = ingresoProm * BANDA_MAX;
  const sugeridoTotal = Math.min(Math.max(base, piso), techo);

  // Reparto proporcional a la meta de cada bucket (mismos % que ya definen los buckets)
  const metaTotal = ORDEN_BUCKETS.reduce((s, id) => s + (BUCKETS_LIVE[id] ? Number(BUCKETS_LIVE[id].metaARS) || 0 : 0), 0);
  const porBucket = {};
  ORDEN_BUCKETS.forEach(id => {
    const metaBucket = BUCKETS_LIVE[id] ? Number(BUCKETS_LIVE[id].metaARS) || 0 : 0;
    const peso = metaTotal > 0 ? metaBucket / metaTotal : 0;
    porBucket[id] = sugeridoTotal * peso;
  });

  return { ingresoProm, sugeridoTotal, porBucket };
}
```

**UI**: card nueva "💡 Aporte sugerido de este mes" en el tab de Fondo de
Emergencia (debajo del resumen agregado, arriba del grid de buckets), de
SOLO LECTURA: ingreso promedio usado como base (con nota "solo ingresos en
ARS de los últimos 3 meses"), aporte total sugerido, desglose por bucket (4
líneas). Sin botones de acción. Si `ingresoPromedioReciente()` da 0, mostrar
un estado vacío tipo "Cargá ingresos en ZAR Finance para ver una sugerencia"
en vez de un número en $0 engañoso.

## 3. Visualización con Chart.js — patrón EXACTO (adaptado de trading-desk/index.html)

Pedro ya usa Chart.js en otro de sus dashboards (`trading-desk/index.html`)
con un patrón específico para que los charts se re-pinten solos cuando
cambia el tema claro/oscuro del sistema (un canvas ya dibujado con un color
fijo NO reacciona solo a un cambio de `prefers-color-scheme`, a diferencia
del resto de la UI que sí usa CSS puro). Reusar ese mismo patrón acá, no
inventar uno nuevo:

**Cargar la librería** (mismo CDN y versión que ya usa Pedro en otro
archivo, agregar el script tag antes del `<script>` principal, cerca del
resto de scripts de Firebase):
```html
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
```

**Helper + instancias globales + listener de cambio de tema**:
```js
// Lee el valor RESUELTO de una variable CSS (Chart.js pinta en un <canvas>,
// no puede usar var(--x) directo como getComputedStyle sí puede).
function cssVar(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
}

// Chart.js no soporta re-crear sobre el mismo canvas sin destroy() previo.
let chartsBucketGauge = {};      // { bucketId: instancia }
let chartPortComposicion = null;
let chartPortTirDuracion = null;

if (window.matchMedia) {
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
    renderBuckets();      // ya existe (Tanda 1) -- ahora también dispara los gauges
    renderPortafolio();   // ya existe (Tanda 2) -- ahora también dispara los charts de Portafolio
  });
}
```

**3a. Gauge de progreso por bucket, coloreado por fase**. Se dibuja DESPUÉS
de insertar el HTML de `renderBuckets()` (el canvas no existe en el DOM
hasta que el `innerHTML` se aplicó):
```js
function renderGaugeBucket(bucketId, pct, colorVarFase){
  const canvas = document.getElementById('gauge-' + bucketId);
  if (!canvas || typeof Chart === 'undefined') return;
  const pctClamp = Math.max(0, Math.min(pct, 100));
  if (chartsBucketGauge[bucketId]) chartsBucketGauge[bucketId].destroy();
  chartsBucketGauge[bucketId] = new Chart(canvas.getContext('2d'), {
    type: 'doughnut',
    data: {
      datasets: [{
        data: [pctClamp, 100 - pctClamp],
        backgroundColor: [cssVar(colorVarFase), cssVar('--border')],
        borderWidth: 0
      }]
    },
    options: { cutout: '70%', plugins: { legend: { display: false }, tooltip: { enabled: false } }, animation: false }
  });
}
```
Modificar `renderBuckets()` (la función que ya existe) para que, después de
`grid.innerHTML = ...`, recorra los buckets visibles y llame a
`renderGaugeBucket(id, pct, faseGlidePath(pct).colorVar)` con el mismo `pct`
que ya calcula `renderBucketCard`.

**3b. Composición del Portafolio** (renta fija vs. variable, por valor de
mercado). Canvas `<canvas id="port-chart-composicion"></canvas>` en la card
resumen del Portafolio, dibujado al final de `renderResumenPortafolio()`:
```js
function renderChartComposicion(){
  const canvas = document.getElementById('port-chart-composicion');
  if (!canvas || typeof Chart === 'undefined') return;
  let rentaFija = 0, variable = 0;
  Object.values(HOLDINGS_LIVE).forEach(h => {
    const v = valorMercadoHolding(h);
    if (h.tipo === 'rentaFija') rentaFija += v; else variable += v;
  });
  if (chartPortComposicion) chartPortComposicion.destroy();
  if (rentaFija + variable <= 0) return; // nada cargado todavía, no dibujar vacío
  chartPortComposicion = new Chart(canvas.getContext('2d'), {
    type: 'doughnut',
    data: {
      labels: ['Renta fija', 'Variable'],
      datasets: [{ data: [rentaFija, variable], backgroundColor: [cssVar('--blue'), cssVar('--amber')], borderWidth: 0 }]
    },
    options: { plugins: { legend: { position: 'bottom', labels: { color: cssVar('--txt') } } } }
  });
}
```

**3c. Vista TIR/duración** (un punto por tenencia de renta fija). Canvas
`<canvas id="port-chart-tir-duracion"></canvas>` en la misma zona, dibujado
también al final de `renderResumenPortafolio()`:
```js
function renderChartTirDuracion(){
  const canvas = document.getElementById('port-chart-tir-duracion');
  if (!canvas || typeof Chart === 'undefined') return;
  const puntos = Object.values(HOLDINGS_LIVE)
    .filter(h => h.tipo === 'rentaFija')
    .map(h => {
      const v = calcularValuacionRentaFija(h);
      return { x: v.modificada, y: v.ytmExacto, nombre: h.nombre };
    });
  if (chartPortTirDuracion) chartPortTirDuracion.destroy();
  if (!puntos.length) return;
  chartPortTirDuracion = new Chart(canvas.getContext('2d'), {
    type: 'scatter',
    data: { datasets: [{ label: 'Renta fija', data: puntos, backgroundColor: cssVar('--blue') }] },
    options: {
      scales: {
        x: { title: { display: true, text: 'Duración modificada (años)', color: cssVar('--text3') } },
        y: { title: { display: true, text: 'TIR exacta (%)', color: cssVar('--text3') } }
      },
      plugins: {
        legend: { display: false },
        tooltip: { callbacks: { label: (ctx) => puntos[ctx.dataIndex].nombre + ': TIR ' + ctx.parsed.y.toFixed(2) + '%, Dur. ' + ctx.parsed.x.toFixed(2) } }
      }
    }
  });
}
```
Llamar a `renderChartComposicion()` y `renderChartTirDuracion()` al final de
`renderResumenPortafolio()` (o de `renderPortafolio()`, lo que ya exista),
mismo criterio que el gauge de buckets: después de que el HTML con los
canvas ya esté insertado en el DOM.

**Degradación si el CDN no carga**: en todos los casos de arriba, si
`typeof Chart === 'undefined'` la función corta antes de intentar dibujar
(no rompe el resto del dashboard) — mismo criterio defensivo que ya usa
Pedro en `trading-desk/index.html`.

## QC al recibir el resultado (recordatorio para la sesión de Cowork)

- `node --check` sobre el JS embebido completo (Tanda 1 + 2 + 3)
- Diff contra el archivo actual (Tanda 1 + 2): los bloques de Fondo de
  Emergencia y Portafolio deben quedar BYTE A BYTE intactos salvo los
  agregados puntuales de esta tanda (badge+gauge en `renderBucketCard`,
  charts al final de `renderResumenPortafolio`)
- Verificar que `faseGlidePath` usa los umbrales 40/75 exactos
- Verificar que `TASA_OBJETIVO`, `BANDA_MIN`, `BANDA_MAX` y `VENTANA_MESES`
  son exactamente 0.10 / 0.10 / 0.15 / 3
- Confirmar que la lectura de ingresos filtra por `moneda === 'ARS'` y no
  convierte ni suma USD
- Confirmar que la card de sugerencia NO escribe nada en Firebase — es
  puramente de lectura/cálculo
- Confirmar que sigue usando `UID_AUTORIZADO` (no un uid nuevo) para leer
  `ingresos/{uid}/...`
- Confirmar que el script tag de Chart.js es exactamente
  `chart.js@4.4.4/dist/chart.umd.min.js` (misma versión que
  `trading-desk/index.html`, no una versión distinta)
- Confirmar que los charts usan `cssVar()` sobre las variables ya
  existentes (`--blue`, `--green`, `--amber`, `--txt`, `--text3`,
  `--border`) y ningún color hex nuevo
- Confirmar que el listener de `matchMedia('(prefers-color-scheme: dark)')`
  vuelve a llamar a `renderBuckets()` y `renderPortafolio()` (los charts
  tienen que re-pintarse al cambiar de tema, igual que el resto de la app)

## Pendiente de confirmar con uso real (anotar en la auditoría, no bloquea la tanda)

- Que las reglas de seguridad de Firebase permitan que la app de Vanguard
  (autenticada con el mismo `UID_AUTORIZADO`) LEA el nodo `ingresos/{uid}/...`
  que pertenece a ZAR Finance — debería funcionar si la regla es del tipo
  `auth.uid == $uid` sobre `ingresos/$uid`, pero no está verificado en vivo
  todavía.

---
*Preparado por Claude Sonnet 5 — 15/09/2026, a partir del SPEC (secciones 2 y
5), de la estructura real del nodo `ingresos` en el `index.html` de ZAR
Finance, y del patrón real de Chart.js en `trading-desk/index.html`. Los
parámetros de la regla de suavizado (10% objetivo, banda 10%-15%, ventana de
3 meses, reparto proporcional a metas de bucket) y la decisión de reusar la
paleta existente para los charts (en vez de una "paleta Matrix" nueva, que no
estaba definida en ningún archivo) fueron confirmados por Pedro en el chat de
generación.*

## Tokens de salida recomendados

**Piso: 60.000.** Misma calibración que Tanda 2 (el cálculo por caracteres
subestimó y truncó en el primer intento). Esta tanda agrega glide path +
suavizado + 3 charts nuevos con Chart.js — más código que la versión anterior
de este mismo prompt, así que no bajar de este piso.
