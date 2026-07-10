const Locale = @import("../locale.zig").Locale;

/// Tetun (East Timor) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Janeiru",  "Fevereiru", "Marsu",    "Abril",
        "Maiu",     "Juñu",      "Jullu",    "Agustu",
        "Setembru", "Outubru",   "Novembru", "Dezembru",
    },
    .month_names_short = .{
        "Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
        "Jul", "Ago", "Set", "Out", "Nov", "Dez",
    },
    .day_names = .{
        "Domingu", "Segunda", "Tersa", "Kuarta",
        "Kinta",   "Sesta",   "Sabadu",
    },
    .day_names_short = .{
        "Dom", "Seg", "Ters", "Kua", "Kint", "Sest", "Sab",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
