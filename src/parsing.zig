const std = @import("std");
const constants = @import("constants.zig");
const calendar = @import("calendar.zig");
const errors = @import("errors.zig");

const Constants = constants.Constants;
const CalendarUtils = calendar.CalendarUtils;
const DateComponents = calendar.DateComponents;
const ZDateError = errors.ZDateError;
const en_us_locale = @import("locales/en_us.zig").locale;

/// Read exactly `n` decimal digits starting at `pos.*`, advancing `pos.*` past them.
/// Fails if fewer than `n` digits remain or a non-digit is encountered.
fn readNDigits(str: []const u8, pos: *usize, n: usize) !u32 {
    if (pos.* + n > str.len) return ZDateError.InvalidFormat;
    var value: u32 = 0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const c = str[pos.* + i];
        if (c < '0' or c > '9') return ZDateError.InvalidFormat;
        value = value * 10 + (c - '0');
    }
    pos.* += n;
    return value;
}

/// Parsing methods for date strings
pub const ParsingMethods = struct {
    /// Parse ISO 8601 / ECMA-262 Date Time String Format (§21.4.3.2)
    ///
    /// Grammar supported:
    ///   Date       := Year | Year-Month | Year-Month-Day
    ///   Year       := DDDD | ('+'|'-') DDDDDD (extended year)
    ///   Time       := 'T' HH:mm | 'T' HH:mm:ss | 'T' HH:mm:ss.sss
    ///   TimeZone   := 'Z' | ('+'|'-') HH:mm
    ///
    /// The entire (trimmed) input must be consumed; trailing garbage is a format error.
    /// Date-only forms are interpreted as UTC; date-time forms without an explicit
    /// offset are interpreted as local time (per spec).
    pub fn parseISO8601(str: []const u8) !i64 {
        const trimmed = std.mem.trim(u8, str, &std.ascii.whitespace);
        if (trimmed.len == 0) return ZDateError.InvalidFormat;

        var pos: usize = 0;

        // ----- Year -----
        var year: i32 = undefined;
        if (trimmed[0] == '+' or trimmed[0] == '-') {
            const negative = trimmed[0] == '-';
            pos += 1;
            const digits = try readNDigits(trimmed, &pos, 6);
            if (negative and digits == 0) return ZDateError.InvalidFormat; // "-000000" is invalid
            year = if (negative) -@as(i32, @intCast(digits)) else @as(i32, @intCast(digits));
        } else {
            const digits = try readNDigits(trimmed, &pos, 4);
            year = @as(i32, @intCast(digits));
        }

        // ----- Month / Day (optional) -----
        var month: i32 = 0;
        var day: i32 = 1;

        if (pos < trimmed.len and trimmed[pos] == '-') {
            pos += 1;
            const m = try readNDigits(trimmed, &pos, 2);
            if (m < 1 or m > 12) return ZDateError.InvalidComponent;
            month = @as(i32, @intCast(m)) - 1;

            if (pos < trimmed.len and trimmed[pos] == '-') {
                pos += 1;
                const d = try readNDigits(trimmed, &pos, 2);
                const max_days = CalendarUtils.getDaysInMonth(year, month);
                if (d < 1 or @as(i32, @intCast(d)) > max_days) return ZDateError.InvalidComponent;
                day = @as(i32, @intCast(d));
            }
        }

        // ----- Time (optional) -----
        var hour: i32 = 0;
        var minute: i32 = 0;
        var second: i32 = 0;
        var millisecond: i32 = 0;
        var has_time = false;
        var has_offset = false;
        var offset_minutes: i32 = 0;

        if (pos < trimmed.len and trimmed[pos] == 'T') {
            has_time = true;
            pos += 1;

            const h = try readNDigits(trimmed, &pos, 2);

            if (pos >= trimmed.len or trimmed[pos] != ':') return ZDateError.InvalidFormat;
            pos += 1;
            const mi = try readNDigits(trimmed, &pos, 2);
            if (mi > 59) return ZDateError.InvalidComponent;

            var s: u32 = 0;
            var ms: u32 = 0;
            if (pos < trimmed.len and trimmed[pos] == ':') {
                pos += 1;
                s = try readNDigits(trimmed, &pos, 2);
                if (s > 59) return ZDateError.InvalidComponent;

                if (pos < trimmed.len and trimmed[pos] == '.') {
                    pos += 1;
                    ms = try readNDigits(trimmed, &pos, 3);
                }
            }

            // Hour is 0-24; 24 is only valid as 24:00:00.000
            if (h > 24) return ZDateError.InvalidComponent;
            if (h == 24 and (mi != 0 or s != 0 or ms != 0)) return ZDateError.InvalidComponent;

            hour = @as(i32, @intCast(h));
            minute = @as(i32, @intCast(mi));
            second = @as(i32, @intCast(s));
            millisecond = @as(i32, @intCast(ms));

            // ----- TimeZone offset (optional) -----
            if (pos < trimmed.len) {
                if (trimmed[pos] == 'Z') {
                    pos += 1;
                    has_offset = true;
                } else if (trimmed[pos] == '+' or trimmed[pos] == '-') {
                    const negative = trimmed[pos] == '-';
                    pos += 1;
                    const oh = try readNDigits(trimmed, &pos, 2);
                    if (pos >= trimmed.len or trimmed[pos] != ':') return ZDateError.InvalidFormat;
                    pos += 1;
                    const om = try readNDigits(trimmed, &pos, 2);
                    if (oh > 23 or om > 59) return ZDateError.InvalidComponent;

                    const total: i32 = @as(i32, @intCast(oh)) * 60 + @as(i32, @intCast(om));
                    offset_minutes = if (negative) -total else total;
                    has_offset = true;
                }
            }
        }

        // The whole (trimmed) string must be consumed - no trailing garbage allowed.
        if (pos != trimmed.len) return ZDateError.InvalidFormat;

        const components = DateComponents{
            .year = year,
            .month = month,
            .day = day,
            .hour = hour,
            .minute = minute,
            .second = second,
            .millisecond = millisecond,
        };

        // Date-only forms are UTC. Date-time forms without an offset are local time;
        // with an explicit offset (Z or ±HH:mm), the offset is applied on top of UTC.
        var timestamp: i64 = undefined;
        if (!has_time) {
            timestamp = CalendarUtils.componentsToTimestamp(components, .utc);
        } else if (has_offset) {
            timestamp = CalendarUtils.componentsToTimestamp(components, .utc) - @as(i64, offset_minutes) * Constants.MS_PER_MINUTE;
        } else {
            timestamp = CalendarUtils.componentsToTimestamp(components, .local);
        }

        // Validate range
        if (timestamp < Constants.MIN_TIME or timestamp > Constants.MAX_TIME) {
            return ZDateError.OutOfRange;
        }

        return timestamp;
    }

    /// Parse various date string formats
    pub fn parse(str: []const u8) i64 {
        // Try ISO 8601 first
        if (parseISO8601(str)) |timestamp| {
            return timestamp;
        } else |_| {}

        // ISO with a space instead of 'T' ("2024-01-15 10:30:00"), a legacy
        // form V8 accepts with local-time semantics.
        if (parseIsoWithSpace(str)) |timestamp| {
            return timestamp;
        } else |_| {}

        // Try other common formats
        // Format: "Mon Jan 01 2024"
        if (parseDateString(str)) |timestamp| {
            return timestamp;
        } else |_| {}

        // Format: "01/01/2024", "1/1/2024" or "2024/01/15"
        if (parseSlashFormat(str)) |timestamp| {
            return timestamp;
        } else |_| {}

        // Return invalid if all parsing attempts fail
        return Constants.INVALID_TIME;
    }

    /// "YYYY-MM-DD HH:mm[:ss]" - rewritten to the ISO 'T' form and delegated
    /// to the strict ISO parser (which gives date-time-without-offset the
    /// local-time semantics V8 uses for this form).
    fn parseIsoWithSpace(str: []const u8) !i64 {
        const trimmed = std.mem.trim(u8, str, &std.ascii.whitespace);
        if (trimmed.len > 63) return ZDateError.InvalidFormat;

        const space_idx = std.mem.indexOfScalar(u8, trimmed, ' ') orelse return ZDateError.InvalidFormat;
        // Only rewrite when what precedes the space looks like an ISO date,
        // so month-name forms fall through to parseDateString.
        if (space_idx < 4 or !std.ascii.isDigit(trimmed[0])) return ZDateError.InvalidFormat;

        var buf: [64]u8 = undefined;
        @memcpy(buf[0..trimmed.len], trimmed);
        buf[space_idx] = 'T';
        return parseISO8601(buf[0..trimmed.len]);
    }

    /// Parse a signed ±HHMM offset (exactly 5 characters, e.g. "+0000",
    /// "-0500") into signed minutes.
    fn parseOffsetHHMM(s: []const u8) !i32 {
        if (s.len != 5 or (s[0] != '+' and s[0] != '-')) return ZDateError.InvalidFormat;
        const oh = try std.fmt.parseInt(i32, s[1..3], 10);
        const om = try std.fmt.parseInt(i32, s[3..5], 10);
        const total = oh * 60 + om;
        return if (s[0] == '-') -total else total;
    }

    /// True if `s` is non-empty and consists entirely of ASCII digits.
    fn isPlainInteger(s: []const u8) bool {
        if (s.len == 0) return false;
        for (s) |c| {
            if (c < '0' or c > '9') return false;
        }
        return true;
    }

    /// Parse a "human-readable" date string. Supports, with or without a
    /// leading day-of-week name (optionally comma-terminated):
    ///   - "Www Mon DD YYYY [HH:mm[:ss] [GMT±HHMM]]"  (toString/toDateString)
    ///   - "Www, DD Mon YYYY HH:mm:ss GMT"             (toUTCString)
    ///   - "Mon DD[,] YYYY [...]"                      (e.g. "January 1, 2024")
    ///   - "DD Mon YYYY [...]"                         (e.g. "1 January 2024")
    /// plus, after the time, an optional "AM"/"PM" token, then either
    /// "GMT"/"UTC"/"GMT±HHMM" or a bare RFC 2822-style "±HHMM" offset, then
    /// an optional parenthesized zone name ("(Coordinated Universal Time)"),
    /// which is ignored - matching V8's legacy grammar.
    ///
    /// Forms without an explicit offset are local time (as in V8); forms
    /// with GMT/UTC/±HHMM are absolute.
    fn parseDateString(str: []const u8) !i64 {
        const trimmed = std.mem.trim(u8, str, &std.ascii.whitespace);

        var token_buf: [12][]const u8 = undefined;
        var token_count: usize = 0;
        var iter = std.mem.tokenizeAny(u8, trimmed, " \t");
        while (iter.next()) |tok| {
            if (token_count >= token_buf.len) return ZDateError.InvalidFormat;
            token_buf[token_count] = tok;
            token_count += 1;
        }
        const tokens = token_buf[0..token_count];
        if (tokens.len < 3) return ZDateError.InvalidFormat;

        var month: i32 = undefined;
        var day: i32 = undefined;
        var idx: usize = undefined;

        if (parseMonthName(tokens[0])) |m| {
            // "Month DD[,] YYYY" - no day-of-week (e.g. "January 1, 2024")
            month = m;
            day = try std.fmt.parseInt(i32, std.mem.trimEnd(u8, tokens[1], ","), 10);
            idx = 2;
        } else if (isPlainInteger(tokens[0]) and parseMonthName(tokens[1]) != null) {
            // "DD Month YYYY" - no day-of-week (e.g. "1 January 2024")
            day = try std.fmt.parseInt(i32, tokens[0], 10);
            month = parseMonthName(tokens[1]).?;
            idx = 2;
        } else {
            // Leading day-of-week name (optionally comma-terminated) to skip.
            if (tokens.len < 4) return ZDateError.InvalidFormat;
            if (parseMonthName(tokens[1])) |m| {
                // "Www Mon DD YYYY" (toString/toDateString order)
                month = m;
                day = try std.fmt.parseInt(i32, tokens[2], 10);
            } else if (parseMonthName(tokens[2])) |m| {
                // "Www, DD Mon YYYY" (toUTCString order)
                day = try std.fmt.parseInt(i32, std.mem.trimEnd(u8, tokens[1], ","), 10);
                month = m;
            } else {
                return ZDateError.InvalidFormat;
            }
            idx = 3;
        }

        if (idx >= tokens.len) return ZDateError.InvalidFormat;
        const year = try std.fmt.parseInt(i32, tokens[idx], 10);
        idx += 1;

        var hour: i32 = 0;
        var minute: i32 = 0;
        var second: i32 = 0;
        var offset_minutes: i32 = 0;
        var has_offset = false;

        if (idx < tokens.len and tokens[idx][0] != '(') {
            const time_str = tokens[idx];
            idx += 1;

            var time_iter = std.mem.splitScalar(u8, time_str, ':');
            const h_str = time_iter.next() orelse return ZDateError.InvalidFormat;
            const mi_str = time_iter.next() orelse return ZDateError.InvalidFormat;
            hour = try std.fmt.parseInt(i32, h_str, 10);
            minute = try std.fmt.parseInt(i32, mi_str, 10);
            // Seconds are optional ("10:30" is valid in the legacy grammar).
            if (time_iter.next()) |s_str| {
                second = try std.fmt.parseInt(i32, s_str, 10);
            }
            if (time_iter.next() != null) return ZDateError.InvalidFormat;

            // Optional AM/PM token (12 AM -> 00, 12 PM -> 12, else PM adds 12).
            if (idx < tokens.len) {
                const tok = tokens[idx];
                if (std.ascii.eqlIgnoreCase(tok, "AM")) {
                    if (hour < 1 or hour > 12) return ZDateError.InvalidComponent;
                    if (hour == 12) hour = 0;
                    idx += 1;
                } else if (std.ascii.eqlIgnoreCase(tok, "PM")) {
                    if (hour < 1 or hour > 12) return ZDateError.InvalidComponent;
                    if (hour != 12) hour += 12;
                    idx += 1;
                }
            }

            // Optional timezone token.
            if (idx < tokens.len and tokens[idx][0] != '(') {
                const offset_str = tokens[idx];
                idx += 1;

                if (std.mem.eql(u8, offset_str, "GMT") or std.mem.eql(u8, offset_str, "UTC")) {
                    // Bare "GMT"/"UTC" with no explicit offset: zero offset.
                } else if (std.mem.startsWith(u8, offset_str, "GMT")) {
                    const rest = offset_str[3..];
                    if (rest.len > 0) {
                        offset_minutes = try parseOffsetHHMM(rest);
                    }
                } else {
                    // Bare RFC 2822/1123-style offset, e.g. "+0000" or "-0500".
                    offset_minutes = try parseOffsetHHMM(offset_str);
                }
                has_offset = true;
            }
        }

        // Optional trailing parenthesized zone name, e.g.
        // "(Coordinated Universal Time)" - may span several tokens; ignored.
        if (idx < tokens.len and tokens[idx][0] == '(') {
            while (idx < tokens.len) {
                const tok = tokens[idx];
                idx += 1;
                if (tok[tok.len - 1] == ')') break;
            } else return ZDateError.InvalidFormat;
        }

        if (idx != tokens.len) return ZDateError.InvalidFormat;

        const components = DateComponents{
            .year = year,
            .month = month,
            .day = day,
            .hour = hour,
            .minute = minute,
            .second = second,
            .millisecond = 0,
        };

        if (!CalendarUtils.validateComponents(components)) {
            return ZDateError.InvalidComponent;
        }

        if (has_offset) {
            const timestamp = CalendarUtils.componentsToTimestamp(components, .utc);
            return timestamp - @as(i64, offset_minutes) * Constants.MS_PER_MINUTE;
        }
        // No explicit offset: legacy forms are local time, per V8.
        return CalendarUtils.componentsToTimestamp(components, .local);
    }

    /// Parse slash formats: "MM/DD/YYYY" (US order) or "YYYY/MM/DD" (when
    /// the first component has 3+ digits). Local-time semantics, per V8.
    fn parseSlashFormat(str: []const u8) !i64 {
        const trimmed = std.mem.trim(u8, str, &std.ascii.whitespace);

        // Split by slash
        var iter = std.mem.splitScalar(u8, trimmed, '/');

        const first_str = iter.next() orelse return ZDateError.InvalidFormat;
        const second_str = iter.next() orelse return ZDateError.InvalidFormat;
        const third_str = iter.next() orelse return ZDateError.InvalidFormat;
        if (iter.next() != null) return ZDateError.InvalidFormat;

        const first = try std.fmt.parseInt(i32, first_str, 10);
        const second = try std.fmt.parseInt(i32, second_str, 10);
        const third = try std.fmt.parseInt(i32, third_str, 10);

        var year: i32 = undefined;
        var month: i32 = undefined;
        var day: i32 = undefined;
        if (first_str.len >= 3) {
            // "2024/01/15": year first.
            year = first;
            month = second;
            day = third;
        } else {
            // "01/15/2024": US month-first order.
            month = first;
            day = second;
            year = third;
        }

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

        return CalendarUtils.componentsToTimestamp(components, .local);
    }

    /// Parse a month name (0-11), accepting either the abbreviated ("Jan") or
    /// full ("January") English form, case-insensitively.
    fn parseMonthName(name: []const u8) ?i32 {
        for (en_us_locale.month_names_short, 0..) |short, i| {
            if (std.ascii.eqlIgnoreCase(name, short)) {
                return @intCast(i);
            }
        }
        for (en_us_locale.month_names, 0..) |full, i| {
            if (std.ascii.eqlIgnoreCase(name, full)) {
                return @intCast(i);
            }
        }

        return null;
    }
};
