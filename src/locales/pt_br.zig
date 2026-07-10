const Locale = @import("../locale.zig").Locale;

/// Portuguese (Brazil) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "janeiro",   "fevereiro", "março",    "abril",
        "maio",      "junho",     "julho",    "agosto",
        "setembro",  "outubro",   "novembro", "dezembro",
    },
    .month_names_short = .{
        "jan", "fev", "mar", "abr", "mai", "jun",
        "jul", "ago", "set", "out", "nov", "dez",
    },
    .day_names = .{
        "domingo",       "segunda-feira", "terça-feira", "quarta-feira",
        "quinta-feira",  "sexta-feira",   "sábado",
    },
    .day_names_short = .{
        "dom", "seg", "ter", "qua", "qui", "sex", "sáb",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
    .long_date_format = "D de MMMM de YYYY",
};
