const Locale = @import("../locale.zig").Locale;

/// Telugu locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "జనవరి",     "ఫిబ్రవరి", "మార్చి",   "ఏప్రిల్",
        "మే",         "జూన్",      "జులై",     "ఆగస్టు",
        "సెప్టెంబర్", "అక్టోబర్",  "నవంబర్",   "డిసెంబర్",
    },
    .month_names_short = .{
        "జన.", "ఫిబ్ర.", "మార్చి", "ఏప్రి.", "మే", "జూన్",
        "జులై", "ఆగ.",   "సెప.",   "అక్టో.", "నవ.", "డిసె.",
    },
    .day_names = .{
        "ఆదివారం", "సోమవారం", "మంగళవారం", "బుధవారం",
        "గురువారం", "శుక్రవారం", "శనివారం",
    },
    .day_names_short = .{
        "ఆది", "సోమ", "మంగళ", "బుధ", "గురు", "శుక్ర", "శని",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};
