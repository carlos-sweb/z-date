# Z-Date

**ECMAScript-compatible Date/Time Library for Zig 0.16**

Z-Date is a comprehensive date and time library for Zig that implements the full JavaScript Date API specification. Designed as a core component for JavaScript engines, it provides 100% compatibility with ECMAScript Date, including all static methods, instance methods, timezone handling (UTC and local), string parsing, and ISO 8601 formatting.

## Features

- **Full ECMAScript Date Compatibility**: Implements all JavaScript Date methods
- **Timezone Support**: Both UTC and local timezone operations
- **ISO 8601**: Complete parsing and formatting support
- **High Precision**: Millisecond precision timestamps
- **Wide Range**: Supports dates from ±273,785 years from Unix epoch
- **Type Safety**: Leverages Zig's type system for compile-time safety
- **Pure Value Type**: `ZDate` is a pure 8-byte struct — no allocator or io stored internally
- **Comprehensive Tests**: 150+ tests ensuring correctness
- **Zig 0.16 Native**: Uses `std.Io.Clock` for time acquisition

## Requirements

- Zig 0.16.0 or later

## Installation

Add Z-Date to your `build.zig.zon`:

```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .zdate = .{
            .url = "https://github.com/yourusername/z-date/archive/main.tar.gz",
        },
    },
}
```

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

    // Create date from current time — io required for clock access
    const now = ZDate.now(io);
    std.debug.print("Current year: {}\n", .{now.getFullYear()});

    // Create date from timestamp — no io, no allocator
    const epoch = ZDate.fromTimestamp(0);
    std.debug.print("Unix epoch: {}\n", .{epoch.getUTCFullYear()}); // 1970

    // Create date from components — no allocator needed
    const custom = ZDate.fromComponentsUTC(
        2024, 0, 1,   // January 1, 2024
        12, 30, 0, 0  // 12:30:00.000
    );

    // Format as ISO 8601 — allocator required only for string output
    const iso_str = try custom.toISOString(allocator);
    defer allocator.free(iso_str);
    std.debug.print("ISO: {s}\n", .{iso_str}); // 2024-01-01T12:30:00.000Z

    // Parse ISO 8601 — no allocator needed
    const parsed = ZDate.fromISO8601("2024-12-25T00:00:00.000Z");
    std.debug.print("Christmas month: {}\n", .{parsed.getUTCMonth()}); // 11 (December)
}
```

## Design Philosophy

`ZDate` is a **pure 8-byte value type** — it only stores a `timestamp: i64` internally. Context objects like `allocator` and `io` are passed per-function only where strictly needed:

- **Constructors** — no allocator, no io (except `now()` which reads the clock)
- **Getters/Setters** — no allocator, no io (pure arithmetic on the timestamp)
- **Formatting methods** — `allocator` as parameter (they return owned `[]u8`)
- **`now()` / `nowTimestamp()`** — `io` as parameter (they read the system clock)

This keeps every `ZDate` instance lightweight and suitable for use in JS engine heaps.

## API Reference

### Static Methods

| Method | Description | Example |
|--------|-------------|---------|
| `ZDate.now(io)` | Create date with current time | `const d = ZDate.now(io);` |
| `ZDate.nowTimestamp(io)` | Get current timestamp (ms) | `const ts = ZDate.nowTimestamp(io);` |
| `ZDate.parse(str)` | Parse date string to timestamp | `const ts = ZDate.parse("2024-01-01");` |
| `ZDate.UTC(...)` | Create UTC timestamp from components | `const ts = ZDate.UTC(2024, 0, 1, 0, 0, 0, 0);` |
| `ZDate.isLeapYear(year)` | Check if year is leap year | `const leap = ZDate.isLeapYear(2024);` |

### Constructors

| Method | Description |
|--------|-------------|
| `fromTimestamp(ms)` | Create from milliseconds since epoch |
| `fromComponents(year, month, ...)` | Create from date/time components (local) |
| `fromComponentsUTC(year, month, ...)` | Create from date/time components (UTC) |
| `fromISO8601(str)` | Create from ISO 8601 string |
| `fromString(str)` | Create from various date string formats |

### Getters (Local Time)

| Method | Returns | Range |
|--------|---------|-------|
| `getFullYear()` | Year (4 digits) | Any integer |
| `getMonth()` | Month | 0-11 (0 = January) |
| `getDate()` | Day of month | 1-31 |
| `getDay()` | Day of week | 0-6 (0 = Sunday) |
| `getHours()` | Hours | 0-23 |
| `getMinutes()` | Minutes | 0-59 |
| `getSeconds()` | Seconds | 0-59 |
| `getMilliseconds()` | Milliseconds | 0-999 |
| `getTime()` | Timestamp (ms since epoch) | i64 |
| `getTimezoneOffset()` | Timezone offset (minutes) | Integer |

### Getters (UTC)

All getters have UTC equivalents: `getUTCFullYear()`, `getUTCMonth()`, `getUTCDate()`, `getUTCDay()`, `getUTCHours()`, `getUTCMinutes()`, `getUTCSeconds()`, `getUTCMilliseconds()`

### Setters (Local Time)

| Method | Description |
|--------|-------------|
| `setFullYear(year, ?month, ?day)` | Set year (optionally month and day) |
| `setMonth(month, ?day)` | Set month (optionally day) |
| `setDate(day)` | Set day of month |
| `setHours(hour, ?min, ?sec, ?ms)` | Set hours (optionally min, sec, ms) |
| `setMinutes(min, ?sec, ?ms)` | Set minutes (optionally sec, ms) |
| `setSeconds(sec, ?ms)` | Set seconds (optionally ms) |
| `setMilliseconds(ms)` | Set milliseconds |
| `setTime(timestamp)` | Set timestamp directly |

### Setters (UTC)

All setters have UTC equivalents: `setUTCFullYear()`, `setUTCMonth()`, `setUTCDate()`, `setUTCHours()`, `setUTCMinutes()`, `setUTCSeconds()`, `setUTCMilliseconds()`

### Formatting Methods

All formatting methods require an `allocator` and return owned `[]u8` — the caller is responsible for freeing.

| Method | Output Format | Example |
|--------|---------------|---------|
| `toString(allocator)` | Full date/time string | "Mon Jan 01 2024 00:00:00 GMT+0000" |
| `toDateString(allocator)` | Date only | "Mon Jan 01 2024" |
| `toTimeString(allocator)` | Time only | "00:00:00 GMT+0000" |
| `toISOString(allocator)` | ISO 8601 (UTC) | "2024-01-01T00:00:00.000Z" |
| `toJSON(allocator)` | JSON (same as ISO) | "2024-01-01T00:00:00.000Z" |
| `toUTCString(allocator)` | UTC string | "Mon, 01 Jan 2024 00:00:00 GMT" |
| `toLocaleDateString(allocator, ?locale)` | Localized date | "01/01/2024" |
| `toLocaleTimeString(allocator, ?locale)` | Localized time | "00:00:00" |
| `toLocaleString(allocator, ?locale)` | Localized date/time | "01/01/2024, 00:00:00" |

### Arithmetic & Comparison

| Method | Description |
|--------|-------------|
| `addMilliseconds(ms)` | Add/subtract milliseconds — returns `!ZDate` |
| `addSeconds(sec)` | Add/subtract seconds — returns `!ZDate` |
| `addMinutes(min)` | Add/subtract minutes — returns `!ZDate` |
| `addHours(hours)` | Add/subtract hours — returns `!ZDate` |
| `addDays(days)` | Add/subtract days — returns `!ZDate` |
| `diffMilliseconds(other)` | Difference in milliseconds |
| `diffSeconds(other)` | Difference in seconds |
| `diffMinutes(other)` | Difference in minutes |
| `diffHours(other)` | Difference in hours |
| `diffDays(other)` | Difference in days |
| `equals(other)` | Check equality |
| `before(other)` | Check if before |
| `after(other)` | Check if after |
| `compare(other)` | Three-way comparison |

### Validation

| Method | Description |
|--------|-------------|
| `isValid()` | Check if date is valid |
| `valueOf()` | Get primitive timestamp value |

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

    // Current date object
    const today = ZDate.now(io);
    std.debug.print("Year: {}\n", .{today.getFullYear()});
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

// diff* methods return i64 — no try needed
const diff_days = next_week.diffDays(date);      // 7
const diff_ms   = next_week.diffMilliseconds(date);
```

### Comparison

```zig
const date1 = ZDate.fromComponentsUTC(2024, 0, 1,  0, 0, 0, 0);
const date2 = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);

if (date1.equals(date2)) { }   // false
if (date1.before(date2)) { }   // true
if (date2.after(date1))  { }   // true

const order = date1.compare(date2); // .lt
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
const date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);

// UTC getters
const utc_hour = date.getUTCHours();  // 0

// Local getters (depends on system timezone)
const local_hour = date.getHours();   // may differ from UTC

// Timezone offset in minutes
const offset = date.getTimezoneOffset();
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
# Build library
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
- `timezone.zig` — Timezone utilities (UTC/local)
- `calendar.zig` — Calendar calculations (leap years, days in month)
- `getters.zig` — Date component getters
- `setters.zig` — Date component setters
- `formatting.zig` — String formatting methods
- `parsing.zig` — String parsing methods
- `arithmetic.zig` — Date arithmetic and comparison
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

### Zig 0.16 Clock API

Uses `std.Io.Clock.real.now(io).toMilliseconds()` for wall-clock time, integrating cleanly with Zig 0.16's unified I/O backend system (`std.Io.Threaded`, `std.Io.Evented`).

### Error Strategy

- Constructors never fail — invalid inputs produce an `Invalid Date` (same as JS)
- `add*` arithmetic methods return `!ZDate` — overflow and out-of-range are real errors
- Formatting methods return `![]u8` — allocation can fail
- `fromISO8601` returns `ZDate` — parse errors produce `Invalid Date` via `catch`

### Timezone Handling

- Dual mode: UTC and local timezone operations
- All methods available in both UTC and local variants
- Timezone offset detection is platform-specific

## Compatibility

- **Zig Version**: 0.16.0 or later
- **ECMAScript**: Full Date API compatibility
- **ISO 8601**: Complete parsing and formatting support
- **Platforms**: Linux, macOS, Windows (all platforms supported by Zig)

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

**Z-Date** — Built with Zig 0.16 for high-performance JavaScript engines