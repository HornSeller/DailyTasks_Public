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
    private let dateFormatter = DateFormatter()
    
    func fetchUserData(uid: String, completion: @escaping ([DataSnapshot]) -> Void) {
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        var children: [DataSnapshot] = []
        database.child("users").child(uid).child("tasks").observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                children.append(child as! DataSnapshot)
            }
            completion(children)
        }
    }
}

