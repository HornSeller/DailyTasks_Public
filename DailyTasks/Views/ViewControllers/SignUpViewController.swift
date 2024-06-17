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
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    private let activityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    private let signUpViewModel = SignUpViewModel()
    private let database = Database.database().reference()
    private let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicatorView.color = .gray
        activityIndicatorView.center = CGPoint.init(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        view.addSubview(activityIndicatorView)
        
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        
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
        activityIndicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        backButton.isEnabled = false
        if let email = emailTf.text, let password = passwordTf.text, let confirmPassword = confirmPasswordTf.text, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty {
            if password != confirmPassword {
                presentAlert(title: "Error", message: "Your password confirmation doesn't match", actionTitle: "Try again", completion: {})
                activityIndicatorView.stopAnimating()
                view.isUserInteractionEnabled = true
                backButton.isEnabled = true
                return
            }
            
            signUpViewModel.email = email
            signUpViewModel.password = password
            signUpViewModel.confirmPassword = confirmPassword
            
            signUpViewModel.createUser() { [self] authResult in
                switch authResult {
                case .failure(let error as NSError):
                    activityIndicatorView.stopAnimating()
                    view.isUserInteractionEnabled = true
                    backButton.isEnabled = true
                    print(error)
                    switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        presentAlert(title: "Error", message: "Invalid email format", actionTitle: "Try again", completion: {})
                    case AuthErrorCode.weakPassword.rawValue:
                        presentAlert(title: "Error", message: "Weak password", actionTitle: "Try again", completion: {})
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        presentAlert(title: "Error", message: "Email already in use", actionTitle: "Try again", completion: {})
                    case AuthErrorCode.operationNotAllowed.rawValue:
                        presentAlert(title: "Error", message: "Operation not allowed", actionTitle: "Try again", completion: {})
                    case AuthErrorCode.networkError.rawValue:
                        presentAlert(title: "Error", message: "Network error", actionTitle: "Try again", completion: {})
                    default:
                        presentAlert(title: "Error", message: "Unknown error", actionTitle: "Try again", completion: {})
                    }
                case .success(let authResult):
                    activityIndicatorView.stopAnimating()
                    view.isUserInteractionEnabled = true
                    backButton.isEnabled = true
                    let user = authResult.user
                    let object: [String: Any] = [
                        "email": email,
                        "tasks": "",
                    ]
                    database.child("users").child(user.uid).setValue(object) { (error, ref) in
                        if let error = error {
                            print("Error saving user data: \(error.localizedDescription)")
                        } else {
                            print("User data saved successfully!")
                        }
                    }
                    presentAlert(title: "Registration successful", message: "", actionTitle: "OK", completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                    print(authResult)
                }
            }
        } else {
            presentAlert(title: "Error", message: "The field cannot be empty", actionTitle: "Try again", completion: {})
            activityIndicatorView.stopAnimating()
            view.isUserInteractionEnabled = true
            backButton.isEnabled = true
            return
        }
    }
    
    func presentAlert(title: String, message: String, actionTitle: String, completion: @escaping (() -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: {_ in
            completion()
        }))
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
