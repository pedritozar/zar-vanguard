# PROMPT PARA EL REACTOR — ZAR Vanguard Capital Partners — Tanda 2
**Portafolio nuevo (Cocos Capital) + lógica de valuación de renta fija + extracción por visión**

Pegar este prompt en el Reactor junto con el `index.html` ACTUAL de ZAR Vanguard (el
de Tanda 1, ya con la paleta corregida y la API key de Firebase hardcodeada) como
contexto. **Esto EXTIENDE ese archivo, no lo reescribe.** El bloque de Fondo de
Emergencia (HTML, CSS, JS) tiene que quedar 100% intacto, byte a byte — no tocarlo,
no reordenarlo, no "mejorarlo" de paso.

---

## Alcance de esta tanda, nada más

- Nueva sección "Portafolio" dentro del MISMO dashboard (un tab nuevo al lado de
  "Fondo de Emergencia", no un archivo aparte).
- Alta de tenencias (renta fija y variable) por formulario manual.
- Alta de tenencias por extracción con visión desde una captura de pantalla de
  Cocos Capital (self-service, revisión humana obligatoria antes de guardar).
- Cálculo de YTM/duración/convexidad para renta fija, reusando la fórmula EXACTA
  de abajo (sección "Motor de valuación") — no reinventarla, no aproximarla
  distinto, no cambiar el método de búsqueda binaria por otro.

**Explícitamente NO construir en esta tanda:**
- Glide path — Tanda 3
- Regla de suavizado de aportes — Tanda 3
- Directorio de 5 cargos / tutor / Modo Revisión de Cartera — Tanda 4
- Integración automática con la cuenta de Cocos Capital (API/scraping) — v1 la
  descarta explícitamente, es manual + visión, no cambia en esta tanda

## Por qué "reusar sin reinventar" importa acá en particular

En la Tanda 1, el Reactor tuvo que copiar una paleta de colores de un archivo de
contexto pegado y en vez de leer los valores reales, generó una paleta propia con
los mismos NOMBRES de variable. Para que no pase lo mismo con matemática de bonos
(mucho más grave si sale mal — son cálculos financieros reales, con plata real),
esta vez el motor de valuación y el patrón de llamada a la API de Anthropic van
pegados LITERALES abajo, listos para copiar/adaptar tal cual — no hay que
extraerlos de ningún archivo de contexto adicional.

## Estructura de datos en Firebase (extiende la ya existente)

```
clientes/{clienteId}/vanguard/portafolio/holdings/{holdingId}
```

Cada holding es uno de dos tipos:

```js
// tipo 'rentaFija'
{
  tipo: 'rentaFija',
  nombre: 'Bonar 2038',           // string, lo que el usuario ponga
  moneda: 'USD',                   // moneda dura esperada, pero no forzar el valor
  nominal: 1000,                   // valor nominal TOTAL de la tenencia (no por unidad)
  cuponAnual: 7.5,                 // % anual
  frecuenciaCupon: 2,              // pagos por año
  precio: 950,                     // valor de mercado TOTAL actual de esa tenencia,
                                    // mismas unidades que nominal (no "por 100")
  fechaVencimiento: '2038-07-09',  // ISO, se usa para calcular años restantes en vivo
  refTasa: 4.5,                    // opcional, tasa de referencia para el spread
  fechaCompra: '2026-09-10',
  fechaUltimaActualizacionPrecio: '2026-09-15',
  notas: '',
  timestamp: <serverTimestamp>
}
// tipo 'variable'
{
  tipo: 'variable',
  nombre: 'AAPL',
  moneda: 'USD',
  cantidad: 10,
  precioUltimo: 230.5,             // precio por unidad
  fechaCompra: '2026-09-10',
  fechaUltimaActualizacionPrecio: '2026-09-15',
  notas: '',
  timestamp: <serverTimestamp>
}
```

`clienteId` es la MISMA constante `CLIENTE_ID` que ya existe en el archivo (no
crear una segunda). Sin sub-buckets (spec: "una sola cuenta, un solo perfil").

## Motor de valuación — COPIAR TAL CUAL (adaptado de renta_fija_tutor.html)

Esta es la función real que ya usa Pedro, verificada y en uso. Adaptarla de
"leer de inputs de un modal" a "leer de los campos de un holding guardado en
Firebase", pero el CÁLCULO no cambia ni un signo:

```js
function calcularValuacionRentaFija(h){
  // h = holding con tipo 'rentaFija'
  const nominal = Number(h.nominal) || 0;
  const precio  = Number(h.precio) || 0;
  const cuponAnual = Number(h.cuponAnual) || 0;
  const frecuencia = Number(h.frecuenciaCupon) || 1;
  const hoy = new Date();
  const venc = new Date(h.fechaVencimiento);
  const anios = Math.max((venc - hoy) / (1000*60*60*24*365.25), 0.01);

  const cuponPeriodo = (cuponAnual/100 * nominal) / frecuencia;
  const nPeriodos = anios * frecuencia;

  // YTM aproximado (fórmula rápida estándar)
  const ytmAprox = ((cuponPeriodo*frecuencia) + (nominal - precio)/anios) / ((nominal+precio)/2) * 100;

  // YTM exacto por búsqueda binaria sobre la tasa por período
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

  // Macaulay / Modified Duration
  let sumaPonderada = 0;
  for(let t=1;t<=nPeriodos;t++){
    const flujo = (t === nPeriodos) ? cuponPeriodo + nominal : cuponPeriodo;
    sumaPonderada += (t/frecuencia) * flujo / Math.pow(1+ytmPeriodo, t);
  }
  const macaulay = sumaPonderada / precio;
  const modificada = macaulay / (1 + ytmPeriodo);

  // Convexidad aproximada
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

Para tipo `variable`: `valorMercado = cantidad * precioUltimo`, sin ninguno de los
cálculos de arriba (no aplica).

## Extracción por visión — patrón EXACTO (adaptado de valuacion_tutor.html)

Mismo patrón BYOK que ya usa Pedro en sus tutores: API key de Anthropic propia,
guardada en `localStorage` bajo la clave `vanguardApiKey` (agregar un campo chico
en el header, ej. botón "🔑" que abre un input + botón guardar, mismo criterio
visual que el resto del header). Llamada a la API EXACTA:

```js
function fileToBase64(file){
  return new Promise((resolve, reject)=>{
    const reader = new FileReader();
    reader.onload = ()=> resolve(reader.result.split(',')[1]);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

async function extraerHoldingsDeCaptura(file){
  const apiKey = localStorage.getItem('vanguardApiKey') || '';
  if(!apiKey){ alert('Falta la API Key de Anthropic. Guardala primero con el botón 🔑.'); return; }
  const base64 = await fileToBase64(file);
  const mediaType = file.type && file.type.startsWith('image/') ? file.type : 'image/png';

  const systemPrompt = `Analizá esta captura de un estado de cuenta o posición de Cocos Capital.
Identificá cada instrumento financiero visible. Para cada uno, clasificalo como "rentaFija"
(bonos, ONs, letras) o "variable" (acciones, CEDEARs, ETFs). Extraé SOLO los campos que puedas
leer con precisión de la imagen -- si un campo no está legible o no aparece, ponelo en null,
NUNCA inventes un número. Devolvé ÚNICAMENTE un JSON válido, sin texto antes ni después, con
este esquema exacto:
{"holdings":[{"tipo":"rentaFija|variable","nombre":string|null,"moneda":string|null,
"nominal":number|null,"cuponAnual":number|null,"frecuenciaCupon":number|null,"precio":number|null,
"fechaVencimiento":"YYYY-MM-DD"|null,"cantidad":number|null,"precioUltimo":number|null}]}`;

  const messages = [{
    role:'user',
    content:[
      { type:'image', source:{ type:'base64', media_type: mediaType, data: base64 } },
      { type:'text', text:'Extraé las tenencias de esta captura según el esquema del system prompt.' }
    ]
  }];

  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method:'POST',
    headers:{
      'Content-Type':'application/json',
      'x-api-key': apiKey,
      'anthropic-version':'2023-06-01',
      'anthropic-dangerous-direct-browser-access':'true'
    },
    body: JSON.stringify({
      model: 'claude-sonnet-5', // fijo, visión siempre con Sonnet 5, sin selector
      max_tokens: 2000,
      system: systemPrompt,
      messages
    })
  });
  if(!res.ok){ throw new Error('HTTP '+res.status+': '+await res.text()); }
  const data = await res.json();
  const textBlock = (data.content||[]).find(b=>b.type==='text');
  if(!textBlock){ throw new Error('Respuesta sin contenido de texto.'); }
  return JSON.parse(textBlock.text); // { holdings: [...] }
}
```

**Flujo obligatorio tras la extracción:** los holdings detectados se muestran en
una lista de "staging" editable (un card por holding, mismos campos que el
formulario manual, precargados con lo que devolvió la API, cualquier `null`
queda vacío para completar a mano) — NUNCA se guardan solos en Firebase. Cada
card tiene "Guardar esta tenencia" y "Descartar" individual. Mismo espíritu que
ya documentó Pedro para sus otros tutores: la IA propone, la persona confirma.

## UI de esta tanda

- Tab bar nueva bajo el header: "Fondo de Emergencia" | "Portafolio" (toggle de
  visibilidad entre las dos secciones `.body`, mismo patrón simple, sin routing).
- Card resumen del Portafolio: valor total de mercado (suma de `precio` de renta
  fija + `cantidad*precioUltimo` de variable), y el % que representa cada tipo
  (para poder chequear a ojo que se mantiene el perfil defensivo — mayoría renta
  fija, porción menor variable — sin forzar ningún límite todavía, eso puede
  llegar en una tanda futura si Pedro lo pide).
- Botón "📷 Extraer de captura" (input file, acepta imagen) → llama a
  `extraerHoldingsDeCaptura` → muestra staging list como se describió arriba.
- Formulario manual "+ Tenencia" con selector tipo (rentaFija/variable) que
  muestra los campos correspondientes.
- Lista de holdings existentes, mismo componente visual `bucket-card` /
  `card` que ya existe — para renta fija, mostrar YTM exacto, Macaulay,
  Modified Duration, convexidad y spread (si hay `refTasa`) calculados con
  `calcularValuacionRentaFija()`; para variable, mostrar valor de mercado y
  ganancia/pérdida simple si hay precio de compra registrado.
- Cada holding editable (actualizar precio/precioUltimo con fecha, mismo patrón
  de edición puntual que ya usan los aportes del Fondo de Emergencia) y
  borrable.
- Reusar exactamente la paleta y los componentes visuales ya corregidos en el
  archivo (no reinventar estilos nuevos para esta sección).

## QC al recibir el resultado (recordatorio para la sesión de Cowork)

- `node --check` sobre el JS embebido completo (Tanda 1 + Tanda 2)
- Diff contra el archivo de Tanda 1: el bloque de Fondo de Emergencia debe
  quedar BYTE A BYTE intacto — cualquier cambio ahí es un desvío a reportar
- Verificar que `calcularValuacionRentaFija` es una copia fiel de la fórmula de
  arriba, no una reescritura "equivalente"
- Verificar que la llamada de visión fuerza `claude-sonnet-5` sin importar
  ningún selector de modelo que se agregue
- Confirmar que ningún holding se guarda en Firebase sin paso de confirmación
  manual (ni el extraído por visión ni ningún otro)
- Confirmar que el nodo `clientes/{clienteId}/vanguard/portafolio/holdings` no
  colisiona con `clientes/{clienteId}/vanguard/fondoEmergencia`

---
*Preparado por Claude Sonnet 5 — 15/09/2026, a partir del SPEC (sección 3) y de
la lectura directa de `renta_fija_tutor.html` (motor de valuación) y
`valuacion_tutor.html` (patrón de extracción por visión) en la carpeta
"Mundo corpo", a pedido de Pedro.*
