import SwiftUI
import UserNotifications
import WidgetKit

@main
struct jejuonlApp: App {
    @State private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
                    model.rescheduleNotifications()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                model.handleSceneActive()
            }
        }
    }
}

@Observable
final class AppModel {
    var settings: AppSettings
    var notificationDeniedBanner = false
    var pendingNotificationCount: Int?

    let persist: AppGroupSettingsStore
    let catalog: ScheduleCatalog?
    let engine: ScheduleEngine?
    let loadError: ScheduleEngineError?

    private let writes: Bool

    init(persist: AppGroupSettingsStore? = nil, preview: Bool = false) {
        let store = persist ?? AppGroupSettingsStore()
        self.persist = store
        self.writes = !preview
        self.settings = preview ? .preview : store.load()

        var loadedCatalog: ScheduleCatalog?
        var loadedEngine: ScheduleEngine?
        var loadedError: ScheduleEngineError?
        do {
            let loaded = try ScheduleCatalog.load()
            loadedCatalog = loaded
            loadedEngine = try ScheduleEngine(catalog: loaded)
        } catch let error as ScheduleEngineError {
            loadedError = error
        } catch {
            loadedError = .catalogMissing
        }
        catalog = loadedCatalog
        engine = loadedEngine
        loadError = loadedError

        if writes {
            NotificationScheduler.registerCategory()
        }
    }

    func selectCity(_ city: CityID) {
        settings.city = city
        persistIfNeeded()
        WidgetCenter.shared.reloadAllTimelines()
        rescheduleNotifications()
    }

    func handleSceneActive() {
        rescheduleNotifications()
        Task { await refreshNotificationStatus() }
    }

    func setNotificationsEnabled(_ enabled: Bool) async {
        if !enabled {
            applyNotificationPrefs { $0.isEnabled = false }
            return
        }
        if !writes {
            applyNotificationPrefs { $0.isEnabled = true }
            notificationDeniedBanner = false
            return
        }

        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings().authorizationStatus
        switch status {
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            if granted {
                applyNotificationPrefs { $0.isEnabled = true }
                notificationDeniedBanner = false
            } else {
                applyNotificationPrefs { $0.isEnabled = false }
                notificationDeniedBanner = true
            }
        case .denied:
            applyNotificationPrefs { $0.isEnabled = false }
            notificationDeniedBanner = true
        case .authorized, .ephemeral, .provisional:
            applyNotificationPrefs { $0.isEnabled = true }
            notificationDeniedBanner = false
        @unknown default:
            applyNotificationPrefs { $0.isEnabled = false }
            notificationDeniedBanner = true
        }
    }

    func updatePreOpenTime(_ time: ClockTime) {
        applyNotificationPrefs { $0.preOpenTime = time.clampedPreOpen() }
    }

    func updateEveningTime(_ time: ClockTime) {
        applyNotificationPrefs { $0.eveningTime = time.clampedEvening() }
    }

    func setEveningEnabled(_ enabled: Bool) {
        applyNotificationPrefs { prefs in
            prefs.eveningEnabled = enabled
            if enabled {
                prefs.eveningTime = prefs.eveningTime.clampedEvening()
            }
        }
    }

    func toggleWatched(_ item: WasteItem) {
        applyNotificationPrefs { prefs in
            if prefs.watchedRestricted.contains(item) {
                prefs.watchedRestricted.remove(item)
            } else {
                prefs.watchedRestricted.insert(item)
            }
        }
    }

    func setIncludeAlwaysOn(_ enabled: Bool) {
        applyNotificationPrefs { $0.includeAlwaysOn = enabled }
    }

    func rescheduleNotificationsNow() async {
        await performReschedule()
        await refreshPendingCount()
    }

    func refreshNotificationStatus() async {
        guard writes else { return }
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        if status == .denied {
            notificationDeniedBanner = true
            if settings.notifications.isEnabled {
                applyNotificationPrefs { $0.isEnabled = false }
            }
        } else if status == .authorized || status == .ephemeral || status == .provisional {
            notificationDeniedBanner = false
        }
        await refreshPendingCount()
    }

    func rescheduleNotifications() {
        guard writes else { return }
        Task { await performReschedule() }
    }

    private func applyNotificationPrefs(_ update: (inout NotificationPrefs) -> Void) {
        update(&settings.notifications)
        persistIfNeeded()
        rescheduleNotifications()
    }

    private func performReschedule() async {
        guard writes else { return }
        if let engine {
            await NotificationScheduler(engine: engine).reschedule(settings: settings, now: Date())
        } else {
            await NotificationScheduler.removePendingJejuBin()
        }
    }

    private func refreshPendingCount() async {
        guard writes else { return }
        pendingNotificationCount = await NotificationScheduler.pendingJejuBinCount()
    }

    private func persistIfNeeded() {
        guard writes else { return }
        persist.save(settings)
    }
}

#Preview("앱") {
    RootView()
        .environment(AppModel(preview: true))
}
