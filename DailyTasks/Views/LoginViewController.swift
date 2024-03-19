//
//  LoginViewController.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var emailTfBackgroundImage: UIImageView!
    @IBOutlet weak var passwordTfBackgroundImage: UIImageView!
    
    var loginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        subView.layer.cornerRadius = 36
        
        emailTf.delegate = self
        passwordTf.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        subView.addGestureRecognizer(tapGesture)
<<<<<<< Updated upstream
        
//        FirebaseAuth.Auth.auth().createUser(withEmail: "duc.nm05102@gmail.com", password: "abcxyz") { (result, error) in
//            print(error)
//        }
        
=======

        if FirebaseAuth.Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }
>>>>>>> Stashed changes
    }
    
    @objc func hideKeyboard() {
        subView.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTf {
            emailTfBackgroundImage.image = UIImage(named: "emailTf1")
        } else {
            passwordTfBackgroundImage.image = UIImage(named: "passwordTf1")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTf {
            emailTfBackgroundImage.image = UIImage(named: "emailTf")
        } else {
            passwordTfBackgroundImage.image = UIImage(named: "passwordTf")
        }
    }
    
    @IBAction func signInBtnTapped(_ sender: UIButton) {
        if let email = emailTf.text, let password = passwordTf.text, !email.isEmpty, !password.isEmpty {
            loginViewModel.email = email
            loginViewModel.password = password
            loginViewModel.signIn { [self] authResult in
                print("\(loginViewModel.email) \(loginViewModel.password)")
                switch authResult {
                case .failure(let error as NSError):
                    switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        presentErrorAlert(message: "Invalid email format")
                    case AuthErrorCode.wrongPassword.rawValue:
                        presentErrorAlert(message: "Incorrect password")
                    case AuthErrorCode.userNotFound.rawValue:
                        presentErrorAlert(message: "User not found")
                    case AuthErrorCode.userDisabled.rawValue:
                        presentErrorAlert(message: "User account disabled")
                    case AuthErrorCode.operationNotAllowed.rawValue:
                        presentErrorAlert(message: "Operation not allowed")
                    case AuthErrorCode.networkError.rawValue:
                        presentErrorAlert(message: "Network error")
                    default:
                        presentErrorAlert(message: "Unknown error")
                    }
                case .success(let result):
                    print(result)
                    let alert = UIAlertController(title: "Sign-in successful", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                    }))
                    self.present(alert, animated: true)
                    return
                }
            }
        } else {
            presentErrorAlert(message: "The field cannot be empty")
        }
    }
    
    func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(SignUpViewController.makeSelf(), animated: true)
    }
}
