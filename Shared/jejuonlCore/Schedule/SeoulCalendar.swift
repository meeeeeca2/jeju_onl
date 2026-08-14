import Foundation

enum SeoulCalendar {
    static func make() throws -> Calendar {
        guard let tz = TimeZone(identifier: "Asia/Seoul") else {
            throw ScheduleEngineError.missingTimeZone
        }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        cal.locale = Locale(identifier: "ko_KR")
        return cal
    }

    /// Gregorian weekday: 1 = Sunday … 7 = Saturday. firstWeekday는 무시.
    static func weekday(from date: Date, calendar: Calendar) -> LocaleWeekday {
        switch calendar.component(.weekday, from: date) {
        case 1: return .sun
        case 2: return .mon
        case 3: return .tue
        case 4: return .wed
        case 5: return .thu
        case 6: return .fri
        case 7: return .sat
        default: preconditionFailure("Gregorian weekday out of 1...7")
        }
    }
}
