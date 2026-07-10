const Locale = @import("../locale.zig").Locale;

/// Hungarian locale: YYYY.MM.DD., 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "január",   "február", "március", "április",
        "május",    "június",  "július",  "augusztus",
        "szeptember", "október", "november", "december",
    },
    .month_names_short = .{
        "jan", "feb", "márc", "ápr", "máj", "jún",
        "júl", "aug", "szept", "okt", "nov", "dec",
    },
    .day_names = .{
        "vasárnap", "hétfő",   "kedd",   "szerda",
        "csütörtök", "péntek", "szombat",
    },
    .day_names_short = .{
        "vas", "hét", "kedd", "sze", "csüt", "pén", "szo",
    },
    .date_order = .ymd,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
