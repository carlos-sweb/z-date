const Locale = @import("../locale.zig").Locale;

/// Bulgarian locale: D.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "януари",    "февруари", "март",     "април",
        "май",       "юни",      "юли",      "август",
        "септември", "октомври", "ноември",  "декември",
    },
    .month_names_short = .{
        "яну", "фев", "мар", "апр", "май", "юни",
        "юли", "авг", "сеп", "окт", "ное", "дек",
    },
    .day_names = .{
        "неделя", "понеделник", "вторник",  "сряда",
        "четвъртък", "петък",   "събота",
    },
    .day_names_short = .{
        "нед", "пон", "вто", "сря", "чет", "пет", "съб",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
