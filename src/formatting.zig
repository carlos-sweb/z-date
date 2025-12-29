const std = @import("std");
const constants = @import("constants.zig");
const timezone = @import("timezone.zig");
const calendar = @import("calendar.zig");
const errors = @import("errors.zig");

const Constants = constants.Constants;
const TimezoneMode = timezone.TimezoneMode;
const CalendarUtils = calendar.CalendarUtils;
const ZDateError = errors.ZDateError;
const Allocator = std.mem.Allocator;

/// Helper to format unsigned integer with zero padding
fn formatPadded(buf: []u8, value: u32, width: usize) ![]const u8 {
    var i = width;
    var v = value;
    while (i > 0) : (i -= 1) {
        buf[i - 1] = @intCast('0' + (v % 10));
        v /= 10;
    }
    return buf[0..width];
}

/// Formatting methods for date strings
pub const FormattingMethods = struct {
    /// Format to ISO 8601 string
    /// Labeled block example 1 from specification
    pub fn toISOString(timestamp: i64, allocator: Allocator) ![]u8 {
        iso_formatter: {
            // Validate timestamp
            if (timestamp == Constants.INVALID_TIME) {
                return ZDateError.InvalidDate;
            }

            if (timestamp < Constants.MIN_TIME or timestamp > Constants.MAX_TIME) {
                return ZDateError.OutOfRange;
            }

            break :iso_formatter;
        }

        // Convert to UTC components
        const components = CalendarUtils.timestampToComponents(timestamp, .utc);

        // Format: YYYY-MM-DDTHH:mm:ss.sssZ
        // Manual formatting to avoid Zig 0.15 sign prefix issues
        var buf: [30]u8 = undefined;
        var pos: usize = 0;

        // Year (4 digits)
        const year_abs: u32 = if (components.year < 0) @intCast(-components.year) else @intCast(components.year);
        var year_buf: [4]u8 = undefined;
        const year_str = try formatPadded(&year_buf, year_abs, 4);
        @memcpy(buf[pos..][0..4], year_str);
        pos += 4;

        buf[pos] = '-';
        pos += 1;

        // Month (2 digits)
        var month_buf: [2]u8 = undefined;
        const month_str = try formatPadded(&month_buf, @intCast(components.month + 1), 2);
        @memcpy(buf[pos..][0..2], month_str);
        pos += 2;

        buf[pos] = '-';
        pos += 1;

        // Day (2 digits)
        var day_buf: [2]u8 = undefined;
        const day_str = try formatPadded(&day_buf, @intCast(components.day), 2);
        @memcpy(buf[pos..][0..2], day_str);
        pos += 2;

        buf[pos] = 'T';
        pos += 1;

        // Hour (2 digits)
        var hour_buf: [2]u8 = undefined;
        const hour_str = try formatPadded(&hour_buf, @intCast(components.hour), 2);
        @memcpy(buf[pos..][0..2], hour_str);
        pos += 2;

        buf[pos] = ':';
        pos += 1;

        // Minute (2 digits)
        var minute_buf: [2]u8 = undefined;
        const minute_str = try formatPadded(&minute_buf, @intCast(components.minute), 2);
        @memcpy(buf[pos..][0..2], minute_str);
        pos += 2;

        buf[pos] = ':';
        pos += 1;

        // Second (2 digits)
        var second_buf: [2]u8 = undefined;
        const second_str = try formatPadded(&second_buf, @intCast(components.second), 2);
        @memcpy(buf[pos..][0..2], second_str);
        pos += 2;

        buf[pos] = '.';
        pos += 1;

        // Millisecond (3 digits)
        var ms_buf: [3]u8 = undefined;
        const ms_str = try formatPadded(&ms_buf, @intCast(components.millisecond), 3);
        @memcpy(buf[pos..][0..3], ms_str);
        pos += 3;

        buf[pos] = 'Z';
        pos += 1;

        return try allocator.dupe(u8, buf[0..pos]);
    }

    /// Format to date string
    /// Labeled block example 2 from specification
    pub fn toDateString(timestamp: i64, allocator: Allocator) ![]u8 {
        date_formatter: {
            if (timestamp == Constants.INVALID_TIME) {
                return try allocator.dupe(u8, "Invalid Date");
            }

            break :date_formatter;
        }

        // Format: "Day Mon DD YYYY"
        // Example: "Mon Jan 01 2024"
        const components = CalendarUtils.timestampToComponents(timestamp, .local);
        const day_of_week = CalendarUtils.getDayOfWeek(components.year, components.month, components.day);

        return try std.fmt.allocPrint(
            allocator,
            "{s} {s} {d:0>2} {d:0>4}",
            .{
                Constants.DAY_NAMES_SHORT[@intCast(day_of_week)],
                Constants.MONTH_NAMES_SHORT[@intCast(components.month)],
                components.day,
                components.year,
            },
        );
    }

    /// Format to time string
    pub fn toTimeString(timestamp: i64, allocator: Allocator) ![]u8 {
        if (timestamp == Constants.INVALID_TIME) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Format: "HH:MM:SS GMT+0000 (Timezone Name)"
        const components = CalendarUtils.timestampToComponents(timestamp, .local);

        return try std.fmt.allocPrint(
            allocator,
            "{d:0>2}:{d:0>2}:{d:0>2} GMT+0000",
            .{
                components.hour,
                components.minute,
                components.second,
            },
        );
    }

    /// Format to full string (date + time)
    pub fn toString(timestamp: i64, allocator: Allocator) ![]u8 {
        if (timestamp == Constants.INVALID_TIME) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Format: "Day Mon DD YYYY HH:MM:SS GMT+0000"
        const components = CalendarUtils.timestampToComponents(timestamp, .local);
        const day_of_week = CalendarUtils.getDayOfWeek(components.year, components.month, components.day);

        return try std.fmt.allocPrint(
            allocator,
            "{s} {s} {d:0>2} {d:0>4} {d:0>2}:{d:0>2}:{d:0>2} GMT+0000",
            .{
                Constants.DAY_NAMES_SHORT[@intCast(day_of_week)],
                Constants.MONTH_NAMES_SHORT[@intCast(components.month)],
                components.day,
                components.year,
                components.hour,
                components.minute,
                components.second,
            },
        );
    }

    /// Format to UTC string
    pub fn toUTCString(timestamp: i64, allocator: Allocator) ![]u8 {
        if (timestamp == Constants.INVALID_TIME) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Format: "Day, DD Mon YYYY HH:MM:SS GMT"
        // Example: "Mon, 01 Jan 2024 00:00:00 GMT"
        const components = CalendarUtils.timestampToComponents(timestamp, .utc);
        const day_of_week = CalendarUtils.getDayOfWeek(components.year, components.month, components.day);

        return try std.fmt.allocPrint(
            allocator,
            "{s}, {d:0>2} {s} {d:0>4} {d:0>2}:{d:0>2}:{d:0>2} GMT",
            .{
                Constants.DAY_NAMES_SHORT[@intCast(day_of_week)],
                components.day,
                Constants.MONTH_NAMES_SHORT[@intCast(components.month)],
                components.year,
                components.hour,
                components.minute,
                components.second,
            },
        );
    }

    /// Format to JSON string (same as ISO 8601)
    pub fn toJSON(timestamp: i64, allocator: Allocator) ![]u8 {
        return toISOString(timestamp, allocator);
    }

    /// Format to locale date string
    /// Simplified version - production would use actual locale data
    pub fn toLocaleDateString(timestamp: i64, allocator: Allocator, locale: ?[]const u8) ![]u8 {
        _ = locale; // Currently unused - would select format based on locale

        if (timestamp == Constants.INVALID_TIME) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Default to MM/DD/YYYY format
        const components = CalendarUtils.timestampToComponents(timestamp, .local);

        return try std.fmt.allocPrint(
            allocator,
            "{d:0>2}/{d:0>2}/{d:0>4}",
            .{
                components.month + 1, // 0-based to 1-based
                components.day,
                components.year,
            },
        );
    }

    /// Format to locale time string
    /// Simplified version - production would use actual locale data
    pub fn toLocaleTimeString(timestamp: i64, allocator: Allocator, locale: ?[]const u8) ![]u8 {
        _ = locale; // Currently unused

        if (timestamp == Constants.INVALID_TIME) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Default to HH:MM:SS format
        const components = CalendarUtils.timestampToComponents(timestamp, .local);

        return try std.fmt.allocPrint(
            allocator,
            "{d:0>2}:{d:0>2}:{d:0>2}",
            .{
                components.hour,
                components.minute,
                components.second,
            },
        );
    }

    /// Format to locale string (date + time)
    /// Simplified version - production would use actual locale data
    pub fn toLocaleString(timestamp: i64, allocator: Allocator, locale: ?[]const u8) ![]u8 {
        _ = locale; // Currently unused

        if (timestamp == Constants.INVALID_TIME) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Default to MM/DD/YYYY, HH:MM:SS format
        const components = CalendarUtils.timestampToComponents(timestamp, .local);

        return try std.fmt.allocPrint(
            allocator,
            "{d:0>2}/{d:0>2}/{d:0>4}, {d:0>2}:{d:0>2}:{d:0>2}",
            .{
                components.month + 1, // 0-based to 1-based
                components.day,
                components.year,
                components.hour,
                components.minute,
                components.second,
            },
        );
    }
};
