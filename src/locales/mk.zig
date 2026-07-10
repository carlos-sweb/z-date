const Locale = @import("../locale.zig").Locale;

/// Macedonian locale: D.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "јануари",   "февруари", "март",     "април",
        "мај",       "јуни",     "јули",     "август",
        "септември", "октомври", "ноември",  "декември",
    },
    .month_names_short = .{
        "јан", "фев", "мар", "апр", "мај", "јун",
        "јул", "авг", "сеп", "окт", "ное", "дек",
    },
    .day_names = .{
        "недела", "понеделник", "вторник", "среда",
        "четврток", "петок", "сабота",
    },
    .day_names_short = .{
        "нед", "пон", "вто", "сре", "чет", "пет", "саб",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
