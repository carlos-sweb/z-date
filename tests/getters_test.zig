const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

test "getFullYear() returns correct year" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
}

test "getMonth() returns 0-11" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 5, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 5), date.getUTCMonth());
}

test "getMonth() for January is 0" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth());
}

test "getMonth() for December is 11" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 11, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 11), date.getUTCMonth());
}

test "getDate() returns 1-31" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 15, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCDate());
}

test "getDate() for first day is 1" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate());
}

test "getDate() for last day of month" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 31, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 31), date.getUTCDate());
}

test "getDay() returns 0-6" {
    const allocator = std.testing.allocator;
    // 2024-01-01 is a Monday (1)
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const day = date.getUTCDay();
    try std.testing.expect(day >= 0 and day <= 6);
}

test "getHours() returns 0-23" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 15, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCHours());
}

test "getHours() for midnight is 0" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 0), date.getUTCHours());
}

test "getHours() for 11 PM is 23" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 23, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 23), date.getUTCHours());
}

test "getMinutes() returns 0-59" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 45, 0, 0);
    try std.testing.expectEqual(@as(i32, 45), date.getUTCMinutes());
}

test "getSeconds() returns 0-59" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 30, 0);
    try std.testing.expectEqual(@as(i32, 30), date.getUTCSeconds());
}

test "getMilliseconds() returns 0-999" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 500);
    try std.testing.expectEqual(@as(i32, 500), date.getUTCMilliseconds());
}

test "getTime() returns timestamp" {
    const allocator = std.testing.allocator;
    const timestamp: i64 = 1704067200000; // 2024-01-01 00:00:00 UTC
    const date = try ZDate.fromTimestamp(allocator, timestamp);
    try std.testing.expectEqual(timestamp, date.getTime());
}

test "getTimezoneOffset() returns minutes" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, 0);
    const offset = date.getTimezoneOffset();
    // Offset should be reasonable (-720 to +840 minutes)
    try std.testing.expect(offset >= -720 and offset <= 840);
}

test "getUTCFullYear() returns UTC year" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
}

test "getUTCMonth() returns UTC month" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 5, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 5), date.getUTCMonth());
}

test "getUTCDate() returns UTC date" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 15, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCDate());
}

test "getUTCDay() returns UTC day of week" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const day = date.getUTCDay();
    try std.testing.expect(day >= 0 and day <= 6);
}

test "getUTCHours() returns UTC hours" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 15, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCHours());
}

test "getUTCMinutes() returns UTC minutes" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 45, 0, 0);
    try std.testing.expectEqual(@as(i32, 45), date.getUTCMinutes());
}

test "getUTCSeconds() returns UTC seconds" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 30, 0);
    try std.testing.expectEqual(@as(i32, 30), date.getUTCSeconds());
}

test "getUTCMilliseconds() returns UTC milliseconds" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 500);
    try std.testing.expectEqual(@as(i32, 500), date.getUTCMilliseconds());
}

test "valueOf() returns timestamp" {
    const allocator = std.testing.allocator;
    const timestamp: i64 = 1704067200000;
    const date = try ZDate.fromTimestamp(allocator, timestamp);
    try std.testing.expectEqual(timestamp, date.valueOf());
}

test "isValid() returns true for valid date" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, 0);
    try std.testing.expect(date.isValid());
}

test "isValid() returns false for invalid date" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, Constants.INVALID_TIME);
    try std.testing.expect(!date.isValid());
}
