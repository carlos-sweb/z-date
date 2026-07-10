const Locale = @import("../locale.zig").Locale;

/// Georgian locale: DD/MM/YYYY, 12-hour clock.
pub const locale: Locale = .{
    .month_names = .{
        "იანვარი",     "თებერვალი", "მარტი",     "აპრილი",
        "მაისი",       "ივნისი",    "ივლისი",    "აგვისტო",
        "სექტემბერი", "ოქტომბერი", "ნოემბერი", "დეკემბერი",
    },
    .month_names_short = .{
        "იან", "თებ", "მარ", "აპრ", "მაი", "ივნ",
        "ივლ", "აგვ", "სექ", "ოქტ", "ნოე", "დეკ",
    },
    .day_names = .{
        "კვირა",     "ორშაბათი", "სამშაბათი", "ოთხშაბათი",
        "ხუთშაბათი", "პარასკევი", "შაბათი",
    },
    .day_names_short = .{
        "კვი", "ორშ", "სამ", "ოთხ", "ხუთ", "პარ", "შაბ",
    },
    .date_order = .dmy,
    .date_separator = '/',
    .time_24h = false,
    .am_label = "AM",
    .pm_label = "PM",
};
