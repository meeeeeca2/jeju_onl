import Foundation
import WidgetKit

enum TodayLoad: Equatable, Sendable {
    case cityMissing
    case ready(DischargeSnapshot, catalogStale: Bool)
    case parseFailed
    case schemaTooNew
}

struct TodayEntry: TimelineEntry {
    var date: Date
    var load: TodayLoad
    var configuredCity: CityID
}

enum TodayLoader {
    static func load(city: CityID, at date: Date) -> TodayLoad {
        do {
            let catalog = try ScheduleCatalog.load()
            let engine = try ScheduleEngine(catalog: catalog)
            let snapshot = engine.snapshot(city: city, now: date)
            return .ready(snapshot, catalogStale: isCatalogStale(verifiedAt: catalog.verifiedAt, now: date))
        } catch let error as ScheduleEngineError {
            switch error {
            case .catalogMissing:
                return .cityMissing
            case .catalogSchemaTooNew:
                return .schemaTooNew
            case .catalogItemUnknown, .missingTimeZone:
                return .parseFailed
            }
        } catch {
            return .parseFailed
        }
    }

    static func placeholder() -> TodayEntry {
        let now = Date()
        let city = CityID.seogwipo
        do {
            _ = try ScheduleCatalog.load()
            return TodayEntry(date: now, load: load(city: city, at: now), configuredCity: city)
        } catch {
            return TodayEntry(date: now, load: .cityMissing, configuredCity: city)
        }
    }

    private static func isCatalogStale(verifiedAt: Date, now: Date) -> Bool {
        guard let calendar = try? SeoulCalendar.make(),
              let cutoff = calendar.date(byAdding: .day, value: 180, to: verifiedAt) else {
            return false
        }
        return now > cutoff
    }
}
