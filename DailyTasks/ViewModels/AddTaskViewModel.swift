//
//  AddTaskViewModel.swift
//  DailyTasks
//
//  Created by Mac on 12/04/2024.
//

import Foundation
import Firebase

final class AddTaskViewModel {
    
    private var database = Database.database().reference()
    
    func createTask(uid: String, title: String, description: String, startTime: String, endTime: String, priority: String, category: String, completion: @escaping () -> Void) {
        let task: [String: Any] = [
            "title": title,
            "description": description,
            "startTime": startTime,
            "endTime": endTime,
            "priority": priority,
            "category": category,
            "isCompleted": "false"
        ]
        
        let taskRef = database.child("users").child(uid).child("tasks").childByAutoId()
        taskRef.setValue(task) { (error, databaseRef) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Task added successfully at \(databaseRef)")
            
            // Calculate notification times
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
            
            guard let startDate = dateFormatter.date(from: startTime),
                  let endDate = dateFormatter.date(from: endTime) else {
                print("Invalid date format")
                return
            }
            
            let taskDuration = endDate.timeIntervalSince(startDate)
            let halfTimeDate = startDate.addingTimeInterval(taskDuration / 2)
            let thirtyMinutesBeforeEnd = endDate.addingTimeInterval(-30 * 60)
            print("Taskduratio: \(taskDuration)\nhalftime: \(halfTimeDate)")
            // Add notifications
            self.addNotification(for: taskRef.key ?? "", uid: uid, title: "Task Reminder", body: "Your task [\(title)] is starting now!", triggerTime: startDate)
            
            self.addNotification(for: taskRef.key ?? "", uid: uid, title: "Task Reminder", body: "Your task [\(title)] is halfway done!", triggerTime: halfTimeDate)
            
            if taskDuration > 30 * 60 {
                self.addNotification(for: taskRef.key ?? "", uid: uid, title: "Task Reminder", body: "30 minutes left for task [\(title)]!", triggerTime: thirtyMinutesBeforeEnd)
            }
            completion()
        }
    }
    private func addNotification(for taskId: String, uid: String, title: String, body: String, triggerTime: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        let triggerTimeString = dateFormatter.string(from: triggerTime)
        
        let notificationData: [String: Any] = [
            "taskId": taskId,
            "title": title,
            "body": body,
            "triggerTime": triggerTimeString,
            "isActive": "true"
        ]
        
        let notificationRef = database.child("users").child(uid).child("notifications").childByAutoId()
        notificationRef.setValue(notificationData) { error, _ in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification added successfully!")
            }
        }
    }
}
