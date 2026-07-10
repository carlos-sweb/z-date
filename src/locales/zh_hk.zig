const Locale = @import("../locale.zig").Locale;

/// Chinese (Hong Kong, Traditional) locale: YYYY/MM/DD, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "一月", "二月", "三月", "四月",
        "五月", "六月", "七月", "八月",
        "九月", "十月", "十一月", "十二月",
    },
    .month_names_short = .{
        "1月", "2月", "3月", "4月", "5月", "6月",
        "7月", "8月", "9月", "10月", "11月", "12月",
    },
    .day_names = .{
        "星期日", "星期一", "星期二", "星期三",
        "星期四", "星期五", "星期六",
    },
    .day_names_short = .{
        "週日", "週一", "週二", "週三", "週四", "週五", "週六",
    },
    .date_order = .ymd,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "上午",
    .pm_label = "下午",
    .long_date_format = "YYYY年M月D日",
};
