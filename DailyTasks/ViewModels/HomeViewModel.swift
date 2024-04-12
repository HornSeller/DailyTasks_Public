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
    
    func fetchUserData(uid: String, completion: @escaping (String, [[String: Any]]) -> Void) {
        database.child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                print("Error: Unable to fetch user data")
                return
            }
            
            let email = userData["email"] as? String ?? ""
            let tasks = userData["tasks"] as? [[String: Any]] ?? []
            
            completion(email, tasks)
        }
    }
}
