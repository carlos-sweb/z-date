const Locale = @import("../locale.zig").Locale;

/// Japanese locale: YYYY/MM/DD, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "1月",  "2月",  "3月",  "4月",
        "5月",  "6月",  "7月",  "8月",
        "9月",  "10月", "11月", "12月",
    },
    .month_names_short = .{
        "1月",  "2月",  "3月",  "4月",
        "5月",  "6月",  "7月",  "8月",
        "9月",  "10月", "11月", "12月",
    },
    .day_names = .{
        "日曜日", "月曜日", "火曜日", "水曜日",
        "木曜日", "金曜日", "土曜日",
    },
    .day_names_short = .{
        "日", "月", "火", "水", "木", "金", "土",
    },
    .date_order = .ymd,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "午前",
    .pm_label = "午後",
    .long_date_format = "YYYY年M月D日",
};
