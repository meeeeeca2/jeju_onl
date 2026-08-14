import Foundation

struct AppSettings: Codable, Equatable, Sendable {
    /// 앱 헤더·오늘·주간·알림이 쓰는 현재 시. 온보딩 집 도시로 시작.
    var city: CityID?
    var hasCompletedOnboarding: Bool
    var notifications: NotificationPrefs

    /// 페이즈 3–5 및 “이미 설치된 설정 없음”이 아닌 로드 실패 시.
    /// 신규 설치 기본값이 아니다. `hasCompletedOnboarding`을 false로 바꾸지 않는다.
    static let `default` = AppSettings(
        city: nil,
        hasCompletedOnboarding: true,
        notifications: .default
    )

    /// `settings.v1` 키가 표준·앱그룹 어디에도 없을 때만. 온보딩을 띄운다.
    static let freshInstall = AppSettings(
        city: nil,
        hasCompletedOnboarding: false,
        notifications: .default
    )

    /// SwiftUI Preview · 시뮬레이터 샘플. 제품 기본 집.
    static let preview = AppSettings(
        city: .seogwipo,
        hasCompletedOnboarding: true,
        notifications: .default
    )
}

struct NotificationPrefs: Codable, Equatable, Sendable {
    var isEnabled: Bool
    var preOpenTime: ClockTime
    var eveningEnabled: Bool
    var eveningTime: ClockTime
    var watchedRestricted: Set<WasteItem>
    var includeAlwaysOn: Bool

    static let `default` = NotificationPrefs(
        isEnabled: false,
        preOpenTime: ClockTime(hour: 14, minute: 30),
        eveningEnabled: false,
        eveningTime: ClockTime(hour: 20, minute: 0),
        watchedRestricted: Set(WasteItem.allCases.filter(\.isWeekdayRestricted)),
        includeAlwaysOn: false
    )
}

struct ClockTime: Codable, Equatable, Sendable {
    var hour: Int
    var minute: Int

    func clampedPreOpen() -> ClockTime {
        clamp(min: ClockTime(hour: 4, minute: 0), max: ClockTime(hour: 14, minute: 59))
    }

    func clampedEvening() -> ClockTime {
        clamp(min: ClockTime(hour: 17, minute: 0), max: ClockTime(hour: 23, minute: 30))
    }

    private func clamp(min: ClockTime, max: ClockTime) -> ClockTime {
        if self < min { return min }
        if self > max { return max }
        return self
    }
}

extension ClockTime: Comparable {
    static func < (lhs: ClockTime, rhs: ClockTime) -> Bool {
        if lhs.hour != rhs.hour { return lhs.hour < rhs.hour }
        return lhs.minute < rhs.minute
    }
}
