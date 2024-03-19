//
//  LoginViewModel.swift
//  DailyTasks
//
//  Created by Mac on 16/03/2024.
//

import Foundation
import FirebaseAuth

enum AuthResult {
    case success(AuthDataResult)
    case failure(Error)
}

final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    
    func signIn(completion: @escaping (AuthResult) -> Void) {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                completion(.success(authResult))
            }
        }
    }
}
