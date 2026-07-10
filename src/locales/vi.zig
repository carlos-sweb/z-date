const Locale = @import("../locale.zig").Locale;

/// Vietnamese locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "tháng 1", "tháng 2", "tháng 3",  "tháng 4",
        "tháng 5", "tháng 6", "tháng 7",  "tháng 8",
        "tháng 9", "tháng 10", "tháng 11", "tháng 12",
    },
    .month_names_short = .{
        "Th01", "Th02", "Th03", "Th04", "Th05", "Th06",
        "Th07", "Th08", "Th09", "Th10", "Th11", "Th12",
    },
    .day_names = .{
        "chủ nhật", "thứ hai", "thứ ba",  "thứ tư",
        "thứ năm",  "thứ sáu", "thứ bảy",
    },
    .day_names_short = .{
        "CN", "T2", "T3", "T4", "T5", "T6", "T7",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
