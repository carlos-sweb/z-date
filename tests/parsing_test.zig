const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

test "parse ISO 8601 full format" {
    const timestamp = ZDate.parse("2024-01-01T00:00:00.000Z");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
}

test "parse ISO 8601 without milliseconds" {
    const timestamp = ZDate.parse("2024-01-01T12:30:45Z");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
}

test "parse ISO 8601 date only" {
    const timestamp = ZDate.parse("2024-06-15");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
}

test "parse ISO 8601 year and month" {
    const timestamp = ZDate.parse("2024-06");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
}

test "parse ISO 8601 year only" {
    const timestamp = ZDate.parse("2024");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
}

test "parse slash format MM/DD/YYYY" {
    const timestamp = ZDate.parse("01/15/2024");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
}

test "parse invalid returns INVALID_TIME" {
    const timestamp = ZDate.parse("not a valid date");
    try std.testing.expectEqual(Constants.INVALID_TIME, timestamp);
}

test "parse empty string returns INVALID_TIME" {
    const timestamp = ZDate.parse("");
    try std.testing.expectEqual(Constants.INVALID_TIME, timestamp);
}

test "parse whitespace only returns INVALID_TIME" {
    const timestamp = ZDate.parse("   ");
    try std.testing.expectEqual(Constants.INVALID_TIME, timestamp);
}

test "fromISO8601 with valid full format" {
    const date = ZDate.fromISO8601("2024-12-25T15:30:45.123Z");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 11), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 25), date.getUTCDate());
    try std.testing.expectEqual(@as(i32, 15), date.getUTCHours());
    try std.testing.expectEqual(@as(i32, 30), date.getUTCMinutes());
    try std.testing.expectEqual(@as(i32, 45), date.getUTCSeconds());
    try std.testing.expectEqual(@as(i32, 123), date.getUTCMilliseconds());
}

test "fromISO8601 leap year February 29" {
    const date = ZDate.fromISO8601("2024-02-29");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 29), date.getUTCDate());
}

test "fromString with various formats" {
    const date = ZDate.fromString("2024-01-01");
    try std.testing.expect(date.isValid());
}
