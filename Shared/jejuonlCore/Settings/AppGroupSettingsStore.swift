import Foundation

protocol SettingsStoring: AnyObject {
    func load() -> AppSettings
    func save(_ settings: AppSettings)
}

final class AppGroupSettingsStore: SettingsStoring {
    static let suiteName = "group.kr.jejuonl.shared"
    static let key = "settings.v1"

    private let standardDefaults: UserDefaults
    private let groupDefaults: UserDefaults?
    private let appGroupAvailableOverride: Bool?

    /// Entitlement + container present. `UserDefaults(suiteName:)` non-nil is not proof.
    var isAppGroupAvailable: Bool {
        if let appGroupAvailableOverride { return appGroupAvailableOverride }
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.suiteName
        ) != nil
    }

    /// Production uses standard + app-group defaults. Tests inject isolated suites.
    init(
        standardDefaults: UserDefaults = .standard,
        groupDefaults: UserDefaults? = nil,
        isAppGroupAvailable: Bool? = nil
    ) {
        self.standardDefaults = standardDefaults
        self.appGroupAvailableOverride = isAppGroupAvailable
        if isAppGroupAvailable != nil {
            self.groupDefaults = groupDefaults
        } else {
            self.groupDefaults = groupDefaults ?? UserDefaults(suiteName: Self.suiteName)
        }
    }

    func load() -> AppSettings {
        let standardHasKey = hasKey(standardDefaults)
        let groupHasKey = groupDefaults.map { hasKey($0) } ?? false

        if !standardHasKey && !groupHasKey {
            return .freshInstall
        }

        if isAppGroupAvailable, groupHasKey, let groupDefaults, let decoded = decode(groupDefaults) {
            return decoded
        }
        if standardHasKey, let decoded = decode(standardDefaults) {
            return decoded
        }
        if groupHasKey, let groupDefaults, let decoded = decode(groupDefaults) {
            return decoded
        }
        return .default
    }

    func save(_ settings: AppSettings) {
        guard let data = encode(settings) else { return }
        standardDefaults.set(data, forKey: Self.key)
        if isAppGroupAvailable {
            groupDefaults?.set(data, forKey: Self.key)
        }
    }

    private func hasKey(_ defaults: UserDefaults) -> Bool {
        defaults.object(forKey: Self.key) != nil
    }

    private func decode(_ defaults: UserDefaults) -> AppSettings? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        return try? JSONDecoder().decode(AppSettings.self, from: data)
    }

    private func encode(_ settings: AppSettings) -> Data? {
        try? JSONEncoder().encode(settings)
    }
}
