const Locale = @import("../locale.zig").Locale;

/// Polish locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "stycznia",   "lutego",    "marca",      "kwietnia",
        "maja",       "czerwca",   "lipca",      "sierpnia",
        "września",   "października", "listopada", "grudnia",
    },
    .month_names_short = .{
        "sty", "lut", "mar", "kwi", "maj", "cze",
        "lip", "sie", "wrz", "paź", "lis", "gru",
    },
    .day_names = .{
        "niedziela",     "poniedziałek", "wtorek", "środa",
        "czwartek",      "piątek",       "sobota",
    },
    .day_names_short = .{
        "ndz", "pon", "wt", "śr", "czw", "pt", "sob",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
