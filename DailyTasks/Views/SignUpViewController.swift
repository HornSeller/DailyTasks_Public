//
//  SignUpViewController.swift
//  DailyTasks
//
//  Created by Mac on 14/03/2024.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var confirmPasswordTf: UITextField!
    @IBOutlet weak var emailTfBackgroundImage: UIImageView!
    @IBOutlet weak var passwordTfBackgroundImage: UIImageView!
    @IBOutlet weak var confirmPasswordTfBackgroundImage: UIImageView!

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
