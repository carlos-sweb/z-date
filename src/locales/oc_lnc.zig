const Locale = @import("../locale.zig").Locale;

/// Occitan (Languedoc dialect) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "genièr",  "febrièr",  "març",     "abrial",
        "mai",     "junh",     "julhet",   "agost",
        "setembre", "octòbre", "novembre", "decembre",
    },
    .month_names_short = .{
        "gen", "feb", "març", "abr", "mai", "junh",
        "julh", "ago", "set", "oct", "nov", "dec",
    },
    .day_names = .{
        "dimenge", "diluns", "dimars", "dimècres",
        "dijòus", "divendres", "dissabte",
    },
    .day_names_short = .{
        "Dg", "Dl", "Dm", "Dc", "Dj", "Dv", "Ds",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
