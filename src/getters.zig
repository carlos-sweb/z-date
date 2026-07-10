const std = @import("std");
const constants = @import("constants.zig");
const timezone = @import("timezone.zig");
const calendar = @import("calendar.zig");

const Constants = constants.Constants;
const TimezoneMode = timezone.TimezoneMode;
const CalendarUtils = calendar.CalendarUtils;

/// Getter methods for date components.
/// All component getters return `null` for an Invalid Date, mirroring the NaN
/// that ECMAScript's Date.prototype getters produce.
pub const GetterMethods = struct {
    /// Get year from timestamp
    pub fn getFullYear(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }

        // Get components with timezone applied
        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.year;
    }

    /// Get month (0-11) from timestamp
    pub fn getMonth(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.month;
    }

    /// Get day of month (1-31) from timestamp
    pub fn getDate(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.day;
    }

    /// Get day of week (0-6, Sunday=0) from timestamp
    pub fn getDay(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return CalendarUtils.getDayOfWeek(components.year, components.month, components.day);
    }

    /// Get hours (0-23) from timestamp
    pub fn getHours(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.hour;
    }

    /// Get minutes (0-59) from timestamp
    pub fn getMinutes(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.minute;
    }

    /// Get seconds (0-59) from timestamp
    pub fn getSeconds(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.second;
    }

    /// Get milliseconds (0-999) from timestamp
    pub fn getMilliseconds(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }

        const components = CalendarUtils.timestampToComponents(timestamp, tz_mode);
        return components.millisecond;
    }

    /// Get timestamp value
    pub fn getTime(timestamp: i64) i64 {
        return timestamp;
    }

    /// Legacy getYear() (ECMA-262 Annex B.2.3): full year minus 1900, local
    /// time only (there is no UTC variant in the spec). Superseded by
    /// getFullYear(); kept for compatibility.
    pub fn getYear(timestamp: i64, tz_mode: TimezoneMode) ?i32 {
        const year = getFullYear(timestamp, tz_mode) orelse return null;
        return year - 1900;
    }

    /// Get timezone offset in minutes (UTC - local) in effect at the given
    /// timestamp. Per ECMA-262 the offset is a property of the specific date
    /// (it changes across DST transitions), and NaN (here: null) for an
    /// Invalid Date.
    pub fn getTimezoneOffset(timestamp: i64) ?i32 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }
        return timezone.TimezoneUtils.getTimezoneOffsetMinutes(timestamp);
    }
};
