const Locale = @import("../locale.zig").Locale;

/// Talossan locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januar",   "Fevraglh", "Març",     "Avrïu",
        "Mai",      "Gün",      "Julia",    "Guscht",
        "Setemvar", "Listopäts", "Noemvar", "Zecemvar",
    },
    .month_names_short = .{
        "Jan", "Fev", "Mar", "Avr", "Mai", "Gün",
        "Jul", "Gus", "Set", "Lis", "Noe", "Zec",
    },
    .day_names = .{
        "Súladi", "Lúneçi",   "Maitzi", "Márcuri",
        "Xhúadi", "Viénerçi", "Sáturi",
    },
    .day_names_short = .{
        "Súl", "Lún", "Mai", "Már", "Xhú", "Vié", "Sát",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
