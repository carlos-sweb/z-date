const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;

test "parse full ISO 8601 with timezone Z" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromISO8601(allocator, "2024-01-01T00:00:00.000Z");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
}

test "parse ISO 8601 date only format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromISO8601(allocator, "2024-12-25");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear());
    try std.testing.expectEqual(@as(i32, 11), date.getUTCMonth());
    try std.testing.expectEqual(@as(i32, 25), date.getUTCDate());
}

test "format and parse round trip" {
    const allocator = std.testing.allocator;
    const original = try ZDate.fromComponentsUTC(allocator, 2024, 5, 15, 12, 30, 45, 123);
    const iso_str = try original.toISOString();
    defer allocator.free(iso_str);

    const parsed = try ZDate.fromISO8601(allocator, iso_str);
    try std.testing.expectEqual(original.getTime(), parsed.getTime());
}

test "toISOString produces valid ISO 8601" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const str = try date.toISOString();
    defer allocator.free(str);

    // Should end with Z
    try std.testing.expect(str[str.len - 1] == 'Z');
    // Should contain T separator
    try std.testing.expect(std.mem.indexOf(u8, str, "T") != null);
}

test "ISO 8601 with all components" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 11, 31, 23, 59, 59, 999);
    const str = try date.toISOString();
    defer allocator.free(str);
    try std.testing.expectEqualStrings("2024-12-31T23:59:59.999Z", str);
}

test "ISO 8601 leap year date" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromISO8601(allocator, "2024-02-29T00:00:00.000Z");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 29), date.getUTCDate());
}

test "ISO 8601 year 1970" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromISO8601(allocator, "1970-01-01T00:00:00.000Z");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i64, 0), date.getTime());
}

test "ISO 8601 parsing preserves milliseconds" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromISO8601(allocator, "2024-01-01T00:00:00.456Z");
    try std.testing.expectEqual(@as(i32, 456), date.getUTCMilliseconds());
}

test "toJSON produces ISO 8601 format" {
    const allocator = std.testing.allocator;
    const date = try ZDate.fromComponentsUTC(allocator, 2024, 0, 1, 0, 0, 0, 0);
    const json_str = try date.toJSON();
    defer allocator.free(json_str);

    // Should be valid ISO 8601
    const parsed = try ZDate.fromISO8601(allocator, json_str);
    try std.testing.expect(parsed.isValid());
}
