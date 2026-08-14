import SwiftUI

struct SmallTodayView: View {
    let snapshot: DischargeSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                WidgetStatusMark(window: snapshot.window, compact: true)
                Spacer(minLength: 4)
                Text(snapshot.dischargeWeekday.shortKoreanName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            restrictedStage
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(9)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(WidgetCopy.statusAccessibility(snapshot))
    }

    @ViewBuilder
    private var restrictedStage: some View {
        let items = snapshot.restrictedItems
        switch items.count {
        case 0:
            Color.clear
        case 1:
            SingleRestrictedIcon(item: items[0], side: 120)
        case 2:
            RestrictedFan(items: items, side: 90, overlap: 42, showsCountBadge: false)
        default:
            RestrictedFan(items: Array(items.prefix(3)), side: 74, overlap: 42, showsCountBadge: true)
        }
    }
}

struct SingleRestrictedIcon: View {
    let item: WasteItem
    var side: CGFloat

    var body: some View {
        WidgetItemWithNameBadge(item: item, side: side, corner: side * 0.25)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RestrictedFan: View {
    let items: [WasteItem]
    var side: CGFloat
    var overlap: CGFloat
    var showsCountBadge: Bool

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(spacing: -overlap) {
                ForEach(Array(items.enumerated()), id: \.element) { index, item in
                    WidgetItemImage(item: item, side: side, corner: side * 0.28)
                        .zIndex(Double(index))
                }
            }
            if showsCountBadge {
                Text("\(items.count)")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(minWidth: 20, minHeight: 20)
                    .padding(.horizontal, 5)
                    .background(WidgetPalette.hallabong, in: Capsule())
                    .shadow(color: WidgetPalette.hallabongGlow, radius: 5)
                    .offset(x: 2, y: 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
