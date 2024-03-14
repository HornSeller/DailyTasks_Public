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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        subView.layer.cornerRadius = 36
        
        emailTf.delegate = self
        passwordTf.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        subView.addGestureRecognizer(tapGesture)
        
        FirebaseAuth.Auth.auth().createUser(withEmail: "b@gmail.com", password: "abcxyz") { (result, error) in
            print(error)
        }
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
    
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        self.navigationController?.pushViewController(SignUpViewController.makeSelf(), animated: true)
    }
}
