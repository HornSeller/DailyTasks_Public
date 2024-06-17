//
//  SignUpViewModel.swift
//  DailyTasks
//
//  Created by Macmini on 15/03/2024.
//

import Foundation
import FirebaseAuth

final class SignUpViewModel {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    
    func createUser(completion: @escaping (AuthResult) -> Void) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                completion(.success(authResult))
            }
        }
    }
}
