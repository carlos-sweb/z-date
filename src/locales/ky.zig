const Locale = @import("../locale.zig").Locale;

/// Kyrgyz locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "январь",   "февраль", "март",    "апрель",
        "май",      "июнь",    "июль",    "август",
        "сентябрь", "октябрь", "ноябрь",  "декабрь",
    },
    .month_names_short = .{
        "янв", "фев", "март", "апр", "май", "июнь",
        "июль", "авг", "сен", "окт", "ноя", "дек",
    },
    .day_names = .{
        "Жекшемби", "Дүйшөмбү", "Шейшемби", "Шаршемби",
        "Бейшемби", "Жума",     "Ишемби",
    },
    .day_names_short = .{
        "Жек", "Дүй", "Шей", "Шар", "Бей", "Жум", "Ише",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
