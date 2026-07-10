const Locale = @import("../locale.zig").Locale;

/// Slovenian locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januar",    "februar", "marec",     "april",
        "maj",       "junij",   "julij",     "avgust",
        "september", "oktober", "november",  "december",
    },
    .month_names_short = .{
        "jan.", "feb.", "mar.", "apr.", "maj.", "jun.",
        "jul.", "avg.", "sep.", "okt.", "nov.", "dec.",
    },
    .day_names = .{
        "nedelja",  "ponedeljek", "torek", "sreda",
        "četrtek",  "petek",      "sobota",
    },
    .day_names_short = .{
        "ned.", "pon.", "tor.", "sre.", "čet.", "pet.", "sob.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
