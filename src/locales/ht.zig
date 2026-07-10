const Locale = @import("../locale.zig").Locale;

/// Haitian Creole locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "janvye", "fevriye", "mas",    "avril",
        "me",     "jen",     "jiyè",   "out",
        "septanm", "oktòb",  "novanm", "desanm",
    },
    .month_names_short = .{
        "jan.",  "fev.", "mas",   "avr.",
        "me",    "jen",  "jiyè.", "out",
        "sept.", "okt.", "nov.",  "des.",
    },
    .day_names = .{
        "dimanch", "lendi",    "madi", "mèkredi",
        "jedi",    "vandredi", "samdi",
    },
    .day_names_short = .{
        "dim.", "len.", "mad.", "mèk.", "jed.", "van.", "sam.",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
