//
//  SignUpViewModel.swift
//  DailyTasks
//
//  Created by Macmini on 15/03/2024.
//

import Foundation
import FirebaseAuth

enum AuthResult {
    case success(AuthDataResult)
    case failure(Error)
}


class SignUpViewModel {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    
    func createUser(email: String, password: String, confirmPassword: String, completion: @escaping (AuthResult) -> Void) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(authResult!))
            }
        }
    }
}
