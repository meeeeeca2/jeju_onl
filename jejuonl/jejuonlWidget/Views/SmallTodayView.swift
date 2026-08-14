import SwiftUI

struct SmallTodayView: View {
    let snapshot: DischargeSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                WidgetStatusMark(window: snapshot.window, compact: true)
                Spacer(minLength: 4)
                Text(snapshot.dischargeWeekday.shortKoreanName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }

            Text(heroNames)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            if !snapshot.restrictedItems.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(snapshot.restrictedItems.prefix(3)), id: \.self) { item in
                        WidgetItemImage(item: item, side: 56, corner: 16)
                    }
                }
            }
        }
        .padding(8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(WidgetCopy.statusAccessibility(snapshot))
    }

    private var heroNames: String {
        let names = snapshot.restrictedItems.map(\.koreanName)
        return names.isEmpty ? "오늘은 제한 품목 없음" : names.joined(separator: " · ")
    }
}
