import Foundation

enum WidgetTimelineDates {
    /// `[now] + 다음 count개의 04:00/15:00`, 오름차순 유니크.
    static func timelineDates(from now: Date, count: Int = 4, calendar: Calendar) -> [Date] {
        var boundaries: [Date] = []
        var day = calendar.startOfDay(for: now)
        var guardDays = 0
        while boundaries.count < count && guardDays < 16 {
            for hour in [4, 15] {
                guard let candidate = date(hour: hour, on: day, calendar: calendar) else { continue }
                if candidate > now {
                    boundaries.append(candidate)
                    if boundaries.count == count { break }
                }
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
            guardDays += 1
        }

        var dates = [now] + boundaries
        dates.sort()
        var unique: [Date] = []
        unique.reserveCapacity(dates.count)
        for date in dates where unique.last != date {
            unique.append(date)
        }
        return unique
    }

    private static func date(hour: Int, on day: Date, calendar: Calendar) -> Date? {
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = hour
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components)
    }
}
