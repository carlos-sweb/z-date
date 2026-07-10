const Locale = @import("../locale.zig").Locale;

/// Lithuanian locale: YYYY-MM-DD, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "sausis",   "vasaris",  "kovas",     "balandis",
        "gegužė",   "birželis", "liepa",     "rugpjūtis",
        "rugsėjis", "spalis",   "lapkritis", "gruodis",
    },
    .month_names_short = .{
        "sau", "vas", "kov", "bal", "geg", "bir",
        "lie", "rgp", "rgs", "spa", "lap", "grd",
    },
    .day_names = .{
        "sekmadienis",  "pirmadienis",   "antradienis", "trečiadienis",
        "ketvirtadienis", "penktadienis", "šeštadienis",
    },
    .day_names_short = .{
        "sek", "pir", "ant", "tre", "ket", "pen", "šeš",
    },
    .date_order = .ymd,
    .date_separator = '-',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
