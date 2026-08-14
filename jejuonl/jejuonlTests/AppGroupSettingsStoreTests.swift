import XCTest

final class AppGroupSettingsStoreTests: XCTestCase {
    private var standardName: String!
    private var groupName: String!
    private var standard: UserDefaults!
    private var group: UserDefaults!

    override func setUp() {
        super.setUp()
        standardName = "jejuonl.tests.standard.\(UUID().uuidString)"
        groupName = "jejuonl.tests.group.\(UUID().uuidString)"
        standard = UserDefaults(suiteName: standardName)
        group = UserDefaults(suiteName: groupName)
        XCTAssertNotNil(standard)
        XCTAssertNotNil(group)
        standard.removePersistentDomain(forName: standardName)
        group.removePersistentDomain(forName: groupName)
    }

    override func tearDown() {
        if let standardName {
            standard?.removePersistentDomain(forName: standardName)
        }
        if let groupName {
            group?.removePersistentDomain(forName: groupName)
        }
        standard = nil
        group = nil
        super.tearDown()
    }

    func testMissingKeyIsFreshInstallOnboarding() {
        let store = AppGroupSettingsStore(
            standardDefaults: standard,
            groupDefaults: group,
            isAppGroupAvailable: false
        )
        let loaded = store.load()
        XCTAssertEqual(loaded, AppSettings.freshInstall)
        XCTAssertFalse(loaded.hasCompletedOnboarding)
        XCTAssertNil(loaded.city)
        XCTAssertTrue(AppSettings.default.hasCompletedOnboarding)
    }

    func testDecodeFailureIsDefaultNotOnboarding() {
        standard.set(Data("not-json".utf8), forKey: AppGroupSettingsStore.key)
        let store = AppGroupSettingsStore(
            standardDefaults: standard,
            groupDefaults: group,
            isAppGroupAvailable: false
        )
        let loaded = store.load()
        XCTAssertEqual(loaded, AppSettings.default)
        XCTAssertTrue(loaded.hasCompletedOnboarding)
    }

    func testDecodedSettingsAreKept() throws {
        let saved = AppSettings(
            city: .seogwipo,
            hasCompletedOnboarding: true,
            notifications: .default
        )
        let store = AppGroupSettingsStore(
            standardDefaults: standard,
            groupDefaults: group,
            isAppGroupAvailable: false
        )
        store.save(saved)
        XCTAssertEqual(store.load(), saved)
    }

    func testKeyInEitherStoreIsNotFreshInstall() throws {
        let saved = AppSettings(
            city: .jejuSi,
            hasCompletedOnboarding: true,
            notifications: .default
        )
        let data = try JSONEncoder().encode(saved)
        group.set(data, forKey: AppGroupSettingsStore.key)

        let store = AppGroupSettingsStore(
            standardDefaults: standard,
            groupDefaults: group,
            isAppGroupAvailable: true
        )
        XCTAssertEqual(store.load(), saved)
        XCTAssertTrue(store.load().hasCompletedOnboarding)
    }
}
