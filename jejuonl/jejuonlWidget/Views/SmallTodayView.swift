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
            .padding(.horizontal, 6)
            stage
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(8)
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(WidgetCopy.statusAccessibility(snapshot))
    }

    @ViewBuilder
    private var stage: some View {
        let items = snapshot.restrictedItems
        switch items.count {
        case 0:
            Text("오늘은 제한 품목 없음")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case 1:
            SmallFittedBadge(item: items[0])
        default:
            SmallFittedFan(items: Array(items.prefix(3)), totalCount: items.count)
        }
    }
}

private struct SmallFittedBadge: View {
    let item: WasteItem

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            WidgetItemWithNameBadge(item: item, side: side, corner: side * 0.25)
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private struct SmallFittedFan: View {
    let items: [WasteItem]
    var totalCount: Int

    var body: some View {
        GeometryReader { geo in
            let count = CGFloat(max(items.count, 1))
            let overlap: CGFloat = min(36, geo.size.width * 0.28)
            let side = min(geo.size.height, (geo.size.width + overlap * (count - 1)) / count)
            ZStack(alignment: .bottomTrailing) {
                HStack(spacing: -overlap) {
                    ForEach(Array(items.enumerated()), id: \.element) { index, item in
                        WidgetItemWithNameBadge(item: item, side: side, corner: side * 0.28)
                            .zIndex(Double(index))
                    }
                }
                if totalCount > 2 {
                    Text("\(totalCount)")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(minWidth: 18, minHeight: 18)
                        .padding(.horizontal, 4)
                        .background(WidgetPalette.hallabong, in: Capsule())
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
