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
    
    func updateTaskCompletionStatus(withId taskId: String, isCompleted: Bool) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        let uid = currentUser.uid
        let taskRef = database.child("users").child(uid).child("tasks").child(taskId)
        
        taskRef.updateChildValues(["isCompleted": "\(isCompleted)"]) { (error, _) in
            if let error = error {
                print("Error updating task completion status:", error.localizedDescription)
            } else {
                print("Task completion status updated successfully!")
            }
        }
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
            }
        }
    }
}

