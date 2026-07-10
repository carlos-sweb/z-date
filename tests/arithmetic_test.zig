const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

test "addMilliseconds adds correctly" {
    const date = ZDate.fromTimestamp(0);
    const new_date = try date.addMilliseconds(1000);
    try std.testing.expectEqual(@as(i64, 1000), new_date.getTime());
}

test "addSeconds adds correctly" {
    const date = ZDate.fromTimestamp(0);
    const new_date = try date.addSeconds(60);
    try std.testing.expectEqual(@as(i64, 60000), new_date.getTime());
}

test "addMinutes adds correctly" {
    const date = ZDate.fromTimestamp(0);
    const new_date = try date.addMinutes(60);
    try std.testing.expectEqual(@as(i64, 3600000), new_date.getTime());
}

test "addHours adds correctly" {
    const date = ZDate.fromTimestamp(0);
    const new_date = try date.addHours(24);
    try std.testing.expectEqual(@as(i64, 86400000), new_date.getTime());
}

test "addDays adds correctly" {
    const date = ZDate.fromTimestamp(0);
    const new_date = try date.addDays(1);
    try std.testing.expectEqual(@as(i64, 86400000), new_date.getTime());
}

test "addDays with multiple days" {
    const date = ZDate.fromTimestamp(0);
    const new_date = try date.addDays(7);
    try std.testing.expectEqual(@as(i64, 604800000), new_date.getTime());
}

test "addMilliseconds with negative value subtracts" {
    const date = ZDate.fromTimestamp(1000);
    const new_date = try date.addMilliseconds(-500);
    try std.testing.expectEqual(@as(i64, 500), new_date.getTime());
}

test "addDays with negative value subtracts" {
    const date = ZDate.fromTimestamp(86400000); // 1 day
    const new_date = try date.addDays(-1);
    try std.testing.expectEqual(@as(i64, 0), new_date.getTime());
}

test "diffMilliseconds calculates difference" {
    const date1 = ZDate.fromTimestamp(1000);
    const date2 = ZDate.fromTimestamp(500);
    try std.testing.expectEqual(@as(i64, 500), date1.diffMilliseconds(date2));
}

test "diffSeconds calculates difference" {
    const date1 = ZDate.fromTimestamp(60000);
    const date2 = ZDate.fromTimestamp(0);
    try std.testing.expectEqual(@as(i64, 60), date1.diffSeconds(date2));
}

test "diffMinutes calculates difference" {
    const date1 = ZDate.fromTimestamp(3600000);
    const date2 = ZDate.fromTimestamp(0);
    try std.testing.expectEqual(@as(i64, 60), date1.diffMinutes(date2));
}

test "diffHours calculates difference" {
    const date1 = ZDate.fromTimestamp(86400000);
    const date2 = ZDate.fromTimestamp(0);
    try std.testing.expectEqual(@as(i64, 24), date1.diffHours(date2));
}

test "diffDays calculates difference" {
    const date1 = ZDate.fromTimestamp(604800000); // 7 days
    const date2 = ZDate.fromTimestamp(0);
    try std.testing.expectEqual(@as(i64, 7), date1.diffDays(date2));
}

test "equals returns true for same timestamp" {
    const date1 = ZDate.fromTimestamp(1000);
    const date2 = ZDate.fromTimestamp(1000);
    try std.testing.expect(date1.equals(date2));
}

test "equals returns false for different timestamps" {
    const date1 = ZDate.fromTimestamp(1000);
    const date2 = ZDate.fromTimestamp(2000);
    try std.testing.expect(!date1.equals(date2));
}

test "before returns true when first is before second" {
    const date1 = ZDate.fromTimestamp(1000);
    const date2 = ZDate.fromTimestamp(2000);
    try std.testing.expect(date1.before(date2));
}

test "before returns false when first is after second" {
    const date1 = ZDate.fromTimestamp(2000);
    const date2 = ZDate.fromTimestamp(1000);
    try std.testing.expect(!date1.before(date2));
}

test "after returns true when first is after second" {
    const date1 = ZDate.fromTimestamp(2000);
    const date2 = ZDate.fromTimestamp(1000);
    try std.testing.expect(date1.after(date2));
}

test "after returns false when first is before second" {
    const date1 = ZDate.fromTimestamp(1000);
    const date2 = ZDate.fromTimestamp(2000);
    try std.testing.expect(!date1.after(date2));
}

test "compare returns .eq for equal timestamps" {
    const date1 = ZDate.fromTimestamp(1000);
    const date2 = ZDate.fromTimestamp(1000);
    try std.testing.expectEqual(std.math.Order.eq, date1.compare(date2));
}

test "compare returns .lt when first is less than second" {
    const date1 = ZDate.fromTimestamp(1000);
    const date2 = ZDate.fromTimestamp(2000);
    try std.testing.expectEqual(std.math.Order.lt, date1.compare(date2));
}

test "compare returns .gt when first is greater than second" {
    const date1 = ZDate.fromTimestamp(2000);
    const date2 = ZDate.fromTimestamp(1000);
    try std.testing.expectEqual(std.math.Order.gt, date1.compare(date2));
}

test "addMilliseconds overflow detection" {
    const date = ZDate.fromTimestamp(Constants.MAX_TIME);
    const result = date.addMilliseconds(1);
    try std.testing.expectError(zdate.ZDateError.OutOfRange, result);
}

test "addMilliseconds underflow detection" {
    const date = ZDate.fromTimestamp(Constants.MIN_TIME);
    const result = date.addMilliseconds(-1);
    try std.testing.expectError(zdate.ZDateError.OutOfRange, result);
}

// ===== NaN-like semantics for Invalid Date (ECMA-262: any comparison =====
// ===== involving NaN is false; NaN - x / x - NaN is NaN)              =====

test "equals is false when either operand is Invalid Date" {
    const invalid = ZDate.fromTimestamp(Constants.INVALID_TIME);
    const valid = ZDate.fromTimestamp(0);
    try std.testing.expect(!invalid.equals(invalid));
    try std.testing.expect(!invalid.equals(valid));
    try std.testing.expect(!valid.equals(invalid));
}

test "before/after are false when either operand is Invalid Date" {
    const invalid = ZDate.fromTimestamp(Constants.INVALID_TIME);
    const valid = ZDate.fromTimestamp(0);
    try std.testing.expect(!invalid.before(valid));
    try std.testing.expect(!valid.before(invalid));
    try std.testing.expect(!invalid.after(valid));
    try std.testing.expect(!valid.after(invalid));
}

test "compare returns null when either operand is Invalid Date" {
    const invalid = ZDate.fromTimestamp(Constants.INVALID_TIME);
    const valid = ZDate.fromTimestamp(0);
    try std.testing.expectEqual(@as(?std.math.Order, null), invalid.compare(valid));
    try std.testing.expectEqual(@as(?std.math.Order, null), valid.compare(invalid));
    try std.testing.expectEqual(@as(?std.math.Order, null), invalid.compare(invalid));
}

test "diff* return null when either operand is Invalid Date" {
    const invalid = ZDate.fromTimestamp(Constants.INVALID_TIME);
    const out_of_range = ZDate{ .timestamp = Constants.MIN_TIME - 1 };
    const valid = ZDate.fromTimestamp(0);

    try std.testing.expectEqual(@as(?i64, null), invalid.diffMilliseconds(valid));
    try std.testing.expectEqual(@as(?i64, null), valid.diffSeconds(invalid));
    try std.testing.expectEqual(@as(?i64, null), invalid.diffMinutes(invalid));
    try std.testing.expectEqual(@as(?i64, null), valid.diffHours(out_of_range));
    try std.testing.expectEqual(@as(?i64, null), out_of_range.diffDays(valid));

    // Also confirm this used to be a crash (integer overflow subtracting
    // INVALID_TIME from a very negative timestamp) and now safely returns null.
    try std.testing.expectEqual(@as(?i64, null), invalid.diffMilliseconds(ZDate.fromTimestamp(Constants.MIN_TIME)));
}

test "diff* still compute correctly for two valid dates" {
    const date1 = ZDate.fromTimestamp(1000);
    const date2 = ZDate.fromTimestamp(500);
    try std.testing.expectEqual(@as(?i64, 500), date1.diffMilliseconds(date2));
}
