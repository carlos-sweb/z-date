const Locale = @import("../locale.zig").Locale;

/// Kazakh locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "қаңтар",  "ақпан",   "наурыз",    "сәуір",
        "мамыр",   "маусым",  "шілде",     "тамыз",
        "қыркүйек", "қазан",   "қараша",    "желтоқсан",
    },
    .month_names_short = .{
        "қаң", "ақп", "нау", "сәу", "мам", "мау",
        "шіл", "там", "қыр", "қаз", "қар", "жел",
    },
    .day_names = .{
        "жексенбі", "дүйсенбі", "сейсенбі", "сәрсенбі",
        "бейсенбі", "жұма",     "сенбі",
    },
    .day_names_short = .{
        "жек", "дүй", "сей", "сәр", "бей", "жұм", "сен",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
