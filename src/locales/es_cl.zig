const Locale = @import("../locale.zig").Locale;

/// Spanish (Chile) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "enero",      "febrero",   "marzo",     "abril",
        "mayo",       "junio",     "julio",     "agosto",
        "septiembre", "octubre",   "noviembre", "diciembre",
    },
    .month_names_short = .{
        "ene", "feb", "mar", "abr", "may", "jun",
        "jul", "ago", "sep", "oct", "nov", "dic",
    },
    .day_names = .{
        "domingo", "lunes",     "martes", "miércoles",
        "jueves",  "viernes",   "sábado",
    },
    .day_names_short = .{
        "dom", "lun", "mar", "mié", "jue", "vie", "sáb",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "a. m.",
    .pm_label = "p. m.",
    .long_date_format = "D de MMMM de YYYY",
};
