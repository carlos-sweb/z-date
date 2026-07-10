const Locale = @import("../locale.zig").Locale;

/// Kannada locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "ಜನವರಿ",     "ಫೆಬ್ರವರಿ", "ಮಾರ್ಚ್",   "ಏಪ್ರಿಲ್",
        "ಮೇ",         "ಜೂನ್",     "ಜುಲೈ",     "ಆಗಸ್ಟ್",
        "ಸೆಪ್ಟೆಂಬರ್", "ಅಕ್ಟೋಬರ್", "ನವೆಂಬರ್", "ಡಿಸೆಂಬರ್",
    },
    .month_names_short = .{
        "ಜನ",      "ಫೆಬ್ರ",   "ಮಾರ್ಚ್", "ಏಪ್ರಿಲ್",
        "ಮೇ",       "ಜೂನ್",     "ಜುಲೈ",   "ಆಗಸ್ಟ್",
        "ಸೆಪ್ಟೆಂ", "ಅಕ್ಟೋ",   "ನವೆಂ",   "ಡಿಸೆಂ",
    },
    .day_names = .{
        "ಭಾನುವಾರ", "ಸೋಮವಾರ",  "ಮಂಗಳವಾರ", "ಬುಧವಾರ",
        "ಗುರುವಾರ", "ಶುಕ್ರವಾರ", "ಶನಿವಾರ",
    },
    .day_names_short = .{
        "ಭಾನು", "ಸೋಮ", "ಮಂಗಳ", "ಬುಧ", "ಗುರು", "ಶುಕ್ರ", "ಶನಿ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};
