const Locale = @import("../locale.zig").Locale;

/// Scottish Gaelic locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Am Faoilleach",  "An Gearran",     "Am Màrt",        "An Giblean",
        "An Cèitean",     "An t-Ògmhios",   "An t-Iuchar",    "An Lùnastal",
        "An t-Sultain",   "An Dàmhair",     "An t-Samhain",   "An Dùbhlachd",
    },
    .month_names_short = .{
        "Faoi", "Gear", "Màrt", "Gibl", "Cèit", "Ògmh",
        "Iuch", "Lùn",  "Sult", "Dàmh", "Samh", "Dùbh",
    },
    .day_names = .{
        "Didòmhnaich", "Diluain",   "Dimàirt", "Diciadain",
        "Diardaoin",   "Dihaoine",  "Disathairne",
    },
    .day_names_short = .{
        "Did", "Dil", "Dim", "Dic", "Dia", "Dih", "Dis",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
