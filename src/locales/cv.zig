const Locale = @import("../locale.zig").Locale;

/// Chuvash locale: DD-MM-YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "кӑрлач", "нарӑс", "пуш",  "ака",
        "май",    "ҫӗртме", "утӑ",  "ҫурла",
        "авӑн",   "юпа",   "чӳк",  "раштав",
    },
    .month_names_short = .{
        "кӑр", "нар", "пуш", "ака", "май", "ҫӗр",
        "утӑ", "ҫур", "авн", "юпа", "чӳк", "раш",
    },
    .day_names = .{
        "вырсарникун", "тунтикун",    "ытларикун", "юнкун",
        "кӗҫнерникун", "эрнекун",     "шӑматкун",
    },
    .day_names_short = .{
        "выр", "тун", "ытл", "юн", "кӗҫ", "эрн", "шӑм",
    },
    .date_order = .dmy,
    .date_separator = '-',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
