const Locale = @import("../locale.zig").Locale;

/// Turkmen locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Ýanwar",   "Fewral", "Mart",   "Aprel",
        "Maý",      "Iýun",   "Iýul",   "Awgust",
        "Sentýabr", "Oktýabr", "Noýabr", "Dekabr",
    },
    .month_names_short = .{
        "Ýan", "Few", "Mar", "Apr", "Maý", "Iýn",
        "Iýl", "Awg", "Sen", "Okt", "Noý", "Dek",
    },
    .day_names = .{
        "Ýekşenbe", "Duşenbe", "Sişenbe", "Çarşenbe",
        "Penşenbe", "Anna",    "Şenbe",
    },
    .day_names_short = .{
        "Ýek", "Duş", "Siş", "Çar", "Pen", "Ann", "Şen",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
