import SwiftUI
import WidgetKit

@main
struct jejuonlApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
        }
    }
}

@Observable
final class AppModel {
    var settings: AppSettings

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
    }

    func selectCity(_ city: CityID) {
        settings.city = city
        persistIfNeeded()
        WidgetCenter.shared.reloadAllTimelines()
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
