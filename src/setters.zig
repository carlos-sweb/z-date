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
        // ECMA-262 21.4.4.27 step 2: "If t is NaN, set t to +0." --
        // unlike every OTHER date setter (setMonth/setDate/setHours/...,
        // which just propagate an invalid date's NaN unchanged),
        // setFullYear alone treats an invalid date as epoch and
        // proceeds to compute a fresh, valid timestamp from the given
        // year (and month/day, if given). Confirmed against real Node:
        // `new Date(NaN).setFullYear(2016)` repairs the date;
        // `new Date(NaN).setMonth(5)` stays NaN.
        const base_ts: i64 = if (timestamp.* == Constants.INVALID_TIME) 0 else timestamp.*;

        // Get current (or, if repairing, epoch) components
        var components = CalendarUtils.timestampToComponents(base_ts, tz_mode);

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
        if (CalendarUtils.isInvalidTimestamp(timestamp.*)) return Constants.INVALID_TIME;
        const adjusted = timezone.TimezoneUtils.applyTimezoneOffset(timestamp.*, tz_mode);
        const in_day = @mod(adjusted, Constants.MS_PER_DAY);
        const midnight = adjusted - in_day;
        // Every i32 component product and their sum fit i64, even at TimeClip's limits.
        const computed = midnight +
            @as(i64, hour) * Constants.MS_PER_HOUR +
            @as(i64, min orelse @as(i32, @intCast(@mod(@divTrunc(in_day, Constants.MS_PER_MINUTE), 60)))) * Constants.MS_PER_MINUTE +
            @as(i64, sec orelse @as(i32, @intCast(@mod(@divTrunc(in_day, Constants.MS_PER_SECOND), 60)))) * Constants.MS_PER_SECOND +
            @as(i64, ms orelse @as(i32, @intCast(@mod(in_day, 1000)))) * 1;
        return finalize(timestamp, timezone.TimezoneUtils.removeTimezoneOffset(computed, tz_mode));
    }

    /// Set minutes component
    pub fn setMinutes(
        timestamp: *i64,
        min: i32,
        sec: ?i32,
        ms: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (CalendarUtils.isInvalidTimestamp(timestamp.*)) return Constants.INVALID_TIME;
        const adjusted = timezone.TimezoneUtils.applyTimezoneOffset(timestamp.*, tz_mode);
        const in_day = @mod(adjusted, Constants.MS_PER_DAY);
        const midnight = adjusted - in_day;
        // Every i32 component product and their sum fit i64, even at TimeClip's limits.
        const computed = midnight +
            @mod(@divTrunc(in_day, Constants.MS_PER_HOUR), 24) * Constants.MS_PER_HOUR +
            @as(i64, min) * Constants.MS_PER_MINUTE +
            @as(i64, sec orelse @as(i32, @intCast(@mod(@divTrunc(in_day, Constants.MS_PER_SECOND), 60)))) * Constants.MS_PER_SECOND +
            @as(i64, ms orelse @as(i32, @intCast(@mod(in_day, 1000)))) * 1;
        return finalize(timestamp, timezone.TimezoneUtils.removeTimezoneOffset(computed, tz_mode));
    }

    /// Set seconds component
    pub fn setSeconds(
        timestamp: *i64,
        sec: i32,
        ms: ?i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (CalendarUtils.isInvalidTimestamp(timestamp.*)) return Constants.INVALID_TIME;
        const adjusted = timezone.TimezoneUtils.applyTimezoneOffset(timestamp.*, tz_mode);
        const in_day = @mod(adjusted, Constants.MS_PER_DAY);
        const midnight = adjusted - in_day;
        // Every i32 component product and their sum fit i64, even at TimeClip's limits.
        const computed = midnight +
            @mod(@divTrunc(in_day, Constants.MS_PER_HOUR), 24) * Constants.MS_PER_HOUR +
            @mod(@divTrunc(in_day, Constants.MS_PER_MINUTE), 60) * Constants.MS_PER_MINUTE +
            @as(i64, sec) * Constants.MS_PER_SECOND +
            @as(i64, ms orelse @as(i32, @intCast(@mod(in_day, 1000)))) * 1;
        return finalize(timestamp, timezone.TimezoneUtils.removeTimezoneOffset(computed, tz_mode));
    }

    /// Set milliseconds component
    pub fn setMilliseconds(
        timestamp: *i64,
        ms: i32,
        tz_mode: TimezoneMode,
    ) i64 {
        if (CalendarUtils.isInvalidTimestamp(timestamp.*)) return Constants.INVALID_TIME;
        const adjusted = timezone.TimezoneUtils.applyTimezoneOffset(timestamp.*, tz_mode);
        const in_day = @mod(adjusted, Constants.MS_PER_DAY);
        const midnight = adjusted - in_day;
        // Every i32 component product and their sum fit i64, even at TimeClip's limits.
        const computed = midnight +
            @mod(@divTrunc(in_day, Constants.MS_PER_HOUR), 24) * Constants.MS_PER_HOUR +
            @mod(@divTrunc(in_day, Constants.MS_PER_MINUTE), 60) * Constants.MS_PER_MINUTE +
            @mod(@divTrunc(in_day, Constants.MS_PER_SECOND), 60) * Constants.MS_PER_SECOND +
            @as(i64, ms) * 1;
        return finalize(timestamp, timezone.TimezoneUtils.removeTimezoneOffset(computed, tz_mode));
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
    /// Like setFullYear, repairs Invalid Date by using epoch as the base.
    pub fn setYear(timestamp: *i64, year: i32, tz_mode: TimezoneMode) i64 {
        const full_year = if (year >= 0 and year <= 99) 1900 + year else year;
        return setFullYear(timestamp, full_year, null, null, tz_mode);
    }
};
