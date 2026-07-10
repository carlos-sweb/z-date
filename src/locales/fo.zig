const Locale = @import("../locale.zig").Locale;

/// Faroese locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januar",  "februar",  "mars",      "apríl",
        "mai",     "juni",     "juli",      "august",
        "september", "oktober", "november", "desember",
    },
    .month_names_short = .{
        "jan", "feb", "mar", "apr", "mai", "jun",
        "jul", "aug", "sep", "okt", "nov", "des",
    },
    .day_names = .{
        "sunnudagur",  "mánadagur",    "týsdagur", "mikudagur",
        "hósdagur",    "fríggjadagur", "leygardagur",
    },
    .day_names_short = .{
        "sun", "mán", "týs", "mik", "hós", "frí", "ley",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
