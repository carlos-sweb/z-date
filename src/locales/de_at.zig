const Locale = @import("../locale.zig").Locale;

/// German (Austria) locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Jänner",  "Februar",  "März",     "April",
        "Mai",     "Juni",     "Juli",     "August",
        "September", "Oktober", "November", "Dezember",
    },
    .month_names_short = .{
        "Jän.", "Feb.", "März", "Apr.", "Mai", "Juni",
        "Juli", "Aug.", "Sep.", "Okt.", "Nov.", "Dez.",
    },
    .day_names = .{
        "Sonntag", "Montag",   "Dienstag", "Mittwoch",
        "Donnerstag", "Freitag", "Samstag",
    },
    .day_names_short = .{
        "So.", "Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa.",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
    .long_date_format = "D. MMMM YYYY",
};
