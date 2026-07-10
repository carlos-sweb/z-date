const Locale = @import("../locale.zig").Locale;

/// Ukrainian locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "січень", "лютий",   "березень", "квітень",
        "травень", "червень", "липень",   "серпень",
        "вересень", "жовтень", "листопад", "грудень",
    },
    .month_names_short = .{
        "січ",  "лют",  "бер",  "квіт", "трав", "черв",
        "лип",  "серп", "вер",  "жовт", "лист", "груд",
    },
    .day_names = .{
        "неділя",  "понеділок", "вівторок", "середа",
        "четвер",  "п’ятниця",  "субота",
    },
    .day_names_short = .{
        "ндл", "пнд", "втр", "срд", "чтв", "птн", "сбт",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
