const Locale = @import("../locale.zig").Locale;

/// Armenian locale: DD.MM.YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "հունվարի",   "փետրվարի",  "մարտի",     "ապրիլի",
        "մայիսի",     "հունիսի",   "հուլիսի",   "օգոստոսի",
        "սեպտեմբերի", "հոկտեմբերի", "նոյեմբերի", "դեկտեմբերի",
    },
    .month_names_short = .{
        "հնվ", "փտր", "մրտ", "ապր", "մյս", "հնս",
        "հլս", "օգս", "սպտ", "հկտ", "նմբ", "դկտ",
    },
    .day_names = .{
        "կիրակի",     "երկուշաբթի", "երեքշաբթի", "չորեքշաբթի",
        "հինգշաբթի",  "ուրբաթ",     "շաբաթ",
    },
    .day_names_short = .{
        "կրկ", "երկ", "երք", "չրք", "հնգ", "ուրբ", "շբթ",
    },
    .date_order = .dmy,
    .date_separator = '.',
    .time_24h = true,
    .am_label = "AM",
    .pm_label = "PM",
};
