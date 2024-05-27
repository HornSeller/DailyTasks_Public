//
//  LoginViewController.swift
//  DailyTasks
//
//  Created by Mac on 13/03/2024.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var emailTfBackgroundImage: UIImageView!
    @IBOutlet weak var passwordTfBackgroundImage: UIImageView!
    
    private var loginViewModel = LoginViewModel()
    private var homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        requestNotificationPermission()
        
        subView.layer.cornerRadius = 36
        
        emailTf.delegate = self
        passwordTf.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        subView.addGestureRecognizer(tapGesture)

        if FirebaseAuth.Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
    
    @objc func hideKeyboard() {
        subView.endEditing(true)
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
                return
            }
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
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
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
                        if let currentUid = Auth.auth().currentUser?.uid {
                            homeViewModel.fetchNotifications(for: currentUid) { children in
                                var notifications: [NotificationItem] = []
                                var count = 0
                                for child in children {
                                    count += 1
                                    if let notificationDict = child.value as? [String: Any],
                                       let taskId = notificationDict["taskId"] as? String,
                                       let title = notificationDict["title"] as? String,
                                       let body = notificationDict["body"] as? String,
                                       let triggerTimeString = notificationDict["triggerTime"] as? String,
                                       let isActiveString = notificationDict["isActive"] as? String,
                                       let isActive = Bool(isActiveString) {
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
                                        
                                        let triggerTime = dateFormatter.date(from: triggerTimeString)
                                        let notification = NotificationItem(taskId: taskId, title: title, body: body, triggerTime: triggerTime!, isActive: isActive)
                                        if notification.isActive {
                                            notifications.append(notification)
                                        }
                                        
                                    }
                                    if count == children.count {
                                        NotificationItem.scheduleNotifications(from: notifications)
                                    }
                                }
                            }
                        }
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

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
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
    
}
