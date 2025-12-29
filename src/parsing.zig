const std = @import("std");
const constants = @import("constants.zig");
const calendar = @import("calendar.zig");
const errors = @import("errors.zig");

const Constants = constants.Constants;
const CalendarUtils = calendar.CalendarUtils;
const DateComponents = calendar.DateComponents;
const ZDateError = errors.ZDateError;

/// Parsing methods for date strings
pub const ParsingMethods = struct {
    /// Parse ISO 8601 string
    /// Labeled block example 3 from specification
    /// Supports formats:
    /// - YYYY-MM-DDTHH:mm:ss.sssZ
    /// - YYYY-MM-DDTHH:mm:ssZ
    /// - YYYY-MM-DD
    /// - YYYY-MM
    /// - YYYY
    pub fn parseISO8601(str: []const u8) !i64 {
        iso_parser: {
            const trimmed = std.mem.trim(u8, str, &std.ascii.whitespace);

            if (trimmed.len == 0) {
                return Constants.INVALID_TIME;
            }

            // Check format: YYYY-MM-DDTHH:mm:ss.sssZ
            // Minimum length check
            if (trimmed.len < 4) { // At least "YYYY"
                return ZDateError.InvalidFormat;
            }

            break :iso_parser;
        }

        const trimmed = std.mem.trim(u8, str, &std.ascii.whitespace);

        // Parse year (required)
        if (trimmed.len < 4) return ZDateError.InvalidFormat;
        const year = try std.fmt.parseInt(i32, trimmed[0..4], 10);

        var components = DateComponents{
            .year = year,
            .month = 0,
            .day = 1,
            .hour = 0,
            .minute = 0,
            .second = 0,
            .millisecond = 0,
        };

        // Check if there's more (month)
        if (trimmed.len >= 7 and trimmed[4] == '-') {
            const month = try std.fmt.parseInt(i32, trimmed[5..7], 10);
            components.month = month - 1; // Convert to 0-based

            // Check if there's more (day)
            if (trimmed.len >= 10 and trimmed[7] == '-') {
                const day = try std.fmt.parseInt(i32, trimmed[8..10], 10);
                components.day = day;

                // Check if there's time component
                if (trimmed.len >= 11 and trimmed[10] == 'T') {
                    // Parse hour
                    if (trimmed.len >= 13) {
                        const hour = try std.fmt.parseInt(i32, trimmed[11..13], 10);
                        components.hour = hour;
                    }

                    // Parse minute
                    if (trimmed.len >= 16 and trimmed[13] == ':') {
                        const minute = try std.fmt.parseInt(i32, trimmed[14..16], 10);
                        components.minute = minute;
                    }

                    // Parse second
                    if (trimmed.len >= 19 and trimmed[16] == ':') {
                        const second = try std.fmt.parseInt(i32, trimmed[17..19], 10);
                        components.second = second;
                    }

                    // Parse milliseconds
                    if (trimmed.len >= 23 and trimmed[19] == '.') {
                        const ms = try std.fmt.parseInt(i32, trimmed[20..23], 10);
                        components.millisecond = ms;
                    }
                }
            }
        }

        // Validate components
        if (!CalendarUtils.validateComponents(components)) {
            return ZDateError.InvalidComponent;
        }

        // Convert to timestamp (ISO 8601 is always UTC)
        const timestamp = CalendarUtils.componentsToTimestamp(components, .utc);

        // Validate range
        if (timestamp < Constants.MIN_TIME or timestamp > Constants.MAX_TIME) {
            return ZDateError.OutOfRange;
        }

        return timestamp;
    }

    /// Parse various date string formats
    /// Labeled block example 4 from specification
    pub fn parse(str: []const u8) i64 {
        date_parser: {
            // Try ISO 8601 first
            if (parseISO8601(str)) |timestamp| {
                return timestamp;
            } else |_| {}

            // Try other common formats
            // Format: "Mon Jan 01 2024"
            if (parseDateString(str)) |timestamp| {
                return timestamp;
            } else |_| {}

            // Format: "01/01/2024" or "1/1/2024"
            if (parseSlashFormat(str)) |timestamp| {
                return timestamp;
            } else |_| {}

            break :date_parser;
        }

        // Return invalid if all parsing attempts fail
        return Constants.INVALID_TIME;
    }

    /// Parse date string format: "Mon Jan 01 2024"
    fn parseDateString(str: []const u8) !i64 {
        const trimmed = std.mem.trim(u8, str, &std.ascii.whitespace);

        // Split by whitespace
        var iter = std.mem.splitScalar(u8, trimmed, ' ');

        // Skip day name
        _ = iter.next() orelse return ZDateError.InvalidFormat;

        // Get month name
        const month_str = iter.next() orelse return ZDateError.InvalidFormat;
        const month = parseMonthName(month_str) orelse return ZDateError.InvalidFormat;

        // Get day
        const day_str = iter.next() orelse return ZDateError.InvalidFormat;
        const day = try std.fmt.parseInt(i32, day_str, 10);

        // Get year
        const year_str = iter.next() orelse return ZDateError.InvalidFormat;
        const year = try std.fmt.parseInt(i32, year_str, 10);

        const components = DateComponents{
            .year = year,
            .month = month,
            .day = day,
            .hour = 0,
            .minute = 0,
            .second = 0,
            .millisecond = 0,
        };

        if (!CalendarUtils.validateComponents(components)) {
            return ZDateError.InvalidComponent;
        }

        return CalendarUtils.componentsToTimestamp(components, .utc);
    }

    /// Parse slash format: "MM/DD/YYYY"
    fn parseSlashFormat(str: []const u8) !i64 {
        const trimmed = std.mem.trim(u8, str, &std.ascii.whitespace);

        // Split by slash
        var iter = std.mem.splitScalar(u8, trimmed, '/');

        // Get month
        const month_str = iter.next() orelse return ZDateError.InvalidFormat;
        const month = try std.fmt.parseInt(i32, month_str, 10);

        // Get day
        const day_str = iter.next() orelse return ZDateError.InvalidFormat;
        const day = try std.fmt.parseInt(i32, day_str, 10);

        // Get year
        const year_str = iter.next() orelse return ZDateError.InvalidFormat;
        const year = try std.fmt.parseInt(i32, year_str, 10);

        const components = DateComponents{
            .year = year,
            .month = month - 1, // Convert to 0-based
            .day = day,
            .hour = 0,
            .minute = 0,
            .second = 0,
            .millisecond = 0,
        };

        if (!CalendarUtils.validateComponents(components)) {
            return ZDateError.InvalidComponent;
        }

        return CalendarUtils.componentsToTimestamp(components, .utc);
    }

    /// Parse month name to month number (0-11)
    fn parseMonthName(name: []const u8) ?i32 {
        const month_names = [_][]const u8{
            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
        };

        for (month_names, 0..) |month_name, i| {
            if (std.ascii.eqlIgnoreCase(name, month_name)) {
                return @intCast(i);
            }
        }

        return null;
    }
};
