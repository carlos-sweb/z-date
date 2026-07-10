const Locale = @import("../locale.zig").Locale;

/// Catalan locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Gener",    "Febrer",   "Març",     "Abril",
        "Maig",     "Juny",     "Juliol",   "Agost",
        "Setembre", "Octubre",  "Novembre", "Desembre",
    },
    .month_names_short = .{
        "Gen.", "Febr.", "Març", "Abr.", "Maig", "Juny",
        "Jul.", "Ag.", "Set.", "Oct.", "Nov.", "Des.",
    },
    .day_names = .{
        "Diumenge", "Dilluns",  "Dimarts", "Dimecres",
        "Dijous",   "Divendres", "Dissabte",
    },
    .day_names_short = .{
        "Dg.", "Dl.", "Dt.", "Dc.", "Dj.", "Dv.", "Ds.",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
