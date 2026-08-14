import XCTest

final class ScheduleCatalogTests: XCTestCase {
    func testBundleLoadDecodesDayStampAndFlags() throws {
        let catalog = try ScheduleCatalog.load(from: Bundle(for: CatalogBundleToken.self))
        XCTAssertEqual(catalog.schemaVersion, 1)
        XCTAssertEqual(catalog.version, "2025-06-06.1")
        XCTAssertEqual(catalog.verifiedAt, seoul("2026-07-13T00:00:00+09:00"))
        XCTAssertEqual(catalog.timezone, "Asia/Seoul")
        XCTAssertTrue(catalog.weekdayRestrictionEnabled(city: .jejuSi))
        XCTAssertTrue(catalog.weekdayRestrictionEnabled(city: .seogwipo))
        XCTAssertEqual(
            catalog.alwaysOnItems(city: .jejuSi),
            [.general, .food, .canMetal, .glass, .styrofoam]
        )
    }

    func testWeekdayTablesMatchOfficialSchedule() throws {
        let catalog = try ScheduleCatalog.load(from: Bundle(for: CatalogBundleToken.self))
        let jeju: [LocaleWeekday: [WasteItem]] = [
            .mon: [.plastic, .clearPET],
            .tue: [.paper, .incombustible],
            .wed: [.plastic, .clearPET],
            .thu: [.paper, .vinyl],
            .fri: [.plastic, .clearPET],
            .sat: [.paper, .incombustible],
            .sun: [.plastic, .clearPET, .vinyl],
        ]
        let seogwipo: [LocaleWeekday: [WasteItem]] = [
            .mon: [.plastic],
            .tue: [.paper, .incombustible],
            .wed: [.plastic],
            .thu: [.paper, .vinyl],
            .fri: [.plastic],
            .sat: [.paper, .incombustible],
            .sun: [.plastic, .vinyl],
        ]
        for weekday in LocaleWeekday.allCases {
            XCTAssertEqual(
                catalog.restrictedItems(city: .jejuSi, weekday: weekday),
                jeju[weekday],
                "jejuSi \(weekday.rawValue)"
            )
            XCTAssertEqual(
                catalog.restrictedItems(city: .seogwipo, weekday: weekday),
                seogwipo[weekday],
                "seogwipo \(weekday.rawValue)"
            )
        }
    }

    func testEngineRoundTripBothCitiesSevenDays() throws {
        let catalog = try ScheduleCatalog.load(from: Bundle(for: CatalogBundleToken.self))
        let engine = try ScheduleEngine(catalog: catalog)
        let jeju: [LocaleWeekday: [WasteItem]] = [
            .mon: [.plastic, .clearPET],
            .tue: [.paper, .incombustible],
            .wed: [.plastic, .clearPET],
            .thu: [.paper, .vinyl],
            .fri: [.plastic, .clearPET],
            .sat: [.paper, .incombustible],
            .sun: [.plastic, .clearPET, .vinyl],
        ]
        let seogwipo: [LocaleWeekday: [WasteItem]] = [
            .mon: [.plastic],
            .tue: [.paper, .incombustible],
            .wed: [.plastic],
            .thu: [.paper, .vinyl],
            .fri: [.plastic],
            .sat: [.paper, .incombustible],
            .sun: [.plastic, .vinyl],
        ]
        let days = [
            (seoul("2026-08-10T15:00:00+09:00"), LocaleWeekday.mon),
            (seoul("2026-08-11T15:00:00+09:00"), .tue),
            (seoul("2026-08-12T15:00:00+09:00"), .wed),
            (seoul("2026-08-13T15:00:00+09:00"), .thu),
            (seoul("2026-08-14T15:00:00+09:00"), .fri),
            (seoul("2026-08-15T15:00:00+09:00"), .sat),
            (seoul("2026-08-16T15:00:00+09:00"), .sun),
        ]
        for (now, weekday) in days {
            let jejuSnap = engine.snapshot(city: .jejuSi, now: now)
            XCTAssertEqual(jejuSnap.dischargeWeekday, weekday)
            XCTAssertEqual(jejuSnap.restrictedItems, jeju[weekday])
            let seogwipoSnap = engine.snapshot(city: .seogwipo, now: now)
            XCTAssertEqual(seogwipoSnap.dischargeWeekday, weekday)
            XCTAssertEqual(seogwipoSnap.restrictedItems, seogwipo[weekday])
            XCTAssertFalse(seogwipoSnap.restrictedItems.contains(.clearPET))
        }
    }

    func testUnknownItemStringThrows() throws {
        let json = """
        {
          "schemaVersion": 1,
          "catalogVersion": "test",
          "verifiedAt": "2026-07-13",
          "timezone": "Asia/Seoul",
          "sources": [],
          "window": {"openHour":15,"openMinute":0,"closeHour":4,"closeMinute":0},
          "alwaysOnItems": ["general"],
          "cities": {
            "jejuSi": {
              "displayName": "제주시",
              "effectiveFrom": "2025-06-06",
              "weekdayRestrictionEnabled": true,
              "notes": [],
              "restrictedByWeekday": { "mon": ["plasticBottle"] }
            }
          }
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try ScheduleCatalog.decode(json)) { error in
            XCTAssertEqual(error as? ScheduleEngineError, .catalogItemUnknown("plasticBottle"))
        }
    }

    func testRestrictionDisabledUsesCityUnionWithoutPETForSeogwipo() throws {
        let json = """
        {
          "schemaVersion": 1,
          "catalogVersion": "test",
          "verifiedAt": "2026-07-13",
          "timezone": "Asia/Seoul",
          "sources": [],
          "window": {"openHour":15,"openMinute":0,"closeHour":4,"closeMinute":0},
          "alwaysOnItems": ["general","food","canMetal","glass","styrofoam"],
          "cities": {
            "seogwipo": {
              "displayName": "서귀포시",
              "effectiveFrom": "2025-06-06",
              "weekdayRestrictionEnabled": false,
              "notes": [],
              "restrictedByWeekday": {
                "mon": ["plastic"],
                "tue": ["paper", "incombustible"],
                "wed": ["plastic"],
                "thu": ["paper", "vinyl"],
                "fri": ["plastic"],
                "sat": ["paper", "incombustible"],
                "sun": ["plastic", "vinyl"]
              }
            }
          }
        }
        """.data(using: .utf8)!

        let catalog = try ScheduleCatalog.decode(json)
        XCTAssertFalse(catalog.weekdayRestrictionEnabled(city: .seogwipo))
        let union = catalog.restrictedItems(city: .seogwipo, weekday: .mon)
        XCTAssertEqual(Set(union), Set([.plastic, .paper, .incombustible, .vinyl]))
        XCTAssertEqual(union.count, 4)
        XCTAssertFalse(union.contains(.clearPET))
        XCTAssertEqual(catalog.restrictedItems(city: .seogwipo, weekday: .sun), union)
    }

    func testOmittedWeekdayRestrictionEnabledDefaultsTrue() throws {
        let json = """
        {
          "schemaVersion": 1,
          "catalogVersion": "test",
          "verifiedAt": "2026-07-13",
          "timezone": "Asia/Seoul",
          "sources": [],
          "window": {"openHour":15,"openMinute":0,"closeHour":4,"closeMinute":0},
          "alwaysOnItems": ["general"],
          "cities": {
            "jejuSi": {
              "displayName": "제주시",
              "effectiveFrom": "2025-06-06",
              "notes": [],
              "restrictedByWeekday": { "fri": ["plastic"] }
            }
          }
        }
        """.data(using: .utf8)!

        let catalog = try ScheduleCatalog.decode(json)
        XCTAssertTrue(catalog.weekdayRestrictionEnabled(city: .jejuSi))
        XCTAssertEqual(catalog.restrictedItems(city: .jejuSi, weekday: .fri), [.plastic])
    }

    func testSchemaVersionTooNewThrows() throws {
        let json = """
        {
          "schemaVersion": 2,
          "catalogVersion": "test",
          "verifiedAt": "2026-07-13",
          "timezone": "Asia/Seoul",
          "sources": [],
          "window": {"openHour":15,"openMinute":0,"closeHour":4,"closeMinute":0},
          "alwaysOnItems": ["general"],
          "cities": {}
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try ScheduleCatalog.decode(json)) { error in
            XCTAssertEqual(error as? ScheduleEngineError, .catalogSchemaTooNew(2))
        }
    }

    func testMissingResourceThrowsCatalogMissing() {
        XCTAssertThrowsError(try ScheduleCatalog.load(from: Bundle(for: NSObject.self))) { error in
            XCTAssertEqual(error as? ScheduleEngineError, .catalogMissing)
        }
    }
}
