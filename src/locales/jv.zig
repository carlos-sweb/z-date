const Locale = @import("../locale.zig").Locale;

/// Javanese locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januari",   "Februari", "Maret",     "April",
        "Mei",       "Juni",     "Juli",      "Agustus",
        "September", "Oktober",  "Nopember", "Desember",
    },
    .month_names_short = .{
        "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
        "Jul", "Ags", "Sep", "Okt", "Nop", "Des",
    },
    .day_names = .{
        "Minggu", "Senen",   "Seloso", "Rebu",
        "Kemis",  "Jemuwah", "Septu",
    },
    .day_names_short = .{
        "Min", "Sen", "Sel", "Reb", "Kem", "Jem", "Sep",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
