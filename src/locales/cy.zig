const Locale = @import("../locale.zig").Locale;

/// Welsh locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Ionawr",     "Chwefror", "Mawrth",   "Ebrill",
        "Mai",        "Mehefin",  "Gorffennaf", "Awst",
        "Medi",       "Hydref",   "Tachwedd", "Rhagfyr",
    },
    .month_names_short = .{
        "Ion", "Chwe", "Maw", "Ebr", "Mai", "Meh",
        "Gor", "Aws", "Med", "Hyd", "Tach", "Rhag",
    },
    .day_names = .{
        "Dydd Sul", "Dydd Llun",   "Dydd Mawrth", "Dydd Mercher",
        "Dydd Iau", "Dydd Gwener", "Dydd Sadwrn",
    },
    .day_names_short = .{
        "Sul", "Llun", "Maw", "Mer", "Iau", "Gwe", "Sad",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
