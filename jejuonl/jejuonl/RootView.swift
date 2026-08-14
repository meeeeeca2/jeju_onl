import SwiftUI

enum AppTab: Hashable {
    case today
    case week
    case settings
}

struct RootView: View {
    @Environment(AppModel.self) private var model
    @State private var tab: AppTab = .today

    var body: some View {
        TabView(selection: $tab) {
            TodayView()
                .tabItem { Label("오늘", systemImage: "clock") }
                .tag(AppTab.today)
            WeekView()
                .tabItem { Label("이번 주", systemImage: "calendar") }
                .tag(AppTab.week)
            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
        .tint(Palette.hallabong)
        .preferredColorScheme(.dark)
        .background(AppBackground())
    }
}

#Preview {
    RootView()
        .environment(AppModel(preview: true))
}
