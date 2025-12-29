/// Z-Date Error Types
/// ECMAScript-compatible date/time library errors

pub const ZDateError = error{
    /// Memory allocation failed
    OutOfMemory,

    /// Invalid date representation
    InvalidDate,

    /// Invalid date string format
    InvalidFormat,

    /// Timestamp out of valid range
    OutOfRange,

    /// Invalid timezone specification
    InvalidTimezone,

    /// Failed to parse date string
    ParseError,

    /// Invalid date component value
    InvalidComponent,

    /// Timestamp calculation overflow
    TimestampOverflow,

    /// Invalid year value
    InvalidYear,

    /// Invalid month value (must be 0-11)
    InvalidMonth,

    /// Invalid day value (must be 1-31)
    InvalidDay,
};
