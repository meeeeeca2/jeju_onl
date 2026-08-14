import SwiftUI

struct MediumTodayView: View {
    let snapshot: DischargeSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                WidgetStatusMark(window: snapshot.window, compact: false)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Spacer(minLength: 6)
                Text("\(snapshot.city.koreanName) · \(snapshot.dischargeWeekday.shortKoreanName)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Text(hint)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 8) {
                ForEach(snapshot.restrictedItems, id: \.self) { item in
                    WidgetItemImage(item: item, side: 76, corner: 20)
                        .accessibilityLabel(item.koreanName)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 2)

            Spacer(minLength: 0)

            Text(alwaysOnLine)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(mediumAccessibility)
    }

    private var hint: String {
        switch snapshot.window {
        case .open:
            return "내일 04:00에 닫혀요"
        case .beforeOpen:
            return "15:00 시작"
        }
    }

    private var alwaysOnLine: String {
        snapshot.alwaysOnItems.map(\.shortKoreanName).joined(separator: " · ")
    }

    private var mediumAccessibility: String {
        let items = snapshot.restrictedItems.map(\.koreanName).joined(separator: ", ")
        return "\(WidgetCopy.statusAccessibility(snapshot)), \(snapshot.city.koreanName), \(hint), \(items), 매일 \(alwaysOnLine)"
    }
}
