import XCTest

final class WidgetTimelineDatesTests: XCTestCase {
    private var calendar: Calendar!

    override func setUpWithError() throws {
        calendar = try SeoulCalendar.make()
    }

    func testFriday1400_nextFourBoundaries() throws {
        let now = seoul("2026-08-14T14:00:00+09:00")
        let dates = WidgetTimelineDates.timelineDates(from: now, count: 4, calendar: calendar)
        XCTAssertEqual(dates.first, now)
        XCTAssertEqual(Array(dates.dropFirst()), [
            seoul("2026-08-14T15:00:00+09:00"),
            seoul("2026-08-15T04:00:00+09:00"),
            seoul("2026-08-15T15:00:00+09:00"),
            seoul("2026-08-16T04:00:00+09:00"),
        ])
        assertStrictlyIncreasing(dates)
    }

    func testFriday1600_nextFourBoundaries() throws {
        let now = seoul("2026-08-14T16:00:00+09:00")
        let dates = WidgetTimelineDates.timelineDates(from: now, count: 4, calendar: calendar)
        XCTAssertEqual(dates.first, now)
        XCTAssertEqual(Array(dates.dropFirst()), [
            seoul("2026-08-15T04:00:00+09:00"),
            seoul("2026-08-15T15:00:00+09:00"),
            seoul("2026-08-16T04:00:00+09:00"),
            seoul("2026-08-16T15:00:00+09:00"),
        ])
        assertStrictlyIncreasing(dates)
    }

    func testSaturday0330_nextFourBoundaries() throws {
        let now = seoul("2026-08-15T03:30:00+09:00")
        let dates = WidgetTimelineDates.timelineDates(from: now, count: 4, calendar: calendar)
        XCTAssertEqual(dates.first, now)
        XCTAssertEqual(Array(dates.dropFirst()), [
            seoul("2026-08-15T04:00:00+09:00"),
            seoul("2026-08-15T15:00:00+09:00"),
            seoul("2026-08-16T04:00:00+09:00"),
            seoul("2026-08-16T15:00:00+09:00"),
        ])
        assertStrictlyIncreasing(dates)
    }

    private func assertStrictlyIncreasing(_ dates: [Date], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertGreaterThanOrEqual(dates.count, 2, file: file, line: line)
        for index in 0..<(dates.count - 1) {
            XCTAssertLessThan(dates[index], dates[index + 1], file: file, line: line)
        }
    }
}
