const Locale = @import("../locale.zig").Locale;

/// Slovak locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "január",    "február", "marec",     "apríl",
        "máj",       "jún",     "júl",       "august",
        "september", "október", "november",  "december",
    },
    .month_names_short = .{
        "jan", "feb", "mar", "apr", "máj", "jún",
        "júl", "aug", "sep", "okt", "nov", "dec",
    },
    .day_names = .{
        "nedeľa",  "pondelok", "utorok", "streda",
        "štvrtok", "piatok",   "sobota",
    },
    .day_names_short = .{
        "ne", "po", "ut", "st", "št", "pi", "so",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
