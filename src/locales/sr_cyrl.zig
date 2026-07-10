const Locale = @import("../locale.zig").Locale;

/// Serbian (Cyrillic) locale: D. M. YYYY., 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Јануар",   "Фебруар",   "Март",     "Април",
        "Мај",      "Јун",       "Јул",      "Август",
        "Септембар", "Октобар",  "Новембар", "Децембар",
    },
    .month_names_short = .{
        "Јан.", "Феб.", "Мар.", "Апр.", "Мај", "Јун",
        "Јул",  "Авг.", "Сеп.", "Окт.", "Нов.", "Дец.",
    },
    .day_names = .{
        "Недеља", "Понедељак", "Уторак", "Среда",
        "Четвртак", "Петак",   "Субота",
    },
    .day_names_short = .{
        "Нед.", "Пон.", "Уто.", "Сре.", "Чет.", "Пет.", "Суб.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
