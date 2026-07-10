const Locale = @import("../locale.zig").Locale;

/// Italian locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "gennaio",  "febbraio", "marzo",     "aprile",
        "maggio",   "giugno",   "luglio",    "agosto",
        "settembre", "ottobre", "novembre",  "dicembre",
    },
    .month_names_short = .{
        "gen", "feb", "mar", "apr", "mag", "giu",
        "lug", "ago", "set", "ott", "nov", "dic",
    },
    .day_names = .{
        "domenica", "lunedì",  "martedì",  "mercoledì",
        "giovedì",  "venerdì", "sabato",
    },
    .day_names_short = .{
        "dom", "lun", "mar", "mer", "gio", "ven", "sab",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
