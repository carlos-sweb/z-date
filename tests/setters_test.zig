const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;

test "setFullYear() updates year correctly" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCFullYear(2025, null, null);
    try std.testing.expectEqual(@as(i32, 2025), date.getUTCFullYear());
}

test "setFullYear() with month and day" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCFullYear(2025, 5, 15);
    try std.testing.expectEqual(@as(i32, 2025), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 5), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 15), date.getUTCDate());
}

test "setMonth() updates month correctly" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCMonth(5, null);
    try std.testing.expectEqual(@as(i32, 5), date.getUTCMonth());
}

test "setMonth() with day" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCMonth(5, 15);
    try std.testing.expectEqual(@as(i32, 5), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 15), date.getUTCDate());
}

test "setMonth() with overflow to next year" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCMonth(13, null); // Should become January 2025
    try std.testing.expectEqual(@as(i32, 2025), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCMonth());
}

test "setDate() updates day correctly" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCDate(15);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCDate());
}

test "setDate() with overflow to next month" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCDate(32); // Should become February 1
    try std.testing.expectEqual(@as(i32, 1), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate());
}

test "setHours() updates hour correctly" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCHours(15, null, null, null);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCHours());
}

test "setHours() with minutes, seconds, and milliseconds" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCHours(15, 30, 45, 500);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCHours());
    try std.testing.expectEqual(@as(i32, 30), date.getUTCMinutes());
    try std.testing.expectEqual(@as(i32, 45), date.getUTCSeconds());
    try std.testing.expectEqual(@as(i32, 500), date.getUTCMilliseconds());
}

test "setMinutes() updates minute correctly" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCMinutes(45, null, null);
    try std.testing.expectEqual(@as(i32, 45), date.getUTCMinutes());
}

test "setMinutes() with seconds and milliseconds" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCMinutes(45, 30, 500);
    try std.testing.expectEqual(@as(i32, 45), date.getUTCMinutes());
    try std.testing.expectEqual(@as(i32, 30), date.getUTCSeconds());
    try std.testing.expectEqual(@as(i32, 500), date.getUTCMilliseconds());
}

test "setSeconds() updates second correctly" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCSeconds(30, null);
    try std.testing.expectEqual(@as(i32, 30), date.getUTCSeconds());
}

test "setSeconds() with milliseconds" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCSeconds(30, 500);
    try std.testing.expectEqual(@as(i32, 30), date.getUTCSeconds());
    try std.testing.expectEqual(@as(i32, 500), date.getUTCMilliseconds());
}

test "setMilliseconds() updates millisecond correctly" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCMilliseconds(500);
    try std.testing.expectEqual(@as(i32, 500), date.getUTCMilliseconds());
}

test "setTime() updates timestamp correctly" {
    const allocator = std.testing.allocator;
    var date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const new_time: i64 = 1704153600000; // 2024-01-02 00:00:00 UTC
    _ = date.setTime(new_time);
    try std.testing.expectEqual(new_time, date.getTime());
}
