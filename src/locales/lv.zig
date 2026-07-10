const Locale = @import("../locale.zig").Locale;

/// Latvian locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "janvāris",   "februāris", "marts",     "aprīlis",
        "maijs",      "jūnijs",    "jūlijs",    "augusts",
        "septembris", "oktobris",  "novembris", "decembris",
    },
    .month_names_short = .{
        "jan", "feb", "mar", "apr", "mai", "jūn",
        "jūl", "aug", "sep", "okt", "nov", "dec",
    },
    .day_names = .{
        "svētdiena", "pirmdiena",  "otrdiena",   "trešdiena",
        "ceturtdiena", "piektdiena", "sestdiena",
    },
    .day_names_short = .{
        "Sv", "P", "O", "T", "C", "Pk", "S",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
