const std = @import("std");
const zdate = @import("zdate");
const locales = zdate.locales;

// Every Day.js locale (https://github.com/iamkun/dayjs) is ported as its own
// file under src/locales/, registered as its own `pub const` in
// zdate.locales — never as an array or map. Referencing a single locale
// (e.g. `locales.fr`) therefore only pulls that one file into analysis;
// this file's "force-analyze every locale" test is the one place that
// deliberately touches all of them at once, to catch structural mistakes
// (wrong array length, empty strings, wrong field name) across the whole
// set in one pass.

test "force-analyze every registered locale: valid shape, no empty fields" {
    @setEvalBranchQuota(1_000_000);
    const info = @typeInfo(locales).@"struct";
    var count: usize = 0;
    inline for (info.decl_names) |decl_name| {
        const loc: zdate.Locale = @field(locales, decl_name);
        inline for (loc.month_names) |m| try std.testing.expect(m.len > 0);
        inline for (loc.month_names_short) |m| try std.testing.expect(m.len > 0);
        inline for (loc.day_names) |d| try std.testing.expect(d.len > 0);
        inline for (loc.day_names_short) |d| try std.testing.expect(d.len > 0);
        try std.testing.expect(loc.am_label.len > 0);
        try std.testing.expect(loc.pm_label.len > 0);
        count += 1;
    }
    // 143 Day.js locales + en_us + es_cl (two pre-existing custom locales
    // that are not Day.js keys).
    try std.testing.expect(count >= 145);
}

test "generic en matches Day.js core defaults (US-style, 12h)" {
    try std.testing.expectEqualStrings("January", locales.en.month_names[0]);
    try std.testing.expectEqualStrings("Sunday", locales.en.day_names[0]);
    try std.testing.expectEqual(.mdy, locales.en.date_order);
    try std.testing.expectEqual(@as(u8, '/'), locales.en.date_separator);
    try std.testing.expect(!locales.en.time_24h);
}

test "fr uses DMY with '/' and a 24-hour clock" {
    try std.testing.expectEqualStrings("janvier", locales.fr.month_names[0]);
    try std.testing.expectEqualStrings("dimanche", locales.fr.day_names[0]);
    try std.testing.expectEqual(.dmy, locales.fr.date_order);
    try std.testing.expectEqual(@as(u8, '/'), locales.fr.date_separator);
    try std.testing.expect(locales.fr.time_24h);
}

test "ja uses YMD with '/' and a real meridiem pair" {
    try std.testing.expectEqualStrings("1月", locales.ja.month_names[0]);
    try std.testing.expectEqualStrings("日曜日", locales.ja.day_names[0]);
    try std.testing.expectEqual(.ymd, locales.ja.date_order);
    try std.testing.expectEqualStrings("午前", locales.ja.am_label);
    try std.testing.expectEqualStrings("午後", locales.ja.pm_label);
}

test "de uses full German month/day names" {
    try std.testing.expectEqualStrings("Januar", locales.de.month_names[0]);
    try std.testing.expectEqualStrings("Sonntag", locales.de.day_names[0]);
}

test "ru uses Cyrillic month/day names" {
    try std.testing.expectEqualStrings("воскресенье", locales.ru.day_names[0]);
}

test "ar (Arabic) and its regional variants are independently registered" {
    try std.testing.expectEqualStrings("الأحد", locales.ar.day_names[0]);
    try std.testing.expectEqualStrings("الأحد", locales.ar_dz.day_names[0]);
    try std.testing.expectEqualStrings("الأحد", locales.ar_sa.day_names[0]);
}

test "sr (Latin) and sr_cyrl (Cyrillic) use genuinely different scripts" {
    try std.testing.expectEqualStrings("Nedelja", locales.sr.day_names[0]);
    try std.testing.expectEqualStrings("Недеља", locales.sr_cyrl.day_names[0]);
    try std.testing.expect(!std.mem.eql(u8, locales.sr.day_names[0], locales.sr_cyrl.day_names[0]));
}

test "zh-cn, zh-hk, zh-tw are independently registered Chinese variants" {
    try std.testing.expectEqualStrings("一月", locales.zh_cn.month_names[0]);
    try std.testing.expectEqual(.ymd, locales.zh_cn.date_order);
    try std.testing.expect(locales.zh_hk.month_names[0].len > 0);
    try std.testing.expect(locales.zh_tw.month_names[0].len > 0);
    try std.testing.expect(locales.zh.month_names[0].len > 0);
}

test "pt_br was corrected against authoritative Day.js data" {
    try std.testing.expectEqualStrings("janeiro", locales.pt_br.month_names[0]);
    try std.testing.expectEqualStrings("domingo", locales.pt_br.day_names[0]);
    try std.testing.expectEqual(.dmy, locales.pt_br.date_order);
    try std.testing.expect(locales.pt_br.time_24h);
}

test "toLocaleDateString works end-to-end with a freshly ported locale" {
    const allocator = std.testing.allocator;
    const ZDate = zdate.ZDate;
    const date = ZDate.fromComponentsUTC(2024, 0, 5, 0, 0, 0, 0);

    const fr_str = try date.toLocaleDateString(allocator, locales.fr);
    defer allocator.free(fr_str);
    try std.testing.expectEqualStrings("05/01/2024", fr_str);

    const ja_str = try date.toLocaleDateString(allocator, locales.ja);
    defer allocator.free(ja_str);
    try std.testing.expectEqualStrings("2024/01/05", ja_str);
}
