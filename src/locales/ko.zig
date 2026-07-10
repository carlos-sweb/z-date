const Locale = @import("../locale.zig").Locale;

/// Korean locale: YYYY.MM.DD., 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "1월",  "2월",  "3월",  "4월",
        "5월",  "6월",  "7월",  "8월",
        "9월",  "10월", "11월", "12월",
    },
    .month_names_short = .{
        "1월",  "2월",  "3월",  "4월",
        "5월",  "6월",  "7월",  "8월",
        "9월",  "10월", "11월", "12월",
    },
    .day_names = .{
        "일요일", "월요일", "화요일", "수요일",
        "목요일", "금요일", "토요일",
    },
    .day_names_short = .{
        "일", "월", "화", "수", "목", "금", "토",
    },
    .date_order = .ymd,
    .date_separator = '.',
    .time_24h = false,
    .am_label = "오전",
    .pm_label = "오후",
    .long_date_format = "YYYY년 MMMM D일",
};
