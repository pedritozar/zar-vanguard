# PROMPT — Tanda 4b: Modo Revisión de Cartera
ZAR Vanguard Capital Partners — extiende `directorio_zar_vanguard.html` (NO es un archivo
nuevo). Pegar este prompt en el Reactor Nuclear IA junto con `directorio_zar_vanguard.html`
completo (la Tanda 4a ya cerrada) como contexto. **No hace falta pegar `index.html` completo**
— los fragmentos de Firebase que hacen falta ya están copiados literalmente más abajo en este
prompt para no repetir el desvío de paleta/valores de la Tanda 1 y la primera pasada de Tanda 4a.

**Tokens de salida recomendados: 60.000** (piso calibrado por precedente de Tanda 3/4a — no
estimar por caracteres).

---

## 0. Qué es esto y qué NO es

Esto es el "Modo Revisión de Cartera" descrito en `SPEC_zar_vanguard_capital_partners.md`
sección 8. Es DISTINTO del tutor educativo de la Tanda 4a (sección 7 del spec):

- **Tutor (4a, ya existe)**: teoría bajo demanda, sin datos reales, cada cargo explica
  conceptos de su disciplina.
- **Revisión de Cartera (4b, esto)**: el directorio comenta sobre datos REALES de Firebase
  (Fondo de Emergencia + Portafolio), disparado manualmente por Pedro (cadencia trimestral o
  bimestral, **nunca automática, nunca en background**). Cada cargo se ciñe estrictamente a
  los números del resumen — cero opinión general, cero cifra inventada.

Se agrega como una TERCERA vista dentro del mismo `directorio_zar_vanguard.html` (ya existen
`selectorView` y `chatView` de la Tanda 4a) — nueva vista `revisionView`. No se crea un archivo
nuevo, no se toca el tutor de la Tanda 4a (regresión cero, mismo criterio que las tandas
anteriores).

## 1. Conexión a Firebase (nueva en este archivo — 4a no tenía Firebase)

`directorio_zar_vanguard.html` hoy es 100% BYOK/localStorage, sin Firebase — no tiene NINGÚN
`<script>` de Firebase cargado. Para leer datos reales hace falta agregar el MISMO login/proyecto
que `index.html`, en modo **exclusivamente lectura** (esta vista nunca escribe en Firebase).

**Primero, en el `<head>`, agregar los mismos 3 `<script>` de Firebase compat que ya usa
`index.html` (misma versión, v10.7.1 — no actualizar, no bajar de versión):**

```html
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-database-compat.js"></script>
```

Después, copiar literal el config y el arranque con reintento:

```js
// ============ CONFIG FIREBASE (idéntica a index.html — mismo proyecto, solo lectura) ============
const FB_CFG = {
  apiKey:            "AIzaSyBDkqXKdtFRs1On4kw0lP3Bk897esslmoM",
  authDomain:        "zarfinance.firebaseapp.com",
  databaseURL:       "https://zarfinance-default-rtdb.firebaseio.com",
  projectId:         "zarfinance",
  storageBucket:     "zarfinance.firebasestorage.app",
  messagingSenderId: "210001894365",
  appId:             "1:210001894365:web:1d9b27f0c3340ed71ef434"
};
const UID_AUTORIZADO = 'JsW7CjDObEhn3DoFkwzuJUGLhrB3';
const CLIENTE_ID = 'pedro';
function pathBuckets(){ return `clientes/${CLIENTE_ID}/vanguard/fondoEmergencia/buckets`; }
function pathHoldings(){ return `clientes/${CLIENTE_ID}/vanguard/portafolio/holdings`; }
function pathAportes(bucketId){ return `${pathBuckets()}/${bucketId}/aportes`; }
const ORDEN_BUCKETS = ['desempleo','accidentesFisicos','multasLegales','otros'];

// db/auth -- idéntico a index.html línea 361. initFirebaseWithRetry los asigna, alguien los
// tiene que declarar primero.
let db = null, auth = null;
// Estado de la foto de esta revisión -- se llenan UNA VEZ al entrar a revisionView, nunca con
// listeners en vivo. Estos nombres son los que ya esperan ingresoPromedioReciente/
// aporteMesAnterior/calcularAporteSugerido/calcularValuacionRentaFija/valorMercadoHolding más
// abajo -- no renombrar.
let BUCKETS_LIVE = {}, APORTES_LIVE = {}, HOLDINGS_LIVE = {};

// Formato de moneda -- idéntico a index.html línea 370, no reinventar el separador de miles.
const fmt = n => '$' + Math.round(Number(n) || 0).toLocaleString('es-AR');

// Arranque con reintento -- copiado literal, NO reescribir la lógica de reintento.
function initFirebaseWithRetry(retries = 10, delayMs = 300){
  return new Promise((resolve, reject) => {
    function attempt(n){
      try{
        if (typeof firebase === 'undefined') throw new Error('SDK de Firebase no cargó todavía');
        if (!firebase.apps.length) firebase.initializeApp(FB_CFG);
        db = firebase.database();
        auth = firebase.auth();
        resolve();
      } catch(e){
        if (n <= 0){ reject(e); return; }
        setTimeout(() => attempt(n - 1), delayMs);
      }
    }
    attempt(retries);
  });
}
```

Usar el mismo chequeo `user.uid === UID_AUTORIZADO` que ya usa `index.html` — si la cuenta de
Google no coincide, mostrar el mismo mensaje de bloqueo, nunca cargar datos. El login solo se
dispara al entrar a `revisionView` (botón nuevo "📊 Revisión de Cartera" en `selectorView`), no
en el arranque general del tutor — así 4a sigue funcionando sin pedir login para quien solo
quiere hablar en modo teórico.

## 2. Fase del glide path — copiar literal de `index.html`, NO reinventar

```js
function faseGlidePath(pct){
  if (pct < 40){
    return { fase: 'acumulacion', etiqueta: 'Acumulación', colorVar: '--blue',
      nota: 'Meta lejos: algo de rendimiento tolerado (plazo fijo corto, money market).' };
  }
  if (pct < 75){
    return { fase: 'transicion', etiqueta: 'Transición', colorVar: '--amber',
      nota: 'Aportes nuevos y parte de lo acumulado migran a liquidez.' };
  }
  return { fase: 'liquidez_total', etiqueta: 'Liquidez total', colorVar: '--green',
    nota: 'Meta alcanzada o superada: liquidez total, revisión continua (nunca "termina").' };
}
```

Los nombres/metas de los 4 buckets (`desempleo`, `accidentesFisicos`, `multasLegales`, `otros`)
y el esquema de campos de holdings (`tipo`, `nombre`, `moneda`, `nominal`, `cuponAnual`,
`frecuenciaCupon`, `precio`, `fechaVencimiento`, `cantidad`, `precioUltimo`) son los mismos que
ya usa `index.html` — leerlos tal cual vienen de Firebase, no renombrar ni agregar campos.

## 3. Armado del resumen (contexto fijo de la sesión)

Al entrar a `revisionView`, leer UNA VEZ (`.once('value')`, no listener en vivo — es una foto
del momento, no un dashboard) `pathBuckets()` y `pathHoldings()`, y armar un objeto
`RESUMEN_CARTERA` con:

- Por bucket: nombre, meta, acumulado, % de la meta, fase del glide path (usando
  `faseGlidePath` de arriba).
- Total del Fondo de Emergencia: acumulado total vs. $3.600.000 (recordar: es PISO, no techo —
  si el acumulado supera la meta, mostrarlo como superávit, nunca truncar a 100%).
- Por holding del Portafolio: todos los campos tal cual están en Firebase. Si es renta fija y
  tiene los campos necesarios (nominal, cupón, frecuencia, precio, vencimiento), calcular
  TIR/duración con `calcularValuacionRentaFija()` (pegada literal más abajo en esta sección) — si
  falta algún campo, mostrar los campos crudos sin llamarla, nunca inventar una fórmula nueva de
  cero (evitar el error que el spec ya previno de "que el Reactor invente matemática de bonos").
- Fecha/hora en que se armó el resumen (para que quede claro en el informe exportado que es una
  foto de ese momento, no en vivo).

Ese objeto se serializa a texto plano (no JSON crudo) y se pega como bloque fijo
`RESUMEN_CARTERA_TEXTO` al final del system prompt de cada cargo en este modo — mismo criterio
que "enviar contexto real" ya usado en `valuacion_tutor.html`/`renta_fija_tutor.html`. **No dejar
el formato librado al Reactor** (mismo desvío que la paleta: "texto plano" sin ejemplo termina en
un dump de objeto o un JSON con otro nombre) — usar como referencia de nivel de detalle, no para
copiar palabra por palabra:

```
=== FONDO DE EMERGENCIA (piso $3.600.000, no techo) ===
Total acumulado: $X · Superávit: $Y (si aplica)
Desempleo: $A / $1.800.000 (Z%) — Fase: Acumulación
Accidentes físicos: $B / $720.000 (Z%) — Fase: Transición
Multas/imprevistos legales: $C / $540.000 (Z%) — Fase: ...
Otros: $D / $540.000 (Z%) — Fase: ...

=== PORTAFOLIO (Cocos Capital) ===
Valor total: $V · Composición: RF $R (X%) / Variable $W (Y%)
Bonar 2038 (USD): nominal $1.000, precio $950, TIR 8.2%, Dur. 5.3a, vto. 2038-07-09
AAPL (USD): 10u @ $230,5, valor $2.305

Foto armada: 2026-09-16 21:40
```

Usar `fmt()` para todos los montos, ARS y USD por igual — **no es un desvío, es el mismo
criterio que ya usa `index.html` en producción**: `renderHoldingCard()` llama `fmt(valor)` (con
`$`) para CUALQUIER holding sin importar su moneda, y lo que desambigua es el tag `(${h.moneda})`
pegado al nombre — nunca cambia el símbolo ni escribe "USD 1.000". El ejemplo de arriba ya sigue
ese patrón (`Bonar 2038 (USD): nominal $1.000...`). No inventar un formato nuevo tipo "USD 1.000"
— sería inconsistente con el dashboard real que Pedro ya usa a diario.

**Excepción — bloque extra SOLO para el Director/a de Oficina de Inversiones**: su responsabilidad
(spec sección 4, charter sección 3) es la regla de suavizado de aportes, así que necesita ver algo
que los otros 4 cargos no ven.

`calcularAporteSugerido()` (Tanda 3 de `index.html`) depende de otras dos funciones que NO están
en `directorio_zar_vanguard.html` — copiarlas literal LAS TRES JUNTAS, no solo la última, o el
Reactor va a improvisar un stub que devuelva 0 (mismo patrón de improvisación que ya rompió la
paleta en Tanda 1):

```js
const TASA_OBJETIVO = 0.10;
const BANDA_MIN = 0.10;
const BANDA_MAX = 0.15;
const VENTANA_MESES = 3;

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

async function calcularAporteSugerido(){
  const ingresoProm = await ingresoPromedioReciente();
  const objetivo = ingresoProm * TASA_OBJETIVO;
  const anterior = aporteMesAnterior();
  const base = anterior > 0 ? (0.8 * anterior + 0.2 * objetivo) : objetivo;
  const piso = ingresoProm * BANDA_MIN;
  const techo = ingresoProm * BANDA_MAX;
  const sugeridoTotal = Math.min(Math.max(base, piso), techo);
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

`aporteMesAnterior()`/`calcularAporteSugerido()` leen de `APORTES_LIVE`/`BUCKETS_LIVE`, ya
declarados en la sección 1. Al armar `RESUMEN_CARTERA`: poblar `BUCKETS_LIVE` con la lectura de
`pathBuckets()` que ya se hace, y `APORTES_LIVE` con una lectura `.once('value')` de
`pathAportes(bucketId)` por cada bucket de `ORDEN_BUCKETS` — recién ahí (y con `await`, la función
es `async`) llamar a `calcularAporteSugerido()`. Así las tres funciones quedan 100% literales, sin
tocar su lógica interna.

`ingresoPromedioReciente()` lee `ingresos/{UID_AUTORIZADO}/...` del mismo proyecto Firebase — si
las reglas de la base no dejan que este archivo (`directorio_zar_vanguard.html`) lea ese nodo,
`calcularAporteSugerido()` va a devolver 0 y el Director se queda sin nada que comentar (mismo
riesgo que ya quedó pendiente de revisar desde la Tanda 3, ahora más crítico). Si al probar la
vista el Director aparece con "$0 sugerido" de forma consistente, revisar las reglas de Firebase
antes de asumir que es un bug del prompt.

De todo esto, agregar a `RESUMEN_DIRECTOR_TEXTO` (bloque separado, concatenado ÚNICAMENTE al
system prompt del Director) SOLO `sugeridoTotal` y `porBucket` — nunca `ingresoProm`. **`ingresoProm`
(el ingreso promedio en sí) NO se serializa a texto ni se manda a la API en ningún bloque** — la
función lo calcula internamente para derivar `sugeridoTotal`, pero ese número intermedio se queda
en JavaScript. También agregar si el aporte real del bucket en el último mes (ya disponible en
`APORTES_LIVE` una vez poblado) quedó por encima, en línea o por debajo del sugerido — un dato
binario/relativo, no una cifra de ingreso.

**Para renta fija — misma decisión que la paleta**: `calcularValuacionRentaFija(h)` (Tanda 2 de
`index.html`, motor de TIR exacta por búsqueda binaria + Macaulay/Modified Duration + convexidad)
NO está en `directorio_zar_vanguard.html`, y como este prompt dice explícitamente que no hace
falta pegar `index.html` completo, el Reactor no la va a tener en contexto. Copiarla literal
(mismo criterio ya usado en Tanda 2 para el prompt del Portafolio, cero desvíos de lógica esa
vez) para que el resumen de holdings de renta fija muestre TIR/duración real, no solo campos
crudos — es justo lo que el lente Crecimiento quiere ver en una revisión:

```js
function calcularValuacionRentaFija(h){
  const nominal = Number(h.nominal) || 0;
  const precio  = Number(h.precio) || 0;
  const cuponAnual = Number(h.cuponAnual) || 0;
  const frecuencia = Number(h.frecuenciaCupon) || 1;
  const hoy = new Date();
  const venc = new Date(h.fechaVencimiento);
  const anios = Math.max((venc - hoy) / (1000*60*60*24*365.25), 0.01);
  const cuponPeriodo = (cuponAnual/100 * nominal) / frecuencia;
  const nPeriodos = anios * frecuencia;
  const ytmAprox = ((cuponPeriodo*frecuencia) + (nominal - precio)/anios) / ((nominal+precio)/2) * 100;
  function precioDado(ytmPeriodo){
    let vp = 0;
    for(let t=1;t<=nPeriodos;t++){ vp += cuponPeriodo / Math.pow(1+ytmPeriodo, t); }
    vp += nominal / Math.pow(1+ytmPeriodo, nPeriodos);
    return vp;
  }
  let lo = 0.00001, hi = 1;
  for(let i=0;i<100;i++){
    const mid = (lo+hi)/2;
    const p = precioDado(mid);
    if(p > precio) lo = mid; else hi = mid;
  }
  const ytmPeriodo = (lo+hi)/2;
  const ytmExacto = ytmPeriodo * frecuencia * 100;
  let sumaPonderada = 0;
  for(let t=1;t<=nPeriodos;t++){
    const flujo = (t === nPeriodos) ? cuponPeriodo + nominal : cuponPeriodo;
    sumaPonderada += (t/frecuencia) * flujo / Math.pow(1+ytmPeriodo, t);
  }
  const macaulay = sumaPonderada / precio;
  const modificada = macaulay / (1 + ytmPeriodo);
  let sumaConvexidad = 0;
  for(let t=1;t<=nPeriodos;t++){
    const flujo = (t === nPeriodos) ? cuponPeriodo + nominal : cuponPeriodo;
    sumaConvexidad += flujo * t * (t+1) / Math.pow(1+ytmPeriodo, t+2);
  }
  const convexidad = sumaConvexidad / (precio * Math.pow(frecuencia,2));
  const spread = h.refTasa != null ? (ytmExacto - Number(h.refTasa)) : null;
  return { ytmExacto, ytmAprox, macaulay, modificada, convexidad, spread, anios };
}
```

Llamarla SOLO para holdings `tipo === 'rentaFija'` que tengan los campos necesarios (nominal,
precio, cupón, frecuencia, vencimiento) — si falta alguno, mostrar los campos crudos sin llamar
la función (evita `NaN`/división por cero), nunca inventar una fórmula alternativa.

**También pegar literal `valorMercadoHolding()`** (index.html, misma sección) — sin ella no hay
valor total del Portafolio ni composición RF/variable, y el resumen del lente Crecimiento queda
sin el dato más básico:

```js
function valorMercadoHolding(h){
  if (h.tipo === 'variable'){
    return (parseFloat(h.cantidad)||0) * (parseFloat(h.precioUltimo)||0);
  }
  return parseFloat(h.precio) || 0;
}
```

Usarla para calcular, y agregar a `RESUMEN_CARTERA`: valor total del Portafolio, y composición
(monto y % en renta fija vs. variable) — mismo cálculo que `renderResumenPortafolio()` en
`index.html` (sumar `valorMercadoHolding(h)` por tipo sobre todos los holdings).

## 4. System prompts — extensión, no reemplazo, de los 5 ya existentes en 4a

Los 5 cargos (`CARGOS` array) ya existen con su `specific` de la Tanda 4a (modo teórico). Para
este modo, `buildSystemPrompt` necesita una segunda rama: cuando `modoRevision === true`, usar
un encabezado distinto (no `COMMON_PROMPT_BLOCK` de 4a) que:

1. Dice explícitamente: **"Estás en Modo Revisión de Cartera. SOLO podés hablar de los números
   que aparecen en RESUMEN_CARTERA_TEXTO abajo. Si Pedro pregunta algo que no está en ese
   resumen, decilo explícitamente en vez de inventar un número o generalizar con teoría."**
   (mitigación de "falsa confianza" ya documentada en el CHANGELOG del proyecto).
2. Prohíbe explícitamente lo mismo que ya prohíben los system prompts de 4a sobre ingresos:
   ningún cargo opina sobre el ingreso o productividad de Pedro, ni siquiera en este modo con
   datos reales — el resumen general NUNCA incluye ingresos, solo composición/desempeño de los
   activos ya asignados al fondo. (El Director tiene una excepción acotada, ver punto 6.)
3. Reusa el `specific` de cada cargo de la Tanda 4a como base de su ROL (qué mira cada uno),
   pero le agrega el peso pedagógico correcto para este modo: **la prioridad es cómo se
   INTERPRETA y COMUNICA el dato, no la corrección técnica del cálculo** (eso ya lo resuelve el
   dashboard antes de llegar acá) — nota de diseño de la 3ra ronda de DeepSeek en Tanda 4a,
   aplica directo a este modo.
4. Para el **Risk Officer específicamente**: agregar el ORSA simplificado en 4 preguntas del
   charter (sección 5) — "¿cuáles son los riesgos hoy?, ¿cambió algo desde la última revisión?,
   ¿la asignación real coincide con la fase del glide path?, ¿hace falta un plan de
   contingencia?". **El system prompt le instruye RESPONDER cada una de las 4 preguntas evaluando
   el `RESUMEN_CARTERA_TEXTO` dado, no enumerarlas como concepto teórico** — el resultado esperado
   es una lectura de riesgo aplicada a los datos de esta revisión puntual, no una explicación de
   qué es un ORSA. El charter ya dice que el Risk Officer corre esto **solo acá, nunca en modo
   educativo (4a)**; el system prompt de 4a del Risk Officer ya tiene una aclaración que se lo
   prohíbe ahí, así que la implementación es simétrica: acá se responde en serio, ahí queda
   prohibido incluso mencionarlo.
   **Pregunta 2 necesita una aclaración aparte**: no hay ninguna revisión anterior guardada (el
   export es un `.md` que se descarga, no se persiste en Firebase ni en `localStorage`), así que
   el Risk Officer no tiene con qué comparar. El system prompt debe decirle explícitamente: "No
   tenés acceso a ninguna revisión anterior. Para la pregunta 2, decilo así en vez de inventar que
   no hubo cambios." Sin esta línea, el default más probable es inventar "no cambió nada" — la
   misma falsa confianza que todo este modo está diseñado para evitar.
5. Todos siguen citando el charter igual que en 4a (`CHARTER_TEXT` ya cargado como constante,
   no reescribir el charter).
6. **Endurecimiento específico para el Director/a de Oficina de Inversiones** (más estricto que
   la prohibición genérica del punto 2, porque este cargo SÍ recibe `RESUMEN_DIRECTOR_TEXTO` con
   el aporte sugerido derivado del ingreso — sección 3): el system prompt del Director agrega un
   párrafo propio que prohíbe explícitamente (a) calificar el aporte sugerido como "bajo" o "alto"
   en relación a lo que Pedro "debería" ganar, (b) sacar conclusiones sobre su desempeño como
   trader/estudiante a partir del monto, (c) especular sobre ingresos futuros, y **(d) intentar
   inferir o mencionar el ingreso de Pedro a partir del aporte sugerido — con la fórmula completa
   de la regla en su propio system prompt y el monto sugerido a la vista, el ingreso es derivable
   en uno o dos pasos de álgebra, y esa inferencia está tan prohibida como si el número viniera
   directo del resumen. El aporte sugerido es un insumo para comentar la regla, no un canal para
   reconstruir el ingreso — si un comentario solo tiene sentido mencionando o dando a entender el
   nivel de ingreso, no lo hagas.** El comentario del Director se limita a: si el aporte real de
   cada bucket está en línea, por encima o por debajo del sugerido, y a la mecánica de la regla en
   sí (suavizado 80/20, banda, reparto proporcional a las metas) — nunca al ingreso que la originó,
   ni siquiera inferido. Esto es un nivel de restricción por encima del resto de los cargos en
   este modo, porque es el único con acceso a un número derivado del ingreso.

Mantener el tag único `[[NEXT_MODEL:x]]` y `modelRegex`/`modelMap`/`callClaudeRaw` EXACTAMENTE
como están en 4a — no crear una segunda función de llamada a la API para este modo.

## 5. Flujo de la vista `revisionView`

1. Botón "📊 Revisión de Cartera" en `selectorView` (junto a los 5 cargos) → pide login de
   Google si no hay sesión → si `user.uid !== UID_AUTORIZADO`, bloquear con el mismo mensaje que
   `index.html`.
2. Login OK → arma `RESUMEN_CARTERA` (sección 3) → lo muestra primero en una tabla/resumen
   visual simple (reusar clases CSS ya existentes tipo `.bucket-card`, no inventar un sistema de
   diseño nuevo) para que Pedro vea qué se va a mandar a la API antes de gastar tokens.
3. Botón "Generar comentarios del directorio" → dispara UNA llamada por cargo, **SECUENCIALES,
   no en paralelo** (5 llamadas una detrás de la otra — evita condiciones de carrera sobre el
   estado de la vista y hace fácil ver cuál de las 5 falló si `callClaudeRaw` devuelve `{error}`)
   con el system prompt de la sección 4 + un mensaje de usuario fijo tipo "Dame tu lectura de
   estos datos según tu rol." → cada respuesta se muestra en una card por cargo apenas llega,
   sin esperar a las 5 (nombre, comentario, o el error si falló esa llamada puntual).
4. Debajo de los 5 comentarios: **chat libre** — mismo motor de `enviarMensaje` de 4a, pero el
   selector ahora deja elegir CUALQUIERA de los 5 cargos para seguir preguntando sobre el mismo
   `RESUMEN_CARTERA_TEXTO` (que se mantiene fijo durante toda la sesión de revisión, no se
   refresca de Firebase en cada mensaje).
5. Botón "Exportar informe" — ver sección 6. NUNCA escribe nada de vuelta en Firebase (ni el
   resumen ni los comentarios ni el chat) — modo 100% lectura, igual que
   `renderAporteSugerido` en `index.html` que ya documenta esta misma regla en un comentario.

## 6. Exportar informe (distinto del export de 4a)

`exportarSesionMarkdown` de 4a exporta un log crudo de conversación. Este modo necesita un
**informe formal**, no un changelog — nueva función `exportarInformeRevision()` (no reemplaza
la de 4a, coexisten) que arma un markdown con esta estructura fija (spec sección 8):

1. Encabezado con fecha Y HORA exactas de la revisión (no solo la fecha), en letra visible al
   tope del documento — no al pie — con una línea aclarando que todo lo que sigue es una foto de
   ese momento puntual, no datos en vivo (importante porque el resumen no se refresca durante la
   sesión: si Pedro abre la revisión, se interrumpe, y sigue horas después, el resumen y el
   informe final siguen siendo los del momento en que se armaron).
2. Composición y desempeño (tabla de buckets + tabla de holdings, tal cual `RESUMEN_CARTERA`).
3. Comentario de cada uno de los 5 cargos (los generados en el paso 3 del flujo) — el cargo
   cuya llamada falló (`callClaudeRaw` devolvió `{error}`) se lista igual, con "— no generado
   (error de API)" en vez de omitirse en silencio.
4. Notas de la conversación libre (si hubo), en formato pregunta/respuesta.

Pensado como plantilla reusable para un futuro cliente real (spec sección 8) — texto claro,
sin jerga interna del proyecto, algo que en teoría se le podría mostrar a un tercero.

## 7. Qué NO hacer

- No tocar nada de la Tanda 4a (selector, chat, backup/restore, export de sesión, los 5
  `specific` de modo teórico) — solo agregar la rama `modoRevision` y la vista nueva.
- No agregar Chart.js ni gráficos nuevos en esta tanda — el spec pide texto/tablas para el
  informe, los charts ya están en `index.html` (Tanda 3).
- No guardar el historial de revisión en `localStorage` junto con el backup de 4a — son
  conceptualmente distintos (uno es teoría reusable entre sesiones, el otro es una foto puntual
  pensada para exportarse y listo). Si hace falta persistencia liviana, usar una key de
  `localStorage` separada, nunca mezclada con `backup_directorio_zar_vanguard`.
- No inventar una paleta de colores nueva — reusar las variables CSS ya definidas en el archivo
  (mismo desvío que ya se corrigió dos veces en este proyecto, Tanda 1 y Tanda 4a).
- **No agregar `localStorage` "por las dudas" para persistir los 5 comentarios o el chat libre de
  esta vista.** Es intencional que si Pedro cierra la pestaña a mitad de una revisión, esos datos
  se pierden — el mecanismo de persistencia de este modo es el export a informe (sección 6), no
  el navegador. Si el Reactor agrega una key nueva de `localStorage` para esto sin que se le pida,
  es un desvío de scope, igual que agregar Chart.js sin que se pida.

## 8. Checklist de QC para Cowork (no generar, solo referencia post-generación)

- [ ] `node --check` OK
- [ ] Diff contra `directorio_zar_vanguard.html` de 4a: selector/chat/backup/export de 4a
      intactos byte a byte salvo el botón nuevo agregado al selector
- [ ] Firebase: solo lectura, mismo UID_AUTORIZADO, mismo CLIENTE_ID, sin nodo nuevo inventado
- [ ] `faseGlidePath` idéntica a `index.html` (sin reescribir umbrales/colores)
- [ ] Ningún system prompt de este modo menciona ingresos/productividad de Pedro
- [ ] Risk Officer: ORSA de 4 preguntas presente SOLO en este modo, sigue ausente en el modo
      teórico de 4a
- [ ] Paleta: variables CSS existentes, cero valores hardcodeados nuevos
- [ ] Export de informe usa la estructura de la sección 6, no reusa `exportarSesionMarkdown` sin
      modificar
- [ ] `ingresoProm` no aparece en ningún string enviado a la API (ni en el resumen general ni en
      `RESUMEN_DIRECTOR_TEXTO`) — solo `sugeridoTotal`/`porBucket` derivados
- [ ] Solo el Director recibe `RESUMEN_DIRECTOR_TEXTO`; los otros 4 cargos no lo ven
- [ ] System prompt del Director tiene el párrafo de endurecimiento del punto 6 (sección 4),
      INCLUYENDO la cláusula anti-inferencia (d) — no solo las 3 prohibiciones originales
- [ ] Los 3 `<script>` de Firebase compat v10.7.1 están en el `<head>`
- [ ] `ingresoPromedioReciente()`, `aporteMesAnterior()` y `calcularAporteSugerido()` están las
      TRES pegadas literales (no solo la última) y `APORTES_LIVE`/`BUCKETS_LIVE` se poblaron con
      `.once('value')` antes de llamarlas
- [ ] `calcularValuacionRentaFija()` pegada literal; holdings de renta fija muestran TIR/duración
      real, no solo campos crudos, cuando tienen los campos necesarios
- [ ] Las 5 llamadas de "Generar comentarios" son secuenciales, no `Promise.all`/paralelo
- [ ] Risk Officer responde las 4 preguntas del ORSA aplicadas al resumen, no las enumera en
      abstracto
- [ ] Encabezado del informe exportado tiene fecha Y hora al tope, no solo al pie
- [ ] Ninguna key nueva de `localStorage` para persistir comentarios/chat de esta vista
- [ ] `let db = null, auth = null;` declarado; `fmt()` y `valorMercadoHolding()` pegadas literales
- [ ] `RESUMEN_CARTERA` incluye valor total del Portafolio y composición RF/variable (via
      `valorMercadoHolding`), no solo campos crudos por holding
- [ ] `RESUMEN_CARTERA_TEXTO` sigue el nivel de detalle del ejemplo de la sección 3 (no
      `[object Object]`, no JSON crudo con otro nombre)
- [ ] Risk Officer: pregunta 2 del ORSA responde "no tengo revisión anterior", nunca inventa
      "no hubo cambios"
- [ ] Informe exportado lista los cargos fallidos como "— no generado", no los omite

---
*Preparado por Claude Sonnet 5 — 2026-09-16, a partir de SPEC sección 8, CHARTER sección 5, y
el código real de `directorio_zar_vanguard.html` (Tanda 4a) e `index.html` (Tanda 1-3), a pedido
de Pedro. Pendiente antes de generar: pasar por DeepSeek (ver
`INSTRUCCIONES_chat_deepseek_tanda4b.md`).*
