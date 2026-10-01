import Foundation

/// 日期工具类
///
/// Date utilities
internal enum DateUtils {
    /// 计算给定日期的十进制年份
    ///
    /// Calculate decimal year from given date
    ///
    /// - Parameters:
    ///   - date: 输入日期
    ///     Input date
    ///   - calendar: 日历对象，默认为公历
    ///     Calendar object, default is Gregorian
    /// - Returns:
    ///   十进制年份值
    ///   Decimal year value
    static func decimalYear(
        from date: Date, calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> Double {
        var cal = calendar
        cal.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let year = cal.component(.year, from: date)
        let startOfYear = cal.date(from: DateComponents(timeZone: cal.timeZone, year: year, month: 1, day: 1)) ?? date
        let startOfNextYear =
            cal.date(from: DateComponents(timeZone: cal.timeZone, year: year + 1, month: 1, day: 1)) ?? date
        let yearLength = startOfNextYear.timeIntervalSince(startOfYear)
        let offset = date.timeIntervalSince(startOfYear)
        if yearLength <= 0 {
            return Double(year)
        }
        return Double(year) + offset / yearLength
    }
}
