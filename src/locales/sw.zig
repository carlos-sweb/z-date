const Locale = @import("../locale.zig").Locale;

/// Swahili locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januari",  "Februari", "Machi",   "Aprili",
        "Mei",      "Juni",     "Julai",   "Agosti",
        "Septemba", "Oktoba",   "Novemba", "Desemba",
    },
    .month_names_short = .{
        "Jan", "Feb", "Mac", "Apr", "Mei", "Jun",
        "Jul", "Ago", "Sep", "Okt", "Nov", "Des",
    },
    .day_names = .{
        "Jumapili", "Jumatatu", "Jumanne", "Jumatano",
        "Alhamisi", "Ijumaa",   "Jumamosi",
    },
    .day_names_short = .{
        "Jpl", "Jtat", "Jnne", "Jtan", "Alh", "Ijm", "Jmos",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
