import Foundation

enum CountdownFormat {
    /// `nextWindowToggle - now`, seconds dropped, minutes floored.
    /// Negative intervals return nil. The string never includes seconds.
    static func remaining(until end: Date, now: Date) -> String? {
        let interval = end.timeIntervalSince(now)
        guard interval >= 0 else { return nil }
        let totalMinutes = Int(interval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours == 0 {
            return "앞으로 \(minutes)분"
        }
        return "앞으로 \(hours)시간 \(minutes)분"
    }
}
