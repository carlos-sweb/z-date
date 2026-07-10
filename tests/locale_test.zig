const std = @import("std");
const zdate = @import("zdate");
const ZDate = zdate.ZDate;
const locales = zdate.locales;

test "toLocaleDateString with null defaults to en_us (MM/DD/YYYY)" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 5, 0, 0, 0, 0);
    const str = try date.toLocaleDateString(allocator, null);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("01/05/2024", str);
}

test "toLocaleDateString with en_us explicitly matches null default" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 5, 0, 0, 0, 0);
    const str = try date.toLocaleDateString(allocator, locales.en_us);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("01/05/2024", str);
}

test "toLocaleDateString with es_cl uses DMY order" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 5, 0, 0, 0, 0);
    const str = try date.toLocaleDateString(allocator, locales.es_cl);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("05/01/2024", str);
}

test "toLocaleDateString with pt_br uses DMY order" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 5, 0, 0, 0, 0);
    const str = try date.toLocaleDateString(allocator, locales.pt_br);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("05/01/2024", str);
}

test "toLocaleTimeString with en_us uses 12-hour clock with AM/PM" {
    const allocator = std.testing.allocator;
    const morning = ZDate.fromComponentsUTC(2024, 0, 5, 9, 5, 3, 0);
    const morning_str = try morning.toLocaleTimeString(allocator, locales.en_us);
    defer allocator.free(morning_str);
    try std.testing.expectEqualStrings("09:05:03 AM", morning_str);

    const afternoon = ZDate.fromComponentsUTC(2024, 0, 5, 15, 5, 3, 0);
    const afternoon_str = try afternoon.toLocaleTimeString(allocator, locales.en_us);
    defer allocator.free(afternoon_str);
    try std.testing.expectEqualStrings("03:05:03 PM", afternoon_str);

    const noon = ZDate.fromComponentsUTC(2024, 0, 5, 12, 0, 0, 0);
    const noon_str = try noon.toLocaleTimeString(allocator, locales.en_us);
    defer allocator.free(noon_str);
    try std.testing.expectEqualStrings("12:00:00 PM", noon_str);

    const midnight = ZDate.fromComponentsUTC(2024, 0, 5, 0, 0, 0, 0);
    const midnight_str = try midnight.toLocaleTimeString(allocator, locales.en_us);
    defer allocator.free(midnight_str);
    try std.testing.expectEqualStrings("12:00:00 AM", midnight_str);
}

test "toLocaleTimeString with es_cl and pt_br uses 24-hour clock" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 5, 15, 5, 3, 0);

    const es_str = try date.toLocaleTimeString(allocator, locales.es_cl);
    defer allocator.free(es_str);
    try std.testing.expectEqualStrings("15:05:03", es_str);

    const pt_str = try date.toLocaleTimeString(allocator, locales.pt_br);
    defer allocator.free(pt_str);
    try std.testing.expectEqualStrings("15:05:03", pt_str);
}

test "toLocaleString combines date and time per locale" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 5, 15, 5, 3, 0);

    const default_str = try date.toLocaleString(allocator, null);
    defer allocator.free(default_str);
    try std.testing.expectEqualStrings("01/05/2024, 03:05:03 PM", default_str);

    const es_str = try date.toLocaleString(allocator, locales.es_cl);
    defer allocator.free(es_str);
    try std.testing.expectEqualStrings("05/01/2024, 15:05:03", es_str);
}

test "locale month/day names are populated correctly" {
    try std.testing.expectEqualStrings("January", locales.en_us.month_names[0]);
    try std.testing.expectEqualStrings("enero", locales.es_cl.month_names[0]);
    try std.testing.expectEqualStrings("janeiro", locales.pt_br.month_names[0]);

    try std.testing.expectEqualStrings("Sunday", locales.en_us.day_names[0]);
    try std.testing.expectEqualStrings("domingo", locales.es_cl.day_names[0]);
    try std.testing.expectEqualStrings("domingo", locales.pt_br.day_names[0]);
}

// ===== Long date style (Intl.DateTimeFormat dateStyle:"long" parity) =====
// Expected strings verified against V8: `d.toLocaleDateString(tag, {dateStyle:"long"})`.

test "long style matches V8 Intl output for en_us" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);
    const str = try date.toLocaleDateStringStyle(allocator, locales.en_us, .long);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("January 15, 2024", str);
}

test "long style matches V8 Intl output for es_cl" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);
    const str = try date.toLocaleDateStringStyle(allocator, locales.es_cl, .long);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("15 de enero de 2024", str);
}

test "long style matches V8 Intl output for ja" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);
    const str = try date.toLocaleDateStringStyle(allocator, locales.ja, .long);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("2024年1月15日", str);
}

test "long style matches V8 Intl output for fr (derived default pattern)" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);
    const str = try date.toLocaleDateStringStyle(allocator, locales.fr, .long);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("15 janvier 2024", str);
}

test "long style matches V8 Intl output for de and ru (explicit patterns)" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);

    const de_str = try date.toLocaleDateStringStyle(allocator, locales.de, .long);
    defer allocator.free(de_str);
    try std.testing.expectEqualStrings("15. Januar 2024", de_str);

    const ru_str = try date.toLocaleDateStringStyle(allocator, locales.ru, .long);
    defer allocator.free(ru_str);
    try std.testing.expectEqualStrings("15 января 2024 г.", ru_str);
}

test "numeric style through the styled API matches toLocaleDateString" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 15, 0, 0, 0, 0);

    const styled = try date.toLocaleDateStringStyle(allocator, locales.es_cl, .numeric);
    defer allocator.free(styled);
    const plain = try date.toLocaleDateString(allocator, locales.es_cl);
    defer allocator.free(plain);
    try std.testing.expectEqualStrings(plain, styled);
}

test "toLocaleStringStyle combines long date with locale time settings" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 15, 14, 30, 5, 0);
    const str = try date.toLocaleStringStyle(allocator, locales.es_cl, .long);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("15 de enero de 2024, 14:30:05", str);
}

test "Finnish uses '.' as time separator (dayjs LT 'HH.mm')" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromComponentsUTC(2024, 0, 15, 14, 30, 5, 0);
    const str = try date.toLocaleTimeString(allocator, locales.fi);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("14.30.05", str);
}

test "long style reports Invalid Date like the other formatters" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(zdate.Constants.INVALID_TIME);
    const str = try date.toLocaleDateStringStyle(allocator, locales.es_cl, .long);
    defer allocator.free(str);
    try std.testing.expectEqualStrings("Invalid Date", str);
}

test "invalid date returns 'Invalid Date' for all locale formatters" {
    const allocator = std.testing.allocator;
    const date = ZDate.fromTimestamp(zdate.Constants.INVALID_TIME);

    const date_str = try date.toLocaleDateString(allocator, locales.es_cl);
    defer allocator.free(date_str);
    try std.testing.expectEqualStrings("Invalid Date", date_str);

    const time_str = try date.toLocaleTimeString(allocator, locales.es_cl);
    defer allocator.free(time_str);
    try std.testing.expectEqualStrings("Invalid Date", time_str);

    const full_str = try date.toLocaleString(allocator, locales.es_cl);
    defer allocator.free(full_str);
    try std.testing.expectEqualStrings("Invalid Date", full_str);
}
