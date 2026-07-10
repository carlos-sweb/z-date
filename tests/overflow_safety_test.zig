const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

// Regression tests for a security review that found integer-overflow panics
// (process aborts) and a performance-DoS hang reachable through the plain
// public constructor/setter API, plus a missing range check that let
// out-of-range timestamps produce bogus formatted output instead of
// "Invalid Date". None of these inputs should crash, hang, or leak the
// out-of-range state past ZDate's public API.

test "extreme year no longer panics: fromComponentsUTC(2_000_000_000, ...)" {
    const date = ZDate.fromComponentsUTC(2_000_000_000, 0, 1, 0, 0, 0, 0);
    try std.testing.expect(!date.isValid());
}

test "extreme month no longer panics: fromComponentsUTC(2024, i32::MIN, ...)" {
    const date = ZDate.fromComponentsUTC(2024, std.math.minInt(i32), 1, 0, 0, 0, 0);
    // Not asserting valid/invalid here since the exact normalized result at
    // this extreme is not the point - the point is that it doesn't crash.
    _ = date.isValid();
}

test "extreme year no longer panics: fromComponentsUTC(i32::MIN, ...)" {
    const date = ZDate.fromComponentsUTC(std.math.minInt(i32), 0, 1, 0, 0, 0, 0);
    _ = date.isValid();
}

test "extreme month no longer panics: setMonth(i32::MIN)" {
    var date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);
    _ = date.setMonth(std.math.minInt(i32), null);
    _ = date.isValid();
}

test "extreme year no longer panics: setFullYear(i32::MIN)" {
    var date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);
    _ = date.setFullYear(std.math.minInt(i32), null, null);
    _ = date.isValid();
}

test "extreme day normalizes in O(1), not a multi-million-iteration loop" {
    // Previously ~70M+ loop iterations; now resolved via a closed-form
    // day-offset round trip instead of a per-month while loop.
    const date = ZDate.fromComponentsUTC(2024, 0, std.math.maxInt(i32), 0, 0, 0, 0);
    _ = date.isValid();
}

test "combined extreme month AND day still resolves without panicking or hanging" {
    const date = ZDate.fromComponentsUTC(2024, std.math.minInt(i32), std.math.maxInt(i32), 0, 0, 0, 0);
    _ = date.isValid();
}

test "legitimate overflow normalization still works after the overflow fix" {
    // (2024, 13, 1) -> Feb 1, 2025 (month is 0-based; 13 overflows two months
    // past December).
    const a = ZDate.fromComponentsUTC(2024, 13, 1, 0, 0, 0, 0);
    try std.testing.expect(a.isValid());
    try std.testing.expectEqual(@as(i32, 2025), a.getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 1), a.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 1), a.getUTCDate().?);

    // (2024, 0, 32) -> Feb 1, 2024
    const b = ZDate.fromComponentsUTC(2024, 0, 32, 0, 0, 0, 0);
    try std.testing.expect(b.isValid());
    try std.testing.expectEqual(@as(i32, 1), b.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 1), b.getUTCDate().?);

    // (2024, 0, 1, 25) -> Jan 2, 01:00
    const c = ZDate.fromComponentsUTC(2024, 0, 1, 25, 0, 0, 0);
    try std.testing.expect(c.isValid());
    try std.testing.expectEqual(@as(i32, 2), c.getUTCDate().?);
    try std.testing.expectEqual(@as(i32, 1), c.getUTCHours().?);

    // Day 0 of March == last day of February (2024 is a leap year).
    const d = ZDate.fromComponentsUTC(2024, 2, 0, 0, 0, 0, 0);
    try std.testing.expect(d.isValid());
    try std.testing.expectEqual(@as(i32, 1), d.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 29), d.getUTCDate().?);
}

// A ZDate's `timestamp` field is public (no accessor enforcement), so a
// caller can construct one directly with a value outside [MIN_TIME,
// MAX_TIME] that isn't exactly INVALID_TIME. Every getter/formatter must
// treat that the same as Invalid Date, not just the exact sentinel.

test "out-of-range (non-sentinel) timestamp: getters return null" {
    const date = ZDate{ .timestamp = Constants.MIN_TIME - 1 };
    try std.testing.expect(!date.isValid());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCFullYear());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCMonth());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCDate());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCHours());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCMinutes());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCSeconds());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCMilliseconds());
    try std.testing.expectEqual(@as(?i32, null), date.getUTCDay());
}

test "out-of-range (non-sentinel) timestamp: toDateString/toString/toUTCString/toTimeString report Invalid Date" {
    const allocator = std.testing.allocator;
    const date = ZDate{ .timestamp = Constants.MAX_TIME + 1 };

    const date_str = try date.toDateString(allocator);
    defer allocator.free(date_str);
    try std.testing.expectEqualStrings("Invalid Date", date_str);

    const time_str = try date.toTimeString(allocator);
    defer allocator.free(time_str);
    try std.testing.expectEqualStrings("Invalid Date", time_str);

    const full_str = try date.toString(allocator);
    defer allocator.free(full_str);
    try std.testing.expectEqualStrings("Invalid Date", full_str);

    const utc_str = try date.toUTCString(allocator);
    defer allocator.free(utc_str);
    try std.testing.expectEqualStrings("Invalid Date", utc_str);
}

test "out-of-range (non-sentinel) timestamp: toLocale* report Invalid Date" {
    const allocator = std.testing.allocator;
    const date = ZDate{ .timestamp = Constants.MIN_TIME - 1 };

    const date_str = try date.toLocaleDateString(allocator, null);
    defer allocator.free(date_str);
    try std.testing.expectEqualStrings("Invalid Date", date_str);

    const time_str = try date.toLocaleTimeString(allocator, null);
    defer allocator.free(time_str);
    try std.testing.expectEqualStrings("Invalid Date", time_str);

    const full_str = try date.toLocaleString(allocator, null);
    defer allocator.free(full_str);
    try std.testing.expectEqualStrings("Invalid Date", full_str);
}

test "sanity: ordinary valid dates are unaffected by the fix" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear().?);

    const str = try date.toDateString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("Mon Jan 01 2024", str);
}
