const Locale = @import("../locale.zig").Locale;

/// Frisian locale: DD-MM-YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "jannewaris", "febrewaris", "maart",     "april",
        "maaie",      "juny",       "july",      "augustus",
        "septimber",  "oktober",    "novimber",  "desimber",
    },
    .month_names_short = .{
        "jan.", "feb.", "mrt.", "apr.", "mai",  "jun.",
        "jul.", "aug.", "sep.", "okt.", "nov.", "des.",
    },
    .day_names = .{
        "snein",      "moandei",   "tiisdei", "woansdei",
        "tongersdei", "freed",     "sneon",
    },
    .day_names_short = .{
        "si.", "mo.", "ti.", "wo.", "to.", "fr.", "so.",
    },
    .date_order = .dmy,
    .date_separator = '-',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
