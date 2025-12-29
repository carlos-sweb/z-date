const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

test "toISOString format YYYY-MM-DDTHH:mm:ss.sssZ" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const str = try date.toISOString();
    defer allocator.free(str);
    try std.testing.expectEqualStrings("2024-01-01T00:00:00.000Z", str);
}

test "toISOString with non-zero values" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 11, 25, 15, 30, 45, 123);
    const str = try date.toISOString();
    defer allocator.free(str);
    try std.testing.expectEqualStrings("2024-12-25T15:30:45.123Z", str);
}

test "toISOString for invalid date returns error" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, Constants.INVALID_TIME);
    const result = date.toISOString();
    try std.testing.expectError(zdate.ZDateError.InvalidDate, result);
}

test "toDateString format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const str = try date.toDateString();
    defer allocator.free(str);
    // Format should be "Day Mon DD YYYY"
    try std.testing.expect(str.len > 0);
}

test "toTimeString format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 15, 30, 45, 0);
    const str = try date.toTimeString();
    defer allocator.free(str);
    try std.testing.expect(str.len > 0);
}

test "toString format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const str = try date.toString();
    defer allocator.free(str);
    try std.testing.expect(str.len > 0);
}

test "toUTCString format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const str = try date.toUTCString();
    defer allocator.free(str);
    // Format should be "Day, DD Mon YYYY HH:MM:SS GMT"
    try std.testing.expect(str.len > 0);
    try std.testing.expect(std.mem.indexOf(u8, str, "GMT") != null);
}

test "toJSON equals toISOString" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const json_str = try date.toJSON();
    defer allocator.free(json_str);
    const iso_str = try date.toISOString();
    defer allocator.free(iso_str);
    try std.testing.expectEqualStrings(iso_str, json_str);
}

test "toLocaleDateString format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const str = try date.toLocaleDateString(null);
    defer allocator.free(str);
    try std.testing.expect(str.len > 0);
}

test "toLocaleTimeString format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 15, 30, 45, 0);
    const str = try date.toLocaleTimeString(null);
    defer allocator.free(str);
    try std.testing.expect(str.len > 0);
}

test "toLocaleString format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 15, 30, 45, 0);
    const str = try date.toLocaleString(null);
    defer allocator.free(str);
    try std.testing.expect(str.len > 0);
}

test "invalid date toString returns 'Invalid Date'" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromTimestamp(allocator, Constants.INVALID_TIME);
    const str = try date.toString();
    defer allocator.free(str);
    try std.testing.expectEqualStrings("Invalid Date", str);
}
