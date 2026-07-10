const Locale = @import("../locale.zig").Locale;

/// Malay (Malaysia) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januari",   "Februari", "Mac",      "April",
        "Mei",       "Jun",      "Julai",    "Ogos",
        "September", "Oktober",  "November", "Disember",
    },
    .month_names_short = .{
        "Jan", "Feb", "Mac", "Apr", "Mei", "Jun",
        "Jul", "Ogs", "Sep", "Okt", "Nov", "Dis",
    },
    .day_names = .{
        "Ahad", "Isnin", "Selasa", "Rabu", "Khamis", "Jumaat", "Sabtu",
    },
    .day_names_short = .{
        "Ahd", "Isn", "Sel", "Rab", "Kha", "Jum", "Sab",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
