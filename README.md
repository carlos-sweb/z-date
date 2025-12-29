# Z-Date

**ECMAScript-compatible Date/Time Library for Zig 0.15**

Z-Date is a comprehensive date and time library for Zig that implements the full JavaScript Date API specification. Designed as a core component for JavaScript engines (like Bun/QuickJS), it provides 100% compatibility with ECMAScript Date, including all static methods, instance methods, timezone handling (UTC and local), string parsing, and ISO 8601 formatting.

## Features

- **Full ECMAScript Date Compatibility**: Implements all JavaScript Date methods
- **Timezone Support**: Both UTC and local timezone operations
- **ISO 8601**: Complete parsing and formatting support
- **High Precision**: Millisecond precision timestamps
- **Wide Range**: Supports dates from ±273,785 years from Unix epoch
- **Type Safety**: Leverages Zig's type system for compile-time safety
- **Comprehensive Tests**: 150+ tests ensuring correctness
- **Labeled Blocks**: Modern Zig 0.15 features for better code organization

## Requirements

- Zig 0.15.x or later

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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create date from current time
    const now = try ZDate.now(allocator);
    std.debug.print("Current year: {}\n", .{now.getFullYear()});

    // Create date from timestamp
    const date = try ZDate.fromTimestamp(allocator, 0);
    std.debug.print("Unix epoch: {}\n", .{date.getUTCFullYear()}); // 1970

    // Create date from components
    const custom = try ZDate.fromComponentsUTC(
        allocator,
        2024, 0, 1, // January 1, 2024
        12, 30, 0, 0 // 12:30:00.000
    );

    // Format as ISO 8601
    const iso_str = try custom.toISOString();
    defer allocator.free(iso_str);
    std.debug.print("ISO: {s}\n", .{iso_str}); // 2024-01-01T12:30:00.000Z

    // Parse ISO 8601
    const parsed = try ZDate.fromISO8601(allocator, "2024-12-25T00:00:00.000Z");
    std.debug.print("Christmas: {}\n", .{parsed.getUTCMonth()}); // 11 (December)
}
```

## API Reference

### Static Methods

| Method | Description | Example |
|--------|-------------|---------|
| `ZDate.now(allocator)` | Create date with current time | `const d = try ZDate.now(alloc);` |
| `ZDate.nowTimestamp()` | Get current timestamp (ms) | `const ts = ZDate.nowTimestamp();` |
| `ZDate.parse(str)` | Parse date string to timestamp | `const ts = ZDate.parse("2024-01-01");` |
| `ZDate.UTC(...)` | Create UTC timestamp from components | `const ts = ZDate.UTC(2024, 0, 1, 0, 0, 0, 0);` |
| `ZDate.isLeapYear(year)` | Check if year is leap year | `const is_leap = ZDate.isLeapYear(2024);` |

### Constructors

| Method | Description |
|--------|-------------|
| `fromTimestamp(allocator, ms)` | Create from milliseconds since epoch |
| `fromComponents(allocator, year, month, ...)` | Create from date/time components (local) |
| `fromComponentsUTC(allocator, year, month, ...)` | Create from date/time components (UTC) |
| `fromISO8601(allocator, str)` | Create from ISO 8601 string |
| `fromString(allocator, str)` | Create from various date string formats |

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

| Method | Output Format | Example |
|--------|---------------|---------|
| `toString()` | Full date/time string | "Mon Jan 01 2024 00:00:00 GMT+0000" |
| `toDateString()` | Date only | "Mon Jan 01 2024" |
| `toTimeString()` | Time only | "00:00:00 GMT+0000" |
| `toISOString()` | ISO 8601 (UTC) | "2024-01-01T00:00:00.000Z" |
| `toJSON()` | JSON (same as ISO) | "2024-01-01T00:00:00.000Z" |
| `toUTCString()` | UTC string | "Mon, 01 Jan 2024 00:00:00 GMT" |
| `toLocaleDateString(?locale)` | Localized date | "01/01/2024" |
| `toLocaleTimeString(?locale)` | Localized time | "00:00:00" |
| `toLocaleString(?locale)` | Localized date/time | "01/01/2024, 00:00:00" |

### Arithmetic & Comparison

| Method | Description |
|--------|-------------|
| `addMilliseconds(ms)` | Add/subtract milliseconds |
| `addSeconds(sec)` | Add/subtract seconds |
| `addMinutes(min)` | Add/subtract minutes |
| `addHours(hours)` | Add/subtract hours |
| `addDays(days)` | Add/subtract days |
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
// Current date/time
const now = try ZDate.now(allocator);

// From timestamp (milliseconds since Unix epoch)
const epoch = try ZDate.fromTimestamp(allocator, 0);

// From components (year, month, day, hour, minute, second, millisecond)
const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);

// From ISO 8601 string
const parsed = try ZDate.fromISO8601(allocator, "2024-01-01T00:00:00.000Z");
```

### Formatting Dates

```zig
const date = try ZDate.fromComponentsUTC(allocator, 2024, 11, 25, 0, 0, 0, 0);

// ISO 8601 format
const iso = try date.toISOString();
defer allocator.free(iso);
// Output: "2024-12-25T00:00:00.000Z"

// Date string
const date_str = try date.toDateString();
defer allocator.free(date_str);
// Output: "Wed Dec 25 2024"

// UTC string
const utc = try date.toUTCString();
defer allocator.free(utc);
// Output: "Wed, 25 Dec 2024 00:00:00 GMT"
```

### Parsing Dates

```zig
// ISO 8601 formats
const ts1 = ZDate.parse("2024-01-01T00:00:00.000Z");
const ts2 = ZDate.parse("2024-01-01");
const ts3 = ZDate.parse("2024-06");

// Slash format
const ts4 = ZDate.parse("01/15/2024");

// Check if parsing succeeded
if (ts1 != zdate.Constants.INVALID_TIME) {
    // Valid timestamp
}
```

### Date Arithmetic

```zig
const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);

// Add 7 days
const next_week = try date.addDays(7);

// Add 3 hours
const later = try date.addHours(3);

// Subtract 30 minutes
const earlier = try date.addMinutes(-30);

// Calculate difference
const diff_days = next_week.diffDays(date); // 7
const diff_ms = next_week.diffMilliseconds(date);
```

### Comparison

```zig
const date1 = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
const date2 = try ZDate.fromComponentsUTC(allocator, 2024, 0, 15, 0, 0, 0, 0);

// Equality
if (date1.equals(date2)) { }

// Ordering
if (date1.before(date2)) { } // true
if (date2.after(date1)) { } // true

// Three-way comparison
const order = date1.compare(date2); // .lt
```

### Leap Years

```zig
// Check leap year
const is_2024_leap = ZDate.isLeapYear(2024); // true
const is_2023_leap = ZDate.isLeapYear(2023); // false
const is_2000_leap = ZDate.isLeapYear(2000); // true
const is_1900_leap = ZDate.isLeapYear(1900); // false

// Create leap year date
const feb29 = try ZDate.fromComponentsUTC(allocator, 2024, 1, 29, 0, 0, 0, 0);
```

### Timezone Handling

```zig
const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);

// UTC getters
const utc_hour = date.getUTCHours(); // 0

// Local getters (depends on system timezone)
const local_hour = date.getHours(); // May differ from UTC

// Timezone offset in minutes
const offset = date.getTimezoneOffset();
```

## Constants

```zig
const Constants = zdate.Constants;

// Time conversions
const ms_per_second = Constants.MS_PER_SECOND; // 1000
const ms_per_minute = Constants.MS_PER_MINUTE; // 60000
const ms_per_hour = Constants.MS_PER_HOUR; // 3600000
const ms_per_day = Constants.MS_PER_DAY; // 86400000

// Valid range
const max_time = Constants.MAX_TIME; // 8,640,000,000,000,000
const min_time = Constants.MIN_TIME; // -8,640,000,000,000,000

// Invalid date marker
const invalid = Constants.INVALID_TIME;
```

## Error Handling

```zig
const ZDateError = zdate.ZDateError;

// Possible errors:
// - OutOfMemory: Memory allocation failed
// - InvalidDate: Invalid date representation
// - InvalidFormat: Invalid date string format
// - OutOfRange: Timestamp out of valid range
// - TimestampOverflow: Arithmetic overflow

// Example:
const result = date.addMilliseconds(huge_value);
if (result) |new_date| {
    // Success
} else |err| switch (err) {
    ZDateError.OutOfRange => {},
    ZDateError.TimestampOverflow => {},
    else => {},
}
```

## Building

```bash
# Build library
zig build

# Run tests
zig build test

# Generate documentation
zig build docs
```

## Testing

The library includes 150+ comprehensive tests covering:

- Constants validation
- Constructor functionality
- Getter methods (local and UTC)
- Setter methods (local and UTC)
- Parsing (ISO 8601, various formats)
- Formatting (all output formats)
- Timezone handling
- Arithmetic operations
- Edge cases (leap years, boundaries, overflow)
- ISO 8601 round-trip

Run tests with:

```bash
zig build test
```

## Architecture

Z-Date is organized into modular components:

- `constants.zig` - Time constants and conversions
- `errors.zig` - Error types
- `timezone.zig` - Timezone utilities (UTC/local)
- `calendar.zig` - Calendar calculations (leap years, days in month)
- `getters.zig` - Date component getters
- `setters.zig` - Date component setters
- `formatting.zig` - String formatting methods
- `parsing.zig` - String parsing methods
- `arithmetic.zig` - Date arithmetic and comparison
- `zdate.zig` - Main ZDate struct and API

## Design Decisions

### Timestamp Representation

- Uses `i64` for timestamps (milliseconds since Unix epoch)
- Range: ±273,785 years from epoch (±8.64e15 milliseconds)
- Invalid dates represented by `std.math.maxInt(i64)`

### Timezone Handling

- Dual mode: UTC and local timezone operations
- All methods available in both UTC and local variants
- Timezone offset detection (platform-specific)

### Labeled Blocks

Uses Zig 0.15 labeled blocks for better code organization:
- Validation blocks in constructors
- Formatting blocks in output methods
- Parsing blocks in input methods
- Arithmetic operation blocks

### Memory Management

- Requires allocator for string operations
- Formatted strings must be freed by caller
- No hidden allocations

## Compatibility

- **Zig Version**: 0.15.x or later
- **ECMAScript**: Full Date API compatibility
- **ISO 8601**: Complete parsing and formatting support
- **Platforms**: All platforms supported by Zig

## Contributing

Contributions are welcome! Please ensure:

1. All tests pass (`zig build test`)
2. Code follows Zig style guidelines
3. New features include tests
4. Documentation is updated

## License

MIT License - see LICENSE file for details

## Related Projects

- [Z-Number](../z-number) - ECMAScript Number implementation in Zig

## Documentation

For Spanish documentation, see [README.es.md](README.es.md).

## Support

For issues, questions, or contributions, please visit the GitHub repository.

---

**Z-Date** - Built with Zig 0.15 for high-performance JavaScript engines
