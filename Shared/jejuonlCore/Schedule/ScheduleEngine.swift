import Foundation

struct ScheduleEngine: Sendable {
    var catalog: ScheduleCataloging
    var timeZone: TimeZone

    init(catalog: ScheduleCataloging, timeZone: TimeZone) {
        self.catalog = catalog
        self.timeZone = timeZone
    }

    init(catalog: ScheduleCataloging) throws {
        try self.init(catalog: catalog, timeZone: SeoulCalendar.make().timeZone)
    }

    func snapshot(city: CityID, now: Date) -> DischargeSnapshot {
        let calendar = makeCalendar()
        let dischargeDayStart = dischargeDay(now: now, calendar: calendar)
        let dischargeWeekday = SeoulCalendar.weekday(from: dischargeDayStart, calendar: calendar)
        let nextCalendarDay = addingDays(1, to: dischargeDayStart, calendar: calendar)
        let windowOpen = setting(hour: 15, minute: 0, second: 0, of: dischargeDayStart, calendar: calendar)
        let windowClose = setting(hour: 4, minute: 0, second: 0, of: nextCalendarDay, calendar: calendar)
        let window: WindowState = now < windowOpen ? .beforeOpen : .open
        return DischargeSnapshot(
            city: city,
            now: now,
            dischargeDayStart: dischargeDayStart,
            dischargeWeekday: dischargeWeekday,
            window: window,
            windowOpen: windowOpen,
            windowClose: windowClose,
            restrictedItems: catalog.restrictedItems(city: city, weekday: dischargeWeekday),
            alwaysOnItems: catalog.alwaysOnItems(city: city),
            nextRestrictedChange: windowClose,
            nextWindowToggle: window == .beforeOpen ? windowOpen : windowClose,
            catalogVersion: catalog.version
        )
    }

    /// `now`가 아니라 dischargeDayStart 가 속한 월–일 7장.
    /// 각 원소의 `now`는 그 배출일 15:00.
    func week(city: CityID, containing now: Date) -> [DischargeSnapshot] {
        let calendar = makeCalendar()
        let day0 = snapshot(city: city, now: now).dischargeDayStart
        let monday = mondayStart(containing: day0, calendar: calendar)
        return (0...6).map { offset in
            let day = addingDays(offset, to: monday, calendar: calendar)
            let atOpen = setting(hour: 15, minute: 0, second: 0, of: day, calendar: calendar)
            return snapshot(city: city, now: atOpen)
        }
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }

    private func dischargeDay(now: Date, calendar: Calendar) -> Date {
        let start = calendar.startOfDay(for: now)
        if calendar.component(.hour, from: now) < 4 {
            return addingDays(-1, to: start, calendar: calendar)
        }
        return start
    }

    private func mondayStart(containing day: Date, calendar: Calendar) -> Date {
        let daysFromMonday: Int
        switch SeoulCalendar.weekday(from: day, calendar: calendar) {
        case .mon: daysFromMonday = 0
        case .tue: daysFromMonday = 1
        case .wed: daysFromMonday = 2
        case .thu: daysFromMonday = 3
        case .fri: daysFromMonday = 4
        case .sat: daysFromMonday = 5
        case .sun: daysFromMonday = 6
        }
        return addingDays(-daysFromMonday, to: day, calendar: calendar)
    }

    private func addingDays(_ value: Int, to date: Date, calendar: Calendar) -> Date {
        guard let shifted = calendar.date(byAdding: .day, value: value, to: date) else {
            preconditionFailure("Seoul calendar failed to add \(value) day(s)")
        }
        return shifted
    }

    private func setting(hour: Int, minute: Int, second: Int, of date: Date, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = 0
        guard let composed = calendar.date(from: components) else {
            preconditionFailure("Seoul calendar failed to compose \(hour):\(minute):\(second)")
        }
        return composed
    }
}
