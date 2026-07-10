const Locale = @import("../locale.zig").Locale;

/// Kinyarwanda locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Mutarama",   "Gashyantare", "Werurwe",  "Mata",
        "Gicurasi",   "Kamena",      "Nyakanga", "Kanama",
        "Nzeri",      "Ukwakira",    "Ugushyingo", "Ukuboza",
    },
    .month_names_short = .{
        "Mut", "Gas", "Wer", "Mat", "Gic", "Kam",
        "Nya", "Kan", "Nze", "Ukw", "Ugu", "Uku",
    },
    .day_names = .{
        "Ku Cyumweru", "Kuwa Mbere",  "Kuwa Kabiri", "Kuwa Gatatu",
        "Kuwa Kane",   "Kuwa Gatanu", "Kuwa Gatandatu",
    },
    .day_names_short = .{
        "KuC", "Kuw", "Kuw", "Kuw", "Kuw", "Kuw", "Kuw",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
