const std = @import("std");
const constants = @import("constants.zig");
const errors = @import("errors.zig");

const Constants = constants.Constants;
const ZDateError = errors.ZDateError;

/// Arithmetic operations on dates
pub const ArithmeticMethods = struct {
    /// Add milliseconds to timestamp
    /// Labeled block example 11 from specification
    pub fn addMilliseconds(timestamp: i64, ms: i64) !i64 {
        var new_timestamp: i64 = undefined;

        adder: {
            // Check for overflow
            const result = @addWithOverflow(timestamp, ms);
            if (result[1] != 0) { // overflow occurred
                return ZDateError.TimestampOverflow;
            }

            new_timestamp = result[0];

            // Validate range
            if (new_timestamp < Constants.MIN_TIME or new_timestamp > Constants.MAX_TIME) {
                return ZDateError.OutOfRange;
            }

            break :adder;
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

    /// Calculate difference in milliseconds
    pub fn diffMilliseconds(timestamp1: i64, timestamp2: i64) i64 {
        return timestamp1 - timestamp2;
    }

    /// Calculate difference in seconds
    pub fn diffSeconds(timestamp1: i64, timestamp2: i64) i64 {
        return @divTrunc(diffMilliseconds(timestamp1, timestamp2), Constants.MS_PER_SECOND);
    }

    /// Calculate difference in minutes
    pub fn diffMinutes(timestamp1: i64, timestamp2: i64) i64 {
        return @divTrunc(diffMilliseconds(timestamp1, timestamp2), Constants.MS_PER_MINUTE);
    }

    /// Calculate difference in hours
    pub fn diffHours(timestamp1: i64, timestamp2: i64) i64 {
        return @divTrunc(diffMilliseconds(timestamp1, timestamp2), Constants.MS_PER_HOUR);
    }

    /// Calculate difference in days
    pub fn diffDays(timestamp1: i64, timestamp2: i64) i64 {
        return @divTrunc(diffMilliseconds(timestamp1, timestamp2), Constants.MS_PER_DAY);
    }

    /// Compare two timestamps
    pub fn compare(timestamp1: i64, timestamp2: i64) std.math.Order {
        if (timestamp1 < timestamp2) {
            return .lt;
        } else if (timestamp1 > timestamp2) {
            return .gt;
        } else {
            return .eq;
        }
    }

    /// Check if first timestamp is before second
    pub fn before(timestamp1: i64, timestamp2: i64) bool {
        return timestamp1 < timestamp2;
    }

    /// Check if first timestamp is after second
    pub fn after(timestamp1: i64, timestamp2: i64) bool {
        return timestamp1 > timestamp2;
    }

    /// Check if timestamps are equal
    pub fn equals(timestamp1: i64, timestamp2: i64) bool {
        return timestamp1 == timestamp2;
    }
};
