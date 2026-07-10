const Locale = @import("../locale.zig").Locale;

/// Russian locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "января",   "февраля", "марта",     "апреля",
        "мая",      "июня",    "июля",      "августа",
        "сентября", "октября", "ноября",    "декабря",
    },
    .month_names_short = .{
        "янв.", "февр.", "мар.", "апр.", "мая", "июня",
        "июля", "авг.",  "сент.", "окт.", "нояб.", "дек.",
    },
    .day_names = .{
        "воскресенье", "понедельник", "вторник", "среда",
        "четверг",     "пятница",     "суббота",
    },
    .day_names_short = .{
        "вск", "пнд", "втр", "срд", "чтв", "птн", "сбт",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
    .long_date_format = "D MMMM YYYY г.",
};
