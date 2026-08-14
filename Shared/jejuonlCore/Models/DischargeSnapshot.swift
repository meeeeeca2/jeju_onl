import Foundation

struct DischargeSnapshot: Equatable, Sendable {
    var city: CityID
    var now: Date
    var dischargeDayStart: Date
    var dischargeWeekday: LocaleWeekday
    var window: WindowState
    var windowOpen: Date
    var windowClose: Date
    var restrictedItems: [WasteItem]
    var alwaysOnItems: [WasteItem]
    var nextRestrictedChange: Date
    var nextWindowToggle: Date
    var catalogVersion: String
}
