# Z-Date

**Biblioteca de Fecha/Hora Compatible con ECMAScript para Zig 0.15**

Z-Date es una biblioteca completa de fecha y hora para Zig que implementa la especificación completa de la API Date de JavaScript. Diseñada como componente central para motores JavaScript (como Bun/QuickJS), proporciona 100% de compatibilidad con ECMAScript Date, incluyendo todos los métodos estáticos, métodos de instancia, manejo de zonas horarias (UTC y local), parsing de strings y formateo ISO 8601.

## Características

- **Compatibilidad Completa con ECMAScript Date**: Implementa todos los métodos de JavaScript Date
- **Soporte de Zonas Horarias**: Operaciones tanto en UTC como en zona horaria local
- **ISO 8601**: Soporte completo de parsing y formateo
- **Alta Precisión**: Timestamps con precisión de milisegundos
- **Amplio Rango**: Soporta fechas desde ±273,785 años desde la época Unix
- **Seguridad de Tipos**: Aprovecha el sistema de tipos de Zig para seguridad en tiempo de compilación
- **Tests Comprehensivos**: 150+ tests asegurando correctitud
- **Labeled Blocks**: Características modernas de Zig 0.15 para mejor organización del código

## Requisitos

- Zig 0.15.x o posterior

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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Crear fecha con la hora actual
    const ahora = try ZDate.now(allocator);
    std.debug.print("Año actual: {}\n", .{ahora.getFullYear()});

    // Crear fecha desde timestamp
    const fecha = try ZDate.fromTimestamp(allocator, 0);
    std.debug.print("Época Unix: {}\n", .{fecha.getUTCFullYear()}); // 1970

    // Crear fecha desde componentes
    const personalizada = try ZDate.fromComponentsUTC(
        allocator,
        2024, 0, 1, // 1 de enero de 2024
        12, 30, 0, 0 // 12:30:00.000
    );

    // Formatear como ISO 8601
    const iso_str = try personalizada.toISOString();
    defer allocator.free(iso_str);
    std.debug.print("ISO: {s}\n", .{iso_str}); // 2024-01-01T12:30:00.000Z

    // Parsear ISO 8601
    const parseada = try ZDate.fromISO8601(allocator, "2024-12-25T00:00:00.000Z");
    std.debug.print("Navidad: {}\n", .{parseada.getUTCMonth()}); // 11 (Diciembre)
}
```

## Referencia de API

### Métodos Estáticos

| Método | Descripción | Ejemplo |
|--------|-------------|---------|
| `ZDate.now(allocator)` | Crear fecha con hora actual | `const d = try ZDate.now(alloc);` |
| `ZDate.nowTimestamp()` | Obtener timestamp actual (ms) | `const ts = ZDate.nowTimestamp();` |
| `ZDate.parse(str)` | Parsear string de fecha a timestamp | `const ts = ZDate.parse("2024-01-01");` |
| `ZDate.UTC(...)` | Crear timestamp UTC desde componentes | `const ts = ZDate.UTC(2024, 0, 1, 0, 0, 0, 0);` |
| `ZDate.isLeapYear(year)` | Verificar si el año es bisiesto | `const es_bisiesto = ZDate.isLeapYear(2024);` |

### Constructores

| Método | Descripción |
|--------|-------------|
| `fromTimestamp(allocator, ms)` | Crear desde milisegundos desde la época |
| `fromComponents(allocator, year, month, ...)` | Crear desde componentes de fecha/hora (local) |
| `fromComponentsUTC(allocator, year, month, ...)` | Crear desde componentes de fecha/hora (UTC) |
| `fromISO8601(allocator, str)` | Crear desde string ISO 8601 |
| `fromString(allocator, str)` | Crear desde varios formatos de string de fecha |

### Getters (Hora Local)

| Método | Retorna | Rango |
|--------|---------|-------|
| `getFullYear()` | Año (4 dígitos) | Cualquier entero |
| `getMonth()` | Mes | 0-11 (0 = Enero) |
| `getDate()` | Día del mes | 1-31 |
| `getDay()` | Día de la semana | 0-6 (0 = Domingo) |
| `getHours()` | Horas | 0-23 |
| `getMinutes()` | Minutos | 0-59 |
| `getSeconds()` | Segundos | 0-59 |
| `getMilliseconds()` | Milisegundos | 0-999 |
| `getTime()` | Timestamp (ms desde época) | i64 |
| `getTimezoneOffset()` | Offset de zona horaria (minutos) | Entero |

### Getters (UTC)

Todos los getters tienen equivalentes UTC: `getUTCFullYear()`, `getUTCMonth()`, `getUTCDate()`, `getUTCDay()`, `getUTCHours()`, `getUTCMinutes()`, `getUTCSeconds()`, `getUTCMilliseconds()`

### Setters (Hora Local)

| Método | Descripción |
|--------|-------------|
| `setFullYear(year, ?month, ?day)` | Establecer año (opcionalmente mes y día) |
| `setMonth(month, ?day)` | Establecer mes (opcionalmente día) |
| `setDate(day)` | Establecer día del mes |
| `setHours(hour, ?min, ?sec, ?ms)` | Establecer horas (opcionalmente min, sec, ms) |
| `setMinutes(min, ?sec, ?ms)` | Establecer minutos (opcionalmente sec, ms) |
| `setSeconds(sec, ?ms)` | Establecer segundos (opcionalmente ms) |
| `setMilliseconds(ms)` | Establecer milisegundos |
| `setTime(timestamp)` | Establecer timestamp directamente |

### Setters (UTC)

Todos los setters tienen equivalentes UTC: `setUTCFullYear()`, `setUTCMonth()`, `setUTCDate()`, `setUTCHours()`, `setUTCMinutes()`, `setUTCSeconds()`, `setUTCMilliseconds()`

### Métodos de Formateo

| Método | Formato de Salida | Ejemplo |
|--------|-------------------|---------|
| `toString()` | String completo de fecha/hora | "Mon Jan 01 2024 00:00:00 GMT+0000" |
| `toDateString()` | Solo fecha | "Mon Jan 01 2024" |
| `toTimeString()` | Solo hora | "00:00:00 GMT+0000" |
| `toISOString()` | ISO 8601 (UTC) | "2024-01-01T00:00:00.000Z" |
| `toJSON()` | JSON (igual que ISO) | "2024-01-01T00:00:00.000Z" |
| `toUTCString()` | String UTC | "Mon, 01 Jan 2024 00:00:00 GMT" |
| `toLocaleDateString(?locale)` | Fecha localizada | "01/01/2024" |
| `toLocaleTimeString(?locale)` | Hora localizada | "00:00:00" |
| `toLocaleString(?locale)` | Fecha/hora localizada | "01/01/2024, 00:00:00" |

### Aritmética y Comparación

| Método | Descripción |
|--------|-------------|
| `addMilliseconds(ms)` | Agregar/restar milisegundos |
| `addSeconds(sec)` | Agregar/restar segundos |
| `addMinutes(min)` | Agregar/restar minutos |
| `addHours(hours)` | Agregar/restar horas |
| `addDays(days)` | Agregar/restar días |
| `diffMilliseconds(other)` | Diferencia en milisegundos |
| `diffSeconds(other)` | Diferencia en segundos |
| `diffMinutes(other)` | Diferencia en minutos |
| `diffHours(other)` | Diferencia en horas |
| `diffDays(other)` | Diferencia en días |
| `equals(other)` | Verificar igualdad |
| `before(other)` | Verificar si es anterior |
| `after(other)` | Verificar si es posterior |
| `compare(other)` | Comparación de tres vías |

### Validación

| Método | Descripción |
|--------|-------------|
| `isValid()` | Verificar si la fecha es válida |
| `valueOf()` | Obtener valor primitivo del timestamp |

## Ejemplos de Uso

### Crear Fechas

```zig
// Fecha/hora actual
const ahora = try ZDate.now(allocator);

// Desde timestamp (milisegundos desde época Unix)
const epoca = try ZDate.fromTimestamp(allocator, 0);

// Desde componentes (año, mes, día, hora, minuto, segundo, milisegundo)
const fecha = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);

// Desde string ISO 8601
const parseada = try ZDate.fromISO8601(allocator, "2024-01-01T00:00:00.000Z");
```

### Formatear Fechas

```zig
const fecha = try ZDate.fromComponentsUTC(allocator, 2024, 11, 25, 0, 0, 0, 0);

// Formato ISO 8601
const iso = try fecha.toISOString();
defer allocator.free(iso);
// Salida: "2024-12-25T00:00:00.000Z"

// String de fecha
const fecha_str = try fecha.toDateString();
defer allocator.free(fecha_str);
// Salida: "Wed Dec 25 2024"

// String UTC
const utc = try fecha.toUTCString();
defer allocator.free(utc);
// Salida: "Wed, 25 Dec 2024 00:00:00 GMT"
```

### Parsear Fechas

```zig
// Formatos ISO 8601
const ts1 = ZDate.parse("2024-01-01T00:00:00.000Z");
const ts2 = ZDate.parse("2024-01-01");
const ts3 = ZDate.parse("2024-06");

// Formato con barras
const ts4 = ZDate.parse("01/15/2024");

// Verificar si el parsing tuvo éxito
if (ts1 != zdate.Constants.INVALID_TIME) {
    // Timestamp válido
}
```

### Aritmética de Fechas

```zig
const fecha = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);

// Agregar 7 días
const proxima_semana = try fecha.addDays(7);

// Agregar 3 horas
const mas_tarde = try fecha.addHours(3);

// Restar 30 minutos
const mas_temprano = try fecha.addMinutes(-30);

// Calcular diferencia
const diff_dias = proxima_semana.diffDays(fecha); // 7
const diff_ms = proxima_semana.diffMilliseconds(fecha);
```

### Comparación

```zig
const fecha1 = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
const fecha2 = try ZDate.fromComponentsUTC(allocator, 2024, 0, 15, 0, 0, 0, 0);

// Igualdad
if (fecha1.equals(fecha2)) { }

// Ordenamiento
if (fecha1.before(fecha2)) { } // true
if (fecha2.after(fecha1)) { } // true

// Comparación de tres vías
const orden = fecha1.compare(fecha2); // .lt
```

### Años Bisiestos

```zig
// Verificar año bisiesto
const es_2024_bisiesto = ZDate.isLeapYear(2024); // true
const es_2023_bisiesto = ZDate.isLeapYear(2023); // false
const es_2000_bisiesto = ZDate.isLeapYear(2000); // true
const es_1900_bisiesto = ZDate.isLeapYear(1900); // false

// Crear fecha de año bisiesto
const feb29 = try ZDate.fromComponentsUTC(allocator, 2024, 1, 29, 0, 0, 0, 0);
```

### Manejo de Zonas Horarias

```zig
const fecha = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);

// Getters UTC
const hora_utc = fecha.getUTCHours(); // 0

// Getters locales (depende de la zona horaria del sistema)
const hora_local = fecha.getHours(); // Puede diferir de UTC

// Offset de zona horaria en minutos
const offset = fecha.getTimezoneOffset();
```

## Constantes

```zig
const Constants = zdate.Constants;

// Conversiones de tiempo
const ms_por_segundo = Constants.MS_PER_SECOND; // 1000
const ms_por_minuto = Constants.MS_PER_MINUTE; // 60000
const ms_por_hora = Constants.MS_PER_HOUR; // 3600000
const ms_por_dia = Constants.MS_PER_DAY; // 86400000

// Rango válido
const tiempo_max = Constants.MAX_TIME; // 8,640,000,000,000,000
const tiempo_min = Constants.MIN_TIME; // -8,640,000,000,000,000

// Marcador de fecha inválida
const invalido = Constants.INVALID_TIME;
```

## Manejo de Errores

```zig
const ZDateError = zdate.ZDateError;

// Errores posibles:
// - OutOfMemory: Fallo en asignación de memoria
// - InvalidDate: Representación de fecha inválida
// - InvalidFormat: Formato de string de fecha inválido
// - OutOfRange: Timestamp fuera del rango válido
// - TimestampOverflow: Overflow aritmético

// Ejemplo:
const resultado = fecha.addMilliseconds(valor_enorme);
if (resultado) |nueva_fecha| {
    // Éxito
} else |err| switch (err) {
    ZDateError.OutOfRange => {},
    ZDateError.TimestampOverflow => {},
    else => {},
}
```

## Compilación

```bash
# Compilar biblioteca
zig build

# Ejecutar tests
zig build test

# Generar documentación
zig build docs
```

## Testing

La biblioteca incluye 150+ tests comprehensivos que cubren:

- Validación de constantes
- Funcionalidad de constructores
- Métodos getter (local y UTC)
- Métodos setter (local y UTC)
- Parsing (ISO 8601, varios formatos)
- Formateo (todos los formatos de salida)
- Manejo de zonas horarias
- Operaciones aritméticas
- Casos extremos (años bisiestos, límites, overflow)
- Round-trip ISO 8601

Ejecutar tests con:

```bash
zig build test
```

## Arquitectura

Z-Date está organizado en componentes modulares:

- `constants.zig` - Constantes de tiempo y conversiones
- `errors.zig` - Tipos de error
- `timezone.zig` - Utilidades de zona horaria (UTC/local)
- `calendar.zig` - Cálculos de calendario (años bisiestos, días en mes)
- `getters.zig` - Getters de componentes de fecha
- `setters.zig` - Setters de componentes de fecha
- `formatting.zig` - Métodos de formateo de strings
- `parsing.zig` - Métodos de parsing de strings
- `arithmetic.zig` - Aritmética y comparación de fechas
- `zdate.zig` - Struct ZDate principal y API

## Decisiones de Diseño

### Representación de Timestamp

- Usa `i64` para timestamps (milisegundos desde época Unix)
- Rango: ±273,785 años desde época (±8.64e15 milisegundos)
- Fechas inválidas representadas por `std.math.maxInt(i64)`

### Manejo de Zonas Horarias

- Modo dual: operaciones en UTC y zona horaria local
- Todos los métodos disponibles en variantes UTC y locales
- Detección de offset de zona horaria (específico de plataforma)

### Labeled Blocks

Usa labeled blocks de Zig 0.15 para mejor organización del código:
- Bloques de validación en constructores
- Bloques de formateo en métodos de salida
- Bloques de parsing en métodos de entrada
- Bloques de operaciones aritméticas

### Gestión de Memoria

- Requiere allocator para operaciones con strings
- Los strings formateados deben ser liberados por el llamador
- Sin asignaciones ocultas

## Compatibilidad

- **Versión de Zig**: 0.15.x o posterior
- **ECMAScript**: Compatibilidad completa con API Date
- **ISO 8601**: Soporte completo de parsing y formateo
- **Plataformas**: Todas las plataformas soportadas por Zig

## Contribuir

¡Las contribuciones son bienvenidas! Por favor asegúrate de:

1. Todos los tests pasen (`zig build test`)
2. El código siga las guías de estilo de Zig
3. Nuevas características incluyan tests
4. La documentación esté actualizada

## Licencia

Licencia MIT - ver archivo LICENSE para detalles

## Proyectos Relacionados

- [Z-Number](../z-number) - Implementación de ECMAScript Number en Zig

## Documentación

Para documentación en inglés, ver [README.md](README.md).

## Soporte

Para issues, preguntas o contribuciones, por favor visita el repositorio de GitHub.

---

**Z-Date** - Construido con Zig 0.15 para motores JavaScript de alto rendimiento
