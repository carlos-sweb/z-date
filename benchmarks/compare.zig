const std = @import("std");
const before = @import("baseline");
const after = @import("zdate");
const allocator = std.heap.smp_allocator;
const n = 4096;
const rounds = 7;
const Profile = enum { full_range, history, future_clustered, future_random };
const Case = enum {
    utc_day,
    utc_hour,
    utc_minute,
    utc_second,
    utc_ms,
    utc_ymd,
    local_day,
    local_hour,
    calendar,
    components,
    normalize,
    set_utc_hour,
    set_utc_ms,
    set_local_hour,
    iso,
    time_string,
    locale_time,
    locale_numeric,
    locale_long,
    parse_iso,
    parse_legacy,
    parse_slash,
    offset,
};
const Input = struct {
    ts: i64,
    year: i32,
    month: i32,
    day: i32,
    hour: i32,
    minute: i32,
    second: i32,
    ms: i32,
    iso: [32]u8,
    iso_len: usize,
    legacy: [80]u8,
    legacy_len: usize,
    slash: [32]u8,
    slash_len: usize,
};

noinline fn fill(data: []Input, profile: Profile) !void {
    var prng = std.Random.DefaultPrng.init(0x2026_017);
    const random = prng.random();
    for (data) |*input| {
        input.ts = switch (profile) {
            .full_range => random.intRangeAtMost(i64, after.Constants.MIN_TIME, after.Constants.MAX_TIME),
            .history => random.intRangeAtMost(i64, 946684800000, 1893456000000), // 2000–2030
            .future_clustered => random.intRangeAtMost(i64, 7258118400000, 7289654399999), // 2200
            .future_random => random.intRangeAtMost(i64, 4102444800000, 256506912000000), // 2100–10098
        };
        const c = before.CalendarUtil.timestampToComponents(input.ts, .utc);
        input.year = c.year;
        input.month = c.month;
        input.day = c.day;
        input.hour = c.hour;
        input.minute = c.minute;
        input.second = c.second;
        input.ms = c.millisecond;
        const iso = try before.ZDate.fromTimestamp(input.ts).toISOString(allocator);
        defer allocator.free(iso);
        @memcpy(input.iso[0..iso.len], iso);
        input.iso_len = iso.len;
        // Legacy parsers use normal positive years; strings vary by sample.
        const year: u32 = @intCast(2000 + @mod(c.year, 30));
        const month = before.locales.en.month_names_short[@intCast(c.month)];
        const legacy = try std.fmt.bufPrint(&input.legacy, "{s} {d} {d} {d}:{d}:00 GMT", .{ month, @as(u32, @intCast(c.day)), year, @as(u32, @intCast(c.hour)), @as(u32, @intCast(c.minute)) });
        input.legacy_len = legacy.len;
        const slash = try std.fmt.bufPrint(&input.slash, "{d}/{d}/{d}", .{ @as(u32, @intCast(c.month + 1)), @as(u32, @intCast(@min(c.day, 28))), year });
        input.slash_len = slash.len;
    }
}

fn components(comptime Lib: type, input: Input) Lib.DateComponents {
    return .{ .year = input.year, .month = input.month, .day = input.day, .hour = input.hour, .minute = input.minute, .second = input.second, .millisecond = input.ms };
}

fn stringResult(s: []u8) u64 {
    defer allocator.free(s);
    // Consume every byte, equally for both versions.
    return std.hash.Wyhash.hash(0, s);
}

noinline fn kernel(comptime Lib: type, comptime case: Case, data: []const Input, repeats: usize) !u64 {
    var checksum: u64 = 0;
    for (0..repeats) |_| {
        for (data) |input| {
            const date = Lib.ZDate.fromTimestamp(input.ts);
            const value: i64 = switch (case) {
                .utc_day => date.getUTCDay().?,
                .utc_hour => date.getUTCHours().?,
                .utc_minute => date.getUTCMinutes().?,
                .utc_second => date.getUTCSeconds().?,
                .utc_ms => date.getUTCMilliseconds().?,
                .utc_ymd => @as(i64, date.getUTCFullYear().?) + date.getUTCMonth().? + date.getUTCDate().?,
                .local_day => date.getDay().?,
                .local_hour => date.getHours().?,
                .calendar => blk: {
                    const c = Lib.CalendarUtil.timestampToComponents(input.ts, .utc);
                    break :blk @as(i64, c.year) + c.month + c.day + c.hour + c.minute + c.second + c.millisecond;
                },
                .components => Lib.CalendarUtil.componentsToTimestamp(components(Lib, input), .utc),
                .normalize => blk: {
                    var c = components(Lib, input);
                    c.day += 90;
                    Lib.CalendarUtil.normalizeComponents(&c);
                    break :blk @as(i64, c.year) + c.month + c.day + c.hour;
                },
                .set_utc_hour => blk: {
                    var d = date;
                    break :blk d.setUTCHours(25, null, null, null);
                },
                .set_utc_ms => blk: {
                    var d = date;
                    break :blk d.setUTCMilliseconds(1500);
                },
                .set_local_hour => blk: {
                    var d = date;
                    break :blk d.setHours(25, null, null, null);
                },
                .iso => @bitCast(stringResult(try date.toISOString(allocator))),
                .time_string => @bitCast(stringResult(try date.toTimeString(allocator))),
                .locale_time => @bitCast(stringResult(try date.toLocaleTimeString(allocator, Lib.locales.en))),
                .locale_numeric => @bitCast(stringResult(try date.toLocaleString(allocator, Lib.locales.en))),
                .locale_long => @bitCast(stringResult(try date.toLocaleStringStyle(allocator, Lib.locales.es, .long))),
                .parse_iso => Lib.ZDate.parse(input.iso[0..input.iso_len]),
                .parse_legacy => Lib.ZDate.parse(input.legacy[0..input.legacy_len]),
                .parse_slash => Lib.ZDate.parse(input.slash[0..input.slash_len]),
                .offset => date.getTimezoneOffset().?,
            };
            checksum +%= @as(u64, @bitCast(value));
        }
    }
    return checksum;
}

fn measure(comptime Lib: type, comptime case: Case, io: std.Io, data: []const Input, repeats: usize) !struct { ns: i96, checksum: u64 } {
    const start = std.Io.Clock.awake.now(io);
    const checksum = try kernel(Lib, case, data, repeats);
    const end = std.Io.Clock.awake.now(io);
    return .{ .ns = start.durationTo(end).toNanoseconds(), .checksum = checksum };
}

fn compare(comptime case: Case, profile: Profile, io: std.Io, data: []const Input) !void {
    // Warm both paths; adapt repetitions until even the faster path takes >=15ms.
    var repeats: usize = 1;
    while (true) {
        const x = try measure(before, case, io, data, repeats);
        const y = try measure(after, case, io, data, repeats);
        if (x.checksum != y.checksum) return error.ResultMismatch;
        if (@min(x.ns, y.ns) >= 15_000_000 or repeats >= 8192) break;
        repeats *= 2;
    }
    for (0..rounds) |round| {
        // Alternate execution order to reduce drift/order bias.
        const x = if (round % 2 == 0) try measure(before, case, io, data, repeats) else {
            const y = try measure(after, case, io, data, repeats);
            const x = try measure(before, case, io, data, repeats);
            if (x.checksum != y.checksum) return error.ResultMismatch;
            std.debug.print("RESULT,{s},{s},{d},{d},{d},{d},{d}\n", .{ @tagName(case), @tagName(profile), round, x.ns, y.ns, repeats * data.len, x.checksum });
            continue;
        };
        const y = try measure(after, case, io, data, repeats);
        if (x.checksum != y.checksum) return error.ResultMismatch;
        std.debug.print("RESULT,{s},{s},{d},{d},{d},{d},{d}\n", .{ @tagName(case), @tagName(profile), round, x.ns, y.ns, repeats * data.len, x.checksum });
    }
}

const CountingAllocator = struct {
    allocations: usize = 0,
    bytes: usize = 0,
    fn get(self: *CountingAllocator) std.mem.Allocator {
        return .{ .ptr = self, .vtable = &.{ .alloc = alloc, .resize = resize, .remap = remap, .free = free } };
    }
    fn alloc(ptr: *anyopaque, len: usize, alignment: std.mem.Alignment, ret: usize) ?[*]u8 {
        const self: *CountingAllocator = @ptrCast(@alignCast(ptr));
        const result = allocator.rawAlloc(len, alignment, ret) orelse return null;
        self.allocations += 1;
        self.bytes += len;
        return result;
    }
    fn resize(_: *anyopaque, memory: []u8, alignment: std.mem.Alignment, len: usize, ret: usize) bool {
        return allocator.rawResize(memory, alignment, len, ret);
    }
    fn remap(_: *anyopaque, memory: []u8, alignment: std.mem.Alignment, len: usize, ret: usize) ?[*]u8 {
        return allocator.rawRemap(memory, alignment, len, ret);
    }
    fn free(_: *anyopaque, memory: []u8, alignment: std.mem.Alignment, ret: usize) void {
        allocator.rawFree(memory, alignment, ret);
    }
};

fn allocationCount(comptime Lib: type, comptime case: Case) !CountingAllocator {
    var counter: CountingAllocator = .{};
    const date = Lib.ZDate.fromTimestamp(1718460000000);
    const s = switch (case) {
        .locale_numeric => try date.toLocaleString(counter.get(), Lib.locales.en),
        .locale_long => try date.toLocaleStringStyle(counter.get(), Lib.locales.es, .long),
        .locale_time => try date.toLocaleTimeString(counter.get(), Lib.locales.en),
        else => unreachable,
    };
    counter.get().free(s);
    return counter;
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const data = try allocator.alloc(Input, n);
    defer allocator.free(data);
    std.debug.print("META,zig=0.17.0,samples={d},rounds={d},allocator=smp,clock=awake\n", .{ n, rounds });
    try fill(data, .full_range);
    inline for (.{ Case.utc_day, .utc_hour, .utc_minute, .utc_second, .utc_ms, .utc_ymd, .calendar, .components, .normalize, .set_utc_hour, .set_utc_ms, .iso, .parse_iso }) |case| {
        try compare(case, .full_range, io, data);
    }
    before.ZDate.setLocalTimezone(try before.Timezone.parseBytes(allocator, before.zones.america_santiago));
    defer before.ZDate.clearLocalTimezone();
    after.ZDate.setLocalTimezone(try after.Timezone.parseBytes(allocator, after.zones.america_santiago));
    defer after.ZDate.clearLocalTimezone();
    for ([_]Profile{ Profile.history, .future_clustered, .future_random }) |profile| {
        try fill(data, profile);
        inline for (.{ Case.local_day, .local_hour, .set_local_hour, .offset, .locale_numeric }) |case| {
            try compare(case, profile, io, data);
        }
    }
    try fill(data, .history);
    inline for (.{ Case.time_string, .locale_time, .locale_long, .parse_legacy, .parse_slash }) |case| {
        try compare(case, .history, io, data);
    }
    inline for (.{ Case.locale_numeric, .locale_long, .locale_time }) |case| {
        const x = try allocationCount(before, case);
        const y = try allocationCount(after, case);
        std.debug.print("ALLOC,{s},{d},{d},{d},{d}\n", .{ @tagName(case), x.allocations, y.allocations, x.bytes, y.bytes });
    }
}
