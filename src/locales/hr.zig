const Locale = @import("../locale.zig").Locale;

/// Croatian locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "siječanj", "veljača", "ožujak",   "travanj",
        "svibanj",  "lipanj",  "srpanj",   "kolovoz",
        "rujan",    "listopad", "studeni", "prosinac",
    },
    .month_names_short = .{
        "sij.", "velj.", "ožu.", "tra.", "svi.", "lip.",
        "srp.", "kol.",  "ruj.", "lis.", "stu.", "pro.",
    },
    .day_names = .{
        "nedjelja", "ponedjeljak", "utorak", "srijeda",
        "četvrtak", "petak",       "subota",
    },
    .day_names_short = .{
        "ned.", "pon.", "uto.", "sri.", "čet.", "pet.", "sub.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
