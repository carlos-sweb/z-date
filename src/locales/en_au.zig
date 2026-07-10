const Locale = @import("../locale.zig").Locale;

/// English (Australia) locale: D Month YYYY / DD/MM/YYYY, 12-hour clock.
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
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};
