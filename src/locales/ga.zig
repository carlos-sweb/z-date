const Locale = @import("../locale.zig").Locale;

/// Irish (Gaelic) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Eanáir",  "Feabhra",       "Márta",         "Aibreán",
        "Bealtaine", "Meitheamh",   "Iúil",          "Lúnasa",
        "Meán Fómhair", "Deireadh Fómhair", "Samhain", "Nollaig",
    },
    .month_names_short = .{
        "Ean", "Fea", "Már", "Aib", "Beal", "Mei",
        "Iúil", "Lún", "MFómh", "DFómh", "Samh", "Noll",
    },
    .day_names = .{
        "Dé Domhnaigh", "Dé Luain",   "Dé Máirt",  "Dé Céadaoin",
        "Déardaoin",    "Dé hAoine",  "Dé Sathairn",
    },
    .day_names_short = .{
        "Dom", "Lua", "Mái", "Céa", "Déa", "Aoi", "Sat",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
