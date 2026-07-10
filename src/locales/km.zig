const Locale = @import("../locale.zig").Locale;

/// Khmer (Cambodian) locale: DD/MM/YYYY, 24-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "មករា",   "កុម្ភៈ", "មីនា",   "មេសា",
        "ឧសភា",   "មិថុនា", "កក្កដា", "សីហា",
        "កញ្ញា",  "តុលា",   "វិច្ឆិកា", "ធ្នូ",
    },
    .month_names_short = .{
        "មករា",   "កុម្ភៈ", "មីនា",   "មេសា",
        "ឧសភា",   "មិថុនា", "កក្កដា", "សីហា",
        "កញ្ញា",  "តុលា",   "វិច្ឆិកា", "ធ្នូ",
    },
    .day_names = .{
        "អាទិត្យ", "ច័ន្ទ", "អង្គារ", "ពុធ",
        "ព្រហស្បតិ៍", "សុក្រ", "សៅរ៍",
    },
    .day_names_short = .{
        "អា", "ច", "អ", "ព", "ព្រ", "សុ", "ស",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = true,
    .am_label = "ព្រឹក",
    .pm_label = "ល្ងាច",
};
