import XCTest

final class NotificationPlannerTests: XCTestCase {
    private var engine: ScheduleEngine!

    override func setUpWithError() throws {
        let catalog = try ScheduleCatalog.load(from: Bundle(for: CatalogBundleToken.self))
        engine = try ScheduleEngine(catalog: catalog)
    }

    func testTuesdaySeogwipoPlasticOnlyHasNoTuesdayPreopen() {
        var prefs = NotificationPrefs.default
        prefs.isEnabled = true
        prefs.watchedRestricted = [.plastic]
        prefs.includeAlwaysOn = false
        let settings = AppSettings(city: .seogwipo, hasCompletedOnboarding: true, notifications: prefs)

        let tuesdayMorning = plan(settings, now: seoul("2026-08-11T10:00:00+09:00"))
        XCTAssertFalse(tuesdayMorning.contains { $0.id == "jejubin.preopen.2026-08-11" })

        let mondayEvening = plan(settings, now: seoul("2026-08-10T20:00:00+09:00"))
        XCTAssertFalse(mondayEvening.contains { $0.id == "jejubin.preopen.2026-08-11" })
    }

    func testFridayJejuPreopenUsesSeoulTriggerAndCityCopy() {
        var prefs = NotificationPrefs.default
        prefs.isEnabled = true
        let settings = AppSettings(city: .jejuSi, hasCompletedOnboarding: true, notifications: prefs)
        let planned = plan(settings, now: seoul("2026-08-14T10:00:00+09:00"))
        let friday = planned.filter { $0.id == "jejubin.preopen.2026-08-14" }
        XCTAssertEqual(friday.count, 1)
        XCTAssertEqual(friday[0].title, NotificationCopy.preopenTitle)
        XCTAssertEqual(friday[0].body, "플라스틱, 투명페트병 · 15:00–내일 04:00 · 제주시")
        XCTAssertTrue(friday[0].body.contains("제주시"))
        XCTAssertEqual(friday[0].dateComponents.timeZone?.identifier, "Asia/Seoul")
        XCTAssertEqual(friday[0].dateComponents.year, 2026)
        XCTAssertEqual(friday[0].dateComponents.month, 8)
        XCTAssertEqual(friday[0].dateComponents.day, 14)
        XCTAssertEqual(friday[0].dateComponents.hour, 14)
        XCTAssertEqual(friday[0].dateComponents.minute, 30)
        XCTAssertEqual(friday[0].fireDate, seoul("2026-08-14T14:30:00+09:00"))
    }

    func testSundayBodyContainsPETOnlyForJeju() {
        var prefs = NotificationPrefs.default
        prefs.isEnabled = true
        let now = seoul("2026-08-16T10:00:00+09:00")

        let jeju = plan(
            AppSettings(city: .jejuSi, hasCompletedOnboarding: true, notifications: prefs),
            now: now
        )
        let jejuSunday = jeju.first { $0.id == "jejubin.preopen.2026-08-16" }
        XCTAssertNotNil(jejuSunday)
        XCTAssertTrue(jejuSunday?.body.contains("투명페트") == true)
        XCTAssertEqual(
            jejuSunday?.body,
            "플라스틱, 투명페트병, 비닐류 · 15:00–내일 04:00 · 제주시"
        )

        let seogwipo = plan(
            AppSettings(city: .seogwipo, hasCompletedOnboarding: true, notifications: prefs),
            now: now
        )
        let seogwipoSunday = seogwipo.first { $0.id == "jejubin.preopen.2026-08-16" }
        XCTAssertNotNil(seogwipoSunday)
        XCTAssertFalse(seogwipoSunday?.body.contains("투명페트") == true)
        XCTAssertEqual(
            seogwipoSunday?.body,
            "플라스틱, 비닐류 · 15:00–내일 04:00 · 서귀포시"
        )
    }

    func testIncludeAlwaysOnEmptyIntersectionCopyHasNoEonjedeun() {
        var prefs = NotificationPrefs.default
        prefs.isEnabled = true
        prefs.watchedRestricted = [.plastic]
        prefs.includeAlwaysOn = true
        prefs.eveningEnabled = true
        let settings = AppSettings(city: .seogwipo, hasCompletedOnboarding: true, notifications: prefs)
        let planned = plan(settings, now: seoul("2026-08-11T10:00:00+09:00"))
        let tuesday = planned.first { $0.id == "jejubin.preopen.2026-08-11" }
        XCTAssertEqual(tuesday?.title, NotificationCopy.alwaysOnOnlyTitle)
        XCTAssertEqual(tuesday?.body, NotificationCopy.alwaysOnOnlyBody)
        XCTAssertTrue(tuesday?.body.contains("15:00") == true)
        XCTAssertTrue(tuesday?.body.contains("음식물만 지금") == true)
        XCTAssertFalse(tuesday?.body.contains("언제든") == true)
        XCTAssertFalse(NotificationCopy.alwaysOnOnlyBody.contains("언제든"))
        XCTAssertFalse(planned.contains { $0.id == "jejubin.evening.2026-08-11" })
    }

    func testCityNilOrMasterOffYieldsNoRequests() {
        var on = NotificationPrefs.default
        on.isEnabled = true
        let noCity = AppSettings(city: nil, hasCompletedOnboarding: true, notifications: on)
        XCTAssertTrue(plan(noCity, now: seoul("2026-08-14T10:00:00+09:00")).isEmpty)

        var off = NotificationPrefs.default
        off.isEnabled = false
        let cityOff = AppSettings(city: .jejuSi, hasCompletedOnboarding: true, notifications: off)
        XCTAssertTrue(plan(cityOff, now: seoul("2026-08-14T10:00:00+09:00")).isEmpty)
    }

    func testMonday0200UsesSundayAsDischargeDayZero() {
        var prefs = NotificationPrefs.default
        prefs.isEnabled = true
        let settings = AppSettings(city: .jejuSi, hasCompletedOnboarding: true, notifications: prefs)
        let planned = plan(settings, now: seoul("2026-08-17T02:00:00+09:00"))
        let ids = planned.map(\.id)
        XCTAssertFalse(ids.contains("jejubin.preopen.2026-08-16"))
        XCTAssertTrue(ids.contains("jejubin.preopen.2026-08-17"))
        XCTAssertTrue(ids.contains("jejubin.preopen.2026-08-22"))
        XCTAssertFalse(ids.contains("jejubin.preopen.2026-08-23"))
        XCTAssertEqual(planned.filter { $0.id.hasPrefix("jejubin.preopen.") }.count, 6)
    }

    func testPreopenAtOrBeforeNowIsSkipped() {
        var prefs = NotificationPrefs.default
        prefs.isEnabled = true
        let settings = AppSettings(city: .jejuSi, hasCompletedOnboarding: true, notifications: prefs)

        let atTime = plan(settings, now: seoul("2026-08-14T14:30:00+09:00"))
        XCTAssertFalse(atTime.contains { $0.id == "jejubin.preopen.2026-08-14" })

        let afterTime = plan(settings, now: seoul("2026-08-14T14:31:00+09:00"))
        XCTAssertFalse(afterTime.contains { $0.id == "jejubin.preopen.2026-08-14" })

        let beforeTime = plan(settings, now: seoul("2026-08-14T14:29:00+09:00"))
        XCTAssertTrue(beforeTime.contains { $0.id == "jejubin.preopen.2026-08-14" })
    }

    func testEveningOpenCopyAndPlannerClampsPreOpen() {
        var prefs = NotificationPrefs.default
        prefs.isEnabled = true
        prefs.eveningEnabled = true
        prefs.preOpenTime = ClockTime(hour: 16, minute: 0)
        let settings = AppSettings(city: .jejuSi, hasCompletedOnboarding: true, notifications: prefs)
        let planned = plan(settings, now: seoul("2026-08-16T10:00:00+09:00"))

        let evening = planned.first { $0.id == "jejubin.evening.2026-08-16" }
        XCTAssertEqual(evening?.title, NotificationCopy.eveningTitle)
        XCTAssertEqual(evening?.body, "플라스틱, 투명페트병, 비닐류 · 창구 내일 04:00에 닫혀요")
        XCTAssertEqual(evening?.dateComponents.timeZone?.identifier, "Asia/Seoul")
        XCTAssertEqual(evening?.dateComponents.hour, 20)
        XCTAssertEqual(evening?.dateComponents.minute, 0)

        let preopen = planned.first { $0.id == "jejubin.preopen.2026-08-16" }
        XCTAssertEqual(preopen?.dateComponents.hour, 14)
        XCTAssertEqual(preopen?.dateComponents.minute, 59)
    }

    private func plan(_ settings: AppSettings, now: Date) -> [PlannedNotification] {
        NotificationPlanner.plan(settings: settings, engine: engine, now: now)
    }
}
