const Locale = @import("../locale.zig").Locale;

/// Czech locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "leden",   "únor",     "březen",    "duben",
        "květen",  "červen",   "červenec",  "srpen",
        "září",    "říjen",    "listopad",  "prosinec",
    },
    .month_names_short = .{
        "led", "úno", "bře", "dub", "kvě", "čvn",
        "čvc", "srp", "zář", "říj", "lis", "pro",
    },
    .day_names = .{
        "neděle", "pondělí", "úterý", "středa",
        "čtvrtek", "pátek",  "sobota",
    },
    .day_names_short = .{
        "ne", "po", "út", "st", "čt", "pá", "so",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
