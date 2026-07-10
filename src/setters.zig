const std = @import("std");
const constants = @import("constants.zig");
const timezone = @import("timezone.zig");
const calendar = @import("calendar.zig");

const Constants = constants.Constants;
const TimezoneMode = timezone.TimezoneMode;
const CalendarUtils = calendar.CalendarUtils;
const DateComponents = calendar.DateComponents;

/// Clamp a freshly computed timestamp to the valid ECMAScript time range,
/// turning out-of-range results into Invalid Date.
fn finalize(timestamp: *i64, computed: i64) i64 {
    if (computed < Constants.MIN_TIME or computed > Constants.MAX_TIME) {
        timestamp.* = Constants.INVALID_TIME;
    } else {
        timestamp.* = computed;
    }
    return timestamp.*;
}

/// Setter methods for date components
pub const SetterMethods = struct {
    /// Set year component
    pub fn setFullYear(
        timestamp: *i64,
        year: i32,
        month: ?i32,
        day: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (timestamp.* == Constants.INVALID_TIME) {
            return Constants.INVALID_TIME;
        }

        // Get current components
        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);

        // Update components
        components.year = year;
        if (month) |m| components.month = m;
        if (day) |d| components.day = d;

        // Normalize components (handle overflow)
        CalendarUtils.normalizeComponents(&components);

        // Convert back to timestamp
        return finalize(timestamp, CalendarUtils.componentsToTimestamp(components, tz_mode));
    }

    /// Set month component
    pub fn setMonth(
        timestamp: *i64,
        month: i32,
        day: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (timestamp.* == Constants.INVALID_TIME) {
            return Constants.INVALID_TIME;
        }

        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.month = month;
        if (day) |d| components.day = d;

        CalendarUtils.normalizeComponents(&components);

        return finalize(timestamp, CalendarUtils.componentsToTimestamp(components, tz_mode));
    }

    /// Set day of month
    pub fn setDate(
        timestamp: *i64,
        day: i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (timestamp.* == Constants.INVALID_TIME) {
            return Constants.INVALID_TIME;
        }

        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.day = day;

        CalendarUtils.normalizeComponents(&components);

        return finalize(timestamp, CalendarUtils.componentsToTimestamp(components, tz_mode));
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
        if (timestamp.* == Constants.INVALID_TIME) {
            return Constants.INVALID_TIME;
        }

        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.hour = hour;
        if (min) |m| components.minute = m;
        if (sec) |s| components.second = s;
        if (ms) |millisecond| components.millisecond = millisecond;

        CalendarUtils.normalizeComponents(&components);

        return finalize(timestamp, CalendarUtils.componentsToTimestamp(components, tz_mode));
    }

    /// Set minutes component
    pub fn setMinutes(
        timestamp: *i64,
        min: i32,
        sec: ?i32,
        ms: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (timestamp.* == Constants.INVALID_TIME) {
            return Constants.INVALID_TIME;
        }

        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.minute = min;
        if (sec) |s| components.second = s;
        if (ms) |millisecond| components.millisecond = millisecond;

        CalendarUtils.normalizeComponents(&components);

        return finalize(timestamp, CalendarUtils.componentsToTimestamp(components, tz_mode));
    }

    /// Set seconds component
    pub fn setSeconds(
        timestamp: *i64,
        sec: i32,
        ms: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (timestamp.* == Constants.INVALID_TIME) {
            return Constants.INVALID_TIME;
        }

        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.second = sec;
        if (ms) |millisecond| components.millisecond = millisecond;

        CalendarUtils.normalizeComponents(&components);

        return finalize(timestamp, CalendarUtils.componentsToTimestamp(components, tz_mode));
    }

    /// Set milliseconds component
    pub fn setMilliseconds(
        timestamp: *i64,
        ms: i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (timestamp.* == Constants.INVALID_TIME) {
            return Constants.INVALID_TIME;
        }

        var components = CalendarUtils.timestampToComponents(timestamp.*, tz_mode);
        components.millisecond = ms;

        CalendarUtils.normalizeComponents(&components);

        return finalize(timestamp, CalendarUtils.componentsToTimestamp(components, tz_mode));
    }

    /// Set timestamp directly (Date.prototype.setTime semantics: out-of-range → Invalid Date)
    pub fn setTime(timestamp: *i64, new_time: i64) i64 {
        return finalize(timestamp, new_time);
    }

    /// Legacy setYear() (ECMA-262 Annex B.2.3): maps a two-digit year (0-99)
    /// to 1900-1999 like the Date constructor's MakeFullYear does, then
    /// behaves like setFullYear(). Local time only (there is no UTC variant
    /// in the spec).
    ///
    /// Deviates from Annex B.2.3 in one respect: the spec resets an Invalid
    /// Date to epoch (+0) before applying the year, so setYear can make an
    /// invalid Date valid again. This library keeps its usual "Invalid Date
    /// stays Invalid Date" rule (shared by every other setter, via
    /// setFullYear's own guard) instead, to avoid that surprising
    /// invalid-becomes-valid side effect.
    pub fn setYear(timestamp: *i64, year: i32, tz_mode: TimezoneMode) i64 {
        const full_year = if (year >= 0 and year <= 99) 1900 + year else year;
        return setFullYear(timestamp, full_year, null, null, tz_mode);
    }
};
