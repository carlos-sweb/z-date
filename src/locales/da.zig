const Locale = @import("../locale.zig").Locale;

/// Danish locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januar",   "februar",  "marts",     "april",
        "maj",      "juni",     "juli",      "august",
        "september", "oktober", "november",  "december",
    },
    .month_names_short = .{
        "jan.", "feb.", "mar.", "apr.", "maj", "juni",
        "juli", "aug.", "sept.", "okt.", "nov.", "dec.",
    },
    .day_names = .{
        "søndag", "mandag",  "tirsdag", "onsdag",
        "torsdag", "fredag", "lørdag",
    },
    .day_names_short = .{
        "søn.", "man.", "tirs.", "ons.", "tors.", "fre.", "lør.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
    .long_date_format = "D. MMMM YYYY",
};
