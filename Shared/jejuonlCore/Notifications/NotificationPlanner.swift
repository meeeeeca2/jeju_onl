import Foundation

struct PlannedNotification: Equatable, Sendable {
    var id: String
    var fireDate: Date
    var dateComponents: DateComponents
    var title: String
    var body: String
}

enum NotificationPlanner {
    static func plan(settings: AppSettings, engine: ScheduleEngine, now: Date) -> [PlannedNotification] {
        guard let city = settings.city, settings.notifications.isEnabled else { return [] }
        guard let calendar = try? SeoulCalendar.make() else { return [] }

        let prefs = settings.notifications
        let preOpen = prefs.preOpenTime.clampedPreOpen()
        let evening = prefs.eveningTime.clampedEvening()
        let day0 = engine.snapshot(city: city, now: now).dischargeDayStart

        var planned: [PlannedNotification] = []
        for offset in 0...6 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: day0) else { continue }
            planned.append(contentsOf: planDay(
                day: day,
                city: city,
                engine: engine,
                prefs: prefs,
                preOpen: preOpen,
                evening: evening,
                now: now,
                calendar: calendar
            ))
        }
        return planned
    }

    private static func planDay(
        day: Date,
        city: CityID,
        engine: ScheduleEngine,
        prefs: NotificationPrefs,
        preOpen: ClockTime,
        evening: ClockTime,
        now: Date,
        calendar: Calendar
    ) -> [PlannedNotification] {
        let midday = instant(on: day, time: ClockTime(hour: 12, minute: 0), calendar: calendar)
        let restricted = engine.snapshot(city: city, now: midday).restrictedItems
        let intersection = restricted.filter { prefs.watchedRestricted.contains($0) }
        let quiet = intersection.isEmpty
        if quiet && !prefs.includeAlwaysOn { return [] }

        let stamp = dayStamp(day, calendar: calendar)
        var requests: [PlannedNotification] = []

        let preOpenFire = instant(on: day, time: preOpen, calendar: calendar)
        if preOpenFire > now {
            if quiet {
                requests.append(
                    PlannedNotification(
                        id: NotificationIdentity.preopen(dayStamp: stamp),
                        fireDate: preOpenFire,
                        dateComponents: triggerComponents(for: preOpenFire, calendar: calendar),
                        title: NotificationCopy.alwaysOnOnlyTitle,
                        body: NotificationCopy.alwaysOnOnlyBody
                    )
                )
            } else {
                requests.append(
                    PlannedNotification(
                        id: NotificationIdentity.preopen(dayStamp: stamp),
                        fireDate: preOpenFire,
                        dateComponents: triggerComponents(for: preOpenFire, calendar: calendar),
                        title: NotificationCopy.preopenTitle,
                        body: NotificationCopy.preopenBody(items: intersection, city: city)
                    )
                )
            }
        }

        if prefs.eveningEnabled && !quiet {
            let eveningFire = instant(on: day, time: evening, calendar: calendar)
            if eveningFire > now, engine.snapshot(city: city, now: eveningFire).window == .open {
                requests.append(
                    PlannedNotification(
                        id: NotificationIdentity.evening(dayStamp: stamp),
                        fireDate: eveningFire,
                        dateComponents: triggerComponents(for: eveningFire, calendar: calendar),
                        title: NotificationCopy.eveningTitle,
                        body: NotificationCopy.eveningBody(items: intersection)
                    )
                )
            }
        }

        return requests
    }

    private static func instant(on day: Date, time: ClockTime, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = time.hour
        components.minute = time.minute
        components.second = 0
        components.nanosecond = 0
        components.timeZone = calendar.timeZone
        guard let date = calendar.date(from: components) else {
            preconditionFailure("Seoul calendar failed to compose notification time")
        }
        return date
    }

    private static func triggerComponents(for fireDate: Date, calendar: Calendar) -> DateComponents {
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        components.second = 0
        components.timeZone = calendar.timeZone
        components.calendar = calendar
        return components
    }

    private static func dayStamp(_ date: Date, calendar: Calendar) -> String {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
