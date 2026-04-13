import Foundation
import UserNotifications

// MARK: - Notification Service

class NotificationService {
    static let shared = NotificationService()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
                self.scheduleDailyReminder()
            }
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleDailyReminder(dueCount: Int = 0) {
        let center = UNUserNotificationCenter.current()
        
        // Remove old notifications
        center.removePendingNotificationRequests(withIdentifiers: ["dailymath_reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = L10n.notificationTitle
        
        if dueCount > 0 {
            content.body = L10n.notificationDueCards(dueCount)
        } else {
            content.body = L10n.notificationDailyReminder
        }
        content.sound = .default
        content.badge = NSNumber(value: dueCount)
        
        // Daily at 9:00 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailymath_reminder", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
