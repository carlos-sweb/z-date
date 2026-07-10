const Locale = @import("../locale.zig").Locale;

/// Azerbaijani locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "yanvar",   "fevral",   "mart",    "aprel",
        "may",      "iyun",     "iyul",    "avqust",
        "sentyabr", "oktyabr",  "noyabr",  "dekabr",
    },
    .month_names_short = .{
        "yan", "fev", "mar", "apr", "may", "iyn",
        "iyl", "avq", "sen", "okt", "noy", "dek",
    },
    .day_names = .{
        "Bazar", "Bazar ertəsi", "Çərşənbə axşamı", "Çərşənbə",
        "Cümə axşamı", "Cümə", "Şənbə",
    },
    .day_names_short = .{
        "Baz", "BzE", "ÇAx", "Çər", "CAx", "Cüm", "Şən",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
