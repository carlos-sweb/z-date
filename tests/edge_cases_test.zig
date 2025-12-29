const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

test "leap year February 29 2024" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 1, 29, 0, 0, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 29), date.getUTCDate());
}

test "leap year February 29 2000" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2000, 1, 29, 0, 0, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 29), date.getUTCDate());
}

test "year 2000 is leap year" {
    try std.testing.expect(ZDate.isLeapYear(2000));
}

test "year 1900 is not leap year" {
    try std.testing.expect(!ZDate.isLeapYear(1900));
}

test "year 2100 is not leap year" {
    try std.testing.expect(!ZDate.isLeapYear(2100));
}

test "year 2024 is leap year" {
    try std.testing.expect(ZDate.isLeapYear(2024));
}

test "year 2023 is not leap year" {
    try std.testing.expect(!ZDate.isLeapYear(2023));
}

test "MAX_TIME boundary is valid" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, Constants.MAX_TIME);
    try std.testing.expect(date.isValid());
}

test "MIN_TIME boundary is valid" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, Constants.MIN_TIME);
    try std.testing.expect(date.isValid());
}

test "MAX_TIME + 1 is invalid" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, Constants.MAX_TIME + 1);
    try std.testing.expect(!date.isValid());
}

test "MIN_TIME - 1 is invalid" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, Constants.MIN_TIME - 1);
    try std.testing.expect(!date.isValid());
}

test "Invalid Date operations return Invalid Date" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, Constants.INVALID_TIME);
    try std.testing.expect(!date.isValid());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCFullYear());
}

test "month overflow to next year" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 11, 15, 0, 0, 0, 0);
    _ = date.setUTCMonth(12, null); // Should become January 2025
    try std.testing.expectEqual(@as(i32, 2025), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth());
}

test "day overflow to next month" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 31, 0, 0, 0, 0);
    _ = date.setUTCDate(32); // Should become February 1
    try std.testing.expectEqual(@as(i32, 1), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate());
}

test "hour overflow to next day" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 23, 0, 0, 0);
    _ = date.setUTCHours(24, null, null, null); // Should become next day at 00:00
    try std.testing.expectEqual(@as(i32, 2), date.getUTCDate());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCHours());
}

test "Unix epoch (0) is valid" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 1970), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate());
}

test "negative timestamp before Unix epoch" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, -86400000); // One day before epoch
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 1969), date.getUTCFullYear());
}

test "February 30 becomes March 1 or 2" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 1, 1, 0, 0, 0, 0);
    _ = date.setUTCDate(30); // February only has 28/29 days
    try std.testing.expect(date.getUTCMonth() == 2); // Should be March
}

test "December 32 becomes January 1 of next year" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 11, 1, 0, 0, 0, 0);
    _ = date.setUTCDate(32);
    try std.testing.expectEqual(@as(i32, 2025), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate());
}

test "year 1970 start of Unix epoch" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, 0);
    try std.testing.expectEqual(@as(i32, 1970), date.getUTCFullYear());
}

test "millisecond precision is preserved" {
    const allocator = std.testing.allocator;
    const timestamp: i64 = 1704067200123; // 2024-01-01 00:00:00.123 UTC
    const date = try ZDate.fromTimestamp(allocator, timestamp);
    try std.testing.expectEqual(timestamp, date.getTime());
}
