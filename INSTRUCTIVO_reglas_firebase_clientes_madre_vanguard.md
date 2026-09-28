# Instructivo para el chat que administra las reglas de Firebase (proyecto `zarfinance`)

Pegar esto en el chat/proyecto donde ya se sabe tocar la consola de Firebase del proyecto
`zarfinance` (Realtime Database → Rules) — no en el chat de ZAR Vanguard, a propósito: acá no se
toca infraestructura compartida, solo se diseña el módulo. Si ese chat tiene alguna skill de
workflow cargada (zar-finance-workflow u otra), que la use como siempre.

---

## Objetivo

Extender (o corregir) las reglas de seguridad de la Realtime Database para que cubran DOS nodos
de cliente bajo `clientes/{clienteId}/vanguard/...`: el que ya existe (`pedro`) y uno nuevo que se
va a sumar (`madre`). Sin este fix, el nodo nuevo va a fallar exactamente igual que el viejo —no
es preventivo, ya está confirmado que el patrón actual de reglas no cubre este tipo de path.

## Contexto — por qué se pide esto

**El bug ya está documentado y confirmado, no es una sospecha.** El 17/09/2026, al probar por
primera vez el Modo Revisión de Cartera de ZAR Vanguard con la carpeta conectada, Firebase tiró
`permission_denied at /clientes/pedro/vanguard/fondoEmergencia/buckets`. Diagnóstico confirmado en
ese momento: no es falta de datos (eso daría `{}` vacío, no `permission_denied`) ni un bug de
código — las reglas de Realtime Database del proyecto `zarfinance` usan el patrón estándar del
resto de ZAR Finance/Tactical Ledger, con el UID como clave (`$uid`). Pero el path de Vanguard usa
`clienteId` ("pedro") en esa posición, que NO es un UID — la regla vieja no lo cubre, y Firebase
deniega por default lo que no está explícito. Nadie verificó las reglas de la consola cuando se
generó ese nodo — el QC de esa etapa verificó estructura de datos, no reglas de seguridad.

**Por qué ahora es urgente y no solo teórico:** se está diseñando un módulo nuevo dentro de ZAR
Vanguard ("Supervisión de Gestor Externo" — cartera propia y de la madre de Pedro en el bróker
Alfy Inversiones), que agrega un SEGUNDO nodo cliente: `clientes/madre/vanguard/...`, además del
ya existente `clientes/pedro/vanguard/...`. Apenas ese módulo intente leer o escribir ahí, va a
pegar el mismo `permission_denied` — es el mismo bug, un cliente más.

**Detalle importante que cambia el fix respecto al patrón habitual:** aunque el path nuevo usa
`clienteId = 'madre'`, el LOGIN sigue siendo el de Pedro — no hay una cuenta de Google separada
para la madre, él administra esa cartera con su propio usuario. Entonces la regla para
`clientes/madre/vanguard` tiene que autorizar el MISMO `auth.uid` de Pedro, no un UID distinto.

## Qué se necesita del lado de Firebase

1. Pedro (o quien opere la consola en este chat) pega acá el JSON completo y actual de
   Realtime Database → Rules del proyecto `zarfinance`, tal cual está hoy — no asumir cómo está
   estructurado, confirmarlo primero (mismo criterio que la vez pasada: no aplicar un bloque a
   ciegas sin ver las reglas reales).
2. Con eso a la vista, proponer el merge exacto. El borrador que ya se había armado el 17/09
   (para pedro solamente) era este — **a confirmar contra las reglas reales antes de publicar,
   no copiar tal cual**:

```json
"clientes": {
  "pedro": { "vanguard": {
    ".read": "auth != null && auth.uid === 'JsW7CjDObEhn3DoFkwzuJUGLhrB3'",
    ".write": "auth != null && auth.uid === 'JsW7CjDObEhn3DoFkwzuJUGLhrB3'"
  }},
  "madre": { "vanguard": {
    ".read": "auth != null && auth.uid === 'JsW7CjDObEhn3DoFkwzuJUGLhrB3'",
    ".write": "auth != null && auth.uid === 'JsW7CjDObEhn3DoFkwzuJUGLhrB3'"
  }}
}
```

   (mismo UID en los dos bloques, a propósito — es el mismo Pedro logueado administrando las dos
   carteras).

3. Confirmar que el merge no pisa ni rompe ninguna regla existente de ZAR Finance o Tactical
   Ledger que ya funciona hoy (mismo proyecto Firebase, reglas compartidas).

## Reglas duras — no negociables

1. Este chat toca **solo la consola de Firebase** (Realtime Database → Rules). No tocar
   `index.html` ni `directorio_zar_vanguard.html` de ZAR Vanguard — eso se queda en el chat de
   Vanguard.
2. No inventar ni asumir el JSON de reglas actual — pedirlo y leerlo antes de proponer el merge.
3. Nada de esto se publica solo — como siempre, confirmar con Pedro antes de aplicar el cambio en
   la consola real.

## Cuando esté resuelto

Avisar en el chat de ZAR Vanguard que la regla quedó publicada y confirmada (idealmente con el
JSON final pegado ahí para que quede en el CHANGELOG del proyecto). Eso desbloquea dos cosas a la
vez: poder probar en vivo el Modo Revisión de Cartera (Tanda 4b, pendiente desde el 17/09) y poder
probar Fase 1 del módulo nuevo de Supervisión apenas esté generado.


---

## Nota agregada por Claude (Cowork, chat de ZAR Vanguard) — 2026-09-28

Antes de mandar este instructivo a cualquier lado, hay una contradicción que conviene resolver:
el documento arma toda su urgencia sobre la base de que el `permission_denied` del 17/09 es "un
bug confirmado, no una sospecha", causado por que las reglas actuales solo cubren `$uid` y no
`clienteId`. Pero el 27-28/09, en el chat de ZAR Vanguard, se probó en vivo exactamente ese mismo
path (`clientes/pedro/vanguard/fondoEmergencia/buckets`, vía Modo Revisión de Cartera) y leyó sin
ningún error, sin que nadie tocara una regla de Firebase entre medio -- solo se corrigió el hábito
de abrir los `.html` por el launcher (`http://localhost`) en vez de `file://`.

Dos lecturas posibles, sin resolver todavía:
1. El diagnóstico del 17/09 estaba mal -- el `permission_denied` de ese día pudo haber sido un
   efecto secundario del entorno roto de `file://` (sesión de auth inconsistente), no un gap real
   en las reglas. Si es así, este instructivo puede no hacer falta.
2. Hay algo intermitente que todavía no se entiende (¿la regla real ya es permisiva por `auth.uid`
   sin importar la clave `clienteId`, y por eso "pedro" lee bien pese a no estar nombrado
   explícito?).

**Antes de pegar esto en el chat que administra la consola de Firebase**, conviene una prueba
barata para desambiguar: intentar leer `clientes/madre/vanguard/...` (path sin datos todavía) y
ver si también lee sin error (te daría `null`/vacío, no `permission_denied`) o si ahí sí tira el
error. Si lee bien, la lectura 2 es la correcta y el fix de reglas puede no ser necesario. Si tira
`permission_denied`, el diagnóstico original del documento es correcto y vale la pena mandarlo tal
cual.

No se modificó nada del contenido original de arriba -- esta nota es solo un dato adicional para
quien lo lea después.
