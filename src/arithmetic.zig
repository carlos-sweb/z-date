const std = @import("std");
const constants = @import("constants.zig");
const errors = @import("errors.zig");
const calendar = @import("calendar.zig");

const Constants = constants.Constants;
const ZDateError = errors.ZDateError;
const CalendarUtils = calendar.CalendarUtils;

/// Arithmetic operations on dates
pub const ArithmeticMethods = struct {
    /// Add milliseconds to timestamp
    pub fn addMilliseconds(timestamp: i64, ms: i64) !i64 {
        // Check for overflow
        const result = @addWithOverflow(timestamp, ms);
        if (result[1] != 0) { // overflow occurred
            return ZDateError.TimestampOverflow;
        }

        const new_timestamp = result[0];

        // Validate range
        if (new_timestamp < Constants.MIN_TIME or new_timestamp > Constants.MAX_TIME) {
            return ZDateError.OutOfRange;
        }

        return new_timestamp;
    }

    /// Add seconds to timestamp
    pub fn addSeconds(timestamp: i64, seconds: i64) !i64 {
        const ms = seconds * Constants.MS_PER_SECOND;
        return addMilliseconds(timestamp, ms);
    }

    /// Add minutes to timestamp
    pub fn addMinutes(timestamp: i64, minutes: i64) !i64 {
        const ms = minutes * Constants.MS_PER_MINUTE;
        return addMilliseconds(timestamp, ms);
    }

    /// Add hours to timestamp
    pub fn addHours(timestamp: i64, hours: i64) !i64 {
        const ms = hours * Constants.MS_PER_HOUR;
        return addMilliseconds(timestamp, ms);
    }

    /// Add days to timestamp
    pub fn addDays(timestamp: i64, days: i64) !i64 {
        const ms = days * Constants.MS_PER_DAY;
        return addMilliseconds(timestamp, ms);
    }

    /// Calculate difference in milliseconds. Returns null (this library's NaN)
    /// if either timestamp is Invalid Date, mirroring `NaN - x === NaN` in JS.
    pub fn diffMilliseconds(timestamp1: i64, timestamp2: i64) ?i64 {
        if (CalendarUtils.isInvalidTimestamp(timestamp1) or CalendarUtils.isInvalidTimestamp(timestamp2)) {
            return null;
        }
        return timestamp1 - timestamp2;
    }

    /// Calculate difference in seconds. Returns null if either timestamp is Invalid Date.
    pub fn diffSeconds(timestamp1: i64, timestamp2: i64) ?i64 {
        const ms = diffMilliseconds(timestamp1, timestamp2) orelse return null;
        return @divTrunc(ms, Constants.MS_PER_SECOND);
    }

    /// Calculate difference in minutes. Returns null if either timestamp is Invalid Date.
    pub fn diffMinutes(timestamp1: i64, timestamp2: i64) ?i64 {
        const ms = diffMilliseconds(timestamp1, timestamp2) orelse return null;
        return @divTrunc(ms, Constants.MS_PER_MINUTE);
    }

    /// Calculate difference in hours. Returns null if either timestamp is Invalid Date.
    pub fn diffHours(timestamp1: i64, timestamp2: i64) ?i64 {
        const ms = diffMilliseconds(timestamp1, timestamp2) orelse return null;
        return @divTrunc(ms, Constants.MS_PER_HOUR);
    }

    /// Calculate difference in days. Returns null if either timestamp is Invalid Date.
    pub fn diffDays(timestamp1: i64, timestamp2: i64) ?i64 {
        const ms = diffMilliseconds(timestamp1, timestamp2) orelse return null;
        return @divTrunc(ms, Constants.MS_PER_DAY);
    }

    /// Compare two timestamps. Returns null (not lt/eq/gt) if either timestamp
    /// is Invalid Date: per ECMA-262, any relational comparison or equality
    /// check involving NaN is neither less-than, equal, nor greater-than.
    pub fn compare(timestamp1: i64, timestamp2: i64) ?std.math.Order {
        if (CalendarUtils.isInvalidTimestamp(timestamp1) or CalendarUtils.isInvalidTimestamp(timestamp2)) {
            return null;
        }
        if (timestamp1 < timestamp2) {
            return .lt;
        } else if (timestamp1 > timestamp2) {
            return .gt;
        } else {
            return .eq;
        }
    }

    /// Check if first timestamp is before second. Always false if either is
    /// Invalid Date (matching `NaN < x` and `x < NaN` both being false in JS).
    pub fn before(timestamp1: i64, timestamp2: i64) bool {
        if (CalendarUtils.isInvalidTimestamp(timestamp1) or CalendarUtils.isInvalidTimestamp(timestamp2)) {
            return false;
        }
        return timestamp1 < timestamp2;
    }

    /// Check if first timestamp is after second. Always false if either is Invalid Date.
    pub fn after(timestamp1: i64, timestamp2: i64) bool {
        if (CalendarUtils.isInvalidTimestamp(timestamp1) or CalendarUtils.isInvalidTimestamp(timestamp2)) {
            return false;
        }
        return timestamp1 > timestamp2;
    }

    /// Check if timestamps are equal. Always false if either is Invalid Date
    /// (matching `NaN === NaN` being false in JS, so two invalid dates never
    /// compare equal).
    pub fn equals(timestamp1: i64, timestamp2: i64) bool {
        if (CalendarUtils.isInvalidTimestamp(timestamp1) or CalendarUtils.isInvalidTimestamp(timestamp2)) {
            return false;
        }
        return timestamp1 == timestamp2;
    }
};
