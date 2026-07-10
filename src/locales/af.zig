const Locale = @import("../locale.zig").Locale;

/// Afrikaans locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januarie", "Februarie", "Maart",     "April",
        "Mei",      "Junie",     "Julie",     "Augustus",
        "September", "Oktober",  "November",  "Desember",
    },
    .month_names_short = .{
        "Jan", "Feb", "Mrt", "Apr", "Mei", "Jun",
        "Jul", "Aug", "Sep", "Okt", "Nov", "Des",
    },
    .day_names = .{
        "Sondag", "Maandag",  "Dinsdag", "Woensdag",
        "Donderdag", "Vrydag", "Saterdag",
    },
    .day_names_short = .{
        "Son", "Maa", "Din", "Woe", "Don", "Vry", "Sat",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
