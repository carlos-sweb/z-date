const Locale = @import("../locale.zig").Locale;

/// Uzbek (Cyrillic script) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "январ",   "феврал",  "март",    "апрел",
        "май",     "июн",     "июл",     "август",
        "сентябр", "октябр",  "ноябр",   "декабр",
    },
    .month_names_short = .{
        "янв", "фев", "мар", "апр", "май", "июн",
        "июл", "авг", "сен", "окт", "ноя", "дек",
    },
    .day_names = .{
        "Якшанба", "Душанба", "Сешанба", "Чоршанба",
        "Пайшанба", "Жума",   "Шанба",
    },
    .day_names_short = .{
        "Якш", "Душ", "Сеш", "Чор", "Пай", "Жум", "Шан",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
