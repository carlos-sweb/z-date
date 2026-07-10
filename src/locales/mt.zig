const Locale = @import("../locale.zig").Locale;

/// Maltese locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "Jannar",  "Frar",     "Marzu",     "April",
        "Mejju",   "Ġunju",    "Lulju",     "Awwissu",
        "Settembru", "Ottubru", "Novembru", "Diċembru",
    },
    .month_names_short = .{
        "Jan", "Fra", "Mar", "Apr", "Mej", "Ġun",
        "Lul", "Aww", "Set", "Ott", "Nov", "Diċ",
    },
    .day_names = .{
        "Il-Ħadd", "It-Tnejn", "It-Tlieta", "L-Erbgħa",
        "Il-Ħamis", "Il-Ġimgħa", "Is-Sibt",
    },
    .day_names_short = .{
        "Ħad", "Tne", "Tli", "Erb", "Ħam", "Ġim", "Sib",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
