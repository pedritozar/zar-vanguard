# Instructivo para el chat exclusivo de ZAR Finance — conectar en vivo la card de "Fondo de Emergencia"

Pegar esto como mensaje en el chat/proyecto dedicado a ZAR Finance (no en este de ZAR Vanguard —
son proyectos separados a propósito). Si ese chat tiene cargada la skill `zar-finance-workflow`,
que la use como siempre (research antes de construir, preguntar antes de asumir, editar con
`device_bash`, verificar con `node --check`, commit local sin pushear nunca).

---

## Objetivo

En `index.html` de ZAR Finance, pestaña Inversiones, hay una card estática de "Fondo de
Emergencia" que hoy siempre muestra:

```
$0
Meta: $3.600.000
⚠️ No iniciado — pendiente abrir Alyc renta fija
```

Ese texto está hardcodeado — nunca leyó de Firebase. Ahora existe un proyecto separado ("ZAR
Vanguard Capital Partners") que sí guarda datos reales del Fondo de Emergencia en el mismo
proyecto Firebase que usa ZAR Finance (`zarfinance`), bajo un nodo propio. La tarea es conectar
esa card en vivo a ese nodo, **sin tocar nada de la lógica de Vanguard, solo lectura**.

## Paso 0 — antes de tocar nada

Localizar en `index.html` de ZAR Finance el bloque exacto de esa card (buscar por el texto "No
iniciado" o "Alyc renta fija") y pegarlo tal cual acá antes de editar nada — confirmar la
estructura real (ids, clases, si ya está dentro de algún `bindFirebaseListeners()` existente)
antes de asumir cómo integrarlo.

## Datos reales del nodo de Vanguard (pegar literal, no reinventar)

Mismo proyecto Firebase que ya usa ZAR Finance (mismo login de Google, mismo patrón
`auth.uid == uid`), así que la config de Firebase NO hace falta agregarla de nuevo — ya existe en
`index.html` de ZAR Finance. Solo hace falta el path nuevo:

```js
const CLIENTE_ID = 'pedro';               // fijo por ahora, no hay multi-cliente todavía
const ORDEN_BUCKETS = ['desempleo','accidentesFisicos','multasLegales','otros'];
const META_TOTAL_FONDO_EMERGENCIA = 3600000; // ARS, PISO no techo (ver nota de mensaje más abajo)

function pathBuckets(){ return `clientes/${CLIENTE_ID}/vanguard/fondoEmergencia/buckets`; }
function pathAportes(bucketId){ return `${pathBuckets()}/${bucketId}/aportes`; }
```

Estructura real de los datos en Firebase (para que quede claro qué se está leyendo):
- `clientes/pedro/vanguard/fondoEmergencia/buckets/{bucketId}` → objeto con `metaARS` (número).
- `clientes/pedro/vanguard/fondoEmergencia/buckets/{bucketId}/aportes/{aporteId}` → cada aporte
  tiene un campo `monto` (número, ARS). El acumulado de un bucket es la SUMA de todos sus
  aportes, no un campo único guardado aparte.

Lógica exacta para calcular el total acumulado del fondo completo (copiada literal de
`armarResumenCartera()` en `directorio_zar_vanguard.html`, adaptada a lectura en vivo en vez de
foto puntual — acá conviene `.on('value')`, no `.once('value')`, porque es una card que el
usuario puede tener abierta un rato, igual que el resto del dashboard de ZAR Finance):

```js
// Un listener por bucket. Cuando cualquiera cambia, recalcula el total y repinta la card.
let APORTES_FONDO_VANGUARD = {}; // { bucketId: montoAcumuladoDeEseBucket }

function iniciarListenerFondoEmergenciaVanguard(){
  ORDEN_BUCKETS.forEach(bucketId=>{
    db.ref(pathAportes(bucketId)).on('value', snap=>{
      const aportes = snap.val() || {};
      APORTES_FONDO_VANGUARD[bucketId] = Object.values(aportes).reduce((s,a)=> s + (Number(a.monto)||0), 0);
      renderCardFondoEmergencia();
    });
  });
}

function renderCardFondoEmergencia(){
  const total = Object.values(APORTES_FONDO_VANGUARD).reduce((s,v)=> s+v, 0);
  // usar acá el formateador de moneda QUE YA EXISTE en index.html de ZAR Finance
  // (no copiar el fmt() de Vanguard — reusar el propio para no tener dos formateadores
  // de plata distintos en el mismo dashboard)
  // ... actualizar el DOM de la card con `total` y el estado (ver mensaje abajo) ...
}
```

## Mensaje de estado (consistencia con Vanguard — "piso, no techo")

Vanguard ya resolvió esta tensión y usa este texto exacto (ver `index.html` de Vanguard,
`res-nota`) — reusar el mismo criterio acá para que las dos pantallas cuenten la misma historia
con las mismas palabras:

- Si `total === 0`: mantener algo equivalente a "No iniciado" (el texto actual de "pendiente
  abrir Alyc renta fija" lo decide el chat de ZAR Finance según si ese dato sigue siendo cierto
  hoy — a chequear con Pedro si ya abrió la cuenta).
- Si `total > 0` y `total < META_TOTAL_FONDO_EMERGENCIA`: mostrar progreso hacia la meta (ej.
  "Faltan $X para completar el piso del fondo").
- Si `total >= META_TOTAL_FONDO_EMERGENCIA`: **"🏆 Piso del Fondo de Emergencia cubierto — es un
  mínimo, no un techo: el excedente sigue sumando como colchón."** (texto literal, ya validado
  este mismo texto en Vanguard — no reformular).

## Reglas duras — no negociables

1. **Solo lectura.** Ningún `.set()`, `.push()`, `.update()` ni `.remove()` sobre
   `clientes/pedro/vanguard/...` desde el código de ZAR Finance. Esa rama de datos es propiedad
   de Vanguard — ZAR Finance solo la mira.
2. **No duplicar el cálculo del glide path, fases, ni nada del resto de Vanguard** — esta card
   solo necesita el total acumulado y la meta, nada más. Si en el futuro se quiere mostrar el
   desglose por bucket acá también, es una tarea aparte a decidir con Pedro, no incluirla ahora
   por iniciativa propia.
3. **No tocar la config de Firebase existente** (`FB_CFG`, reglas de auth) — ya está bien como
   está, comparte proyecto con Vanguard sin que haga falta ningún cambio de permisos.
4. Verificar con `node --check` (extraer el `<script>` a `.js` temporal si hace falta, igual que
   siempre), commitear local, **nunca pushear** — eso lo hace Pedro desde su Terminal.

## Cuando esté listo

Avisá acá en este chat (ZAR Vanguard) cuando esté instalado y corriendo — lo miramos juntos vía
capturas para confirmar que el total que muestra ZAR Finance coincide exactamente con lo que
arma `armarResumenCartera()` del lado de Vanguard antes de darlo por cerrado.
