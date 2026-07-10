const Locale = @import("../locale.zig").Locale;

/// Breton locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Genver",   "Cʼhwevrer", "Meurzh",   "Ebrel",
        "Mae",      "Mezheven",  "Gouere",   "Eost",
        "Gwengolo", "Here",      "Du",       "Kerzu",
    },
    .month_names_short = .{
        "Gen", "Cʼhwe", "Meu", "Ebr", "Mae", "Eve",
        "Gou", "Eos", "Gwe", "Her", "Du", "Ker",
    },
    .day_names = .{
        "Sul", "Lun",   "Meurzh", "Mercʼher",
        "Yaou", "Gwener", "Sadorn",
    },
    .day_names_short = .{
        "Sul", "Lun", "Meu", "Mer", "Yao", "Gwe", "Sad",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "a.m.",
    .pm_label = "g.m.",
};
