const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

test "now() creates valid date" {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    const date = ZDate.now(io);
    try std.testing.expect(date.isValid());
}

test "fromTimestamp() with valid timestamp" {
    const date = ZDate.fromTimestamp(0);
    try std.testing.expectEqual(@as(i64, 0), date.timestamp);
}

test "fromTimestamp() with epoch" {
    const date = ZDate.fromTimestamp(Constants.UNIX_EPOCH);
    try std.testing.expectEqual(@as(i64, 0), date.timestamp);
    try std.testing.expect(date.isValid());
}

test "fromTimestamp() with invalid timestamp (too large)" {
    const date = ZDate.fromTimestamp(Constants.MAX_TIME + 1);
    try std.testing.expect(!date.isValid());
    try std.testing.expectEqual(Constants.INVALID_TIME, date.timestamp);
}

test "fromTimestamp() with invalid timestamp (too small)" {
    const date = ZDate.fromTimestamp(Constants.MIN_TIME - 1);
    try std.testing.expect(!date.isValid());
}

test "fromTimestamp() at MAX_TIME boundary" {
    const date = ZDate.fromTimestamp(Constants.MAX_TIME);
    try std.testing.expect(date.isValid());
}

test "fromTimestamp() at MIN_TIME boundary" {
    const date = ZDate.fromTimestamp(Constants.MIN_TIME);
    try std.testing.expect(date.isValid());
}

test "fromComponents() creates correct date" {
    const date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate());
}

test "fromComponents() with default values" {
    const date = ZDate.fromComponentsUTC(2024, 0, null, null, null, null, null);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate());
}

test "fromISO8601() parses valid string" {
    const date = ZDate.fromISO8601("2024-01-01T00:00:00.000Z");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate());
}

test "fromISO8601() parses date only" {
    const date = ZDate.fromISO8601("2024-01-15");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 15), date.getUTCDate());
}

test "fromISO8601() parses year and month" {
    const date = ZDate.fromISO8601("2024-06");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 5), date.getUTCMonth());
}

test "fromISO8601() with invalid format" {
    const date = ZDate.fromISO8601("invalid");
    try std.testing.expect(!date.isValid());
}

test "fromString() parses ISO 8601" {
    const date = ZDate.fromString("2024-01-01T00:00:00.000Z");
    try std.testing.expect(date.isValid());
}

test "fromString() with invalid string" {
    const date = ZDate.fromString("not a date");
    try std.testing.expect(!date.isValid());
}

test "nowTimestamp() returns reasonable value" {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    const timestamp = ZDate.nowTimestamp(io);
    // Should be somewhere between 2020 and 2100 (reasonable range)
    try std.testing.expect(timestamp > 1577836800000); // 2020-01-01
    try std.testing.expect(timestamp < 4102444800000); // 2100-01-01
}

test "parse() static method with ISO 8601" {
    const timestamp = ZDate.parse("2024-01-01T00:00:00.000Z");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
}

test "parse() static method with invalid string" {
    const timestamp = ZDate.parse("invalid");
    try std.testing.expectEqual(Constants.INVALID_TIME, timestamp);
}

test "UTC() static method creates correct timestamp" {
    const timestamp = ZDate.UTC(2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expect(timestamp != Constants.INVALID_TIME);

    const date = ZDate.fromTimestamp(timestamp);
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
}

test "UTC() static method with defaults" {
    const timestamp = ZDate.UTC(2024, 0, null, null, null, null, null);
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
}
