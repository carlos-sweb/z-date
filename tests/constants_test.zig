const std = @import("std");
const zdate = @import("zdate");
const Constants = zdate.Constants;

test "MS_PER_SECOND is 1000" {
    try std.testing.expectEqual(@as(i64, 1000), Constants.MS_PER_SECOND);
}

test "MS_PER_MINUTE is 60000" {
    try std.testing.expectEqual(@as(i64, 60000), Constants.MS_PER_MINUTE);
}

test "MS_PER_HOUR is 3600000" {
    try std.testing.expectEqual(@as(i64, 3600000), Constants.MS_PER_HOUR);
}

test "MS_PER_DAY is 86400000" {
    try std.testing.expectEqual(@as(i64, 86400000), Constants.MS_PER_DAY);
}

test "UNIX_EPOCH is 0" {
    try std.testing.expectEqual(@as(i64, 0), Constants.UNIX_EPOCH);
}

test "MAX_TIME is within valid range" {
    try std.testing.expectEqual(@as(i64, 8_640_000_000_000_000), Constants.MAX_TIME);
}

test "MIN_TIME is within valid range" {
    try std.testing.expectEqual(@as(i64, -8_640_000_000_000_000), Constants.MIN_TIME);
}

test "DAYS_PER_COMMON_YEAR is 365" {
    try std.testing.expectEqual(@as(i32, 365), Constants.DAYS_PER_COMMON_YEAR);
}

test "DAYS_PER_LEAP_YEAR is 366" {
    try std.testing.expectEqual(@as(i32, 366), Constants.DAYS_PER_LEAP_YEAR);
}

test "MONTHS_PER_YEAR is 12" {
    try std.testing.expectEqual(@as(i32, 12), Constants.MONTHS_PER_YEAR);
}

test "HOURS_PER_DAY is 24" {
    try std.testing.expectEqual(@as(i32, 24), Constants.HOURS_PER_DAY);
}

test "MINUTES_PER_HOUR is 60" {
    try std.testing.expectEqual(@as(i32, 60), Constants.MINUTES_PER_HOUR);
}

test "SECONDS_PER_MINUTE is 60" {
    try std.testing.expectEqual(@as(i32, 60), Constants.SECONDS_PER_MINUTE);
}

test "DAYS_IN_MONTH has 12 elements" {
    try std.testing.expectEqual(@as(usize, 12), Constants.DAYS_IN_MONTH.len);
}

test "DAYS_IN_MONTH January is 31" {
    try std.testing.expectEqual(@as(i32, 31), Constants.DAYS_IN_MONTH[0]);
}

test "DAYS_IN_MONTH February is 28" {
    try std.testing.expectEqual(@as(i32, 28), Constants.DAYS_IN_MONTH[1]);
}

test "MONTH_NAMES has 12 elements" {
    try std.testing.expectEqual(@as(usize, 12), Constants.MONTH_NAMES.len);
}

test "MONTH_NAMES_SHORT has 12 elements" {
    try std.testing.expectEqual(@as(usize, 12), Constants.MONTH_NAMES_SHORT.len);
}

test "DAY_NAMES has 7 elements" {
    try std.testing.expectEqual(@as(usize, 7), Constants.DAY_NAMES.len);
}

test "DAY_NAMES_SHORT has 7 elements" {
    try std.testing.expectEqual(@as(usize, 7), Constants.DAY_NAMES_SHORT.len);
}
