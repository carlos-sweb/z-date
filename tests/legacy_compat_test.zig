const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const Constants = zdate.Constants;

// ===== Point 3: extended Date.parse() legacy grammar =====

test "parse: 'Month DD, YYYY' with no day-of-week (full month name)" {
    const timestamp = ZDate.parse("January 1, 2024");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
    const date = ZDate.fromTimestamp(timestamp);
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate().?);
}

test "parse: 'Month DD YYYY' with no comma, abbreviated month" {
    const timestamp = ZDate.parse("Dec 25 2024");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
    const date = ZDate.fromTimestamp(timestamp);
    try std.testing.expectEqual(@as(i32, 11), date.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 25), date.getUTCDate().?);
}

test "parse: 'DD Month YYYY' with no day-of-week" {
    const timestamp = ZDate.parse("1 January 2024");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
    const date = ZDate.fromTimestamp(timestamp);
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear().?);
    try std.testing.expectEqual(@as(i32, 0), date.getUTCMonth().?);
    try std.testing.expectEqual(@as(i32, 1), date.getUTCDate().?);
}

test "parse: RFC 2822/1123-style bare numeric offset" {
    const timestamp = ZDate.parse("Mon, 01 Jan 2024 10:00:00 +0200");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
    const date = ZDate.fromTimestamp(timestamp);
    try std.testing.expectEqual(@as(i32, 8), date.getUTCHours().?);
}

test "parse: RFC 2822-style negative offset" {
    const timestamp = ZDate.parse("Mon, 01 Jan 2024 10:00:00 -0500");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
    const date = ZDate.fromTimestamp(timestamp);
    try std.testing.expectEqual(@as(i32, 15), date.getUTCHours().?);
}

test "parse: bare 'UTC' token is treated like 'GMT' (zero offset)" {
    const timestamp = ZDate.parse("Mon, 01 Jan 2024 10:00:00 UTC");
    try std.testing.expect(timestamp != Constants.INVALID_TIME);
    const date = ZDate.fromTimestamp(timestamp);
    try std.testing.expectEqual(@as(i32, 10), date.getUTCHours().?);
}

test "parse: still rejects garbage even with the extended grammar" {
    try std.testing.expectEqual(Constants.INVALID_TIME, ZDate.parse("Notamonth 1, 2024"));
    try std.testing.expectEqual(Constants.INVALID_TIME, ZDate.parse("January 1, 2024 extra garbage"));
}

// ===== Point 4: legacy getYear/setYear and toGMTString =====

test "getYear returns full year minus 1900" {
    const date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, 124), date.getYear());
}

test "getYear returns null for Invalid Date" {
    const date = ZDate.fromTimestamp(Constants.INVALID_TIME);
    try std.testing.expectEqual(@as(?i32, null), date.getYear());
}

test "setYear maps two-digit years 0-99 to 1900-1999" {
    var date = ZDate.fromComponentsUTC(2024, 0, 1, 0, 0, 0, 0);
    _ = date.setYear(99);
    try std.testing.expectEqual(@as(i32, 1999), date.getUTCFullYear().?);
}

test "setYear leaves years outside 0-99 untouched" {
    var date = ZDate.fromComponentsUTC(1999, 0, 1, 0, 0, 0, 0);
    _ = date.setYear(2024);
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear().?);
}

test "setYear on an Invalid Date repairs it, like setFullYear (Annex B.2.3 step 2: t=NaN -> +0)" {
    // Previously asserted the opposite ("deliberate deviation") --
    // confirmed against real Node that `new Date(NaN).setYear(2024)`
    // DOES repair the date (getTime() becomes a real timestamp, not
    // NaN), matching Annex B.2.3's own "If t is NaN, set t to +0"
    // step. setYear delegates to the same underlying logic as
    // setFullYear, which was fixed to do this for the exact same
    // spec-mandated reason.
    var date = ZDate.fromTimestamp(Constants.INVALID_TIME);
    const result = date.setYear(2024);
    try std.testing.expectEqual(@as(i32, 2024), date.getUTCFullYear().?);
    try std.testing.expect(result != Constants.INVALID_TIME);
    try std.testing.expect(date.isValid());
}

test "toGMTString matches toUTCString" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 1, 12, 30, 0, 0);

    const gmt_str = try date.toGMTString(allocator);
    defer allocator.free(gmt_str);
    const utc_str = try date.toUTCString(allocator);
    defer allocator.free(utc_str);

    try std.testing.expectEqualStrings(utc_str, gmt_str);
}

test "toGMTString round-trips through parse like toUTCString does" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 5, 15, 12, 30, 45, 0);
    const str = try date.toGMTString(allocator);
    defer allocator.free(str);
    try std.testing.expectEqual(date.getTime(), ZDate.parse(str));
}

// ===== V8 legacy-grammar parity =====
// Expected millisecond values captured from `TZ=UTC node -e 'Date.parse(...)'`
// (no timezone is loaded in this test binary, so local == UTC, matching).

test "parse: slash YMD form '2024/01/15' (V8: 1705276800000)" {
    try std.testing.expectEqual(@as(i64, 1705276800000), ZDate.parse("2024/01/15"));
}

test "parse: time without seconds 'Jan 15 2024 10:30' (V8: 1705314600000)" {
    try std.testing.expectEqual(@as(i64, 1705314600000), ZDate.parse("Jan 15 2024 10:30"));
}

test "parse: PM suffix 'January 1, 2024 5:30 PM' (V8: 1704130200000)" {
    try std.testing.expectEqual(@as(i64, 1704130200000), ZDate.parse("January 1, 2024 5:30 PM"));
}

test "parse: full toString output with parenthesized zone name (V8: 1704123000000)" {
    try std.testing.expectEqual(
        @as(i64, 1704123000000),
        ZDate.parse("Mon Jan 01 2024 15:30:00 GMT+0000 (Coordinated Universal Time)"),
    );
}

test "parse: AM suffix 'Jan 15 2024 10:30 AM' (V8: 1705314600000)" {
    try std.testing.expectEqual(@as(i64, 1705314600000), ZDate.parse("Jan 15 2024 10:30 AM"));
}

test "parse: PM with seconds 'Jan 15 2024 10:30:45 PM' (V8: 1705357845000)" {
    try std.testing.expectEqual(@as(i64, 1705357845000), ZDate.parse("Jan 15 2024 10:30:45 PM"));
}

test "parse: lowercase '12:00 am' means midnight (V8: 1735084800000)" {
    try std.testing.expectEqual(@as(i64, 1735084800000), ZDate.parse("December 25 2024 12:00 am"));
}

test "parse: ISO with space separator '2024-01-15 10:30:00' (V8: 1705314600000)" {
    try std.testing.expectEqual(@as(i64, 1705314600000), ZDate.parse("2024-01-15 10:30:00"));
}

test "parse: extended grammar still rejects malformed strings" {
    const Constants2 = zdate.Constants;
    try std.testing.expectEqual(Constants2.INVALID_TIME, ZDate.parse("Jan 15 2024 25:00 PM"));
    try std.testing.expectEqual(Constants2.INVALID_TIME, ZDate.parse("Jan 15 2024 10:30 XM"));
    try std.testing.expectEqual(Constants2.INVALID_TIME, ZDate.parse("Mon Jan 01 2024 15:30:00 GMT+0000 (Unclosed"));
    try std.testing.expectEqual(Constants2.INVALID_TIME, ZDate.parse("2024/13/45"));
}

test "fuzz: arbitrary byte soup never panics, only returns INVALID_TIME or a value" {
    var prng = std.Random.DefaultPrng.init(0xC0FFEE);
    const random = prng.random();

    // Mutations of realistic inputs plus raw noise, exercising every parser
    // path. The property under test: no crash, ever.
    const seeds = [_][]const u8{
        "2024-01-15T10:30:00.000Z",
        "Mon Jan 01 2024 15:30:00 GMT+0000 (UTC)",
        "January 1, 2024 5:30 PM",
        "2024/01/15",
        "+275760-09-13T00:00:00.000Z",
        "12/31/1999 23:59:59",
    };

    var buf: [64]u8 = undefined;
    var i: usize = 0;
    while (i < 2000) : (i += 1) {
        const seed = seeds[random.uintLessThan(usize, seeds.len)];
        const len = @min(seed.len, buf.len);
        @memcpy(buf[0..len], seed[0..len]);

        // Corrupt 1-4 random bytes.
        const mutations = 1 + random.uintLessThan(usize, 4);
        var m: usize = 0;
        while (m < mutations) : (m += 1) {
            buf[random.uintLessThan(usize, len)] = random.int(u8);
        }

        _ = ZDate.parse(buf[0..len]); // must not panic
    }

    // Pure noise as well.
    i = 0;
    while (i < 500) : (i += 1) {
        const len = 1 + random.uintLessThan(usize, buf.len);
        random.bytes(buf[0..len]);
        _ = ZDate.parse(buf[0..len]); // must not panic
    }
}
