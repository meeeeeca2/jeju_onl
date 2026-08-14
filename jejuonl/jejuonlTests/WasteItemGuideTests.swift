import XCTest
@testable import jejuonl

final class WasteItemGuideTests: XCTestCase {
    func testEveryItemHasNonEmptyTitleBodyAndMeta() {
        // Core types are compiled into both modules; the guide is app-target only.
        for city in jejuonl.CityID.allCases {
            for item in jejuonl.WasteItem.allCases {
                let guide = WasteItemGuide(item: item, city: city)
                XCTAssertFalse(guide.title.isEmpty, "\(item.rawValue) \(city.rawValue) title")
                XCTAssertFalse(guide.body.isEmpty, "\(item.rawValue) \(city.rawValue) body")
                XCTAssertFalse(guide.meta.isEmpty, "\(item.rawValue) \(city.rawValue) meta")
            }
        }
    }

    func testMetaMatchesWindowKind() {
        XCTAssertEqual(WasteItemGuide(item: .plastic, city: .jejuSi).meta, "요일제 · 15:00–04:00")
        XCTAssertEqual(WasteItemGuide(item: .clearPET, city: .jejuSi).meta, "요일제 · 15:00–04:00")
        XCTAssertEqual(WasteItemGuide(item: .food, city: .seogwipo).meta, "매일 · 24시간")
        XCTAssertEqual(WasteItemGuide(item: .general, city: .seogwipo).meta, "매일 · 15:00–04:00")
        XCTAssertEqual(WasteItemGuide(item: .canMetal, city: .jejuSi).meta, "매일 · 15:00–04:00")
    }

    func testSeogwipoPETNoteIsCityOnly() {
        let jeju = WasteItemGuide(item: .clearPET, city: .jejuSi)
        let seogwipo = WasteItemGuide(item: .clearPET, city: .seogwipo)
        XCTAssertFalse(jeju.extraLines.joined().contains("공식 요일표"))
        XCTAssertTrue(seogwipo.extraLines.joined().contains("공식 요일표"))
        XCTAssertTrue(jeju.body.contains("전용수거함"))
        XCTAssertFalse(seogwipo.body.contains("공식 요일표"))
    }

    func testJejuPlasticMentionsDedicatedPETBin() {
        let jeju = WasteItemGuide(item: .plastic, city: .jejuSi)
        let seogwipo = WasteItemGuide(item: .plastic, city: .seogwipo)
        XCTAssertTrue(jeju.body.contains("전용함"))
        XCTAssertFalse(seogwipo.body.contains("전용함"))
    }
}
