const Locale = @import("../locale.zig").Locale;

/// siSwati locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Bhimbidvwane", "Indlovana",       "Indlov'lenkhulu", "Mabasa",
        "Inkhwekhweti", "Inhlaba",         "Kholwane",        "Ingci",
        "Inyoni",       "Imphala",         "Lweti",           "Ingongoni",
    },
    .month_names_short = .{
        "Bhi", "Ina", "Inu", "Mab", "Ink", "Inh",
        "Kho", "Igc", "Iny", "Imp", "Lwe", "Igo",
    },
    .day_names = .{
        "Lisontfo", "Umsombuluko", "Lesibili", "Lesitsatfu",
        "Lesine",   "Lesihlanu",   "Umgcibelo",
    },
    .day_names_short = .{
        "Lis", "Umb", "Lsb", "Les", "Lsi", "Lsh", "Umg",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};
