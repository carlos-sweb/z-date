const Locale = @import("../locale.zig").Locale;

/// Indonesian locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Januari",  "Februari", "Maret",     "April",
        "Mei",      "Juni",     "Juli",      "Agustus",
        "September", "Oktober", "November",  "Desember",
    },
    .month_names_short = .{
        "Jan", "Feb", "Mar", "Apr", "Mei", "Jun",
        "Jul", "Agt", "Sep", "Okt", "Nov", "Des",
    },
    .day_names = .{
        "Minggu", "Senin", "Selasa", "Rabu",
        "Kamis",  "Jumat", "Sabtu",
    },
    .day_names_short = .{
        "Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
