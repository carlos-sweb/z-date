const Locale = @import("../locale.zig").Locale;

/// Norwegian Bokmål locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januar",    "februar", "mars",     "april",
        "mai",       "juni",    "juli",     "august",
        "september", "oktober", "november", "desember",
    },
    .month_names_short = .{
        "jan.", "feb.", "mars", "april", "mai", "juni",
        "juli", "aug.", "sep.", "okt.",  "nov.", "des.",
    },
    .day_names = .{
        "søndag", "mandag", "tirsdag", "onsdag",
        "torsdag", "fredag", "lørdag",
    },
    .day_names_short = .{
        "sø.", "ma.", "ti.", "on.", "to.", "fr.", "lø.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
