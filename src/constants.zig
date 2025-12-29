const std = @import("std");

/// ECMAScript Date Constants
/// All time-related constants following JavaScript Date specification
pub const Constants = struct {
    /// Milliseconds per second
    pub const MS_PER_SECOND: i64 = 1000;

    /// Milliseconds per minute
    pub const MS_PER_MINUTE: i64 = 60 * MS_PER_SECOND;

    /// Milliseconds per hour
    pub const MS_PER_HOUR: i64 = 60 * MS_PER_MINUTE;

    /// Milliseconds per day
    pub const MS_PER_DAY: i64 = 24 * MS_PER_HOUR;

    /// Unix epoch: January 1, 1970, 00:00:00 UTC
    pub const UNIX_EPOCH: i64 = 0;

    /// Maximum valid timestamp (±273,785 years from epoch)
    /// Approximately September 13, 275760
    pub const MAX_TIME: i64 = 8_640_000_000_000_000;

    /// Minimum valid timestamp
    /// Approximately April 20, -271821
    pub const MIN_TIME: i64 = -8_640_000_000_000_000;

    /// Invalid date representation
    pub const INVALID_TIME: i64 = std.math.maxInt(i64);

    /// Days per common year
    pub const DAYS_PER_COMMON_YEAR: i32 = 365;

    /// Days per leap year
    pub const DAYS_PER_LEAP_YEAR: i32 = 366;

    /// Months per year
    pub const MONTHS_PER_YEAR: i32 = 12;

    /// Hours per day
    pub const HOURS_PER_DAY: i32 = 24;

    /// Minutes per hour
    pub const MINUTES_PER_HOUR: i32 = 60;

    /// Seconds per minute
    pub const SECONDS_PER_MINUTE: i32 = 60;

    /// Milliseconds per second (as i32)
    pub const MS_PER_SECOND_I32: i32 = 1000;

    /// Days in each month (non-leap year)
    pub const DAYS_IN_MONTH = [_]i32{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    /// Month names (full)
    pub const MONTH_NAMES = [_][]const u8{
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    };

    /// Month names (abbreviated)
    pub const MONTH_NAMES_SHORT = [_][]const u8{
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
    };

    /// Day names (full)
    pub const DAY_NAMES = [_][]const u8{
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
    };

    /// Day names (abbreviated)
    pub const DAY_NAMES_SHORT = [_][]const u8{
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
    };
};
