const Locale = @import("../locale.zig").Locale;

/// English (Singapore) locale: D Month YYYY / DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "January",  "February", "March",    "April",
        "May",      "June",     "July",     "August",
        "September", "October", "November", "December",
    },
    .month_names_short = .{
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    },
    .day_names = .{
        "Sunday",   "Monday", "Tuesday",  "Wednesday",
        "Thursday", "Friday", "Saturday",
    },
    .day_names_short = .{
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
