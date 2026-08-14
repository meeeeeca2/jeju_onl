import Foundation

enum AppIdentity {
    static let displayName = "오늘 뭐 버려?"
}

enum DischargeDayText {
    static func header(weekday: LocaleWeekday, dischargeDayStart: Date) -> String {
        guard let calendar = try? SeoulCalendar.make() else { return "" }
        let month = calendar.component(.month, from: dischargeDayStart)
        let day = calendar.component(.day, from: dischargeDayStart)
        return "\(weekday.koreanName) · \(month)월 \(day)일"
    }
}

enum SeoulClockText {
    static func hm(_ date: Date) -> String {
        guard let calendar = try? SeoulCalendar.make() else { return "" }
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return String(format: "%02d:%02d", hour, minute)
    }

    static func windowRange(open: Date, close: Date) -> String {
        "\(hm(open)) – \(hm(close))"
    }

    static func clock(_ time: ClockTime) -> String {
        String(format: "%d:%02d", time.hour, time.minute)
    }

    static func dayStamp(_ date: Date) -> String {
        guard let tz = TimeZone(identifier: "Asia/Seoul") else { return "" }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = tz
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

enum CatalogFreshness {
    static func isStale(verifiedAt: Date, now: Date) -> Bool {
        guard let calendar = try? SeoulCalendar.make(),
              let cutoff = calendar.date(byAdding: .day, value: 180, to: verifiedAt) else {
            return false
        }
        return now > cutoff
    }
}
