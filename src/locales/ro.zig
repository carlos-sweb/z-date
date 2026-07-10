const Locale = @import("../locale.zig").Locale;

/// Romanian locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Ianuarie",   "Februarie", "Martie",    "Aprilie",
        "Mai",        "Iunie",     "Iulie",     "August",
        "Septembrie", "Octombrie", "Noiembrie", "Decembrie",
    },
    .month_names_short = .{
        "Ian.", "Febr.", "Mart.", "Apr.", "Mai", "Iun.",
        "Iul.", "Aug.",  "Sept.", "Oct.", "Nov.", "Dec.",
    },
    .day_names = .{
        "Duminică", "Luni", "Marți", "Miercuri",
        "Joi",      "Vineri", "Sâmbătă",
    },
    .day_names_short = .{
        "Dum", "Lun", "Mar", "Mie", "Joi", "Vin", "Sâm",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
