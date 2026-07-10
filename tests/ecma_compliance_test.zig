const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

// ===== Constructor normalization (ECMA-262 MakeDay/MakeDate semantics) =====
//
// Note: real ECMAScript month numbering is 0-based, so month 13 overflows by
// *two* months past December (month 11), landing on February of the next
// year - not January. Verified against Node.js: new Date(2024, 13, 1) =>
// 2025-02-01.

test "fromComponentsUTC normalizes month overflow (Feb of next year)" {
    const date = ZDate.fromComponentsUTC(2024, 13, 1, 0, 0, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2025), date.getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCMonth().?); // February
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate().?);
}

test "fromComponentsUTC normalizes day overflow within January" {
    const date = ZDate.fromComponentsUTC(2024, 0, 32, 0, 0, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCMonth().?); // February
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate().?);
}

test "fromComponentsUTC normalizes hour overflow into next day" {
    const date = ZDate.fromComponentsUTC(2024, 0, 1, 25, 0, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 2), date.getUTCDate().?);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCHours().?);
}

test "fromComponents normalizes negative (underflow) day" {
    // Day 0 of March == last day of February
    const date = ZDate.fromComponentsUTC(2024, 2, 0, 0, 0, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 1), date.getUTCMonth().?); // February
    try std.testing.expectEqual(@as(i32, 29), date.getUTCDate().?); // 2024 is a leap year
}

test "MakeFullYear maps two-digit years 0-99 to 1900-1999" {
    try std.testing.expectEqual(@as(i32, 1950), ZDate.fromComponentsUTC(50, 0, 1, 0, 0, 0, 0).getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 1999), ZDate.fromComponentsUTC(99, 0, 1, 0, 0, 0, 0).getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 1900), ZDate.fromComponentsUTC(0, 0, 1, 0, 0, 0, 0).getUTCFullYear().?);
}

test "MakeFullYear leaves years outside 0-99 untouched" {
    try std.testing.expectEqual(@as(i32, 100), ZDate.fromComponentsUTC(100, 0, 1, 0, 0, 0, 0).getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 2024), ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0).getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, -5), ZDate.fromComponentsUTC(-5, 0, 1, 0, 0, 0, 0).getUTCFullYear().?);
}

test "Date.UTC() applies the same normalization as fromComponentsUTC" {
    const timestamp = ZDate.UTC(2024, 0, 32, 0, 0, 0, 0);
    const date = ZDate.fromTimestamp(timestamp);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate().?);
}

test "fromComponents only rejects when the final timestamp overflows the valid range" {
    const date = ZDate.fromComponentsUTC(300000, 0, 1, 0, 0, 0, 0);
    try std.testing.expect(!date.isValid());
}

// ===== Setters on Invalid Date =====

test "setters on an Invalid Date stay Invalid Date without touching components" {
    var date = ZDate.fromTimestamp(Constants.INVALID_TIME);

    try std.testing.expectEqual(Constants.INVALID_TIME, date.setUTCFullYear(2024, 0, 1));
    try std.testing.expect(!date.isValid());

    try std.testing.expectEqual(Constants.INVALID_TIME, date.setUTCMonth(0, null));
    try std.testing.expect(!date.isValid());

    try std.testing.expectEqual(Constants.INVALID_TIME, date.setUTCDate(1));
    try std.testing.expect(!date.isValid());

    try std.testing.expectEqual(Constants.INVALID_TIME, date.setUTCHours(0, null, null, null));
    try std.testing.expect(!date.isValid());

    try std.testing.expectEqual(Constants.INVALID_TIME, date.setUTCMinutes(0, null, null));
    try std.testing.expect(!date.isValid());

    try std.testing.expectEqual(Constants.INVALID_TIME, date.setUTCSeconds(0, null));
    try std.testing.expect(!date.isValid());

    try std.testing.expectEqual(Constants.INVALID_TIME, date.setUTCMilliseconds(0));
    try std.testing.expect(!date.isValid());
}

test "setTime with an out-of-range value produces Invalid Date" {
    var date = ZDate.fromTimestamp(0);
    const result = date.setTime(Constants.MAX_TIME + 1);
    try std.testing.expectEqual(Constants.INVALID_TIME, result);
    try std.testing.expect(!date.isValid());
}

test "setTime with a valid value updates the timestamp normally" {
    var date = ZDate.fromTimestamp(0);
    const result = date.setTime(1000);
    try std.testing.expectEqual(@as(i64, 1000), result);
    try std.testing.expect(date.isValid());
}

test "setFullYear producing an out-of-range result becomes Invalid Date" {
    var date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);
    _ = date.setUTCFullYear(300000, null, null);
    try std.testing.expect(!date.isValid());
}

// ===== Strict ISO 8601 parsing =====

test "trailing garbage after a valid date-time is rejected" {
    try std.testing.expect(!ZDate.fromISO8601("2024abcd").isValid());
    try std.testing.expect(!ZDate.fromISO8601("2024-01-01T10:00:00.000ZXYZ").isValid());
    try std.testing.expect(!ZDate.fromISO8601("2024-01-01T10:00:00XYZ").isValid());
}

test "invalid month/day ranges are rejected" {
    try std.testing.expect(!ZDate.fromISO8601("2024-13-01").isValid());
    try std.testing.expect(!ZDate.fromISO8601("2024-00-01").isValid());
    try std.testing.expect(!ZDate.fromISO8601("2024-02-30").isValid()); // Feb only has 29 days in 2024
    try std.testing.expect(!ZDate.fromISO8601("2023-02-29").isValid()); // 2023 is not a leap year
}

test "hour 24 is only valid as exactly 24:00:00.000" {
    const date = ZDate.fromISO8601("2024-01-01T24:00:00.000Z");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2), date.getUTCDate().?);
    try std.testing.expectEqual(@as(i32, 0), date.getUTCHours().?);

    try std.testing.expect(!ZDate.fromISO8601("2024-01-01T24:00:01.000Z").isValid());
    try std.testing.expect(!ZDate.fromISO8601("2024-01-01T25:00:00.000Z").isValid());
}

test "explicit +HH:mm offset is applied against UTC" {
    const date = ZDate.fromISO8601("2024-01-01T10:00:00+02:00");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 8), date.getUTCHours().?);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate().?);
}

test "explicit -HH:mm offset is applied against UTC" {
    const date = ZDate.fromISO8601("2024-01-01T10:00:00-05:00");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 15), date.getUTCHours().?);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate().?);
}

test "extended (signed 6-digit) years parse correctly" {
    const positive = ZDate.fromISO8601("+002024-06-15T00:00:00.000Z");
    try std.testing.expect(positive.isValid());
    try std.testing.expectEqual(@as(i32, 2024), positive.getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 5), positive.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 15), positive.getUTCDate().?);

    const negative = ZDate.fromISO8601("-000001-01-01T00:00:00.000Z");
    try std.testing.expect(negative.isValid());
    try std.testing.expectEqual(@as(i32, -1), negative.getUTCFullYear().?);
}

test "-000000 extended year is rejected" {
    try std.testing.expect(!ZDate.fromISO8601("-000000-01-01").isValid());
}

test "date-only forms are interpreted as UTC" {
    const date = ZDate.fromISO8601("2024-06-15");
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 5), date.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCDate().?);
    try std.testing.expectEqual(@as(i32, 0), date.getUTCHours().?);
}

// ===== Round-trip: parse(toString(d)) / parse(toUTCString(d)) =====

test "round trip through toString for several dates" {
    const allocator = std.testing.allocator;
    const dates = [_]ZDate{
        ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0),
        ZDate.fromComponentsUTC(1999, 11, 31, 23, 59, 59, 0),
        ZDate.fromComponentsUTC(1970, 0, 1, 0, 0, 0, 0),
        ZDate.fromComponentsUTC(2024, 5, 15, 12, 30, 45, 0),
    };

    for (dates) |date| {
        const str = try date.toString(allocator);
        defer allocator.free(str);

        const parsed_ts = ZDate.parse(str);
        try std.testing.expectEqual(date.getTime(), parsed_ts);
    }
}

test "round trip through toUTCString for several dates" {
    const allocator = std.testing.allocator;
    const dates = [_]ZDate{
        ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0),
        ZDate.fromComponentsUTC(1999, 11, 31, 23, 59, 59, 0),
        ZDate.fromComponentsUTC(1970, 0, 1, 0, 0, 0, 0),
        ZDate.fromComponentsUTC(2024, 5, 15, 12, 30, 45, 0),
    };

    for (dates) |date| {
        const str = try date.toUTCString(allocator);
        defer allocator.free(str);

        const parsed_ts = ZDate.parse(str);
        try std.testing.expectEqual(date.getTime(), parsed_ts);
    }
}

// ===== toISOString at the extremes of the valid time range =====

test "toISOString at MAX_TIME uses the expanded signed format" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(Constants.MAX_TIME);
    const str = try date.toISOString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("+275760-09-13T00:00:00.000Z", str);
}

test "toISOString at MIN_TIME uses the expanded signed format" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(Constants.MIN_TIME);
    const str = try date.toISOString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("-271821-04-20T00:00:00.000Z", str);
}

test "toISOString uses the standard 4-digit format inside [0, 9999]" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(9999, 11, 31, 23, 59, 59, 999);
    const str = try date.toISOString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("9999-12-31T23:59:59.999Z", str);

    // Year 0 via ISO parsing (fromComponentsUTC would apply the two-digit
    // MakeFullYear rule and turn 0 into 1900, which is not what we want here).
    const date0 = ZDate.fromISO8601("0000-01-01T00:00:00.000Z");
    const str0 = try date0.toISOString(allocator);
    defer allocator.free(str0);
    try std.testing.expectEqualStrings("0000-01-01T00:00:00.000Z", str0);
}
