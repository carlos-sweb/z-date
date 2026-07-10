const Locale = @import("../locale.zig").Locale;

/// Bislama locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januari",  "Februari", "Maj",     "Eprel",
        "Mei",      "Jun",      "Julae",   "Okis",
        "Septemba", "Oktoba",   "Novemba", "Disemba",
    },
    .month_names_short = .{
        "Jan", "Feb", "Maj", "Epr", "Mai", "Jun",
        "Jul", "Oki", "Sep", "Okt", "Nov", "Dis",
    },
    .day_names = .{
        "Sande", "Mande",   "Tusde", "Wenesde",
        "Tosde", "Fraede", "Sarade",
    },
    .day_names_short = .{
        "San", "Man", "Tus", "Wen", "Tos", "Frae", "Sar",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};
