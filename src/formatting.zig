const std = @import("std");
const constants = @import("constants.zig");
const timezone = @import("timezone.zig");
const calendar = @import("calendar.zig");
const errors = @import("errors.zig");
const locale = @import("locale.zig");

const Constants = constants.Constants;
const TimezoneMode = timezone.TimezoneMode;
const CalendarUtils = calendar.CalendarUtils;
const ZDateError = errors.ZDateError;
const Allocator = std.mem.Allocator;
const Locale = locale.Locale;

/// Default locale used by toDateString/toString/toUTCString (day/month names)
/// and by the toLocale*String() methods when no explicit Locale is given.
const en_us: Locale = @import("locales/en_us.zig").locale;

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

/// Cast a date/time component known to be non-negative (day, 1-based month,
/// hour, minute, second) to u32 before handing it to a zero-padded `{d:0>N}`
/// placeholder. Zig's std.fmt prepends a spurious '+' to zero-width-padded
/// *signed* integers, which toISOString() avoids by building its buffer
/// manually; the other formatters below sidestep it by only ever formatting
/// unsigned values.
fn nn(v: i32) u32 {
    return @intCast(v);
}

/// Format a year as decimal digits, zero-padded to at least `min_width`, with
/// a leading '-' for negative years and no sign for non-negative ones (see `nn`).
fn formatYear(buf: []u8, year: i32, min_width: usize) []const u8 {
    const negative = year < 0;
    const abs_year: u32 = if (negative) @intCast(-@as(i64, year)) else @intCast(year);

    var digits_buf: [10]u8 = undefined;
    const digits = std.fmt.bufPrint(&digits_buf, "{d}", .{abs_year}) catch unreachable;

    var pos: usize = 0;
    if (negative) {
        buf[0] = '-';
        pos = 1;
    }
    if (digits.len < min_width) {
        const pad = min_width - digits.len;
        @memset(buf[pos..][0..pad], '0');
        pos += pad;
    }
    @memcpy(buf[pos..][0..digits.len], digits);
    pos += digits.len;
    return buf[0..pos];
}

/// Formatting methods for date strings
pub const FormattingMethods = struct {
    /// Format to ISO 8601 string
    ///
    /// Years within [0, 9999] use the standard 4-digit form ("YYYY-MM-DD...").
    /// Years outside that range use the expanded form with an explicit sign and
    /// 6 digits ("+YYYYYY-MM-DD..." / "-YYYYYY-MM-DD..."), per ECMA-262 §21.4.4.36.
    pub fn toISOString(timestamp: i64, allocator: Allocator) ![]u8 {
        // Validate timestamp
        if (timestamp == Constants.INVALID_TIME) {
            return ZDateError.InvalidDate;
        }

        if (timestamp < Constants.MIN_TIME or timestamp > Constants.MAX_TIME) {
            return ZDateError.OutOfRange;
        }

        // Convert to UTC components
        const components = CalendarUtils.timestampToComponents(timestamp, .utc);

        // Format: YYYY-MM-DDTHH:mm:ss.sssZ (or ±YYYYYY-MM-DDTHH:mm:ss.sssZ)
        var buf: [32]u8 = undefined;
        var pos: usize = 0;

        const extended_year = components.year < 0 or components.year > 9999;
        const year_abs: u32 = if (components.year < 0) @intCast(-components.year) else @intCast(components.year);

        if (extended_year) {
            buf[pos] = if (components.year < 0) '-' else '+';
            pos += 1;

            var year_buf: [6]u8 = undefined;
            const year_str = try formatPadded(&year_buf, year_abs, 6);
            @memcpy(buf[pos..][0..6], year_str);
            pos += 6;
        } else {
            var year_buf: [4]u8 = undefined;
            const year_str = try formatPadded(&year_buf, year_abs, 4);
            @memcpy(buf[pos..][0..4], year_str);
            pos += 4;
        }

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
    pub fn toDateString(timestamp: i64, allocator: Allocator) ![]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Format: "Day Mon DD YYYY"
        // Example: "Mon Jan 01 2024"
        const components = CalendarUtils.timestampToComponents(timestamp, .local);
        const day_of_week = CalendarUtils.getDayOfWeek(components.year, components.month, components.day);

        var year_buf: [11]u8 = undefined;
        const year_str = formatYear(&year_buf, components.year, 4);

        return try std.fmt.allocPrint(
            allocator,
            "{s} {s} {d:0>2} {s}",
            .{
                en_us.day_names_short[@intCast(day_of_week)],
                en_us.month_names_short[@intCast(components.month)],
                nn(components.day),
                year_str,
            },
        );
    }

    /// Format to time string
    pub fn toTimeString(timestamp: i64, allocator: Allocator) ![]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Format: "HH:MM:SS GMT+0000 (Timezone Name)"
        const components = CalendarUtils.timestampToComponents(timestamp, .local);

        return try std.fmt.allocPrint(
            allocator,
            "{d:0>2}:{d:0>2}:{d:0>2} GMT+0000",
            .{
                nn(components.hour),
                nn(components.minute),
                nn(components.second),
            },
        );
    }

    /// Format to full string (date + time)
    pub fn toString(timestamp: i64, allocator: Allocator) ![]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Format: "Day Mon DD YYYY HH:MM:SS GMT+0000"
        const components = CalendarUtils.timestampToComponents(timestamp, .local);
        const day_of_week = CalendarUtils.getDayOfWeek(components.year, components.month, components.day);

        var year_buf: [11]u8 = undefined;
        const year_str = formatYear(&year_buf, components.year, 4);

        return try std.fmt.allocPrint(
            allocator,
            "{s} {s} {d:0>2} {s} {d:0>2}:{d:0>2}:{d:0>2} GMT+0000",
            .{
                en_us.day_names_short[@intCast(day_of_week)],
                en_us.month_names_short[@intCast(components.month)],
                nn(components.day),
                year_str,
                nn(components.hour),
                nn(components.minute),
                nn(components.second),
            },
        );
    }

    /// Format to UTC string
    pub fn toUTCString(timestamp: i64, allocator: Allocator) ![]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        // Format: "Day, DD Mon YYYY HH:MM:SS GMT"
        // Example: "Mon, 01 Jan 2024 00:00:00 GMT"
        const components = CalendarUtils.timestampToComponents(timestamp, .utc);
        const day_of_week = CalendarUtils.getDayOfWeek(components.year, components.month, components.day);

        var year_buf: [11]u8 = undefined;
        const year_str = formatYear(&year_buf, components.year, 4);

        return try std.fmt.allocPrint(
            allocator,
            "{s}, {d:0>2} {s} {s} {d:0>2}:{d:0>2}:{d:0>2} GMT",
            .{
                en_us.day_names_short[@intCast(day_of_week)],
                nn(components.day),
                en_us.month_names_short[@intCast(components.month)],
                year_str,
                nn(components.hour),
                nn(components.minute),
                nn(components.second),
            },
        );
    }

    /// toGMTString(): legacy alias for toUTCString(). ECMA-262 specifies that
    /// Date.prototype.toGMTString is literally the same function object as
    /// Date.prototype.toUTCString; new code should prefer toUTCString().
    pub fn toGMTString(timestamp: i64, allocator: Allocator) ![]u8 {
        return toUTCString(timestamp, allocator);
    }

    /// Format to JSON string (same as ISO 8601). Per ECMA-262
    /// Date.prototype.toJSON, returns null (JSON `null`) for Invalid Date
    /// instead of erroring like toISOString does.
    pub fn toJSON(timestamp: i64, allocator: Allocator) !?[]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return null;
        }
        return try toISOString(timestamp, allocator);
    }

    /// Date rendering style for toLocaleDateString/toLocaleString, mirroring
    /// the numeric-vs-long distinction of Intl.DateTimeFormat's dateStyle.
    pub const DateStyle = enum { numeric, long };

    /// Render a long-style date from the locale's pattern (see
    /// Locale.long_date_format for the token grammar).
    fn formatLongDate(allocator: Allocator, l: Locale, components: anytype) ![]u8 {
        const pattern = if (l.long_date_format.len > 0)
            l.long_date_format
        else switch (l.date_order) {
            .dmy => "D MMMM YYYY",
            .mdy => "MMMM D, YYYY",
            .ymd => "YYYY MMMM D",
        };

        var out: std.ArrayList(u8) = .empty;
        defer out.deinit(allocator);

        var i: usize = 0;
        while (i < pattern.len) {
            if (std.mem.startsWith(u8, pattern[i..], "YYYY")) {
                var year_buf: [11]u8 = undefined;
                try out.appendSlice(allocator, formatYear(&year_buf, components.year, 1));
                i += 4;
            } else if (std.mem.startsWith(u8, pattern[i..], "MMMM")) {
                try out.appendSlice(allocator, l.month_names[@intCast(components.month)]);
                i += 4;
            } else if (std.mem.startsWith(u8, pattern[i..], "MMM")) {
                try out.appendSlice(allocator, l.month_names_short[@intCast(components.month)]);
                i += 3;
            } else if (std.mem.startsWith(u8, pattern[i..], "MM")) {
                try out.print(allocator, "{d:0>2}", .{nn(components.month + 1)});
                i += 2;
            } else if (pattern[i] == 'M') {
                try out.print(allocator, "{d}", .{nn(components.month + 1)});
                i += 1;
            } else if (std.mem.startsWith(u8, pattern[i..], "DD")) {
                try out.print(allocator, "{d:0>2}", .{nn(components.day)});
                i += 2;
            } else if (pattern[i] == 'D') {
                try out.print(allocator, "{d}", .{nn(components.day)});
                i += 1;
            } else {
                try out.append(allocator, pattern[i]);
                i += 1;
            }
        }

        return out.toOwnedSlice(allocator);
    }

    /// toLocaleDateString with an explicit style (.numeric matches
    /// toLocaleDateString exactly; .long uses the locale's long pattern with
    /// full month names).
    pub fn toLocaleDateStringStyle(timestamp: i64, allocator: Allocator, loc: ?Locale, style: DateStyle) ![]u8 {
        if (style == .numeric) return toLocaleDateString(timestamp, allocator, loc);

        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        const l = loc orelse en_us;
        const components = CalendarUtils.timestampToComponents(timestamp, .local);
        return formatLongDate(allocator, l, components);
    }

    /// toLocaleString with an explicit date style; the time part is always
    /// rendered per the locale's clock settings.
    pub fn toLocaleStringStyle(timestamp: i64, allocator: Allocator, loc: ?Locale, style: DateStyle) ![]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        const date_str = try toLocaleDateStringStyle(timestamp, allocator, loc, style);
        defer allocator.free(date_str);
        const time_str = try toLocaleTimeString(timestamp, allocator, loc);
        defer allocator.free(time_str);

        return try std.fmt.allocPrint(allocator, "{s}, {s}", .{ date_str, time_str });
    }

    /// Format to locale date string, honoring the locale's date_order and date_separator.
    /// A null locale defaults to en-US (MM/DD/YYYY).
    pub fn toLocaleDateString(timestamp: i64, allocator: Allocator, loc: ?Locale) ![]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        const l = loc orelse en_us;
        const components = CalendarUtils.timestampToComponents(timestamp, .local);
        const sep = l.date_separator;
        const month = nn(components.month + 1); // 0-based to 1-based
        const day = nn(components.day);

        var year_buf: [11]u8 = undefined;
        const year_str = formatYear(&year_buf, components.year, 4);

        return switch (l.date_order) {
            .mdy => try std.fmt.allocPrint(allocator, "{d:0>2}{c}{d:0>2}{c}{s}", .{ month, sep, day, sep, year_str }),
            .dmy => try std.fmt.allocPrint(allocator, "{d:0>2}{c}{d:0>2}{c}{s}", .{ day, sep, month, sep, year_str }),
            .ymd => try std.fmt.allocPrint(allocator, "{s}{c}{d:0>2}{c}{d:0>2}", .{ year_str, sep, month, sep, day }),
        };
    }

    /// Format to locale time string, honoring the locale's time_24h/am_label/pm_label.
    /// A null locale defaults to en-US (12-hour clock with AM/PM).
    pub fn toLocaleTimeString(timestamp: i64, allocator: Allocator, loc: ?Locale) ![]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        const l = loc orelse en_us;
        const components = CalendarUtils.timestampToComponents(timestamp, .local);

        const sep = l.time_separator;
        if (l.time_24h) {
            return try std.fmt.allocPrint(
                allocator,
                "{d:0>2}{c}{d:0>2}{c}{d:0>2}",
                .{ nn(components.hour), sep, nn(components.minute), sep, nn(components.second) },
            );
        }

        var hour12 = @mod(components.hour, 12);
        if (hour12 == 0) hour12 = 12;
        const meridiem = if (components.hour < 12) l.am_label else l.pm_label;

        return try std.fmt.allocPrint(
            allocator,
            "{d:0>2}{c}{d:0>2}{c}{d:0>2} {s}",
            .{ nn(hour12), sep, nn(components.minute), sep, nn(components.second), meridiem },
        );
    }

    /// Format to locale string (date + time). A null locale defaults to en-US.
    pub fn toLocaleString(timestamp: i64, allocator: Allocator, loc: ?Locale) ![]u8 {
        if (CalendarUtils.isInvalidTimestamp(timestamp)) {
            return try allocator.dupe(u8, "Invalid Date");
        }

        const date_str = try toLocaleDateString(timestamp, allocator, loc);
        defer allocator.free(date_str);
        const time_str = try toLocaleTimeString(timestamp, allocator, loc);
        defer allocator.free(time_str);

        return try std.fmt.allocPrint(allocator, "{s}, {s}", .{ date_str, time_str });
    }
};
