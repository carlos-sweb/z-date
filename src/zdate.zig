const std = @import("std");
const constants = @import("constants.zig");
const errors = @import("errors.zig");
const timezone = @import("timezone.zig");
const calendar = @import("calendar.zig");
const getters = @import("getters.zig");
const setters = @import("setters.zig");
const formatting = @import("formatting.zig");
const parsing = @import("parsing.zig");
const arithmetic = @import("arithmetic.zig");

pub const Constants = constants.Constants;
pub const ZDateError = errors.ZDateError;
pub const TimezoneMode = timezone.TimezoneMode;
pub const DateComponents = calendar.DateComponents;

const TimezoneUtils = timezone.TimezoneUtils;
const CalendarUtils = calendar.CalendarUtils;
const GetterMethods = getters.GetterMethods;
const SetterMethods = setters.SetterMethods;
const FormattingMethods = formatting.FormattingMethods;
const ParsingMethods = parsing.ParsingMethods;
const ArithmeticMethods = arithmetic.ArithmeticMethods;

const Allocator = std.mem.Allocator;

/// Z-Date: ECMAScript-compatible date/time library for Zig
/// Implements the full JavaScript Date API specification
pub const ZDate = struct {
    /// Timestamp in milliseconds since Unix epoch (January 1, 1970, 00:00:00 UTC)
    /// ZDate is a pure 8-byte value — allocator and io are passed per-function, not stored.
    timestamp: i64,

    const Self = @This();

    // ===== Constructors =====

    /// Initialize with current date/time
    /// Requires io context from std.process.Init (Zig 0.16+)
    pub fn now(io: std.Io) Self {
        return fromTimestamp(nowTimestamp(io));
    }

    /// Initialize from timestamp (milliseconds)
    pub fn fromTimestamp(ms: i64) Self {
        const validated_timestamp: i64 = if (ms < Constants.MIN_TIME or ms > Constants.MAX_TIME)
            Constants.INVALID_TIME
        else
            ms;
        return .{ .timestamp = validated_timestamp };
    }

    /// Initialize from components (year, month, day, etc.)
    pub fn fromComponents(
        year: i32,
        month: i32,
        day: ?i32,
        hour: ?i32,
        minute: ?i32,
        second: ?i32,
        millisecond: ?i32,
    ) Self {
        const components = DateComponents{
            .year = year,
            .month = month,
            .day = day orelse 1,
            .hour = hour orelse 0,
            .minute = minute orelse 0,
            .second = second orelse 0,
            .millisecond = millisecond orelse 0,
        };

        if (!CalendarUtils.validateComponents(components)) {
            return fromTimestamp(Constants.INVALID_TIME);
        }

        const timestamp = CalendarUtils.componentsToTimestamp(components, .local);
        return fromTimestamp(timestamp);
    }

    /// Initialize from components (UTC)
    pub fn fromComponentsUTC(
        year: i32,
        month: i32,
        day: ?i32,
        hour: ?i32,
        minute: ?i32,
        second: ?i32,
        millisecond: ?i32,
    ) Self {
        const components = DateComponents{
            .year = year,
            .month = month,
            .day = day orelse 1,
            .hour = hour orelse 0,
            .minute = minute orelse 0,
            .second = second orelse 0,
            .millisecond = millisecond orelse 0,
        };

        if (!CalendarUtils.validateComponents(components)) {
            return fromTimestamp(Constants.INVALID_TIME);
        }

        const timestamp = CalendarUtils.componentsToTimestamp(components, .utc);
        return fromTimestamp(timestamp);
    }

    /// Initialize from ISO 8601 string
    pub fn fromISO8601(str: []const u8) Self {
        const timestamp = ParsingMethods.parseISO8601(str) catch Constants.INVALID_TIME;
        return fromTimestamp(timestamp);
    }

    /// Initialize from date string (various formats)
    pub fn fromString(str: []const u8) Self {
        return fromTimestamp(ParsingMethods.parse(str));
    }

    // ===== Static Methods (Date.*) =====

    /// Date.now() - Get current timestamp in milliseconds
    /// Requires io context from std.process.Init (Zig 0.16+)
    pub fn nowTimestamp(io: std.Io) i64 {
        const t = std.Io.Clock.real.now(io);
        return t.toMilliseconds();
    }

    /// Date.parse() - Parse date string to timestamp
    pub fn parse(str: []const u8) i64 {
        return ParsingMethods.parse(str);
    }

    /// Date.UTC() - Get UTC timestamp from components
    pub fn UTC(
        year: i32,
        month: i32,
        day: ?i32,
        hour: ?i32,
        minute: ?i32,
        second: ?i32,
        millisecond: ?i32,
    ) i64 {
        const components = DateComponents{
            .year = year,
            .month = month,
            .day = day orelse 1,
            .hour = hour orelse 0,
            .minute = minute orelse 0,
            .second = second orelse 0,
            .millisecond = millisecond orelse 0,
        };

        if (!CalendarUtils.validateComponents(components)) {
            return Constants.INVALID_TIME;
        }

        return CalendarUtils.componentsToTimestamp(components, .utc);
    }

    // ===== Getters (Local Time) =====

    /// getFullYear() - Get 4-digit year (local time)
    pub fn getFullYear(self: Self) i32 {
        return GetterMethods.getFullYear(self.timestamp, .local);
    }

    /// getMonth() - Get month (0-11, local time)
    pub fn getMonth(self: Self) i32 {
        return GetterMethods.getMonth(self.timestamp, .local);
    }

    /// getDate() - Get day of month (1-31, local time)
    pub fn getDate(self: Self) i32 {
        return GetterMethods.getDate(self.timestamp, .local);
    }

    /// getDay() - Get day of week (0-6, Sunday=0, local time)
    pub fn getDay(self: Self) i32 {
        return GetterMethods.getDay(self.timestamp, .local);
    }

    /// getHours() - Get hours (0-23, local time)
    pub fn getHours(self: Self) i32 {
        return GetterMethods.getHours(self.timestamp, .local);
    }

    /// getMinutes() - Get minutes (0-59, local time)
    pub fn getMinutes(self: Self) i32 {
        return GetterMethods.getMinutes(self.timestamp, .local);
    }

    /// getSeconds() - Get seconds (0-59, local time)
    pub fn getSeconds(self: Self) i32 {
        return GetterMethods.getSeconds(self.timestamp, .local);
    }

    /// getMilliseconds() - Get milliseconds (0-999, local time)
    pub fn getMilliseconds(self: Self) i32 {
        return GetterMethods.getMilliseconds(self.timestamp, .local);
    }

    /// getTime() - Get timestamp
    pub fn getTime(self: Self) i64 {
        return GetterMethods.getTime(self.timestamp);
    }

    /// getTimezoneOffset() - Get timezone offset in minutes
    pub fn getTimezoneOffset(self: Self) i32 {
        _ = self;
        return GetterMethods.getTimezoneOffset();
    }

    // ===== Getters (UTC) =====

    /// getUTCFullYear() - Get 4-digit year (UTC)
    pub fn getUTCFullYear(self: Self) i32 {
        return GetterMethods.getFullYear(self.timestamp, .utc);
    }

    /// getUTCMonth() - Get month (0-11, UTC)
    pub fn getUTCMonth(self: Self) i32 {
        return GetterMethods.getMonth(self.timestamp, .utc);
    }

    /// getUTCDate() - Get day of month (1-31, UTC)
    pub fn getUTCDate(self: Self) i32 {
        return GetterMethods.getDate(self.timestamp, .utc);
    }

    /// getUTCDay() - Get day of week (0-6, Sunday=0, UTC)
    pub fn getUTCDay(self: Self) i32 {
        return GetterMethods.getDay(self.timestamp, .utc);
    }

    /// getUTCHours() - Get hours (0-23, UTC)
    pub fn getUTCHours(self: Self) i32 {
        return GetterMethods.getHours(self.timestamp, .utc);
    }

    /// getUTCMinutes() - Get minutes (0-59, UTC)
    pub fn getUTCMinutes(self: Self) i32 {
        return GetterMethods.getMinutes(self.timestamp, .utc);
    }

    /// getUTCSeconds() - Get seconds (0-59, UTC)
    pub fn getUTCSeconds(self: Self) i32 {
        return GetterMethods.getSeconds(self.timestamp, .utc);
    }

    /// getUTCMilliseconds() - Get milliseconds (0-999, UTC)
    pub fn getUTCMilliseconds(self: Self) i32 {
        return GetterMethods.getMilliseconds(self.timestamp, .utc);
    }

    // ===== Setters (Local Time) =====

    /// setFullYear() - Set year (local time)
    pub fn setFullYear(self: *Self, year: i32, month: ?i32, day: ?i32) i64 {
        return SetterMethods.setFullYear(&self.timestamp, year, month, day, .local);
    }

    /// setMonth() - Set month (local time)
    pub fn setMonth(self: *Self, month: i32, day: ?i32) i64 {
        return SetterMethods.setMonth(&self.timestamp, month, day, .local);
    }

    /// setDate() - Set day of month (local time)
    pub fn setDate(self: *Self, day: i32) i64 {
        return SetterMethods.setDate(&self.timestamp, day, .local);
    }

    /// setHours() - Set hours (local time)
    pub fn setHours(self: *Self, hour: i32, min: ?i32, sec: ?i32, ms: ?i32) i64 {
        return SetterMethods.setHours(&self.timestamp, hour, min, sec, ms, .local);
    }

    /// setMinutes() - Set minutes (local time)
    pub fn setMinutes(self: *Self, min: i32, sec: ?i32, ms: ?i32) i64 {
        return SetterMethods.setMinutes(&self.timestamp, min, sec, ms, .local);
    }

    /// setSeconds() - Set seconds (local time)
    pub fn setSeconds(self: *Self, sec: i32, ms: ?i32) i64 {
        return SetterMethods.setSeconds(&self.timestamp, sec, ms, .local);
    }

    /// setMilliseconds() - Set milliseconds (local time)
    pub fn setMilliseconds(self: *Self, ms: i32) i64 {
        return SetterMethods.setMilliseconds(&self.timestamp, ms, .local);
    }

    /// setTime() - Set timestamp
    pub fn setTime(self: *Self, timestamp: i64) i64 {
        return SetterMethods.setTime(&self.timestamp, timestamp);
    }

    // ===== Setters (UTC) =====

    /// setUTCFullYear() - Set year (UTC)
    pub fn setUTCFullYear(self: *Self, year: i32, month: ?i32, day: ?i32) i64 {
        return SetterMethods.setFullYear(&self.timestamp, year, month, day, .utc);
    }

    /// setUTCMonth() - Set month (UTC)
    pub fn setUTCMonth(self: *Self, month: i32, day: ?i32) i64 {
        return SetterMethods.setMonth(&self.timestamp, month, day, .utc);
    }

    /// setUTCDate() - Set day of month (UTC)
    pub fn setUTCDate(self: *Self, day: i32) i64 {
        return SetterMethods.setDate(&self.timestamp, day, .utc);
    }

    /// setUTCHours() - Set hours (UTC)
    pub fn setUTCHours(self: *Self, hour: i32, min: ?i32, sec: ?i32, ms: ?i32) i64 {
        return SetterMethods.setHours(&self.timestamp, hour, min, sec, ms, .utc);
    }

    /// setUTCMinutes() - Set minutes (UTC)
    pub fn setUTCMinutes(self: *Self, min: i32, sec: ?i32, ms: ?i32) i64 {
        return SetterMethods.setMinutes(&self.timestamp, min, sec, ms, .utc);
    }

    /// setUTCSeconds() - Set seconds (UTC)
    pub fn setUTCSeconds(self: *Self, sec: i32, ms: ?i32) i64 {
        return SetterMethods.setSeconds(&self.timestamp, sec, ms, .utc);
    }

    /// setUTCMilliseconds() - Set milliseconds (UTC)
    pub fn setUTCMilliseconds(self: *Self, ms: i32) i64 {
        return SetterMethods.setMilliseconds(&self.timestamp, ms, .utc);
    }

    // ===== Formatting Methods =====

    /// toString() - Convert to string (local time)
    pub fn toString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toString(self.timestamp, allocator);
    }

    /// toDateString() - Date portion only
    pub fn toDateString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toDateString(self.timestamp, allocator);
    }

    /// toTimeString() - Time portion only
    pub fn toTimeString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toTimeString(self.timestamp, allocator);
    }

    /// toISOString() - ISO 8601 format (UTC)
    pub fn toISOString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toISOString(self.timestamp, allocator);
    }

    /// toJSON() - JSON representation
    pub fn toJSON(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toJSON(self.timestamp, allocator);
    }

    /// toUTCString() - UTC string
    pub fn toUTCString(self: Self, allocator: Allocator) ![]u8 {
        return FormattingMethods.toUTCString(self.timestamp, allocator);
    }

    /// toLocaleDateString() - Localized date string
    pub fn toLocaleDateString(self: Self, allocator: Allocator, locale: ?[]const u8) ![]u8 {
        return FormattingMethods.toLocaleDateString(self.timestamp, allocator, locale);
    }

    /// toLocaleTimeString() - Localized time string
    pub fn toLocaleTimeString(self: Self, allocator: Allocator, locale: ?[]const u8) ![]u8 {
        return FormattingMethods.toLocaleTimeString(self.timestamp, allocator, locale);
    }

    /// toLocaleString() - Localized date and time string
    pub fn toLocaleString(self: Self, allocator: Allocator, locale: ?[]const u8) ![]u8 {
        return FormattingMethods.toLocaleString(self.timestamp, allocator, locale);
    }

    /// valueOf() - Return timestamp
    pub fn valueOf(self: Self) i64 {
        return self.timestamp;
    }

    // ===== Comparison and Arithmetic =====

    /// Check if two dates are equal
    pub fn equals(self: Self, other: Self) bool {
        return ArithmeticMethods.equals(self.timestamp, other.timestamp);
    }

    /// Check if this date is before another
    pub fn before(self: Self, other: Self) bool {
        return ArithmeticMethods.before(self.timestamp, other.timestamp);
    }

    /// Check if this date is after another
    pub fn after(self: Self, other: Self) bool {
        return ArithmeticMethods.after(self.timestamp, other.timestamp);
    }

    /// Compare with another date
    pub fn compare(self: Self, other: Self) std.math.Order {
        return ArithmeticMethods.compare(self.timestamp, other.timestamp);
    }

    /// Add milliseconds
    pub fn addMilliseconds(self: Self, ms: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addMilliseconds(self.timestamp, ms);
        return fromTimestamp(new_timestamp);
    }

    /// Add seconds
    pub fn addSeconds(self: Self, seconds: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addSeconds(self.timestamp, seconds);
        return fromTimestamp(new_timestamp);
    }

    /// Add minutes
    pub fn addMinutes(self: Self, minutes: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addMinutes(self.timestamp, minutes);
        return fromTimestamp(new_timestamp);
    }

    /// Add hours
    pub fn addHours(self: Self, hours: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addHours(self.timestamp, hours);
        return fromTimestamp(new_timestamp);
    }

    /// Add days
    pub fn addDays(self: Self, days: i64) !Self {
        const new_timestamp = try ArithmeticMethods.addDays(self.timestamp, days);
        return fromTimestamp(new_timestamp);
    }

    /// Difference in milliseconds
    pub fn diffMilliseconds(self: Self, other: Self) i64 {
        return ArithmeticMethods.diffMilliseconds(self.timestamp, other.timestamp);
    }

    /// Difference in seconds
    pub fn diffSeconds(self: Self, other: Self) i64 {
        return ArithmeticMethods.diffSeconds(self.timestamp, other.timestamp);
    }

    /// Difference in minutes
    pub fn diffMinutes(self: Self, other: Self) i64 {
        return ArithmeticMethods.diffMinutes(self.timestamp, other.timestamp);
    }

    /// Difference in hours
    pub fn diffHours(self: Self, other: Self) i64 {
        return ArithmeticMethods.diffHours(self.timestamp, other.timestamp);
    }

    /// Difference in days
    pub fn diffDays(self: Self, other: Self) i64 {
        return ArithmeticMethods.diffDays(self.timestamp, other.timestamp);
    }

    // ===== Validation =====

    /// Check if date is valid
    pub fn isValid(self: Self) bool {
        return self.timestamp != Constants.INVALID_TIME and
            self.timestamp >= Constants.MIN_TIME and
            self.timestamp <= Constants.MAX_TIME;
    }

    /// Check if year is leap year
    pub fn isLeapYear(year: i32) bool {
        return CalendarUtils.isLeapYear(year);
    }
};

// Export all public APIs
pub const CalendarUtil = CalendarUtils;
pub const TimezoneUtil = TimezoneUtils;
