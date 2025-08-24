import Foundation
import UserNotifications

func scheduleMindfulnessForNextDays(
    days: Int = 60,
    provider: PositiveNoteProviding = DefaultPositiveNoteProvider()
) {
    requestNotificationPermission { granted in
        guard granted else { return }
        removeExistingMindfulnessNotifications {
            scheduleDaysAhead(days, provider: provider)
        }
    }
}

private let mindfulIDPrefix = "mindful-"

private func requestNotificationPermission(_ completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
}

private func removeExistingMindfulnessNotifications(_ completion: @escaping () -> Void) {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { requests in
        let ids = requests.map(\.identifier).filter { $0.hasPrefix(mindfulIDPrefix) }
        if !ids.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
        completion()
    }
}

private func scheduleDaysAhead(_ days: Int, provider: PositiveNoteProviding) {
    let cal = Calendar.current
    let now = Date()
    let startOfToday = cal.startOfDay(for: now)
    
    for offset in 0..<days {
        guard let day = cal.date(byAdding: .day, value: offset, to: startOfToday) else { continue }
        
        guard let fireDate = randomFireDate(on: day) else { continue }
        
        let id = notificationID(for: day)
        let note = provider.randomNote()
        scheduleOneNotification(id: id, fireDate: fireDate, title: note, body: "")
    }
}

private func randomFireDate(on day: Date, hourWindow: Range<Int> = 10..<15) -> Date? {
    let cal = Calendar.current
    let now = Date()
    
    guard
        let start = cal.date(bySettingHour: hourWindow.lowerBound, minute: 0, second: 0, of: day),
        let end   = cal.date(bySettingHour: hourWindow.upperBound,  minute: 0, second: 0, of: day),
        start < end
    else { return nil }
    
    // If it's today and we've missed the window, skip.
    if cal.isDateInToday(day), now >= end { return nil }
    
    let hour = Int.random(in: hourWindow)
    let minute = Int.random(in: 0..<60)
    var fire = cal.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? now
    
    // If we accidentally picked a past time for today, nudge into the near future.
    if cal.isDateInToday(day), fire <= now {
        fire = now.addingTimeInterval(60)
    }
    return fire
}

private func notificationID(for day: Date) -> String {
    let fmt = DateFormatter()
    fmt.calendar = Calendar(identifier: .gregorian)
    fmt.dateFormat = "yyyyMMdd"
    return mindfulIDPrefix + fmt.string(from: day)
}

private func scheduleOneNotification(id: String, fireDate: Date, title: String, body: String) {
    let cal = Calendar.current
    let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body  = body
    content.sound = .default
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

