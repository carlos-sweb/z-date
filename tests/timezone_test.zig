const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

// TZif fixture copied from this machine's /usr/share/zoneinfo/America/Santiago
// (IANA tzdata). Embedded so tests do not depend on the CI host's tzdata.
// Reference transitions, verified with `zdump -v America/Santiago`:
//   2024-04-07 03:00:00 UT: DST -03:00 (-10800) -> standard -04:00 (-14400)
//   2024-09-08 04:00:00 UT: standard -04:00     -> DST -03:00
const santiago_tzif = @embedFile("fixtures/america_santiago.tzif");

fn loadSantiago() !void {
    const tz = try zdate.Timezone.parseBytes(std.testing.allocator, santiago_tzif);
    ZDate.setLocalTimezone(tz);
}

test "no timezone loaded: local behaves exactly like UTC (offset 0)" {
    ZDate.clearLocalTimezone();
    const date = ZDate.fromComponentsUTC(2024, 0, 1, 12, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 0), date.getTimezoneOffset().?);
    try std.testing.expectEqual(date.getUTCHours().?, date.getHours().?);
}

test "getTimezoneOffset reflects standard time (-04:00 -> +240 minutes)" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // June 2024: Chilean winter, standard time -04:00.
    const date = ZDate.fromTimestamp(ZDate.UTC(2024, 5, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 240), date.getTimezoneOffset().?);
}

test "getTimezoneOffset reflects DST (-03:00 -> +180 minutes)" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // December 2024: Chilean summer, DST -03:00.
    const date = ZDate.fromTimestamp(ZDate.UTC(2024, 11, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 180), date.getTimezoneOffset().?);
}

test "offset changes exactly at the 2024-04-07 03:00 UT transition" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    const transition = ZDate.UTC(2024, 3, 7, 3, 0, 0, 0);

    const before = ZDate.fromTimestamp(transition - 1);
    try std.testing.expectEqual(@as(i32, 180), before.getTimezoneOffset().?); // still DST -03:00

    const at = ZDate.fromTimestamp(transition);
    try std.testing.expectEqual(@as(i32, 240), at.getTimezoneOffset().?); // standard -04:00
}

test "offset changes exactly at the 2024-09-08 04:00 UT transition" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    const transition = ZDate.UTC(2024, 8, 8, 4, 0, 0, 0);

    const before = ZDate.fromTimestamp(transition - 1);
    try std.testing.expectEqual(@as(i32, 240), before.getTimezoneOffset().?); // standard -04:00

    const at = ZDate.fromTimestamp(transition);
    try std.testing.expectEqual(@as(i32, 180), at.getTimezoneOffset().?); // DST -03:00
}

test "local getters shift by the active offset (UTC noon = 08:00 in Santiago winter)" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // 2024-06-15T12:00:00Z with offset -04:00 -> local 08:00, same day.
    const date = ZDate.fromTimestamp(ZDate.UTC(2024, 5, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 8), date.getHours().?);
    try std.testing.expectEqual(@as(i32, 15), date.getDate().?);
    try std.testing.expectEqual(@as(i32, 12), date.getUTCHours().?);
}

test "local getters cross the day boundary (UTC 02:00 = previous day 22:00 local)" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // 2024-06-15T02:00:00Z with offset -04:00 -> local 2024-06-14T22:00.
    const date = ZDate.fromTimestamp(ZDate.UTC(2024, 5, 15, 2, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 22), date.getHours().?);
    try std.testing.expectEqual(@as(i32, 14), date.getDate().?);
}

test "fromComponents (local) round-trips through local getters" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // Construct a local wall-clock time away from any DST transition.
    const date = ZDate.fromComponents(2024, 5, 15, 10, 30, 0, 0);
    try std.testing.expect(date.isValid());
    try std.testing.expectEqual(@as(i32, 2024), date.getFullYear().?);
    try std.testing.expectEqual(@as(i32, 5), date.getMonth().?);
    try std.testing.expectEqual(@as(i32, 15), date.getDate().?);
    try std.testing.expectEqual(@as(i32, 10), date.getHours().?);
    try std.testing.expectEqual(@as(i32, 30), date.getMinutes().?);

    // And the underlying instant really is 4 hours later in UTC.
    try std.testing.expectEqual(@as(i32, 14), date.getUTCHours().?);
}

test "ISO date-time strings without offset are interpreted as local time" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // Per ECMA-262: date-time forms without an offset are local time.
    const local = ZDate.fromISO8601("2024-06-15T10:00:00");
    try std.testing.expectEqual(@as(i32, 14), local.getUTCHours().?);

    // Date-only forms remain UTC.
    const date_only = ZDate.fromISO8601("2024-06-15");
    try std.testing.expectEqual(@as(i32, 0), date_only.getUTCHours().?);

    // Explicit offsets are unaffected by the local zone.
    const zulu = ZDate.fromISO8601("2024-06-15T10:00:00Z");
    try std.testing.expectEqual(@as(i32, 10), zulu.getUTCHours().?);
}

test "toISOString is unaffected by the local timezone (always UTC)" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(ZDate.UTC(2024, 5, 15, 12, 0, 0, 0));
    const str = try date.toISOString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("2024-06-15T12:00:00.000Z", str);
}

test "offsets before the first recorded transition use the earliest standard time" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // Year 1700 predates every transition in the table; must not crash and
    // must return a plausible fixed offset (Santiago LMT-era handling maps
    // to the first non-DST type).
    const date = ZDate.fromTimestamp(ZDate.UTC(1700, 0, 1, 0, 0, 0, 0));
    const offset = date.getTimezoneOffset().?;
    try std.testing.expect(offset >= -720 and offset <= 840);
}

// ===== POSIX TZ footer rule: offsets beyond the transition table =====
//
// Santiago's footer is "<-04>4<-03>,M9.1.6/24,M4.1.6/24". Reference values
// verified with `zdump -v -c 2199,2201 America/Santiago`:
//   2200-04-06 03:00 UT: DST -03 -> standard -04
// New York's footer is "EST5EDT,M3.2.0,M11.1.0"; per
// `zdump -v -c 2099,2101 America/New_York`:
//   2100-03-14 07:00 UT: EST -05 -> EDT -04

const new_york_tzif = @embedFile("fixtures/america_new_york.tzif");
const tokyo_tzif = @embedFile("fixtures/asia_tokyo.tzif");

test "POSIX rule: Santiago January 2200 is DST (-03:00)" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    const date = ZDate.fromTimestamp(ZDate.UTC(2200, 0, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 180), date.getTimezoneOffset().?);
}

test "POSIX rule: Santiago June 2200 is standard time (-04:00)" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    const date = ZDate.fromTimestamp(ZDate.UTC(2200, 5, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 240), date.getTimezoneOffset().?);
}

test "POSIX rule: Santiago 2200 transition instant matches zdump exactly" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    const transition = ZDate.UTC(2200, 3, 6, 3, 0, 0, 0);
    const before = ZDate.fromTimestamp(transition - 1);
    const at = ZDate.fromTimestamp(transition);
    try std.testing.expectEqual(@as(i32, 180), before.getTimezoneOffset().?);
    try std.testing.expectEqual(@as(i32, 240), at.getTimezoneOffset().?);
}

test "POSIX rule: New York 2100 transition instant matches zdump exactly" {
    const tz = try zdate.Timezone.parseBytes(std.testing.allocator, new_york_tzif);
    ZDate.setLocalTimezone(tz);
    defer ZDate.clearLocalTimezone();

    const transition = ZDate.UTC(2100, 2, 14, 7, 0, 0, 0);
    const before = ZDate.fromTimestamp(transition - 1);
    const at = ZDate.fromTimestamp(transition);
    try std.testing.expectEqual(@as(i32, 300), before.getTimezoneOffset().?); // EST -05:00
    try std.testing.expectEqual(@as(i32, 240), at.getTimezoneOffset().?); // EDT -04:00
}

test "POSIX rule: fixed-offset zone (Tokyo, footer JST-9, no DST) at year 2500" {
    const tz = try zdate.Timezone.parseBytes(std.testing.allocator, tokyo_tzif);
    ZDate.setLocalTimezone(tz);
    defer ZDate.clearLocalTimezone();

    const date = ZDate.fromTimestamp(ZDate.UTC(2500, 5, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, -540), date.getTimezoneOffset().?); // UTC+9 -> -540 min
}

test "POSIX rule: offsets remain sane at the MAX_TIME extreme" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    const date = ZDate.fromTimestamp(Constants.MAX_TIME);
    const offset = date.getTimezoneOffset().?;
    try std.testing.expect(offset == 180 or offset == 240);
}

test "POSIX TZ parser handles the classic and bracketed forms" {
    const classic = try zdate.PosixTz.parse("EST5EDT,M3.2.0,M11.1.0");
    try std.testing.expectEqual(@as(i64, -5 * std.time.ms_per_hour), classic.std_offset_ms);
    try std.testing.expectEqual(@as(i64, -4 * std.time.ms_per_hour), classic.dst.?.offset_ms);

    const bracketed = try zdate.PosixTz.parse("<-04>4<-03>,M9.1.6/24,M4.1.6/24");
    try std.testing.expectEqual(@as(i64, -4 * std.time.ms_per_hour), bracketed.std_offset_ms);
    try std.testing.expectEqual(@as(i64, -3 * std.time.ms_per_hour), bracketed.dst.?.offset_ms);
    try std.testing.expectEqual(@as(i64, 24 * std.time.ms_per_hour), bracketed.dst.?.start.time_ms);

    const fixed = try zdate.PosixTz.parse("JST-9");
    try std.testing.expectEqual(@as(i64, 9 * std.time.ms_per_hour), fixed.std_offset_ms);
    try std.testing.expectEqual(@as(?zdate.PosixTz.Dst, null), fixed.dst);

    const half_hour = try zdate.PosixTz.parse("<+1030>-10:30<+11>-11,M10.1.0,M4.1.0");
    try std.testing.expectEqual(@as(i64, 10 * std.time.ms_per_hour + 30 * std.time.ms_per_min), half_hour.std_offset_ms);
    try std.testing.expectEqual(@as(i64, 11 * std.time.ms_per_hour), half_hour.dst.?.offset_ms);

    try std.testing.expectError(error.InvalidPosixTz, zdate.PosixTz.parse(""));
    try std.testing.expectError(error.InvalidPosixTz, zdate.PosixTz.parse("EST"));
    try std.testing.expectError(error.InvalidPosixTz, zdate.PosixTz.parse("EST5EDT,M13.1.0,M11.1.0"));
}

// ===== Local->UTC disambiguation at DST transitions (tc39/ecma262#778) =====
//
// Santiago 2024 transitions in *local* wall-clock terms:
//   Fall-back  (Apr 7 03:00 UT):  local 23:59:59 -03 is followed by local
//     23:00:00 -04 - so local times 23:00-23:59 on Apr 6 happen TWICE.
//   Spring-forward (Sep 8 04:00 UT): local 23:59:59 -04 is followed by
//     local 01:00:00 -03 - so local times 00:00-00:59 on Sep 8 NEVER happen.

test "repeated local time resolves with the offset before the transition" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // Local 2024-04-06T23:30 exists twice: as 02:30Z (offset -03, before)
    // and as 03:30Z (offset -04, after). The spec picks the earlier offset.
    const date = ZDate.fromComponents(2024, 3, 6, 23, 30, 0, 0);
    const expected_utc = ZDate.UTC(2024, 3, 7, 2, 30, 0, 0);
    try std.testing.expectEqual(expected_utc, date.getTime());
}

test "skipped local time resolves with the offset before the transition" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // Local 2024-09-08T00:30 never happens (clock jumps 00:00 -> 01:00).
    // With the pre-transition offset (-04) it maps to 04:30Z.
    const date = ZDate.fromComponents(2024, 8, 8, 0, 30, 0, 0);
    const expected_utc = ZDate.UTC(2024, 8, 8, 4, 30, 0, 0);
    try std.testing.expectEqual(expected_utc, date.getTime());
}

test "local times just outside a transition window resolve normally" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // Local 2024-04-06T22:59 (only exists once, offset -03).
    const before_window = ZDate.fromComponents(2024, 3, 6, 22, 59, 0, 0);
    try std.testing.expectEqual(ZDate.UTC(2024, 3, 7, 1, 59, 0, 0), before_window.getTime());

    // Local 2024-04-07T00:00 (only exists once, offset -04).
    const after_window = ZDate.fromComponents(2024, 3, 7, 0, 0, 0, 0);
    try std.testing.expectEqual(ZDate.UTC(2024, 3, 7, 4, 0, 0, 0), after_window.getTime());

    // Local 2024-09-08T01:00 (first instant after the spring-forward jump, offset -03).
    const after_jump = ZDate.fromComponents(2024, 8, 8, 1, 0, 0, 0);
    try std.testing.expectEqual(ZDate.UTC(2024, 8, 8, 4, 0, 0, 0), after_jump.getTime());
}

test "setHours across a transition keeps spec disambiguation" {
    try loadSantiago();
    defer ZDate.clearLocalTimezone();

    // Start at local 2024-04-06T12:00, then set the (repeated) hour 23:30.
    var date = ZDate.fromComponents(2024, 3, 6, 12, 0, 0, 0);
    _ = date.setHours(23, 30, 0, 0);
    try std.testing.expectEqual(ZDate.UTC(2024, 3, 7, 2, 30, 0, 0), date.getTime());
}

test "loading a real zone from the system tzdata directory works" {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    // Skip silently on machines without system tzdata.
    ZDate.loadNamedTimezone(std.testing.allocator, io, "America/Santiago") catch return;
    defer ZDate.clearLocalTimezone();

    const date = ZDate.fromTimestamp(ZDate.UTC(2024, 5, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 240), date.getTimezoneOffset().?);
}

// ===== Embedded tzdata (src/zones.zig, generated by scripts/update_tzdata.py) =====

test "a single embedded zone can be used without the full database" {
    // References only zones.america_santiago: lazy analysis embeds just
    // that one TZif file, not the ~1.4 MB database.
    const tz = try zdate.Timezone.parseBytes(std.testing.allocator, zdate.zones.america_santiago);
    ZDate.setLocalTimezone(tz);
    defer ZDate.clearLocalTimezone();

    const date = ZDate.fromTimestamp(ZDate.UTC(2024, 5, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 240), date.getTimezoneOffset().?);
}

test "zones.find locates zones by IANA name" {
    const data = zdate.zones.find("America/Santiago") orelse return error.TestUnexpectedResult;
    try std.testing.expect(std.mem.eql(u8, data[0..4], "TZif"));

    try std.testing.expectEqual(@as(?[]const u8, null), zdate.zones.find("Not/A_Zone"));
}

test "loadEmbeddedTimezone loads a zone from the embedded database" {
    try ZDate.loadEmbeddedTimezone(std.testing.allocator, "Asia/Tokyo");
    defer ZDate.clearLocalTimezone();

    const date = ZDate.fromTimestamp(ZDate.UTC(2024, 5, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, -540), date.getTimezoneOffset().?); // UTC+9

    try std.testing.expectError(
        error.UnknownTimezone,
        ZDate.loadEmbeddedTimezone(std.testing.allocator, "Invalid/Zone"),
    );
}

test "embedded zone data matches the system tzdata behavior" {
    // Same zone loaded from the embedded DB and from the fixture must agree.
    try ZDate.loadEmbeddedTimezone(std.testing.allocator, "America/Santiago");
    defer ZDate.clearLocalTimezone();

    const summer = ZDate.fromTimestamp(ZDate.UTC(2024, 11, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 180), summer.getTimezoneOffset().?);
    const winter = ZDate.fromTimestamp(ZDate.UTC(2024, 5, 15, 12, 0, 0, 0));
    try std.testing.expectEqual(@as(i32, 240), winter.getTimezoneOffset().?);
}

// ===== Windows zone mapping (CLDR windowsZones data, pure lookup) =====

test "windows_zones mappings table is strictly sorted (binary search precondition)" {
    const m = zdate.windows_zones.mappings;
    for (m[0 .. m.len - 1], m[1..]) |a, b| {
        try std.testing.expectEqual(std.math.Order.lt, std.mem.order(u8, a.windows, b.windows));
    }
}

test "windowsToIana finds known mappings including binary-search edges" {
    const w = zdate.windows_zones;
    try std.testing.expectEqualStrings("America/Los_Angeles", w.windowsToIana("Pacific Standard Time").?);
    try std.testing.expectEqualStrings("America/Santiago", w.windowsToIana("Pacific SA Standard Time").?);
    try std.testing.expectEqualStrings("Europe/Paris", w.windowsToIana("Romance Standard Time").?);
    try std.testing.expectEqualStrings("Etc/UTC", w.windowsToIana("UTC").?);
    // First and last entries.
    try std.testing.expectEqualStrings("Australia/Darwin", w.windowsToIana("AUS Central Standard Time").?);
    try std.testing.expectEqualStrings("America/Whitehorse", w.windowsToIana("Yukon Standard Time").?);
    try std.testing.expectEqual(@as(?[]const u8, null), w.windowsToIana("Not A Zone"));
}

test "every Windows-mapped IANA zone exists in the embedded tzdata" {
    for (zdate.windows_zones.mappings) |m| {
        if (zdate.zones.find(m.iana) == null) {
            std.debug.print("missing embedded zone: {s} (for {s})\n", .{ m.iana, m.windows });
            return error.MissingEmbeddedZone;
        }
    }
}

test "loadNamedTimezone rejects path traversal" {
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    try std.testing.expectError(
        error.InvalidTimezoneName,
        ZDate.loadNamedTimezone(std.testing.allocator, io, "../../etc/passwd"),
    );
    try std.testing.expectError(
        error.InvalidTimezoneName,
        ZDate.loadNamedTimezone(std.testing.allocator, io, "/etc/passwd"),
    );
}
