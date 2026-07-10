const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

// Ports of ECMA-262 conformance cases from the official test262 suite
// (https://github.com/tc39/test262, test/built-ins/Date/). Each test cites
// the source test file it transcribes. JS's NaN maps to this library's
// INVALID_TIME/null convention; behaviors tied to JS object semantics
// (prototypes, coercion, property descriptors) are out of scope for a value
// type and are not ported.

// --- TimeClip (test/built-ins/Date/15.9.1.14 family) ---

test "test262 TimeClip: |t| > 8.64e15 is NaN (setTime clamps to Invalid Date)" {
    var date = ZDate.fromTimestamp(0);
    try std.testing.expectEqual(Constants.INVALID_TIME, date.setTime(8_640_000_000_000_001));
    try std.testing.expectEqual(Constants.INVALID_TIME, date.setTime(-8_640_000_000_000_001));
    // Exactly ±8.64e15 is still valid.
    try std.testing.expectEqual(@as(i64, 8_640_000_000_000_000), date.setTime(8_640_000_000_000_000));
    try std.testing.expectEqual(@as(i64, -8_640_000_000_000_000), date.setTime(-8_640_000_000_000_000));
}

// --- Date.UTC (test/built-ins/Date/UTC/) ---

test "test262 Date.UTC: epoch is 0 and defaults fill in (UTC/return-value.js)" {
    try std.testing.expectEqual(@as(i64, 0), ZDate.UTC(1970, 0, 1, 0, 0, 0, 0));
    // Omitted arguments default: day=1, time=00:00:00.000.
    try std.testing.expectEqual(@as(i64, 0), ZDate.UTC(1970, 0, null, null, null, null, null));
}

test "test262 Date.UTC: two-digit years map to 1900+ (UTC/year-number-relative.js)" {
    const t = ZDate.UTC(70, 0, 1, 0, 0, 0, 0);
    const date = ZDate.fromTimestamp(t);
    try std.testing.expectEqual(@as(i32, 1970), date.getUTCFullYear().?);
}

// --- Constructor normalization (test/built-ins/Date/S15.9.3.1_A3 family) ---

test "test262 constructor: month 12 wraps to January of the next year" {
    const a = ZDate.fromComponentsUTC(2000, 12, 1, 0, 0, 0, 0);
    const b = ZDate.fromComponentsUTC(2001, 0, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(b.getTime(), a.getTime());
}

test "test262 constructor: day 0 is the last day of the previous month" {
    const a = ZDate.fromComponentsUTC(2000, 1, 0, 0, 0, 0, 0);
    const b = ZDate.fromComponentsUTC(2000, 0, 31, 0, 0, 0, 0);
    try std.testing.expectEqual(b.getTime(), a.getTime());
}

// --- Date.parse (test/built-ins/Date/parse/) ---

test "test262 parse: zero.js - the ISO epoch string parses to +0" {
    try std.testing.expectEqual(@as(i64, 0), ZDate.parse("1970-01-01T00:00:00.000Z"));
}

test "test262 parse: date-only forms are UTC, date-time-without-offset is local (time-value-maximum-range.js context)" {
    // With no local timezone loaded, local == UTC, so both agree; the
    // semantic distinction itself is covered in timezone_test.zig.
    try std.testing.expectEqual(@as(i64, 946684800000), ZDate.parse("2000-01-01"));
    try std.testing.expectEqual(@as(i64, 8_640_000_000_000_000), ZDate.parse("+275760-09-13T00:00:00.000Z"));
    try std.testing.expectEqual(@as(i64, -8_640_000_000_000_000), ZDate.parse("-271821-04-20T00:00:00.000Z"));
    // One millisecond beyond the range must not produce a time value.
    try std.testing.expectEqual(Constants.INVALID_TIME, ZDate.parse("+275760-09-13T00:00:00.001Z"));
}

// --- toISOString (test/built-ins/Date/prototype/toISOString/) ---

test "test262 toISOString: 15.9.5.43-0-8 - epoch renders as 1970-01-01T00:00:00.000Z" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(0);
    const str = try date.toISOString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("1970-01-01T00:00:00.000Z", str);
}

test "test262 toISOString: 15.9.5.43-0-13 - extended years use the signed 6-digit form" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(Constants.MIN_TIME);
    const str = try date.toISOString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("-271821-04-20T00:00:00.000Z", str);
}

test "test262 toISOString: 15.9.5.43-0-15 - invalid time value throws (here: error)" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(Constants.INVALID_TIME);
    try std.testing.expectError(zdate.ZDateError.InvalidDate, date.toISOString(allocator));
}

// --- toUTCString (test/built-ins/Date/prototype/toUTCString/format.js) ---

test "test262 toUTCString: format.js - epoch renders as 'Thu, 01 Jan 1970 00:00:00 GMT'" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(0);
    const str = try date.toUTCString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("Thu, 01 Jan 1970 00:00:00 GMT", str);
}

// --- Component getters (test/built-ins/Date/prototype/getUTCDay/, etc.) ---

test "test262 getUTCDay: epoch was a Thursday (day 4)" {
    const date = ZDate.fromTimestamp(0);
    try std.testing.expectEqual(@as(i32, 4), date.getUTCDay().?);
}

test "test262 getters: NaN time value yields NaN (here: null) for every component" {
    const date = ZDate.fromTimestamp(Constants.INVALID_TIME);
    try std.testing.expectEqual(@as(?i32, null), date.getUTCFullYear());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCMonth());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCDate());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCDay());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCHours());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCMinutes());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCSeconds());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCMilliseconds());
    try std.testing.expectEqual(@as(?i32, null), date.getTimezoneOffset());
}

// --- Setters on Invalid Date (test/built-ins/Date/prototype/setUTCHours/ etc.) ---

test "test262 setters: operating on an Invalid Date keeps NaN" {
    var date = ZDate.fromTimestamp(Constants.INVALID_TIME);
    try std.testing.expectEqual(Constants.INVALID_TIME, date.setUTCHours(10, null, null, null));
    try std.testing.expect(!date.isValid());
}

// --- Annex B (test/annexB/built-ins/Date/prototype/getYear|setYear/) ---

test "test262 annexB getYear: B.2.4 - returns YearFromTime minus 1900" {
    const date = ZDate.fromComponentsUTC(2000, 0, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 100), date.getYear().?);
}

test "test262 annexB setYear: B.2.5 - values 0-99 map to 1900-1999" {
    var date = ZDate.fromComponentsUTC(2000, 0, 1, 0, 0, 0, 0);
    _ = date.setYear(0);
    try std.testing.expectEqual(@as(i32, 1900), date.getUTCFullYear().?);
    _ = date.setYear(99);
    try std.testing.expectEqual(@as(i32, 1999), date.getUTCFullYear().?);
    _ = date.setYear(100);
    try std.testing.expectEqual(@as(i32, 100), date.getUTCFullYear().?);
}
