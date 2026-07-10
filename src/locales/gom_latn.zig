const Locale = @import("../locale.zig").Locale;

/// Konkani (Latin script) locale: DD-MM-YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Janer",   "Febrer",  "Mars",    "Abril",
        "Mai",     "Jun",     "Julai",   "Agost",
        "Setembr", "Otubr",   "Novembr", "Dezembr",
    },
    .month_names_short = .{
        "Jan.", "Feb.", "Mars", "Abr.", "Mai", "Jun",
        "Jul.", "Ago.", "Set.", "Otu.", "Nov.", "Dez.",
    },
    .day_names = .{
        "Aitar",  "Somar",  "Mongllar", "Budvar",
        "Brestar", "Sukrar", "Son'var",
    },
    .day_names_short = .{
        "Ait.", "Som.", "Mon.", "Bud.", "Bre.", "Suk.", "Son.",
    },
    .date_order = .dmy,
    .date_separator = '-',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};
