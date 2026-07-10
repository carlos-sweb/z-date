const Locale = @import("../locale.zig").Locale;

/// Esperanto locale: D-a de Month, YYYY / YYYY-MM-DD, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "januaro",   "februaro", "marto",     "aprilo",
        "majo",      "junio",    "julio",     "aŭgusto",
        "septembro", "oktobro",  "novembro",  "decembro",
    },
    .month_names_short = .{
        "jan", "feb", "mar", "apr", "maj", "jun",
        "jul", "aŭg", "sep", "okt", "nov", "dec",
    },
    .day_names = .{
        "dimanĉo", "lundo",  "mardo",    "merkredo",
        "ĵaŭdo",   "vendredo", "sabato",
    },
    .day_names_short = .{
        "dim", "lun", "mard", "merk", "ĵaŭ", "ven", "sab",
    },
    .date_order = .ymd,
    .date_separator = '-',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
