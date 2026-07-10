const Locale = @import("../locale.zig").Locale;

/// Swedish locale: YYYY-MM-DD, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januari",   "februari", "mars",      "april",
        "maj",       "juni",     "juli",      "augusti",
        "september", "oktober",  "november",  "december",
    },
    .month_names_short = .{
        "jan", "feb", "mar", "apr", "maj", "jun",
        "jul", "aug", "sep", "okt", "nov", "dec",
    },
    .day_names = .{
        "söndag", "måndag", "tisdag", "onsdag",
        "torsdag", "fredag", "lördag",
    },
    .day_names_short = .{
        "sön", "mån", "tis", "ons", "tor", "fre", "lör",
    },
    .date_order = .ymd,
    .date_separator = '-',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
