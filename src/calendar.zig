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
    /// Check if year is leap year
    /// Labeled block example 9 from specification
    pub fn isLeapYear(year: i32) bool {
        leap_checker: {
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

            break :leap_checker;
        }

        return true;
    }

    /// Get days in month
    /// Labeled block example 10 from specification
    pub fn getDaysInMonth(year: i32, month: i32) i32 {
        var days: i32 = undefined;

        days_calculator: {
            // Validate month
            if (month < 0 or month > 11) {
                return 0;
            }

            days = Constants.DAYS_IN_MONTH[@intCast(month)];

            // February in leap year
            if (month == 1 and isLeapYear(year)) {
                days = 29;
            }

            break :days_calculator;
        }

        return days;
    }

    /// Get day of week (0-6, Sunday=0) using Zeller's congruence
    pub fn getDayOfWeek(year: i32, month: i32, day: i32) i32 {
        // Adjust month and year for Zeller's congruence
        // (January and February are counted as months 13 and 14 of previous year)
        var adj_month = month + 1; // Convert from 0-based to 1-based
        var adj_year = year;

        if (adj_month <= 2) {
            adj_month += 12;
            adj_year -= 1;
        }

        const q = day;
        const m = adj_month;
        const k = @mod(adj_year, 100);
        const j = @divTrunc(adj_year, 100);

        // Zeller's congruence formula
        const h = @mod(q + @divTrunc(13 * (m + 1), 5) + k + @divTrunc(k, 4) + @divTrunc(j, 4) - 2 * j, 7);

        // Convert to Sunday=0 format (Zeller gives Saturday=0)
        return @mod(h + 6, 7);
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
        var timestamp: i64 = days * Constants.MS_PER_DAY;
        timestamp += @as(i64, components.hour) * Constants.MS_PER_HOUR;
        timestamp += @as(i64, components.minute) * Constants.MS_PER_MINUTE;
        timestamp += @as(i64, components.second) * Constants.MS_PER_SECOND;
        timestamp += @as(i64, components.millisecond);

        // Remove timezone offset if in local mode
        return TimezoneUtils.removeTimezoneOffset(timestamp, mode);
    }

    /// Calculate days since epoch for a given year's January 1
    fn yearToEpochDay(year: i32) i64 {
        const y = year - 1970;

        // Count leap years between 1970 and year
        var leap_years: i64 = 0;

        if (y >= 0) {
            // Years since 1970
            const years_since = @as(i64, y);
            // Count leap years: every 4 years, except centuries, except every 400 years

            // Leap years from 1970 to year-1
            leap_years = @divFloor(years_since + 1, 4) - @divFloor(years_since + 69, 100) + @divFloor(years_since + 369, 400);
        } else {
            // Years before 1970
            const years_before = @as(i64, -y);
            leap_years = -(@divFloor(years_before + 2, 4) - @divFloor(years_before + 30, 100) + @divFloor(years_before + 30, 400));
        }

        const total_days = @as(i64, y) * 365 + leap_years;
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
    pub fn normalizeComponents(components: *DateComponents) void {
        // Normalize milliseconds
        if (components.millisecond >= 1000 or components.millisecond < 0) {
            const extra_seconds = @divFloor(components.millisecond, 1000);
            components.second += extra_seconds;
            components.millisecond -= extra_seconds * 1000;
        }

        // Normalize seconds
        if (components.second >= 60 or components.second < 0) {
            const extra_minutes = @divFloor(components.second, 60);
            components.minute += extra_minutes;
            components.second -= extra_minutes * 60;
        }

        // Normalize minutes
        if (components.minute >= 60 or components.minute < 0) {
            const extra_hours = @divFloor(components.minute, 60);
            components.hour += extra_hours;
            components.minute -= extra_hours * 60;
        }

        // Normalize hours
        if (components.hour >= 24 or components.hour < 0) {
            const extra_days = @divFloor(components.hour, 24);
            components.day += extra_days;
            components.hour -= extra_days * 24;
        }

        // Normalize days and months (more complex due to variable month lengths)
        while (components.day < 1) {
            components.month -= 1;
            if (components.month < 0) {
                components.month = 11;
                components.year -= 1;
            }
            components.day += getDaysInMonth(components.year, components.month);
        }

        while (true) {
            const max_days = getDaysInMonth(components.year, components.month);
            if (components.day <= max_days) {
                break;
            }
            components.day -= max_days;
            components.month += 1;
            if (components.month > 11) {
                components.month = 0;
                components.year += 1;
            }
        }
    }
};
