const Locale = @import("../locale.zig").Locale;

/// Icelandic locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "janúar",   "febrúar", "mars",      "apríl",
        "maí",      "júní",    "júlí",      "ágúst",
        "september", "október", "nóvember", "desember",
    },
    .month_names_short = .{
        "jan", "feb", "mar", "apr", "maí", "jún",
        "júl", "ágú", "sep", "okt", "nóv", "des",
    },
    .day_names = .{
        "sunnudagur",  "mánudagur",  "þriðjudagur", "miðvikudagur",
        "fimmtudagur", "föstudagur", "laugardagur",
    },
    .day_names_short = .{
        "sun", "mán", "þri", "mið", "fim", "fös", "lau",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
