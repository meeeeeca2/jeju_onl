import Foundation

protocol ScheduleCataloging: Sendable {
    var version: String { get }
    var verifiedAt: Date { get }
    func restrictedItems(city: CityID, weekday: LocaleWeekday) -> [WasteItem]
    func alwaysOnItems(city: CityID) -> [WasteItem]
    func weekdayRestrictionEnabled(city: CityID) -> Bool
}

final class CatalogBundleToken {}

struct ScheduleCatalog: ScheduleCataloging, Sendable {
    struct CitySchedule: Sendable {
        var displayName: String
        var effectiveFrom: Date
        var weekdayRestrictionEnabled: Bool
        var notes: [String]
        var restrictedByWeekday: [LocaleWeekday: [WasteItem]]
    }

    var schemaVersion: Int
    var catalogVersion: String
    var verifiedAt: Date
    var timezone: String
    var sources: [String]
    var window: WindowHours
    var alwaysOn: [WasteItem]
    var cities: [CityID: CitySchedule]

    var version: String { catalogVersion }

    struct WindowHours: Sendable {
        var openHour: Int
        var openMinute: Int
        var closeHour: Int
        var closeMinute: Int
    }

    func restrictedItems(city: CityID, weekday: LocaleWeekday) -> [WasteItem] {
        guard let citySchedule = cities[city] else { return [] }
        if citySchedule.weekdayRestrictionEnabled {
            return citySchedule.restrictedByWeekday[weekday] ?? []
        }
        return Self.uniqueUnion(of: citySchedule.restrictedByWeekday)
    }

    func alwaysOnItems(city: CityID) -> [WasteItem] {
        _ = city
        return alwaysOn
    }

    func weekdayRestrictionEnabled(city: CityID) -> Bool {
        cities[city]?.weekdayRestrictionEnabled ?? true
    }

    static func load() throws -> ScheduleCatalog {
        let candidates = [Bundle(for: CatalogBundleToken.self), .main]
        for bundle in candidates {
            if let catalog = try loadIfPresent(from: bundle) {
                return catalog
            }
        }
        throw ScheduleEngineError.catalogMissing
    }

    static func load(from bundle: Bundle) throws -> ScheduleCatalog {
        guard let catalog = try loadIfPresent(from: bundle) else {
            throw ScheduleEngineError.catalogMissing
        }
        return catalog
    }

    static func decode(_ data: Data) throws -> ScheduleCatalog {
        if let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let schemaVersion = raw["schemaVersion"] as? Int,
           schemaVersion != 1 {
            throw ScheduleEngineError.catalogSchemaTooNew(schemaVersion)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(try dayStamp())
        let dto = try decoder.decode(DTO.self, from: data)
        if dto.schemaVersion != 1 {
            throw ScheduleEngineError.catalogSchemaTooNew(dto.schemaVersion)
        }

        var cities: [CityID: CitySchedule] = [:]
        for (key, cityDTO) in dto.cities {
            guard let cityID = CityID(rawValue: key) else { continue }
            var byWeekday: [LocaleWeekday: [WasteItem]] = [:]
            for (weekdayKey, itemKeys) in cityDTO.restrictedByWeekday {
                guard let weekday = LocaleWeekday(rawValue: weekdayKey) else { continue }
                byWeekday[weekday] = try itemKeys.map(Self.wasteItem(from:))
            }
            cities[cityID] = CitySchedule(
                displayName: cityDTO.displayName,
                effectiveFrom: cityDTO.effectiveFrom,
                weekdayRestrictionEnabled: cityDTO.weekdayRestrictionEnabled ?? true,
                notes: cityDTO.notes,
                restrictedByWeekday: byWeekday
            )
        }

        return ScheduleCatalog(
            schemaVersion: dto.schemaVersion,
            catalogVersion: dto.catalogVersion,
            verifiedAt: dto.verifiedAt,
            timezone: dto.timezone,
            sources: dto.sources,
            window: WindowHours(
                openHour: dto.window.openHour,
                openMinute: dto.window.openMinute,
                closeHour: dto.window.closeHour,
                closeMinute: dto.window.closeMinute
            ),
            alwaysOn: try dto.alwaysOnItems.map(Self.wasteItem(from:)),
            cities: cities
        )
    }

    private static func loadIfPresent(from bundle: Bundle) throws -> ScheduleCatalog? {
        guard let url = bundle.url(forResource: "schedule_v1", withExtension: "json") else {
            return nil
        }
        return try decode(Data(contentsOf: url))
    }

    private static func wasteItem(from raw: String) throws -> WasteItem {
        guard let item = WasteItem(rawValue: raw) else {
            throw ScheduleEngineError.catalogItemUnknown(raw)
        }
        return item
    }

    private static func uniqueUnion(of table: [LocaleWeekday: [WasteItem]]) -> [WasteItem] {
        var seen = Set<WasteItem>()
        var union: [WasteItem] = []
        for weekday in LocaleWeekday.allCases {
            for item in table[weekday] ?? [] where seen.insert(item).inserted {
                union.append(item)
            }
        }
        return union
    }

    private static func dayStamp() throws -> DateFormatter {
        guard let tz = TimeZone(identifier: "Asia/Seoul") else {
            throw ScheduleEngineError.missingTimeZone
        }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = tz
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

private extension ScheduleCatalog {
    struct DTO: Decodable {
        var schemaVersion: Int
        var catalogVersion: String
        var verifiedAt: Date
        var timezone: String
        var sources: [String]
        var window: WindowDTO
        var alwaysOnItems: [String]
        var cities: [String: CityDTO]
    }

    struct WindowDTO: Decodable {
        var openHour: Int
        var openMinute: Int
        var closeHour: Int
        var closeMinute: Int
    }

    struct CityDTO: Decodable {
        var displayName: String
        var effectiveFrom: Date
        var weekdayRestrictionEnabled: Bool?
        var notes: [String]
        var restrictedByWeekday: [String: [String]]
    }
}
