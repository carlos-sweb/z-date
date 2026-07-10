const std = @import("std");
const constants = @import("constants.zig");
const timezone = @import("timezone.zig");
const errors = @import("errors.zig");

const Constants = constants.Constants;
const TimezoneMode = timezone.TimezoneMode;
const TimezoneUtils = timezone.TimezoneUtils;
const ZDateError = errors.ZDateError;

/// Date components structure
pub const DateComponents = struct {
    year: i32,
    month: i32, // 0-11
    day: i32, // 1-31
    hour: i32, // 0-23
    minute: i32, // 0-59
    second: i32, // 0-59
    millisecond: i32, // 0-999
};

/// Calendar calculation utilities
pub const CalendarUtils = struct {
    /// True if `timestamp` cannot represent a valid ECMAScript Date: either
    /// the `INVALID_TIME` sentinel, or outside `[MIN_TIME, MAX_TIME]`.
    ///
    /// `timestamp` is a public field on `ZDate`, so a caller can construct a
    /// value directly (bypassing every constructor/setter) that is neither
    /// the exact sentinel nor within the representable range; every getter
    /// and non-ISO formatter must check both conditions before calling
    /// `timestampToComponents`, not just equality with the sentinel.
    pub fn isInvalidTimestamp(timestamp: i64) bool {
        return timestamp == Constants.INVALID_TIME or
            timestamp < Constants.MIN_TIME or
            timestamp > Constants.MAX_TIME;
    }

    /// Check if year is leap year
    pub fn isLeapYear(year: i32) bool {
        // Divisible by 4
        if (@mod(year, 4) != 0) {
            return false;
        }

        // Century years must be divisible by 400
        if (@mod(year, 100) == 0) {
            if (@mod(year, 400) != 0) {
                return false;
            }
        }

        return true;
    }

    /// Get days in month
    pub fn getDaysInMonth(year: i32, month: i32) i32 {
        // Validate month
        if (month < 0 or month > 11) {
            return 0;
        }

        var days = Constants.DAYS_IN_MONTH[@intCast(month)];

        // February in leap year
        if (month == 1 and isLeapYear(year)) {
            days = 29;
        }

        return days;
    }

    /// Get day of week (0-6, Sunday=0), derived from days-since-epoch with
    /// the same calendar arithmetic as the rest of the library.
    ///
    /// (Previously Zeller's congruence, whose truncated-division `k`/`j`
    /// split silently produced wrong weekdays for negative (BCE) years — a
    /// bug surfaced by differential testing against V8.)
    pub fn getDayOfWeek(year: i32, month: i32, day: i32) i32 {
        var days: i64 = yearToEpochDay(year);
        var m: i32 = 0;
        while (m < month) : (m += 1) {
            days += getDaysInMonth(year, m);
        }
        days += day - 1;

        // 1970-01-01 was a Thursday (day-of-week 4, Sunday = 0); @mod is
        // floored, so negative epoch days resolve correctly.
        return @intCast(@mod(days + 4, 7));
    }

    /// Get day of year (0-365)
    pub fn getDayOfYear(year: i32, month: i32, day: i32) i32 {
        var day_of_year: i32 = day;

        var m: i32 = 0;
        while (m < month) : (m += 1) {
            day_of_year += getDaysInMonth(year, m);
        }

        return day_of_year;
    }

    /// Convert timestamp to date components
    pub fn timestampToComponents(timestamp: i64, mode: TimezoneMode) DateComponents {
        // Apply timezone offset if needed
        const adjusted_ts = TimezoneUtils.applyTimezoneOffset(timestamp, mode);

        // Extract time components (milliseconds within day)
        const ms_in_day = @mod(adjusted_ts, Constants.MS_PER_DAY);
        var positive_ms_in_day = ms_in_day;
        if (positive_ms_in_day < 0) {
            positive_ms_in_day += Constants.MS_PER_DAY;
        }

        const millisecond: i32 = @intCast(@mod(positive_ms_in_day, 1000));
        const seconds_in_day = @divTrunc(positive_ms_in_day, 1000);
        const second: i32 = @intCast(@mod(seconds_in_day, 60));
        const minutes_in_day = @divTrunc(seconds_in_day, 60);
        const minute: i32 = @intCast(@mod(minutes_in_day, 60));
        const hour: i32 = @intCast(@divTrunc(minutes_in_day, 60));

        // Calculate days since epoch
        const days_since_epoch = @divFloor(adjusted_ts, Constants.MS_PER_DAY);

        // Calculate year (approximate then adjust)
        // Average days per year including leap years
        var year: i32 = 1970 + @as(i32, @intCast(@divTrunc(days_since_epoch * 400, 146097)));

        // Adjust year if necessary
        while (true) {
            const year_start_day = yearToEpochDay(year);
            const next_year_start_day = yearToEpochDay(year + 1);

            if (days_since_epoch >= year_start_day and days_since_epoch < next_year_start_day) {
                break;
            }

            if (days_since_epoch < year_start_day) {
                year -= 1;
            } else {
                year += 1;
            }
        }

        // Calculate day of year
        const year_start_day = yearToEpochDay(year);
        const day_of_year = @as(i32, @intCast(days_since_epoch - year_start_day));

        // Calculate month and day
        var month: i32 = 0;
        var day_in_month: i32 = day_of_year + 1;

        while (month < 12) : (month += 1) {
            const days_in_current_month = getDaysInMonth(year, month);
            if (day_in_month <= days_in_current_month) {
                break;
            }
            day_in_month -= days_in_current_month;
        }

        return DateComponents{
            .year = year,
            .month = month,
            .day = day_in_month,
            .hour = hour,
            .minute = minute,
            .second = second,
            .millisecond = millisecond,
        };
    }

    /// Convert date components to timestamp
    ///
    /// Uses saturating arithmetic for the final millisecond computation: a
    /// component set whose `year` is so extreme that `days * MS_PER_DAY`
    /// would overflow i64 (e.g. year ~2e9, still well within i32) saturates
    /// to i64::MAX/MIN instead of panicking. i64::MAX/MIN is far outside
    /// [MIN_TIME, MAX_TIME], so callers that check the returned timestamp
    /// against that range (as `fromTimestamp`/`finalize` do) correctly treat
    /// it as Invalid Date.
    pub fn componentsToTimestamp(components: DateComponents, mode: TimezoneMode) i64 {
        // Calculate days since epoch
        var days: i64 = yearToEpochDay(components.year);

        // Add days for complete months
        var m: i32 = 0;
        while (m < components.month) : (m += 1) {
            days += getDaysInMonth(components.year, m);
        }

        // Add remaining days
        days += components.day - 1;

        // Calculate total milliseconds
        var timestamp: i64 = days *| Constants.MS_PER_DAY;
        timestamp +|= @as(i64, components.hour) * Constants.MS_PER_HOUR;
        timestamp +|= @as(i64, components.minute) * Constants.MS_PER_MINUTE;
        timestamp +|= @as(i64, components.second) * Constants.MS_PER_SECOND;
        timestamp +|= @as(i64, components.millisecond);

        // Remove timezone offset if in local mode
        return TimezoneUtils.removeTimezoneOffset(timestamp, mode);
    }

    /// Calculate days since epoch for a given year's January 1
    ///
    /// Takes `year` as i64 (any i32 value widens implicitly) so that
    /// `year - 1970` can never overflow, even for `year == minInt(i32)`.
    fn yearToEpochDay(year: i64) i64 {
        const y = year - 1970;

        // Count leap years between 1970 and year
        var leap_years: i64 = 0;

        if (y >= 0) {
            // Years since 1970
            const years_since = y;
            // Count leap years: every 4 years, except centuries, except every 400 years

            // Leap years from 1970 to year-1
            leap_years = @divFloor(years_since + 1, 4) - @divFloor(years_since + 69, 100) + @divFloor(years_since + 369, 400);
        } else {
            // Years before 1970
            const years_before = -y;
            leap_years = -(@divFloor(years_before + 2, 4) - @divFloor(years_before + 30, 100) + @divFloor(years_before + 30, 400));
        }

        const total_days = y * 365 + leap_years;
        return total_days;
    }

    /// Validate date components
    pub fn validateComponents(components: DateComponents) bool {
        // Validate month
        if (components.month < 0 or components.month > 11) {
            return false;
        }

        // Validate day
        const max_days = getDaysInMonth(components.year, components.month);
        if (components.day < 1 or components.day > max_days) {
            return false;
        }

        // Validate hour
        if (components.hour < 0 or components.hour > 23) {
            return false;
        }

        // Validate minute
        if (components.minute < 0 or components.minute > 59) {
            return false;
        }

        // Validate second
        if (components.second < 0 or components.second > 59) {
            return false;
        }

        // Validate millisecond
        if (components.millisecond < 0 or components.millisecond > 999) {
            return false;
        }

        return true;
    }

    /// Normalize components (handle overflow/underflow)
    ///
    /// All arithmetic is done with i64 locals so a caller-supplied component
    /// far outside its normal range (e.g. `month == minInt(i32)`) can never
    /// overflow i32 mid-computation; fields are narrowed back to i32 only at
    /// the very end, with `year` clamped (not truncated) into i32 range.
    ///
    /// The day/month carry is resolved by converting to an absolute
    /// day-since-epoch offset and back (the same closed-form year
    /// approximation `timestampToComponents` uses), instead of a per-month
    /// loop — so a pathological `day` (e.g. 2_000_000_000) normalizes in
    /// O(1) instead of tens of millions of loop iterations.
    pub fn normalizeComponents(components: *DateComponents) void {
        var year: i64 = components.year;
        var month: i64 = components.month;
        var day: i64 = components.day;
        var hour: i64 = components.hour;
        var minute: i64 = components.minute;
        var second: i64 = components.second;
        var millisecond: i64 = components.millisecond;

        // Normalize milliseconds
        if (millisecond >= 1000 or millisecond < 0) {
            const extra_seconds = @divFloor(millisecond, 1000);
            second += extra_seconds;
            millisecond -= extra_seconds * 1000;
        }

        // Normalize seconds
        if (second >= 60 or second < 0) {
            const extra_minutes = @divFloor(second, 60);
            minute += extra_minutes;
            second -= extra_minutes * 60;
        }

        // Normalize minutes
        if (minute >= 60 or minute < 0) {
            const extra_hours = @divFloor(minute, 60);
            hour += extra_hours;
            minute -= extra_hours * 60;
        }

        // Normalize hours
        if (hour >= 24 or hour < 0) {
            const extra_days = @divFloor(hour, 24);
            day += extra_days;
            hour -= extra_days * 24;
        }

        // Normalize months (handle overflow/underflow)
        if (month >= 12 or month < 0) {
            const extra_years = @divFloor(month, 12);
            year += extra_years;
            month -= extra_years * 12;
        }

        // Normalize day/month (variable month lengths). `month` is already
        // in [0,11] at this point. Skip the (more expensive) round-trip
        // entirely in the common case where `day` is already in range.
        const year_for_lookup: i32 = @intCast(std.math.clamp(year, std.math.minInt(i32), std.math.maxInt(i32)));
        const month_i32: i32 = @intCast(month);
        if (day < 1 or day > getDaysInMonth(year_for_lookup, month_i32)) {
            var days_before_month: i64 = 0;
            var m: i64 = 0;
            while (m < month) : (m += 1) {
                days_before_month += getDaysInMonth(year_for_lookup, @intCast(m));
            }

            const absolute_day: i64 = yearToEpochDay(year) + days_before_month + (day - 1);

            // Approximate the year from the absolute day offset (same ratio
            // as timestampToComponents: 146097 days == 400 Gregorian years),
            // then adjust by a small, bounded number of steps.
            var new_year: i64 = 1970 + @divTrunc(absolute_day * 400, 146097);
            while (true) {
                const year_start = yearToEpochDay(new_year);
                const next_year_start = yearToEpochDay(new_year + 1);
                if (absolute_day >= year_start and absolute_day < next_year_start) break;
                if (absolute_day < year_start) new_year -= 1 else new_year += 1;
            }

            const new_year_for_lookup: i32 = @intCast(std.math.clamp(new_year, std.math.minInt(i32), std.math.maxInt(i32)));
            const day_of_year = absolute_day - yearToEpochDay(new_year);

            var new_month: i32 = 0;
            var day_in_month: i64 = day_of_year + 1;
            while (new_month < 12) : (new_month += 1) {
                const days_in_current = getDaysInMonth(new_year_for_lookup, new_month);
                if (day_in_month <= days_in_current) break;
                day_in_month -= days_in_current;
            }

            year = new_year;
            month = new_month;
            day = day_in_month;
        }

        components.year = @intCast(std.math.clamp(year, std.math.minInt(i32), std.math.maxInt(i32)));
        components.month = @intCast(month);
        components.day = @intCast(day);
        components.hour = @intCast(hour);
        components.minute = @intCast(minute);
        components.second = @intCast(second);
        components.millisecond = @intCast(millisecond);
    }
};
