# Z-Date

**Biblioteca de Fecha/Hora compatible con ECMAScript para Zig 0.17**

Z-Date es una biblioteca completa de fecha y hora para Zig que implementa la especificación completa de la API Date de JavaScript (ECMA-262 §21.4). Su conformidad no es aspiracional: la suite de tests incluye una suite diferencial cuyos valores esperados son **la salida real de V8**, más ports de casos oficiales de **test262**. Consulta la [matriz de conformidad](#matriz-de-conformidad-ecma-262-214) para el alcance método por método y las pocas desviaciones documentadas.

## Características

- **Conformidad ECMA-262 §21.4, verificada contra V8**: constructores, getters/setters, parseo, formateo, métodos legacy del Annex B — probados diferencialmente contra la salida real de V8
- **Soporte real de zonas horarias IANA**: tzdata del sistema en Linux/macOS, registro de Windows + mapeo CLDR, 599 zonas embebibles para WASM/embedded; transiciones DST históricas, reglas POSIX TZ para fechas lejanas y la desambiguación DST que exige el spec
- **145 locales** (datos de Day.js) con estilos de fecha numérico y largo (estilo `Intl`), compilados perezosamente — referenciar un locale embebe solo ese locale
- **ISO 8601**: gramática estricta de §21.4.3.2, años extendidos ±YYYYYY, más formatos legacy de parseo con paridad V8
- **Rango amplio**: ±273.785 años desde la época Unix (±8.64e15 ms), aritmética segura contra overflow
- **Value type puro**: `ZDate` es un struct puro de 8 bytes — sin allocator ni io almacenados internamente
- **Más de 300 tests**, incluyendo fuzzing de los parsers y casos límite de TimeClip/overflow
- **Nativo de Zig 0.17**: usa `std.Io.Clock` para obtener la hora

## Requisitos

- Zig 0.17.0 o superior

Los modos de optimización de Zig 0.17 son `debug`, `safe`, `fast` y `small`;
por ejemplo, usa `zig build test -Doptimize=fast` para probar la biblioteca optimizada.

## Instalación

Agrega Z-Date a tu `build.zig.zon`:

```zig
.{
    .name = "mi-proyecto",
    .version = "0.1.0",
    .dependencies = .{
        .zdate = .{
            .url = "https://github.com/yourusername/z-date/archive/main.tar.gz",
        },
    },
}
```

Luego en tu `build.zig`:

```zig
const zdate = b.dependency("zdate", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zdate", zdate.module("zdate"));
```

## Inicio Rápido

```zig
const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    // Carga la zona horaria real del host una vez al inicio (opcional: sin
    // ella, hora local == UTC, lo que ECMA-262 permite para hosts sin datos).
    try ZDate.loadSystemTimezone(allocator, io, null);
    defer ZDate.clearLocalTimezone();

    // Fecha con la hora actual — io requerido para acceder al reloj.
    // Los getters de componentes retornan ?i32: null significa Invalid Date
    // (el NaN de JS).
    const now = ZDate.now(io);
    std.debug.print("Año actual: {d}\n", .{now.getFullYear().?});

    // Fecha desde timestamp — sin io, sin allocator
    const epoch = ZDate.fromTimestamp(0);
    std.debug.print("Época Unix: {d}\n", .{epoch.getUTCFullYear().?}); // 1970

    // Fecha desde componentes — sin allocator
    const custom = ZDate.fromComponentsUTC(
        2024, 0, 1,   // 1 de enero de 2024
        12, 30, 0, 0  // 12:30:00.000
    );

    // Formatear como ISO 8601 — allocator requerido solo para salida string
    const iso_str = try custom.toISOString(allocator);
    defer allocator.free(iso_str);
    std.debug.print("ISO: {s}\n", .{iso_str}); // 2024-01-01T12:30:00.000Z

    // Salida localizada: 145 locales incluidos, estilo numérico o largo
    const es = try custom.toLocaleDateStringStyle(allocator, zdate.locales.es_cl, .long);
    defer allocator.free(es);
    std.debug.print("es-CL: {s}\n", .{es}); // 1 de enero de 2024

    // Parsear ISO 8601 — sin allocator
    const parsed = ZDate.fromISO8601("2024-12-25T00:00:00.000Z");
    std.debug.print("Mes de navidad: {d}\n", .{parsed.getUTCMonth().?}); // 11 (diciembre)
}
```

## Filosofía de Diseño

`ZDate` es un **value type puro de 8 bytes** — internamente solo guarda un `timestamp: i64`. Los objetos de contexto como `allocator` e `io` se pasan por función solo donde son estrictamente necesarios:

- **Constructores** — sin allocator, sin io (excepto `now()`, que lee el reloj)
- **Getters/Setters** — sin allocator, sin io (aritmética pura sobre el timestamp)
- **Métodos de formateo** — `allocator` como parámetro (retornan `[]u8` propiedad del llamador)
- **`now()` / `nowTimestamp()`** — `io` como parámetro (leen el reloj del sistema)

Esto mantiene cada instancia de `ZDate` liviana y apta para heaps de motores JS.

## Panorama de la API

La referencia completa y siempre actualizada de la API se genera desde los
doc comments del código: ejecuta `zig build docs` y abre
`zig-out/docs/index.html`. Resumen de la superficie:

| Grupo | Métodos | Notas |
|---|---|---|
| Estáticos | `now(io)`, `nowTimestamp(io)`, `parse(str)`, `UTC(...)`, `isLeapYear(y)` | `parse` retorna un timestamp (`INVALID_TIME` si falla) |
| Constructores | `fromTimestamp`, `fromComponents[UTC]`, `fromISO8601`, `fromString` | Nunca fallan — entrada inválida produce Invalid Date, como en JS |
| Timezone (host) | `loadSystemTimezone`, `loadNamedTimezone`, `loadEmbeddedTimezone`, `setLocalTimezone`, `clearLocalTimezone` | A nivel de proceso, como el host environment de un motor JS |
| Getters | `get*` / `getUTC*` (8 componentes), `getTime`, `getTimezoneOffset`, `getYear` | Los getters de componentes retornan `?i32` — `null` ≡ `NaN` de JS |
| Setters | `set*` / `setUTC*`, `setTime`, `setYear` | Invalid Date sigue inválida; resultados acotados por TimeClip |
| Formateo | `toString`, `toDateString`, `toTimeString`, `toISOString`, `toJSON`, `toUTCString`, `toGMTString`, `toLocale*String[Style]` | Reciben `allocator`, retornan `[]u8` propio; `toJSON` retorna `!?[]u8` (`null` para Invalid Date) |
| Aritmética | `add{Milliseconds,Seconds,Minutes,Hours,Days}` (`!ZDate`), `diff*` (`?i64`) | `diff*` retornan `null` si alguna fecha es inválida |
| Comparación | `equals`, `before`, `after` (`bool`), `compare` (`?std.math.Order`) | Semántica NaN: siempre false / `null` con una Invalid Date |
| Validación | `isValid()`, `valueOf()` | |
| Namespaces de datos | `zdate.locales` (145 locales), `zdate.zones` (599 zonas IANA), `zdate.windows_zones` | Individualmente perezosos — solo embebes lo que referencias |

## Ejemplos de Uso

### Crear Fechas

```zig
// Fecha/hora actual — requiere io de std.process.Init
const now = ZDate.now(io);

// Desde timestamp (milisegundos desde la época Unix) — puro, sin io
const epoch = ZDate.fromTimestamp(0);

// Desde componentes (año, mes, día, hora, minuto, segundo, milisegundo)
const date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);

// Desde string ISO 8601 — puro, sin allocator
const parsed = ZDate.fromISO8601("2024-01-01T00:00:00.000Z");

// Desde varios formatos de string
const from_str = ZDate.fromString("01/15/2024");
```

### Obtener el Timestamp Actual

```zig
pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // Timestamp actual en milisegundos
    const ms = ZDate.nowTimestamp(io);

    // Objeto fecha actual (getters retornan ?i32; null = Invalid Date)
    const today = ZDate.now(io);
    std.debug.print("Año: {d}\n", .{today.getFullYear().?});
}
```

### Formatear Fechas

```zig
const date = ZDate.fromComponentsUTC(2024, 11, 25, 0, 0, 0, 0);

// Formato ISO 8601 — allocator requerido, el llamador libera
const iso = try date.toISOString(allocator);
defer allocator.free(iso);
// Salida: "2024-12-25T00:00:00.000Z"

// String de fecha
const date_str = try date.toDateString(allocator);
defer allocator.free(date_str);
// Salida: "Wed Dec 25 2024"

// String UTC
const utc = try date.toUTCString(allocator);
defer allocator.free(utc);
// Salida: "Wed, 25 Dec 2024 00:00:00 GMT"
```

### Parsear Fechas

```zig
// Formatos ISO 8601 — todos retornan ZDate directamente, sin try
const d1 = ZDate.fromISO8601("2024-01-01T00:00:00.000Z");
const d2 = ZDate.fromISO8601("2024-01-01");

// Parsear a timestamp crudo
const ts1 = ZDate.parse("2024-01-01T00:00:00.000Z");
const ts2 = ZDate.parse("01/15/2024");

// Verificar si el parseo tuvo éxito
if (d1.isValid()) {
    // Fecha válida
}
```

### Aritmética de Fechas

```zig
const date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);

// Los métodos add* retornan !ZDate — usa try
const next_week = try date.addDays(7);
const later     = try date.addHours(3);
const earlier   = try date.addMinutes(-30);

// Los métodos diff* retornan ?i64 — null si alguna fecha es Invalid Date
const diff_days = next_week.diffDays(date).?;      // 7
const diff_ms   = next_week.diffMilliseconds(date).?;
```

### Comparación

```zig
const date1 = ZDate.fromComponentsUTC(2024, 0, 1,  0, 0, 0, 0);
const date2 = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);

if (date1.equals(date2)) { }   // false
if (date1.before(date2)) { }   // true
if (date2.after(date1))  { }   // true

// compare retorna ?std.math.Order — null si alguna fecha es Invalid Date
// (semántica NaN de JS: no existe relación de orden).
const order = date1.compare(date2).?; // .lt
```

### Manejo de Errores en Aritmética

```zig
const ZDateError = zdate.ZDateError;

const result = date.addMilliseconds(huge_value);
if (result) |new_date| {
    // Éxito — usa new_date
    _ = new_date;
} else |err| switch (err) {
    ZDateError.OutOfRange       => {},
    ZDateError.TimestampOverflow => {},
    else => {},
}
```

### Años Bisiestos

```zig
const is_2024_leap = ZDate.isLeapYear(2024); // true
const is_2023_leap = ZDate.isLeapYear(2023); // false
const is_2000_leap = ZDate.isLeapYear(2000); // true
const is_1900_leap = ZDate.isLeapYear(1900); // false

const feb29 = ZDate.fromComponentsUTC(2024, 1, 29, 0, 0, 0, 0);
```

### Manejo de Zonas Horarias

```zig
// Carga la zona del host una vez al inicio (variable TZ, luego /etc/localtime;
// en Windows: nombre del registro -> mapeo CLDR -> tzdata embebida).
try ZDate.loadSystemTimezone(allocator, io, null);
defer ZDate.clearLocalTimezone();

// O elige una zona IANA específica desde la tzdata del sistema...
try ZDate.loadNamedTimezone(allocator, io, "America/Santiago");

// ...o desde la base embebida (funciona en WASM/Windows; embebe ~1.4 MB)
try ZDate.loadEmbeddedTimezone(allocator, "Asia/Tokyo");

// ...o embebe exactamente UNA zona (solo sus ~2 KB entran al binario)
ZDate.setLocalTimezone(try zdate.Timezone.parseBytes(allocator, zdate.zones.america_santiago));

const date = ZDate.fromComponentsUTC(2024, 5, 15, 12, 0, 0, 0);
const utc_hour = date.getUTCHours().?;      // 12
const local_hour = date.getHours().?;       // 8 en Santiago (invierno, -04:00)
const offset = date.getTimezoneOffset().?;  // 240 (UTC - local, en minutos)

// El DST se maneja por fecha, incluida la desambiguación del spec para horas
// locales que se repiten o nunca existen alrededor de una transición
// (tc39/ecma262#778).
```

### Formateo Localizado

```zig
const date = ZDate.fromComponentsUTC(2024, 0, 15, 14, 30, 0, 0);

// El estilo numérico respeta el orden de fecha y separadores de cada locale
const us = try date.toLocaleDateString(allocator, zdate.locales.en_us); // "01/15/2024"
defer allocator.free(us);

// El estilo largo coincide con dateStyle: "long" de Intl.DateTimeFormat
const cl = try date.toLocaleDateStringStyle(allocator, zdate.locales.es_cl, .long);
defer allocator.free(cl); // "15 de enero de 2024"

const jp = try date.toLocaleDateStringStyle(allocator, zdate.locales.ja, .long);
defer allocator.free(jp); // "2024年1月15日"

// locale null usa en-US por defecto
const default_style = try date.toLocaleString(allocator, null);
defer allocator.free(default_style); // "01/15/2024, 02:30:00 PM"
```

### Testing con io

En tests, crea un backend liviano `std.Io.Threaded`:

```zig
test "now() crea una fecha válida" {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    const date = ZDate.now(io);
    try std.testing.expect(date.isValid());
}

test "nowTimestamp() retorna un valor positivo" {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    const ms = ZDate.nowTimestamp(io);
    try std.testing.expect(ms > 0);
}
```

## Constantes

```zig
const Constants = zdate.Constants;

// Conversiones de tiempo
const ms_per_second = Constants.MS_PER_SECOND; // 1_000
const ms_per_minute = Constants.MS_PER_MINUTE; // 60_000
const ms_per_hour   = Constants.MS_PER_HOUR;   // 3_600_000
const ms_per_day    = Constants.MS_PER_DAY;     // 86_400_000

// Rango válido
const max_time = Constants.MAX_TIME; //  8_640_000_000_000_000
const min_time = Constants.MIN_TIME; // -8_640_000_000_000_000

// Marcador de fecha inválida
const invalid = Constants.INVALID_TIME;
```

## Tipos de Error

```zig
const ZDateError = zdate.ZDateError;

// OutOfMemory       — el allocator falló durante el formateo de strings
// InvalidDate       — representación de fecha inválida (ej. toISOString sobre Invalid Date)
// InvalidFormat     — formato de string de fecha inválido
// OutOfRange        — timestamp fuera del rango válido
// TimestampOverflow — overflow aritmético en métodos add*
```

## Compilación

```bash
# Compilar la biblioteca
zig build

# Ejecutar tests
zig build test --summary all

# Generar documentación
zig build docs
```

## Arquitectura

Z-Date está organizada en componentes modulares:

- `constants.zig` — Constantes de tiempo y conversiones
- `errors.zig` — Tipos de error
- `timezone.zig` — Estado de zona horaria local a nivel de proceso (modelo host environment)
- `tzdata.zig` — Carga TZif (vía `std.Tz`), búsqueda de offsets, reglas POSIX TZ, desambiguación DST
- `calendar.zig` — Cálculos de calendario (bisiestos, días por mes, normalización)
- `getters.zig` — Getters de componentes de fecha
- `setters.zig` — Setters de componentes de fecha
- `formatting.zig` — Métodos de formateo de strings (incl. estilos por locale)
- `parsing.zig` — Parseo de strings (ISO 8601 estricto + gramática legacy con paridad V8)
- `arithmetic.zig` — Aritmética y comparación de fechas
- `locale.zig` + `locales/` — Tipo `Locale` y 145 locales incluidos (un archivo cada uno, compilación perezosa)
- `zones.zig` + `zones/` — 599 zonas IANA TZif embebidas (una declaración perezosa cada una; generado)
- `windows_zones.zig` — Mapeo de nombres de zona Windows↔IANA (datos CLDR; generado)
- `zdate.zig` — Struct ZDate principal y API

## Decisiones de Diseño

### Value Type Puro de 8 Bytes

`ZDate` solo guarda `timestamp: i64`. Sin allocator, sin contexto io. Esto significa:
- Cero overhead por instancia en el heap de un motor JS
- Seguro de copiar, pasar por valor y guardar en arrays
- El allocator se pasa solo a métodos de formateo que retornan `[]u8`
- `io` se pasa solo a `now()` y `nowTimestamp()` para acceso al reloj

### Representación del Timestamp

- Usa `i64` para timestamps (milisegundos desde la época Unix)
- Rango: ±273.785 años desde la época (±8.64e15 milisegundos)
- Fechas inválidas representadas por `std.math.maxInt(i64)`

### API de Reloj de Zig 0.17

Usa `std.Io.Clock.real.now(io).toMilliseconds()` para la hora de pared, integrándose limpiamente con el sistema unificado de backends de I/O de Zig 0.17 (`std.Io.Threaded`, `std.Io.Evented`).

### Estrategia de Errores

- Los constructores nunca fallan — entradas inválidas producen `Invalid Date` (como en JS)
- Los métodos aritméticos `add*` retornan `!ZDate` — overflow y fuera-de-rango son errores reales
- Los métodos de formateo retornan `![]u8` — la asignación puede fallar
- `fromISO8601` retorna `ZDate` — errores de parseo producen `Invalid Date` vía `catch`

### Manejo de Zonas Horarias

- La zona local es **estado a nivel de proceso**, reflejando el modelo de
  ECMA-262 donde la zona pertenece al host environment, no a cada valor Date —
  así `ZDate` sigue siendo un value type de 8 bytes y ninguna firma carga una zona
- Todos los métodos disponibles en variantes UTC y local
- Respaldado por tzdata IANA real (TZif vía `std.Tz`), no offsets fijos:
  transiciones DST históricas, reglas del footer POSIX TZ más allá de la tabla,
  y la desambiguación local→UTC del spec en las transiciones
- Hasta que se carga una zona, local == UTC (offset 0) — el comportamiento que
  ECMA-262 prescribe para hosts sin datos de zona horaria

## Comparación de rendimiento

El código de Zig 0.17 anterior a las optimizaciones se conserva en
`benchmarks/baseline-zig-0.17.tar.gz`, con un manifiesto SHA-256. `zig build test`
incluye pruebas diferenciales contra esa copia; esas pruebas y los benchmarks
requieren Python 3 para extraer y verificar el archivo.

Ejecuta `python3 scripts/benchmark.py --runs 3 --mode fast`. El script fija una CPU
en Linux, calienta ambas versiones, alterna el orden, verifica checksums y guarda
muestras crudas y medianas en `benchmarks/results-fast.{csv,json,md}`. Usa
`--mode safe` para medir con comprobaciones de seguridad.
`zig build benchmark -Doptimize=fast` ejecuta un proceso e imprime las muestras.

La caché POSIX almacena una regla/año por hilo, sin asignaciones dinámicas; compara
los valores de las reglas para impedir reutilizar datos de una zona reemplazada.
WASM conserva el cálculo sin caché. ZDate continúa siendo un valor de 8 bytes.

## Compatibilidad

- **Versión de Zig**: 0.17.0 o superior
- **ECMAScript**: compatibilidad completa con la API Date (ver la matriz de conformidad)
- **ISO 8601**: soporte completo de parseo y formateo
- **Plataformas**: Linux, macOS, Windows (todas las plataformas soportadas por Zig)

## Matriz de Conformidad ECMA-262 §21.4

Cada comportamiento listado está cubierto por la suite de tests (más de 300),
incluida una suite diferencial (`tests/v8_differential_test.zig`) cuyos valores
esperados son la salida real de V8 — 150 timestamps aleatorios en todo el rango
±8.64e15 más casos límite de transiciones DST — y ports de casos oficiales de
test262 (`tests/test262_port_test.zig`).

| Área | Estado | Notas |
|---|---|---|
| Rango de tiempo ±8.64e15 ms (TimeClip) | ✅ | Fuera de rango → Invalid Date en todas partes (constructores, setters, parse) |
| Constructores: normalización (MakeDay/MakeTime) | ✅ | El overflow de mes/día/hora se acarrea, `(2024, 13, 1)` → feb 2025; años de dos dígitos mapean a 1900-1999 (MakeFullYear) |
| Getters (`get*`/`getUTC*`) | ✅ | Retornan `?i32`; `null` ≡ `NaN` de JS para Invalid Date |
| `getTimezoneOffset` | ✅ | Por fecha (cambia con el DST), `null` para Invalid Date |
| Setters (`set*`/`setUTC*`, `setTime`) | ✅ | Invalid Date sigue inválida; resultados acotados por TimeClip |
| `Date.parse`: ISO 8601 (§21.4.3.2) | ✅ | Gramática posicional estricta; años extendidos ±YYYYYY; offsets ±HH:mm; solo-fecha → UTC, fecha-hora sin offset → local |
| `Date.parse`: formatos legacy | ✅ | Gramática con paridad V8: round-trips de `toString`/`toUTCString`, nombres de mes, AM/PM, `2024/01/15`, ISO-con-espacio, offsets ±HHMM, nombres de zona entre paréntesis; semántica local como en V8 |
| Formateo (`toISOString`, `toUTCString`, `toString`, …) | ✅ | Años expandidos con signo de 6 dígitos fuera de [0, 9999]; los casos de formato de test262 pasan |
| `toJSON` | ✅ | `null` (no un error) para Invalid Date |
| Semántica de comparación NaN | ✅ | `equals`/`before`/`after` false y `compare`/`diff*` `null` cuando alguna fecha es inválida |
| Zona horaria local (LocalTZA) | ✅ | Tzdata IANA real vía `std.Tz` (RFC 8536): zona del sistema (variable TZ, `/etc/localtime`, nombre del registro de Windows vía mapeo CLDR), transiciones DST históricas, reglas del footer POSIX TZ para fechas más allá de la tabla, y la desambiguación local del spec (tc39/ecma262#778) |
| Annex B (`getYear`, `setYear`, `toGMTString`) | ✅ | Una desviación documentada: `setYear` sobre Invalid Date sigue inválida (el spec la resetea a +0) |
| `toLocale*String` | ✅* | 145 locales (datos Day.js) con estilos numérico y largo (tipo `dateStyle: "long"` de `Intl`); no respaldado por CLDR/ICU |

**Desviaciones documentadas** (deliberadas, todas cubiertas por tests):
`null` reemplaza al `NaN` de JS en toda la API (Zig no tiene enteros con NaN);
`setYear` sobre una Invalid Date no la resucita; `toLocale*` usa datos de
locale derivados de Day.js en lugar de CLDR completo. Los hosts sin datos de
zona horaria corren con offset 0, lo que ECMA-262 permite explícitamente.

### Datos de zona horaria

- **Linux/macOS**: lee la tzdata del sistema (`ZDate.loadSystemTimezone`).
- **Windows**: `GetDynamicTimeZoneInformation` → mapeo CLDR `windowsZones` →
  tzdata embebida.
- **WASM/embedded**: 599 zonas IANA vendorizadas bajo `src/zones/`; cada una es
  una declaración perezosa individual, así que referenciar una zona embebe solo
  esa zona (~2 KB); la búsqueda por nombre (`zones.find`,
  `loadEmbeddedTimezone`) opta por la base completa (~1.4 MB). Actualiza con
  `scripts/update_tzdata.py`.

## Contribuir

¡Las contribuciones son bienvenidas! Por favor asegúrate de:

1. Que todos los tests pasen (`zig build test --summary all`)
2. Que el código siga las guías de estilo de Zig
3. Que las funcionalidades nuevas incluyan tests
4. Que la documentación esté actualizada

## Licencia

Licencia MIT — ver el archivo LICENSE para más detalles

## Proyectos Relacionados

- [Z-Number](../z-number) — Implementación de Number de ECMAScript en Zig

## Documentación

Para la documentación en inglés, consulta [README.md](README.md).

---

**Z-Date** — Construido con Zig 0.17 para motores JavaScript de alto rendimiento
