const Locale = @import("../locale.zig").Locale;

/// Luxembourgish locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januar",    "Februar", "Mäerz",     "Abrëll",
        "Mee",       "Juni",    "Juli",      "August",
        "September", "Oktober", "November", "Dezember",
    },
    .month_names_short = .{
        "Jan.",  "Febr.", "Mrz.",  "Abr.",
        "Mee",   "Jun.",  "Jul.",  "Aug.",
        "Sept.", "Okt.",  "Nov.",  "Dez.",
    },
    .day_names = .{
        "Sonndeg", "Méindeg",    "Dënschdeg", "Mëttwoch",
        "Donneschdeg", "Freideg", "Samschdeg",
    },
    .day_names_short = .{
        "So.", "Mé.", "Dë.", "Më.", "Do.", "Fr.", "Sa.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
