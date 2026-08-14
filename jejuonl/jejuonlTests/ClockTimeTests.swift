import XCTest

final class ClockTimeTests: XCTestCase {
    func testClampedPreOpenLowerAndUpperBounds() {
        XCTAssertEqual(ClockTime(hour: 3, minute: 0).clampedPreOpen(), ClockTime(hour: 4, minute: 0))
        XCTAssertEqual(ClockTime(hour: 16, minute: 0).clampedPreOpen(), ClockTime(hour: 14, minute: 59))
        XCTAssertEqual(ClockTime(hour: 4, minute: 0).clampedPreOpen(), ClockTime(hour: 4, minute: 0))
        XCTAssertEqual(ClockTime(hour: 14, minute: 59).clampedPreOpen(), ClockTime(hour: 14, minute: 59))
        XCTAssertEqual(ClockTime(hour: 14, minute: 30).clampedPreOpen(), ClockTime(hour: 14, minute: 30))
    }

    func testClampedEveningLowerAndUpperBounds() {
        XCTAssertEqual(ClockTime(hour: 16, minute: 0).clampedEvening(), ClockTime(hour: 17, minute: 0))
        XCTAssertEqual(ClockTime(hour: 23, minute: 45).clampedEvening(), ClockTime(hour: 23, minute: 30))
        XCTAssertEqual(ClockTime(hour: 17, minute: 0).clampedEvening(), ClockTime(hour: 17, minute: 0))
        XCTAssertEqual(ClockTime(hour: 23, minute: 30).clampedEvening(), ClockTime(hour: 23, minute: 30))
        XCTAssertEqual(ClockTime(hour: 20, minute: 0).clampedEvening(), ClockTime(hour: 20, minute: 0))
    }

    func testAppSettingsDefaultAndPreview() {
        XCTAssertNil(AppSettings.default.city)
        XCTAssertTrue(AppSettings.default.hasCompletedOnboarding)
        XCTAssertNil(AppSettings.freshInstall.city)
        XCTAssertFalse(AppSettings.freshInstall.hasCompletedOnboarding)
        XCTAssertEqual(AppSettings.preview.city, .seogwipo)

        let prefs = NotificationPrefs.default
        XCTAssertFalse(prefs.isEnabled)
        XCTAssertEqual(prefs.preOpenTime, ClockTime(hour: 14, minute: 30))
        XCTAssertFalse(prefs.eveningEnabled)
        XCTAssertEqual(prefs.eveningTime, ClockTime(hour: 20, minute: 0))
        XCTAssertEqual(
            prefs.watchedRestricted,
            Set(WasteItem.allCases.filter(\.isWeekdayRestricted))
        )
        XCTAssertFalse(prefs.includeAlwaysOn)
    }
}
