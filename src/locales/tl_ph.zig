const Locale = @import("../locale.zig").Locale;

/// Tagalog (Philippines) locale: MM/D/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Enero",   "Pebrero",  "Marso",    "Abril",
        "Mayo",    "Hunyo",    "Hulyo",    "Agosto",
        "Setyembre", "Oktubre", "Nobyembre", "Disyembre",
    },
    .month_names_short = .{
        "Ene", "Peb", "Mar", "Abr", "May", "Hun",
        "Hul", "Ago", "Set", "Okt", "Nob", "Dis",
    },
    .day_names = .{
        "Linggo", "Lunes", "Martes", "Miyerkules",
        "Huwebes", "Biyernes", "Sabado",
    },
    .day_names_short = .{
        "Lin", "Lun", "Mar", "Miy", "Huw", "Biy", "Sab",
    },
    .date_order = .mdy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
