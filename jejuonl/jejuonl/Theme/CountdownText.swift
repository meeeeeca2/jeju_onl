import SwiftUI

struct CountdownText: View {
    let until: Date
    let now: Date

    var body: some View {
        if let text = CountdownFormat.remaining(until: until, now: now) {
            Text(text)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Palette.ink)
                .tracking(-0.4)
                .accessibilityLabel(text)
        }
    }
}
