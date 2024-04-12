//
//  AddTaskViewModel.swift
//  DailyTasks
//
//  Created by Mac on 12/04/2024.
//

import Foundation
import Firebase

final class AddTaskViewModel {
    var title = ""
    var description = ""
    var startTime = ""
    var endTime = ""
    var category = ""
    var priority = ""
    var id = UUID().uuidString
    
    private var database = Database.database().reference()
    
    func createTask(uid: String) {
        let task: [String: Any] = [
            "id": id,
            "title": title,
            "description": description,
            "startTime": startTime,
            "endTime": endTime,
            "priority": priority,
            "category": category,
            "isCompleted": "false"
            
        ]
        database.child("users").child(uid).child("tasks").childByAutoId().setValue(task) { (error, databaseRef) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print(databaseRef)
        }
    }
}
