const std = @import("std");
const constants = @import("constants.zig");
const timezone = @import("timezone.zig");
const calendar = @import("calendar.zig");

const Constants = constants.Constants;
const TimezoneMode = timezone.TimezoneMode;
const CalendarUtils = calendar.CalendarUtils;

/// Getter methods for date components
pub const GetterMethods = struct {
    /// Get year from timestamp
    /// Labeled block example 5 from specification
    pub fn getFullYear(timestamp: i64, tz_mode: TimezoneMode) i32 {
        year_extractor: {
            if (timestamp == Constants.INVALID_TIME) {
                return 0; // Invalid date
            }

            break :year_extractor;
        }

        // Get components with timezone applied
        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.year;
    }

    /// Get month (0-11) from timestamp
    /// Labeled block example 6 from specification
    pub fn getMonth(timestamp: i64, tz_mode: TimezoneMode) i32 {
        month_extractor: {
            if (timestamp == Constants.INVALID_TIME) {
                return 0;
            }

            break :month_extractor;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.month;
    }

    /// Get day of month (1-31) from timestamp
    pub fn getDate(timestamp: i64, tz_mode: TimezoneMode) i32 {
        if (timestamp == Constants.INVALID_TIME) {
            return 0;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.day;
    }

    /// Get day of week (0-6, Sunday=0) from timestamp
    pub fn getDay(timestamp: i64, tz_mode: TimezoneMode) i32 {
        if (timestamp == Constants.INVALID_TIME) {
            return 0;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return CalendarUtils.getDayOfWeek(components.year, components.month, components.day);
    }

    /// Get hours (0-23) from timestamp
    pub fn getHours(timestamp: i64, tz_mode: TimezoneMode) i32 {
        if (timestamp == Constants.INVALID_TIME) {
            return 0;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.hour;
    }

    /// Get minutes (0-59) from timestamp
    pub fn getMinutes(timestamp: i64, tz_mode: TimezoneMode) i32 {
        if (timestamp == Constants.INVALID_TIME) {
            return 0;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.minute;
    }

    /// Get seconds (0-59) from timestamp
    pub fn getSeconds(timestamp: i64, tz_mode: TimezoneMode) i32 {
        if (timestamp == Constants.INVALID_TIME) {
            return 0;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.second;
    }

    /// Get milliseconds (0-999) from timestamp
    pub fn getMilliseconds(timestamp: i64, tz_mode: TimezoneMode) i32 {
        if (timestamp == Constants.INVALID_TIME) {
            return 0;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.millisecond;
    }

    /// Get timestamp value
    pub fn getTime(timestamp: i64) i64 {
        return timestamp;
    }

    /// Get timezone offset in minutes (UTC - local)
    pub fn getTimezoneOffset() i32 {
        return timezone.TimezoneUtils.getTimezoneOffsetMinutes();
    }
};
