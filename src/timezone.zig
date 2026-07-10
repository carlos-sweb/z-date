const std = @import("std");
const constants = @import("constants.zig");
const tzdata = @import("tzdata.zig");

const Constants = constants.Constants;

/// Timezone mode for date operations
pub const TimezoneMode = enum {
    utc,
    local,
};

/// The process-wide local timezone, mirroring ECMA-262's model where the
/// local zone belongs to the host environment rather than to each Date.
///
/// When null (the default), the local offset is 0 — i.e. local time equals
/// UTC, which ECMA-262 explicitly permits for hosts without timezone data.
///
/// Not synchronized: load the timezone once at program startup (as a JS
/// engine does) before concurrent ZDate use, via ZDate.loadSystemTimezone /
/// ZDate.setLocalTimezone.
var local_timezone: ?tzdata.Timezone = null;

/// Timezone utilities for handling local and UTC time
pub const TimezoneUtils = struct {
    /// Load the host system's timezone (TZ env var when `environ` is given,
    /// then /etc/localtime) as the process-wide local zone. Replaces any
    /// previously loaded zone.
    pub fn loadSystemTimezone(allocator: std.mem.Allocator, io: std.Io, environ: ?std.process.Environ) !void {
        const tz = try tzdata.Timezone.loadSystem(allocator, io, environ);
        clearLocalTimezone();
        local_timezone = tz;
    }

    /// Load a named IANA zone (e.g. "America/Santiago") from the system
    /// tzdata directory as the process-wide local zone.
    pub fn loadNamedTimezone(allocator: std.mem.Allocator, io: std.Io, name: []const u8) !void {
        const tz = try tzdata.Timezone.loadNamed(allocator, io, name);
        clearLocalTimezone();
        local_timezone = tz;
    }

    /// Install an already-loaded timezone as the process-wide local zone,
    /// taking ownership. Replaces any previously loaded zone.
    pub fn setLocalTimezone(tz: tzdata.Timezone) void {
        clearLocalTimezone();
        local_timezone = tz;
    }

    /// Release the local timezone and return to the no-data default
    /// (offset 0, local == UTC).
    pub fn clearLocalTimezone() void {
        if (local_timezone) |*tz| {
            tz.deinit();
            local_timezone = null;
        }
    }

    /// Whether a local timezone is currently loaded.
    pub fn hasLocalTimezone() bool {
        return local_timezone != null;
    }

    /// Local timezone offset in milliseconds (positive = east of UTC) in
    /// effect at the given UTC timestamp. 0 when no timezone is loaded.
    pub fn getTimezoneOffsetMs(utc_timestamp: i64) i64 {
        const tz = &(local_timezone orelse return 0);
        return tz.offsetAtUtc(utc_timestamp);
    }

    /// Get timezone offset in minutes for a given UTC timestamp (for
    /// getTimezoneOffset()). ECMAScript specifies the offset as
    /// (UTC - local) in minutes, so east-of-UTC zones yield negative values.
    pub fn getTimezoneOffsetMinutes(utc_timestamp: i64) i32 {
        const ms_offset = getTimezoneOffsetMs(utc_timestamp);
        return -@as(i32, @intCast(@divTrunc(ms_offset, Constants.MS_PER_MINUTE)));
    }

    /// Apply timezone offset to a timestamp (UTC -> local wall-clock ms)
    pub fn applyTimezoneOffset(timestamp: i64, mode: TimezoneMode) i64 {
        return switch (mode) {
            .utc => timestamp,
            .local => timestamp + getTimezoneOffsetMs(timestamp),
        };
    }

    /// Remove timezone offset from a timestamp (local wall-clock ms -> UTC)
    pub fn removeTimezoneOffset(timestamp: i64, mode: TimezoneMode) i64 {
        return switch (mode) {
            .utc => timestamp,
            .local => blk: {
                const tz = &(local_timezone orelse break :blk timestamp);
                break :blk tz.utcFromLocal(timestamp);
            },
        };
    }
};
