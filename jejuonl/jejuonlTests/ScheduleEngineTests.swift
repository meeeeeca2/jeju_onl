import XCTest

final class ScheduleEngineTests: XCTestCase {
    private var engine: ScheduleEngine!

    override func setUpWithError() throws {
        let catalog = try ScheduleCatalog.load(from: Bundle(for: CatalogBundleToken.self))
        engine = try ScheduleEngine(catalog: catalog)
    }

    func testE1_friday1459_jejuSi_beforeOpen_plasticPET() throws {
        let now = seoul("2026-08-14T14:59:00+09:00")
        let snap = engine.snapshot(city: .jejuSi, now: now)
        assertSnapshot(
            snap,
            city: .jejuSi,
            now: now,
            dayStart: seoul("2026-08-14T00:00:00+09:00"),
            weekday: .fri,
            window: .beforeOpen,
            restricted: [.plastic, .clearPET]
        )
        XCTAssertEqual(snap.nextRestrictedChange, seoul("2026-08-15T04:00:00+09:00"))
        XCTAssertEqual(snap.nextWindowToggle, seoul("2026-08-14T15:00:00+09:00"))
        XCTAssertEqual(snap.windowOpen, seoul("2026-08-14T15:00:00+09:00"))
        XCTAssertEqual(snap.windowClose, seoul("2026-08-15T04:00:00+09:00"))
    }

    func testE2_friday1500_jejuSi_open_sameItems() throws {
        let now = seoul("2026-08-14T15:00:00+09:00")
        let snap = engine.snapshot(city: .jejuSi, now: now)
        assertSnapshot(
            snap,
            city: .jejuSi,
            now: now,
            dayStart: seoul("2026-08-14T00:00:00+09:00"),
            weekday: .fri,
            window: .open,
            restricted: [.plastic, .clearPET]
        )
        XCTAssertEqual(snap.nextRestrictedChange, seoul("2026-08-15T04:00:00+09:00"))
        XCTAssertEqual(snap.nextWindowToggle, seoul("2026-08-15T04:00:00+09:00"))
    }

    func testE3_saturday0359_jejuSi_stillFridayOpen() throws {
        let now = seoul("2026-08-15T03:59:00+09:00")
        let snap = engine.snapshot(city: .jejuSi, now: now)
        assertSnapshot(
            snap,
            city: .jejuSi,
            now: now,
            dayStart: seoul("2026-08-14T00:00:00+09:00"),
            weekday: .fri,
            window: .open,
            restricted: [.plastic, .clearPET]
        )
        XCTAssertEqual(snap.nextRestrictedChange, seoul("2026-08-15T04:00:00+09:00"))
        XCTAssertEqual(snap.nextWindowToggle, seoul("2026-08-15T04:00:00+09:00"))
    }

    func testE4_saturday0400_jejuSi_saturdayBeforeOpen() throws {
        let now = seoul("2026-08-15T04:00:00+09:00")
        let snap = engine.snapshot(city: .jejuSi, now: now)
        assertSnapshot(
            snap,
            city: .jejuSi,
            now: now,
            dayStart: seoul("2026-08-15T00:00:00+09:00"),
            weekday: .sat,
            window: .beforeOpen,
            restricted: [.paper, .incombustible]
        )
        XCTAssertEqual(snap.nextRestrictedChange, seoul("2026-08-16T04:00:00+09:00"))
        XCTAssertEqual(snap.nextWindowToggle, seoul("2026-08-15T15:00:00+09:00"))
    }

    func testE5_sunday1500_jejuSi_open_plasticPETVinyl() throws {
        let now = seoul("2026-08-16T15:00:00+09:00")
        let snap = engine.snapshot(city: .jejuSi, now: now)
        assertSnapshot(
            snap,
            city: .jejuSi,
            now: now,
            dayStart: seoul("2026-08-16T00:00:00+09:00"),
            weekday: .sun,
            window: .open,
            restricted: [.plastic, .clearPET, .vinyl]
        )
        XCTAssertEqual(snap.nextRestrictedChange, seoul("2026-08-17T04:00:00+09:00"))
        XCTAssertEqual(snap.nextWindowToggle, seoul("2026-08-17T04:00:00+09:00"))
    }

    func testE6_sunday1500_seogwipo_open_plasticVinyl_noPET() throws {
        let now = seoul("2026-08-16T15:00:00+09:00")
        let snap = engine.snapshot(city: .seogwipo, now: now)
        assertSnapshot(
            snap,
            city: .seogwipo,
            now: now,
            dayStart: seoul("2026-08-16T00:00:00+09:00"),
            weekday: .sun,
            window: .open,
            restricted: [.plastic, .vinyl]
        )
        XCTAssertFalse(snap.restrictedItems.contains(.clearPET))
    }

    func testE7_thursday1200_seogwipo_beforeOpen_paperVinyl() throws {
        let now = seoul("2026-08-13T12:00:00+09:00")
        let snap = engine.snapshot(city: .seogwipo, now: now)
        assertSnapshot(
            snap,
            city: .seogwipo,
            now: now,
            dayStart: seoul("2026-08-13T00:00:00+09:00"),
            weekday: .thu,
            window: .beforeOpen,
            restricted: [.paper, .vinyl]
        )
        XCTAssertEqual(snap.nextRestrictedChange, seoul("2026-08-14T04:00:00+09:00"))
        XCTAssertEqual(snap.nextWindowToggle, seoul("2026-08-13T15:00:00+09:00"))
    }

    func testE8_monday0030_jejuSi_stillSundayOpen() throws {
        let now = seoul("2026-08-17T00:30:00+09:00")
        let snap = engine.snapshot(city: .jejuSi, now: now)
        assertSnapshot(
            snap,
            city: .jejuSi,
            now: now,
            dayStart: seoul("2026-08-16T00:00:00+09:00"),
            weekday: .sun,
            window: .open,
            restricted: [.plastic, .clearPET, .vinyl]
        )
        XCTAssertEqual(snap.nextRestrictedChange, seoul("2026-08-17T04:00:00+09:00"))
        XCTAssertEqual(snap.nextWindowToggle, seoul("2026-08-17T04:00:00+09:00"))
    }

    func testE9_monday0400_jejuSi_mondayBeforeOpen() throws {
        let now = seoul("2026-08-17T04:00:00+09:00")
        let snap = engine.snapshot(city: .jejuSi, now: now)
        assertSnapshot(
            snap,
            city: .jejuSi,
            now: now,
            dayStart: seoul("2026-08-17T00:00:00+09:00"),
            weekday: .mon,
            window: .beforeOpen,
            restricted: [.plastic, .clearPET]
        )
        XCTAssertEqual(snap.nextRestrictedChange, seoul("2026-08-18T04:00:00+09:00"))
        XCTAssertEqual(snap.nextWindowToggle, seoul("2026-08-17T15:00:00+09:00"))
    }

    func testE10_monday0200_weekIsPreviousMondayThroughSunday() throws {
        let now = seoul("2026-08-17T02:00:00+09:00")
        let snap = engine.snapshot(city: .jejuSi, now: now)
        XCTAssertEqual(snap.dischargeDayStart, seoul("2026-08-16T00:00:00+09:00"))
        XCTAssertEqual(snap.dischargeWeekday, .sun)
        XCTAssertEqual(snap.window, .open)

        let week = engine.week(city: .jejuSi, containing: now)
        XCTAssertEqual(week.count, 7)

        let expectedStarts = [
            "2026-08-10T00:00:00+09:00",
            "2026-08-11T00:00:00+09:00",
            "2026-08-12T00:00:00+09:00",
            "2026-08-13T00:00:00+09:00",
            "2026-08-14T00:00:00+09:00",
            "2026-08-15T00:00:00+09:00",
            "2026-08-16T00:00:00+09:00",
        ].map(seoul)
        let expectedNows = [
            "2026-08-10T15:00:00+09:00",
            "2026-08-11T15:00:00+09:00",
            "2026-08-12T15:00:00+09:00",
            "2026-08-13T15:00:00+09:00",
            "2026-08-14T15:00:00+09:00",
            "2026-08-15T15:00:00+09:00",
            "2026-08-16T15:00:00+09:00",
        ].map(seoul)
        let expectedWeekdays: [LocaleWeekday] = [.mon, .tue, .wed, .thu, .fri, .sat, .sun]

        XCTAssertEqual(week.map(\.dischargeDayStart), expectedStarts)
        XCTAssertEqual(week.map(\.now), expectedNows)
        XCTAssertEqual(week.map(\.dischargeWeekday), expectedWeekdays)
        XCTAssertTrue(week.allSatisfy { $0.window == .open })
        XCTAssertFalse(week.contains { $0.dischargeDayStart == seoul("2026-08-17T00:00:00+09:00") })

        let highlight = week.first { $0.dischargeDayStart == snap.dischargeDayStart }
        XCTAssertEqual(highlight?.dischargeWeekday, .sun)
        XCTAssertEqual(highlight?.now, seoul("2026-08-16T15:00:00+09:00"))
    }

    func testNextRestrictedChangeIsAlwaysNext0400() throws {
        let beforeOpen = engine.snapshot(city: .jejuSi, now: seoul("2026-08-14T14:59:00+09:00"))
        let open = engine.snapshot(city: .jejuSi, now: seoul("2026-08-14T16:00:00+09:00"))
        XCTAssertEqual(beforeOpen.nextRestrictedChange, seoul("2026-08-15T04:00:00+09:00"))
        XCTAssertEqual(open.nextRestrictedChange, seoul("2026-08-15T04:00:00+09:00"))
        XCTAssertEqual(beforeOpen.nextWindowToggle, beforeOpen.windowOpen)
        XCTAssertEqual(open.nextWindowToggle, open.windowClose)
    }

    private func assertSnapshot(
        _ snap: DischargeSnapshot,
        city: CityID,
        now: Date,
        dayStart: Date,
        weekday: LocaleWeekday,
        window: WindowState,
        restricted: [WasteItem],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(snap.city, city, file: file, line: line)
        XCTAssertEqual(snap.now, now, file: file, line: line)
        XCTAssertEqual(snap.dischargeDayStart, dayStart, file: file, line: line)
        XCTAssertEqual(snap.dischargeWeekday, weekday, file: file, line: line)
        XCTAssertEqual(snap.window, window, file: file, line: line)
        XCTAssertEqual(snap.restrictedItems, restricted, file: file, line: line)
        XCTAssertEqual(
            snap.alwaysOnItems,
            [.general, .food, .canMetal, .glass, .styrofoam],
            file: file,
            line: line
        )
        XCTAssertEqual(snap.catalogVersion, "2025-06-06.1", file: file, line: line)
        XCTAssertEqual(snap.nextRestrictedChange, snap.windowClose, file: file, line: line)
        XCTAssertEqual(
            snap.nextWindowToggle,
            window == .beforeOpen ? snap.windowOpen : snap.windowClose,
            file: file,
            line: line
        )
    }
}

func seoul(_ iso: String) -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    guard let date = formatter.date(from: iso) else {
        preconditionFailure("invalid Seoul fixture: \(iso)")
    }
    return date
}
