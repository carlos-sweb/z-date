const Locale = @import("../locale.zig").Locale;

/// Turkish locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Ocak",   "Şubat", "Mart",   "Nisan",
        "Mayıs",  "Haziran", "Temmuz", "Ağustos",
        "Eylül",  "Ekim",  "Kasım",  "Aralık",
    },
    .month_names_short = .{
        "Oca", "Şub", "Mar", "Nis", "May", "Haz",
        "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara",
    },
    .day_names = .{
        "Pazar", "Pazartesi", "Salı", "Çarşamba",
        "Perşembe", "Cuma", "Cumartesi",
    },
    .day_names_short = .{
        "Paz", "Pts", "Sal", "Çar", "Per", "Cum", "Cts",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
