# Auditoría de rendimiento después de la migración a Zig 0.17

## Resultado de la implementación y benchmark

Las mejoras de getters, calendario, normalización, setters horarios, formato
localizado, despacho del parser y reutilización POSIX ya están implementadas.
Las firmas públicas se conservan; ZDate mantiene sus 8 bytes. Las APIs opcionales
hacia buffer/writer y los hallazgos de corrección independientes quedan pendientes.

Validación: 310/310 tests en debug, safe, fast y small; documentación generada.
Se añadieron seis pruebas diferenciales contra la copia anterior, con 292194 días
consecutivos en ciclos gregorianos, 20000 timestamps aleatorios, overflow,
145 locales, reglas POSIX, DST y consultas concurrentes.

Benchmark: Zig 0.17.0 fast, Linux x86_64, CPU 0; tres procesos con siete pares
alternados por caso. Son 21 muestras por versión/caso, 33 casos y 693 pares,
con checksums iguales en todos los pares. Se preservó la versión migrada anterior
a optimizar en [baseline-zig-0.17.tar.gz](benchmarks/baseline-zig-0.17.tar.gz).

| API / escenario | Anterior ns/op | Nuevo ns/op | Aceleración |
|---|---:|---:|---:|
| getUTCDay | 36.7 | 5.9 | 6.22× |
| getUTCHours | 28.3 | 5.1 | 5.57× |
| getUTCMilliseconds | 28.5 | 3.0 | 9.37× |
| timestampToComponents | 29.9 | 16.3 | 1.84× |
| componentsToTimestamp | 18.5 | 8.4 | 2.22× |
| normalizeComponents | 34.3 | 16.5 | 2.08× |
| setUTCHours | 48.1 | 10.5 | 4.59× |
| toLocaleString, en, 2000–2030 | 398.9 | 191.2 | 2.09× |
| toLocaleStringStyle(.long), es | 388.0 | 198.9 | 1.95× |
| parse ISO | 45.4 | 32.0 | 1.42× |
| getTimezoneOffset, 2000–2030 | 29.5 | 29.0 | 1.02× |
| getTimezoneOffset, año 2200 | 202.6 | 15.9 | 12.76× |
| getTimezoneOffset, años aleatorios futuros | 209.1 | 154.3 | 1.36× |

En la muestra medida, toLocaleString y su estilo largo pasaron de **7 a 1
asignaciones**, y toLocaleTimeString de 2 a 1. La consulta histórica de offset es
prácticamente neutral; su 1.02× está dentro de la dispersión observada. El resto
presenta ganancias en estas entradas. La mejora grande del footer POSIX depende
de reutilizar años; en años aleatorios la aceleración del conjunto es 1.36×.

Recomendación: conservar los cambios de cálculo y formato. Conservar también la
caché acotada si se consultan fechas posteriores a la tabla histórica, sin
extrapolar sus 12.76× a todos los timestamps. Cada medida compara el conjunto
de cambios; no es una ablación para atribuir la ganancia a una sola modificación.
Los tiempos incluyen el harness y el consumo del resultado, no solo el cuerpo
puro de una función; no constituyen una mejora global de una aplicación.

[Resultados completos y dispersión](benchmarks/results-fast.md),
[muestras crudas CSV](benchmarks/results-fast.csv) y
[metadatos/hash JSON](benchmarks/results-fast.json).
Repetir: `python3 scripts/benchmark.py --runs 3 --mode fast`.

## Auditoría previa (histórico)

Las tablas siguientes conservan el análisis previo; sus números de línea y las
referencias a propuestas corresponden al código antes de optimizar.


Fecha: 2026-10-12. Compilador: Zig 0.17.0. Host de validación: Linux x86_64.

Se revisaron las **155 funciones declaradas `pub fn`** de `src/`, incluidas
las 78 funciones de ZDate y los auxiliares que implementan esas APIs.
Validación: `zig build test` y los modos `safe`, `fast` y `small` pasaron
los 304 tests en cada ejecución. `zig build docs` también completó correctamente.
No se ejecutaron pruebas nativas en Windows/macOS.

107 funciones son accesibles desde el módulo raíz (ZDate, CalendarUtil,
TimezoneUtil, Timezone, PosixTz, zones y windows_zones); las otras 48 son
implementaciones auxiliares declaradas públicas dentro de sus archivos.
Las constantes, locales y registros sin funciones no se cuentan como funciones.

El análisis es estático: se inspeccionaron cuerpos, rutas compartidas, bucles,
asignaciones y dependencias de zona horaria. **No se midieron tiempos ni se
prometen porcentajes de aceleración.** El compilador puede eliminar trabajo
innecesario en modos optimizados; los candidatos deben confirmarse con
benchmarks representativos antes de sustituir algoritmos. La migración conserva
las firmas y los algoritmos actuales; las optimizaciones siguientes son propuestas.

Dificultad: 1 = cambio local sencillo; 10 = rediseño con alta complejidad de
validación. Incluye pruebas de corrección, no solo líneas de código.
P1 = medir primero por trabajo redundante visible; P2 = candidato compartido o
condicionado al uso; Opcional = mejora de API o prioridad baja; Conservar = sin
cambio de rendimiento recomendado. «—» significa que no se propone una mejora.
Las dificultades de wrappers corresponden al cambio compartido del que se beneficiarían.

## Orden recomendado

1. Getters de día semanal y campos horarios: aritmética directa, especialmente UTC.
2. toLocaleString/toLocaleStringStyle: una conversión y una salida final.
3. PosixTz.offsetAtUtc: reutilización de transiciones para fechas fuera de la tabla histórica.
4. Tabla de días acumulados por mes y conversión gregoriana compartida.
5. Setters horarios, despacho del parser y APIs de formato hacia buffer/writer,
   únicamente si el perfil de uso muestra que son importantes.

## Validación requerida para futuras optimizaciones

- Medir con `-Doptimize=fast`, entradas variables y checksum consumido para evitar
  eliminación/hoisting del trabajo; comparar también `safe` cuando sea el modo de producción.
- Separar UTC, local sin zona, zona fija, tabla histórica y footer POSIX; incluir
  fechas ordenadas y aleatorias, fechas BCE y extremos ±8.64e15.
- Para getters, comparar consultas individuales y varios campos del mismo instante.
- Para formato, contar asignaciones además del tiempo; probar numeric/long, años
  expandidos, 12/24 h, locales multibyte y patrones/etiquetas personalizados largos.
- Mantener las suites de overflow, V8, test262, locales y DST; reforzar propiedades
  de round-trip y los gaps/folds antes de cambiar calendario o resolución local.
- Mantener ZDate como valor de 8 bytes. La escritura pública de timestamp y el
  cambio de zona global dificultan una cache implícita dentro de ZDate.
- No introducir carreras: la zona se configura al inicio antes del uso concurrente;
  una cache de consultas necesita un diseño explícito para concurrencia.

## Hallazgos de corrección independientes del rendimiento

Estos hallazgos proceden de la lectura del código, no de fallos de la suite actual;
no se modificaron como parte de la migración.

- addSeconds/addMinutes/addHours/addDays multiplican i64 antes de comprobar la
  suma. Valores extremos pueden desbordar ese producto (panic en debug/safe o
  comportamiento no definido en fast). Propuesta: @mulWithOverflow y
  TimestampOverflow; dificultad 2/10.
- toString/toTimeString imprimen GMT+0000 aunque los componentes sean locales con
  zona no UTC. El offset del texto debe corresponder al instante; dificultad 3/10.
- Los setters de componentes comprueban solo el sentinel, mientras el campo
  timestamp es público. Una escritura directa fuera de rango puede alcanzar
  conversiones sin el guard completo de getters/formatters; dificultad 4/10.

## Inventario por función


### src/arithmetic.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [ArithmeticMethods.addMilliseconds](src/arithmetic.zig#L13) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.addSeconds](src/arithmetic.zig#L31) | Conservar | — | Escalado y suma O(1), sin asignaciones. Revisar overflow del escalado como corrección, no como optimización. |
| [ArithmeticMethods.addMinutes](src/arithmetic.zig#L37) | Conservar | — | Escalado y suma O(1), sin asignaciones. Revisar overflow del escalado como corrección, no como optimización. |
| [ArithmeticMethods.addHours](src/arithmetic.zig#L43) | Conservar | — | Escalado y suma O(1), sin asignaciones. Revisar overflow del escalado como corrección, no como optimización. |
| [ArithmeticMethods.addDays](src/arithmetic.zig#L49) | Conservar | — | Escalado y suma O(1), sin asignaciones. Revisar overflow del escalado como corrección, no como optimización. |
| [ArithmeticMethods.diffMilliseconds](src/arithmetic.zig#L56) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.diffSeconds](src/arithmetic.zig#L64) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.diffMinutes](src/arithmetic.zig#L70) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.diffHours](src/arithmetic.zig#L76) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.diffDays](src/arithmetic.zig#L82) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.compare](src/arithmetic.zig#L90) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.before](src/arithmetic.zig#L105) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.after](src/arithmetic.zig#L113) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ArithmeticMethods.equals](src/arithmetic.zig#L123) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |

### src/calendar.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [CalendarUtil.isInvalidTimestamp](src/calendar.zig#L32) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [CalendarUtil.isLeapYear](src/calendar.zig#L39) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [CalendarUtil.getDaysInMonth](src/calendar.zig#L56) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [CalendarUtil.getDayOfWeek](src/calendar.zig#L78) | P2 | 3 | Reemplazar la suma de meses por una tabla de días acumulados y el ajuste bisiesto; definir/preservar el contrato para meses fuera de rango. |
| [CalendarUtil.getDayOfYear](src/calendar.zig#L92) | P2 | 3 | Reemplazar la suma de meses por una tabla de días acumulados y el ajuste bisiesto; definir/preservar el contrato para meses fuera de rango. |
| [CalendarUtil.timestampToComponents](src/calendar.zig#L104) | P2 | 7 | Evaluar conversión gregoriana cerrada por ciclos de 400 años; eliminar ajuste del año/búsqueda mensual tras medir. Validar BCE y extremos. |
| [CalendarUtil.componentsToTimestamp](src/calendar.zig#L181) | P2 | 3 | Reemplazar la suma de meses por una tabla de días acumulados y el ajuste bisiesto; definir/preservar el contrato para meses fuera de rango. |
| [CalendarUtil.validateComponents](src/calendar.zig#L233) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [CalendarUtil.normalizeComponents](src/calendar.zig#L280) | Opcional | 7 | Ya evita bucles proporcionales al overflow. Mejorar solo su conversión gregoriana y suma de meses; mantener el fast path de campos válidos. |

### src/formatting.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [FormattingMethods.toISOString](src/formatting.zig#L71) | Opcional | 4 | La salida válida ya asigna una vez. Una API adicional hacia buffer/writer permitiría serialización sin heap; JSON hereda ISO. |
| [FormattingMethods.toDateString](src/formatting.zig#L167) | P2 | 3 | Evitar el segundo recorrido del calendario para el día semanal; conservar una sola asignación de salida. GMT hereda UTC. |
| [FormattingMethods.toTimeString](src/formatting.zig#L192) | P1 | 3 | Extraer solo hora/minuto/segundo después de aplicar la zona; no necesita año ni mes. |
| [FormattingMethods.toString](src/formatting.zig#L211) | P2 | 3 | Evitar el segundo recorrido del calendario para el día semanal; conservar una sola asignación de salida. GMT hereda UTC. |
| [FormattingMethods.toUTCString](src/formatting.zig#L238) | P2 | 3 | Evitar el segundo recorrido del calendario para el día semanal; conservar una sola asignación de salida. GMT hereda UTC. |
| [FormattingMethods.toGMTString](src/formatting.zig#L268) | P2 | 3 | Evitar el segundo recorrido del calendario para el día semanal; conservar una sola asignación de salida. GMT hereda UTC. |
| [FormattingMethods.toJSON](src/formatting.zig#L275) | Opcional | 4 | La salida válida ya asigna una vez. Una API adicional hacia buffer/writer permitiría serialización sin heap; JSON hereda ISO. |
| [FormattingMethods.toLocaleDateStringStyle](src/formatting.zig#L336) | P2 | 5 | En estilo largo, evitar crecimiento incremental de ArrayList mediante medición y reserva exacta o writer; respetar patrones/strings arbitrarios. |
| [FormattingMethods.toLocaleStringStyle](src/formatting.zig#L350) | P1 | 6 | Unificar conversión y salida, incluido el patrón largo; eliminar las cadenas temporales de fecha y hora. |
| [FormattingMethods.toLocaleDateString](src/formatting.zig#L365) | P2 | 7 | Mejora indirecta del calendario; la salida numérica ya realiza una asignación. |
| [FormattingMethods.toLocaleTimeString](src/formatting.zig#L388) | P1 | 3 | Extraer solo hora/minuto/segundo después de aplicar la zona; no necesita año ni mes. |
| [FormattingMethods.toLocaleString](src/formatting.zig#L415) | P1 | 5 | Descomponer una vez y renderizar fecha/hora en un solo resultado: actualmente usa dos conversiones y tres cadenas asignadas. |

### src/getters.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [GetterMethods.getFullYear](src/getters.zig#L15) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [GetterMethods.getMonth](src/getters.zig#L26) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [GetterMethods.getDate](src/getters.zig#L36) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [GetterMethods.getDay](src/getters.zig#L46) | P1 | 2 | Calcular el día semanal directamente con @divFloor del timestamp ajustado y @mod(días + 4, 7); evitar la conversión de año/mes/día. |
| [GetterMethods.getHours](src/getters.zig#L56) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [GetterMethods.getMinutes](src/getters.zig#L66) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [GetterMethods.getSeconds](src/getters.zig#L76) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [GetterMethods.getMilliseconds](src/getters.zig#L86) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [GetterMethods.getTime](src/getters.zig#L96) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [GetterMethods.getYear](src/getters.zig#L103) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [GetterMethods.getTimezoneOffset](src/getters.zig#L112) | P2 | 7 | Mejora indirecta de Timezone.offsetAtUtc/PosixTz.offsetAtUtc; su coste depende de la ruta histórica o POSIX, aunque el wrapper sea mínimo. |

### src/parsing.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [ParsingMethods.parseISO8601](src/parsing.zig#L40) | Conservar | — | Parser posicional sin heap; optimizar el calendario compartido antes de añadir un fast path ISO sin evidencia. |
| [ParsingMethods.parse](src/parsing.zig#L174) | P2 | 4 | Compartir trim y clasificar formatos antes de los intentos sucesivos; conservar el fallback legacy y la interpretación UTC/local. |

### src/setters.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [SetterMethods.setFullYear](src/setters.zig#L25) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [SetterMethods.setMonth](src/setters.zig#L58) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [SetterMethods.setDate](src/setters.zig#L78) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [SetterMethods.setHours](src/setters.zig#L96) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [SetterMethods.setMinutes](src/setters.zig#L120) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [SetterMethods.setSeconds](src/setters.zig#L142) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [SetterMethods.setMilliseconds](src/setters.zig#L162) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [SetterMethods.setTime](src/setters.zig#L180) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [SetterMethods.setYear](src/setters.zig#L195) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |

### src/timezone.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [TimezoneUtil.loadSystemTimezone](src/timezone.zig#L29) | Conservar | — | Configuración/liberación al inicio o comprobación simple; no hay trabajo repetido relevante que eliminar. |
| [TimezoneUtil.loadNamedTimezone](src/timezone.zig#L37) | Conservar | — | Configuración/liberación al inicio o comprobación simple; no hay trabajo repetido relevante que eliminar. |
| [TimezoneUtil.setLocalTimezone](src/timezone.zig#L45) | Conservar | — | Configuración/liberación al inicio o comprobación simple; no hay trabajo repetido relevante que eliminar. |
| [TimezoneUtil.clearLocalTimezone](src/timezone.zig#L52) | Conservar | — | Configuración/liberación al inicio o comprobación simple; no hay trabajo repetido relevante que eliminar. |
| [TimezoneUtil.hasLocalTimezone](src/timezone.zig#L60) | Conservar | — | Configuración/liberación al inicio o comprobación simple; no hay trabajo repetido relevante que eliminar. |
| [TimezoneUtil.getTimezoneOffsetMs](src/timezone.zig#L66) | P2 | 7 | Wrapper de consulta de zona: mejora indirecta de la ruta POSIX; no añadir caches mutables globales. |
| [TimezoneUtil.getTimezoneOffsetMinutes](src/timezone.zig#L74) | P2 | 7 | Wrapper de consulta de zona: mejora indirecta de la ruta POSIX; no añadir caches mutables globales. |
| [TimezoneUtil.applyTimezoneOffset](src/timezone.zig#L80) | P2 | 7 | Wrapper de consulta de zona: mejora indirecta de la ruta POSIX; no añadir caches mutables globales. |
| [TimezoneUtil.removeTimezoneOffset](src/timezone.zig#L88) | P2 | 7 | Mejora indirecta de utcFromLocal; preservar la desambiguación DST. |

### src/tzdata.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [PosixTz.parse](src/tzdata.zig#L84) | Conservar | — | Parseo lineal sin heap, normalmente al cargar la zona; no es una consulta repetida. |
| [PosixTz.offsetAtUtc](src/tzdata.zig#L126) | P1 | 7 | Precalcular/reutilizar transiciones por zona/año: actualmente evalúa inicio y fin para cuatro años. Cache explícita o inmutable, sin carreras ni memoria ilimitada. |
| [Timezone.deinit](src/tzdata.zig#L327) | Conservar | — | Carga/parseo/liberación de datos; coste ligado a tamaño TZif, asignaciones o I/O. Cargar una vez al iniciar. |
| [Timezone.parseBytes](src/tzdata.zig#L332) | Conservar | — | Carga/parseo/liberación de datos; coste ligado a tamaño TZif, asignaciones o I/O. Cargar una vez al iniciar. |
| [Timezone.loadFromFile](src/tzdata.zig#L340) | Conservar | — | Carga/parseo/liberación de datos; coste ligado a tamaño TZif, asignaciones o I/O. Cargar una vez al iniciar. |
| [Timezone.loadNamed](src/tzdata.zig#L352) | Conservar | — | Carga/parseo/liberación de datos; coste ligado a tamaño TZif, asignaciones o I/O. Cargar una vez al iniciar. |
| [Timezone.loadSystem](src/tzdata.zig#L379) | Conservar | — | Carga/parseo/liberación de datos; coste ligado a tamaño TZif, asignaciones o I/O. Cargar una vez al iniciar. |
| [Timezone.offsetAtUtc](src/tzdata.zig#L430) | P2 | 7 | La búsqueda histórica O(log T) es adecuada; el coste alto proviene del footer POSIX. Optimizar PosixTz.offsetAtUtc primero. |
| [Timezone.utcFromLocal](src/tzdata.zig#L473) | P2 | 7 | Reutilizar transiciones/offsets al resolver la hora local; puede consultar el offset hasta cuatro veces. No eliminar pruebas de gaps/folds sin demostración. |

### src/windows_zones.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [windows_zones.windowsToIana](src/windows_zones.zig#L154) | Conservar | — | Búsqueda binaria sin asignaciones. Un hash exige justificar coste de compilación y tamaño del binario; no hay evidencia para cambiarla. |

### src/zdate.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [ZDate.now](src/zdate.zig#L217) | Conservar | — | El coste corresponde al reloj del backend std.Io; reutilizar un instante solo cuando lo permita la semántica de la aplicación. |
| [ZDate.fromTimestamp](src/zdate.zig#L222) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.fromComponents](src/zdate.zig#L239) | P2 | 7 | Mejora indirecta de componentsToTimestamp/normalizeComponents; preservar años 0–99, saturación y límites ECMAScript. |
| [ZDate.fromComponentsUTC](src/zdate.zig#L266) | P2 | 7 | Mejora indirecta de componentsToTimestamp/normalizeComponents; preservar años 0–99, saturación y límites ECMAScript. |
| [ZDate.fromISO8601](src/zdate.zig#L292) | Conservar | — | Parser posicional sin heap; optimizar el calendario compartido antes de añadir un fast path ISO sin evidencia. |
| [ZDate.fromString](src/zdate.zig#L298) | P2 | 4 | Compartir trim y clasificar formatos antes de los intentos sucesivos; conservar el fallback legacy y la interpretación UTC/local. |
| [ZDate.nowTimestamp](src/zdate.zig#L306) | Conservar | — | El coste corresponde al reloj del backend std.Io; reutilizar un instante solo cuando lo permita la semántica de la aplicación. |
| [ZDate.loadSystemTimezone](src/zdate.zig#L321) | Conservar | — | Wrapper de configuración/carga; cargar una vez y reutilizar la zona. Embebido por nombre incluye toda la base; referencia directa reduce tamaño. |
| [ZDate.loadNamedTimezone](src/zdate.zig#L327) | Conservar | — | Wrapper de configuración/carga; cargar una vez y reutilizar la zona. Embebido por nombre incluye toda la base; referencia directa reduce tamaño. |
| [ZDate.setLocalTimezone](src/zdate.zig#L334) | Conservar | — | Wrapper de configuración/carga; cargar una vez y reutilizar la zona. Embebido por nombre incluye toda la base; referencia directa reduce tamaño. |
| [ZDate.loadEmbeddedTimezone](src/zdate.zig#L344) | Conservar | — | Wrapper de configuración/carga; cargar una vez y reutilizar la zona. Embebido por nombre incluye toda la base; referencia directa reduce tamaño. |
| [ZDate.clearLocalTimezone](src/zdate.zig#L352) | Conservar | — | Wrapper de configuración/carga; cargar una vez y reutilizar la zona. Embebido por nombre incluye toda la base; referencia directa reduce tamaño. |
| [ZDate.parse](src/zdate.zig#L357) | P2 | 4 | Compartir trim y clasificar formatos antes de los intentos sucesivos; conservar el fallback legacy y la interpretación UTC/local. |
| [ZDate.UTC](src/zdate.zig#L363) | P2 | 7 | Mejora indirecta de componentsToTimestamp/normalizeComponents; preservar años 0–99, saturación y límites ECMAScript. |
| [ZDate.getFullYear](src/zdate.zig#L394) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [ZDate.getMonth](src/zdate.zig#L399) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [ZDate.getDate](src/zdate.zig#L404) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [ZDate.getDay](src/zdate.zig#L409) | P1 | 2 | Calcular el día semanal directamente con @divFloor del timestamp ajustado y @mod(días + 4, 7); evitar la conversión de año/mes/día. |
| [ZDate.getHours](src/zdate.zig#L414) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [ZDate.getMinutes](src/zdate.zig#L419) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [ZDate.getSeconds](src/zdate.zig#L424) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [ZDate.getMilliseconds](src/zdate.zig#L429) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [ZDate.getTime](src/zdate.zig#L434) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.getTimezoneOffset](src/zdate.zig#L440) | P2 | 7 | Mejora indirecta de Timezone.offsetAtUtc/PosixTz.offsetAtUtc; su coste depende de la ruta histórica o POSIX, aunque el wrapper sea mínimo. |
| [ZDate.getYear](src/zdate.zig#L446) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [ZDate.getUTCFullYear](src/zdate.zig#L453) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [ZDate.getUTCMonth](src/zdate.zig#L458) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [ZDate.getUTCDate](src/zdate.zig#L463) | P2 | 7 | Beneficio indirecto de mejorar timestampToComponents; para lecturas múltiples, usar una única descomposición sin cachear dentro del valor mutable. |
| [ZDate.getUTCDay](src/zdate.zig#L468) | P1 | 2 | Calcular el día semanal directamente con @divFloor del timestamp ajustado y @mod(días + 4, 7); evitar la conversión de año/mes/día. |
| [ZDate.getUTCHours](src/zdate.zig#L473) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [ZDate.getUTCMinutes](src/zdate.zig#L478) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [ZDate.getUTCSeconds](src/zdate.zig#L483) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [ZDate.getUTCMilliseconds](src/zdate.zig#L488) | P1 | 3 | Extraer el campo con división/módulo del timestamp ajustado; conservar el offset histórico y la semántica para negativos/null. |
| [ZDate.setFullYear](src/zdate.zig#L495) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [ZDate.setMonth](src/zdate.zig#L500) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [ZDate.setDate](src/zdate.zig#L505) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [ZDate.setHours](src/zdate.zig#L510) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [ZDate.setMinutes](src/zdate.zig#L515) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [ZDate.setSeconds](src/zdate.zig#L520) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [ZDate.setMilliseconds](src/zdate.zig#L525) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [ZDate.setTime](src/zdate.zig#L530) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.setYear](src/zdate.zig#L536) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [ZDate.setUTCFullYear](src/zdate.zig#L543) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [ZDate.setUTCMonth](src/zdate.zig#L548) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [ZDate.setUTCDate](src/zdate.zig#L553) | P2 | 7 | Mejora indirecta del calendario; conservar normalización y recuperación de Invalid Date por setFullYear. |
| [ZDate.setUTCHours](src/zdate.zig#L558) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [ZDate.setUTCMinutes](src/zdate.zig#L563) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [ZDate.setUTCSeconds](src/zdate.zig#L568) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [ZDate.setUTCMilliseconds](src/zdate.zig#L573) | P2 | 6 | Reconstruir la parte horaria sobre el día absoluto; mantener overflow de campos, TimeClip y resolución local→UTC durante DST. |
| [ZDate.toString](src/zdate.zig#L580) | P2 | 3 | Evitar el segundo recorrido del calendario para el día semanal; conservar una sola asignación de salida. GMT hereda UTC. |
| [ZDate.toDateString](src/zdate.zig#L585) | P2 | 3 | Evitar el segundo recorrido del calendario para el día semanal; conservar una sola asignación de salida. GMT hereda UTC. |
| [ZDate.toTimeString](src/zdate.zig#L590) | P1 | 3 | Extraer solo hora/minuto/segundo después de aplicar la zona; no necesita año ni mes. |
| [ZDate.toISOString](src/zdate.zig#L595) | Opcional | 4 | La salida válida ya asigna una vez. Una API adicional hacia buffer/writer permitiría serialización sin heap; JSON hereda ISO. |
| [ZDate.toJSON](src/zdate.zig#L601) | Opcional | 4 | La salida válida ya asigna una vez. Una API adicional hacia buffer/writer permitiría serialización sin heap; JSON hereda ISO. |
| [ZDate.toUTCString](src/zdate.zig#L606) | P2 | 3 | Evitar el segundo recorrido del calendario para el día semanal; conservar una sola asignación de salida. GMT hereda UTC. |
| [ZDate.toGMTString](src/zdate.zig#L611) | P2 | 3 | Evitar el segundo recorrido del calendario para el día semanal; conservar una sola asignación de salida. GMT hereda UTC. |
| [ZDate.toLocaleDateString](src/zdate.zig#L616) | P2 | 7 | Mejora indirecta del calendario; la salida numérica ya realiza una asignación. |
| [ZDate.toLocaleTimeString](src/zdate.zig#L621) | P1 | 3 | Extraer solo hora/minuto/segundo después de aplicar la zona; no necesita año ni mes. |
| [ZDate.toLocaleString](src/zdate.zig#L626) | P1 | 5 | Descomponer una vez y renderizar fecha/hora en un solo resultado: actualmente usa dos conversiones y tres cadenas asignadas. |
| [ZDate.toLocaleDateStringStyle](src/zdate.zig#L633) | P2 | 5 | En estilo largo, evitar crecimiento incremental de ArrayList mediante medición y reserva exacta o writer; respetar patrones/strings arbitrarios. |
| [ZDate.toLocaleStringStyle](src/zdate.zig#L638) | P1 | 6 | Unificar conversión y salida, incluido el patrón largo; eliminar las cadenas temporales de fecha y hora. |
| [ZDate.valueOf](src/zdate.zig#L643) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.equals](src/zdate.zig#L651) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.before](src/zdate.zig#L656) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.after](src/zdate.zig#L661) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.compare](src/zdate.zig#L667) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.addMilliseconds](src/zdate.zig#L672) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.addSeconds](src/zdate.zig#L678) | Conservar | — | Escalado y suma O(1), sin asignaciones. Revisar overflow del escalado como corrección, no como optimización. |
| [ZDate.addMinutes](src/zdate.zig#L684) | Conservar | — | Escalado y suma O(1), sin asignaciones. Revisar overflow del escalado como corrección, no como optimización. |
| [ZDate.addHours](src/zdate.zig#L690) | Conservar | — | Escalado y suma O(1), sin asignaciones. Revisar overflow del escalado como corrección, no como optimización. |
| [ZDate.addDays](src/zdate.zig#L696) | Conservar | — | Escalado y suma O(1), sin asignaciones. Revisar overflow del escalado como corrección, no como optimización. |
| [ZDate.diffMilliseconds](src/zdate.zig#L702) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.diffSeconds](src/zdate.zig#L707) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.diffMinutes](src/zdate.zig#L712) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.diffHours](src/zdate.zig#L717) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.diffDays](src/zdate.zig#L722) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.isValid](src/zdate.zig#L729) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |
| [ZDate.isLeapYear](src/zdate.zig#L736) | Conservar | — | Operación O(1) sin heap o wrapper mínimo; no se justifica complejidad adicional. |

### src/zones.zig

| Función | Decisión | Dificultad /10 | Análisis y propuesta |
|---|---|---|---|
| [zones.find](src/zones.zig#L1218) | Conservar | — | Búsqueda binaria sin asignaciones. Un hash exige justificar coste de compilación y tamaño del binario; no hay evidencia para cambiarla. |
