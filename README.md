# Z-Date

**ECMAScript-compatible Date/Time Library for Zig 0.17 · v0.1.0**

[API reference](https://carlos-sweb.github.io/z-date/) · [Release](https://github.com/carlos-sweb/z-date/releases/tag/v0.1.0) · [Benchmark results](benchmarks/results-fast.md)

Z-Date is a comprehensive date and time library for Zig that provides the JavaScript Date API surface (ECMA-262 §21.4). The test suite includes a differential suite whose expected values are **V8's actual output**, plus ports of official **test262** cases. See the [conformance matrix](#ecma-262-214-conformance-matrix) for the method-by-method scope and the few documented deviations.

## Features

- **ECMA-262 §21.4 conformance, verified against V8**: constructors, getters/setters, parsing, formatting, Annex B legacy methods — differential-tested against real V8 output
- **Real IANA timezone support**: system tzdata on Linux/macOS, Windows registry + CLDR mapping, 599 embeddable zones for WASM/embedded; historical DST transitions, POSIX TZ rules for far-future dates, and spec-mandated DST disambiguation
- **145 locales** (Day.js data) with numeric and long (`Intl`-like) date styles, lazily compiled — referencing one locale embeds only that locale
- **ISO 8601**: strict §21.4.3.2 grammar, extended ±YYYYYY years, plus V8-parity legacy parse formats
- **Wide Range**: ±273,785 years from Unix epoch (±8.64e15 ms), TimeClip-clamped constructors and calendar normalization
- **Pure Value Type**: `ZDate` is a pure 8-byte struct — no allocator or io stored internally
- **310 tests**, including fuzzing of the parsers and TimeClip/overflow edge cases
- **Zig 0.17 Native**: Uses `std.Io.Clock` for time acquisition

## Requirements

- Zig 0.17.0 or later

Zig 0.17 optimization modes are `debug`, `safe`, `fast`, and `small`; for example,
run `zig build test -Doptimize=fast` to test the optimized library.

## Installation

Add the versioned dependency from your project directory:

```bash
zig fetch --save=zdate https://github.com/carlos-sweb/z-date/archive/refs/tags/v0.1.0.tar.gz
```

Zig writes the dependency URL and its verified package hash to `build.zig.zon`.

Then in your `build.zig`:

```zig
const zdate = b.dependency("zdate", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("zdate", zdate.module("zdate"));
```

## Quick Start

```zig
const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    // Load the host's real timezone once at startup (optional: without it,
    // local time == UTC, which ECMA-262 permits for hosts without tz data).
    try ZDate.loadSystemTimezone(allocator, io, null);
    defer ZDate.clearLocalTimezone();

    // Create date from current time — io required for clock access.
    // Component getters return ?i32: null means Invalid Date (JS's NaN).
    const now = ZDate.now(io);
    std.debug.print("Current year: {d}\n", .{now.getFullYear().?});

    // Create date from timestamp — no io, no allocator
    const epoch = ZDate.fromTimestamp(0);
    std.debug.print("Unix epoch: {d}\n", .{epoch.getUTCFullYear().?}); // 1970

    // Create date from components — no allocator needed
    const custom = ZDate.fromComponentsUTC(
        2024, 0, 1,   // January 1, 2024
        12, 30, 0, 0  // 12:30:00.000
    );

    // Format as ISO 8601 — allocator required only for string output
    const iso_str = try custom.toISOString(allocator);
    defer allocator.free(iso_str);
    std.debug.print("ISO: {s}\n", .{iso_str}); // 2024-01-01T12:30:00.000Z

    // Localized output: 145 bundled locales, numeric or long style
    const es = try custom.toLocaleDateStringStyle(allocator, zdate.locales.es_cl, .long);
    defer allocator.free(es);
    std.debug.print("es-CL: {s}\n", .{es}); // 1 de enero de 2024

    // Parse ISO 8601 — no allocator needed
    const parsed = ZDate.fromISO8601("2024-12-25T00:00:00.000Z");
    std.debug.print("Christmas month: {d}\n", .{parsed.getUTCMonth().?}); // 11 (December)
}
```

## Design Philosophy

`ZDate` is a **pure 8-byte value type** — it only stores a `timestamp: i64` internally. Context objects like `allocator` and `io` are passed per-function only where strictly needed:

- **Constructors** — no allocator, no io (except `now()` which reads the clock)
- **Getters/Setters** — no allocator, no io (pure arithmetic on the timestamp)
- **Formatting methods** — `allocator` as parameter (they return owned `[]u8`)
- **`now()` / `nowTimestamp()`** — `io` as parameter (they read the system clock)

This keeps every `ZDate` instance lightweight and suitable for use in JS engine heaps.

## API Overview

Browse the [generated API reference](https://carlos-sweb.github.io/z-date/),
including signatures, parameters, errors and source links. It is rebuilt from
Zig doc comments after each push to `master`.

To browse locally, run `zig build docs`, then serve the generated files:

```bash
python3 -m http.server 8000 --directory zig-out/docs
```

Open http://localhost:8000/. The generated reference uses JavaScript and WebAssembly
to load its source archive, so serve it over HTTP rather than opening a `file://` URL.
See [DOCS.md](DOCS.md) for the build/publishing workflow. Summary of the surface:

| Group | Methods | Notes |
|---|---|---|
| Static | `now(io)`, `nowTimestamp(io)`, `parse(str)`, `UTC(...)`, `isLeapYear(y)` | `parse` returns a timestamp (`INVALID_TIME` on failure) |
| Constructors | `fromTimestamp`, `fromComponents[UTC]`, `fromISO8601`, `fromString` | Never fail — invalid input yields an Invalid Date, as in JS |
| Timezone (host) | `loadSystemTimezone`, `loadNamedTimezone`, `loadEmbeddedTimezone`, `setLocalTimezone`, `clearLocalTimezone` | Process-wide, like a JS engine's host environment |
| Getters | `get*` / `getUTC*` (8 components), `getTime`, `getTimezoneOffset`, `getYear` | Component getters return `?i32` — `null` ≡ JS `NaN` |
| Setters | `set*` / `setUTC*`, `setTime`, `setYear` | `setFullYear`/`setUTCFullYear`/`setYear` can repair Invalid Date; other component setters preserve it. `setTime` replaces the timestamp. Results are TimeClip-clamped. |
| Formatting | `toString`, `toDateString`, `toTimeString`, `toISOString`, `toJSON`, `toUTCString`, `toGMTString`, `toLocale*String[Style]` | Take `allocator`, return owned `[]u8`; `toJSON` returns `!?[]u8` (`null` for Invalid Date) |
| Arithmetic | `add{Milliseconds,Seconds,Minutes,Hours,Days}` (`!ZDate`), `diff*` (`?i64`) | `diff*` return `null` if either date is invalid |
| Comparison | `equals`, `before`, `after` (`bool`), `compare` (`?std.math.Order`) | NaN semantics: always false / `null` with an Invalid Date |
| Validation | `isValid()`, `valueOf()` | |
| Data namespaces | `zdate.locales` (145 locales), `zdate.zones` (599 IANA zones), `zdate.windows_zones` | Individually lazy — you embed only what you reference |

## Usage Examples

### Creating Dates

```zig
// Current date/time — requires io from std.process.Init
const now = ZDate.now(io);

// From timestamp (milliseconds since Unix epoch) — pure, no io
const epoch = ZDate.fromTimestamp(0);

// From components (year, month, day, hour, minute, second, millisecond)
const date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);

// From ISO 8601 string — pure, no allocator
const parsed = ZDate.fromISO8601("2024-01-01T00:00:00.000Z");

// From various string formats
const from_str = ZDate.fromString("01/15/2024");
```

### Getting the Current Timestamp

```zig
pub fn main(init: std.process.Init) !void {
    const io = init.io;

    // Current timestamp in milliseconds
    const ms = ZDate.nowTimestamp(io);
    std.debug.print("Timestamp: {d}\n", .{ms});

    // Current date object (getters return ?i32; null = Invalid Date)
    const today = ZDate.now(io);
    std.debug.print("Year: {d}\n", .{today.getFullYear().?});
}
```

### Formatting Dates

```zig
const date = ZDate.fromComponentsUTC(2024, 11, 25, 0, 0, 0, 0);

// ISO 8601 format — allocator required, caller frees
const iso = try date.toISOString(allocator);
defer allocator.free(iso);
// Output: "2024-12-25T00:00:00.000Z"

// Date string
const date_str = try date.toDateString(allocator);
defer allocator.free(date_str);
// Output: "Wed Dec 25 2024"

// UTC string
const utc = try date.toUTCString(allocator);
defer allocator.free(utc);
// Output: "Wed, 25 Dec 2024 00:00:00 GMT"
```

### Parsing Dates

```zig
// ISO 8601 formats — all return ZDate directly, no try needed
const d1 = ZDate.fromISO8601("2024-01-01T00:00:00.000Z");
const d2 = ZDate.fromISO8601("2024-01-01");

// Parse to raw timestamp
const ts1 = ZDate.parse("2024-01-01T00:00:00.000Z");
const ts2 = ZDate.parse("01/15/2024");

// Check if parsing succeeded
if (d1.isValid()) {
    // Valid date
}
```

### Date Arithmetic

```zig
const date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);

// add* methods return !ZDate — use try
const next_week = try date.addDays(7);
const later     = try date.addHours(3);
const earlier   = try date.addMinutes(-30);

// diff* methods return ?i64 — null if either date is Invalid Date
const diff_days = next_week.diffDays(date).?;      // 7
const diff_ms   = next_week.diffMilliseconds(date).?;
```

### Comparison

```zig
const date1 = ZDate.fromComponentsUTC(2024, 0, 1,  0, 0, 0, 0);
const date2 = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);

if (date1.equals(date2)) { }   // false
if (date1.before(date2)) { }   // true
if (date2.after(date1))  { }   // true

// compare returns ?std.math.Order — null if either date is Invalid Date
// (JS NaN semantics: no ordering relation holds).
const order = date1.compare(date2).?; // .lt
```

### Error Handling for Arithmetic

```zig
const ZDateError = zdate.ZDateError;

const result = date.addMilliseconds(huge_value);
if (result) |new_date| {
    // Success — use new_date
    _ = new_date;
} else |err| switch (err) {
    ZDateError.OutOfRange       => {},
    ZDateError.TimestampOverflow => {},
    else => {},
}
```

### Leap Years

```zig
const is_2024_leap = ZDate.isLeapYear(2024); // true
const is_2023_leap = ZDate.isLeapYear(2023); // false
const is_2000_leap = ZDate.isLeapYear(2000); // true
const is_1900_leap = ZDate.isLeapYear(1900); // false

const feb29 = ZDate.fromComponentsUTC(2024, 1, 29, 0, 0, 0, 0);
```

### Timezone Handling

```zig
// Load the host's zone once at startup (TZ env var, then /etc/localtime;
// on Windows: registry name -> CLDR mapping -> embedded tzdata).
try ZDate.loadSystemTimezone(allocator, io, null);
defer ZDate.clearLocalTimezone();

// Or pick a specific IANA zone from the system tzdata...
try ZDate.loadNamedTimezone(allocator, io, "America/Santiago");

// ...or from the embedded database (works on WASM/Windows; embeds ~1.4 MB)
try ZDate.loadEmbeddedTimezone(allocator, "Asia/Tokyo");

// ...or embed exactly ONE zone (only that zone's ~2 KB goes in the binary)
ZDate.setLocalTimezone(try zdate.Timezone.parseBytes(allocator, zdate.zones.america_santiago));

const date = ZDate.fromComponentsUTC(2024, 5, 15, 12, 0, 0, 0);
const utc_hour = date.getUTCHours().?;      // 12
const local_hour = date.getHours().?;       // 8 in Santiago (winter, -04:00)
const offset = date.getTimezoneOffset().?;  // 240 (UTC - local, in minutes)

// DST is handled per-date, including the spec's disambiguation for local
// times that repeat or never exist around a transition (tc39/ecma262#778).
```

### Localized Formatting

```zig
const date = ZDate.fromComponentsUTC(2024, 0, 15, 14, 30, 0, 0);

// Numeric style honors each locale's date order and separators
const us = try date.toLocaleDateString(allocator, zdate.locales.en_us); // "01/15/2024"
defer allocator.free(us);

// Long style matches Intl.DateTimeFormat's dateStyle: "long"
const cl = try date.toLocaleDateStringStyle(allocator, zdate.locales.es_cl, .long);
defer allocator.free(cl); // "15 de enero de 2024"

const jp = try date.toLocaleDateStringStyle(allocator, zdate.locales.ja, .long);
defer allocator.free(jp); // "2024年1月15日"

// null locale defaults to en-US
const default_style = try date.toLocaleString(allocator, null);
defer allocator.free(default_style); // "01/15/2024, 02:30:00 PM"
```

### Testing with io

In tests, create a lightweight `std.Io.Threaded` backend:

```zig
test "now() creates valid date" {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    const date = ZDate.now(io);
    try std.testing.expect(date.isValid());
}

test "nowTimestamp() returns positive value" {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    const ms = ZDate.nowTimestamp(io);
    std.debug.print("Timestamp: {d}\n", .{ms});
    try std.testing.expect(ms > 0);
}
```

## Constants

```zig
const Constants = zdate.Constants;

// Time conversions
const ms_per_second = Constants.MS_PER_SECOND; // 1_000
const ms_per_minute = Constants.MS_PER_MINUTE; // 60_000
const ms_per_hour   = Constants.MS_PER_HOUR;   // 3_600_000
const ms_per_day    = Constants.MS_PER_DAY;     // 86_400_000

// Valid range
const max_time = Constants.MAX_TIME; //  8_640_000_000_000_000
const min_time = Constants.MIN_TIME; // -8_640_000_000_000_000

// Invalid date marker
const invalid = Constants.INVALID_TIME;
```

## Error Types

```zig
const ZDateError = zdate.ZDateError;

// OutOfMemory      — allocator failed during string formatting
// InvalidDate      — invalid date representation (e.g. toISOString on Invalid Date)
// InvalidFormat    — invalid date string format
// OutOfRange       — timestamp out of valid range
// TimestampOverflow — arithmetic overflow in add* methods
```

## Building

```bash
# Configure the project
zig build

# Run tests
zig build test --summary all

# Generate documentation
zig build docs
```

## Architecture

Z-Date is organized into modular components:

- `constants.zig` — Time constants and conversions
- `errors.zig` — Error types
- `timezone.zig` — Process-wide local timezone state (host-environment model)
- `tzdata.zig` — TZif loading (via `std.Tz`), offset lookup, POSIX TZ rules, DST disambiguation
- `calendar.zig` — Calendar calculations (leap years, days in month, normalization)
- `getters.zig` — Date component getters
- `setters.zig` — Date component setters
- `formatting.zig` — String formatting methods (incl. locale-aware styles)
- `parsing.zig` — String parsing (strict ISO 8601 + V8-parity legacy grammar)
- `arithmetic.zig` — Date arithmetic and comparison
- `locale.zig` + `locales/` — `Locale` type and 145 bundled locales (one file each, lazily compiled)
- `zones.zig` + `zones/` — 599 embedded IANA TZif zones (one lazy declaration each; generated)
- `windows_zones.zig` — Windows↔IANA zone name mapping (CLDR data; generated)
- `zdate.zig` — Main ZDate struct and API

## Design Decisions

### Pure 8-byte Value Type

`ZDate` stores only `timestamp: i64`. No allocator, no io context. This means:
- Zero overhead per instance on the JS engine heap
- Safe to copy, pass by value, and store in arrays
- Allocator passed only to formatting methods that return `[]u8`
- `io` passed only to `now()` and `nowTimestamp()` for clock access

### Timestamp Representation

- Uses `i64` for timestamps (milliseconds since Unix epoch)
- Range: ±273,785 years from epoch (±8.64e15 milliseconds)
- Invalid dates represented by `std.math.maxInt(i64)`

### Zig 0.17 Clock API

Uses `std.Io.Clock.real.now(io).toMilliseconds()` for wall-clock time, integrating cleanly with Zig 0.17's unified I/O backend system (`std.Io.Threaded`, `std.Io.Evented`).

### Error Strategy

- Constructors never fail — invalid inputs produce an `Invalid Date` (same as JS)
- `add*` arithmetic methods return `!ZDate` — overflow and out-of-range are real errors
- Formatting methods return `![]u8` — allocation can fail
- `fromISO8601` returns `ZDate` — parse errors produce `Invalid Date` via `catch`

### Timezone Handling

- The local zone is **process-wide state**, mirroring ECMA-262's model where
  the timezone belongs to the host environment, not to each Date value — so
  `ZDate` stays an 8-byte value type and no method signature carries a zone
- Component getters/setters are available in both UTC and local variants
- Backed by real IANA tzdata (TZif via `std.Tz`), not fixed offsets: historic
  DST transitions, POSIX TZ footer rules beyond the table, and the spec's
  local→UTC disambiguation at transitions
- Until a zone is loaded, local == UTC (offset 0) — the behavior ECMA-262
  prescribes for hosts without timezone data

## Performance comparison

The pre-optimization Zig 0.17 code is preserved in `benchmarks/baseline-zig-0.17.tar.gz`
with a SHA-256 manifest. `zig build test` includes differential tests against that
snapshot; those tests and benchmarks require Python 3 for verified extraction.

Run `python3 scripts/benchmark.py --runs 3 --mode fast` for paired measurements.
The runner fixes CPU affinity on Linux, warms both versions, alternates execution
order, checks matching checksums, and writes raw samples plus median results to
`benchmarks/results-fast.{csv,json,md}`. Use `--mode safe` to measure safety-enabled
builds. `zig build benchmark -Doptimize=fast` runs one process and prints raw samples.

The POSIX transition cache holds one rule/year per thread, performs no allocation,
and compares rule values so changing zones cannot reuse stale entries. WASM uses
the uncached calculation. ZDate remains an 8-byte value.

Measured on Linux x86_64 with Zig 0.17.0 `fast`, three processes and seven
alternating pairs per case (21 samples per version). Median speedups included
5.57× for `getUTCHours`, 9.37× for `getUTCMilliseconds`, 4.59× for `setUTCHours`,
and 2.09× for numeric `toLocaleString` on 2000–2030 Santiago timestamps.
Combined localized formatting dropped from seven allocations to one in the
measured sample. The POSIX offset path reached 12.76× for dates within 2200,
and 1.36× for random future years; historical offset queries were effectively
unchanged. These are per-operation benchmarks, not an application-wide speedup.
See [all 33 cases, raw samples and dispersion](benchmarks/results-fast.md).

## Compatibility

- **Zig Version**: 0.17.0 or later
- **ECMAScript**: Full Date API compatibility (see the conformance matrix below)
- **ISO 8601**: Complete parsing and formatting support
- **Platforms**: Linux, macOS, Windows (all platforms supported by Zig)

## ECMA-262 §21.4 Conformance Matrix

Every behavior below is covered by the test suite (310 tests), including a
differential suite (`tests/v8_differential_test.zig`) whose expected values
are V8's actual output — 150 random timestamps across the full ±8.64e15 range
plus DST-transition edge cases — and ports of official test262 cases
(`tests/test262_port_test.zig`).

| Area | Status | Notes |
|---|---|---|
| Time range ±8.64e15 ms (TimeClip) | ✅ | Out-of-range → Invalid Date everywhere (constructors, setters, parse) |
| Constructors: normalization (MakeDay/MakeTime) | ✅ | Month/day/time overflow rolls over, `(2024, 13, 1)` → Feb 2025; two-digit years map to 1900-1999 (MakeFullYear) |
| Getters (`get*`/`getUTC*`) | ✅ | Return `?i32`; `null` ≡ JS `NaN` for Invalid Date |
| `getTimezoneOffset` | ✅ | Per-date (changes across DST), `null` for Invalid Date |
| Setters (`set*`/`setUTC*`, `setTime`) | ✅ | Year setters can repair Invalid Date; `setTime` replaces it; other component setters preserve Invalid Date. Results clamped by TimeClip. |
| `Date.parse`: ISO 8601 (§21.4.3.2) | ✅ | Strict positional grammar; extended ±YYYYYY years; ±HH:mm offsets; date-only → UTC, date-time w/o offset → local |
| `Date.parse`: legacy formats | ✅ | V8-parity grammar: `toString`/`toUTCString` round-trips, month names, AM/PM, `2024/01/15`, ISO-with-space, bare ±HHMM offsets, parenthesized zone names; local-time semantics as in V8 |
| Formatting (`toISOString`, `toUTCString`, `toString`, …) | Partial | Expanded ISO years and UTC format cases pass. Local `toString`/`toTimeString` currently label the offset as `GMT+0000`; see limitations. |
| `toJSON` | ✅ | `null` (not an error) for Invalid Date |
| NaN comparison semantics | ✅ | `equals`/`before`/`after` false and `compare`/`diff*` `null` when either date is invalid |
| Local timezone (LocalTZA) | ✅ | Real IANA tzdata via `std.Tz` (RFC 8536): system zone (TZ env, `/etc/localtime`, Windows registry name via CLDR mapping), historical DST transitions, POSIX TZ footer rules for dates beyond the table, and the spec's local-time disambiguation (tc39/ecma262#778) |
| Annex B (`getYear`, `setYear`, `toGMTString`) | ✅ | `setYear` repairs Invalid Date via the same epoch fallback as `setFullYear`. |
| `toLocale*String` | ✅* | 145 locales (Day.js data) with numeric and long (`Intl` `dateStyle: "long"`-like) styles; not CLDR/ICU-backed |

**Documented deviations** (deliberate, all covered by tests):
`null` replaces JS `NaN` throughout (Zig has no NaN-able integers);
`toLocale*` uses bundled Day.js-derived locale data rather than full CLDR. Hosts without timezone data
run with offset 0, which ECMA-262 explicitly permits.

### Current limitations

- `toString` and `toTimeString` render local clock components but currently print
  `GMT+0000` even when a non-UTC zone is configured. Use `toISOString` or
  `toUTCString` for an unambiguous absolute-time representation.
- For `addSeconds`, `addMinutes`, `addHours` and `addDays`, the scaled duration must
  fit `i64`. Extreme arguments can overflow before the checked addition.
- Prefer constructors and setters over writing `timestamp` directly; calendar
  component setters assume the existing value is valid or the invalid sentinel.
- Local timezone configuration is process-wide. Configure it once before
  concurrent use. No zone is loaded implicitly; local time defaults to UTC.

### Timezone data

- **Linux/macOS**: reads the system's tzdata (`ZDate.loadSystemTimezone`).
- **Windows**: `GetDynamicTimeZoneInformation` → CLDR `windowsZones` mapping →
  embedded tzdata.
- **WASM/embedded**: 599 IANA zones vendored under `src/zones/`; each is an
  individual lazy declaration, so referencing one zone embeds only that zone
  (~2 KB); name-based lookup (`zones.find`, `loadEmbeddedTimezone`) opts into
  the full database (~1.4 MB). Refresh with `scripts/update_tzdata.py`.

## Contributing

Contributions are welcome! Please ensure:

1. All tests pass (`zig build test --summary all`)
2. Code follows Zig style guidelines
3. New features include tests
4. Documentation is updated

## License

MIT License — see LICENSE file for details

## Related Projects

- [Z-Number](../z-number) — ECMAScript Number implementation in Zig

## Documentation

For Spanish documentation, see [README.es.md](README.es.md).

---

**Z-Date** — Built with Zig 0.17 for high-performance JavaScript engines