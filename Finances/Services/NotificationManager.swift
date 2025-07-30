import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Authorization
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
            print("Notification permission granted: \(granted)")
        }
    }
    // MARK: - Schedule Notifications
    /// Schedule a notification for a transaction that occurs today
    /// For testing: 1 minute after creation
//    func scheduleTransactionNotification(title: String, amount: Double, date: Date) {
//        let content = UNMutableNotificationContent()
//        content.title = "💸 Transaction Reminder"
//        content.body = "Don't forget: \(title) - $\(String(format: "%.2f", amount))"
//        content.sound = .default
//        content.badge = 1
//        
//        // For testing: trigger 1 minute from now
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
//        
//        // Create unique identifier using transaction details
//        let identifier = "transaction_\(title)_\(Int(date.timeIntervalSince1970))"
//        
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            } else {
//                print("Notification scheduled successfully for: \(title)")
//            }
//        }
//    }
    
    /// Schedule a daily notification at 8:00 AM for transaction reminders
    func scheduleDailyTransactionReminders(title: String, amount: Double, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "💸 Transaction Reminder"
        content.body = "Don't forget: \(title) - $\(String(format: "%.2f", amount))"
        content.sound = .default
        content.badge = 1
        
        // Create date components for 8:00 AM of the transaction date
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 8
        dateComponents.minute = 0
        dateComponents.second = 0
        
        // Create calendar trigger for 8:00 AM
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create unique identifier using transaction date (daily grouping)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        let identifier = "daily_transactions_\(dateString)"
        
        // Check if notification for this date already exists
        checkExistingNotification(identifier: identifier) { [weak self] exists in
            if exists {
                // Update existing notification with multiple transactions
                self?.updateExistingNotification(identifier: identifier, newTitle: title, newAmount: amount)
            } else {
                 // Create new notification
                 let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                 
                 UNUserNotificationCenter.current().add(request) { error in
                     if let error = error {
                         print("Error scheduling notification: \(error.localizedDescription)")
                     } else {
                         print("Daily notification scheduled successfully for: \(title) at 8:00 AM")
                     }
                 }
             }
         }
    }
    
    // MARK: - Helper Methods for Daily Notifications
    /// Check if a notification with specific identifier already exists
    private func checkExistingNotification(identifier: String, completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let exists = requests.contains { $0.identifier == identifier }
            DispatchQueue.main.async {
                completion(exists)
            }
        }
    }
    /// Update existing notification to include multiple transactions
    private func updateExistingNotification(identifier: String, newTitle: String, newAmount: Double) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            guard let existingRequest = requests.first(where: { $0.identifier == identifier }) else {
                return
            }
            
            // Cancel existing notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
            
            // Create updated content with multiple transactions
            let content = UNMutableNotificationContent()
            content.title = "💸 Daily Transaction Reminders"
            content.body = "You have multiple transactions scheduled for today. Tap to view details."
            content.sound = .default
            content.badge = 1
            
            // Create new request with same trigger
            let newRequest = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: existingRequest.trigger
            )
            
            UNUserNotificationCenter.current().add(newRequest) { error in
                if let error = error {
                    print("Error updating notification: \(error.localizedDescription)")
                } else {
                    print("Daily notification updated successfully")
                }
            }
        }
    }
    
    // MARK: - Cancel Notifications
    /// Cancel a specific notification by identifier
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled notification with identifier: \(identifier)")
    }
    
    /// Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }
    
    // MARK: - Helper Methods
    /// Check if notifications are authorized
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}
