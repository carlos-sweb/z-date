const Locale = @import("../locale.zig").Locale;

/// Galician locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "xaneiro",  "febreiro",  "marzo",     "abril",
        "maio",     "xuño",      "xullo",     "agosto",
        "setembro", "outubro",   "novembro",  "decembro",
    },
    .month_names_short = .{
        "xan.", "feb.", "mar.", "abr.", "mai.", "xuñ.",
        "xul.", "ago.", "set.", "out.", "nov.", "dec.",
    },
    .day_names = .{
        "domingo", "luns",     "martes",  "mércores",
        "xoves",   "venres",  "sábado",
    },
    .day_names_short = .{
        "dom.", "lun.", "mar.", "mér.", "xov.", "ven.", "sáb.",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
