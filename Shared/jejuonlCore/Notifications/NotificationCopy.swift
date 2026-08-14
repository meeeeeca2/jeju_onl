import Foundation

enum NotificationIdentity {
    static let category = "JEJUBIN_REMIND"
    static let openToday = "OPEN_TODAY"
    static let idPrefix = "jejubin."

    static func preopen(dayStamp: String) -> String {
        "jejubin.preopen.\(dayStamp)"
    }

    static func evening(dayStamp: String) -> String {
        "jejubin.evening.\(dayStamp)"
    }
}

enum NotificationCopy {
    static let preopenTitle = "오늘 저녁부터 버릴 수 있어요"
    static let eveningTitle = "지금 배출 가능"
    static let alwaysOnOnlyTitle = "오늘은 매일 품목만"
    static let alwaysOnOnlyBody = "종량제·캔·병·스티로폼은 오늘 저녁 15:00부터 · 음식물만 지금 가능"

    static func itemName(_ item: WasteItem) -> String {
        switch item {
        case .clearPET: return "투명페트병"
        case .paper: return "종이류"
        case .vinyl: return "비닐류"
        default: return item.koreanName
        }
    }

    static func joinedItems(_ items: [WasteItem]) -> String {
        items.map(itemName).joined(separator: ", ")
    }

    static func preopenBody(items: [WasteItem], city: CityID) -> String {
        "\(joinedItems(items)) · 15:00–내일 04:00 · \(city.koreanName)"
    }

    static func eveningBody(items: [WasteItem]) -> String {
        "\(joinedItems(items)) · 창구 내일 04:00에 닫혀요"
    }
}
