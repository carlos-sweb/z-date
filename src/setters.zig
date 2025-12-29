const std = @import("std");
const constants = @import("constants.zig");
const timezone = @import("timezone.zig");
const calendar = @import("calendar.zig");

const Constants = constants.Constants;
const TimezoneMode = timezone.TimezoneMode;
const CalendarUtils = calendar.CalendarUtils;
const DateComponents = calendar.DateComponents;

/// Setter methods for date components
pub const SetterMethods = struct {
    /// Set year component
    /// Labeled block example 7 from specification
    pub fn setFullYear(
        timestamp: *i64,
        year: i32,
        month: ?i32,
        day: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        // Get current components
        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);

        year_setter: {
            // Update components
            components.year = year;
            if (month) |m| components.month = m;
            if (day) |d| components.day = d;

            // Normalize components (handle overflow)
            CalendarUtils.normalizeComponents(&components);

            // Validate
            if (!CalendarUtils.validateComponents(components)) {
                timestamp.* = Constants.INVALID_TIME;
                return Constants.INVALID_TIME;
            }

            break :year_setter;
        }

        // Convert back to timestamp
        timestamp.* = CalendarUtils.componentsToTimestamp(components, tz_mode);
        return timestamp.*;
    }

    /// Set month component
    pub fn setMonth(
        timestamp: *i64,
        month: i32,
        day: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.month = month;
        if (day) |d| components.day = d;

        CalendarUtils.normalizeComponents(&components);

        if (!CalendarUtils.validateComponents(components)) {
            timestamp.* = Constants.INVALID_TIME;
            return Constants.INVALID_TIME;
        }

        timestamp.* = CalendarUtils.componentsToTimestamp(components, tz_mode);
        return timestamp.*;
    }

    /// Set day of month
    pub fn setDate(
        timestamp: *i64,
        day: i32,
        tz_mode: TimezoneMode,
    ) i64 {
        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.day = day;

        CalendarUtils.normalizeComponents(&components);

        if (!CalendarUtils.validateComponents(components)) {
            timestamp.* = Constants.INVALID_TIME;
            return Constants.INVALID_TIME;
        }

        timestamp.* = CalendarUtils.componentsToTimestamp(components, tz_mode);
        return timestamp.*;
    }

    /// Set hours component
    pub fn setHours(
        timestamp: *i64,
        hour: i32,
        min: ?i32,
        sec: ?i32,
        ms: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.hour = hour;
        if (min) |m| components.minute = m;
        if (sec) |s| components.second = s;
        if (ms) |millisecond| components.millisecond = millisecond;

        CalendarUtils.normalizeComponents(&components);

        if (!CalendarUtils.validateComponents(components)) {
            timestamp.* = Constants.INVALID_TIME;
            return Constants.INVALID_TIME;
        }

        timestamp.* = CalendarUtils.componentsToTimestamp(components, tz_mode);
        return timestamp.*;
    }

    /// Set minutes component
    pub fn setMinutes(
        timestamp: *i64,
        min: i32,
        sec: ?i32,
        ms: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.minute = min;
        if (sec) |s| components.second = s;
        if (ms) |millisecond| components.millisecond = millisecond;

        CalendarUtils.normalizeComponents(&components);

        if (!CalendarUtils.validateComponents(components)) {
            timestamp.* = Constants.INVALID_TIME;
            return Constants.INVALID_TIME;
        }

        timestamp.* = CalendarUtils.componentsToTimestamp(components, tz_mode);
        return timestamp.*;
    }

    /// Set seconds component
    pub fn setSeconds(
        timestamp: *i64,
        sec: i32,
        ms: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.second = sec;
        if (ms) |millisecond| components.millisecond = millisecond;

        CalendarUtils.normalizeComponents(&components);

        if (!CalendarUtils.validateComponents(components)) {
            timestamp.* = Constants.INVALID_TIME;
            return Constants.INVALID_TIME;
        }

        timestamp.* = CalendarUtils.componentsToTimestamp(components, tz_mode);
        return timestamp.*;
    }

    /// Set milliseconds component
    pub fn setMilliseconds(
        timestamp: *i64,
        ms: i32,
        tz_mode: TimezoneMode,
    ) i64 {
        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.millisecond = ms;

        CalendarUtils.normalizeComponents(&components);

        if (!CalendarUtils.validateComponents(components)) {
            timestamp.* = Constants.INVALID_TIME;
            return Constants.INVALID_TIME;
        }

        timestamp.* = CalendarUtils.componentsToTimestamp(components, tz_mode);
        return timestamp.*;
    }

    /// Set timestamp directly
    pub fn setTime(timestamp: *i64, new_time: i64) i64 {
        timestamp.* = new_time;
        return timestamp.*;
    }
};
