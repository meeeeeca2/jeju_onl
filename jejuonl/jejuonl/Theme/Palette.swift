import SwiftUI

enum Palette {
    static let hallabong = Color(red: 1, green: 78 / 255, blue: 8 / 255)
    static let hallabongInk = Color(red: 224 / 255, green: 58 / 255, blue: 0)
    static let hallabongGlow = Color(red: 1, green: 78 / 255, blue: 8 / 255).opacity(0.5)
    static let ink = Color(red: 244 / 255, green: 240 / 255, blue: 234 / 255)
    static let inkDim = ink.opacity(0.62)
    static let inkFaint = ink.opacity(0.40)
    static let sea = Color(red: 142 / 255, green: 196 / 255, blue: 200 / 255)
    static let basalt = Color(red: 28 / 255, green: 36 / 255, blue: 48 / 255)
    static let teal0 = Color(red: 26 / 255, green: 44 / 255, blue: 48 / 255)
    static let teal1 = Color(red: 36 / 255, green: 56 / 255, blue: 61 / 255)
    static let teal2 = Color(red: 21 / 255, green: 32 / 255, blue: 36 / 255)

    static var appBackground: LinearGradient {
        LinearGradient(
            colors: [teal1, teal0, teal2],
            startPoint: UnitPoint(x: 0.15, y: 0),
            endPoint: UnitPoint(x: 0.85, y: 1)
        )
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            Palette.appBackground
            RadialGradient(
                colors: [
                    Color(red: 56 / 255, green: 112 / 255, blue: 118 / 255).opacity(0.42),
                    .clear
                ],
                center: UnitPoint(x: 1.1, y: -0.08),
                startRadius: 10,
                endRadius: 420
            )
            RadialGradient(
                colors: [
                    Color(red: 32 / 255, green: 72 / 255, blue: 78 / 255).opacity(0.55),
                    .clear
                ],
                center: UnitPoint(x: -0.08, y: 1.08),
                startRadius: 10,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// `.buttonStyle(.plain)` only hits drawn text unless the frame is a hit target.
    func fillsHitTarget() -> some View {
        contentShape(Rectangle())
    }

    @ViewBuilder
    func appGlass<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
                .overlay {
                    shape.stroke(Color.white.opacity(0.16), lineWidth: 1)
                }
                .background(Palette.teal2.opacity(0.35), in: shape)
        }
    }
}
