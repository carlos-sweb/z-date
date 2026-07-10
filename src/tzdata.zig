const std = @import("std");
const builtin = @import("builtin");
const constants = @import("constants.zig");
const calendar = @import("calendar.zig");
const windows_zones = @import("windows_zones.zig");
const zones = @import("zones.zig");

const Constants = constants.Constants;
const CalendarUtils = calendar.CalendarUtils;
const Allocator = std.mem.Allocator;

// ===== Windows system-timezone detection =====
// GetDynamicTimeZoneInformation is not declared in Zig's std; declared here.
// Only referenced inside comptime-pruned `builtin.os.tag == .windows`
// branches, so it never affects non-Windows builds.

const WinSystemTime = extern struct {
    wYear: u16,
    wMonth: u16,
    wDayOfWeek: u16,
    wDay: u16,
    wHour: u16,
    wMinute: u16,
    wSecond: u16,
    wMilliseconds: u16,
};

const DynamicTimeZoneInformation = extern struct {
    Bias: i32,
    StandardName: [32]u16,
    StandardDate: WinSystemTime,
    StandardBias: i32,
    DaylightName: [32]u16,
    DaylightDate: WinSystemTime,
    DaylightBias: i32,
    TimeZoneKeyName: [128]u16,
    DynamicDaylightTimeDisabled: u8,
};

const TIME_ZONE_ID_INVALID: u32 = 0xFFFF_FFFF;

extern "kernel32" fn GetDynamicTimeZoneInformation(
    pTimeZoneInformation: *DynamicTimeZoneInformation,
) callconv(.winapi) u32;

/// A parsed POSIX TZ rule string (the TZif footer, e.g.
/// "<-04>4<-03>,M9.1.6/24,M4.1.6/24" or "EST5EDT,M3.2.0,M11.1.0"), used to
/// extrapolate offsets for timestamps beyond the file's transition table -
/// exactly what RFC 8536 specifies the footer is for. Without it, dates past
/// the last recorded transition (typically a few decades out, while ECMA-262
/// requires ±275,760 years) would freeze at the last known offset.
pub const PosixTz = struct {
    /// Standard offset in ms east of UTC (sign already converted from
    /// POSIX's west-positive convention).
    std_offset_ms: i64,
    dst: ?Dst,

    pub const Dst = struct {
        offset_ms: i64,
        start: Rule,
        end: Rule,
    };

    pub const Rule = struct {
        kind: Kind,
        /// 1-12 for .month_week_day.
        month: i32 = 0,
        /// 1-5 for .month_week_day (5 = last week of the month).
        week: i32 = 0,
        /// Day-of-week 0-6 (Sunday=0) for .month_week_day; day-of-year
        /// 1-365 for .julian_no_leap (Feb 29 never counted); 0-365 for
        /// .julian_leap (Feb 29 counted).
        day: i32,
        /// Wall-clock time of the transition within the day, in ms. POSIX
        /// TZ v3 allows negative values and values beyond 24h (e.g. "/24"
        /// in Chile's rule).
        time_ms: i64,
    };

    pub const Kind = enum { month_week_day, julian_no_leap, julian_leap };

    const default_transition_time_ms: i64 = 2 * Constants.MS_PER_HOUR;

    pub fn parse(str: []const u8) !PosixTz {
        var pos: usize = 0;

        try skipName(str, &pos);
        // POSIX offsets are west-positive; convert to east-positive ms.
        const std_offset_ms = -(try parseOffsetMs(str, &pos, false));

        if (pos >= str.len) {
            return .{ .std_offset_ms = std_offset_ms, .dst = null };
        }

        try skipName(str, &pos);
        // DST offset defaults to one hour ahead of (east of) standard time.
        var dst_offset_ms = std_offset_ms + Constants.MS_PER_HOUR;
        if (pos < str.len and str[pos] != ',') {
            dst_offset_ms = -(try parseOffsetMs(str, &pos, false));
        }

        // A DST name without rules is legal in POSIX (rules come from
        // elsewhere); treat it as fixed standard time since we have no rules
        // to apply.
        if (pos >= str.len) {
            return .{ .std_offset_ms = std_offset_ms, .dst = null };
        }

        if (str[pos] != ',') return error.InvalidPosixTz;
        pos += 1;
        const start = try parseRule(str, &pos);

        if (pos >= str.len or str[pos] != ',') return error.InvalidPosixTz;
        pos += 1;
        const end = try parseRule(str, &pos);

        if (pos != str.len) return error.InvalidPosixTz;

        return .{
            .std_offset_ms = std_offset_ms,
            .dst = .{ .offset_ms = dst_offset_ms, .start = start, .end = end },
        };
    }

    /// Offset (ms east of UTC) in effect at `utc_ms` according to this rule.
    pub fn offsetAtUtc(self: *const PosixTz, utc_ms: i64) i64 {
        const dst = self.dst orelse return self.std_offset_ms;

        // Approximate local year, then scan transition events across enough
        // adjacent years to be certain the latest event at-or-before utc_ms
        // is among them (handles both hemispheres and year boundaries).
        const local_year = CalendarUtils.timestampToComponents(utc_ms +| self.std_offset_ms, .utc).year;

        var latest_ts: i64 = std.math.minInt(i64);
        var latest_is_dst = false;
        var found = false;

        var y: i32 = local_year - 2;
        while (y <= local_year + 1) : (y += 1) {
            // DST start is expressed in standard wall-clock time; DST end in
            // DST wall-clock time.
            const start_utc = ruleLocalMs(dst.start, y) -| self.std_offset_ms;
            const end_utc = ruleLocalMs(dst.end, y) -| dst.offset_ms;

            if (start_utc <= utc_ms and start_utc > latest_ts) {
                latest_ts = start_utc;
                latest_is_dst = true;
                found = true;
            }
            if (end_utc <= utc_ms and end_utc > latest_ts) {
                latest_ts = end_utc;
                latest_is_dst = false;
                found = true;
            }
        }

        if (!found) return self.std_offset_ms;
        return if (latest_is_dst) dst.offset_ms else self.std_offset_ms;
    }

    /// Wall-clock ms (relative to the epoch, no zone applied) of the rule's
    /// transition instant in the given year.
    fn ruleLocalMs(rule: Rule, year: i32) i64 {
        var day_of_month: i32 = undefined;
        var month0: i32 = undefined;

        switch (rule.kind) {
            .month_week_day => {
                month0 = rule.month - 1;
                const first_dow = CalendarUtils.getDayOfWeek(year, month0, 1);
                const first_target = 1 + @mod(rule.day - first_dow + 7, 7);
                day_of_month = first_target + (rule.week - 1) * 7;
                const days_in_month = CalendarUtils.getDaysInMonth(year, month0);
                while (day_of_month > days_in_month) day_of_month -= 7;
            },
            .julian_no_leap => {
                // Day 1-365 where Feb 29 is never counted: for days at or
                // past March 1 in a leap year, shift forward one calendar day.
                month0 = 0;
                day_of_month = rule.day;
                if (CalendarUtils.isLeapYear(year) and rule.day >= 60) {
                    day_of_month += 1;
                }
            },
            .julian_leap => {
                // Zero-based day-of-year, Feb 29 counted.
                month0 = 0;
                day_of_month = rule.day + 1;
            },
        }

        // componentsToTimestamp adds (day - 1) days directly, so out-of-range
        // day values from the julian forms resolve without normalization.
        const midnight = CalendarUtils.componentsToTimestamp(.{
            .year = year,
            .month = month0,
            .day = day_of_month,
            .hour = 0,
            .minute = 0,
            .second = 0,
            .millisecond = 0,
        }, .utc);

        return midnight +| rule.time_ms;
    }

    fn skipName(str: []const u8, pos: *usize) !void {
        if (pos.* >= str.len) return error.InvalidPosixTz;
        if (str[pos.*] == '<') {
            const close = std.mem.indexOfScalarPos(u8, str, pos.*, '>') orelse return error.InvalidPosixTz;
            pos.* = close + 1;
            return;
        }
        const start = pos.*;
        while (pos.* < str.len and std.ascii.isAlphabetic(str[pos.*])) pos.* += 1;
        if (pos.* == start) return error.InvalidPosixTz;
    }

    /// Parse "[+-]h[h][:mm[:ss]]" into ms. `extended_hours` allows the POSIX
    /// v3 rule-time range (-167..167) instead of the offset range.
    fn parseOffsetMs(str: []const u8, pos: *usize, extended_hours: bool) !i64 {
        var negative = false;
        if (pos.* < str.len and (str[pos.*] == '+' or str[pos.*] == '-')) {
            negative = str[pos.*] == '-';
            pos.* += 1;
        }

        const hours = try parseIntComponent(str, pos, if (extended_hours) 3 else 2);
        const max_hours: i64 = if (extended_hours) 167 else 24;
        if (hours > max_hours) return error.InvalidPosixTz;

        var minutes: i64 = 0;
        var seconds: i64 = 0;
        if (pos.* < str.len and str[pos.*] == ':') {
            pos.* += 1;
            minutes = try parseIntComponent(str, pos, 2);
            if (minutes > 59) return error.InvalidPosixTz;
            if (pos.* < str.len and str[pos.*] == ':') {
                pos.* += 1;
                seconds = try parseIntComponent(str, pos, 2);
                if (seconds > 59) return error.InvalidPosixTz;
            }
        }

        const total = hours * Constants.MS_PER_HOUR + minutes * Constants.MS_PER_MINUTE + seconds * Constants.MS_PER_SECOND;
        return if (negative) -total else total;
    }

    fn parseRule(str: []const u8, pos: *usize) !Rule {
        if (pos.* >= str.len) return error.InvalidPosixTz;

        var rule: Rule = .{
            .kind = undefined,
            .day = undefined,
            .time_ms = default_transition_time_ms,
        };

        switch (str[pos.*]) {
            'M' => {
                pos.* += 1;
                rule.kind = .month_week_day;
                rule.month = @intCast(try parseIntComponent(str, pos, 2));
                if (rule.month < 1 or rule.month > 12) return error.InvalidPosixTz;
                if (pos.* >= str.len or str[pos.*] != '.') return error.InvalidPosixTz;
                pos.* += 1;
                rule.week = @intCast(try parseIntComponent(str, pos, 1));
                if (rule.week < 1 or rule.week > 5) return error.InvalidPosixTz;
                if (pos.* >= str.len or str[pos.*] != '.') return error.InvalidPosixTz;
                pos.* += 1;
                rule.day = @intCast(try parseIntComponent(str, pos, 1));
                if (rule.day > 6) return error.InvalidPosixTz;
            },
            'J' => {
                pos.* += 1;
                rule.kind = .julian_no_leap;
                rule.day = @intCast(try parseIntComponent(str, pos, 3));
                if (rule.day < 1 or rule.day > 365) return error.InvalidPosixTz;
            },
            else => {
                rule.kind = .julian_leap;
                rule.day = @intCast(try parseIntComponent(str, pos, 3));
                if (rule.day > 365) return error.InvalidPosixTz;
            },
        }

        if (pos.* < str.len and str[pos.*] == '/') {
            pos.* += 1;
            rule.time_ms = try parseOffsetMs(str, pos, true);
        }

        return rule;
    }

    fn parseIntComponent(str: []const u8, pos: *usize, max_digits: usize) !i64 {
        var value: i64 = 0;
        var digits: usize = 0;
        while (pos.* < str.len and str[pos.*] >= '0' and str[pos.*] <= '9' and digits < max_digits) {
            value = value * 10 + (str[pos.*] - '0');
            pos.* += 1;
            digits += 1;
        }
        if (digits == 0) return error.InvalidPosixTz;
        return value;
    }
};

/// An IANA timezone loaded from a TZif (RFC 8536) file, with offset lookup
/// by UTC timestamp. Wraps std.Tz (the TZif parser already in Zig's std).
///
/// This mirrors how JS engines resolve local time without ICU: read the
/// host's tzdata directly (V8's "POSIX fallback" path), except we use the
/// full transition table rather than a constant offset.
pub const Timezone = struct {
    tz: std.Tz,
    /// Parsed from the TZif footer when present and well-formed; extends
    /// offset lookup beyond the transition table's range.
    posix: ?PosixTz,

    fn fromTz(tz: std.Tz) Timezone {
        const posix: ?PosixTz = if (tz.footer) |footer|
            PosixTz.parse(footer) catch null
        else
            null;
        return .{ .tz = tz, .posix = posix };
    }

    pub fn deinit(self: *Timezone) void {
        self.tz.deinit();
    }

    /// Parse a TZif byte buffer (e.g. an @embedFile'd zone).
    pub fn parseBytes(allocator: Allocator, data: []const u8) !Timezone {
        var reader: std.Io.Reader = .fixed(data);
        const tz = try std.Tz.parse(allocator, &reader);
        return fromTz(tz);
    }

    /// Load a TZif file from an absolute path (e.g. "/etc/localtime" or
    /// "/usr/share/zoneinfo/America/Santiago").
    pub fn loadFromFile(allocator: Allocator, io: std.Io, path: []const u8) !Timezone {
        var file = try std.Io.Dir.openFileAbsolute(io, path, .{});
        defer file.close(io);

        var buffer: [4096]u8 = undefined;
        var file_reader = file.reader(io, &buffer);
        const tz = try std.Tz.parse(allocator, &file_reader.interface);
        return fromTz(tz);
    }

    /// Load a named IANA zone (e.g. "America/Santiago") from the system
    /// tzdata directory.
    pub fn loadNamed(allocator: Allocator, io: std.Io, name: []const u8) !Timezone {
        // Reject anything that could escape the zoneinfo directory.
        if (name.len == 0 or name[0] == '/' or std.mem.indexOf(u8, name, "..") != null) {
            return error.InvalidTimezoneName;
        }

        var path_buf: [512]u8 = undefined;
        const path = try std.fmt.bufPrint(&path_buf, "/usr/share/zoneinfo/{s}", .{name});
        return loadFromFile(allocator, io, path);
    }

    /// Load the host system's configured timezone.
    ///
    /// POSIX (same detection order as glibc and V8's POSIX fallback):
    ///   1. The TZ environment variable, when `environ` is provided and TZ
    ///      names an IANA zone (a leading ':' is stripped per POSIX).
    ///   2. /etc/localtime (a symlink to — or copy of — the zone's TZif file;
    ///      opening it follows the symlink).
    ///
    /// Windows: GetDynamicTimeZoneInformation's key name, mapped to an IANA
    /// zone via the CLDR windowsZones table, loaded from the embedded tzdata
    /// (Windows has no TZif files of its own; this embeds the full database,
    /// like V8 shipping ICU data).
    ///
    /// Returns an error if no source yields a parseable TZif file; the
    /// caller may treat that as "no timezone data" (offset 0, which ECMA-262
    /// explicitly permits).
    pub fn loadSystem(allocator: Allocator, io: std.Io, environ: ?std.process.Environ) !Timezone {
        if (builtin.os.tag == .windows) {
            return loadSystemWindows(allocator);
        }

        if (environ) |env| {
            if (getTzEnv(env)) |tz_name| {
                if (tz_name.len > 0) {
                    if (loadNamed(allocator, io, tz_name)) |tz| {
                        return tz;
                    } else |_| {
                        // TZ was set but unusable (e.g. a raw POSIX rule
                        // string): fall through to /etc/localtime.
                    }
                }
            }
        }

        return loadFromFile(allocator, io, "/etc/localtime");
    }

    fn loadSystemWindows(allocator: Allocator) !Timezone {
        var info: DynamicTimeZoneInformation = undefined;
        if (GetDynamicTimeZoneInformation(&info) == TIME_ZONE_ID_INVALID) {
            return error.NoTimezoneData;
        }

        const key_utf16 = std.mem.sliceTo(&info.TimeZoneKeyName, 0);
        var key_buf: [256]u8 = undefined;
        const key_len = std.unicode.utf16LeToUtf8(&key_buf, key_utf16) catch return error.NoTimezoneData;

        const iana_name = windows_zones.windowsToIana(key_buf[0..key_len]) orelse return error.NoTimezoneData;
        const data = zones.find(iana_name) orelse return error.NoTimezoneData;
        return parseBytes(allocator, data);
    }

    fn getTzEnv(environ: std.process.Environ) ?[]const u8 {
        if (builtin.os.tag == .windows) return null;
        const raw = environ.getPosix("TZ") orelse return null;
        // POSIX allows a leading ':' before an implementation-defined name.
        return if (raw.len > 0 and raw[0] == ':') raw[1..] else raw;
    }

    /// UTC offset in milliseconds (positive = east of UTC) in effect at the
    /// given UTC timestamp in milliseconds.
    ///
    /// Timestamps within the file's transition table use the recorded
    /// history; timestamps past the last transition use the footer's POSIX
    /// rule when available (falling back to the last recorded offset);
    /// timestamps before the first transition use the earliest standard
    /// offset.
    pub fn offsetAtUtc(self: *const Timezone, utc_ms: i64) i64 {
        const utc_s = @divFloor(utc_ms, Constants.MS_PER_SECOND);
        const transitions = self.tz.transitions;

        if (transitions.len == 0) {
            if (self.posix) |*posix| return posix.offsetAtUtc(utc_ms);
            return firstStandardOffsetMs(self);
        }

        if (utc_s < transitions[0].ts) {
            return firstStandardOffsetMs(self);
        }

        if (utc_s >= transitions[transitions.len - 1].ts) {
            if (self.posix) |*posix| return posix.offsetAtUtc(utc_ms);
            return @as(i64, transitions[transitions.len - 1].timetype.offset) * Constants.MS_PER_SECOND;
        }

        // Binary search: index of the last transition with ts <= utc_s.
        var lo: usize = 0;
        var hi: usize = transitions.len;
        while (lo < hi) {
            const mid = lo + (hi - lo) / 2;
            if (transitions[mid].ts <= utc_s) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        return @as(i64, transitions[lo - 1].timetype.offset) * Constants.MS_PER_SECOND;
    }

    /// Convert a local-time timestamp (ms) to UTC (ms), with the
    /// disambiguation ECMA-262 mandates (tc39/ecma262#778):
    ///
    /// - A local time that occurs twice (clock set backward): interpret it
    ///   with the offset in effect *before* the transition.
    /// - A local time that never occurs (clock set forward): likewise use
    ///   the offset in effect *before* the transition.
    ///
    /// Implemented by probing the offset well before and after the local
    /// instant (one day on each side covers every real-world offset) and
    /// preferring the earlier offset when it is self-consistent.
    pub fn utcFromLocal(self: *const Timezone, local_ms: i64) i64 {
        const probe_distance = Constants.MS_PER_DAY;

        // Saturating arithmetic: local_ms may itself be near the i64 edges
        // (constructor normalization saturates out-of-range component sets).
        const offset_before = self.offsetAtUtc(local_ms -| probe_distance);
        const utc_with_before = local_ms -| offset_before;
        if (self.offsetAtUtc(utc_with_before) == offset_before) {
            // Consistent with the pre-transition offset. For repeated local
            // times both offsets are consistent; the spec picks this one.
            return utc_with_before;
        }

        const offset_after = self.offsetAtUtc(local_ms +| probe_distance);
        const utc_with_after = local_ms -| offset_after;
        if (self.offsetAtUtc(utc_with_after) == offset_after) {
            return utc_with_after;
        }

        // Skipped (nonexistent) local time: spec says use the offset in
        // effect before the transition.
        return utc_with_before;
    }

    /// Offset of the earliest standard (non-DST) time type, used for
    /// timestamps before the first recorded transition (per common tzdata
    /// reader practice, matching glibc).
    fn firstStandardOffsetMs(self: *const Timezone) i64 {
        for (self.tz.timetypes) |tt| {
            if (!tt.isDst()) return @as(i64, tt.offset) * Constants.MS_PER_SECOND;
        }
        if (self.tz.timetypes.len > 0) {
            return @as(i64, self.tz.timetypes[0].offset) * Constants.MS_PER_SECOND;
        }
        return 0;
    }
};
