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
            let filteredSnapshots = self.filterNotifications(with: taskId, from: snapshots)
            
            for snapshot in filteredSnapshots {
                let notificationRef = snapshot.ref
                notificationRef.updateChildValues(["isActive": "\(status)"]) { error, _ in
                    if let error = error {
                        print("Error updating notification: \(error.localizedDescription)")
                    } else {
                        print("Notification updated successfully.")
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
                        print(UserDefaults.standard.array(forKey: "ScheduledNotificationIDs"))
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

