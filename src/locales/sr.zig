const Locale = @import("../locale.zig").Locale;

/// Serbian (Latin) locale: D. M. YYYY., 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januar",   "Februar",   "Mart",     "April",
        "Maj",      "Jun",       "Jul",      "Avgust",
        "Septembar", "Oktobar",  "Novembar", "Decembar",
    },
    .month_names_short = .{
        "Jan.", "Feb.", "Mar.", "Apr.", "Maj", "Jun",
        "Jul",  "Avg.", "Sep.", "Okt.", "Nov.", "Dec.",
    },
    .day_names = .{
        "Nedelja", "Ponedeljak", "Utorak", "Sreda",
        "Četvrtak", "Petak",     "Subota",
    },
    .day_names_short = .{
        "Ned.", "Pon.", "Uto.", "Sre.", "Čet.", "Pet.", "Sub.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
