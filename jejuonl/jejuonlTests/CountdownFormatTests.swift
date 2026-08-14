import XCTest

final class CountdownFormatTests: XCTestCase {
    func testHoursAndMinutesIncludesPrefix() {
        let now = seoul("2026-08-14T12:49:00+09:00")
        let end = seoul("2026-08-14T15:00:00+09:00")
        XCTAssertEqual(CountdownFormat.remaining(until: end, now: now), "앞으로 2시간 11분")
    }

    func testExactOneHourKeepsZeroMinutes() {
        let now = seoul("2026-08-14T14:00:00+09:00")
        let end = seoul("2026-08-14T15:00:00+09:00")
        XCTAssertEqual(CountdownFormat.remaining(until: end, now: now), "앞으로 1시간 0분")
    }

    func testMinutesOnlyWhenUnderOneHour() {
        let now = seoul("2026-08-14T14:49:00+09:00")
        let end = seoul("2026-08-14T15:00:00+09:00")
        XCTAssertEqual(CountdownFormat.remaining(until: end, now: now), "앞으로 11분")
    }

    func testDropsSecondsAndFloorsMinutes() {
        let now = seoul("2026-08-14T14:00:00+09:00")
        let end = seoul("2026-08-14T15:00:59+09:00")
        XCTAssertEqual(CountdownFormat.remaining(until: end, now: now), "앞으로 1시간 0분")

        let almostTwo = seoul("2026-08-14T13:00:01+09:00")
        XCTAssertEqual(CountdownFormat.remaining(until: end, now: almostTwo), "앞으로 2시간 0분")

        let fiftyNineSeconds = seoul("2026-08-14T14:59:01+09:00")
        XCTAssertEqual(CountdownFormat.remaining(until: end, now: fiftyNineSeconds), "앞으로 1분")
    }

    func testZeroIntervalIsZeroMinutes() {
        let now = seoul("2026-08-14T15:00:00+09:00")
        XCTAssertEqual(CountdownFormat.remaining(until: now, now: now), "앞으로 0분")
    }

    func testNegativeIntervalIsNil() {
        let now = seoul("2026-08-14T15:01:00+09:00")
        let end = seoul("2026-08-14T15:00:00+09:00")
        XCTAssertNil(CountdownFormat.remaining(until: end, now: now))
    }

    func testStringNeverMentionsSeconds() {
        let now = seoul("2026-08-14T12:49:30+09:00")
        let end = seoul("2026-08-14T15:00:45+09:00")
        let text = CountdownFormat.remaining(until: end, now: now)
        XCTAssertEqual(text, "앞으로 2시간 11분")
        XCTAssertFalse(text?.contains("초") ?? true)
    }
}
