const std = @import("std");
const old = @import("baseline");
const new = @import("zdate");
const a = std.testing.allocator;

fn componentsEqual(x: anytype, y: anytype) !void {
    inline for (@typeInfo(@TypeOf(x)).@"struct".field_names) |name| {
        try std.testing.expectEqual(@field(x, name), @field(y, name));
    }
}

fn gettersEqual(ts: i64) !void {
    const x = old.ZDate.fromTimestamp(ts);
    const y = new.ZDate.fromTimestamp(ts);
    inline for (.{ "getUTCFullYear", "getUTCMonth", "getUTCDate", "getUTCDay", "getUTCHours", "getUTCMinutes", "getUTCSeconds", "getUTCMilliseconds", "getFullYear", "getMonth", "getDate", "getDay", "getHours", "getMinutes", "getSeconds", "getMilliseconds", "getTimezoneOffset" }) |name| {
        try std.testing.expectEqual(@field(old.ZDate, name)(x), @field(new.ZDate, name)(y));
    }
}

fn settersEqual(ts: i64, value: i32) !void {
    inline for (.{ "setHours", "setUTCHours", "setMinutes", "setUTCMinutes", "setSeconds", "setUTCSeconds", "setMilliseconds", "setUTCMilliseconds" }) |name| {
        var x = old.ZDate.fromTimestamp(ts);
        var y = new.ZDate.fromTimestamp(ts);
        const args_x = if (comptime std.mem.endsWith(u8, name, "Hours")) .{ &x, value, null, null, null } else if (comptime std.mem.endsWith(u8, name, "Minutes")) .{ &x, value, null, null } else if (comptime std.mem.endsWith(u8, name, "Seconds")) .{ &x, value, null } else .{ &x, value };
        const args_y = if (comptime std.mem.endsWith(u8, name, "Hours")) .{ &y, value, null, null, null } else if (comptime std.mem.endsWith(u8, name, "Minutes")) .{ &y, value, null, null } else if (comptime std.mem.endsWith(u8, name, "Seconds")) .{ &y, value, null } else .{ &y, value };
        try std.testing.expectEqual(@call(.auto, @field(old.ZDate, name), args_x), @call(.auto, @field(new.ZDate, name), args_y));
    }
    var x = old.ZDate.fromTimestamp(ts);
    var y = new.ZDate.fromTimestamp(ts);
    try std.testing.expectEqual(x.setHours(value, value, value, value), y.setHours(value, value, value, value));
}

test "calendar: two complete Gregorian cycles and random TimeClip timestamps match baseline" {
    for ([_]i64{ @as(i64, -865625), @as(i64, 10957) }) |start| {
        for (0..146097) |i| {
            const ts = (start + @as(i64, @intCast(i))) * new.Constants.MS_PER_DAY;
            const x = old.CalendarUtil.timestampToComponents(ts, .utc);
            const y = new.CalendarUtil.timestampToComponents(ts, .utc);
            try componentsEqual(x, y);
            try std.testing.expectEqual(ts, new.CalendarUtil.componentsToTimestamp(y, .utc));
        }
    }
    var prng = std.Random.DefaultPrng.init(0x17_2026);
    const r = prng.random();
    for (0..20000) |_| {
        const ts = r.intRangeAtMost(i64, new.Constants.MIN_TIME, new.Constants.MAX_TIME);
        try gettersEqual(ts);
    }
    for ([_]i64{ new.Constants.MIN_TIME, new.Constants.MAX_TIME, @as(i64, -1), @as(i64, 0), new.Constants.INVALID_TIME }) |ts| try gettersEqual(ts);
}

test "normalization and constructors match for overflowing and extreme components" {
    var prng = std.Random.DefaultPrng.init(0x101);
    const r = prng.random();
    for (0..10000) |_| {
        const year = r.intRangeAtMost(i32, -280000, 280000);
        const month = r.intRangeAtMost(i32, -100, 100);
        const day = r.int(i32);
        const hour = r.int(i32);
        const minute = r.int(i32);
        const second = r.int(i32);
        const ms = r.int(i32);
        try std.testing.expectEqual(old.ZDate.UTC(year, month, day, hour, minute, second, ms), new.ZDate.UTC(year, month, day, hour, minute, second, ms));
    }
    for ([_]i32{ std.math.minInt(i32), std.math.maxInt(i32) }) |year| {
        for ([_]i32{ @as(i32, -2000000000), 0, 2000000000 }) |day| {
            var x: old.DateComponents = .{ .year = year, .month = 1, .day = day, .hour = 0, .minute = 0, .second = 0, .millisecond = 0 };
            var y: new.DateComponents = .{ .year = year, .month = 1, .day = day, .hour = 0, .minute = 0, .second = 0, .millisecond = 0 };
            old.CalendarUtil.normalizeComponents(&x);
            new.CalendarUtil.normalizeComponents(&y);
            try componentsEqual(x, y);
        }
    }
}

test "local getters and setters preserve history, DST disambiguation and extreme fields" {
    old.ZDate.setLocalTimezone(try old.Timezone.parseBytes(a, old.zones.america_santiago));
    defer old.ZDate.clearLocalTimezone();
    new.ZDate.setLocalTimezone(try new.Timezone.parseBytes(a, new.zones.america_santiago));
    defer new.ZDate.clearLocalTimezone();
    var prng = std.Random.DefaultPrng.init(0xD57);
    const r = prng.random();
    for (0..2000) |_| {
        const ts = r.intRangeAtMost(i64, -2208988800000, 10413792000000);
        try gettersEqual(ts);
        try settersEqual(ts, r.int(i32));
    }
    // Sample each minute around Chile's 2024 gap and fold, with optional fields retained.
    for ([_]i64{ @as(i64, 1712458800000), @as(i64, 1725768000000) }) |transition| {
        for (0..241) |i| {
            const ts = transition + (@as(i64, @intCast(i)) - 120) * 60000;
            try settersEqual(ts, 0);
            try settersEqual(ts, 24);
        }
    }
    for ([_]i64{ new.Constants.MIN_TIME, new.Constants.MAX_TIME, new.Constants.INVALID_TIME }) |ts| {
        for ([_]i32{ std.math.minInt(i32), @as(i32, -1), 0, std.math.maxInt(i32) }) |value| try settersEqual(ts, value);
    }
}

fn compareLocale(l_old: old.Locale, l_new: new.Locale, ts: i64) !void {
    const x = old.ZDate.fromTimestamp(ts);
    const y = new.ZDate.fromTimestamp(ts);
    inline for (.{ "toLocaleString", "toLocaleTimeString", "toLocaleDateString" }) |name| {
        const sx = try @field(old.ZDate, name)(x, a, l_old);
        defer a.free(sx);
        const sy = try @field(new.ZDate, name)(y, a, l_new);
        defer a.free(sy);
        try std.testing.expectEqualStrings(sx, sy);
    }
    inline for (.{ "toLocaleStringStyle", "toLocaleDateStringStyle" }) |name| {
        const sx = try @field(old.ZDate, name)(x, a, l_old, .long);
        defer a.free(sx);
        const sy = try @field(new.ZDate, name)(y, a, l_new, .long);
        defer a.free(sy);
        try std.testing.expectEqualStrings(sx, sy);
    }
}

test "all 145 locales, negative/expanded years and long custom patterns preserve exact output" {
    @setEvalBranchQuota(1_000_000);
    const pairs = comptime blk: {
        const names = @typeInfo(new.locales).@"struct".decl_names;
        var result: [names.len]struct { before: old.Locale, after: new.Locale } = undefined;
        for (names, 0..) |key, i| result[i] = .{ .before = @field(old.locales, key), .after = @field(new.locales, key) };
        break :blk result;
    };
    for (pairs) |pair| {
        for ([_]i64{ @as(i64, -1), new.Constants.MIN_TIME, new.Constants.MAX_TIME, new.ZDate.UTC(2024, 1, 29, 23, 59, 59, 999), new.Constants.INVALID_TIME }) |ts| try compareLocale(pair.before, pair.after, ts);
    }
    var long: [2048]u8 = @splat('x');
    var l_old = old.locales.en;
    var l_new = new.locales.en;
    l_old.long_date_format = &long;
    l_new.long_date_format = &long;
    l_old.pm_label = &long;
    l_new.pm_label = &long;
    const ts = new.ZDate.UTC(2024, 0, 1, 15, 0, 0, 0);
    const sx = try old.ZDate.fromTimestamp(ts).toLocaleStringStyle(a, l_old, .long);
    defer a.free(sx);
    const sy = try new.ZDate.fromTimestamp(ts).toLocaleStringStyle(a, l_new, .long);
    defer a.free(sy);
    try std.testing.expectEqualStrings(sx, sy);
}

test "POSIX cache matches uncached baseline for rule replacement, year boundaries and full range" {
    const rules = .{ "<-04>4<-03>,M9.1.6/24,M4.1.6/24", "EST5EDT,M3.2.0/2,M11.1.0/2", "CET-1CEST,M3.5.0/-167,M10.5.0/167", "AAA0BBB,J60/0,J300/24", "AAA0BBB,59/-1,365/25" };
    var prng = std.Random.DefaultPrng.init(0x9051);
    const r = prng.random();
    for (0..1000) |_| {
        const ts = r.intRangeAtMost(i64, new.Constants.MIN_TIME, new.Constants.MAX_TIME);
        inline for (rules) |rule| {
            const x = try old.PosixTz.parse(rule);
            const y = try new.PosixTz.parse(rule);
            try std.testing.expectEqual(x.offsetAtUtc(ts), y.offsetAtUtc(ts));
            try std.testing.expectEqual(x.offsetAtUtc(ts +| 3600000), y.offsetAtUtc(ts +| 3600000));
        }
    }
    inline for (rules) |rule| {
        const x = try old.PosixTz.parse(rule);
        const y = try new.PosixTz.parse(rule);
        for ([_]i32{ @as(i32, -400), 0, 1900, 2000, 2200 }) |year| {
            const start = new.CalendarUtil.componentsToTimestamp(.{ .year = year, .month = 0, .day = 1, .hour = 0, .minute = 0, .second = 0, .millisecond = 0 }, .utc);
            for (0..370) |day| {
                const ts = start + (@as(i64, @intCast(day)) - 2) * 86400000;
                try std.testing.expectEqual(x.offsetAtUtc(ts), y.offsetAtUtc(ts));
            }
        }
    }
}

fn cacheWorker(result: *bool, rule: []const u8) void {
    const x = old.PosixTz.parse(rule) catch return;
    const y = new.PosixTz.parse(rule) catch return;
    for (0..2000) |i| {
        const ts = 7258118400000 + @as(i64, @intCast(i)) * 87654321;
        if (x.offsetAtUtc(ts) != y.offsetAtUtc(ts)) return;
    }
    result.* = true;
}

test "POSIX cache is isolated between concurrent threads" {
    const rules = [_][]const u8{ "EST5EDT,M3.2.0,M11.1.0", "CET-1CEST,M3.5.0,M10.5.0", "<-04>4<-03>,M9.1.6/24,M4.1.6/24", "AAA0BBB,J60/0,J300/24" };
    var results: [4]bool = @splat(false);
    var threads: [4]std.Thread = undefined;
    var started: usize = 0;
    defer for (threads[0..started]) |thread| thread.join();
    for (rules, 0..) |rule, i| {
        threads[i] = try std.Thread.spawn(.{}, cacheWorker, .{ &results[i], rule });
        started += 1;
    }
    for (threads) |thread| thread.join();
    started = 0;
    for (results) |ok| try std.testing.expect(ok);
}
