const Locale = @import("../locale.zig").Locale;

/// Dutch (Belgium) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januari",   "februari", "maart",     "april",
        "mei",       "juni",     "juli",      "augustus",
        "september", "oktober",  "november",  "december",
    },
    .month_names_short = .{
        "jan.", "feb.", "mrt.", "apr.", "mei", "jun.",
        "jul.", "aug.", "sep.", "okt.", "nov.", "dec.",
    },
    .day_names = .{
        "zondag", "maandag", "dinsdag", "woensdag",
        "donderdag", "vrijdag", "zaterdag",
    },
    .day_names_short = .{
        "zo.", "ma.", "di.", "wo.", "do.", "vr.", "za.",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
