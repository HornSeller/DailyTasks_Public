//
//  SignUpViewController.swift
//  DailyTasks
//
//  Created by Mac on 14/03/2024.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var confirmPasswordTf: UITextField!
    @IBOutlet weak var emailTfBackgroundImage: UIImageView!
    @IBOutlet weak var passwordTfBackgroundImage: UIImageView!
    @IBOutlet weak var confirmPasswordTfBackgroundImage: UIImageView!
    
    private let signUpViewModel = SignUpViewModel()
    private let database = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        emailTf.delegate = self
        passwordTf.delegate = self
        confirmPasswordTf.delegate = self
                
        let tapGetsure = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(tapGetsure)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        if let email = emailTf.text, let password = passwordTf.text, let confirmPassword = confirmPasswordTf.text, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty {
            if password != confirmPassword {
                presentAlert(title: "Error", message: "Your password confirmation doesn't match", actionTitle: "Try again")
                return
            }
            
            signUpViewModel.email = email
            signUpViewModel.password = password
            signUpViewModel.confirmPassword = confirmPassword
            
            signUpViewModel.createUser() { [self] authResult in
                switch authResult {
                case .failure(let error as NSError):
                    switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        presentAlert(title: "Error", message: "Invalid email format", actionTitle: "Try again")
                    case AuthErrorCode.weakPassword.rawValue:
                        presentAlert(title: "Error", message: "Weak password", actionTitle: "Try again")
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        presentAlert(title: "Error", message: "Email already in use", actionTitle: "Try again")
                    case AuthErrorCode.operationNotAllowed.rawValue:
                        presentAlert(title: "Error", message: "Operation not allowed", actionTitle: "Try again")
                    case AuthErrorCode.networkError.rawValue:
                        presentAlert(title: "Error", message: "Network error", actionTitle: "Try again")
                    default:
                        presentAlert(title: "Error", message: "Unknown error", actionTitle: "Try again")
                    }
                case .success(let authResult):
                    let user = authResult.user
                    var sampleTasks: [Task] = []
                    sampleTasks.append(Task(title: "test", description: "test", startTime: "24 Mar, 2024 00:00", endTime: "24 Mar, 2024 00:00", priority: .high, category: .none, isCompleted: false))
                    let object: [String: Any] = [
                        "email": email,
                        "tasks": sampleTasks.map { [
                            "id": $0.id,
                            "title": $0.title,
                            "description": $0.description,
                            "startTime": $0.startTime.description,
                            "endTime": $0.endTime.description,
                            "priority": $0.priority.rawValue,
                            "category": $0.category.rawValue,
                            "isCompleted": String($0.isCompleted)
                        ] }
                    ]
                    database.child("users").child(user.uid).setValue(object) { (error, ref) in
                        if let error = error {
                            print("Error saving user data: \(error.localizedDescription)")
                        } else {
                            print("User data saved successfully!")
                        }
                    }
                    presentAlert(title: "Registration successful", message: "", actionTitle: "OK")
                    print(authResult)
                }
            }
        } else {
            presentAlert(title: "Error", message: "The field cannot be empty", actionTitle: "Try again")
            return
        }
    }
    
    func presentAlert(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signInBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    static func makeSelf() -> SignUpViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let rootViewController = storyboard.instantiateViewController(identifier: "SignUpViewController") as SignUpViewController
        
        return rootViewController
    }

}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTf {
            emailTfBackgroundImage.image = UIImage(named: "emailTf1")
        } else if textField == passwordTf {
            passwordTfBackgroundImage.image = UIImage(named: "passwordTf1")
        } else {
            confirmPasswordTfBackgroundImage.image = UIImage(named: "passwordTf1")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTf {
            emailTfBackgroundImage.image = UIImage(named: "emailTf")
        } else if textField == passwordTf {
            passwordTfBackgroundImage.image = UIImage(named: "passwordTf")
        } else {
            confirmPasswordTfBackgroundImage.image = UIImage(named: "passwordTf")
        }
    }
}
