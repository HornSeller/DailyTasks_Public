//
//  HomeViewModel.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import Foundation
import Firebase

final class HomeViewModel {
    
    private let database = Database.database().reference()
    
    func fetchUserData(uid: String, completion: @escaping ([DataSnapshot]) -> Void) {
        var children: [DataSnapshot] = []
        database.child("users").child(uid).child("tasks").observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                children.append(child as! DataSnapshot)
            }
            completion(children)
        }
    }
    
    func fetchNotifications(for uid: String, completion: @escaping ([DataSnapshot]) -> Void) {
        var children: [DataSnapshot] = []
        let notificationsRef = database.child("users").child(uid).child("notifications")
        
        notificationsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    children.append(childSnapshot)
                }
            }
            
            completion(children)
        }
    }
    
    private func filterNotifications(with taskId: String, from snapshots: [DataSnapshot]) -> [DataSnapshot] {
        return snapshots.filter { snapshot in
            if let notificationData = snapshot.value as? [String: Any],
               let taskIdValue = notificationData["taskId"] as? String {
                return taskIdValue == taskId
            }
            return false
        }
    }
    
    private func updateNotificationsStatus(for uid: String, taskId: String, with status: Bool) {
        fetchNotifications(for: uid) { snapshots in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
            
            var notifications: [NotificationItem] = []
            var identifiers: [String] = []
            let filteredSnapshots = self.filterNotifications(with: taskId, from: snapshots)
            
            var count = 0
            for snapshot in filteredSnapshots {
                count += 1
                let notificationRef = snapshot.ref
                notificationRef.updateChildValues(["isActive": "\(status)"]) { error, _ in
                    if let error = error {
                        print("Error updating notification: \(error.localizedDescription)")
                    } else {
                        print("Notification updated successfully.")
                    }
                }
                if status {
                    if let notificationDict = snapshot.value as? [String: Any],
                       let taskId = notificationDict["taskId"] as? String,
                       let title = notificationDict["title"] as? String,
                       let body = notificationDict["body"] as? String,
                       let triggerTimeString = notificationDict["triggerTime"] as? String,
                       let isActiveString = notificationDict["isActive"] as? String,
                       let isActive = Bool(isActiveString) {
                        
                        let triggerTime = dateFormatter.date(from: triggerTimeString)
                        
                        notifications.append(NotificationItem(taskId: taskId, title: title, body: body, triggerTime: triggerTime!, isActive: isActive))
                    }
                    if count == filteredSnapshots.count {
                        NotificationItem.scheduleNotifications(from: notifications)
                    }
                }
                else {
                    if let notificationData = snapshot.value as? [String: Any],
                       let taskIdValue = notificationData["taskId"] as? String,
                       taskIdValue == taskId,
                       let triggerTimeString = notificationData["triggerTime"] as? String,
                       let triggerTime = dateFormatter.date(from: triggerTimeString) {
                        let identifier = "\(taskId)-\(triggerTime.timeIntervalSince1970)"
                        identifiers.append(identifier)
                    }
                    if count == filteredSnapshots.count {
                        NotificationItem.deleteScheduledNotifications(identifiers: identifiers)
                    }
                }
            }
            
        }
    }

    func updateTaskCompletionStatus(withId taskId: String, setStatus status: Bool) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        let uid = currentUser.uid
        let taskRef = database.child("users").child(uid).child("tasks").child(taskId)
        
        taskRef.updateChildValues(["isCompleted": "\(status)"]) { (error, _) in
            if let error = error {
                print("Error updating task completion status:", error.localizedDescription)
            } else {
                print("Task completion status updated successfully!")
            }
        }
        
        updateNotificationsStatus(for: uid, taskId: taskId, with: !status)
    }
    
    func deleteTask(withId taskId: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        let uid = currentUser.uid
        let taskRef = database.child("users").child(uid).child("tasks").child(taskId)
        
        taskRef.removeValue() { (error, _) in
            if let error = error {
                print("Error deleting task:", error.localizedDescription)
            } else {
                print("Task deleted successfully!")
                self.deleteNotifications(for: uid, taskId: taskId)
            }
        }
    }
    
    func deleteNotifications(for uid: String, taskId: String) {
        fetchNotifications(for: uid) { snapshots in
            let identifiers = self.getNotificationIdentifiers(for: taskId, from: snapshots)
            let filteredSnapshots = self.filterNotifications(with: taskId, from: snapshots)
            
            for snapshot in filteredSnapshots {
                let notificationRef = snapshot.ref
                notificationRef.removeValue() { (error, _) in
                    if let error = error {
                        print("Error deleting notification:", error.localizedDescription)
                    } else {
                        print("Notification deleted successfully!")
                        NotificationItem.deleteScheduledNotifications(identifiers: identifiers)
                    }
                }
            }
        }
    }
    
    private func getNotificationIdentifiers(for taskId: String, from snapshots: [DataSnapshot]) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        var identifiers: [String] = []
        for snapshot in snapshots {
            if let notificationData = snapshot.value as? [String: Any],
               let taskIdValue = notificationData["taskId"] as? String,
               taskIdValue == taskId,
               let triggerTimeString = notificationData["triggerTime"] as? String,
               let triggerTime = dateFormatter.date(from: triggerTimeString) {
                let identifier = "\(taskId)-\(triggerTime.timeIntervalSince1970)"
                identifiers.append(identifier)
            }
        }
        return identifiers
    }
}

