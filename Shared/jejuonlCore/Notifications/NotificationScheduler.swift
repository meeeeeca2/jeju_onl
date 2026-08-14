import Foundation
import UserNotifications

struct NotificationScheduler: Sendable {
    var engine: ScheduleEngine
    var center: UNUserNotificationCenter

    init(engine: ScheduleEngine, center: UNUserNotificationCenter = .current()) {
        self.engine = engine
        self.center = center
    }

    /// Clears pending `jejubin.*` requests, then adds planner output as one-shot Seoul calendar triggers.
    func reschedule(settings: AppSettings, now: Date) async {
        await Self.removePendingJejuBin(on: center)
        let planned = NotificationPlanner.plan(settings: settings, engine: engine, now: now)
        for item in planned {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default
            content.categoryIdentifier = NotificationIdentity.category

            let trigger = UNCalendarNotificationTrigger(dateMatching: item.dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: item.id, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    static func registerCategory(on center: UNUserNotificationCenter = .current()) {
        let open = UNNotificationAction(
            identifier: NotificationIdentity.openToday,
            title: "오늘 보기",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: NotificationIdentity.category,
            actions: [open],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
    }

    static func removePendingJejuBin(on center: UNUserNotificationCenter = .current()) async {
        let pending = await center.pendingNotificationRequests()
        let identifiers = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(NotificationIdentity.idPrefix) }
        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    static func pendingJejuBinCount(on center: UNUserNotificationCenter = .current()) async -> Int {
        let pending = await center.pendingNotificationRequests()
        return pending.filter { $0.identifier.hasPrefix(NotificationIdentity.idPrefix) }.count
    }
}
