# Mensaje de arranque para el chat nuevo de DeepSeek — ZAR Vanguard Capital Partners

Pegar esto como primer mensaje, junto con la carpeta completa `ZAR vanguard`
adjunta (SPEC, CHANGELOG, los `PROMPT_tanda*.md`, `index.html`, y las
auditorías de `reactor IA/` si las adjuntás también).

---

Buenas. Este chat es para dar una segunda opinión sobre "ZAR Vanguard Capital
Partners", un fondo personal con plata real que estoy armando (Fondo de
Emergencia con sub-buckets + un Portafolio en el bróker Cocos Capital).

**Contexto rápido**: el código lo genera una herramienta propia mía ("Reactor
Nuclear IA", BYOK contra la API de Anthropic) a partir de prompts que arma
Claude en otra sesión (Cowork). Esa misma sesión de Cowork ya hace el control
de calidad técnico — sintaxis, balance de tags, diff byte a byte contra la
versión anterior — y viene saliendo limpio en las tandas generadas hasta
ahora. Así que **no necesito que revises sintaxis de código ni nombres de
API/modelos** — para eso ya tengo el otro control, y la última vez que te
usé me diste nombres de modelo desactualizados, así que en esa parte no sos
la fuente más confiable.

**Lo que sí quiero de vos**: una lectura crítica de las partes de DISEÑO/
CRITERIO, no de sintaxis. Concretamente:

1. Leé el `SPEC_zar_vanguard_capital_partners.md` completo primero —ahí está
   el diseño de fondo (4 lentes de J.P. Morgan, sub-buckets con glide path,
   directorio de 5 cargos estilo family office + Yale, regla de suavizado de
   aportes).
2. Cuando te pase los 5 system prompts del directorio (Tanda 4), decime si
   alguno se puede ir de tema — el riesgo específico que me preocupa es que
   un cargo termine opinando sobre cosas fuera de su scope (ej. que el CFO
   o el Risk Officer terminen comentando sobre cuánto gano o mi
   productividad como trader, en vez de quedarse en gestión de los activos
   ya asignados al fondo). Marcame cualquier system prompt donde el límite
   de alcance no quede lo suficientemente claro o donde el "tono mentor
   exigente" se pueda malinterpretar como el board juzgándome a mí en vez
   de a la cartera.
3. Si ves inconsistencias entre lo que dice el SPEC y lo que terminó
   implementado (comparando contra `index.html` o contra los PROMPT_tanda*.md
   ya ejecutados), marcalas.
4. Preguntas puntuales, no una auditoría genérica: te voy a pasar un prompt
   o un system prompt específico por vez con una pregunta concreta (tipo
   "¿este system prompt se queda ceñido a los datos que le doy, o se puede
   ir por las ramas?"), no "revisá todo el proyecto".

Avisame cuando terminaste de leer la carpeta y quedamos listos para arrancar.
