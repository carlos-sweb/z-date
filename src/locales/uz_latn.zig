const Locale = @import("../locale.zig").Locale;

/// Uzbek (Latin script) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Yanvar",  "Fevral", "Mart",   "Aprel",
        "May",     "Iyun",   "Iyul",   "Avgust",
        "Sentabr", "Oktabr", "Noyabr", "Dekabr",
    },
    .month_names_short = .{
        "Yan", "Fev", "Mar", "Apr", "May", "Iyun",
        "Iyul", "Avg", "Sen", "Okt", "Noy", "Dek",
    },
    .day_names = .{
        "Yakshanba", "Dushanba", "Seshanba", "Chorshanba",
        "Payshanba", "Juma",     "Shanba",
    },
    .day_names_short = .{
        "Yak", "Dush", "Sesh", "Chor", "Pay", "Jum", "Shan",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
