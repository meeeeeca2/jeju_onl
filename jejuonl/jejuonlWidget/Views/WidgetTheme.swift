import SwiftUI
import WidgetKit

enum WidgetPalette {
    static let hallabong = Color(red: 1, green: 78 / 255, blue: 8 / 255)
    static let hallabongInk = Color(red: 224 / 255, green: 58 / 255, blue: 0)
    static let hallabongGlow = hallabong.opacity(0.5)
    static let teal0 = Color(red: 26 / 255, green: 44 / 255, blue: 48 / 255)
    static let teal1 = Color(red: 36 / 255, green: 56 / 255, blue: 61 / 255)
    static let teal2 = Color(red: 21 / 255, green: 32 / 255, blue: 36 / 255)

    static var homePlateGradient: LinearGradient {
        LinearGradient(
            colors: [
                teal1.opacity(0.72),
                teal0.opacity(0.65),
                teal2.opacity(0.75)
            ],
            startPoint: UnitPoint(x: 0.15, y: 0),
            endPoint: UnitPoint(x: 0.85, y: 1)
        )
    }
}

struct WidgetPlateFill: View {
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        if renderingMode == .accented {
            EmptyView()
        } else {
            WidgetPalette.homePlateGradient
        }
    }
}

struct WidgetPlateChrome: ViewModifier {
    @Environment(\.widgetRenderingMode) private var renderingMode

    func body(content: Content) -> some View {
        if renderingMode == .accented {
            content
                .containerBackground(for: .widget) {
                    WidgetPlateFill()
                }
        } else {
            content
                .environment(\.colorScheme, .dark)
                .containerBackground(for: .widget) {
                    WidgetPlateFill()
                }
        }
    }
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
            .widgetAccentedRenderingMode(.fullColor)
            .scaledToFill()
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .shadow(color: .black.opacity(0.22), radius: side > 48 ? 6 : 3, y: side > 48 ? 4 : 2)
            .accessibilityHidden(true)
    }
}

struct WidgetItemWithNameBadge: View {
    let item: WasteItem
    var side: CGFloat
    var corner: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            WidgetItemImage(item: item, side: side, corner: corner)
            Text(item.koreanName)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.78), in: Capsule())
                .offset(y: 3)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.koreanName)
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
