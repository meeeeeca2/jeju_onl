import SwiftUI

enum WidgetPalette {
    static let hallabong = Color(red: 1, green: 78 / 255, blue: 8 / 255)
    static let hallabongInk = Color(red: 224 / 255, green: 58 / 255, blue: 0)
    static let hallabongGlow = hallabong.opacity(0.5)
}

enum WidgetClockText {
    static func hm(_ date: Date) -> String {
        guard let calendar = try? SeoulCalendar.make() else { return "" }
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return String(format: "%02d:%02d", hour, minute)
    }

    static func windowRange(open: Date, close: Date) -> String {
        "\(hm(open))–\(hm(close))"
    }
}

struct WidgetItemImage: View {
    let item: WasteItem
    var side: CGFloat
    var corner: CGFloat

    var body: some View {
        Image(item.assetName)
            .resizable()
            .scaledToFill()
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: side > 48 ? 6 : 3, y: side > 48 ? 4 : 2)
            .accessibilityHidden(true)
    }
}

struct WidgetMessageView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.8)
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WidgetStatusMark: View {
    let window: WindowState
    var compact: Bool

    var body: some View {
        Text(title)
            .font(.system(size: compact ? 10 : 12, weight: .bold))
            .foregroundStyle(window == .open ? WidgetPalette.hallabong : Color.secondary)
    }

    private var title: String {
        switch window {
        case .open:
            return compact ? "지금" : "지금 배출 가능"
        case .beforeOpen:
            return compact ? "저녁부터" : "오늘 저녁부터"
        }
    }
}

enum WidgetCopy {
    static func statusAccessibility(_ snapshot: DischargeSnapshot) -> String {
        let weekday = snapshot.dischargeWeekday.koreanName
        let items = snapshot.restrictedItems.map(\.koreanName).joined(separator: ", ")
        switch snapshot.window {
        case .open:
            return "\(items), 지금 배출 가능, \(weekday)"
        case .beforeOpen:
            return "\(items), 오늘 저녁부터, \(weekday)"
        }
    }
}
