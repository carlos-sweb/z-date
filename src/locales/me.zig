const Locale = @import("../locale.zig").Locale;

/// Montenegrin locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januar",    "februar",   "mart",      "april",
        "maj",       "jun",       "jul",       "avgust",
        "septembar", "oktobar",   "novembar", "decembar",
    },
    .month_names_short = .{
        "jan.", "feb.", "mar.", "apr.", "maj",  "jun",
        "jul",  "avg.", "sep.", "okt.", "nov.", "dec.",
    },
    .day_names = .{
        "nedjelja",  "ponedjeljak", "utorak",   "srijeda",
        "četvrtak", "petak",       "subota",
    },
    .day_names_short = .{
        "ned.", "pon.", "uto.", "sri.", "čet.", "pet.", "sub.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
