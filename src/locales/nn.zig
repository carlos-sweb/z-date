const Locale = @import("../locale.zig").Locale;

/// Norwegian Nynorsk locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januar",    "februar", "mars",     "april",
        "mai",       "juni",    "juli",     "august",
        "september", "oktober", "november", "desember",
    },
    .month_names_short = .{
        "jan", "feb", "mar", "apr", "mai", "jun",
        "jul", "aug", "sep", "okt", "nov", "des",
    },
    .day_names = .{
        "sundag", "måndag", "tysdag", "onsdag",
        "torsdag", "fredag", "laurdag",
    },
    .day_names_short = .{
        "sun", "mån", "tys", "ons", "tor", "fre", "lau",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
