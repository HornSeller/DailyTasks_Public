//
//  Notification.swift
//  DailyTasks
//
//  Created by Mac on 22/05/2024.
//

import Foundation
import UserNotifications

struct NotificationItem {
    let taskId: String
    let title: String
    let body: String
    let triggerTime: Date
    var isActive: Bool
    
    func toDictionary() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        return [
            "body": body,
            "isActive": isActive,
            "taskId": taskId,
            "title": title,
            "triggerTime": dateFormatter.string(from: triggerTime),
        ]
    }
    
    static func saveScheduledNotificationID(_ id: String) {
        var scheduledNotificationIDs = UserDefaults.standard.array(forKey: "ScheduledNotificationIDs") as? [String] ?? []
        scheduledNotificationIDs.append(id)
        UserDefaults.standard.setValue(scheduledNotificationIDs, forKey: "ScheduledNotificationIDs")
    }
    
    static func isNotificationIDScheduled(_ id: String) -> Bool {
        let scheduledNotificationIDs = UserDefaults.standard.array(forKey: "ScheduledNotificationIDs") as? [String] ?? []
        return scheduledNotificationIDs.contains(id)
    }
    
    static func scheduleNotifications(from notifications: [NotificationItem]) {
        let center = UNUserNotificationCenter.current()
        
        for notification in notifications {
            // Tạo một identifier duy nhất cho mỗi thông báo
            let identifier = "\(notification.taskId)-\(notification.triggerTime.timeIntervalSince1970)"
            
            // Kiểm tra xem thông báo đã được lên lịch chưa
            if isNotificationIDScheduled(identifier) {
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = .default
            
            let triggerDate = notification.triggerTime
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    // Lưu ID của thông báo đã được lên lịch
                    saveScheduledNotificationID(identifier)
                    print("them noti thanh cong")
                }
            }
        }
    }
    
    static func deleteScheduledNotifications(identifiers: [String]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        var scheduledNotificationIDs = UserDefaults.standard.array(forKey: "ScheduledNotificationIDs") as? [String] ?? []
        var indexToDelete: [Int] = []
        for i in 0 ..< identifiers.count {
            if scheduledNotificationIDs.contains(identifiers[i]) {
                indexToDelete.append(i)
            }
        }
        for index in indexToDelete.reversed() {
            scheduledNotificationIDs.remove(at: index)
        }
        UserDefaults.standard.setValue(scheduledNotificationIDs, forKey: "ScheduledNotificationIDs")
    }
    
    static func removeAllScheduledNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
}
