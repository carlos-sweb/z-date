const Locale = @import("../locale.zig").Locale;

/// Albanian locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Janar",   "Shkurt", "Mars",   "Prill",
        "Maj",     "Qershor", "Korrik", "Gusht",
        "Shtator", "Tetor",  "Nëntor", "Dhjetor",
    },
    .month_names_short = .{
        "Jan", "Shk", "Mar", "Pri", "Maj", "Qer",
        "Kor", "Gus", "Sht", "Tet", "Nën", "Dhj",
    },
    .day_names = .{
        "E Diel",   "E Hënë",  "E Martë",  "E Mërkurë",
        "E Enjte",  "E Premte", "E Shtunë",
    },
    .day_names_short = .{
        "Die", "Hën", "Mar", "Mër", "Enj", "Pre", "Sht",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
