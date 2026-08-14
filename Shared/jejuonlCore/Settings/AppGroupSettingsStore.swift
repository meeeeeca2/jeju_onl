import Foundation

protocol SettingsStoring: AnyObject {
    func load() -> AppSettings
    func save(_ settings: AppSettings)
}

final class AppGroupSettingsStore: SettingsStoring {
    static let suiteName = "group.kr.jejuonl.shared"
    static let key = "settings.v1"

    /// Entitlement + container present. `UserDefaults(suiteName:)` non-nil is not proof.
    var isAppGroupAvailable: Bool {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.suiteName
        ) != nil
    }

    func load() -> AppSettings {
        if isAppGroupAvailable, let defaults = UserDefaults(suiteName: Self.suiteName) {
            return decode(defaults) ?? .default
        }
        return decode(UserDefaults.standard) ?? .default
    }

    func save(_ settings: AppSettings) {
        guard let data = encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
        if isAppGroupAvailable {
            UserDefaults(suiteName: Self.suiteName)?.set(data, forKey: Self.key)
        }
    }

    private func decode(_ defaults: UserDefaults) -> AppSettings? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(AppSettings.self, from: data)
    }

    private func encode(_ settings: AppSettings) -> Data? {
        try? JSONEncoder().encode(settings)
    }
}
