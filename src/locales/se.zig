const Locale = @import("../locale.zig").Locale;

/// Northern Sami locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ođđajagemánnu", "guovvamánnu", "njukčamánnu", "cuoŋománnu",
        "miessemánnu",   "geassemánnu", "suoidnemánnu", "borgemánnu",
        "čakčamánnu",    "golggotmánnu", "skábmamánnu", "juovlamánnu",
    },
    .month_names_short = .{
        "ođđj", "guov", "njuk", "cuo", "mies", "geas",
        "suoi", "borg", "čakč", "golg", "skáb", "juov",
    },
    .day_names = .{
        "sotnabeaivi", "vuossárga", "maŋŋebárga", "gaskavahkku",
        "duorastat",   "bearjadat", "lávvardat",
    },
    .day_names_short = .{
        "sotn", "vuos", "maŋ", "gask", "duor", "bear", "láv",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
