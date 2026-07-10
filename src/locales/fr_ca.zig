const Locale = @import("../locale.zig").Locale;

/// French (Canada) locale: YYYY-MM-DD, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "janvier",   "février",   "mars",      "avril",
        "mai",       "juin",      "juillet",   "août",
        "septembre", "octobre",   "novembre",  "décembre",
    },
    .month_names_short = .{
        "janv.", "févr.", "mars",  "avr.",
        "mai",   "juin",  "juil.", "août",
        "sept.", "oct.",  "nov.",  "déc.",
    },
    .day_names = .{
        "dimanche", "lundi",     "mardi", "mercredi",
        "jeudi",    "vendredi",  "samedi",
    },
    .day_names_short = .{
        "dim.", "lun.", "mar.", "mer.", "jeu.", "ven.", "sam.",
    },
    .date_order = .ymd,
    .date_separator = '-',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
